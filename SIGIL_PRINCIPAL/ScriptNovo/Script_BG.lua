Script_BG_limits = 11

-- Variáveis locais do módu
local socketClient
local motorSync
local apiClient
local sqliteDB
local motorCurrentReader
local conta = 0
local sistemaInicializado = false

-- UUID da planta
local PLANTA_UUID = "661e8415-65eb-4821-86e9-462d7ad57c9e"

-- Função de inicialização que pode ser chamada manualmente (ex: por botão)
function inicializarSistema()
    if sistemaInicializado then
        print("[Init] ⚠ Sistema já está inicializado!")
        return true
    end
    
    conta = 0

    -- Inicializar cache de motores em RAM (sem SD/USB/SQLite — só tabela Lua).
    -- O nome SQLiteDB ficou por inércia da migração; ver SQLiteDB.lua.
    print("[Init] === INICIANDO SISTEMA ===")
    print("[Init] Inicializando cache de motores em RAM...")

    sqliteDB = SQLiteDB:new()
    we_bas_setint("@W_HDW300", 11)
    local cacheOk, cacheErr = sqliteDB:Conectar()
    we_bas_setint("@W_HDW300", 12)
    if not cacheOk then
        print("[Init] ✗ Erro ao inicializar cache: " .. tostring(cacheErr))
        sistemaInicializado = false
        return false
    else
        print("[Init] ✓ Cache em RAM pronto")
    end
    
    -- Inicializar API Client
    print("[Init] Inicializando API Client...")
    we_bas_setint("@W_HDW300",13)
    apiClient = APIClient:new("http://api.motores.automais.io") -- API em produção
    print("[Init] ✓ API Client inicializado")
    
    -- Inicializar MotorSync
    print("[Init] Inicializando MotorSync...")
    we_bas_setint("@W_HDW300",14)
    motorSync = MotorSync:new(apiClient, sqliteDB, PLANTA_UUID)
    we_bas_setint("@W_HDW300",15)
    local syncInicializado = motorSync:Inicializar()
    if syncInicializado then
        print("[Init] ✓ MotorSync inicializado")
    else
        print("[Init] ✗ Erro ao inicializar MotorSync")
        sistemaInicializado = false
        return false
    end
    
    -- Inicializar SocketClient
    print("[Init] Inicializando SocketClient...")
    we_bas_setint("@W_HDW300",16)
    socketClient = SocketClient:new("api.motores.automais.io", 5055)
    
    we_bas_setint("@W_HDW300",17)
    -- NÃO configurar SetMotorDataCallback: o envio de dados de motor agora é
    -- 100% do MotorCurrentReader (resumo agregado de TODOS os motores, 1 msg
    -- a cada 60s, tipo:"correntes", com média/máx/mín e status por limiar).
    -- O callback antigo devolvia só motores[1] com status espelhado da API e
    -- interleava outra mensagem no socket -> backend (sem framing) recolava
    -- JSON e dropava tudo. Sem GetMotorDataCallback, SocketClient:Loop não
    -- dispara EnviarDadosMotor (guard: "if not self.GetMotorDataCallback").
    print("[Init] ✓ SocketClient inicializado (envio via MotorCurrentReader)")
    
    -- Inicializar MotorCurrentReader (passar socketClient para enviar dados)
    print("[Init] Inicializando MotorCurrentReader...")
    we_bas_setint("@W_HDW300",21)
    motorCurrentReader = MotorCurrentReader:new(motorSync, socketClient)
    print("[Init] ✓ MotorCurrentReader inicializado")
    we_bas_setint("@W_HDW300",22)
    sistemaInicializado = true
    print("[Init] === INICIALIZAÇÃO CONCLUÍDA ===")

    return true
end

-- Função para verificar se o sistema está inicializado
function sistemaEstaInicializado()
    return sistemaInicializado
end

