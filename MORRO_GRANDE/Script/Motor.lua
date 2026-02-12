-- CasseMotor
Motor = {}
Motor.__index = Motor

-- Construtor
function Motor:new(id, nome, registroModBus, registroLocal, correnteNominal)
    local obj = {}
    setmetatable(obj, Motor)
    
    obj.ID = id or ""
    obj.Nome = nome or ""
    obj.GUID = nil -- GUID do motor na API
    obj.Potencia = 0.0
    obj.Tensao = 0.0
    obj.RegistroModBus = registroModBus or ""
    obj.RegistroLocal = registroLocal or ""
    obj.CorrenteAtual = 0.0
    obj.CorrenteNominal = correnteNominal or 0.0
    obj.PercentualCorrenteMaxima = 0.0  -- Nome da API: percentualCorrenteMaxima
    obj.Histerese = 0.0  -- Nome da API: histerese
    obj.Status = false
    obj.Horimetro = 0.0
    obj.Habilitado = true
    obj.PosicaoX = 0.0
    obj.PosicaoY = 0.0
    obj.HorimetroProximaManutencao = nil
    obj.DataEstimadaProximaManutencao = nil
    obj.DataCriacao = nil
    
    -- Sistema de monitoramento de corrente (buffer circular)
    obj.AmostrasCorrente = {} -- Array fixo de 60 posições para buffer circular
    for i = 1, 60 do
        obj.AmostrasCorrente[i] = nil -- Inicializar todas as posições como nil
    end
    obj.IndiceAmostra = 0 -- Ponteiro rotativo (0 a 59)
    obj.TotalAmostras = 0 -- Contador de amostras válidas (até 60)
    obj.CorrenteMaxima = nil -- Corrente máxima registrada
    obj.CorrenteMinima = nil -- Corrente mínima registrada
    obj.UltimaAmostraTime = 0 -- Timestamp da última amostra
    obj.UltimoRegistroBancoTime = we_bas_gettickcount() -- Timestamp do último registro no banco (inicializa com tempo atual)
    
    return obj
end

-- Método para definir a corrent atual
function Motor:setCorrenteAtual(valor)
    if valor and valor >= 0 then
        self.CorrenteAtual = valor
        
        -- Atualizar status baseado na corrente: se maior que 2A (200 em centésimos), motor está ligado
        if valor > 200 then
            self.Status = true  -- Ligado
        else
            self.Status = false -- Desligado
        end
        
        return true
    else
        return false, "Corrente inválida"
    end
end

-- Método para obter informações do motor
function Motor:getInfo()
    return string.format(
        "Motor [ID: %d, Nome: %s, ModBus: %d, Local: %d, Corrente: %.2fA (Nominal: %.2fA), PercentErro: %.2f%%, Histerese: %.2f%%, Status: %s, Horimetro: %.2fh]",
        self.ID,
        self.Nome,
        self.RegistroModBus,
        self.RegistroLocal,
        self.CorrenteAtual,
        self.CorrenteNominal,
        self.PercentCorrenteMaximaErro,
        self.PercentHistereseErro,
        self.Status and "Ligado" or "Desligado",
        self.Horimetro
    )
end

-- Método para verificar se a corrente está dentro dos limites (baseado na corrente nominal e percentual de erro)
function Motor:correnteValida()
    if self.CorrenteNominal <= 0 then
        return true -- Se não há corrente nominal definida, considera válido
    end
    
    local limiteMaximo = self.CorrenteNominal * (1 + (self.PercentCorrenteMaximaErro / 100))
    return self.CorrenteAtual <= limiteMaximo
end

-- Método para definir o percentual de corrente máxima de erro
function Motor:setPercentCorrenteMaximaErro(valor)
    self.PercentCorrenteMaximaErro = valor or 0.0
end

-- Método para definir o percentual de histerese de erro
function Motor:setPercentHistereseErro(valor)
    self.PercentHistereseErro = valor or 0.0
end

-- Método para definir o status do motor
function Motor:setStatus(status)
    self.Status = status or false
end

-- Método para atualizar o horímetro (adiciona horas)
function Motor:adicionarHoras(horas)
    if horas and horas > 0 then
        self.Horimetro = self.Horimetro + horas
    end
end

