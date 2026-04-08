-- =========================
-- Configurações Gerais
-- =========================
local DB_HORIMETRO = "horimetro.db"
local DB_CONFIGURACAO = "configuracao.db"
local PLANTA_NOME = "SIGIL"

-- Limiares e intervalos otimizados
local LIMIAR_CORRENTE_MOTOR_LIGADO = 500  -- 5 Amperes
local INTERVALO_SALVAR_HORIMETRO = 60000   -- 60 segundos (motor ligado)
local INTERVALO_SALVAR_HORIMETRO_DESLIGADO = 300000  -- 5 minutos (motor desligado)

-- =========================
-- CONFIGURAÇÃO DOS MOTORES
-- Total: 22 motores (AV01, CV01, BRT01-03, TC01-14, PV01-03)
-- =========================
local MOTORES = {
    {tag="AV01",  corrente="@W_1#48",    alarme_w="@W_0#HAW0",  nominal_w="@W_0#HAW30", alarme_r="@W_0#HAW60",  nominal_r="@W_0#HAW90",  horimetro="@W_0#HAW200"},
    {tag="CV01",  corrente="@W_1#49",    alarme_w="@W_0#HAW1",  nominal_w="@W_0#HAW31", alarme_r="@W_0#HAW61",  nominal_r="@W_0#HAW91",  horimetro="@W_0#HAW202"},
    {tag="BRT01", corrente="@W_1#410",   alarme_w="@W_0#HAW2",  nominal_w="@W_0#HAW32", alarme_r="@W_0#HAW62",  nominal_r="@W_0#HAW92",  horimetro="@W_0#HAW204"},
    {tag="BRT02", corrente="@W_1#411",   alarme_w="@W_0#HAW3",  nominal_w="@W_0#HAW33", alarme_r="@W_0#HAW63",  nominal_r="@W_0#HAW93",  horimetro="@W_0#HAW206"},
    {tag="BRT03", corrente="@W_1#412",   alarme_w="@W_0#HAW4",  nominal_w="@W_0#HAW34", alarme_r="@W_0#HAW64",  nominal_r="@W_0#HAW94",  horimetro="@W_0#HAW208"},
    {tag="TC01",  corrente="@W_1#413",   alarme_w="@W_0#HAW5",  nominal_w="@W_0#HAW35", alarme_r="@W_0#HAW65",  nominal_r="@W_0#HAW95",  horimetro="@W_0#HAW210"},
    {tag="TC02",  corrente="@W_1#414",   alarme_w="@W_0#HAW6",  nominal_w="@W_0#HAW36", alarme_r="@W_0#HAW66",  nominal_r="@W_0#HAW96",  horimetro="@W_0#HAW212"},
    {tag="TC03",  corrente="@W_1#415",   alarme_w="@W_0#HAW7",  nominal_w="@W_0#HAW37", alarme_r="@W_0#HAW67",  nominal_r="@W_0#HAW97",  horimetro="@W_0#HAW214"},
    {tag="TC04",  corrente="@W_1#416",   alarme_w="@W_0#HAW8",  nominal_w="@W_0#HAW38", alarme_r="@W_0#HAW68",  nominal_r="@W_0#HAW98",  horimetro="@W_0#HAW216"},
    {tag="TC05",  corrente="@W_1#417",   alarme_w="@W_0#HAW9",  nominal_w="@W_0#HAW39", alarme_r="@W_0#HAW69",  nominal_r="@W_0#HAW99",  horimetro="@W_0#HAW218"},
    {tag="TC06",  corrente="@W_1#418",   alarme_w="@W_0#HAW10", nominal_w="@W_0#HAW40", alarme_r="@W_0#HAW70",  nominal_r="@W_0#HAW100", horimetro="@W_0#HAW220"},
    {tag="TC07",  corrente="@W_1#419",   alarme_w="@W_0#HAW11", nominal_w="@W_0#HAW41", alarme_r="@W_0#HAW71",  nominal_r="@W_0#HAW101", horimetro="@W_0#HAW222"},
    {tag="TC08",  corrente="@W_1#420",   alarme_w="@W_0#HAW12", nominal_w="@W_0#HAW42", alarme_r="@W_0#HAW72",  nominal_r="@W_0#HAW102", horimetro="@W_0#HAW224"},
    {tag="TC09",  corrente="@W_1#421",   alarme_w="@W_0#HAW13", nominal_w="@W_0#HAW43", alarme_r="@W_0#HAW73",  nominal_r="@W_0#HAW103", horimetro="@W_0#HAW226"},
    {tag="TC10",  corrente="@W_1#422",   alarme_w="@W_0#HAW14", nominal_w="@W_0#HAW44", alarme_r="@W_0#HAW74",  nominal_r="@W_0#HAW104", horimetro="@W_0#HAW228"},
    {tag="TC11",  corrente="@W_1#423",   alarme_w="@W_0#HAW15", nominal_w="@W_0#HAW45", alarme_r="@W_0#HAW75",  nominal_r="@W_0#HAW105", horimetro="@W_0#HAW230"},
    {tag="TC12",  corrente="@W_1#2:48",  alarme_w="@W_0#HAW16", nominal_w="@W_0#HAW46", alarme_r="@W_0#HAW76",  nominal_r="@W_0#HAW106", horimetro="@W_0#HAW232"},
    {tag="TC13",  corrente="@W_1#2:49",  alarme_w="@W_0#HAW17", nominal_w="@W_0#HAW47", alarme_r="@W_0#HAW77",  nominal_r="@W_0#HAW107", horimetro="@W_0#HAW234"},
    {tag="TC14",  corrente="@W_1#2:410", alarme_w="@W_0#HAW18", nominal_w="@W_0#HAW48", alarme_r="@W_0#HAW78",  nominal_r="@W_0#HAW108", horimetro="@W_0#HAW236"},
    {tag="PV01",  corrente="@W_1#2:411", alarme_w="@W_0#HAW19", nominal_w="@W_0#HAW49", alarme_r="@W_0#HAW79",  nominal_r="@W_0#HAW109", horimetro="@W_0#HAW238"},
    {tag="PV02",  corrente="@W_1#2:412", alarme_w="@W_0#HAW20", nominal_w="@W_0#HAW50", alarme_r="@W_0#HAW80",  nominal_r="@W_0#HAW110", horimetro="@W_0#HAW240"},
    {tag="PV03",  corrente="@W_1#2:413", alarme_w="@W_0#HAW21", nominal_w="@W_0#HAW51", alarme_r="@W_0#HAW81",  nominal_r="@W_0#HAW111", horimetro="@W_0#HAW242"}
}