-- ============================================================
-- Botões da TELA DE EDIÇÃO DE MOTORES (horímetro)
-- ------------------------------------------------------------
-- IHM NÃO trata horímetro — só delega ao backend, fonte da verdade.
-- Cálculo, zeramento e persistência são 100% do servidor.
--
-- ZerarHorimetro(motorGuid)
--   POST /api/motors/{id}/zerar-horimetro
--   Zera o Horímetro DE OPERAÇÃO + grava DataZeramentoHorimetro.
--   NÃO toca em HorimetroCalculado.
--
-- CalcularHorimetro(motorGuid)
--   POST /api/motors/{id}/calcular-horimetro
--   Recalcula o Horímetro CALCULADO integrando TODO o histórico do Influx.
--   Grava em HorimetroCalculado + DataCalculoHorimetro. NÃO toca no de operação.
--
-- Wire-up no PIStudio (botão "Execute Lua"):
--   Botão "Zerar Horímetro"          -> ZerarHorimetro(<reg_string_com_guid>)
--   Botão "Calcular do Histórico"    -> CalcularHorimetro(<reg_string_com_guid>)
--
-- ATENÇÃO: o botão antigo "Ajustar Horímetro" (definir para valor arbitrário)
-- foi removido — o backend não tem mais esse endpoint. Se o botão ainda
-- existir na tela do PIStudio, remova-o ou redirecione para Zerar/Calcular.
-- ============================================================

function ZerarHorimetro(motorGuid)
    if not motorGuid or motorGuid == "" then
        print("[Horímetro] ✗ GUID vazio — botão não pode chamar sem identificar o motor")
        return false
    end
    if not apiClient then
        print("[Horímetro] ✗ Sistema ainda não inicializado")
        return false
    end

    local resp, err = apiClient:ZerarHorimetroOperacao(motorGuid)
    if resp ~= nil then
        -- Atualizar cópia em memória pra UI refletir imediatamente. O próximo
        -- MotorSync vai trazer o valor canônico do backend de qualquer forma.
        local motor = motorSync and motorSync:ObterMotor(motorGuid) or nil
        if motor then
            motor.Horimetro = tonumber(resp.horimetro) or 0
        end
        print("[Horímetro] ✓ Zerado pelo backend: motor=" .. tostring(motorGuid))
        return true
    else
        print("[Horímetro] ✗ Falha ao zerar: " .. tostring(err))
        return false
    end
end

function CalcularHorimetro(motorGuid)
    if not motorGuid or motorGuid == "" then
        print("[Horímetro] ✗ GUID vazio — botão não pode chamar sem identificar o motor")
        return false
    end
    if not apiClient then
        print("[Horímetro] ✗ Sistema ainda não inicializado")
        return false
    end

    local resp, err = apiClient:CalcularHorimetroDoHistorico(motorGuid)
    if resp ~= nil then
        print(string.format("[Horímetro] ✓ Calculado do histórico: motor=%s, valor=%s h",
            tostring(motorGuid), tostring(resp.horimetroCalculado)))
        return true
    else
        print("[Horímetro] ✗ Falha ao calcular: " .. tostring(err))
        return false
    end
end

-- Função chamada automaticamente pelo sistema (pode ficar vazia ou fazer inicialização mínima)
function we_bg_init()
    -- Iicialização automática desabilitada para permitir inicialização manual
    -- Chame inicializarSistema() através de um botão ou script
    print("[Init] Sistema aguardando inicialização manual...")
    print("[Init] Use a função 'inicializarSistema()' para inicializar o sistema")
end

function we_bg_poll()
    if we_bas_gettickcount() > 5000 and sistemaInicializado == false then
        we_bas_setint("@W_HDW300",10)
        inicializarSistema()
    end
    
    -- Só executar loops se o sistema estiver inicializado
    if not sistemaInicializado then
        return
    end
    
    -- Chamar o loop da classe SocketClient
    if socketClient then
        socketClient:Loop()
    end
    
    -- Chamar o loop da classe MotorSync (sincronização a cada minuto)
    if motorSync then
        motorSync:Loop()
    end
    
    -- Chamar o loop da classe MotorCurrentReader (atualiza correntes da IHM)
    if motorCurrentReader then
        motorCurrentReader:Loop()
    end
end