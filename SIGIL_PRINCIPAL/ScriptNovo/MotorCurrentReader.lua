-- MotorCurrentReader: dois caminhos distintos sobre o mesmo socket :5055
--   1) TEMPO REAL: `tipo:"correntes"` (array de TODOS os motores), rápido
--      (default 2s). Drives a tela via WebSocket "console" do backend.
--   2) HISTÓRICO:  `tipo:"historico"` (1 motor por mensagem), periódico
--      (default 60s), escalonado (1 motor por poll, gap >= HistStaggerMs)
--      pra não colar 22 JSONs num read TCP — o SocketServerService NÃO
--      faz framing por '\n' e dropa quando 2+ msgs colidem num read.
--
-- ARQUITETURA (2026-05-25): a IHM NÃO decide nada — só lê a corrente do
-- registrador, aplica a aferição local (raw/100, em centésimos de Ampere) e
-- manda já em AMPERES. O backend recebe valores em A e usa o limiar de 5 A
-- pra integrar horímetro. Status (ligado/desligado) é derivado na UI a partir
-- da corrente — não é enviado pela IHM nem persistido como regra de negócio.
--
-- Payload atual:
--   correntes: {"tipo":"correntes","timestamp":<unix_s>,"plantaId":"<uuid>",
--               "motores":[{"id","correnteAtual"}]}
--   historico: {"tipo":"historico","timestamp":<unix_s>,"plantaId":"<uuid>",
--               "id","correnteAtual","correnteMedia","correnteMaxima","correnteMinima"}
-- Valores em AMPERES (float). Aferição (escala raw→A) vive aqui, no reader;
-- ajustar este fator se o registrador do PLC mudar de escala.

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
    -- "correntes" sai TODO ciclo de poll ("tão rápido quanto a tela da IHM").
    -- Payload agora é minúsculo (só id+correnteAtual por motor) e cabe num
    -- read TCP — improbabilidade de colidir com a próxima.
    obj.LiveIntervalMs = 0        -- 0 = envia em todo poll do we_bg_poll
    obj.HistIntervalMs = 60000    -- "historico" (resumo persistido) a cada 60s
    obj.HistStaggerMs  = 150      -- gap mínimo entre msgs de historico no drain
    -- Aferição: o registrador do PLC reporta corrente em centésimos de Ampere
    -- (raw 247 = 2,47 A). Se o eletricista ajustar a escala no CT, mudar aqui.
    obj.FatorEscala    = 1 / 100  -- raw → Amperes
    -- ======================
    -- (sem LimiarLigado: IHM não decide status; backend decide.)

    local agora = we_bas_gettickcount()
    obj.LastLiveTime     = agora
    obj.LastHistTime     = agora
    obj.LastHistItemTime = agora

    -- Acumulador por GUID (janela longa: reseta SÓ ao enviar historico)
    obj.Acc = {}        -- guid -> {soma,n,max,min,ultima}
    obj.HistFila = {}   -- guids pendentes de envio no ciclo de historico atual

    return obj
end

local function novoAcc()
    return { soma = 0, n = 0, max = nil, min = nil, ultima = 0 }
end

-- Lê todos os motores TODO ciclo de poll.
-- máx/mín/última = o mais rápido possível; soma/n acumula pra média da janela.
function MotorCurrentReader:Ler()
    if not self.MotorSync or not self.MotorSync.Inicializado then return end
    local mm = self.MotorSync.MotoresMemoria
    if not mm then return end

    for guid, motorData in pairs(mm) do
        local motor = motorData.motor
        if motor and motor.RegistroLocal and motor.RegistroLocal ~= "" then
            -- 16-bit: lê SÓ o registro do próprio motor (ver fix do word alto)
            local raw = we_bas_getword(motor.RegistroLocal)
            if raw ~= nil then
                raw = tonumber(raw) or 0
                if raw < 0 then raw = 0 end
                -- Sanidade: 0xFFFF (65535) é o padrão de "registrador
                -- não inicializado / falha de sensor". Trata como zero
                -- pra não fazer o backend integrar hora em motor parado.
                if raw >= 65535 then raw = 0 end

                -- Aferição: converte raw → Amperes ANTES de acumular.
                -- Daqui pra frente, o acc/payload/JSON tudo está em A.
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

