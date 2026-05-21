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
    
    -- Inicializar banco de dados local
    print("[Init] === INICIANDO SISTEMA ===")
    print("[Init] Inicializando banco de dados local...")
    
    -- Usar "udisk:" para disco USB ou caminho relativo conforme documentação
    sqliteDB = SQLiteDB:new("udisk:motores.db")
    we_bas_setint("@W_HDW300",11)
    local dbConnected, dbErr = sqliteDB:Conectar()
    we_bas_setint("@W_HDW300",12)
    if not dbConnected then
        print("[Init] ✗ Erro ao conectar ao banco local: " .. tostring(dbErr))
        print("[Init] Detalhes do erro: " .. tostring(dbErr))
        sistemaInicializado = false
        return false -- Não continua se não conseguir conectar ao banco
    else
        print("[Init] ✓ Banco de dados local conectado")
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