-- =========================
-- Variáveis de Estado por Motor
-- =========================
local estadoMotores = {}
for i, motor in ipairs(MOTORES) do
    estadoMotores[motor.tag] = {
        -- Horímetro
        horimetroSegundos = 0,
        ultimoSalvarHorimetro = 0,
        motorLigado = false,
        ultimoTickHorimetro = 0,
        horimetroAnterior = 0,
        
        -- Configuração
        setpointAlarmeAnterior = 0,
        setpointNominalAnterior = 0,
        configCarregada = false,
        ultimaVerificacaoConfig = 0
    }
end

-- =========================
-- Variáveis Globais
-- =========================
local Inicializa = 0
local bancoHorimetroInicializado = false
local bancoConfiguracaoInicializado = false
local tentativasInicializacao = 0

local INTERVALO_VERIFICACAO_CONFIG = 5000  -- Verificar mudanças nas configs a cada 5 segundos

-- =========================
-- Utilitários DB
-- =========================
local function getDBPath(filename)
    local sdPath = we_bas_getsdpath()
    if not sdPath or sdPath == "" then
        print("ERRO: Caminho do SD não disponível")
        return nil
    end
    if not string.match(sdPath, "[/\\]$") then
        sdPath = sdPath .. "/"
    end
    return sdPath .. filename
end

local function abrirDB(filename)
    if not luasql_sqlite3 then 
        print("ERRO: luasql_sqlite3 não disponível")
        return nil, nil 
    end
    
    local dbpath = getDBPath(filename)
    if not dbpath then 
        print("ERRO: Caminho do banco inválido")
        return nil, nil 
    end
    
    local env, err_env = luasql_sqlite3.sqlite3()
    if not env then
        print("ERRO: Falha ao criar environment: " .. tostring(err_env))
        return nil, nil
    end
    
    local db, err_db = env:connect(dbpath)
    if not db then
        print("ERRO: Falha ao conectar ao banco: " .. tostring(err_db))
        if env then pcall(function() env:close() end) end
        return nil, nil
    end
    
    return env, db
end