-- 1) TEMPO REAL: envia array `tipo:"correntes"` com todos os motores.
--    Versão enxuta: id + status + correnteAtual (não reseta o acumulador).
function MotorCurrentReader:EnviarLive()
    if not self.SocketClient then return end
    local mm = self.MotorSync and self.MotorSync.MotoresMemoria
    if not mm then return end

    local arr = {}
    for guid, motorData in pairs(mm) do
        local motor = motorData.motor
        local acc = self.Acc[guid]
        if motor and motor.GUID and acc then
            -- IHM só reporta a corrente bruta. Sem `status` e sem `horimetro`:
            -- backend é quem decide ligado/desligado e quem mantém o horímetro.
            table.insert(arr, {
                id            = motor.GUID,
                correnteAtual = acc.ultima
            })
        end
    end
    if #arr > 0 then
        local plantaId = self.MotorSync and self.MotorSync.PlantaUUID or nil
        -- EnviarCorrentesArray embrulha em
        -- {tipo="correntes",plantaId,motores=arr,timestamp=os.time()} + "\n"
        self.SocketClient:EnviarCorrentesArray(arr, plantaId)
    end
end

-- 2) HISTÓRICO: monta a fila com TODOS os GUIDs; será drenado 1-por-poll
--    no Loop, respeitando HistStaggerMs entre mensagens.
function MotorCurrentReader:IniciarDrenoHistorico()
    self.HistFila = {}
    if not self.MotorSync or not self.MotorSync.MotoresMemoria then return end
    for guid, _ in pairs(self.MotorSync.MotoresMemoria) do
        table.insert(self.HistFila, guid)
    end
end

-- Envia 1 mensagem `tipo:"historico"` do próximo motor da fila e reseta o acc.
function MotorCurrentReader:EnviarProximoHistorico()
    local guid = table.remove(self.HistFila, 1)
    if not guid then return end
    if not self.SocketClient then return end

    local mm = self.MotorSync and self.MotorSync.MotoresMemoria
    local motorData = mm and mm[guid]
    local motor = motorData and motorData.motor
    local acc = self.Acc[guid]
    if not (motor and motor.GUID and acc) then
        -- nada a enviar; só reseta acc se existir
        if acc then self.Acc[guid] = novoAcc() end
        return
    end

    local media = (acc.n > 0) and (acc.soma / acc.n) or acc.ultima

    -- Sem `status`: backend decide. Manda sempre max/min — backend filtra/usa.
    local item = {
        tipo           = "historico",
        timestamp      = os.time(),
        plantaId       = self.MotorSync.PlantaUUID,
        id             = motor.GUID,
        correnteAtual  = acc.ultima,
        correnteMedia  = media,
        correnteMaxima = acc.max or acc.ultima,
        correnteMinima = acc.min or acc.ultima
    }

    -- 1 mensagem só, EnviarMensagem já anexa "\n"
    self.SocketClient:EnviarMensagem(json.encode(item))

    -- reseta a janela desse motor (a média/máx/mín é por janela de HistIntervalMs)
    self.Acc[guid] = novoAcc()
end

-- Chamado no we_bg_poll.
-- Garante NO MÁXIMO 1 envio por tick (live OU historico) — reduz o risco
-- de o backend juntar mensagens no mesmo read TCP.
function MotorCurrentReader:Loop()
    if not self.Enabled then return end

    local agora = we_bas_gettickcount()
    if agora < self.LastLiveTime     then self.LastLiveTime     = agora end
    if agora < self.LastHistTime     then self.LastHistTime     = agora end
    if agora < self.LastHistItemTime then self.LastHistItemTime = agora end

    -- lê e acumula TODO ciclo (máx/mín o mais rápido possível)
    self:Ler()

    -- (A) drenando histórico? prioriza, respeitando o stagger
    if #self.HistFila > 0 then
        if (agora - self.LastHistItemTime) >= self.HistStaggerMs then
            self:EnviarProximoHistorico()
            self.LastHistItemTime = agora
            if #self.HistFila == 0 then
                self.LastHistTime = agora  -- ciclo de historico concluído
                -- O backend acabou de receber o histórico e recalculou os
                -- horímetros de TODOS os motores. Faz uma sync REST agora
                -- pra trazer o valor "sincronizado" pra `motor.Horimetro`
                -- em memória da IHM. A tela pode ler dali (ainda a wirear).
                if self.MotorSync and self.MotorSync.Sincronizar then
                    self.MotorSync:Sincronizar()
                end
            end
        end
        return  -- não envia live no mesmo tick
    end

    -- (B) é hora de iniciar um novo ciclo de historico?
    if (agora - self.LastHistTime) >= self.HistIntervalMs then
        self:IniciarDrenoHistorico()
        self.LastHistItemTime = 0  -- libera 1º envio no próximo tick
        return
    end

    -- (C) caso contrário, envio de tempo real (correntes) na cadência LiveIntervalMs
    if (agora - self.LastLiveTime) >= self.LiveIntervalMs then
        self.LastLiveTime = agora
        self:EnviarLive()
    end
end

function MotorCurrentReader:SetEnabled(enabled)
    self.Enabled = enabled
    print(enabled and "[CurrentReader] ✓ habilitado" or "[CurrentReader] ✗ desabilitado")
end

return MotorCurrentReader
