-- MotorCurrentReader: três fluxos no mesmo socket :5055
--   1) ACUMULAÇÃO (todo poll): lê o registrador Modbus local, converte raw→A
--      e atualiza Acc[guid] (soma/n/max/min/ultima) da janela atual.
--   2) LIVE (1Hz): envia 'tipo:"correntes"' com {id, correnteAtual=ultima}
--      de TODOS os motores. Drives o gráfico em tempo real do front.
--   3) HISTÓRICO consolidado (1×/min) com FILA persistente em RAM:
--      Ao fechar a janela de 60s, captura UM os.time() (timestamp DA medição)
--      e empurra todos os motores acumulados na Fila com esse timestamp.
--      A Fila drena 1 item por poll (gap DrainStaggerMs). Item só sai da
--      fila depois que o backend ACK 'OK'. Em falha de TCP ou sem ACK,
--      MANTÉM o item na fila e tenta no próximo tick.
--
-- TIMESTAMP: CRÍTICO — o timestamp gravado no Influx tem que ser DA MEDIÇÃO,
-- não da chegada no backend nem do reenvio. Por isso `os.time()` é capturado
-- UMA VEZ por janela (em FecharJanelaParaFila) e fica preso ao item.
--
-- FILA EM RAM (sem disco): limite FilaMax=50000 itens (~38h a 22 motores/min).
-- Ao atingir o limite, descarta o mais antigo (FIFO). Tamanho atual da fila é
-- exposto no registro Word @W_HDW301 (visível na tela da IHM). Sentinela de
-- memória via collectgarbage("count") logado a cada minuto.
--
-- REGISTROS EXPOSTOS NA IHM:
--   @W_HDW301 = tamanho atual da fila pendente (0..65535)
--   @W_HDW302 = % GERAL de envios bem-sucedidos nos últimos PctIntervalMs (0..100)
--   @W_HDW303 = % do fluxo LIVE (correntes 1Hz) — sucesso = TCP send aceitou
--   @W_HDW304 = % do fluxo HISTÓRICO (drain da fila) — sucesso = ACK "OK"
--   Sem amostra na janela = 100 (canal saudável).
--
-- O log a cada janela imprime tudo discriminado:
--   "3s | geral X% (ok/tot) | live X% (ok/tot) | hist X% (ok/tot tcpFail=N semAck=N ackErr=N) | fila=N"
-- Onde tcpFail = TCP send retornou false; semAck = send OK mas ACK não veio
-- em AckTimeoutSec; ackErr = backend respondeu "ERROR...".
--
-- ARQUITETURA (2026-05-25): IHM lê corrente do registrador, aplica aferição
-- local (raw/100 = centésimos de Ampere → A) e manda já em AMPERES. Backend
-- usa limiar de 5 A pra integrar horímetro. Status (ligado/desligado) é
-- derivado na UI a partir da corrente.
--
-- Payload atual:
--   correntes: {"tipo":"correntes","timestamp":<unix_s>,"plantaId":"<uuid>",
--               "motores":[{"id","correnteAtual"}]}
--   historico: {"tipo":"historico","timestamp":<unix_s>,"plantaId":"<uuid>",
--               "id","correnteAtual","correnteMedia","correnteMaxima","correnteMinima"}
-- Valores em AMPERES (float). Aferição vive aqui; ajustar `FatorEscala` se o
-- registrador do PLC mudar de escala.

local json = require("json")

MotorCurrentReader = {}
MotorCurrentReader.__index = MotorCurrentReader

