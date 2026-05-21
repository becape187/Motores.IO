-- =====================================================================
-- SQLiteDB.lua  (VERSÃO EM RAM / SEM PERSISTÊNCIA)
-- ---------------------------------------------------------------------
-- Drop-in que substitui o SQLiteDB baseado em luasql_sqlite3.
-- NÃO usa SD/USB/flash, NÃO usa luasql_sqlite3, NÃO persiste em disco.
-- Toda a "infra" do banco vira tabela Lua na memória da IHM.
--
-- Por que isso é seguro aqui:
--   - O registro de motores tem o SERVIDOR como fonte da verdade
--     (MotorSync re-sincroniza da API a cada boot).
--   - O histórico já é enviado pra nuvem via socket; a cópia local
--     é só buffer temporário.
--
-- Proteção de memória:
--   - LIMITE_* = teto rígido de linhas por tabela (ring buffer:
--     ao estourar, descarta as MAIS ANTIGAS).
--   - LimparHistoricoEnviado() / LimparTabela() = purga explícita,
--     pra você chamar APÓS envio bem-sucedido pra nuvem.
--
-- Mantém o MESMO nome de módulo e a MESMA interface pública do
-- SQLiteDB original -> nenhum outro arquivo precisa mudar.
-- =====================================================================

SQLiteDB = {}
SQLiteDB.__index = SQLiteDB

-- =========================
-- Limites de proteção (ajustáveis na IHM)
-- =========================
SQLiteDB.LIMITE_HISTORICO = 500   -- máx. linhas em historico_correntes
SQLiteDB.LIMITE_DADOS     = 500   -- máx. linhas em dados (média/min/máx por minuto)
SQLiteDB.LIMITE_EVENTOS   = 300   -- máx. linhas em eventos

-- =========================
-- Construtor
-- =========================
function SQLiteDB:new(dbPath)
    local obj = {}
    setmetatable(obj, SQLiteDB)

    obj.DBPath    = dbPath or "RAM:motores"  -- só informativo (ObterCaminhoBanco)
    obj.Connected = false

    -- "Tabelas" em memória
    obj.motores            = {}   -- array de objetos Motor
    obj._motorPorGuid      = {}   -- guid -> índice em obj.motores
    obj._dataAtualizacao   = {}   -- guid -> string ISO
    obj.historico_correntes = {}
    obj.eventos             = {}
    obj.dados               = {}

    -- contadores de id (autoincrement em memória)
    obj._seq = { historico_correntes = 0, eventos = 0, dados = 0 }

    return obj
end

-- =========================
-- Conexão (no-op: não há disco)
-- =========================
function SQLiteDB:Conectar()
    self.Connected = true
    print("[SQLite-RAM] ✓ Banco em MEMÓRIA inicializado (sem persistência, sem SD)")
    self:CriarTabelas()
    return true
end

function SQLiteDB:CriarTabelas()
    -- Estruturas já criadas no construtor; aqui só garante e loga.
    self.motores             = self.motores or {}
    self.historico_correntes = self.historico_correntes or {}
    self.eventos             = self.eventos or {}
    self.dados               = self.dados or {}
    print("[SQLite-RAM] ✓ Tabelas em memória prontas (motores, historico_correntes, eventos, dados)")
    return true
end

-- Mantido por compatibilidade (não há SQL, mas algum código pode chamar)
function SQLiteDB:escapeString(str)
    if not str then return "NULL" end
    str = tostring(str)
    str = string.gsub(str, "'", "''")
    return "'" .. str .. "'"
end

-- =========================
-- Helper: append com teto (ring buffer)
-- =========================
local function appendLimitado(tabela, linha, limite)
    table.insert(tabela, linha)
    -- descarta as mais antigas até respeitar o teto
    while #tabela > limite do
        table.remove(tabela, 1)
    end
end

-- =========================
-- Motores
-- =========================

-- Legado: upsert por ID
function SQLiteDB:SalvarMotor(motor)
    if not self.Connected then return false, "Banco não conectado" end
    if not motor then return false, "Motor nulo" end

    -- procura por ID
    for i, m in ipairs(self.motores) do
        if m.ID == motor.ID then
            self.motores[i] = motor
            if motor.GUID then self._motorPorGuid[motor.GUID] = i end
            return true
        end
    end

    table.insert(self.motores, motor)
    if motor.GUID then
        self._motorPorGuid[motor.GUID] = #self.motores
    end
    return true
