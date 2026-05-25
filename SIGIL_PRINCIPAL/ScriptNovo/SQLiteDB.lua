-- =====================================================================
-- SQLiteDB.lua  (CACHE DE MOTORES EM RAM)
-- ---------------------------------------------------------------------
-- Nome é legado da migração que abandonou SQLite/SD. Hoje é só uma
-- tabela Lua em RAM que serve de cache local dos motores recebidos da
-- API. Sem disco, sem persistência entre reboots, sem luasql_sqlite3.
--
-- Por que é seguro:
--   - O cadastro de motores tem o SERVIDOR como fonte da verdade
--     (MotorSync re-sincroniza da API a cada boot e a cada minuto).
--   - Histórico/telemetria não vive aqui — vai pelo socket :5055
--     e pelo backend; a IHM não persiste nada localmente.
--
-- Interface (usada por MotorSync):
--   :new()
--   :Conectar()
--   :InserirOuAtualizarMotor(motor, timestampUnix)
--   :BuscarTodosMotores()
--   :BuscarMotor(id)
--   :BuscarUltimaAtualizacaoMotor(guid)
-- =====================================================================

SQLiteDB = {}
SQLiteDB.__index = SQLiteDB

-- =========================
-- Construtor
-- =========================
function SQLiteDB:new()
    local obj = {}
    setmetatable(obj, SQLiteDB)

    obj.Connected = false

    -- Cache em memória
    obj.motores            = {}   -- array de objetos Motor
    obj._motorPorGuid      = {}   -- guid -> índice em obj.motores
    obj._dataAtualizacao   = {}   -- guid -> string ISO

    return obj
end

-- =========================
-- "Conexão" — no-op, só marca pronto
-- =========================
function SQLiteDB:Conectar()
    self.Connected = true
    print("[Cache] ✓ Cache de motores inicializado (RAM, sem persistência)")
    return true
end

-- =========================
-- Operações de motor
-- =========================

-- Upsert por ID (legado — algumas chamadas antigas)
function SQLiteDB:SalvarMotor(motor)
    if not self.Connected then return false, "Cache não inicializado" end
    if not motor then return false, "Motor nulo" end

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
    if not self.Connected then return nil, "Cache não inicializado" end
    for _, m in ipairs(self.motores) do
        if m.ID == id then
            return m
        end
    end
    return nil, "Motor não encontrado"
end

function SQLiteDB:BuscarTodosMotores()
    if not self.Connected then
        return {}, "Cache não inicializado"
    end
    local lista = {}
    for _, m in ipairs(self.motores) do
        table.insert(lista, m)
    end
    return lista
end

-- Upsert por GUID (caminho principal usado por MotorSync)
function SQLiteDB:InserirOuAtualizarMotor(motor, timestampUnix)
    if not self.Connected then
        return false, "Cache não inicializado"
    end
    if not motor or not motor.GUID then
        return false, "Motor sem GUID"
    end

    if timestampUnix and timestampUnix > 0 then
        self._dataAtualizacao[motor.GUID] = os.date("!%Y-%m-%dT%H:%M:%SZ", timestampUnix)
    end

    local idx = self._motorPorGuid[motor.GUID]
    if idx and self.motores[idx] then
        self.motores[idx] = motor
    else
        table.insert(self.motores, motor)
        self._motorPorGuid[motor.GUID] = #self.motores
    end
    return true
end

function SQLiteDB:BuscarUltimaAtualizacaoMotor(guid)
    if not self.Connected or not guid then return nil end
    return self._dataAtualizacao[guid]
end

-- =========================
-- Fechar (no-op real — cache fica vivo até reboot)
-- =========================
function SQLiteDB:Fechar()
    self.Connected = false
    print("[Cache] Cache marcado como fechado (dados em RAM seguem até reboot)")
end

return SQLiteDB