local function fecharDB(env, db)
    if db then 
        local ok, err = pcall(function() db:close() end)
        if not ok then print("AVISO: Erro ao fechar DB: " .. tostring(err)) end
    end
    if env then 
        local ok, err = pcall(function() env:close() end)
        if not ok then print("AVISO: Erro ao fechar ENV: " .. tostring(err)) end
    end
end

-- =========================
-- Criar Estrutura dos Bancos
-- =========================
local function CriarBancoHorimetro()
    print("\n=== CRIANDO BANCO DE HORÍMETROS ===")
    
    local env, db = abrirDB(DB_HORIMETRO)
    if not env or not db then 
        print("ERRO: Não foi possível abrir " .. DB_HORIMETRO)
        return false 
    end
    
    local comandos = {
        -- CORREÇÃO: Mudar estrutura para ter TAG como UNIQUE, permitindo UPDATE
        [[CREATE TABLE IF NOT EXISTS horimetro (
            TAG       TEXT PRIMARY KEY,
            HORAS     INTEGER NOT NULL DEFAULT 0,
            DataHora  DATETIME DEFAULT CURRENT_TIMESTAMP
        )]],
        
        "CREATE INDEX IF NOT EXISTS idx_horim_data ON horimetro(DataHora)"
    }
    
    for i, sql in ipairs(comandos) do
        local ok, err = db:execute(sql)
        if not ok then
            print("ERRO no comando " .. i .. ": " .. tostring(err))
            fecharDB(env, db)
            return false
        end
    end
    
    fecharDB(env, db)
    print("✓ Banco de horímetros criado: " .. DB_HORIMETRO)
    print("===================================\n")
    return true
end

local function CriarBancoConfiguracao()
    print("\n=== CRIANDO BANCO DE CONFIGURAÇÕES ===")
    
    local env, db = abrirDB(DB_CONFIGURACAO)
    if not env or not db then 
        print("ERRO: Não foi possível abrir " .. DB_CONFIGURACAO)
        return false 
    end
    
    local comandos = {
        -- CORREÇÃO: Mudar estrutura para ter TAG como UNIQUE, permitindo UPDATE
        [[CREATE TABLE IF NOT EXISTS configuracoes (
            TAG       TEXT PRIMARY KEY,
            SETPOINT_ALARME   REAL NOT NULL DEFAULT 0,
            SETPOINT_NOMINAL  REAL NOT NULL DEFAULT 0,
            DataHora  DATETIME DEFAULT CURRENT_TIMESTAMP
        )]],
        
        "CREATE INDEX IF NOT EXISTS idx_config_data ON configuracoes(DataHora)"
    }
    
    for i, sql in ipairs(comandos) do
        local ok, err = db:execute(sql)
        if not ok then
            print("ERRO no comando " .. i .. ": " .. tostring(err))
            fecharDB(env, db)
            return false
        end
    end
    
    fecharDB(env, db)
    print("✓ Banco de configurações criado: " .. DB_CONFIGURACAO)
    print("===================================\n")
    return true
end

-- =========================
-- Helpers
-- =========================
local function formatarTempo(segundos)
    segundos = tonumber(segundos) or 0
    if segundos < 0 then segundos = 0 end
    local hh = math.floor(segundos / 3600)
    local mm = math.floor((segundos % 3600) / 60)
    local ss = segundos % 60
    return string.format("%02d:%02d:%02d", hh, mm, ss)
end

-- Escapar strings para SQL (proteção contra SQL injection)
local function escaparSQL(str)
    if not str then return "''" end
    str = tostring(str)
    str = string.gsub(str, "'", "''")
    return "'" .. str .. "'"
end

-- =========================
-- Funções de Configuração
-- =========================
local function EscreverEfetivos(motor, alarme, nominal)
    local alarmeInt = math.floor(tonumber(alarme) or 0)
    local nominalInt = math.floor(tonumber(nominal) or 0)
    
    if alarmeInt < 0 then alarmeInt = 0 end
    if nominalInt < 0 then nominalInt = 0 end
    
    we_bas_setword(motor.alarme_r, alarmeInt)
    we_bas_setword(motor.nominal_r, nominalInt)
    
    return true
end