-- Método para adicionar amostra de corrente (chamado a cada 1 segundo)
-- Usa buffer circular rotativo para manter sempre os últimos 60 segundos
function Motor:adicionarAmostraCorrente(corrente)
    local currentTime = we_bas_gettickcount()
    
    -- Verificar se passou 1 segundo desde a última amostra
    if currentTime - self.UltimaAmostraTime >= 1000 then
        -- Incrementar índice rotativo (1 a 60)
        -- Usa módulo para garantir rotação: quando chega em 60, volta para 1
        self.IndiceAmostra = ((self.IndiceAmostra) % 60) + 1
        
        -- Armazenar amostra na posição atual do buffer circular
        -- Sobrescreve a posição mais antiga quando o buffer está cheio
        self.AmostrasCorrente[self.IndiceAmostra] = corrente
        
        -- Incrementar contador de amostras válidas (até máximo de 60)
        if self.TotalAmostras < 60 then
            self.TotalAmostras = self.TotalAmostras + 1
        end
        
        -- Verificar e atualizar corrente máxima e mínima
        self:verificarCorrenteMaximaMinima(corrente)
        
        self.UltimaAmostraTime = currentTime
    end
end

-- Método para verificar e atualizar corrente máxima e mínima
function Motor:verificarCorrenteMaximaMinima(corrente)
    -- Verificar se a corrente está no range válido (maior que 400 e menor que 65535)
    if corrente > 400 and corrente < 60000 then
        -- Verificar corrente máxima
        if self.CorrenteMaxima == nil or corrente > self.CorrenteMaxima then
            self.CorrenteMaxima = corrente
        end
        
        -- Verificar corrente mínima
        if self.CorrenteMinima == nil or corrente < self.CorrenteMinima then
            self.CorrenteMinima = corrente
        end
    end
end

-- Método para calcular média das amostras (buffer circular)
function Motor:calcularMediaCorrente()
    if self.TotalAmostras == 0 then
        return 0.0
    end
    
    local soma = 0.0
    local contador = 0
    
    -- Percorrer todas as 60 posições do buffer circular
    -- Somar apenas as posições que têm valor válido (não nil)
    for i = 1, 60 do
        local valor = self.AmostrasCorrente[i]
        if valor ~= nil then
            soma = soma + valor
            contador = contador + 1
        end
    end
    
    if contador == 0 then
        return 0.0
    end
    
    -- Retornar média baseada no número de amostras válidas
    -- Se completou 60 amostras, sempre será 60, senão será o número atual
    return soma / contador
end

-- Método para obter corrente média (getter)
function Motor:getCorrenteMedia()
    return self:calcularMediaCorrente()
end

-- Método para obter corrente máxima registrada
function Motor:getCorrenteMaxima()
    return self.CorrenteMaxima or nil
end

-- Método para obter corrente mínima registrada
function Motor:getCorrenteMinima()
    return self.CorrenteMinima or nil
end

-- Método para verificar se deve registrar no banco (após 1 minuto)
function Motor:verificarRegistroBanco(sqliteDB, socketClient)
    if not sqliteDB then
        return false
    end
    
    local currentTime = we_bas_gettickcount()
    
    -- Verificar se passou 1 minuto (60000 ms) desde o último registro
    if currentTime - self.UltimoRegistroBancoTime >= 60000 then
        -- Calcular média das amostras
        local media = self:calcularMediaCorrente()
        local correnteInstantanea = self.CorrenteAtual or 0.0
        local correnteMaxima = self.CorrenteMaxima
        local correnteMinima = self.CorrenteMinima
        
        -- Registrar no banco de dados local
        if sqliteDB:RegistrarDadosCorrente(self.ID, self.GUID, media, correnteMaxima, correnteMinima) then
            -- Enviar para a API via socket (se disponível)
            if socketClient and self.GUID then
                socketClient:EnviarHistoricoMotor({
                    id = self.GUID,
                    correnteAtual = correnteInstantanea,
                    correnteMedia = media,
                    correnteMaxima = correnteMaxima,
                    correnteMinima = correnteMinima,
                    status = self.Status and "ligado" or "desligado",
                    timestamp = os.time()
                })
            end
            
            -- Resetar máximo e mínimo após registrar
            self.CorrenteMaxima = nil
            self.CorrenteMinima = nil
            -- Não limpar o buffer circular - ele continua rotativo
            -- Apenas resetar o contador se necessário (mas mantém as últimas amostras)
            -- O buffer continuará sendo sobrescrito naturalmente
            self.UltimoRegistroBancoTime = currentTime
            return true
        end
    end
    
    return false
end


return Motor
