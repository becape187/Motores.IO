-- ss LteDBpar iteragir com SQLite (API nativa do PIStudio)
-- Conforme documetação: https://docs.we-con.com.cn/bin/view/PIStudio/09%20Lua%20Editor/Lua%20Script/#HLuaSqlitemodule
SQLiteDB = {}
SQLiteDB.__index = SQLiteDB

-- Construtor
function SQLiteDB:new(dbPath)
    local obj = {}
    setmetatable(obj, SQLiteDB)
    
    -- Usar "udisk:" prefix para arquivos no disco USB ou caminho relativo
    -- "sdcard" é o padrão caso não venha na inicialização do Script no BG.
    -- Se vier o path via construtor, (leia-se inicialização) a classe utiliza
    -- do construtor.
    obj.DBPath = dbPath or "sdcard:motores.db"
    obj.Env = nil  -- Ambiente luasql_sqlite3
    obj.DB = nil   -- Conexão do banco
    obj.Connected = false
    
    return obj
end

-- Função para conectar ao banco de dados
-- Conforme documentação: 
-- env = luasql_sqlite3.sqlite3()  -- Inicializar ambiente
-- db = env:connect("udisk:test.db")  -- Conectar ao arquivo
function SQLiteDB:Conectar()
    -- Verificar se luasql_sqlite3 está disponível
    if not luasql_sqlite3 then
        local err = "luasql_sqlite3 não está disponível. Verifique se o módulo está habilitado no PIStudio."
        print("[SQLite] ✗ " .. err)
        return false, err
    end
    
    -- Inicializar ambiente antes de obter o objeto db
    self.Env = luasql_sqlite3.sqlite3()
    if not self.Env then
        local err = "Não foi possível inicializar ambiente luasql_sqlite3"
        print("[SQLite] ✗ " .. err)
        return false, err
    end
    
    -- Conectar ao arquivo de banco de dados
    -- Usar "udisk:" para disco USB ou caminho relativo
    self.DB = self.Env:connect(self.DBPath)
    
    if not self.DB then
        self.Connected = false
        local err = "Não foi possível conectar ao banco de dados: " .. self.DBPath
        print("[SQLite] ✗ " .. err)
        return false, err
    end
    
    self.Connected = true
    print("[SQLite] ✓ Conectado ao banco de dados: " .. self.DBPath)
    
    -- Criar tabelas após conexão bem-sucedida
    self:CriarTabelas()
    
    return true
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
        print("[SQLite] ⚠ Banco não conectado, não é possível criar tabelas")
        return false
    end
    
    print("[SQLite] Criando/verificando tabelas...")
    
    -- Tabela de motores
    -- IMPORTANTE: id deve ser AUTOINCREMENT para permitir inserção sem especificar ID
    local sql_motores = [[
        CREATE TABLE IF NOT EXISTS motores (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            guid TEXT UNIQUE,
            nome TEXT NOT NULL,
            potencia REAL DEFAULT 0.0,
            tensao REAL DEFAULT 0.0,
            correnteAtual REAL DEFAULT 0.0,
            correnteNominal REAL DEFAULT 0.0,
            percentualCorrenteMaxima REAL DEFAULT 0.0,
            histerese REAL DEFAULT 0.0,
            registroModBus TEXT,
            registroLocal TEXT,
            status TEXT DEFAULT 'desligado',
            horimetro REAL DEFAULT 0.0,
            habilitado INTEGER DEFAULT 1,
            posicaoX REAL DEFAULT 0.0,
            posicaoY REAL DEFAULT 0.0,
            horimetroProximaManutencao REAL,
            dataEstimadaProximaManutencao TEXT,
            dataCriacao TEXT,
            ultimaAtualizacao TEXT DEFAULT CURRENT_TIMESTAMP,
            dataAtualizacao TEXT
        )
    ]]
    
    -- Criar índice para GUID se não existir
    local sql_index = [[
        CREATE INDEX IF NOT EXISTS idx_motores_guid ON motores(guid)
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
    
    -- Tabela de dados (médias, máximos e mínimos a cada minuto)
    local sql_dados = [[
        CREATE TABLE IF NOT EXISTS dados (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            motor_id INTEGER,
            motor_guid TEXT,
            media REAL NOT NULL,
            corrente_maxima REAL,
            corrente_minima REAL,
            timestamp TEXT DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (motor_id) REFERENCES motores(id)
        )
    ]]
    
    -- Usando db:execute() conforme API do PIStudio
    -- Para CREATE TABLE, execute() não retorna cursor, apenas executa
    -- Conforme documentação: db:execute() para comandos DDL/DML
    -- execute() retorna true/nil ou número de linhas afetadas
    local result1 = self.DB:execute(sql_motores)
    local result2 = self.DB:execute(sql_historico)
    local result3 = self.DB:execute(sql_eventos)
    local result4 = self.DB:execute(sql_index)
    local result5 = self.DB:execute(sql_dados)
    
    -- Verificar se todas as execuções foram bem-sucedidas
    -- No luasql_sqlite3, execute() retorna true/nil ou número de linhas
    if not result1 or not result2 or not result3 or not result4 or not result5 then
        print("[SQLite] ✗ Erro ao criar tabelas")
        print("[SQLite]   SQL motores: " .. (result1 and "OK" or "FALHOU"))
        print("[SQLite]   SQL histórico: " .. (result2 and "OK" or "FALHOU"))
        print("[SQLite]   SQL eventos: " .. (result3 and "OK" or "FALHOU"))
        print("[SQLite]   SQL índice: " .. (result4 and "OK" or "FALHOU"))
        print("[SQLite]   SQL dados: " .. (result5 and "OK" or "FALHOU"))
        return false
    end
    
    print("[SQLite] ✓ Tabelas criadas/verificadas com sucesso")
    
    -- Verificar se a tabela dados foi criada corretamente
    local checkCursor = self.DB:execute("SELECT name FROM sqlite_master WHERE type='table' AND name='dados'")
    if checkCursor then
        local row = checkCursor:fetch()
        if row then
            print("[SQLite] ✓ Tabela 'dados' confirmada no banco")
        else
            print("[SQLite] ⚠ AVISO: Tabela 'dados' não encontrada após criação!")
            print("[SQLite] Tentando criar novamente...")
            -- Tentar criar novamente
            local retryResult = self.DB:execute(sql_dados)
            if retryResult then
                print("[SQLite] ✓ Tabela 'dados' criada na segunda tentativa")
            else
                print("[SQLite] ✗ Erro ao criar tabela 'dados' na segunda tentativa")
            end
        end
        if checkCursor.close then
            checkCursor:close()
        end
    end
    
    -- Listar todas as tabelas e número de linhas
    self:ListarTabelasEQuantidade()
    
    return true
end

-- Função para listar todas as tabelas e quantidade de linhas
function SQLiteDB:ListarTabelasEQuantidade()
    if not self.Connected then
        print("[SQLite] ⚠ Banco não conectado, não é possível listar tabelas")
        return
    end
    
    print("[SQLite] === LISTAGEM DE TABELAS DO BANCO ===")
    
    -- Buscar todas as tabelas (excluindo tabelas do sistema SQLite)
    local sql = "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name"
    local cursor = self.DB:execute(sql)
    
    if not cursor then
        print("[SQLite] ✗ Erro ao buscar lista de tabelas")
        return
    end
    
    local tabelas = {}
    local row = cursor:fetch()
    
    -- Coletar nomes das tabelas
    while row do
        local nomeTabela
        if type(row) == "table" then
            nomeTabela = row[1] or row.name
        elseif type(row) == "string" then
            nomeTabela = row
        end
        
        if nomeTabela then
            table.insert(tabelas, nomeTabela)
        end
        
        row = cursor:fetch()
    end
    
    if cursor.close then
        cursor:close()
    end
    
    -- Para cada tabela, contar o número de linhas
    for _, nomeTabela in ipairs(tabelas) do
        local countSql = string.format("SELECT COUNT(*) FROM %s", nomeTabela)
        local countCursor = self.DB:execute(countSql)
        
        if countCursor then
            local countRow = countCursor:fetch()
            local count = 0
            
            if countRow then
                if type(countRow) == "table" then
                    count = countRow[1] or countRow["COUNT(*)"] or 0
                elseif type(countRow) == "number" then
                    count = countRow
                end
            end
            
            print(string.format("[SQLite]   Tabela: %s | Linhas: %d", nomeTabela, count))
            
            if countCursor.close then
                countCursor:close()
            end
        else
            print(string.format("[SQLite]   Tabela: %s | Erro ao contar linhas", nomeTabela))
        end
    end
    
    print("[SQLite] === FIM DA LISTAGEM ===")
end

-- Função para verificar se a tabela dados existe
function SQLiteDB:VerificarTabelaDados()
    if not self.Connected then
        return false, "Banco de dados não está conectado"
    end
    
    local sql = "SELECT name FROM sqlite_master WHERE type='table' AND name='dados'"
    local cursor = self.DB:execute(sql)
    
    if not cursor then
        return false, "Erro ao verificar tabela"
    end
    
    local row = cursor:fetch()
    local exists = row ~= nil
    
    if cursor.close then
        cursor:close()
    end
    
    return exists
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
        print("[SQLite] ✗ Banco de dados não está conectado")
        return {}, "Banco de dados não está conectado"
    end
    
    print("[SQLite] Buscando todos os motores do banco local...")
    local sql = "SELECT id, guid, nome, registroModBus, registroLocal, correnteAtual, correnteNominal, percentCorrenteMaximaErro, percentHistereseErro, status, horimetro, ultimaAtualizacao, dataAtualizacao FROM motores"
    
    -- Conforme documentação: db:execute() para SELECT retorna um cursor
    local cursor = self.DB:execute(sql)
    local motores = {}
    
    if not cursor then
        print("[SQLite] ✗ Erro ao executar query")
        print("[SQLite]   SQL: " .. sql)
        return {}, "Erro ao executar query"
    end
    
    local row = cursor:fetch()
    local count = 0
    while row do
        count = count + 1
        -- Ordem das colunas: id(1), guid(2), nome(3), potencia(4), tensao(5), registroModBus(6), registroLocal(7),
        -- correnteAtual(8), correnteNominal(9), percentualCorrenteMaxima(10), histerese(11), status(12), 
        -- horimetro(13), habilitado(14), posicaoX(15), posicaoY(16), horimetroProximaManutencao(17),
        -- dataEstimadaProximaManutencao(18), dataCriacao(19), ultimaAtualizacao(20), dataAtualizacao(21)
        local motor = Motor:new(
            row[1] or row.id, -- id
            row[3] or row.nome, -- nome (coluna 3)
            row[6] or row.registroModBus, -- registroModBus (coluna 6)
            row[7] or row.registroLocal, -- registroLocal (coluna 7)
            row[9] or row.correnteNominal or 0.0  -- correnteNominal (coluna 9)
        )
        
        motor.ID = row[1] or row.id
        motor.GUID = row[2] or row.guid -- GUID está na coluna 2
        motor.Potencia = row[4] or row.potencia or 0.0
        motor.Tensao = row[5] or row.tensao or 0.0
        motor:setCorrenteAtual(row[8] or row.correnteAtual or 0.0)
        motor.PercentualCorrenteMaxima = row[10] or row.percentualCorrenteMaxima or 0.0
        motor.Histerese = row[11] or row.histerese or 0.0
        -- Status pode ser string ("ligado"/"desligado") ou número (0/1)
        local statusValue = row[12] or row.status
        if type(statusValue) == "string" then
            motor.Status = statusValue == "ligado"
        else
            motor.Status = (statusValue == 1 or statusValue == true)
        end
        motor.Horimetro = row[13] or row.horimetro or 0.0
        motor.Habilitado = (row[14] or row.habilitado or 1) == 1
        motor.PosicaoX = row[15] or row.posicaoX or 0.0
        motor.PosicaoY = row[16] or row.posicaoY or 0.0
        motor.HorimetroProximaManutencao = row[17] or row.horimetroProximaManutencao
        motor.DataEstimadaProximaManutencao = row[18] or row.dataEstimadaProximaManutencao
        motor.DataCriacao = row[19] or row.dataCriacao
        
        table.insert(motores, motor)
        row = cursor:fetch()
    end
    
    if cursor.close then
        cursor:close()
    end
    
    print("[SQLite] ✓ " .. count .. " motores encontrados no banco local")
    return motores
end

-- Função para inserir ou atualizar motor (com suporte a GUID e timestamp)
function SQLiteDB:InserirOuAtualizarMotor(motor, timestampUnix)
    if not self.Connected then
        print("[SQLite] ✗ Banco de dados não está conectado")
        return false, "Banco de dados não está conectado"
    end
    
    if not motor.GUID then
        print("[SQLite] ✗ Motor sem GUID, não é possível salvar")
        return false, "Motor sem GUID"
    end
    
    local guidValue = self:escapeString(motor.GUID)
    
    -- Converter timestamp Unix para string ISO se fornecido
    local dataAtualizacaoValue = "NULL"
    if timestampUnix and timestampUnix > 0 then
        -- Converter timestamp Unix para formato ISO (YYYY-MM-DDTHH:MM:SSZ)
        local dataISO = os.date("!%Y-%m-%dT%H:%M:%SZ", timestampUnix)
        dataAtualizacaoValue = self:escapeString(dataISO)
    end
    
    -- Verificar se motor já existe pelo GUID
    -- Conforme documentação: db:execute() para SELECT retorna um cursor
    local checkSql = string.format("SELECT id FROM motores WHERE guid = %s", guidValue)
    local checkCursor = self.DB:execute(checkSql)
    local existingId = nil
    
    if checkCursor then
        local row = checkCursor:fetch()
        if row then
            -- Quando SELECT retorna apenas uma coluna, fetch pode retornar o valor diretamente
            -- ou uma tabela. Verificar o tipo e tratar adequadamente.
            if type(row) == "table" then
                existingId = row[1] or row.id
            elseif type(row) == "number" then
                -- Se retornou diretamente o número (id), usar esse valor
                existingId = row
            else
                print("[SQLite] ⚠ AVISO: cursor:fetch() retornou tipo inesperado: " .. type(row))
            end
        end
        -- Fechar cursor conforme documentação
        if checkCursor.close then
            checkCursor:close()
        end
    else
        -- Se não retornou cursor, pode ser que não houve erro, apenas não encontrou registro
        -- Isso é normal, não é um erro
    end
    
    -- Preparar valores para campos opcionais
    local potenciaValue = motor.Potencia or 0.0
    local tensaoValue = motor.Tensao or 0.0
    local registroModBusValue = self:escapeString(tostring(motor.RegistroModBus or ""))
    local registroLocalValue = self:escapeString(tostring(motor.RegistroLocal or ""))
    local percentualCorrenteMaximaValue = motor.PercentualCorrenteMaxima or 0.0
    local histereseValue = motor.Histerese or 0.0
    local statusValue = motor.Status
    if type(statusValue) == "string" then
        statusValue = statusValue == "ligado"
    end
    local statusStr = statusValue and "ligado" or "desligado"
    local habilitadoValue = motor.Habilitado and 1 or 0
    local posicaoXValue = motor.PosicaoX or 0.0
    local posicaoYValue = motor.PosicaoY or 0.0
    local horimetroProximaManutencaoValue = "NULL"
    if motor.HorimetroProximaManutencao ~= nil then
        horimetroProximaManutencaoValue = tostring(motor.HorimetroProximaManutencao)
    end
    local dataEstimadaProximaManutencaoValue = "NULL"
    if motor.DataEstimadaProximaManutencao then
        dataEstimadaProximaManutencaoValue = self:escapeString(motor.DataEstimadaProximaManutencao)
    end
    local dataCriacaoValue = "NULL"
    if motor.DataCriacao then
        dataCriacaoValue = self:escapeString(motor.DataCriacao)
    end
    
    local sql
    if existingId then
        -- UPDATE: motor já existe, atualizar
        sql = string.format([[
            UPDATE motores SET
                nome = %s,
                potencia = %.2f,
                tensao = %.2f,
                registroModBus = %s,
                registroLocal = %s,
                correnteAtual = %.2f,
                correnteNominal = %.2f,
                percentualCorrenteMaxima = %.2f,
                histerese = %.2f,
                status = %s,
                horimetro = %.2f,
                habilitado = %d,
                posicaoX = %.2f,
                posicaoY = %.2f,
                horimetroProximaManutencao = %s,
                dataEstimadaProximaManutencao = %s,
                dataCriacao = %s,
                ultimaAtualizacao = CURRENT_TIMESTAMP,
                dataAtualizacao = %s
            WHERE guid = %s
        ]],
            self:escapeString(motor.Nome),
            potenciaValue,
            tensaoValue,
            registroModBusValue,
            registroLocalValue,
            motor.CorrenteAtual or 0.0,
            motor.CorrenteNominal or 0.0,
            percentualCorrenteMaximaValue,
            histereseValue,
            self:escapeString(statusStr),
            motor.Horimetro or 0.0,
            habilitadoValue,
            posicaoXValue,
            posicaoYValue,
            horimetroProximaManutencaoValue,
            dataEstimadaProximaManutencaoValue,
            dataCriacaoValue,
            dataAtualizacaoValue,
            guidValue
        )
        print("[SQLite] Atualizando motor: " .. motor.Nome .. " (GUID: " .. motor.GUID .. ")")
    else
        -- INSERT: motor não existe, criar novo
        sql = string.format([[
            INSERT INTO motores 
            (guid, nome, potencia, tensao, registroModBus, registroLocal, correnteAtual, correnteNominal, 
             percentualCorrenteMaxima, histerese, status, horimetro, habilitado, posicaoX, posicaoY, 
             horimetroProximaManutencao, dataEstimadaProximaManutencao, dataCriacao, ultimaAtualizacao, dataAtualizacao)
            VALUES (
                %s, %s, %.2f, %.2f, %s, %s, %.2f, %.2f, %.2f, %.2f, %s, %.2f, %d, %.2f, %.2f, 
                %s, %s, %s, CURRENT_TIMESTAMP, %s
            )
        ]],
            guidValue,
            self:escapeString(motor.Nome),
            potenciaValue,
            tensaoValue,
            registroModBusValue,
            registroLocalValue,
            motor.CorrenteAtual or 0.0,
            motor.CorrenteNominal or 0.0,
            percentualCorrenteMaximaValue,
            histereseValue,
            self:escapeString(statusStr),
            motor.Horimetro or 0.0,
            habilitadoValue,
            posicaoXValue,
            posicaoYValue,
            horimetroProximaManutencaoValue,
            dataEstimadaProximaManutencaoValue,
            dataCriacaoValue,
            dataAtualizacaoValue
        )
        print("[SQLite] Criando novo motor: " .. motor.Nome .. " (GUID: " .. motor.GUID .. ")")
    end
    
    -- Conforme documentação: db:execute() para INSERT/UPDATE não retorna cursor
    -- Retorna true/nil ou número de linhas afetadas
    local result = self.DB:execute(sql)
    
    -- Verificar se a execução foi bem-sucedida
    if not result then
        print("[SQLite] ✗ Erro ao salvar motor")
        print("[SQLite]   Motor: " .. motor.Nome .. " (GUID: " .. motor.GUID .. ")")
        print("[SQLite]   SQL: " .. string.sub(sql, 1, 200) .. "...")
        return false, "Falha ao executar SQL"
    end
    
    -- Log simplificado (dados completos removidos para evitar poluição)
    print("[SQLite] ✓ Motor salvo: " .. motor.Nome .. " (GUID: " .. motor.GUID .. ")")
    return true
end

-- Função para buscar última atualização de um motor por GUID
function SQLiteDB:BuscarUltimaAtualizacaoMotor(guid)
    if not self.Connected then
        print("[SQLite] ✗ Banco de dados não está conectado")
        return nil
    end
    
    if not guid then
        return nil
    end
    
    local sql = string.format("SELECT dataAtualizacao FROM motores WHERE guid = %s", 
        self:escapeString(guid))
    
    -- Conforme documentação: db:execute() para SELECT retorna um cursor
    local cursor = self.DB:execute(sql)
    
    if not cursor then
        -- Se não retornou cursor, pode ser que não encontrou registro ou houve erro
        -- Retornar nil é o comportamento esperado quando não encontra
        return nil
    end
    
    local row = cursor:fetch()
    local dataAtualizacao = nil
    
    if row then
        -- Quando SELECT retorna apenas uma coluna, fetch pode retornar o valor diretamente
        -- ou uma tabela. Verificar o tipo e tratar adequadamente.
        if type(row) == "table" then
            dataAtualizacao = row[1] or row.dataAtualizacao
        elseif type(row) == "string" then
            -- Se retornou diretamente a string (dataAtualizacao), usar esse valor
            dataAtualizacao = row
        else
            print("[SQLite] ⚠ AVISO: cursor:fetch() retornou tipo inesperado: " .. type(row))
        end
    end
    
    -- Fechar cursor conforme documentação
    if cursor.close then
        cursor:close()
    end
    
    return dataAtualizacao
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

-- Função para registrar dados de corrente (média, máximo e mínimo a cada minuto)
function SQLiteDB:RegistrarDadosCorrente(motorId, motorGuid, media, correnteMaxima, correnteMinima)
    if not self.Connected then
        return false, "Banco de dados não está conectado"
    end
    
    -- Preparar valores (pode ser NULL se não houver máximo/mínimo)
    local correnteMaximaValue = "NULL"
    if correnteMaxima ~= nil then
        correnteMaximaValue = string.format("%.2f", correnteMaxima)
    end
    
    local correnteMinimaValue = "NULL"
    if correnteMinima ~= nil then
        correnteMinimaValue = string.format("%.2f", correnteMinima)
    end
    
    local motorGuidValue = "NULL"
    if motorGuid then
        motorGuidValue = self:escapeString(motorGuid)
    end
    
    local sql = string.format(
        "INSERT INTO dados (motor_id, motor_guid, media, corrente_maxima, corrente_minima) VALUES (%s, %s, %.2f, %s, %s)",
        motorId and tostring(motorId) or "NULL",
        motorGuidValue,
        media or 0.0,
        correnteMaximaValue,
        correnteMinimaValue
    )
    
    local success = self.DB:execute(sql)
    
    if success then
        print("[SQLite] ✓ Dados de corrente registrados para motor ID: " .. tostring(motorId))
        return true
    else
        print("[SQLite] ✗ Erro ao registrar dados de corrente")
        return false, "Erro ao registrar dados de corrente"
    end
end

-- Função para fechar conexão
function SQLiteDB:Fechar()
    if self.DB then
        self.DB:close()
        self.DB = nil
    end
    
    if self.Env then
        self.Env:close()
        self.Env = nil
    end
    
    self.Connected = false
    print("[SQLite] Conexão com banco de dados fechada")
end

return SQLiteDB
