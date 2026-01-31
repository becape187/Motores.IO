# Documentação LuaSocket, HTTP e SQLite - PIStudio

Documentação oficial: [PIStudio Lua Script](https://docs.we-con.com.cn/bin/view/PIStudio/09%20Lua%20Editor/Lua%20Script/)

---

## LuaSocket

Módulo de programação de rede do Lua para desenvolvimento secundário conforme requisitos.

### Carregamento de Módulos

```lua
local socket = require("socket")         -- Carregar módulo socket e tudo que ele precisa
local http = require("socket.http")      -- Carregar módulo http e tudo que ele precisa
local smtp = require("socket.smtp")      -- Carregar módulo smtp e tudo que ele precisa
local ftp = require("socket.ftp")        -- Carregar módulo ftp e tudo que ele precisa
local ltn12 = require("ltn12")           -- Módulo auxiliar para manipulação de dados
```

### Módulos Incluídos

- **socket**: Módulo básico de rede - parâmetros e funções básicas
- **dns**: Módulo DNS
- **TCP**: Objeto de protocolo TCP
- **UDP**: Objeto de protocolo UDP
- **ftp**: API de protocolo FTP - usado para transferência de arquivos (apenas cliente)
- **http**: API de protocolo HTTP
- **https**: API de protocolo HTTPS
- **smtp**: API de protocolo SMTP - usado para serviços de email de terceiros
- **ltn12**: Módulo auxiliar LTN12
- **mime**: Módulo auxiliar MIME

---

## Socket - Funções Básicas

### socket.tcp()

Cria um objeto TCP mestre.

**Sintaxe:**
```lua
tcp = socket.tcp()
```

**Retorno:**
- `tcp`: Objeto TCP criado

**Exemplo:**
```lua
local socket = require("socket")
local tcp = socket.tcp()
```

### socket.udp()

Cria um objeto UDP não conectado.

**Sintaxe:**
```lua
udp = socket.udp()
```

**Retorno:**
- `udp`: Objeto UDP criado

---

## TCP - Módulo de Protocolo TCP

### tcp:connect()

Conecta um objeto TCP mestre a um endereço remoto e porta.

**Sintaxe:**
```lua
success, err = tcp:connect(address, port)
```

**Parâmetros:**
- `address`: Endereço IP ou hostname do servidor
- `port`: Número da porta

**Retorno:**
- `success`: 1 se sucesso, nil se falha
- `err`: Mensagem de erro (se houver)

**Exemplo:**
```lua
local socket = require("socket")
local tcp = socket.tcp()
local success, err = tcp:connect("192.168.1.100", 8080)
if success then
    print("Conectado com sucesso")
else
    print("Erro: " .. tostring(err))
end
```

### tcp:send()

Envia dados através do socket TCP.

**Sintaxe:**
```lua
success, err, last_byte = tcp:send(data, i, j)
```

**Parâmetros:**
- `data`: String de dados a enviar
- `i`: Índice inicial (opcional)
- `j`: Índice final (opcional)

**Retorno:**
- `success`: Número de bytes enviados ou nil
- `err`: Mensagem de erro (se houver)
- `last_byte`: Índice do último byte enviado

**Exemplo:**
```lua
local sent, err = tcp:send("Hello, Server!\n")
if sent then
    print("Enviados " .. sent .. " bytes")
end
```

### tcp:receive()

Recebe dados do socket TCP.

**Sintaxe:**
```lua
data, err, partial = tcp:receive(pattern)
```

**Parâmetros:**
- `pattern`: Padrão de recepção
  - `"*l"`: Lê uma linha (até \n)
  - `"*a"`: Lê tudo até conexão fechar
  - `number`: Lê exatamente `number` bytes

**Retorno:**
- `data`: Dados recebidos
- `err`: Mensagem de erro (se houver)
- `partial`: Dados parciais recebidos antes do erro

**Exemplo:**
```lua
local line, err = tcp:receive("*l")
if line then
    print("Recebido: " .. line)
end
```

### tcp:settimeout()

Define o tempo limite para operações de I/O.

**Sintaxe:**
```lua
tcp:settimeout(value, mode)
```

**Parâmetros:**
- `value`: Tempo em segundos (nil para sem timeout)
- `mode`: 'b' (block) ou 't' (total) - opcional

**Exemplo:**
```lua
tcp:settimeout(5) -- Timeout de 5 segundos
```

### tcp:close()

Fecha o socket TCP.

**Sintaxe:**
```lua
tcp:close()
```

**Exemplo:**
```lua
tcp:close()
print("Conexão fechada")
```

### tcp:setpeername()

Conecta a um endereço remoto (alternativa ao connect).

**Sintaxe:**
```lua
success, err = tcp:setpeername(address, port)
```

---

## HTTP - Módulo de Protocolo HTTP

### http.request()

Realiza uma requisição HTTP.

**Sintaxe Simples:**
```lua
body, code, headers, status = http.request(url)
```

**Sintaxe Completa:**
```lua
body, code, headers, status = http.request{
    url = string,
    sink = LTN12 sink,
    method = string,
    headers = header-table,
    source = LTN12 source,
    step = LTN12 pump step,
    proxy = string,
    redirect = boolean,
    create = function
}
```

**Parâmetros:**
- `url`: URL completa da requisição
- `method`: Método HTTP (GET, POST, PUT, DELETE, etc.)
- `headers`: Tabela com cabeçalhos HTTP
- `source`: Fonte de dados (para POST/PUT) usando LTN12
- `sink`: Destino dos dados recebidos usando LTN12

**Retorno:**
- `body`: Corpo da resposta (ou 1 se sucesso com sink)
- `code`: Código de status HTTP
- `headers`: Cabeçalhos da resposta
- `status`: String de status

**Exemplo GET Simples:**
```lua
local http = require("socket.http")

local body, code = http.request("http://example.com/api/data")
if code == 200 then
    print("Resposta: " .. body)
end
```

**Exemplo POST com JSON:**
```lua
local http = require("socket.http")
local ltn12 = require("ltn12")

local request_body = json.encode({name = "Motor 1", status = true})
local response_body = {}

local result, code, headers = http.request{
    url = "http://api.example.com/motors",
    method = "POST",
    headers = {
        ["Content-Type"] = "application/json",
        ["Content-Length"] = string.len(request_body)
    },
    source = ltn12.source.string(request_body),
    sink = ltn12.sink.table(response_body)
}

if code == 200 or code == 201 then
    local response = table.concat(response_body)
    print("Sucesso: " .. response)
end
```

---

## HTTPS - Módulo de Protocolo HTTPS

### https.request()

Realiza uma requisição HTTPS (mesmo formato do http.request).

**Sintaxe:**
```lua
body, code, headers, status = https.request(url)
-- ou formato completo igual http.request
```

**Exemplo:**
```lua
local https = require("socket.https")

local body, code = https.request("https://api.example.com/data")
if code == 200 then
    print("Dados seguros recebidos")
end
```

---

## LTN12 - Módulo Auxiliar

Módulo para manipulação eficiente de dados em requisições HTTP.

### LTN12.source.string()

Cria uma fonte a partir de uma string.

**Sintaxe:**
```lua
source = ltn12.source.string(str)
```

**Exemplo:**
```lua
local ltn12 = require("ltn12")
local source = ltn12.source.string("dados a enviar")
```

### LTN12.sink.table()

Cria um destino que armazena dados em uma tabela.

**Sintaxe:**
```lua
sink = ltn12.sink.table(t)
```

**Exemplo:**
```lua
local ltn12 = require("ltn12")
local response = {}
local sink = ltn12.sink.table(response)
-- Após requisição: local body = table.concat(response)
```

---

## JSON - Codificação e Decodificação

O PIStudio fornece funções globais para JSON (não precisa de require).

### json.encode()

Converte uma tabela Lua em string JSON.

**Sintaxe:**
```lua
json_string = json.encode(table)
```

**Exemplo:**
```lua
local data = {
    id = 1,
    nome = "Motor Principal",
    status = true,
    corrente = 15.5
}

local json_string = json.encode(data)
print(json_string)
-- Resultado: {"id":1,"nome":"Motor Principal","status":true,"corrente":15.5}
```

### json.decode()

Converte uma string JSON em tabela Lua.

**Sintaxe:**
```lua
table = json.decode(json_string)
```

**Exemplo:**
```lua
local json_string = '{"id":1,"nome":"Motor 1","status":true}'
local data = json.decode(json_string)

print(data.id)      -- 1
print(data.nome)    -- Motor 1
print(data.status)  -- true
```

---

## LuaSqlite - Banco de Dados SQLite

Módulo para operações com banco de dados SQLite local.

### Conectar ao Banco de Dados

**Sintaxe:**
```lua
db = sqlite3.open(filename)
```

**Parâmetros:**
- `filename`: Caminho do arquivo do banco de dados

**Exemplo:**
```lua
local db = sqlite3.open("motores.db")
if db then
    print("Banco de dados aberto com sucesso")
end
```

### db:execute()

Executa um comando SQL.

**Sintaxe:**
```lua
success = db:execute(sql_statement)
```

**Parâmetros:**
- `sql_statement`: Comando SQL a executar

**Retorno:**
- `success`: true se sucesso, nil se falha

**Exemplo - Criar Tabela:**
```lua
local sql = [[
    CREATE TABLE IF NOT EXISTS motores (
        id INTEGER PRIMARY KEY,
        nome TEXT NOT NULL,
        corrente REAL DEFAULT 0.0,
        status INTEGER DEFAULT 0
    )
]]

local success = db:execute(sql)
if success then
    print("Tabela criada com sucesso")
end
```

**Exemplo - Inserir Dados:**
```lua
local sql = string.format(
    "INSERT INTO motores (id, nome, corrente, status) VALUES (%d, '%s', %.2f, %d)",
    1, "Motor Principal", 15.5, 1
)

db:execute(sql)
```

### db:escape()

Escapa caracteres especiais em strings SQL.

**Sintaxe:**
```lua
escaped_string = db:escape(str)
```

**Exemplo:**
```lua
local nome = "Motor's Name"
local nome_escapado = db:escape(nome)
local sql = "INSERT INTO motores (nome) VALUES ('" .. nome_escapado .. "')"
```

### db:execute() com Cursor

Executa uma query e retorna um cursor para iteração.

**Sintaxe:**
```lua
cursor = db:execute(sql_query)
```

**Exemplo - Buscar Dados:**
```lua
local sql = "SELECT * FROM motores"
local cursor = db:execute(sql)

if cursor then
    local row = cursor:fetch()
    while row do
        print("ID: " .. row[1])
        print("Nome: " .. row[2])
        print("Corrente: " .. row[3])
        
        row = cursor:fetch()
    end
    cursor:close()
end
```

### cursor:fetch()

Busca a próxima linha do resultado.

**Sintaxe:**
```lua
row = cursor:fetch(mode)
```

**Parâmetros:**
- `mode`: Opcional - pode ser uma tabela para armazenar resultados

**Retorno:**
- `row`: Tabela com os valores da linha (nil se não houver mais linhas)

**Exemplo:**
```lua
local row = cursor:fetch()
if row then
    -- Acessar por índice
    local id = row[1]
    local nome = row[2]
    
    -- ou por nome (dependendo do driver)
    local id = row.id
    local nome = row.nome
end
```

### cursor:getcolnames()

Obtém os nomes das colunas do resultado.

**Sintaxe:**
```lua
column_names = cursor:getcolnames()
```

**Retorno:**
- `column_names`: Tabela com os nomes das colunas

### cursor:close()

Fecha o cursor.

**Sintaxe:**
```lua
cursor:close()
```

### db:close()

Fecha a conexão com o banco de dados.

**Sintaxe:**
```lua
db:close()
```

**Exemplo:**
```lua
db:close()
print("Banco de dados fechado")
```

### db:commit()

Confirma uma transação.

**Sintaxe:**
```lua
db:commit()
```

### db:rollback()

Reverte uma transação.

**Sintaxe:**
```lua
db:rollback()
```

### db:setautocommit()

Define o modo de auto-commit.

**Sintaxe:**
```lua
db:setautocommit(boolean)
```

**Parâmetros:**
- `boolean`: true para ativar, false para desativar

---

## Exemplo Completo - Socket TCP Cliente

```lua
local socket = require("socket")

-- Criar e conectar socket TCP
local tcp = socket.tcp()
tcp:settimeout(5)

local success, err = tcp:connect("192.168.1.100", 8080)

if success then
    print("Conectado ao servidor")
    
    -- Enviar mensagem
    local msg = json.encode({cmd = "status", id = 1})
    tcp:send(msg .. "\n")
    
    -- Receber resposta
    local response, err = tcp:receive("*l")
    if response then
        local data = json.decode(response)
        print("Resposta recebida:", data)
    end
    
    -- Fechar conexão
    tcp:close()
else
    print("Erro ao conectar:", err)
end
```

---

## Exemplo Completo - HTTP com JSON

```lua
local http = require("socket.http")
local ltn12 = require("ltn12")

-- Preparar dados
local motor_data = {
    id = 1,
    nome = "Motor Principal",
    corrente = 15.5,
    status = true
}

local request_body = json.encode(motor_data)
local response_body = {}

-- Fazer requisição POST
local result, code, headers = http.request{
    url = "http://api.example.com/motors",
    method = "POST",
    headers = {
        ["Content-Type"] = "application/json",
        ["Content-Length"] = string.len(request_body)
    },
    source = ltn12.source.string(request_body),
    sink = ltn12.sink.table(response_body)
}

if code == 200 or code == 201 then
    local response = table.concat(response_body)
    local data = json.decode(response)
    print("Sucesso! ID retornado:", data.id)
else
    print("Erro HTTP:", code)
end
```

---

## Exemplo Completo - SQLite

```lua
-- Abrir/criar banco de dados
local db = sqlite3.open("motores.db")

-- Criar tabela
local sql_create = [[
    CREATE TABLE IF NOT EXISTS motores (
        id INTEGER PRIMARY KEY,
        nome TEXT NOT NULL,
        corrente REAL,
        status INTEGER,
        timestamp TEXT DEFAULT CURRENT_TIMESTAMP
    )
]]

db:execute(sql_create)

-- Inserir dados
local nome = db:escape("Motor Principal")
local sql_insert = string.format(
    "INSERT INTO motores (id, nome, corrente, status) VALUES (1, '%s', 15.5, 1)",
    nome
)
db:execute(sql_insert)

-- Consultar dados
local sql_select = "SELECT * FROM motores WHERE status = 1"
local cursor = db:execute(sql_select)

if cursor then
    local row = cursor:fetch()
    while row do
        print(string.format("Motor: %s, Corrente: %.2fA", row[2], row[3]))
        row = cursor:fetch()
    end
    cursor:close()
end

-- Fechar banco
db:close()
```

---

## Observações Importantes

1. **Módulos**: Sempre use `require()` para carregar módulos socket, http, ltn12, etc.
2. **JSON**: As funções `json.encode()` e `json.decode()` são globais (não precisam de require)
3. **SQLite**: O objeto `sqlite3` é global no PIStudio
4. **Timeouts**: Sempre defina timeouts em operações de rede para evitar travamentos
5. **Erro Handling**: Sempre verifique os valores de retorno para detectar erros
6. **Strings SQL**: Use `db:escape()` para evitar SQL injection

---

## Compatibilidade

- **i/HMI+ series**: ✓
- **ie series**: ✓
- **ig series**: ✓
- **HMI V2.0**: ✓

---

**Referência Oficial:** [PIStudio Lua Script Documentation](https://docs.we-con.com.cn/bin/view/PIStudio/09%20Lua%20Editor/Lua%20Script/)
