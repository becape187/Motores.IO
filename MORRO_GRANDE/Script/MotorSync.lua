-- Case MooSync para sinconização bidirecional entre API e banco loc
MotorSync = {}
MotorSync.__index = MotorSync

-- Construtor
function MotorSync:new(apiClient, sqliteDB, plantaUUID)
    local obj = {}
    setmetatable(obj, MotorSync)
    
    obj.APIClient = apiClient
    obj.SQLiteDB = sqliteDB
    obj.PlantaUUID = plantaUUID
    obj.MotoresMemoria = {} -- Tabela em memória: [GUID] = {motor, ultimaAtualizacao}
    obj.LastSyncTime = 0
    obj.SyncInterval = 300000 -- 20 segundos em milissegundos
    obj.Inicializado = false
    
    return obj
end

-- Função para inicializar: carregar motores do banco local para memória
function MotorSync:Inicializar()
    print("[Sync] === INICIALIZAÇÃO ===")
    
    if not self.SQLiteDB.Connected then
        print("[Sync] ✗ Banco de dados local não está conectado")
        return false
    end
    
    -- Buscar todos os motores do banco local
    local motores = self.SQLiteDB:BuscarTodosMotores()
    
    print("[Sync] Carregando " .. #motores .. " motores do banco local...")
    
    -- Carregar para memória
    self.MotoresMemoria = {}
    for _, motor in ipairs(motores) do
        if motor.GUID then
            -- Buscar última atualização do banco
            local ultimaAtualizacaoStr = self.SQLiteDB:BuscarUltimaAtualizacaoMotor(motor.GUID)
            local ultimaAtualizacao = 0
            if ultimaAtualizacaoStr then
                ultimaAtualizacao = self:StringParaTimestamp(ultimaAtualizacaoStr)
            end
            self.MotoresMemoria[motor.GUID] = {
                motor = motor,
                ultimaAtualizacao = ultimaAtualizacao
            }
            print(string.format("[Sync]   - Motor carregado: %s (GUID: %s, Última atualização: %s)", 
                motor.Nome, motor.GUID, ultimaAtualizacaoStr or "N/A"))
        else
            print("[Sync]   ⚠ Motor sem GUID ignorado: " .. motor.Nome)
        end
    end
    
    print("[Sync] ✓ " .. #motores .. " motores carregados em memória")
    print("[Sync] =====================")
    
    self.Inicializado = true
    return true
end

-- Função para converter string ISO para timestamp Unix
function MotorSync:StringParaTimestamp(isoString)
    if not isoString or isoString == "" then
        return 0
    end
    -- Parse ISO string (formato: 2024-01-01T12:00:00Z ou 2024-01-01T12:00:00.000Z)
    local year, month, day, hour, min, sec = isoString:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
    if year and month and day and hour and min and sec then
        return os.time({
            year = tonumber(year),
            month = tonumber(month),
            day = tonumber(day),
            hour = tonumber(hour),
            min = tonumber(min),
            sec = tonumber(sec)
        })
    end
    return 0
end

-- Função para sincronizar: comparar e atualizar baseado em timestamps
function MotorSync:Sincronizar()
    if not self.Inicializado then
        print("[Sync] ⚠ Sincronização não inicializada, inicializando agora...")
        self:Inicializar()
        return
    end
    
    -- Buscar motores da API
    local motoresAPI, errAPI = self.APIClient:BuscarMotoresPlanta(self.PlantaUUID)
    
    if not motoresAPI then
        print("[Sync] ✗ Erro ao buscar motores da API: " .. tostring(errAPI))
        print("[Sync] ================================")
        return false
    end
    
    
    -- Criar tabela de motores da API indexada por GUID
    local motoresAPIMap = {}
    for _, motorAPI in ipairs(motoresAPI) do
        if motorAPI.id then
            motoresAPIMap[motorAPI.id] = motorAPI
        end
    end
    
    local atualizadosLocal = 0
    local atualizadosAPI = 0
    local criadosLocal = 0
    
    -- ETAPA 1: Sincronizar EXISTÊNCIA de motores (API -> IHM)
    -- A IHM NUNCA cria motores na API, apenas recebe da API
    for guid, motorAPI in pairs(motoresAPIMap) do
        local motorLocal = self.MotoresMemoria[guid]
        
        if not motorLocal then
            -- Motor não existe localmente, criar na IHM (API -> IHM)
            local timestampAPI = 0
            if motorAPI.dataAtualizacao then
                timestampAPI = self:StringParaTimestamp(motorAPI.dataAtualizacao)
            end
            local novoMotor = self:CriarMotorLocal(motorAPI)
            if novoMotor then
                self.MotoresMemoria[guid] = {
                    motor = novoMotor,
                    ultimaAtualizacao = timestampAPI
                }
                criadosLocal = criadosLocal + 1
            end
        end
    end
    
    -- ETAPA 2: Sincronizar DADOS dos motores (bidirecional baseado em timestamp)
    for guid, motorAPI in pairs(motoresAPIMap) do
        local motorLocal = self.MotoresMemoria[guid]
        
        if motorLocal then
            -- Motor existe em ambos, comparar timestamps para atualização bidirecional
            local timestampAPI = 0
            if motorAPI.dataAtualizacao then
                timestampAPI = self:StringParaTimestamp(motorAPI.dataAtualizacao)
            end
            local timestampLocal = motorLocal.ultimaAtualizacao or 0
            
            if timestampAPI > timestampLocal then
                -- API é mais recente, atualizar local
                self:AtualizarMotorLocal(motorLocal.motor, motorAPI, timestampAPI)
                motorLocal.ultimaAtualizacao = timestampAPI
                atualizadosLocal = atualizadosLocal + 1
            elseif timestampLocal > timestampAPI then
                -- Local é mais recente, atualizar API
                local success = self:AtualizarMotorAPI(motorLocal.motor, motorAPI.id)
                if success then
                    -- Atualizar timestamp local após sucesso na API
                    motorLocal.ultimaAtualizacao = os.time()
                    atualizadosAPI = atualizadosAPI + 1
                end
            end
        end
    end
    
    -- Resumo da sincronização (apenas se houver mudanças)
    if criadosLocal > 0 or atualizadosLocal > 0 or atualizadosAPI > 0 then
        print(string.format("[Sync] Sync: +%d criados, ↻%d atualizados (IHM), ↻%d atualizados (API)", 
            criadosLocal, atualizadosLocal, atualizadosAPI))
    end
    
    return true
end

-- Função para criar motor local a partir de dados da API
function MotorSync:CriarMotorLocal(motorAPI)
    -- Converter dados da API para formato local
    local motor = Motor:new(
        nil, -- ID será gerado pelo banco
        motorAPI.nome or "",
        tostring(motorAPI.registroModBus or ""),
        tostring(motorAPI.registroLocal or ""),
        tonumber(motorAPI.correnteNominal) or 0
    )
    
    motor.GUID = motorAPI.id
    motor.Potencia = tonumber(motorAPI.potencia) or 0.0
    motor.Tensao = tonumber(motorAPI.tensao) or 0.0
    motor.CorrenteAtual = tonumber(motorAPI.correnteAtual) or 0
    motor.CorrenteNominal = tonumber(motorAPI.correnteNominal) or 0
    motor.PercentualCorrenteMaxima = tonumber(motorAPI.percentualCorrenteMaxima) or 0.0
    motor.Histerese = tonumber(motorAPI.histerese) or 0.0
    motor.Status = motorAPI.status == "ligado" or false
    motor.Horimetro = tonumber(motorAPI.horimetro) or 0.0
    motor.Habilitado = motorAPI.habilitado ~= false  -- true por padrão se não especificado
    motor.PosicaoX = tonumber(motorAPI.posicaoX) or 0.0
    motor.PosicaoY = tonumber(motorAPI.posicaoY) or 0.0
    motor.HorimetroProximaManutencao = motorAPI.horimetroProximaManutencao
    motor.DataEstimadaProximaManutencao = motorAPI.dataEstimadaProximaManutencao
    motor.DataCriacao = motorAPI.dataCriacao
    
    -- Salvar no banco local com timestamp da API
    local timestampAPI = 0
    if motorAPI.dataAtualizacao then
        timestampAPI = self:StringParaTimestamp(motorAPI.dataAtualizacao)
    end
    local success = self.SQLiteDB:InserirOuAtualizarMotor(motor, timestampAPI)
    if success then
        return motor
    end
    return nil
end

-- Função para atualizar motor local a partir de dados da API
function MotorSync:AtualizarMotorLocal(motorLocal, motorAPI, timestampAPI)
    motorLocal.Nome = motorAPI.nome or motorLocal.Nome
    motorLocal.Potencia = tonumber(motorAPI.potencia) or motorLocal.Potencia
    motorLocal.Tensao = tonumber(motorAPI.tensao) or motorLocal.Tensao
    motorLocal.RegistroModBus = tostring(motorAPI.registroModBus or motorLocal.RegistroModBus or "")
    motorLocal.RegistroLocal = tostring(motorAPI.registroLocal or motorLocal.RegistroLocal or "")
    motorLocal.CorrenteAtual = tonumber(motorAPI.correnteAtual) or motorLocal.CorrenteAtual
    motorLocal.CorrenteNominal = tonumber(motorAPI.correnteNominal) or motorLocal.CorrenteNominal
    motorLocal.PercentualCorrenteMaxima = tonumber(motorAPI.percentualCorrenteMaxima) or motorLocal.PercentualCorrenteMaxima
    motorLocal.Histerese = tonumber(motorAPI.histerese) or motorLocal.Histerese
    motorLocal.Status = motorAPI.status == "ligado" or false
    motorLocal.Horimetro = tonumber(motorAPI.horimetro) or motorLocal.Horimetro
    if motorAPI.habilitado ~= nil then
        motorLocal.Habilitado = motorAPI.habilitado
    end
    motorLocal.PosicaoX = tonumber(motorAPI.posicaoX) or motorLocal.PosicaoX
    motorLocal.PosicaoY = tonumber(motorAPI.posicaoY) or motorLocal.PosicaoY
    if motorAPI.horimetroProximaManutencao ~= nil then
        motorLocal.HorimetroProximaManutencao = motorAPI.horimetroProximaManutencao
    end
    if motorAPI.dataEstimadaProximaManutencao ~= nil then
        motorLocal.DataEstimadaProximaManutencao = motorAPI.dataEstimadaProximaManutencao
    end
    if motorAPI.dataCriacao ~= nil then
        motorLocal.DataCriacao = motorAPI.dataCriacao
    end
    
    -- Atualizar no banco local com timestamp
    self.SQLiteDB:InserirOuAtualizarMotor(motorLocal, timestampAPI)
end

-- Função para atualizar motor na API
function MotorSync:AtualizarMotorAPI(motorLocal, guidAPI)
    local dados = {
        id = guidAPI,
        nome = motorLocal.Nome,
        status = motorLocal.Status and "ligado" or "desligado",
        horimetro = motorLocal.Horimetro,
        correnteAtual = motorLocal.CorrenteAtual,
        registroModBus = tostring(motorLocal.RegistroModBus),
        registroLocal = tostring(motorLocal.RegistroLocal),
        correnteNominal = motorLocal.CorrenteNominal
    }
    
    local success, err = self.APIClient:AtualizarMotorPlanta(self.PlantaUUID, guidAPI, dados)
    if not success then
        print(string.format("[Sync] ✗ Erro ao atualizar motor na API: %s - %s", motorLocal.Nome, tostring(err)))
    end
    return success
end

-- Função para criar motor na API (REMOVIDA - IHM nunca cria motores na API)
-- A criação de motores é sempre feita pela API, a IHM apenas recebe

-- Função de loop - deve ser chamada periodicamente
function MotorSync:Loop()
    local currentTime = we_bas_gettickcount()
    
    if currentTime - self.LastSyncTime >= self.SyncInterval then
        self.LastSyncTime = currentTime
        self:Sincronizar()
    end
end

-- Função para obter motor da memória por GUID
function MotorSync:ObterMotor(guid)
    local motorData = self.MotoresMemoria[guid]
    if motorData then
        return motorData.motor
    end
    return nil
end

-- Função para obter todos os motores da memória
function MotorSync:ObterTodosMotores()
    local motores = {}
    for guid, motorData in pairs(self.MotoresMemoria) do
        table.insert(motores, motorData.motor)
    end
    return motores
end

return MotorSync