function MotorCurrentReader:new(motorSync, socketClient)
    local obj = {}
    setmetatable(obj, MotorCurrentReader)

    obj.MotorSync    = motorSync
    obj.SocketClient = socketClient
    obj.Enabled      = true

    -- ====== TUNÁVEIS ======
    obj.LiveIntervalMs    = 1000     -- envio 'correntes' a 1Hz (Acc continua sendo lido em todo poll)
    obj.HistIntervalMs    = 60000    -- fecha janela de média a cada 60s
    obj.DrainStaggerMs    = 150      -- gap entre envios de itens da fila (~6.6/s)
    obj.RamLogIntervalMs  = 60000    -- log periódico de RAM/fila
    obj.PctIntervalMs     = 3000     -- janela do % de acertos do socket (3s = sensível)
    obj.FilaMax           = 50000    -- limite da fila em RAM (~38h)
    obj.RegistroFilaPend  = "@W_HDW301"  -- Word: tamanho da fila pendente
    obj.RegistroPctAcerto = "@W_HDW302"  -- Word: % geral de envios bem-sucedidos (0-100)
    obj.RegistroPctLive   = "@W_HDW303"  -- Word: % específico do fluxo live (correntes)
    obj.RegistroPctHist   = "@W_HDW304"  -- Word: % específico do fluxo histórico (drain da fila)
    obj.AckTimeoutSec     = 0.5      -- timeout pra ler 'OK' do backend após enviar histórico

    -- Aferição: o registrador do PLC reporta corrente em centésimos de Ampere
    -- (raw 247 = 2,47 A). Se o eletricista ajustar a escala no CT, mudar aqui.
    obj.FatorEscala       = 1 / 100  -- raw → Amperes
    -- ======================
    -- (sem LimiarLigado: IHM não decide status; backend decide.)

    local agora = we_bas_gettickcount()
    obj.LastLiveTime    = agora
    obj.LastHistTime    = agora      -- início da janela atual
    obj.LastDrainTime   = agora
    obj.LastRamLogTime  = agora
    obj.LastPctTime     = agora      -- início da janela de % acertos

    -- Acumulador da janela ATUAL (zera ao fechar a janela)
    obj.Acc = {}                     -- guid -> {soma,n,max,min,ultima} em AMPERES
    -- Fila persistente de itens prontos para envio
    obj.Fila = {}                    -- array FIFO: {id, ts, atual, media, max, min}

    -- Contadores da janela do % de acertos (resetados após gravar em @W_HDW302).
    -- Separados por fluxo + causa de falha pra identificar onde o canal "fura".
    obj.LiveTentados      = 0  -- envios de 'correntes' (1Hz)
    obj.LiveOK            = 0  -- TCP send aceitou
    obj.HistTentados      = 0  -- envios de 'historico' (drain da fila)
    obj.HistOK            = 0  -- backend respondeu "OK"
    obj.HistFalhaTcp      = 0  -- send do TCP falhou (socket morto)
    obj.HistSemAck        = 0  -- send OK mas backend não respondeu em AckTimeoutSec
    obj.HistAckError      = 0  -- backend respondeu "ERROR..." (rejeição explícita)

    -- Garantir que os registros começam em valores neutros
    pcall(function() we_bas_setint(obj.RegistroFilaPend, 0) end)
    pcall(function() we_bas_setint(obj.RegistroPctAcerto, 100) end)  -- sem amostra = 100% saudável
    pcall(function() we_bas_setint(obj.RegistroPctLive, 100) end)
    pcall(function() we_bas_setint(obj.RegistroPctHist, 100) end)

    return obj
end

local function novoAcc()
    return { soma = 0, n = 0, max = nil, min = nil, ultima = 0 }
end

-- Atualiza @W_HDW301 com o tamanho atual da fila (clampado a 65535 = Word máx).
function MotorCurrentReader:AtualizarRegistroFila()
    local n = #self.Fila
    if n > 65535 then n = 65535 end
    pcall(function() we_bas_setint(self.RegistroFilaPend, n) end)
end

-- Insere item no fim da fila. Se atingir FilaMax, descarta os mais antigos.
function MotorCurrentReader:PushFila(item)
    while #self.Fila >= self.FilaMax do
        table.remove(self.Fila, 1)  -- FIFO: descarta mais antigo
    end
    table.insert(self.Fila, item)
end

