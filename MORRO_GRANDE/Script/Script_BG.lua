Script_BG_limits = 11

-- Variáveis locais do módu
local socketClient
local logger
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
    
    -- PRIMEIRA COISA: Conectar ao Socket ANTES de qualquer outra inicialização
    print("[Init] === INICIANDO SISTEMA ===")
    print("[Init] Conectando ao Socket (PRIORIDADE)...")
    we_bas_setint("@W_HDW300",10)
    
    -- Criar SocketClient primeiro
    socketClient = SocketClient:new("api.motores.automais.io", 5055)
    
    -- Tentar conectar ao socket
    local socketConnected, socketErr = socketClient:Conectar()
    if not socketConnected then
        print("[Init] ⚠ Aviso: Não foi possível conectar ao socket: " .. tostring(socketErr))
        print("[Init] Continuando inicialização sem socket (logs locais apenas)...")
    else
        print("[Init] ✓ Socket conectado com sucesso")
    end
    
    -- Inicializar Logger e configurar redirecionamento de prints/erros
    print("[Init] Inicializando Logger...")
    logger = Logger:new(socketClient, PLANTA_UUID)  -- Passar PLANTA_UUID para incluir nas mensagens
    logger:SubstituirPrint()  -- Substitui print global
    logger:ConfigurarTratamentoErros()  -- Configura tratamento de erros
    print("[Init] ✓ Logger inicializado - prints e erros serão enviados via socket")
    
    -- Agora continuar com inicialização normal
    -- Inicializar banco de dados local
    print("[Init] Inicializando banco de dados local...")
    -- Usar "udisk:" para disco USB ou caminho relativo conforme documentação
    sqliteDB = SQLiteDB:new("sdcard:motores.db")
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
    
    -- Configurar callback para obter dados do motor (buscar da memória do MotorSync)
    we_bas_setint("@W_HDW300",17)
    socketClient:SetMotorDataCallback(function()
        -- Buscar motor da memória do MotorSync pelo GUID
        -- Você pode ajustar isso para buscar o motor correto
        if motorSync then
            we_bas_setint("@W_HDW300",18)
            local motores = motorSync:ObterTodosMotores()
            we_bas_setint("@W_HDW300",19)
            if #motores > 0 then
                we_bas_setint("@W_HDW300",20)
                return motores[1] -- Retorna o primeiro motor (ajuste conforme necessário)
            end
        end
        return nil
    end)
    print("[Init] ✓ SocketClient configurado")
    
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