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
local PLANTA_UUID = "6e1c1fd1-f104-4172-bbd9-1f5a7e90e874"

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
    local dbConnected, dbErr = sqliteDB:Conectar()
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
    apiClient = APIClient:new("http://api.motores.automais.io") -- API em produção
    print("[Init] ✓ API Client inicializado")
    
    -- Inicializar MotorSync
    print("[Init] Inicializando MotorSync...")
    motorSync = MotorSync:new(apiClient, sqliteDB, PLANTA_UUID)
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
    socketClient = SocketClient:new("api.motores.automais.io", 5055)
    
    -- Configurar callback para obter dados do motor (buscar da memória do MotorSync)
    socketClient:SetMotorDataCallback(function()
        -- Buscar motor da memória do MotorSync pelo GUID
        -- Você pode ajustar isso para buscar o motor correto
        if motorSync then
            local motores = motorSync:ObterTodosMotores()
            if #motores > 0 then
                return motores[1] -- Retorna o primeiro motor (ajuste conforme necessário)
            end
        end
        return nil
    end)
    print("[Init] ✓ SocketClient inicializado")
    
    -- Inicializar MotorCurrentReader (passar socketClient para enviar dados)
    print("[Init] Inicializando MotorCurrentReader...")
    motorCurrentReader = MotorCurrentReader:new(motorSync, socketClient)
    print("[Init] ✓ MotorCurrentReader inicializado")
    
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
    -- Inicialização automática desabilitada para permitir inicialização manual
    -- Chame inicializarSistema() através de um botão ou script
    print("[Init] Sistema aguardando inicialização manual...")
    print("[Init] Use a função 'inicializarSistema()' para inicializar o sistema")
end

function we_bg_poll()
    conta = conta + 1
    we_bas_setint("@HDW_W_0000000", conta)
    
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