local function CarregarConfiguracoes(motor)
    if not bancoConfiguracaoInicializado then return false end
    
    local env, db = abrirDB(DB_CONFIGURACAO)
    if not env or not db then return false end
    
    local tagEscapado = escaparSQL(motor.tag)
    local sql = string.format(
        "SELECT SETPOINT_ALARME, SETPOINT_NOMINAL FROM configuracoes WHERE TAG=%s",
        tagEscapado
    )
    
    local cursor = nil
    local status, err = pcall(function()
        cursor = db:execute(sql)
    end)
    
    if not status or not cursor then
        fecharDB(env, db)
        return false
    end
    
    local row = nil
    pcall(function()
        row = cursor:fetch({}, "a")
    end)
    
    if row then
        local alarme = tonumber(row.SETPOINT_ALARME) or 0
        local nominal = tonumber(row.SETPOINT_NOMINAL) or 0
        
        pcall(function() cursor:close() end)
        fecharDB(env, db)
        
        we_bas_setword(motor.alarme_w, alarme)
        we_bas_setword(motor.nominal_w, nominal)
        EscreverEfetivos(motor, alarme, nominal)
        
        local estado = estadoMotores[motor.tag]
        if estado then
            estado.setpointAlarmeAnterior = alarme
            estado.setpointNominalAnterior = nominal
        end
        
        return true
    end
    
    pcall(function() cursor:close() end)
    fecharDB(env, db)
    return false
end

-- CORREÇÃO: Usar INSERT OR REPLACE para manter apenas 1 linha por motor
local function SalvarConfiguracao(motor, setpointAlarme, setpointNominal)
    if not bancoConfiguracaoInicializado then return false end
    
    local env, db = abrirDB(DB_CONFIGURACAO)
    if not db then return false end
    
    local alarmeNum = math.floor(tonumber(setpointAlarme) or 0)
    local nominalNum = math.floor(tonumber(setpointNominal) or 0)
    
    if alarmeNum < 0 then alarmeNum = 0 end
    if nominalNum < 0 then nominalNum = 0 end
    
    local tagEscapado = escaparSQL(motor.tag)
    -- CORREÇÃO: Usar INSERT OR REPLACE para atualizar ao invés de inserir nova linha
    local sql = string.format(
        "INSERT OR REPLACE INTO configuracoes (TAG, SETPOINT_ALARME, SETPOINT_NOMINAL, DataHora) VALUES (%s, %d, %d, CURRENT_TIMESTAMP)",
        tagEscapado, alarmeNum, nominalNum
    )
    
    local ok, err = pcall(function()
        return db:execute(sql)
    end)
    
    fecharDB(env, db)
    
    if ok then
        EscreverEfetivos(motor, alarmeNum, nominalNum)
        return true
    else
        print("ERRO ao salvar configuração: " .. tostring(err))
        return false
    end
end

local function CriarConfiguracaoInicial(motor)
    local alarmeAtual = we_bas_getword(motor.alarme_w) or 0
    local nominalAtual = we_bas_getword(motor.nominal_w) or 0
    
    if alarmeAtual == 0 then alarmeAtual = 40000 end
    if nominalAtual == 0 then nominalAtual = 8000 end
    
    if SalvarConfiguracao(motor, alarmeAtual, nominalAtual) then
        we_bas_setword(motor.alarme_w, alarmeAtual)
        we_bas_setword(motor.nominal_w, nominalAtual)
        EscreverEfetivos(motor, alarmeAtual, nominalAtual)
        
        local estado = estadoMotores[motor.tag]
        if estado then
            estado.setpointAlarmeAnterior = alarmeAtual
            estado.setpointNominalAnterior = nominalAtual
        end
        
        return true
    end
    
    return false
end

-- =========================
-- Funções de Horímetro
-- =========================
local function CarregarHorimetro(motor)
    if not bancoHorimetroInicializado then return 0 end
    
    local env, db = abrirDB(DB_HORIMETRO)
    if not db then return 0 end
    
    local tagEscapado = escaparSQL(motor.tag)
    local sql = string.format(
        "SELECT HORAS FROM horimetro WHERE TAG=%s",
        tagEscapado
    )
    
    local cursor = nil
    local status, err = pcall(function()
        cursor = db:execute(sql)
    end)
    
    if not status or not cursor then
        fecharDB(env, db)
        return 0
    end
    
    local row = nil
    pcall(function()
        row = cursor:fetch({}, "a")
    end)
    
    if row then
        local horas = tonumber(row.HORAS) or 0
        if horas < 0 then horas = 0 end
        pcall(function() cursor:close() end)
        fecharDB(env, db)
        return horas
    end
    
    pcall(function() cursor:close() end)
    fecharDB(env, db)
    return 0