-- Lê todos os motores em TODO ciclo de poll.
-- Converte raw → Amperes e acumula soma/n/max/min/ultima para a janela.
function MotorCurrentReader:Ler()
    if not self.MotorSync or not self.MotorSync.Inicializado then return end
    local mm = self.MotorSync.MotoresMemoria
    if not mm then return end

    for guid, motorData in pairs(mm) do
        local motor = motorData.motor
        if motor and motor.RegistroLocal and motor.RegistroLocal ~= "" then
            -- 16-bit: lê SÓ o registro do próprio motor (fix do word alto)
            local raw = we_bas_getword(motor.RegistroLocal)
            if raw ~= nil then
                raw = tonumber(raw) or 0
                if raw < 0 then raw = 0 end
                -- 0xFFFF = registrador não inicializado / falha de sensor → trata como 0
                if raw >= 65535 then raw = 0 end

                -- Aferição: raw → Amperes. Daqui pra frente tudo está em A.
                local amperes = raw * self.FatorEscala

                local acc = self.Acc[guid]
                if not acc then acc = novoAcc(); self.Acc[guid] = acc end

                if acc.max == nil or amperes > acc.max then acc.max = amperes end
                if acc.min == nil or amperes < acc.min then acc.min = amperes end
                acc.ultima = amperes
                acc.soma = acc.soma + amperes
                acc.n = acc.n + 1

                motor:setCorrenteAtual(amperes)
            end
        end
    end
end

-- LIVE (1Hz): array 'correntes' com {id, correnteAtual=ultima} de todos motores.
-- Não toca a janela de Acc (que continua acumulando para o consolidado).
function MotorCurrentReader:EnviarLive()
    if not self.SocketClient then return end
    local mm = self.MotorSync and self.MotorSync.MotoresMemoria
    if not mm then return end

    local arr = {}
    for guid, motorData in pairs(mm) do
        local motor = motorData.motor
        local acc = self.Acc[guid]
        if motor and motor.GUID and acc then
            table.insert(arr, {
                id            = motor.GUID,
                correnteAtual = acc.ultima
            })
        end
    end
    if #arr > 0 then
        local plantaId = self.MotorSync and self.MotorSync.PlantaUUID or nil
        -- EnviarCorrentesArray serializa {tipo='correntes',plantaId,motores=arr,
        -- timestamp=os.time()}+'\n'. Backend agora não responde OK (fire-and-forget),
        -- então não há acúmulo de OKs no buffer da IHM.
        -- Conta para o % de acertos do socket: live só tem garantia TCP (kernel
        -- aceitou o send); falha aqui = conexão morta ou kernel cheio.
        local ok, errLive = self.SocketClient:EnviarCorrentesArray(arr, plantaId)
        self.LiveTentados = self.LiveTentados + 1
        if ok then
            self.LiveOK = self.LiveOK + 1
        else
            print("[CurrentReader] live ✗ TCP send falhou: " .. tostring(errLive))
        end
    end
end

