-- Classe MotorSync para sincronização bidirecional entre API e banco loca
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
    obj.SyncInterval = 60000 -- 1 minuto em milissegundos
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
    
    print("[Sync] === INICIANDO SINCRONIZAÇÃO ===")
    print("[Sync] Timestamp: " .. os.date("%Y-%m-%d %H:%M:%S"))
    
    -- Buscar motores da API
    print("[Sync] Buscando motores da API...")
    local motoresAPI, errAPI = self.APIClient:BuscarMotoresPlanta(self.PlantaUUID)
    
    if not motoresAPI then
        print("[Sync] ✗ Erro ao buscar motores da API: " .. tostring(errAPI))
        print("[Sync] ================================")
        return false
    end
    
    print("[Sync] ✓ " .. #motoresAPI .. " motores encontrados na API")
    
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
    print("[Sync] --- ETAPA 1: Sincronizando EXISTÊNCIA (API -> IHM) ---")
    for guid, motorAPI in pairs(motoresAPIMap) do
        local motorLocal = self.MotoresMemoria[guid]
        
        if not motorLocal then
            -- Motor não existe localmente, criar na IHM (API -> IHM)
            print(string.format("[Sync]   + Criando motor local (da API): %s (GUID: %s)", 
                motorAPI.nome or "Sem nome", guid))
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
        else
            print(string.format("[Sync]   = Motor já existe localmente: %s", motorAPI.nome or "Sem nome"))
        end
    end
    
    -- ETAPA 2: Sincronizar DADOS dos motores (bidirecional baseado em timestamp)
    print("[Sync] --- ETAPA 2: Sincronizando DADOS (bidirecional) ---")
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
                print(string.format("[Sync]   ↻ Atualizando motor local: %s (API: %s, Local: %s)", 
                    motorAPI.nome or "Sem nome", 
                    os.date("%Y-%m-%d %H:%M:%S", timestampAPI),
                    os.date("%Y-%m-%d %H:%M:%S", timestampLocal)))
                self:AtualizarMotorLocal(motorLocal.motor, motorAPI, timestampAPI)
                motorLocal.ultimaAtualizacao = timestampAPI
                atualizadosLocal = atualizadosLocal + 1
            elseif timestampLocal > timestampAPI then
                -- Local é mais recente, atualizar API
                print(string.format("[Sync]   ↻ Atualizando motor na API: %s (Local: %s, API: %s)", 
                    motorAPI.nome or "Sem nome",
                    os.date("%Y-%m-%d %H:%M:%S", timestampLocal),
                    os.date("%Y-%m-%d %H:%M:%S", timestampAPI)))
                local success = self:AtualizarMotorAPI(motorLocal.motor, motorAPI.id)
                if success then
                    -- Atualizar timestamp local após sucesso na API
                    motorLocal.ultimaAtualizacao = os.time()
                    atualizadosAPI = atualizadosAPI + 1
                end
            else
                -- Mesmo timestamp, sem necessidade de atualização
                print(string.format("[Sync]   = Motor já sincronizado: %s", motorAPI.nome or "Sem nome"))
            end
        end
    end
    
    -- Resumo da sincronização
    print("[Sync] === RESUMO DA SINCRONIZAÇÃO ===")
    print(string.format("[Sync] Criados na IHM (da API): %d", criadosLocal))
    print(string.format("[Sync] Atualizados na IHM (da API): %d", atualizadosLocal))
    print(string.format("[Sync] Atualizados na API (da IHM): %d", atualizadosAPI))
    print("[Sync] ==============================")
    
    return true
end

-- Função para criar motor local a partir de dados da API
function MotorSync:CriarMotorLocal(motorAPI)
    -- Converter dados da API para formato local
    local motor = Motor:new(
        nil, -- ID será gerado pelo banco
        motorAPI.nome or "",
        tonumber(motorAPI.registroModBus) or 0,
        tonumber(motorAPI.registroLocal) or 0,
        tonumber(motorAPI.correnteNominal) or 0
    )
    
    motor.GUID = motorAPI.id
    motor.CorrenteAtual = tonumber(motorAPI.correnteAtual) or 0
    motor.Status = motorAPI.status == "ligado" or false
    motor.Horimetro = tonumber(motorAPI.horimetro) or 0
    motor.CorrenteNominal = tonumber(motorAPI.correnteNominal) or 0
    
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
    motorLocal.CorrenteAtual = tonumber(motorAPI.correnteAtual) or motorLocal.CorrenteAtual
    motorLocal.Status = motorAPI.status == "ligado" or false
    motorLocal.Horimetro = tonumber(motorAPI.horimetro) or motorLocal.Horimetro
    motorLocal.CorrenteNominal = tonumber(motorAPI.correnteNominal) or motorLocal.CorrenteNominal
    
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
    if success then
        print(string.format("[Sync]   ✓ Motor atualizado na API: %s", motorLocal.Nome))
        return true
    else
        print(string.format("[Sync]   ✗ Erro ao atualizar motor na API: %s", tostring(err)))
        return false
    end
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