end

-- CORREÇÃO CRÍTICA: Usar INSERT OR REPLACE para manter apenas 1 linha por motor
-- Isso evita que o banco fique com milhares de linhas
local function SalvarHorimetro(motor, segundos)
    if not bancoHorimetroInicializado then return false end
    
    local env, db = abrirDB(DB_HORIMETRO)
    if not db then return false end
    
    -- Proteção contra valores negativos
    segundos = math.floor(tonumber(segundos) or 0)
    if segundos < 0 then segundos = 0 end
    
    local tagEscapado = escaparSQL(motor.tag)
    -- CORREÇÃO: Usar INSERT OR REPLACE para atualizar ao invés de inserir nova linha
    -- Isso mantém apenas 1 linha por motor, evitando crescimento excessivo do banco
    local sql = string.format(
        "INSERT OR REPLACE INTO horimetro (TAG, HORAS, DataHora) VALUES (%s, %d, CURRENT_TIMESTAMP)",
        tagEscapado, segundos
    )
    
    local ok, err = pcall(function()
        return db:execute(sql)
    end)
    
    fecharDB(env, db)
    
    if ok then
        local horasInteiras = math.floor(segundos / 3600)
        we_bas_setdword(motor.horimetro, horasInteiras)
        return true
    else
        print("ERRO ao salvar horímetro: " .. tostring(err))
        return false
    end
end

-- =========================
-- Verificar Ajuste Manual do Horímetro
-- =========================
local function VerificarAjusteManualHorimetro(motor)
    local estado = estadoMotores[motor.tag]
    if not estado then return false end
    
    -- Ler valor atual do registrador (em horas)
    local horasNoRegistrador = we_bas_getdword(motor.horimetro) or 0
    if horasNoRegistrador < 0 then horasNoRegistrador = 0 end
    
    -- Verificar se houve mudança manual
    if horasNoRegistrador ~= estado.horimetroAnterior then
        -- Usuário alterou manualmente o horímetro
        local segundosNovos = horasNoRegistrador * 3600
        
        print("\n>>> AJUSTE MANUAL DETECTADO - " .. motor.tag .. " <<<")
        print("  Valor anterior: " .. estado.horimetroAnterior .. "h")
        print("  Valor novo:     " .. horasNoRegistrador .. "h")
        print("  Diferença:      " .. (horasNoRegistrador - estado.horimetroAnterior) .. "h")
        
        -- Atualizar o horímetro interno
        estado.horimetroSegundos = segundosNovos
        estado.horimetroAnterior = horasNoRegistrador
        estado.ultimoTickHorimetro = we_bas_gettickcount()
        
        -- Salvar no banco imediatamente
        if SalvarHorimetro(motor, segundosNovos) then
            print("✓ Novo valor salvo no banco: " .. formatarTempo(segundosNovos))
        end
        
        return true
    end
    
    return false
end

