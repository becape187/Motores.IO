-- Clss SocketClient para comunicação via socke
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

    -- Controle de reconexão (evita vazamento de sockets e tempestade de reconexão)
    obj.ReconnectBackoffMin = 2000    -- intervalo mínimo entre tentativas (ms)
    obj.ReconnectBackoffMax = 30000   -- teto do backoff exponencial (ms)
    obj.ReconnectBackoff = 2000       -- backoff atual (ms)
    obj.LastConnectAttemptTime = nil  -- tick da última tentativa de conexão
    
    -- Intervalos em milissegundos (configuráveis)
    obj.ConnectionCheckInterval = 5000   -- Verificar conexão a cada 5 segundos (5000ms)
    obj.PoolingInterval = 10000          -- Enviar keep-alive a cada 10 segundos (10000ms)
    obj.DataSendInterval = 30000          -- Enviar dados do motor a cada 30 segundos (30000ms)
    
    -- Callback para obter dados do motor (será configurado externamente)
    obj.GetMotorDataCallback = nil
    
    -- Inicializar variáveis de controle de tempo (usando we_bas_gettickcount() que retorna milissegundos)
    local currentTime = we_bas_gettickcount()
    obj.LastConnectionCheckTime = currentTime
    obj.LastPoolingTime = currentTime
    obj.LastDataSendTime = currentTime
    
    return obj
end

-- Função para conectar ao socket (usando API do PIStudio)
function SocketClient:Conectar()
    -- Conforme documentação do PIStudio: local socket = require("socket")
    -- https://docs.we-con.com.cn/bin/view/PIStudio/09%20Lua%20Editor/Lua%20Script/#HSocketbasicfunction
    
    if not socket or not socket.tcp then
        return false, "Módulo socket não foi carregado corretamente"
    end

    -- Backoff: não tentar reconectar mais de 1x a cada ReconnectBackoff ms.
    -- Sem isso, falhas sucessivas geram uma tempestade de sockets novos.
    local agora = we_bas_gettickcount()
    if self.LastConnectAttemptTime and (agora - self.LastConnectAttemptTime) < self.ReconnectBackoff then
        return false, "Aguardando backoff de reconexão"
    end
    self.LastConnectAttemptTime = agora

    -- IMPORTANTE: fechar o socket anterior ANTES de criar um novo.
    -- Sem isso, cada reconexão deixava uma conexão TCP órfã (ESTAB no servidor) -> vazamento.
    if self.Socket then
        pcall(function() self.Socket:close() end)
        self.Socket = nil
        self.Connected = false
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
        self.ReconnectBackoff = self.ReconnectBackoffMin -- conexão ok: zera o backoff
        print("Socket conectado com sucesso em " .. self.Host .. ":" .. self.Port)
        return true
    else
        -- Falha: fechar o socket recém-criado para não deixar FD órfão
        pcall(function() self.Socket:close() end)
        self.Socket = nil
        self.Connected = false
        self.ReconnectAttempts = self.ReconnectAttempts + 1
        -- Backoff exponencial limitado ao teto
        self.ReconnectBackoff = math.min(self.ReconnectBackoff * 2, self.ReconnectBackoffMax)
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
    -- Verificação simples: apenas verifica se o socket existe e está marcado como conectado
    -- Não faz ping para evitar recursão e problemas de stack overflow
    -- O ping será feito apenas quando necessário (ex: no FazerPooling)
    if not self.Socket or not self.Connected then
        return false
    end
    
    -- Retorna true se socket existe e está marcado como conectado
    -- A verificação real da conexão será feita quando tentar enviar dados
    return true
end

-- Função para fazer pooling e manter conexão ativa
function SocketClient:FazerPooling()
    -- Verificação simples: apenas verifica se socket existe antes de enviar
    if not self.Socket or not self.Connected then
        print("Socket desconectado, tentando reconectar...")
        self:Conectar()
        return
    end
    
    -- Envia mensagem de keep-alive
    -- tcp:send() retorna: sent (número de bytes ou nil), err, last_byte
    local sent, err = self.Socket:send("KEEPALIVE\n")
    if not sent then
        print("Erro ao enviar keep-alive: " .. tostring(err))
        self:Desconectar()   -- fecha o socket morto antes de reconectar (sem vazar FD)
        self:Conectar()
    else
        -- Opcionalmente, verificar resposta do servidor (timeout curto)
        -- Usar verificação direta do socket para evitar recursão
        if self.Socket and self.Connected then
            local resposta, errResp = self:ReceberMensagem(1) -- timeout de 1 segundo
            if resposta then
                resposta = string.gsub(resposta, "\n", "") -- Remove quebra de linha
                if resposta ~= "OK" then
                    print("Resposta inesperada do servidor no keep-alive: " .. tostring(resposta))
                end
            end
            -- Se não recebeu resposta, continua normalmente (compatibilidade)
        end
    end