-- Fecha a janela atual: captura tsJanela uma vez, empurra todos os motores
-- com acumulador não-vazio para a Fila com esse timestamp, e zera o Acc.
function MotorCurrentReader:FecharJanelaParaFila()
    local tsJanela = os.time()  -- ⚠ timestamp DA medição — fica preso ao item
    local mm = self.MotorSync and self.MotorSync.MotoresMemoria
    if not mm then return end

    local enfileirados = 0
    for guid, motorData in pairs(mm) do
        local motor = motorData.motor
        local acc = self.Acc[guid]
        if motor and motor.GUID and acc and acc.n > 0 then
            local media = acc.soma / acc.n
            self:PushFila({
                id    = motor.GUID,
                ts    = tsJanela,
                atual = acc.ultima,
                media = media,
                max   = acc.max or acc.ultima,
                min   = acc.min or acc.ultima
            })
            enfileirados = enfileirados + 1
        end
        -- zera o acc do motor independente de ter sido enfileirado
        self.Acc[guid] = novoAcc()
    end

    if enfileirados > 0 then
        self:AtualizarRegistroFila()
        print(string.format("[CurrentReader] janela ts=%d enfileirou %d (fila=%d)",
            tsJanela, enfileirados, #self.Fila))
    end
end

-- Envia 1 item da Fila e tenta ler o ACK do backend.
-- Remove o item APENAS se receber 'OK'. Em timeout/falha TCP, mantém para
-- tentar de novo no próximo tick.
function MotorCurrentReader:DrenarUmDaFila()
    local item = self.Fila[1]
    if not item then return end
    if not self.SocketClient then return end

    local msg = {
        tipo           = "historico",
        timestamp      = item.ts,                                       -- ⚠ timestamp DA medição
        plantaId       = self.MotorSync and self.MotorSync.PlantaUUID or nil,
        id             = item.id,
        correnteAtual  = item.atual,
        correnteMedia  = item.media,
        correnteMaxima = item.max,
        correnteMinima = item.min
    }

    -- Cada drain conta como 1 envio tentado (sucesso = ACK "OK" recebido).
    self.HistTentados = self.HistTentados + 1

    local sent, errSend = self.SocketClient:EnviarMensagem(json.encode(msg))
    if not sent then
        -- TCP morto. Item fica no início da fila pra próxima tentativa.
        self.HistFalhaTcp = self.HistFalhaTcp + 1
        print("[CurrentReader] hist ✗ TCP send falhou: " .. tostring(errSend))
        return
    end

    -- Tenta ler ACK com timeout curto pra não congelar a UI
    local resp, errR = self.SocketClient:ReceberMensagem(self.AckTimeoutSec)
    if resp then
        resp = string.gsub(resp, "\n", "")
        if resp == "OK" or string.find(resp, "OK", 1, true) then
            -- Backend confirmou — remove da fila
            self.HistOK = self.HistOK + 1
            table.remove(self.Fila, 1)
            self:AtualizarRegistroFila()
        else
            -- Backend rejeitou explicitamente (ERROR: ...).
            -- Não adianta reenviar — DESCARTA pra não loopar infinitamente.
            self.HistAckError = self.HistAckError + 1
            print("[CurrentReader] hist ✗ Server rejeitou ts=" .. tostring(item.ts)
                  .. " id=" .. tostring(item.id) .. " resp=" .. tostring(resp))
            table.remove(self.Fila, 1)
            self:AtualizarRegistroFila()
        end
    else
        -- Sem ACK (timeout). Conservador: MANTÉM na fila.
        -- Risco: duplicar se backend gravou mas o ACK não chegou.
        self.HistSemAck = self.HistSemAck + 1
        -- Logar com baixa freq porque acontece bastante em rede ruim
        -- (mas o usuário pediu pra entender quem fura — então logamos sempre)
        print("[CurrentReader] hist ⚠ sem ACK em " .. tostring(self.AckTimeoutSec)
              .. "s ts=" .. tostring(item.ts) .. " id=" .. tostring(item.id))
    end
end

-- Calcula o percentual de envios bem-sucedidos na janela do último minuto
-- e grava em @W_HDW302 (Word, 0..100). Se nenhum envio na janela, assume
-- 100 (sem amostra = nada a reclamar). Reseta os contadores no fim.
-- Calcula percentual robusto: se 0 amostras → 100 (neutro), clampa [0,100].
local function pctSeguro(ok, total)
    if total <= 0 then return 100 end
    local p = math.floor((ok * 100) / total + 0.5)
    if p < 0 then p = 0 end
    if p > 100 then p = 100 end
    return p
end

-- Calcula e grava os percentuais nos registros + log detalhado SEMPRE.
-- Discrimina causas de falha do histórico (tcp/sem ack/error) pra identificar
-- qual ponto do pipeline está furando.
function MotorCurrentReader:GravarPctAcertos()
    local pctLive  = pctSeguro(self.LiveOK, self.LiveTentados)
    local pctHist  = pctSeguro(self.HistOK, self.HistTentados)
    local totalOK  = self.LiveOK + self.HistOK
    local totalTen = self.LiveTentados + self.HistTentados
    local pctGeral = pctSeguro(totalOK, totalTen)

    pcall(function() we_bas_setint(self.RegistroPctAcerto, pctGeral) end)
    pcall(function() we_bas_setint(self.RegistroPctLive,   pctLive) end)
    pcall(function() we_bas_setint(self.RegistroPctHist,   pctHist) end)

    -- Log SEMPRE quando houve qualquer envio na janela. Janela de 3s + 1Hz live
    -- = ~3 prints/min em saúde plena. Quando dá problema, o operador vê causa.
    if totalTen > 0 then
        print(string.format(
            "[CurrentReader] %ds | geral %d%% (%d/%d) | live %d%% (%d/%d) | hist %d%% (%d/%d ok:tcpFail=%d semAck=%d ackErr=%d) | fila=%d",
            self.PctIntervalMs / 1000,
            pctGeral, totalOK, totalTen,
            pctLive,  self.LiveOK, self.LiveTentados,
            pctHist,  self.HistOK, self.HistTentados,
            self.HistFalhaTcp, self.HistSemAck, self.HistAckError,
            #self.Fila
        ))
    end

    -- Reseta a janela
    self.LiveTentados = 0
    self.LiveOK = 0
    self.HistTentados = 0
    self.HistOK = 0
    self.HistFalhaTcp = 0
    self.HistSemAck = 0
    self.HistAckError = 0
end

-- Sentinela de memória: loga uso do Lua VM e tamanho da fila.
function MotorCurrentReader:LogRam()
    local kb = collectgarbage("count")  -- KB usados pelo Lua VM (incluindo Fila)
    print(string.format("[CurrentReader] RAM lua=%.1fKB fila=%d/%d (%.1f%%)",
        kb, #self.Fila, self.FilaMax, (#self.Fila / self.FilaMax) * 100))
end

-- Chamado no we_bg_poll. Política por tick:
--   1) Sempre lê e acumula (rápido)
--   2) Se passou 60s desde início da janela → fecha janela → enfileira → sync REST
--   3) Se há item na fila E passou DrainStaggerMs → drena 1 item (retorna, não envia live no mesmo tick)
--   4) Se passou LiveIntervalMs → envia live
--   5) Periódico: log de RAM
function MotorCurrentReader:Loop()
    if not self.Enabled then return end

    local agora = we_bas_gettickcount()
    -- Sanidade: tickcount voltou (overflow / reboot)
    if agora < self.LastLiveTime    then self.LastLiveTime    = agora end
    if agora < self.LastHistTime    then self.LastHistTime    = agora end
    if agora < self.LastDrainTime   then self.LastDrainTime   = agora end
    if agora < self.LastRamLogTime  then self.LastRamLogTime  = agora end
    if agora < self.LastPctTime     then self.LastPctTime     = agora end

    -- (1) leitura/acumulação em todo poll
    self:Ler()

    -- (2) fim de janela: empurra Acc → Fila e dispara sync REST
    if (agora - self.LastHistTime) >= self.HistIntervalMs then
        self.LastHistTime = agora
        self:FecharJanelaParaFila()
        if self.MotorSync and self.MotorSync.Sincronizar then
            -- Sync REST traz horímetro consolidado do backend (independe da fila TCP)
            self.MotorSync:Sincronizar()
        end
    end

    -- (3) drain contínuo da fila — prioridade sobre o live
    if #self.Fila > 0 and (agora - self.LastDrainTime) >= self.DrainStaggerMs then
        self.LastDrainTime = agora
        self:DrenarUmDaFila()
        return  -- não envia live no mesmo tick
    end

    -- (4) live a 1Hz
    if (agora - self.LastLiveTime) >= self.LiveIntervalMs then
        self.LastLiveTime = agora
        self:EnviarLive()
    end

    -- (5) sentinela de RAM
    if (agora - self.LastRamLogTime) >= self.RamLogIntervalMs then
        self.LastRamLogTime = agora
        self:LogRam()
    end

    -- (6) percentual de acertos do socket no último minuto → @W_HDW302
    if (agora - self.LastPctTime) >= self.PctIntervalMs then
        self.LastPctTime = agora
        self:GravarPctAcertos()
    end
end

function MotorCurrentReader:SetEnabled(enabled)
    self.Enabled = enabled
    print(enabled and "[CurrentReader] ✓ habilitado" or "[CurrentReader] ✗ desabilitado")
end

return MotorCurrentReader
