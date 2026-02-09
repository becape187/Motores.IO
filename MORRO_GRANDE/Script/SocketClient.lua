-- ClssSkeClient para comunicação via socke
SocketClient = {}
SocketClient.__index = SocketClient

-- Carregar módulos conforme documentação do PIStud
local socket = require("socket") -- Load the socket mdule and everything it needs

-- Configurações do socket
-- IP do PC de desenvolvimento para testes locais
local SOCKET_HOST
local SOCKET_PORT
local POOLING_INTERVAL = 5 -- segundos

-- Construtor
function SocketClient:new(host, port)
    local obj = {}
    setmetatable(obj, SocketClient)
    
    obj.Host = host or SOCKET_HOST
    obj.Port = port or SOCKET_PORT
    obj.Socket = nil
    obj.Connected = false
    obj.ReconnectAttempts = 0
    obj.MaxReconnectAttempts = 10
    
    -- Intervalos em milissegundos (configuráveis)
    obj.ConnectionCheckInterval = 5000   -- Verificar conexão a cada 5 segundos (5000ms)
    obj.PoolingInterval = 10000          -- Enviar keep-alive a cada 10 segundos (10000ms)
    obj.DataSendInterval = 30000          -- Enviar dados do motor a cada 30 segundos (30000ms)
    obj.SendProcessInterval = 100         -- Processar envios pendentes a cada 100ms
    obj.ErrorCheckInterval = 1000        -- Verificar erros de envio a cada 1 segundo
    
    -- Callback para obter dados do motor (será configurado externamente)
    obj.GetMotorDataCallback = nil
    
    -- Callback para processar comandos recebidos (será configurado externamente)
    obj.CommandHandlerCallback = nil
    
    -- Inicializar variáveis de controle de tempo (usando we_bas_gettickcount() que retorna milissegundos)
    local currentTime = we_bas_gettickcount()
    
    -- Sistema de fila para envios assíncronos
    obj.SendQueue = {}                    -- Fila de mensagens para enviar
    obj.PendingSends = {}                  -- Envios pendentes com timestamp e status
    obj.LastSendProcessTime = currentTime  -- Última vez que processou envios
    obj.LastErrorCheckTime = currentTime  -- Última vez que verificou erros
    obj.LastConnectionCheckTime = currentTime
    obj.LastPoolingTime = currentTime
    obj.LastDataSendTime = currentTime
    obj.LastCommandCheckTime = currentTime
    obj.CommandCheckInterval = 50  -- Verificar comandos a cada 50ms (alta frequência para comandos)
    
    return obj
end

-- Função para conectar ao socket
function SocketClient:Conectar()
    self.Socket = socket.tcp()
    self.Socket:settimeout(5)
    
    local success, err = self.Socket:connect(self.Host, self.Port)
    
    if success == 1 then
        self.Connected = true
        self.ReconnectAttempts = 0
        print("[Socket] ✓ Conectado: " .. self.Host .. ":" .. self.Port)
        return true
    else
        self.Connected = false
        print("[Socket] ✗ Erro ao conectar: " .. tostring(err))
        return false, err
    end
end

-- Função para desconectar do socket
function SocketClient:Desconectar()
    if self.Socket then
        self.Socket:close()
        self.Socket = nil
        self.Connected = false
        print("Socket desconectado")
    end
end

-- Funço para verificar se está conectado
function SocketClient:EstaConectado()
    return self.Connected
end

-- Função para fazer pooling (mantida para compatibilidade)
function SocketClient:FazerPooling()
    self:EnviarMensagem("KEEPALIVE")
end

-- Função para adicionar mensagem à fila de envio (não-bloqueante)
function SocketClient:EnviarMensagem(mensagem)
    -- Adicionar à fila de envio (não bloqueia o fluxo principal)
    local sendId = #self.SendQueue + 1
    local currentTime = we_bas_gettickcount()
    
    -- Adiciona quebra de linha se não tiver
    if not string.match(mensagem, "\n$") then
        mensagem = mensagem .. "\n"
    end
    
    table.insert(self.SendQueue, {
        id = sendId,
        mensagem = mensagem,
        timestamp = currentTime,
        tentativas = 0,
        maxTentativas = 3
    })
    
    -- Marcar como pendente
    self.PendingSends[sendId] = {
        status = "pending",
        timestamp = currentTime,
        mensagem = mensagem
    }
    
    return true  -- Retorna imediatamente (envio será processado assincronamente)
end