end

function SQLiteDB:BuscarMotor(id)
    if not self.Connected then return nil, "Banco não conectado" end
    for _, m in ipairs(self.motores) do
        if m.ID == id then
            return m
        end
    end
    return nil, "Motor não encontrado"
end

function SQLiteDB:BuscarTodosMotores()
    if not self.Connected then
        print("[SQLite-RAM] ✗ Banco não conectado")
        return {}, "Banco não conectado"
    end
    -- Cópia rasa do array (mesma referência dos objetos Motor)
    local lista = {}
    for _, m in ipairs(self.motores) do
        table.insert(lista, m)
    end
    print("[SQLite-RAM] ✓ " .. #lista .. " motores em memória")
    return lista
end

-- Upsert por GUID (usado pelo MotorSync)
function SQLiteDB:InserirOuAtualizarMotor(motor, timestampUnix)
    if not self.Connected then
        print("[SQLite-RAM] ✗ Banco não conectado")
        return false, "Banco não conectado"
    end
    if not motor or not motor.GUID then
        print("[SQLite-RAM] ✗ Motor sem GUID")
        return false, "Motor sem GUID"
    end

    -- string ISO de dataAtualizacao (mesmo formato do original)
    if timestampUnix and timestampUnix > 0 then
        self._dataAtualizacao[motor.GUID] = os.date("!%Y-%m-%dT%H:%M:%SZ", timestampUnix)
    end

    local idx = self._motorPorGuid[motor.GUID]
    if idx and self.motores[idx] then
        self.motores[idx] = motor
        print("[SQLite-RAM] Motor atualizado: " .. tostring(motor.Nome) .. " (GUID: " .. motor.GUID .. ")")
    else
        table.insert(self.motores, motor)
        self._motorPorGuid[motor.GUID] = #self.motores
        print("[SQLite-RAM] Motor criado: " .. tostring(motor.Nome) .. " (GUID: " .. motor.GUID .. ")")
    end
    return true
end

function SQLiteDB:BuscarUltimaAtualizacaoMotor(guid)
    if not self.Connected or not guid then return nil end
    return self._dataAtualizacao[guid]
end

-- =========================
-- Histórico / Eventos / Dados (buffers limitados)
-- =========================
function SQLiteDB:RegistrarHistoricoCorrente(motorId, corrente)
    if not self.Connected then return false, "Banco não conectado" end
    self._seq.historico_correntes = self._seq.historico_correntes + 1
    appendLimitado(self.historico_correntes, {
        id        = self._seq.historico_correntes,
        motor_id  = motorId,
        corrente  = corrente,
        timestamp = os.date("!%Y-%m-%d %H:%M:%S")
    }, self.LIMITE_HISTORICO)
    return true
end

function SQLiteDB:RegistrarEvento(motorId, tipo, descricao)
    if not self.Connected then return false, "Banco não conectado" end
    self._seq.eventos = self._seq.eventos + 1
    appendLimitado(self.eventos, {
        id        = self._seq.eventos,
        motor_id  = motorId,
        tipo      = tipo,
        descricao = descricao,
        timestamp = os.date("!%Y-%m-%d %H:%M:%S")
    }, self.LIMITE_EVENTOS)
    return true
end

function SQLiteDB:RegistrarDadosCorrente(motorId, motorGuid, media, correnteMaxima, correnteMinima)
    if not self.Connected then return false, "Banco não conectado" end
    self._seq.dados = self._seq.dados + 1
    appendLimitado(self.dados, {
        id              = self._seq.dados,
        motor_id        = motorId,
        motor_guid      = motorGuid,
        media           = (type(media) == "number") and media or 0.0,
        corrente_maxima = correnteMaxima,
        corrente_minima = correnteMinima,
        timestamp       = os.date("!%Y-%m-%d %H:%M:%S")
    }, self.LIMITE_DADOS)
    print("[SQLite-RAM] ✓ Dados registrados (motor ID: " .. tostring(motorId or "N/A")
          .. ", buffer dados=" .. #self.dados .. "/" .. self.LIMITE_DADOS .. ")")
    return true
end

-- =========================
-- Purga explícita — chamar APÓS envio bem-sucedido pra nuvem
-- =========================
-- Limpa os buffers de telemetria (histórico + dados). NÃO mexe em motores.
function SQLiteDB:LimparHistoricoEnviado()
    local h, d = #self.historico_correntes, #self.dados
    self.historico_correntes = {}
    self.dados = {}
    print("[SQLite-RAM] ✓ Histórico purgado após envio (historico=" .. h .. ", dados=" .. d .. " removidos)")
    return true
end

-- Limpa uma tabela específica por nome
function SQLiteDB:LimparTabela(nome)
    if nome == "motores" then
        self.motores = {}; self._motorPorGuid = {}; self._dataAtualizacao = {}
    elseif self[nome] ~= nil and type(self[nome]) == "table" then
        self[nome] = {}
    else
        return false, "Tabela desconhecida: " .. tostring(nome)
    end
    print("[SQLite-RAM] ✓ Tabela '" .. tostring(nome) .. "' limpa")
    return true
end

-- =========================
-- Introspecção (DatabaseHandler / browser remoto)
-- =========================
function SQLiteDB:ObterCaminhoBanco()
    return "RAM (memória volátil — sem persistência)"
end

function SQLiteDB:ListarTabelasComQuantidade()
    return {
        { nome = "motores",             linhas = #self.motores },
        { nome = "historico_correntes", linhas = #self.historico_correntes },
        { nome = "eventos",             linhas = #self.eventos },
        { nome = "dados",               linhas = #self.dados },
    }
end

-- Projeção de cada tabela para consulta paginada
local COLUNAS = {
    motores             = { "ID", "GUID", "Nome", "CorrenteAtual", "CorrenteNominal", "Status", "Horimetro" },
    historico_correntes = { "id", "motor_id", "corrente", "timestamp" },
    eventos             = { "id", "motor_id", "tipo", "descricao", "timestamp" },
    dados               = { "id", "motor_id", "motor_guid", "media", "corrente_maxima", "corrente_minima", "timestamp" },
}

function SQLiteDB:ConsultarTabela(nomeTabela, pagina, tamanhoPagina)
    if not self.Connected then return nil, "Banco não conectado" end
    if not nomeTabela or self[nomeTabela] == nil then
        return nil, "Tabela não encontrada: " .. tostring(nomeTabela)
    end

    pagina = pagina or 1
    tamanhoPagina = tamanhoPagina or 50
    if pagina < 1 then pagina = 1 end
    if tamanhoPagina < 1 then tamanhoPagina = 50 end

    local origem = self[nomeTabela]
    local total  = #origem
    local offset = (pagina - 1) * tamanhoPagina
    local colunas = COLUNAS[nomeTabela] or {}

    local dados = {}
    for i = offset + 1, math.min(offset + tamanhoPagina, total) do
        local item = origem[i]
        local linha = {}
        if nomeTabela == "motores" then
            -- item é objeto Motor: projeta os campos
            linha = {
                ID = item.ID, GUID = item.GUID, Nome = item.Nome,
                CorrenteAtual = item.CorrenteAtual, CorrenteNominal = item.CorrenteNominal,
                Status = (item.Status and "ligado" or "desligado"),
                Horimetro = item.Horimetro
            }
        else
            linha = item
        end
        table.insert(dados, linha)
    end

    return {
        dados         = dados,
        colunas       = colunas,
        totalLinhas   = total,
        pagina        = pagina,
        tamanhoPagina = tamanhoPagina
    }
end

-- Compat: alguns códigos antigos chamam estes
function SQLiteDB:ListarTabelasEQuantidade()
    for _, t in ipairs(self:ListarTabelasComQuantidade()) do
        print(string.format("[SQLite-RAM]   Tabela: %s | Linhas: %d", t.nome, t.linhas))
    end
end

function SQLiteDB:VerificarTabelaDados()
    return self.dados ~= nil
end

-- =========================
-- Fechar
-- =========================
function SQLiteDB:Fechar()
    self.Connected = false
    -- Mantém os dados em RAM por padrão (próximo Conectar reaproveita).
    -- Se quiser zerar tudo ao fechar, descomente:
    -- self.motores = {}; self._motorPorGuid = {}; self._dataAtualizacao = {}
    -- self.historico_correntes = {}; self.eventos = {}; self.dados = {}
    print("[SQLite-RAM] Conexão (memória) fechada")
end

return SQLiteDB
