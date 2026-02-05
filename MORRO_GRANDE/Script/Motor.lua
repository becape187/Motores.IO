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
    
    return obj
end

-- Método para definir a corrente atual
function Motor:setCorrenteAtual(valor)
    if valor and valor >= 0 then
        self.CorrenteAtual = valor
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


return Motor
