-- Classe Logger para interceptar prints e erros, enviando via socket quando conectado
-- Sempre mntém o print original também
Logger = {}
Logger.__index = Logger

-- Guardar referência ao print original e pcall original (para evitar recursão)
local printOriginal = print
local pcallOriginal = pcall
local db1 =0
local db2 = 0
local db3 = 0
local db4 = 0

-- Construtor
function Logger:new(socketClient, plantaId)
    local obj = {}
    setmetatable(obj, Logger)
    
    obj.SocketClient = socketClient
    obj.PlantaId = plantaId or nil
    obj.Enabled = true
    -- Inicializar LastPingTime com tempo atual menos intervalo para enviar primeiro ping logo
    obj.LastPingTime = we_bas_gettickcount() - 30000  -- Inicializar para enviar primeiro ping imediatamente
    obj.PingInterval = 5000  -- 30 segundos em milissegundos
    
    return obj
end

-- Função para enviarmensagem via socket (se conectado)
function Logger:EnviarParaSocket(mensagem, tipo)
        we_bas_setdword("@HDW305",2)
    if not self.Enabled then
        we_bas_setdword("@HDW305",3)
        return
    end
    
    if not self.SocketClient then
        we_bas_setdword("@HDW305",4)
        return
    end
    
    -- Verificar se socket está conectado
    if not self.SocketClient:EstaConectado() then
        we_bas_setdword("@HDW305",5)
        return
    end
    we_bas_setdword("@HDW305",6)
    -- Criar payload JSON para o console
    local payload = {
        tipo = tipo or "log",  -- "log", "error", "warn", "info"
        mensagem = mensagem,
        timestamp = os.time(),
        nivel = tipo or "log",
        plantaId = self.PlantaId  -- Incluir plantaId se disponível
    }
    we_bas_setdword("@HDW305",7)
    -- Enviar via socket (não bloquear se falhar)
    -- Usar pcallOriginal para evitar recursão
    local success, err = pcallOriginal(function()
        local jsonMsg = json.encode(payload)
        self.SocketClient:EnviarMensagem(jsonMsg)
    end)
    
    -- Se falhar, não fazer nada (não queremos que logger cause erros)
    if not success then
        we_bas_setdword("@HDW305",8)
        -- Silenciosamente falha (não queremos recursão)
    else
        we_bas_setdword("@HDW305",10)
    end
end

-- Função para log (substitui print)
function Logger:Log(mensagem, tipo)
    -- Sempre imprimir no console original
    printOriginal(mensagem)
    
    -- Se socket conectado, enviar também
    if self.SocketClient and self.SocketClient:EstaConectado() then
        self:EnviarParaSocket(mensagem, tipo or "log")
    end
end

-- Função para log de erro
function Logger:LogError(mensagem)
    -- Sempre imprimir no console original
    printOriginal("[ERRO] " .. tostring(mensagem))
    
    -- Se socket conectado, enviar também
    if self.SocketClient and self.SocketClient:EstaConectado() then
        self:EnviarParaSocket(tostring(mensagem), "error")
    end
end

-- Função para log de aviso
function Logger:LogWarn(mensagem)
    -- Sempre imprimir no console original
    printOriginal("[AVISO] " .. tostring(mensagem))
    
    -- Se socket conectado, enviar também
    if self.SocketClient and self.SocketClient:EstaConectado() then
        self:EnviarParaSocket(tostring(mensagem), "warn")
    end
end

-- Função para log de informação
function Logger:LogInfo(mensagem)
    -- Sempre imprimir no console original
    printOriginal("[INFO] " .. tostring(mensagem))
    
    -- Se socket conectado, enviar também
    if self.SocketClient and self.SocketClient:EstaConectado() then
        self:EnviarParaSocket(tostring(mensagem), "info")
    end
end

-- Função para substituir print global
function Logger:SubstituirPrint()
    -- Substituir print global por nossa função
    _G.print = function(...)
        local args = {...}
        local mensagem = ""
        
        -- Concatenar todos os argumentos
        for i, arg in ipairs(args) do
            if i > 1 then
                mensagem = mensagem .. "\t"
            end
            mensagem = mensagem .. tostring(arg)
        end
        
        -- Usar nosso logger
        self:Log(mensagem, "log")
    end
end

-- Função para configurar tratamento de erros
function Logger:ConfigurarTratamentoErros()
    -- Usar pcallOriginal já salvo no início do arquivo (evita recursão)
    
    -- Substituir pcall global para capturar erros
    _G.pcall = function(func, ...)
        -- Passar argumentos diretamente usando ... (mais eficiente e compatível)
        local success, result = pcallOriginal(func, ...)
        
        -- Se falhou, enviar erro para socket
        if not success then
            self:LogError("ERRO EM PCALL: " .. tostring(result))
        end
        
        return success, result
    end
    
    -- Interceptar erros usando xpcall também
    local xpcallOriginal = _G.xpcall
    
    -- Substituir xpcall global
    _G.xpcall = function(func, errorHandler, ...)
        -- Criar error handler que também envia para socket
        local enhancedErrorHandler = function(err)
            -- Enviar erro para socket primeiro
            self:LogError("ERRO CAPTURADO EM XPCALL: " .. tostring(err))
            
            -- Chamar handler original
            local result = errorHandler(err)
            
            -- Se o handler retornar algo, usar, senão retornar erro
            return result or err
        end
        
        -- Chamar xpcall original com handler aprimorado
        -- Passar argumentos diretamente usando ... (mais eficiente e compatível)
        return xpcallOriginal(func, enhancedErrorHandler, ...)
    end
end

-- Função para habilitar/desabilitar logger
function Logger:SetEnabled(enabled)
    self.Enabled = enabled
end

-- Função para enviar ping periódico (deve ser chamada no loop principal)
function Logger:EnviarPing()
    if not self.Enabled then
        return
    end
    
    if not self.SocketClient then 
        return
    end
    
    -- Verificar se socket está conectado
    if not self.SocketClient:EstaConectado() then
        return
    end
    
    -- Verificar se passou o intervalo desde o último ping
    local currentTime = we_bas_gettickcount()
    if currentTime - self.LastPingTime < self.PingInterval then
        return
    end
    
    -- Atualizar último ping
    self.LastPingTime = currentTime
    
    -- Enviar ping
    self:EnviarParaSocket("PING - Sistema ativo e conectado", "info")
    return
end

return Logger
