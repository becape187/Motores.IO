Script_BG_limits = 11

-- Variáeis locis do módu
local socketClient
local logger
local motorSync
local apiClient
local sqliteDB
local motorCurrentReader
local fileManager
local fileManagerHandler
local conta = 0
local sistemaInicializado = false
local inicioms 

-- UUID da planta
local PLANTA_UUID = "6e1c1fd1-f104-4172-bbd9-1f5a7e90e874"

-- Função de inicializaçoque pode ser chamada manualmente (ex:por botão)
function inicializarSistema()
    -- IMPORTANTE: Verificar se já está inicializado SEM usar print (ainda não temos Logger)
    if sistemaInicializado then
        -- Usar print original aqui pois Logger ainda não foi inicializado
        -- Mas isso só acontece se já estiver inicializado, então é raro
        return true
    end
    
    conta = 0
    
    -- ============================================
    -- PRIMEIRA COISA: Conectar ao Socket
    -- ANTES de QUALQUER outra coisa, incluindo prints
    -- ============================================
    we_bas_setint("@W_HDW300",10)
    
    -- Criar SocketClient primeiro (sem prints ainda)
    -- Porta 5055 é onde o SocketServerService escuta conexões TCP simples
    socketClient = SocketClient:new("api.motores.automais.io", 5055)
    --socketClient = SocketClient:new("192.168.15.187", 5055)

    -- Tentar conectar ao socket (PRIMEIRA ação do sistema)
    local socketConnected, socketErr = socketClient:Conectar()
    
    -- Enviar identificação da planta após conectar
    if socketConnected then
        local identMessage = json.encode({
            tipo = "identificacao",
            plantaId = PLANTA_UUID
        })
        socketClient:EnviarMensagem(identMessage)
    end
    
    -- ============================================
    -- SEGUNDA COISA: Inicializar Logger IMEDIATAMENTE
    -- Logo após conectar ao socket, antes de qualquer print
    -- ============================================
    logger = Logger:new(socketClient, PLANTA_UUID)  -- Passar PLANTA_UUID para incluir nas mensagens
    logger:SubstituirPrint()  -- Substitui print global - AGORA todos os prints serão capturados
    logger:ConfigurarTratamentoErros()  -- Configura tratamento de erros - AGORA todos os erros serão capturados
    
    -- AGORA SIM podemos usar print - ele já será redirecionado para o socket
    if not socketConnected then
        print("[Init] ⚠ Aviso: Não foi possível conectar ao socket: " .. tostring(socketErr))
        print("[Init] Continuando inicialização sem socket (logs locais apenas)...")
    else
        print("[Init] ✓ Socket conectado com sucesso")
    end
    
    print("[Init] === INICIANDO SISTEMA ===")
    print("[Init] Logger inicializado - prints e erros serão enviados via socket")
    
    -- Agora continuar com inicialização normal
    -- Inicializar banco de dados local
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
    
    -- Inicializar FileManager e FileManagerHandler
    print("[Init] Inicializando FileManager...")
    we_bas_setint("@W_HDW300",22)
    fileManager = FileManager:new("/flash")
    fileManagerHandler = FileManagerHandler:new(fileManager, socketClient)
    
    -- Configurar callback para processar comandos de arquivo
    socketClient:SetCommandHandlerCallback(function(comando)
        return fileManagerHandler:ProcessarComando(comando)
    end)
    print("[Init] ✓ FileManager inicializado")
    
    we_bas_setint("@W_HDW300",23)
    sistemaInicializado = true
    print("[Init] === INICIALIZAÇÃO CONCLUÍDA ===")

    return true
end

-- Função pra verificar se o sistema está inicializado
function sistemaEstaInicializado()
    return sistemaInicializado
end

-- Função chamada automaticamente pelo sistema (pode ficar vazia ou fazer inicialização mínima)
function we_bg_init()
    -- Iicialização automática desabilitada para permitir inicialização manual
    -- Chame inicializarSistema() através de um botão ou script
    inicioms = we_bas_gettickcount()
    print("[Init] Sistema aguardando inicialização manual...")
    print("[Init] Use a função 'inicializarSistema()' para inicializar o sistema")
end

function we_bg_poll()
    if we_bas_gettickcount() > (inicioms + 5000) and sistemaInicializado == false then
        inicializarSistema()
    end
    
    -- Só executar loops se o sistema estiver inicializado
    if not sistemaInicializado then
        return
    end
    
    -- Chamar o loop da classe SocketClient
    if socketClient then
        --we_bas_setdword("@W_HDW305",we_bas_gettickcount())
        socketClient:Loop()
    end
    
    -- Enviar ping periódico do Logger (mostra que está conectado)
    if logger then
        logger:EnviarPing()
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