-- Função para processar envios pendentes
function SocketClient:ProcessarEnvios()
    if not self.Connected then
        self:Conectar()
        return
    end
    
    local processadas = 0
    local maxPorCiclo = 5
    
    for i = #self.SendQueue, 1, -1 do
        if processadas >= maxPorCiclo then
            break
        end
        
        local item = self.SendQueue[i]
        local sent, err = self.Socket:send(item.mensagem)
        
        if sent then
            self.PendingSends[item.id] = {
                status = "sent",
                timestamp = we_bas_gettickcount()
            }
            table.remove(self.SendQueue, i)
            processadas = processadas + 1
        else
            item.tentativas = item.tentativas + 1
            
            if item.tentativas >= item.maxTentativas then
                self.PendingSends[item.id] = {
                    status = "error",
                    timestamp = we_bas_gettickcount(),
                    erro = tostring(err)
                }
                table.remove(self.SendQueue, i)
                self.Connected = false
            end
            
            processadas = processadas + 1
        end
    end
end

-- Função para verificar e tratar erros de envio (chamada assincronamente)
function SocketClient:VerificarErrosEnvio()
    local currentTime = we_bas_gettickcount()
    local timeoutErro = 5000  -- 5 segundos para considerar erro antigo
    
    -- Limpar erros antigos
    for id, pending in pairs(self.PendingSends) do
        if pending.status == "error" then
            if currentTime - pending.timestamp > timeoutErro then
                -- Erro antigo, remover
                self.PendingSends[id] = nil
            end
        elseif pending.status == "sent" then
            if currentTime - pending.timestamp > timeoutErro then
                -- Envio antigo bem-sucedido, remover
                self.PendingSends[id] = nil
            end
        end
    end
end

-- Função para receber mensagem
function SocketClient:ReceberMensagem(timeout)
    if timeout then
        self.Socket:settimeout(timeout)
    end
    
    local mensagem, err = self.Socket:receive("*l")
    
    if mensagem then
        return mensagem
    else
        if err ~= "timeout" then
            self.Connected = false
        end
        return nil, err
    end
end

-- Função para enviar array de correntes via socket
function SocketClient:EnviarCorrentesArray(correntesArray, plantaId)
    if not correntesArray or #correntesArray == 0 then
        return false, "Array de correntes vazio"
    end
    
    -- Criar mensagem com array de correntes
    local data = {
        tipo = "correntes",
        plantaId = plantaId,
        motores = correntesArray,
        timestamp = os.time()
    }
    
    local mensagem = json.encode(data)
    
    local success, err = self:EnviarMensagem(mensagem)
    
    -- Não logar erro a cada tentativa para evitar poluição
    -- if not success then
    --     print("[Socket] ✗ Erro ao enviar correntes: " .. tostring(err))
    -- end
    
    return success, err
end

-- Função para enviar dados de motor via socket
function SocketClient:EnviarDadosMotor(motor)
    -- json.encode está disponível globalmente no PIStudio
    -- Não precisa de require("json") conforme documentação
    
    -- Usar GUID se disponível, caso contrário usar ID numérico convertido para string
    local motorId = motor.GUID or tostring(motor.ID)
    
    -- Converter status booleano para string se necessário
    local statusStr = "desligado"
    if type(motor.Status) == "boolean" then
        statusStr = motor.Status and "ligado" or "desligado"
    elseif type(motor.Status) == "string" then
        statusStr = motor.Status
    end
    
    local data = {
        tipo = "motor",
        id = motorId,
        nome = motor.Nome,
        correnteAtual = motor.CorrenteAtual,
        status = statusStr,
        horimetro = motor.Horimetro,
        timestamp = os.time()
    }
    
    local mensagem = json.encode(data)
    
    
    local success, err = self:EnviarMensagem(mensagem)
    
    if success then
        -- Opcionalmente, tentar ler confirmação do servidor (timeout curto)
        local resposta, errResp = self:ReceberMensagem(2) -- timeout de 2 segundos (aumentado para garantir recebimento)
        if resposta then
            resposta = string.gsub(resposta, "\n", "") -- Remove quebra de linha
            
            if resposta == "OK" then
                return true
            elseif resposta == "ERROR" or string.find(resposta, "ERROR") then
                print("[Socket] ✗ Servidor retornou ERROR")
                return false, "Erro no servidor"
            else
                -- Resposta inesperada, mas assume sucesso se conseguiu enviar
                return true
            end
        else
            -- Se não recebeu resposta, assume sucesso (compatibilidade)
            return true
        end
    else
        print("[Socket] ✗ Erro ao enviar mensagem: " .. tostring(err))
        return false, err
    end
end

-- Função para configurar callback de dados do motor
function SocketClient:SetMotorDataCallback(callback)
    self.GetMotorDataCallback = callback
end