local function AtualizarHorimetro(motor, corrente)
    local estado = estadoMotores[motor.tag]
    if not estado then return end
    
    local agora = we_bas_gettickcount()
    
    -- Proteção contra valores inválidos
    corrente = tonumber(corrente) or 0
    if corrente < 0 then corrente = 0 end
    
    -- Motor ligado quando corrente > 5A
    if corrente > LIMIAR_CORRENTE_MOTOR_LIGADO then
        if not estado.motorLigado then
            -- Motor acabou de ligar
            estado.motorLigado = true
            estado.ultimoTickHorimetro = agora
            print(motor.tag .. ": Motor LIGADO (corrente: " .. string.format("%.1f", corrente) .. "A)")
        else
            -- Motor continua ligado - acumular tempo
            local deltaMs = agora - estado.ultimoTickHorimetro
            
            -- Proteção contra wrap-around do tickcount
            if deltaMs < 0 then
                deltaMs = 0
                estado.ultimoTickHorimetro = agora
            end
            
            if deltaMs >= 1000 then
                local segundosDecorridos = math.floor(deltaMs / 1000)
                estado.horimetroSegundos = estado.horimetroSegundos + segundosDecorridos
                
                -- Proteção contra overflow
                if estado.horimetroSegundos < 0 then
                    estado.horimetroSegundos = 0
                end
                
                estado.ultimoTickHorimetro = agora
                
                -- Atualizar registrador apenas se mudou
                local horasInteiras = math.floor(estado.horimetroSegundos / 3600)
                if horasInteiras ~= estado.horimetroAnterior then
                    we_bas_setdword(motor.horimetro, horasInteiras)
                    estado.horimetroAnterior = horasInteiras
                end
            end
        end
        
        -- Salvar periodicamente quando ligado (60 segundos)
        local deltaSalvar = agora - estado.ultimoSalvarHorimetro
        if deltaSalvar < 0 then deltaSalvar = 0 end  -- Proteção wrap-around
        
        if deltaSalvar >= INTERVALO_SALVAR_HORIMETRO then
            if SalvarHorimetro(motor, estado.horimetroSegundos) then
                print(motor.tag .. ": Horímetro salvo - " .. formatarTempo(estado.horimetroSegundos))
            end
            estado.ultimoSalvarHorimetro = agora
        end
    else
        -- Motor desligado
        if estado.motorLigado then
            -- Motor acabou de desligar - salvar imediatamente
            estado.motorLigado = false
            print(motor.tag .. ": Motor DESLIGADO")
            if SalvarHorimetro(motor, estado.horimetroSegundos) then
                print(motor.tag .. ": Horímetro salvo ao desligar - " .. formatarTempo(estado.horimetroSegundos))
            end
            estado.ultimoSalvarHorimetro = agora
        else
            -- Motor continua desligado - salvar periodicamente (5 minutos)
            local deltaSalvar = agora - estado.ultimoSalvarHorimetro
            if deltaSalvar < 0 then deltaSalvar = 0 end  -- Proteção wrap-around
            
            if deltaSalvar >= INTERVALO_SALVAR_HORIMETRO_DESLIGADO then
                SalvarHorimetro(motor, estado.horimetroSegundos)
                estado.ultimoSalvarHorimetro = agora
            end
        end
    end
    
    -- Atualizar registrador apenas se necessário (evitar escrita duplicada)
    local horasInteiras = math.floor(estado.horimetroSegundos / 3600)
    if horasInteiras ~= estado.horimetroAnterior then
        we_bas_setdword(motor.horimetro, horasInteiras)
        estado.horimetroAnterior = horasInteiras
    end
end

-- =========================
-- Verificar Mudanças nos Setpoints (Otimizado)
-- =========================
local function VerificarMudancasSetpoints(motor)
    local estado = estadoMotores[motor.tag]
    if not estado then return end
    if not bancoConfiguracaoInicializado or not estado.configCarregada then return end
    
    local agora = we_bas_gettickcount()
    
    -- Verificar apenas a cada 5 segundos para não sobrecarregar
    local deltaConfig = agora - estado.ultimaVerificacaoConfig
    if deltaConfig < 0 then deltaConfig = 0 end  -- Proteção wrap-around
    
    if deltaConfig < INTERVALO_VERIFICACAO_CONFIG then
        return
    end
    
    estado.ultimaVerificacaoConfig = agora
    
    local alarmeAtual = we_bas_getword(motor.alarme_w) or 0
    local nominalAtual = we_bas_getword(motor.nominal_w) or 0
    
    local mudouAlarme = (alarmeAtual ~= estado.setpointAlarmeAnterior)
    local mudouNominal = (nominalAtual ~= estado.setpointNominalAnterior)
    
    if mudouAlarme or mudouNominal then
        print("\n>>> CONFIGURAÇÃO ALTERADA - " .. motor.tag .. " <<<")
        print("  Alarme:  " .. estado.setpointAlarmeAnterior .. " → " .. alarmeAtual)
        print("  Nominal: " .. estado.setpointNominalAnterior .. " → " .. nominalAtual)
        
        if SalvarConfiguracao(motor, alarmeAtual, nominalAtual) then
            print("✓ Nova configuração salva (atualizada, não inserida)")
            estado.setpointAlarmeAnterior = alarmeAtual
            estado.setpointNominalAnterior = nominalAtual
        else
            print("✗ Erro ao salvar configuração")
        end
    end
end

