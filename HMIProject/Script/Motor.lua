-- Classe Motor
Motor = {}
Motor.__index = Motor

-- Construtor
function Motor:new(id, nome, registroModBus, registroLocal, correnteMinima, correnteMaxima, correnteInicial)
    local obj = {}
    setmetatable(obj, Motor)
    
    obj.ID = id or 0
    obj.Nome = nome or ""
    obj.RegistroModBus = registroModBus or ""
    obj.RegistroLocal = registroLocal or ""
    obj.CorrenteAtual = 0.0
    obj.CorrenteMinima = correnteMinima or 0.0
    obj.CorrenteMaxima = correnteMaxima or 0.0
    obj.CorrenteInicial = correnteInicial or 0.0
    obj.PercentCorrenteMaximaErro = 0.0
    obj.PercentHistereseErro = 0.0
    obj.Status = false
    obj.Horimetro = 0.0
    
    return obj
end

-- Método para definir a corrente atual
function Motor:setCorrenteAtual(valor)
    if valor >= self.CorrenteMinima and valor <= self.CorrenteMaxima then
        self.CorrenteAtual = valor
        return true
    else
        return false, "Corrente fora dos limites permitidos"
    end
end

-- Método para obter informações do motor
function Motor:getInfo()
    return string.format(
        "Motor [ID: %d, Nome: %s, ModBus: %d, Local: %d, Corrente: %.2fA (Min: %.2fA, Max: %.2fA, Inicial: %.2fA), PercentErro: %.2f%%, Histerese: %.2f%%, Status: %s, Horimetro: %.2fh]",
        self.ID,
        self.Nome,
        self.RegistroModBus,
        self.RegistroLocal,
        self.CorrenteAtual,
        self.CorrenteMinima,
        self.CorrenteMaxima,
        self.CorrenteInicial,
        self.PercentCorrenteMaximaErro,
        self.PercentHistereseErro,
        self.Status and "Ligado" or "Desligado",
        self.Horimetro
    )
end

-- Método para verificar se a corrente está dentro dos limites
function Motor:correnteValida()
    return self.CorrenteAtual >= self.CorrenteMinima and self.CorrenteAtual <= self.CorrenteMaxima
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

-- Método para resetar o horímetro
function Motor:resetarHorimetro()
    self.Horimetro = 0.0
end

return Motor