-- Função para configurar callback de comandos recebidos
function SocketClient:SetCommandHandlerCallback(callback)
    self.CommandHandlerCallback = callback
end

-- Função para verificar se há dados disponíveis usando socket.select
function SocketClient:VerificarDadosDisponiveis()
    local recvt = {self.Socket}
    local recvt_ready = socket.select(recvt, nil, 0)
    return recvt_ready and #recvt_ready > 0
end

-- Função para processar mensagens recebidas (alta prioridade)
function SocketClient:ProcessarRecebimentos()
    -- Processar TODAS as mensagens disponíveis imediatamente (sem limite)
    while self:VerificarDadosDisponiveis() do
        local mensagem = self:ReceberMensagem(0.01)
        
        if not mensagem then
            break
        end
        
        -- Ignorar mensagens simples de controle
        if mensagem ~= "OK" and mensagem ~= "PONG" and mensagem ~= "ERROR" then
            print("[Socket] MSG RECEBIDO: " .. mensagem)
            local comando = json.decode(mensagem)
            
            -- Normalizar acao: se vazia mas tem Path, assumir "listar"
            if comando then
                if (not comando.acao or comando.acao == "") and comando.Path then
                    comando.acao = "listar"
                    print("[Socket] Acao vazia detectada, assumindo 'listar' para Path: " .. tostring(comando.Path))
                end
                
                -- Normalizar campo path (pode vir como Path ou path)
                if not comando.path and comando.Path then
                    comando.path = comando.Path
                end
            end
            
            if comando and comando.acao and comando.acao ~= "" then
                print("[Socket] Processando comando: " .. comando.acao .. " (RequestId: " .. tostring(comando.requestId or "sem ID") .. ")")
                local resultado = self.CommandHandlerCallback(comando)
                if resultado then
                    if not resultado.requestId then
                        resultado.requestId = comando.requestId
                    end
                    -- Enviar resposta imediatamente (não via fila para respostas de comandos)
                    local respostaJson = json.encode(resultado)
                    self.Socket:send(respostaJson .. "\n")
                    print("[Socket] Resposta enviada para comando: " .. comando.acao)
                else
                    print("[Socket] ⚠ Comando processado mas não retornou resultado")
                end
            else
                print("[Socket] ⚠ Comando recebido sem ação válida: " .. tostring(comando and comando.acao or "nil"))
            end
        end
    end
end

-- Função principal de loop - deve ser chamada periodicamente (ex: no we_bg_poll)
-- Agora separada em: recebimentos, envios, conexão, e dados periódicos
function SocketClient:Loop()
    local currentTime = we_bas_gettickcount()
    
    -- 1. PROCESSAR RECEBIMENTOS (ALTA PRIORIDADE - sempre verificar primeiro)
    -- Processar recebimentos com alta frequência para comandos chegarem rápido
    if currentTime - self.LastCommandCheckTime >= self.CommandCheckInterval then
        self.LastCommandCheckTime = currentTime
        if self.Connected then
            self:ProcessarRecebimentos()
        end
    end
    
    -- 2. PROCESSAR ENVIOS PENDENTES (assíncrono, não bloqueia)
    if currentTime - self.LastSendProcessTime >= self.SendProcessInterval then
        self.LastSendProcessTime = currentTime
        self:ProcessarEnvios()
    end
    
    -- 3. VERIFICAR ERROS DE ENVIO (assíncrono, limpeza)
    if currentTime - self.LastErrorCheckTime >= self.ErrorCheckInterval then
        self.LastErrorCheckTime = currentTime
        self:VerificarErrosEnvio()
    end
    
    -- 4. VERIFICAR E MANTER CONEXÃO
    if currentTime - self.LastConnectionCheckTime >= self.ConnectionCheckInterval then
        self.LastConnectionCheckTime = currentTime
        if not self:EstaConectado() then
            self:Conectar()
        end
    end
    
    -- 5. ENVIAR KEEP-ALIVE (via fila, não bloqueia)
    if currentTime - self.LastPoolingTime >= self.PoolingInterval then
        self.LastPoolingTime = currentTime
        if self:EstaConectado() then
            self:EnviarMensagem("KEEPALIVE")
        end
    end
    
    -- 6. ENVIAR DADOS DO MOTOR (via fila, não bloqueia)
    if currentTime - self.LastDataSendTime >= self.DataSendInterval then
        self.LastDataSendTime = currentTime
        
        if not self.GetMotorDataCallback then
            return
        end
        
        local motor = self.GetMotorDataCallback()
        if motor then
            -- Enviar via fila (não bloqueia)
            self:EnviarDadosMotor(motor)
        end
    end
end

return SocketClient
