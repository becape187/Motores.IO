-- Classe SQLiteDB para interagir com SQLite (API nativa do PIStudio)
SQLiteDB = {}
SQLiteDB.__index = SQLiteDB

-- Construtor
function SQLiteDB:new(dbPath)
    local obj = {}
    setmetatable(obj, SQLiteDB)
    
    obj.DBPath = dbPath or "motores.db"
    obj.DB = nil
    obj.Connected = false
    
    return obj
end

-- Função para conectar ao banco de dados
function SQLiteDB:Conectar()
    -- Conforme documentação do PIStudio: sqlite3 é global
    -- Sintaxe: db = sqlite3.open(filename)
    
    if not sqlite3 or not sqlite3.open then
        return false, "LuaSqlite não está disponível. Verifique se o módulo está habilitado no PIStudio."
    end
    
    -- Abrir banco de dados conforme documentação
    self.DB = sqlite3.open(self.DBPath)
    
    if self.DB then
        self.Connected = true
        self:CriarTabelas()
        print("Conectado ao banco de dados: " .. self.DBPath)
        return true
    else
        self.Connected = false
        local err = "Não foi possível abrir o banco de dados: " .. self.DBPath
        print("Erro ao conectar ao banco de dados: " .. tostring(err))
        return false, err
    end
end

-- Função auxiliar para escapar strings SQL
function SQLiteDB:escapeString(str)
    if not str then
        return "NULL"
    end
    
    -- Usar db:escape() conforme documentação do PIStudio
    if self.DB and self.DB.escape then
        local escaped = self.DB:escape(str)
        return "'" .. escaped .. "'"
    else
        -- Fallback: escape manual básico (substituir ' por '')
        str = string.gsub(str, "'", "''")
        return "'" .. str .. "'"
    end
end

-- Função para criar tabelas necessárias
function SQLiteDB:CriarTabelas()
    if not self.Connected then
        return false
    end
    
    -- Tabela de motores
    local sql_motores = [[
        CREATE TABLE IF NOT EXISTS motores (
            id INTEGER PRIMARY KEY,
            nome TEXT NOT NULL,
            registroModBus INTEGER,
            registroLocal INTEGER,
            correnteAtual REAL DEFAULT 0.0,
            correnteNominal REAL DEFAULT 0.0,
            percentCorrenteMaximaErro REAL DEFAULT 0.0,
            percentHistereseErro REAL DEFAULT 0.0,
            status INTEGER DEFAULT 0,
            horimetro REAL DEFAULT 0.0,
            ultimaAtualizacao TEXT DEFAULT CURRENT_TIMESTAMP
        )
    ]]
    
    -- Tabela de histórico de correntes
    local sql_historico = [[
        CREATE TABLE IF NOT EXISTS historico_correntes (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            motor_id INTEGER NOT NULL,
            corrente REAL NOT NULL,
            timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (motor_id) REFERENCES motores(id)
        )
    ]]
    
    -- Tabela de eventos
    local sql_eventos = [[
        CREATE TABLE IF NOT EXISTS eventos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            motor_id INTEGER,
            tipo TEXT NOT NULL,
            descricao TEXT,
            timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (motor_id) REFERENCES motores(id)
        )
    ]]
    
    -- Usando db:execute() conforme API do PIStudio
    local success1 = self.DB:execute(sql_motores)
    local success2 = self.DB:execute(sql_historico)
    local success3 = self.DB:execute(sql_eventos)
    
    if success1 and success2 and success3 then
        print("Tabelas criadas/verificadas com sucesso")
        return true
    else
        local err = "Erro ao criar tabelas"
        print("Erro ao criar tabelas: " .. tostring(err))
        return false
    end
end

-- Função para inserir ou atualizar motor
function SQLiteDB:SalvarMotor(motor)
    if not self.Connected then
        return false, "Banco de dados não está conectado"
    end
    
    -- Usando db:execute() com valores escapados
    local sql = string.format([[
        INSERT OR REPLACE INTO motores 
        (id, nome, registroModBus, registroLocal, correnteAtual, correnteNominal, 
         percentCorrenteMaximaErro, percentHistereseErro, status, horimetro, ultimaAtualizacao)
        VALUES (%d, %s, %d, %d, %.2f, %.2f, %.2f, %.2f, %d, %.2f, CURRENT_TIMESTAMP)
    ]],
        motor.ID,
        self:escapeString(motor.Nome),
        motor.RegistroModBus,
        motor.RegistroLocal,
        motor.CorrenteAtual,
        motor.CorrenteNominal,
        motor.PercentCorrenteMaximaErro,
        motor.PercentHistereseErro,
        motor.Status and 1 or 0,
        motor.Horimetro
    )
    
    local success = self.DB:execute(sql)
    
    if success then
        return true
    else
        return false, "Erro ao salvar motor"
    end