-- =========================
-- Inicialização
-- =========================
function InicializaDB()
    if Inicializa == 1 then return end

    local tempo = we_bas_gettickcount()
    
    if tempo < 5000 then 
        if tentativasInicializacao == 0 then
            print("Aguardando sistema estabilizar...")
        end
        tentativasInicializacao = tentativasInicializacao + 1
        if tentativasInicializacao > 100 then
            print("AVISO: Muitas tentativas de inicialização")
        end
        return 
    end

    print("\n========================================")
    print("SISTEMA DE HORÍMETROS - SIGIL")
    print("Versão Otimizada - 1 linha por motor")
    print("========================================\n")
    
    local dbpathHorim = getDBPath(DB_HORIMETRO)
    local dbpathConfig = getDBPath(DB_CONFIGURACAO)
    
    if not dbpathHorim or not dbpathConfig then 
        print("ERRO CRÍTICO: Caminho do SD não disponível")
        return 
    end

    print("Criando banco de horímetros...")
    if not CriarBancoHorimetro() then
        print("ERRO CRÍTICO: Falha ao criar banco de horímetros")
        return
    end
    bancoHorimetroInicializado = true
    
    we_bas_sleep(500)
    
    print("Criando banco de configurações...")
    if not CriarBancoConfiguracao() then
        print("ERRO CRÍTICO: Falha ao criar banco de configurações")
        return
    end
    bancoConfiguracaoInicializado = true
    
    print("\n✓ Ambos os bancos inicializados com sucesso")
    print("NOTA: Cada motor terá apenas 1 linha no banco (atualizada, não inserida)")
    
    we_bas_sleep(1000)
    
    print("\n--- Inicializando " .. #MOTORES .. " motores ---")
    
    for i, motor in ipairs(MOTORES) do
        print("\n[" .. i .. "/" .. #MOTORES .. "] Configurando " .. motor.tag .. "...")
        
        local estado = estadoMotores[motor.tag]
        if estado then
            -- Carregar ou criar configuração
            if CarregarConfiguracoes(motor) then
                estado.configCarregada = true
                print("  ✓ Configuração carregada")
            else
                if CriarConfiguracaoInicial(motor) then
                    estado.configCarregada = true
                    print("  ✓ Configuração inicial criada")
                else
                    print("  ✗ ERRO: Falha ao criar configuração")
                end
            end
            
            -- Carregar horímetro
            estado.horimetroSegundos = CarregarHorimetro(motor)
            local horasInteiras = math.floor(estado.horimetroSegundos / 3600)
            we_bas_setdword(motor.horimetro, horasInteiras)
            estado.horimetroAnterior = horasInteiras
            estado.ultimoTickHorimetro = we_bas_gettickcount()
            estado.ultimoSalvarHorimetro = estado.ultimoTickHorimetro
            estado.ultimaVerificacaoConfig = estado.ultimoTickHorimetro
            print("  ✓ Horímetro: " .. horasInteiras .. "h (" .. formatarTempo(estado.horimetroSegundos) .. ")")
        else
            print("  ✗ ERRO: Estado não encontrado")
        end
        
        we_bas_sleep(100)
    end
    
    Inicializa = 1
    print("\n✓✓✓ SISTEMA INICIALIZADO COM SUCESSO ✓✓✓")
    print("Limiar de corrente: " .. LIMIAR_CORRENTE_MOTOR_LIGADO .. "A")
    print("Intervalo de salvamento (ligado): " .. (INTERVALO_SALVAR_HORIMETRO/1000) .. "s")
    print("Intervalo de salvamento (desligado): " .. (INTERVALO_SALVAR_HORIMETRO_DESLIGADO/1000) .. "s")
    print("========================================\n")
end

-- =========================
-- Loop Principal
-- =========================
function LoopPrincipal()
    local status, err = pcall(function()
        InicializaDB()
        
        if not bancoHorimetroInicializado or not bancoConfiguracaoInicializado then 
            return 
        end
        
        -- Loop para cada motor
        for i, motor in ipairs(MOTORES) do
            local estado = estadoMotores[motor.tag]
            
            if not estado or not estado.configCarregada then
                goto continue
            end
            
            -- 1. Verificar ajuste manual no horímetro
            VerificarAjusteManualHorimetro(motor)
            
            -- 2. Verificar mudanças nas configurações (otimizado - a cada 5 segundos)
            VerificarMudancasSetpoints(motor)
            
            -- 3. Ler corrente do motor
            local corrente = we_bas_getword(motor.corrente) or 0
            
            -- 4. Atualizar horímetro
            AtualizarHorimetro(motor, corrente)
            
            ::continue::
        end
    end)
    
    if not status then
        print("ERRO CRÍTICO NO LOOP: " .. tostring(err))
    end
end
