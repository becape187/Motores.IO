-- Classe SocketClient para comunicação via socket
SocketClient = {}
SocketClient.__index = SocketClient

-- Carregar módulos conforme documentação do PIStudio
local socket = require("socket") -- Load the socket module and everything it needs

-- Configurações do socket
local SOCKET_HOST = "api.motores.automais.io"
local SOCKET_PORT = 5055
local POOLING_INTERVAL = 5 -- segundos

-- Construtor
function SocketClient:new(host, port)
    local obj = {}
    setmetatable(obj, SocketClient)
    
    obj.Host = host or SOCKET_HOST
    obj.Port = port or SOCKET_PORT
    obj.Socket = nil
    obj.Connected = false
    obj.PoolingInterval = POOLING_INTERVAL
    obj.LastPoolingTime = 0
    obj.ReconnectAttempts = 0
    obj.MaxReconnectAttempts = 10
    
    return obj
end

-- Função para conectar ao socket (usando API do PIStudio)
function SocketClient:Conectar()
    -- Conforme documentação do PIStudio: local socket = require("socket")
    -- https://docs.we-con.com.cn/bin/view/PIStudio/09%20Lua%20Editor/Lua%20Script/#HSocketbasicfunction
    
    if not socket or not socket.tcp then
        return false, "Módulo socket não foi carregado corretamente"
    end
    
    -- Criar socket TCP
    self.Socket = socket.tcp()
    
    if not self.Socket then
        return false, "Não foi possível criar socket TCP"
    end
    
    -- Configurar timeout (conforme API do PIStudio: tcp:settimeout())
    self.Socket:settimeout(5) -- timeout de 5 segundos
    
    -- Conectar ao servidor
    -- Conforme documentação: tcp:connect(address, port) retorna success, err
    -- success = 1 se sucesso, nil se falha
    local success, err = self.Socket:connect(self.Host, self.Port)
    
    -- tcp:connect() retorna 1 se sucesso, nil se falha
    if success == 1 then
        self.Connected = true
        self.ReconnectAttempts = 0
        print("Socket conectado com sucesso em " .. self.Host .. ":" .. self.Port)
        return true
    else
        self.Connected = false
        print("Erro ao conectar socket: " .. tostring(err))
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

-- Função para verificar se está conectado
function SocketClient:EstaConectado()
    if not self.Socket or not self.Connected then
        return false
    end
    
    -- Tenta enviar um ping para verificar a conexão
    -- tcp:send() retorna: success (número de bytes ou nil), err, last_byte
    local sent, err = self.Socket:send("PING\n")
    if not sent then
        self.Connected = false
        return false
    end
    
    return true
end

-- Função para fazer pooling e manter conexão ativa
function SocketClient:FazerPooling()
    local currentTime = os.time()
    
    -- Verifica se é hora de fazer pooling
    if currentTime - self.LastPoolingTime >= self.PoolingInterval then
        self.LastPoolingTime = currentTime
        
        -- Verifica se está conectado
        if not self:EstaConectado() then
            print("Socket desconectado, tentando reconectar...")
            self:Conectar()
        else
            -- Envia mensagem de keep-alive
            -- tcp:send() retorna: sent (número de bytes ou nil), err, last_byte
            local sent, err = self.Socket:send("KEEPALIVE\n")
            if not sent then
                print("Erro ao enviar keep-alive: " .. tostring(err))
                self.Connected = false
                self:Conectar()
            end
        end
    end
end

-- Função para enviar mensagem
function SocketClient:EnviarMensagem(mensagem)
    if not self:EstaConectado() then
        local connected = self:Conectar()
        if not connected then
            return false, "Não foi possível conectar ao socket"
        end
    end
    
    -- Adiciona quebra de linha se não tiver
    if not string.match(mensagem, "\n$") then
        mensagem = mensagem .. "\n"
    end
    
    -- tcp:send() retorna: sent (número de bytes ou nil), err, last_byte
    local sent, err = self.Socket:send(mensagem)
    
    if sent then
        return true
    else
        self.Connected = false
        return false, "Erro ao enviar mensagem: " .. tostring(err)
    end
end

-- Função para receber mensagem
function SocketClient:ReceberMensagem(timeout)
    if not self:EstaConectado() then
        return nil, "Socket não está conectado"
    end
    
    -- Salvar timeout atual e configurar novo se necessário
    local old_timeout = nil
    if self.Socket.gettimeout then
        old_timeout = self.Socket:gettimeout()
    end
    
    if timeout then
        self.Socket:settimeout(timeout)
    end
    
    -- Receber mensagem (conforme API do PIStudio: tcp:receive())
    -- O formato pode ser receive() ou receive("*l") para receber linha
    local mensagem, err
    
    -- Tentar receber uma linha (até encontrar \n)
    if self.Socket.receive then
        -- No PIStudio, receive() pode aceitar padrão "*l" para linha ou número de bytes
        mensagem, err = self.Socket:receive("*l")
        
        -- Se não funcionar, tentar sem parâmetro
        if not mensagem and err then
            mensagem, err = self.Socket:receive()
        end
    else
        return nil, "Método receive não disponível no socket"
    end
    
    -- Restaurar timeout anterior
    if timeout and old_timeout then
        self.Socket:settimeout(old_timeout)
    end
    
    if mensagem then
        return mensagem
    else
        if err == "timeout" then
            return nil, "Timeout ao receber mensagem"
        else
            self.Connected = false
            return nil, "Erro ao receber mensagem: " .. tostring(err)
        end
    end
end

-- Função para enviar dados de motor via socket
function SocketClient:EnviarDadosMotor(motor)
    -- json.encode está disponível globalmente no PIStudio
    -- Não precisa de require("json") conforme documentação
    
    local data = {
        tipo = "motor",
        id = motor.ID,
        nome = motor.Nome,
        correnteAtual = motor.CorrenteAtual,
        status = motor.Status,
        horimetro = motor.Horimetro,
        timestamp = os.time()
    }
    
    local mensagem = json.encode(data)
    return self:EnviarMensagem(mensagem)
end

return SocketClient
