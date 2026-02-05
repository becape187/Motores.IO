-- l MtorCu=rrentReader para ler correntes dos motores da IHM
-- Lê os alrs dos registros locais e atualiza a corrente atual de cada motor em memória
MotorCurrentReader = {}
MotorCurrentReader.__index = MotorCurrentReader

-- Construtor
function MotorCurrentReader:new(motorSync, socketClient)
    local obj = {}
    setmetatable(obj, MotorCurrentReader)
    
    obj.MotorSync = motorSync -- Referência ao MotorSync que mantém os motores em memória
    obj.SocketClient = socketClient -- Referência ao SocketClient para enviar dados
    obj.LastUpdateTime = 0
    obj.UpdateInterval = 1 -- 1 segundo em milissegundos (pode ser ajustado)
    obj.Enabled = true
    
    return obj
end


-- Função para atualizar as correntes de todos os motores
function MotorCurrentReader:AtualizarCorrentes()
    if not self.Enabled then
        return
    end
    
    if not self.MotorSync or not self.MotorSync.Inicializado then
        return
    end
    
    local motoresMemoria = self.MotorSync.MotoresMemoria
    if not motoresMemoria then
        return
    end
    
    local atualizados = 0
    local erros = 0
    local correntesArray = {} -- Array para armazenar UUID e corrente atual de cada motor
    
    -- Iterar sobre todos os motores em memória
    for guid, motorData in pairs(motoresMemoria) do
        local motor = motorData.motor
        
        if motor and motor.RegistroLocal and motor.RegistroLocal ~= "" then
            local registro = motor.RegistroLocal
            local valorRegistro = we_bas_getint(registro)
            
            -- Verificar se conseguiu ler (nil indica erro, mas 0 é um valor válido)
            if valorRegistro ~= nil then
                -- Converter o valor lido para corrente
                local correnteAtual = tonumber(valorRegistro) or 0.0
                
                -- Atualizar a corrente atual do motor
                motor:setCorrenteAtual(correnteAtual)
                atualizados = atualizados + 1
                
                -- Adicionar ao array de correntes para envio via socket
                if motor.GUID then
                    table.insert(correntesArray, {
                        id = motor.GUID,
                        correnteAtual = correnteAtual
                    })
                end
            else
                -- Não conseguiu ler o registro
                erros = erros + 1
            end
        end
    end
    
    -- Enviar array de correntes via socket se houver dados e socket estiver disponível
    if #correntesArray > 0 and self.SocketClient then
        -- Obter plantaId do MotorSync
        local plantaId = self.MotorSync and self.MotorSync.PlantaUUID or nil
        self.SocketClient:EnviarCorrentesArray(correntesArray, plantaId)
    end
end

-- Função para habilitar/desabilitar atualizações
function MotorCurrentReader:SetEnabled(enabled)
    self.Enabled = enabled
    if enabled then
        print("[CurrentReader] ✓ Atualização de correntes habilitada")
    else
        print("[CurrentReader] ✗ Atualização de correntes desabilitada")
    end
end

-- Função para loop (pode ser chamada no we_bg_poll)
-- Atualiza as correntes a cada intervalo configurado
function MotorCurrentReader:Loop()
    if not self.Enabled then
        return
    end
    
    local currentTime = we_bas_gettickcount()
    
    -- Verificar se passou o intervalo desde a última atualização
    if currentTime - self.LastUpdateTime >= self.UpdateInterval then
        self:AtualizarCorrentes()
        self.LastUpdateTime = currentTime
    end
end

-- Função para obter estatísticas
function MotorCurrentReader:GetEstatisticas()
    if not self.MotorSync or not self.MotorSync.Inicializado then
        return {
            totalMotores = 0,
            motoresComRegistro = 0,
            motoresSemRegistro = 0
        }
    end
    
    local totalMotores = 0
    local motoresComRegistro = 0
    local motoresSemRegistro = 0
    
    for guid, motorData in pairs(self.MotorSync.MotoresMemoria) do
        local motor = motorData.motor
        totalMotores = totalMotores + 1
        
        if motor and motor.RegistroLocal and motor.RegistroLocal ~= "" then
            motoresComRegistro = motoresComRegistro + 1
        else
            motoresSemRegistro = motoresSemRegistro + 1
        end
    end
    
    return {
        totalMotores = totalMotores,
        motoresComRegistro = motoresComRegistro,
        motoresSemRegistro = motoresSemRegistro,
        enabled = self.Enabled,
        updateInterval = self.UpdateInterval
    }
end

return MotorCurrentReader
