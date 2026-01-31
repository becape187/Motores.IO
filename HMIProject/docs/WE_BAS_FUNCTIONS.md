# Documentação Funções we_bas_ - PIStudio

Funções básicas para interação com registros internos da IHM (Address Read & Write, operações de tela, etc.)

Documentação oficial: [PIStudio Lua Script - Basic Functions](https://docs.we-con.com.cn/bin/view/PIStudio/09%20Lua%20Editor/Lua%20Script/)

---

## Visão Geral

As funções `we_bas_` são funções básicas do PIStudio para:
- Leitura e escrita de endereços de memória (registros internos)
- Operações com telas (screen operations)
- Controle de objetos da IHM
- Informações do sistema

---

## Leitura e Escrita de Endereços

### we_bas_readaddress()

Lê valor de um endereço de registro.

**Sintaxe:**
```lua
value = we_bas_readaddress(address_type, address, data_type)
```

**Parâmetros:**
- `address_type`: Tipo do endereço (string)
  - `"LW"`: Local Word (16 bits)
  - `"LB"`: Local Bit
  - `"RW"`: Remote Word
  - `"RB"`: Remote Bit
- `address`: Número do endereço (integer)
- `data_type`: Tipo de dados a ler
  - `0`: BIT (1 bit)
  - `1`: WORD (16 bits sem sinal)
  - `2`: SWORD (16 bits com sinal)
  - `3`: DWORD (32 bits sem sinal)
  - `4`: SDWORD (32 bits com sinal)
  - `5`: FLOAT (32 bits ponto flutuante)
  - `6`: STRING

**Retorno:**
- `value`: Valor lido do endereço

**Exemplo:**
```lua
-- Ler um Word do registro local LW100
local valor = we_bas_readaddress("LW", 100, 1)
print("Valor de LW100:", valor)

-- Ler um Float do registro local LW200
local temperatura = we_bas_readaddress("LW", 200, 5)
print("Temperatura:", temperatura)

-- Ler um Bit do registro local LB10
local estado = we_bas_readaddress("LB", 10, 0)
print("Estado do bit LB10:", estado)
```

### we_bas_writeaddress()

Escreve valor em um endereço de registro.

**Sintaxe:**
```lua
success = we_bas_writeaddress(address_type, address, data_type, value)
```

**Parâmetros:**
- `address_type`: Tipo do endereço (string) - igual readaddress
- `address`: Número do endereço (integer)
- `data_type`: Tipo de dados a escrever (igual readaddress)
- `value`: Valor a escrever

**Retorno:**
- `success`: true se sucesso, false se falha

**Exemplo:**
```lua
-- Escrever valor 100 em LW100 (Word)
we_bas_writeaddress("LW", 100, 1, 100)

-- Escrever temperatura 25.5 em LW200 (Float)
we_bas_writeaddress("LW", 200, 5, 25.5)

-- Setar bit LB10
we_bas_writeaddress("LB", 10, 0, 1)

-- Resetar bit LB11
we_bas_writeaddress("LB", 11, 0, 0)
```

---

## Operações com Telas

### we_bas_switchscreen()

Troca para outra tela.

**Sintaxe:**
```lua
we_bas_switchscreen(screen_id)
```

**Parâmetros:**
- `screen_id`: ID da tela para a qual deseja trocar (integer)

**Exemplo:**
```lua
-- Trocar para a tela com ID 5
we_bas_switchscreen(5)
```

### we_bas_getcurrentscreen()

Obtém o ID da tela atual.

**Sintaxe:**
```lua
screen_id = we_bas_getcurrentscreen()
```

**Retorno:**
- `screen_id`: ID da tela atual

**Exemplo:**
```lua
local tela_atual = we_bas_getcurrentscreen()
print("Tela atual:", tela_atual)

if tela_atual == 1 then
    print("Estamos na tela principal")
end
```

### we_bas_openwindow()

Abre uma janela popup.

**Sintaxe:**
```lua
we_bas_openwindow(window_id)
```

**Parâmetros:**
- `window_id`: ID da janela a abrir

**Exemplo:**
```lua
-- Abrir janela de configuração (ID 10)
we_bas_openwindow(10)
```

### we_bas_closewindow()

Fecha uma janela popup.

**Sintaxe:**
```lua
we_bas_closewindow(window_id)
```

**Parâmetros:**
- `window_id`: ID da janela a fechar (0 para fechar todas)

**Exemplo:**
```lua
-- Fechar janela específica
we_bas_closewindow(10)

-- Fechar todas as janelas
we_bas_closewindow(0)
```

---

## Controle de Sistema

### we_bas_beep()

Emite um beep sonoro.

**Sintaxe:**
```lua
we_bas_beep(duration)
```

**Parâmetros:**
- `duration`: Duração do beep em milissegundos

**Exemplo:**
```lua
-- Beep de 200ms
we_bas_beep(200)
```

### we_bas_setbacklight()

Define o brilho da tela.

**Sintaxe:**
```lua
we_bas_setbacklight(level)
```

**Parâmetros:**
- `level`: Nível de brilho (0-100)

**Exemplo:**
```lua
-- Definir brilho para 80%
we_bas_setbacklight(80)

-- Desligar backlight
we_bas_setbacklight(0)

-- Brilho máximo
we_bas_setbacklight(100)
```

### we_bas_getbacklight()

Obtém o nível atual de brilho.

**Sintaxe:**
```lua
level = we_bas_getbacklight()
```

**Retorno:**
- `level`: Nível de brilho atual (0-100)

**Exemplo:**
```lua
local brilho = we_bas_getbacklight()
print("Brilho atual:", brilho .. "%")
```

---

## Informações do Sistema

### we_bas_getmachineinfo()

Obtém informações sobre a IHM.

**Sintaxe:**
```lua
info = we_bas_getmachineinfo(info_type)
```

**Parâmetros:**
- `info_type`: Tipo de informação solicitada
  - `0`: Nome do modelo
  - `1`: Versão do firmware
  - `2`: Número de série
  - `3`: Endereço MAC
  - `4`: Endereço IP

**Retorno:**
- `info`: String com a informação solicitada

**Exemplo:**
```lua
-- Obter modelo da IHM
local modelo = we_bas_getmachineinfo(0)
print("Modelo:", modelo)

-- Obter versão do firmware
local versao = we_bas_getmachineinfo(1)
print("Firmware:", versao)

-- Obter número de série
local serial = we_bas_getmachineinfo(2)
print("Serial:", serial)

-- Obter endereço MAC
local mac = we_bas_getmachineinfo(3)
print("MAC:", mac)

-- Obter endereço IP
local ip = we_bas_getmachineinfo(4)
print("IP:", ip)
```

---

## Exemplo Prático - Monitoramento de Motor

```lua
-- Definir endereços de memória
local ADDR_MOTOR_STATUS = 100     -- LW100: Status do motor (0=Desligado, 1=Ligado)
local ADDR_MOTOR_CORRENTE = 102   -- LW102: Corrente do motor (Float)
local ADDR_MOTOR_TEMP = 104       -- LW104: Temperatura do motor (Float)
local ADDR_ALARME = 10            -- LB10: Bit de alarme

-- Função para ler dados do motor
function LerDadosMotor()
    local status = we_bas_readaddress("LW", ADDR_MOTOR_STATUS, 1)
    local corrente = we_bas_readaddress("LW", ADDR_MOTOR_CORRENTE, 5)
    local temperatura = we_bas_readaddress("LW", ADDR_MOTOR_TEMP, 5)
    
    return {
        status = status,
        corrente = corrente,
        temperatura = temperatura
    }
end

-- Função para verificar alarmes
function VerificarAlarmes()
    local dados = LerDadosMotor()
    
    -- Verificar sobrecorrente
    if dados.corrente > 50.0 then
        we_bas_writeaddress("LB", ADDR_ALARME, 0, 1)  -- Setar bit de alarme
        we_bas_beep(500)  -- Beep de alarme
        we_bas_openwindow(99)  -- Abrir janela de alarme
        return true
    end
    
    -- Verificar superaquecimento
    if dados.temperatura > 80.0 then
        we_bas_writeaddress("LB", ADDR_ALARME, 0, 1)
        we_bas_beep(500)
        we_bas_openwindow(99)
        return true
    end
    
    -- Se tudo OK, resetar alarme
    we_bas_writeaddress("LB", ADDR_ALARME, 0, 0)
    return false
end

-- Função para ligar/desligar motor
function ControlarMotor(ligar)
    if ligar then
        we_bas_writeaddress("LW", ADDR_MOTOR_STATUS, 1, 1)
        print("Motor ligado")
    else
        we_bas_writeaddress("LW", ADDR_MOTOR_STATUS, 1, 0)
        print("Motor desligado")
    end
end
```

---

## Exemplo Prático - Navegação entre Telas

```lua
-- IDs das telas
local TELA_PRINCIPAL = 1
local TELA_CONFIG = 5
local TELA_ALARMES = 10
local TELA_HISTORICO = 15

-- Função para ir para tela principal
function IrParaPrincipal()
    we_bas_switchscreen(TELA_PRINCIPAL)
end

-- Função para ir para tela de configuração
function IrParaConfig()
    -- Verificar se usuário está autenticado
    local usuario_autenticado = we_bas_readaddress("LB", 50, 0)
    
    if usuario_autenticado == 1 then
        we_bas_switchscreen(TELA_CONFIG)
    else
        we_bas_openwindow(100)  -- Abrir janela de login
        we_bas_beep(200)
    end
end

-- Função para voltar à tela anterior
function VoltarTela()
    -- Ler ID da tela anterior (armazenado em LW500)
    local tela_anterior = we_bas_readaddress("LW", 500, 1)
    
    if tela_anterior > 0 then
        we_bas_switchscreen(tela_anterior)
    else
        we_bas_switchscreen(TELA_PRINCIPAL)
    end
end

-- Salvar tela atual antes de trocar
function TrocarTelaComHistorico(nova_tela)
    local tela_atual = we_bas_getcurrentscreen()
    we_bas_writeaddress("LW", 500, 1, tela_atual)  -- Salvar tela atual
    we_bas_switchscreen(nova_tela)
end
```

---

## Exemplo Prático - Sistema de Logs

```lua
-- Endereços para armazenar logs
local LOG_INDEX = 600      -- LW600: Índice do último log
local LOG_DATA_START = 700 -- LW700-799: 100 words para logs

-- Função para adicionar log
function AdicionarLog(codigo_evento, valor)
    -- Ler índice atual
    local index = we_bas_readaddress("LW", LOG_INDEX, 1)
    
    -- Calcular posição no buffer circular (máximo 50 logs)
    local posicao = (index % 50) * 2  -- Cada log usa 2 words
    
    -- Escrever código do evento
    we_bas_writeaddress("LW", LOG_DATA_START + posicao, 1, codigo_evento)
    
    -- Escrever valor
    we_bas_writeaddress("LW", LOG_DATA_START + posicao + 1, 5, valor)
    
    -- Incrementar índice
    we_bas_writeaddress("LW", LOG_INDEX, 1, index + 1)
    
    print("Log adicionado: Evento=" .. codigo_evento .. ", Valor=" .. valor)
end

-- Função para ler últimos logs
function LerUltimosLogs(quantidade)
    local index = we_bas_readaddress("LW", LOG_INDEX, 1)
    local logs = {}
    
    for i = 1, quantidade do
        local pos = ((index - i) % 50) * 2
        
        if pos >= 0 then
            local codigo = we_bas_readaddress("LW", LOG_DATA_START + pos, 1)
            local valor = we_bas_readaddress("LW", LOG_DATA_START + pos + 1, 5)
            
            table.insert(logs, {codigo = codigo, valor = valor})
        end
    end
    
    return logs
end
```

---

## Tipos de Dados - Referência Rápida

| Código | Tipo      | Descrição                    | Tamanho |
|--------|-----------|------------------------------|---------|
| 0      | BIT       | Bit único                    | 1 bit   |
| 1      | WORD      | 16 bits sem sinal            | 16 bits |
| 2      | SWORD     | 16 bits com sinal            | 16 bits |
| 3      | DWORD     | 32 bits sem sinal            | 32 bits |
| 4      | SDWORD    | 32 bits com sinal            | 32 bits |
| 5      | FLOAT     | Ponto flutuante              | 32 bits |
| 6      | STRING    | String de caracteres         | Variável|

---

## Tipos de Endereço - Referência Rápida

| Tipo | Descrição          | Uso                        |
|------|--------------------|-----------------------------|
| LW   | Local Word         | Registros internos da IHM   |
| LB   | Local Bit          | Bits internos da IHM        |
| RW   | Remote Word        | Registros do PLC/dispositivo|
| RB   | Remote Bit         | Bits do PLC/dispositivo     |

---

## Boas Práticas

1. **Sempre verificar valores de retorno** ao ler endereços
2. **Usar constantes** para endereços de memória (facilita manutenção)
3. **Documentar** o uso de cada endereço no código
4. **Validar limites** antes de escrever valores
5. **Usar timeouts** em loops de leitura/escrita
6. **Evitar polling excessivo** - use timers apropriados
7. **Tratar erros** adequadamente

---

## Observações Importantes

1. **Endereços LW e LB**: São voláteis e perdem valores ao desligar a IHM (a menos que configurado para retenção)
2. **Performance**: Evite ler/escrever muitos endereços em um único ciclo
3. **Sincronização**: Use bits de handshake ao comunicar com PLC
4. **Timeout**: Operações de leitura/escrita podem falhar em caso de problemas de comunicação

---

## Compatibilidade

- **i/HMI+ series**: ✓
- **ie series**: ✓
- **ig series**: ✓
- **HMI V2.0**: ✓

---

**Referência Oficial:** [PIStudio Lua Script Documentation](https://docs.we-con.com.cn/bin/view/PIStudio/09%20Lua%20Editor/Lua%20Script/)