end

-- Função para buscar motor por ID
function SQLiteDB:BuscarMotor(id)
    if not self.Connected then
        return nil, "Banco de dados não está conectado"
    end
    
    local sql = "SELECT * FROM motores WHERE id = " .. tostring(id)
    local cursor = self.DB:execute(sql)
    
    if not cursor then
        return nil, "Erro ao executar query"
    end
    
    -- Usando cursor:fetch() conforme API do PIStudio
    local row = cursor:fetch()
    
    if row then
        -- Assumindo que fetch retorna uma tabela com os valores
        -- A ordem das colunas: id, nome, registroModBus, registroLocal, correnteAtual, 
        -- correnteNominal, percentCorrenteMaximaErro, percentHistereseErro, status, horimetro
        local motor = Motor:new(
            row[1] or row.id, -- id
            row[2] or row.nome, -- nome
            row[3] or row.registroModBus, -- registroModBus
            row[4] or row.registroLocal, -- registroLocal
            row[6] or row.correnteNominal or 0.0  -- correnteNominal
        )
        
        motor:setCorrenteAtual(row[5] or row.correnteAtual or 0.0)
        motor:setPercentCorrenteMaximaErro(row[7] or row.percentCorrenteMaximaErro or 0.0)
        motor:setPercentHistereseErro(row[8] or row.percentHistereseErro or 0.0)
        motor:setStatus((row[9] or row.status or 0) == 1)
        motor.Horimetro = row[10] or row.horimetro or 0.0
        
        cursor:close()
        return motor
    else
        cursor:close()
        return nil, "Motor não encontrado"
    end
end

-- Função para buscar todos os motores
function SQLiteDB:BuscarTodosMotores()
    if not self.Connected then
        return {}, "Banco de dados não está conectado"
    end
    
    local sql = "SELECT * FROM motores"
    local cursor = self.DB:execute(sql)
    local motores = {}
    
    if cursor then
        local row = cursor:fetch()
        while row do
            local motor = Motor:new(
                row[1] or row.id,
                row[2] or row.nome,
                row[3] or row.registroModBus,
                row[4] or row.registroLocal,
                row[6] or row.correnteNominal or 0.0
            )
            
            motor:setCorrenteAtual(row[5] or row.correnteAtual or 0.0)
            motor:setPercentCorrenteMaximaErro(row[7] or row.percentCorrenteMaximaErro or 0.0)
            motor:setPercentHistereseErro(row[8] or row.percentHistereseErro or 0.0)
            motor:setStatus((row[9] or row.status or 0) == 1)
            motor.Horimetro = row[10] or row.horimetro or 0.0
            
            table.insert(motores, motor)
            row = cursor:fetch()
        end
        cursor:close()
    end
    
    return motores
end

-- Função para registrar histórico de corrente
function SQLiteDB:RegistrarHistoricoCorrente(motorId, corrente)
    if not self.Connected then
        return false, "Banco de dados não está conectado"
    end
    
    local sql = string.format(
        "INSERT INTO historico_correntes (motor_id, corrente) VALUES (%d, %.2f)",
        motorId,
        corrente
    )
    
    local success = self.DB:execute(sql)
    
    if success then
        return true
    else
        return false, "Erro ao registrar histórico"
    end
end

-- Função para registrar evento
function SQLiteDB:RegistrarEvento(motorId, tipo, descricao)
    if not self.Connected then
        return false, "Banco de dados não está conectado"
    end
    
    local sql = string.format(
        "INSERT INTO eventos (motor_id, tipo, descricao) VALUES (%s, %s, %s)",
        motorId and tostring(motorId) or "NULL",
        self:escapeString(tipo),
        self:escapeString(descricao)
    )
    
    local success = self.DB:execute(sql)
    
    if success then
        return true
    else
        return false, "Erro ao registrar evento"
    end
end

-- Função para fechar conexão
function SQLiteDB:Fechar()
    if self.DB then
        self.DB:close()
        self.DB = nil
        self.Connected = false
        print("Conexão com banco de dados fechada")
    end
end

return SQLiteDB