end

-- Função para enviar mensagem
function SocketClient:EnviarMensagem(mensagem)
    -- Verificação simples sem recursão: apenas verifica se socket existe
    if not self.Socket or not self.Connected then
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
        print("[Socket] ✗ Erro ao enviar: " .. tostring(err))
        self:Desconectar()   -- erro de envio = conexão morta: fechar de fato (sem vazar FD)
        return false, "Erro ao enviar mensagem: " .. tostring(err)
    end
end

-- Função para receber mensagem
function SocketClient:ReceberMensagem(timeout)
    -- Verificação simples sem recursão: apenas verifica se socket existe
    if not self.Socket or not self.Connected then
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
        if err ~= "timeout" then
            print("[Socket] ✗ Erro ao receber mensagem: " .. tostring(err))
            self:Desconectar()   -- erro de recepção (não-timeout) = conexão morta: fechar (sem vazar FD)
        end
        return nil, err == "timeout" and "Timeout ao receber mensagem" or "Erro ao receber mensagem: " .. tostring(err)
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
    
    if not success then
        print("[Socket] ✗ Erro ao enviar correntes: " .. tostring(err))
    end
    
    return success, err
end

-- Função para enviar dados de motor via socket
function SocketClient:EnviarDadosMotor(motor)
    -- Blindagem: 'motor' precisa ser tabela (objeto Motor). Cópias divergentes
    -- de Script_BG já mandaram boolean aqui e quebraram em motor.GUID.
    if type(motor) ~= "table" then
        print("[Socket] ✗ EnviarDadosMotor: 'motor' inválido (tipo "
              .. type(motor) .. ") — ignorando")
        return false, "motor inválido: tipo " .. type(motor)
    end

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

-- Função principal de loop - deve ser chamada periodicamente (ex: no we_bg_poll)
function SocketClient:Loop()
    -- Obter tempo atual em milissegundos usando função nativa da IHM
    local currentTime = we_bas_gettickcount()
    
    -- Verificar e manter conexão
    if currentTime - self.LastConnectionCheckTime >= self.ConnectionCheckInterval then
        self.LastConnectionCheckTime = currentTime
        
        -- Verificar se está conectado
        if not self:EstaConectado() then
            self:Conectar()
        end
    end
    
    -- Enviar keep-alive/pooling
    if currentTime - self.LastPoolingTime >= self.PoolingInterval then
        self.LastPoolingTime = currentTime
        
        -- Verificar se está conectado antes de enviar
        if self:EstaConectado() then
            -- Fazer pooling (keep-alive)
            self:FazerPooling()
        else
            -- Se não estiver conectado, tentar conectar
            local connected = self:Conectar()
            if connected then
                self:FazerPooling()
            end
        end
    end
    
    -- Enviar dados do motor
    if currentTime - self.LastDataSendTime >= self.DataSendInterval then
        self.LastDataSendTime = currentTime
        
        -- Verificar se callback está configurado
        if not self.GetMotorDataCallback then
            return
        end
        
        -- Obter dados do motor através do callback
        local motor = self.GetMotorDataCallback()
        if type(motor) ~= "table" then
            if motor ~= nil and motor ~= false then
                print("[Socket] ✗ GetMotorDataCallback retornou tipo inválido ("
                      .. type(motor) .. ") — ciclo ignorado")
            end
            return
        end
        
        -- Verificar se está conectado antes de enviar
        if self:EstaConectado() then
            -- Enviar dados do motor via socket
            local success, err = self:EnviarDadosMotor(motor)
            if not success then
                print("[Socket] ✗ Erro ao enviar dados do motor: " .. tostring(err))
                -- Se falhou, fechar a conexão de fato (não só a flag) para não vazar FD
                self:Desconectar()
            end
        else
            -- Se não estiver conectado, tentar conectar
            local connected = self:Conectar()
            if connected then
                local success, err = self:EnviarDadosMotor(motor)
                if not success then
                    print("[Socket] ✗ Erro ao enviar dados do motor: " .. tostring(err))
                end
            end
        end
    end
end

return SocketClient
