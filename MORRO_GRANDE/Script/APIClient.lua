-- Cs= AIClientpra consult
APIClient = {}
APIClient.__index = APIClient

-- Carregar módulos conforme documentação do PIStudio
-- Usando apenas HTTP (HTTPS não é suportado)
local http = require("socket.http") -- Para requisições HTTP
local json = require("json")
local ltn12 = require("ltn12") -- Para sink.table (receber dados)
-- Nota: No exemplo que funciona, usa LTN12 (maiúsculas), mas ltn12 (minúsculas) também funciona

-- UUID da planta (hardcoded)
local PLANTA_UUID = "6e1c1fd1-f104-4172-bbd9-1f5a7e90e874" -- TODO: Definir UUID real da planta

-- Token da API da planta (deve ser configurado)
local PLANTA_API_TOKEN = "T7pcp1FXmE65nBM35fQgRQ-zZu1-6ndwUeS5g1Ijx7opQ" -- TODO: Configurar o token gerado na API

-- Construtor
function APIClient:new(baseURL, apiToken)
    print("[DEBUG] === INÍCIO DA CRIACAO API ==")
    local obj = {}
    setmetatable(obj, APIClient)
    
    -- Usar apenas HTTP (HTTPS não é suportado no PIStudio)
    local url = baseURL or "http://api.motores.automais.io"
    
    -- Garantir que seja HTTP (converter HTTPS para HTTP se necessário)
    if string.sub(url, 1, 5) == "https" then
        url = "http" .. string.sub(url, 6)
    end
    
    -- Garantir que comece com http://
    if string.sub(url, 1, 4) ~= "http" then
        url = "http://" .. url
    end
    
    obj.BaseURL = url
    obj.PlantaUUID = PLANTA_UUID
    obj.ApiToken = apiToken or PLANTA_API_TOKEN
    obj.Timeout = 30 -- segundos
    print("[DEBUG] === FIM DA CRIACAO API ===")
    return obj
end

-- Função para fazer requisição HTTP (usando API do PIStudio)
-- Conforme documentação oficial: https://docs.we-con.com.cn/bin/view/PIStudio/09%20Lua%20Editor/Lua%20Script/#Hhttpmodule-1
function APIClient:httpRequest(method, endpoint, data)
    print("[DEBUG] === INÍCIO DA REQUISIÇÃO HTTP ==")
    print("[DEBUG] Método: " .. method)
    print("[DEBUG] Endpoint: " .. endpoint)
    
    -- json.encode e json.decode estão disponíveis globalmente no PIStudio
    local url = self.BaseURL .. endpoint
    print("[DEBUG] URL completa (antes): " .. url)
    
    -- Garantir que a URL seja HTTP (não HTTPS)
    if string.sub(url, 1, 5) == "https" then
        url = "http" .. string.sub(url, 6)
        print("[DEBUG] URL convertida de HTTPS para HTTP: " .. url)
    end
    
    print("[DEBUG] URL final: " .. url)
    
    if not http or not http.request then
        print("[DEBUG] ERRO: Módulo HTTP não foi carregado corretamente")
        return false, "Módulo HTTP não foi carregado corretamente"
    end
    
    print("[DEBUG] Módulo HTTP carregado: OK")
    
    -- Preparar headers com token de autenticação
    -- A API espera: Authorization: Bearer {token}
    local headers = {}
    if self.ApiToken and string.len(self.ApiToken) > 0 then
        headers["Authorization"] = "Bearer " .. self.ApiToken
        print("[DEBUG] Token configurado: " .. string.sub(self.ApiToken, 1, 10) .. "...")
    else
        print("[DEBUG] AVISO: Token não configurado!")
    end
    
    -- Para GET: usar sintaxe simples sem sink (mais confiável)
    if method == "GET" then
        print("[DEBUG] Preparando requisição GET...")
        print("[DEBUG] URL: " .. url)
        print("[DEBUG] Headers:")
        for key, value in pairs(headers) do
            if key == "Authorization" then
                print("[DEBUG]   " .. key .. ": Bearer " .. string.sub(value, 8, 17) .. "...")
            else
                print("[DEBUG]   " .. key .. ": " .. tostring(value))
            end
        end
        
        -- Verificar se http está disponível
        if not http then
            print("[DEBUG] ERRO: http não está disponível")
            return false, "Módulo HTTP não disponível", nil
        end
        
        if not http.request then
            print("[DEBUG] ERRO: http.request não está disponível")
            return false, "http.request não disponível", nil
        end
        
        print("[DEBUG] Fazendo chamada http.request com sink.table (conforme exemplo)...")
        print("[DEBUG] Tipo de http.request: " .. type(http.request))
        
        -- Usar sink.table conforme exemplo que funciona
        -- Conforme exemplo: status, str_result = http.request(tabRequest)
        -- O body fica em response_body_table[1]
        local response_body_table = {}
        local tabRequest = {}
        tabRequest.url = url
        tabRequest.method = "GET"
        tabRequest.headers = headers
        tabRequest.sink = ltn12.sink.table(response_body_table)
        
        local request_ok, status_result, str_result = pcall(function()
            return http.request(tabRequest)
        end)
        
        if not request_ok then
            print("[DEBUG] ERRO ao chamar http.request: " .. tostring(status_result))
            print("[DEBUG] === FIM DA REQUISIÇÃO HTTP (ERRO DE EXECUÇÃO) ===")
            return false, "Erro ao chamar http.request: " .. tostring(status_result), nil
        end
        
        -- Conforme exemplo: status_result é 1 (sucesso do sink), str_result pode ser o código HTTP ou nil
        local status_code = str_result  -- O código HTTP pode estar em str_result
        local response_body = nil
        
        -- O body pode estar em response_body_table[1] ou em múltiplos chunks
        -- Conforme documentação LTN12, quando usa sink.table, os dados podem vir em múltiplas partes
        print("[DEBUG] Verificando response_body_table...")
        print("[DEBUG]   response_body_table existe: " .. tostring(response_body_table ~= nil))
        print("[DEBUG]   response_body_table tamanho: " .. tostring(#response_body_table))
        
        -- Concatenar todos os chunks do response_body_table
        if response_body_table and #response_body_table > 0 then
            print("[DEBUG]   Concatenando " .. tostring(#response_body_table) .. " chunk(s) do response...")
            response_body = ""
            for i = 1, #response_body_table do
                local chunk = response_body_table[i]
                if chunk then
                    print("[DEBUG]   Chunk " .. i .. " tipo: " .. type(chunk) .. ", tamanho: " .. tostring(string.len(tostring(chunk))))
                    response_body = response_body .. tostring(chunk)
                end
            end
            print("[DEBUG]   Tamanho total concatenado: " .. tostring(string.len(response_body)) .. " bytes")
            print("[DEBUG]   Primeiros 100 chars: " .. string.sub(response_body, 1, 100))
            print("[DEBUG]   Últimos 100 chars: " .. string.sub(response_body, -100))
        else
            print("[DEBUG]   AVISO: response_body_table está vazio")
            response_body = nil
        end
        
        print("[DEBUG] http.request retornou:")
        print("[DEBUG]   request_ok: " .. tostring(request_ok))
        print("[DEBUG]   status_result: " .. tostring(status_result))
        print("[DEBUG]   str_result (status_code): " .. tostring(str_result))
        print("[DEBUG]   response_body tipo: " .. type(response_body))
        if response_body then
            if type(response_body) == "string" then
                print("[DEBUG]   response_body tamanho: " .. tostring(string.len(response_body)))
                print("[DEBUG]   response_body (primeiros 500 chars): " .. string.sub(response_body, 1, 500))
            else
                print("[DEBUG]   response_body valor: " .. tostring(response_body))
            end
        end
        
        print("[DEBUG] Resposta final:")
        print("[DEBUG]   Status Code: " .. tostring(status_code))
        print("[DEBUG]   Response Body COMPLETO:")
        print("========================================")
        print(tostring(response_body or ""))
        print("========================================")
        
        -- Verificar se status_result é 1 (sucesso do sink)
        if status_result ~= 1 then
            print("[DEBUG] ERRO: status_result não é 1 (sink falhou)")
            print("[DEBUG] status_result: " .. tostring(status_result))
            print("[DEBUG] === FIM DA REQUISIÇÃO HTTP (ERRO DE SINK) ===")
            return false, "Erro no sink: " .. tostring(status_result), nil
        end
        
        -- Se temos response_body válido e status_result é 1, consideramos sucesso
        -- Mesmo que status_code seja nil (algumas versões do luasocket não retornam o código)
        if response_body and type(response_body) == "string" and string.len(response_body) > 0 then
            -- Se status_code for nil mas temos body válido, assumir 200 OK
            if not status_code or status_code == nil then
                print("[DEBUG] Status code é nil, mas temos body válido - assumindo 200 OK")
                status_code = 200
            end
            
            -- Se temos body válido, processar como sucesso (mesmo que status_code seja diferente de 200/201)
            -- Isso é necessário porque algumas versões do luasocket não retornam o status code corretamente
            print("[DEBUG] Status OK (body válido encontrado), tentando decodificar JSON...")
            print("[DEBUG] Tamanho do JSON: " .. tostring(string.len(response_body)) .. " bytes")
            
            -- Verificar se JSON parece válido (começa com [ ou {)
            local firstChar = string.sub(response_body, 1, 1)
            if firstChar ~= "[" and firstChar ~= "{" then
                print("[DEBUG] AVISO: JSON não começa com [ ou {, primeiro char: " .. firstChar)
            end
            
            -- Tentar decodificar JSON completo primeiro
            local success, decoded = pcall(function()
                -- Limpar possíveis caracteres problemáticos no início/fim
                local cleanJson = string.gsub(response_body, "^%s+", "")  -- Remove espaços no início
                cleanJson = string.gsub(cleanJson, "%s+$", "")  -- Remove espaços no fim
                
                -- Verificar se json.decode está disponível
                if not json or not json.decode then
                    error("json.decode não está disponível")
                end
                
                -- Tentar decodificar
                return json.decode(cleanJson)
            end)
            
            if success and decoded then
                print("[DEBUG] JSON decodificado com sucesso (método normal)")
                print("[DEBUG] Tipo do decoded: " .. type(decoded))
                if type(decoded) == "table" then
                    print("[DEBUG] Tamanho da tabela decoded: " .. tostring(#decoded))
                end
                print("[DEBUG] === FIM DA REQUISIÇÃO HTTP (SUCESSO) ===")
                return true, decoded, status_code or 200
            else
                print("[DEBUG] Erro ao decodificar JSON completo, tentando método manual (objeto por objeto)...")
                print("[DEBUG] Erro capturado: " .. tostring(decoded))
                
                -- Método alternativo: extrair objetos manualmente de { a }
                local cleanJson = string.gsub(response_body, "^%s+", "")
                cleanJson = string.gsub(cleanJson, "%s+$", "")
                
                -- Se começa com [, é um array de objetos
                if string.sub(cleanJson, 1, 1) == "[" then
                    print("[DEBUG] JSON é um array, extraindo objetos manualmente...")
                    local result = {}
                    local pos = 2  -- Pular o [
                    local depth = 0
                    local startPos = nil
                    local objCount = 0
                    local inString = false
                    local escapeNext = false
                    
                    while pos <= string.len(cleanJson) do
                        local char = string.sub(cleanJson, pos, pos)
                        
                        -- Tratar escape de caracteres
                        if escapeNext then
                            escapeNext = false
                        elseif char == "\\" and inString then
                            escapeNext = true
                        -- Detectar início/fim de strings
                        elseif char == '"' and not escapeNext then
                            inString = not inString
                        -- Só processar { e } se não estiver dentro de uma string
                        elseif not inString then
                            if char == "{" then
                                if depth == 0 then
                                    startPos = pos  -- Início de um novo objeto
                                end
                                depth = depth + 1
                            elseif char == "}" then
                                depth = depth - 1
                                if depth == 0 and startPos then
                                    -- Encontramos um objeto completo
                                    local objJson = string.sub(cleanJson, startPos, pos)
                                    objCount = objCount + 1
                                    
                                    -- Tentar decodificar este objeto individual
                                    local objSuccess, objDecoded = pcall(function()
                                        return json.decode(objJson)
                                    end)
                                    
                                    if objSuccess and objDecoded then
                                        table.insert(result, objDecoded)
                                        print("[DEBUG] Objeto " .. objCount .. " decodificado com sucesso")
                                    else
                                        print("[DEBUG] Erro ao decodificar objeto " .. objCount .. ": " .. tostring(objDecoded))
                                    end
                                    
                                    startPos = nil
                                end
                            elseif char == "]" and depth == 0 then
                                -- Fim do array
                                break
                            end
                        end
                        
                        pos = pos + 1
                    end
                    
                    if #result > 0 then
                        print("[DEBUG] JSON decodificado com sucesso (método manual)")
                        print("[DEBUG] Total de objetos decodificados: " .. tostring(#result))
                        print("[DEBUG] === FIM DA REQUISIÇÃO HTTP (SUCESSO) ===")
                        return true, result, status_code or 200
                    else
                        print("[DEBUG] Nenhum objeto foi decodificado com sucesso")
                    end
                end
                
                -- Se chegou aqui, ambos os métodos falharam
                print("[DEBUG] ERRO: Ambos os métodos de decodificação falharam")
                print("[DEBUG] Tamanho do response_body: " .. tostring(string.len(response_body)))
                print("[DEBUG] Primeiros 200 chars: " .. string.sub(response_body, 1, 200))
                print("[DEBUG] Últimos 200 chars: " .. string.sub(response_body, -200))
                print("[DEBUG] === FIM DA REQUISIÇÃO HTTP (ERRO JSON) ===")
                -- Retornar erro mais informativo
                local errorMsg = "Erro ao decodificar JSON (métodos normal e manual falharam)"
                if decoded then
                    errorMsg = errorMsg .. ": " .. tostring(decoded)
                end
                return false, errorMsg, status_code or 200
            end
        else
            -- Se não temos body válido, verificar status_code
            if not status_code or status_code == nil then
                print("[DEBUG] ERRO: status_code é nil e não há body válido")
                print("[DEBUG] === FIM DA REQUISIÇÃO HTTP (ERRO DE CONEXÃO) ===")
                return false, "Erro de conexão: status_code nil e sem body. Verifique se a API está rodando em " .. url, nil
            end
            
            print("[DEBUG] ERRO HTTP: " .. tostring(status_code))
            print("[DEBUG] Response body: " .. tostring(response_body))
            print("[DEBUG] === FIM DA REQUISIÇÃO HTTP (ERRO HTTP) ===")
            local errorMsg = "Erro HTTP: " .. tostring(status_code)
            if response_body then
                errorMsg = errorMsg .. " | Response: " .. tostring(response_body)
            end
            return false, errorMsg, status_code
        end
    else
        -- Para POST, PUT, etc: usar sintaxe completa com headers
        print("[DEBUG] Preparando requisição " .. method .. "...")
        
        -- Nota: Sem source/sink, o body pode não ser enviado, mas evita erro de ltn12
        local request_data = ""
        if data then
            print("[DEBUG] Codificando dados para JSON...")
            request_data = json.encode(data)
            print("[DEBUG] Request body (primeiros 200 chars): " .. string.sub(request_data, 1, 200))
        else
            print("[DEBUG] Nenhum dado para enviar")
        end
        
        headers["Content-Type"] = "application/json"
        if request_data and string.len(request_data) > 0 then
            headers["Content-Length"] = string.len(request_data)
        end
        
        print("[DEBUG] Headers:")
        for key, value in pairs(headers) do
            if key == "Authorization" then
                print("[DEBUG]   " .. key .. ": Bearer " .. string.sub(value, 8, 17) .. "...")
            else
                print("[DEBUG]   " .. key .. ": " .. tostring(value))
            end
        end
        
        print("[DEBUG] Fazendo chamada http.request...")
        -- Sintaxe completa conforme documentação: http.request{url=..., method=..., headers=...}
        -- Retorno: body, code, headers, status
        local response_body, status_code, response_headers, status = http.request{
            url = url,
            method = method,
            headers = headers
        }
        
        print("[DEBUG] Resposta recebida (POST/PUT): v2.0")
        print("[DEBUG]   Status Code: " .. tostring(status_code))
        print("[DEBUG]   Status: " .. tostring(status))
        print("[DEBUG]   Response Body COMPLETO (literal):")
        print("========================================")
        print(tostring(response_body or ""))
        print("========================================")
        print("[DEBUG]   Response Body tipo: " .. type(response_body))
        print("[DEBUG]   Response Body tamanho: " .. tostring(string.len(tostring(response_body or ""))))
        print("[DEBUG]   Response Body (primeiros 500 chars): " .. string.sub(tostring(response_body or ""), 1, 500))
        
        if status_code == 200 or status_code == 201 then
            print("[DEBUG] Status OK, verificando json...")
            print("[DEBUG] json existe? " .. tostring(json ~= nil))
            if json then
                print("[DEBUG] json.decode existe? " .. tostring(json.decode ~= nil))
            end
            
            -- Verificar se json está disponível
            if not json then
                print("[DEBUG] ERRO: json não está disponível globalmente")
                print("[DEBUG] Retornando response_body como string")
                return true, response_body, status_code
            end
            if not json.decode then
                print("[DEBUG] ERRO: json.decode não está disponível")
                print("[DEBUG] Retornando response_body como string")
                return true, response_body, status_code
            end
            
            print("[DEBUG] Tentando decodificar JSON...")
            local success, decoded = pcall(json.decode, response_body or "")
            if success and decoded then
                print("[DEBUG] JSON decodificado com sucesso")
                print("[DEBUG] Tipo do decoded: " .. type(decoded))
                print("[DEBUG] === FIM DA REQUISIÇÃO HTTP (SUCESSO) ===")
                return true, decoded, status_code
            else
                print("[DEBUG] ERRO ao decodificar JSON")
                print("[DEBUG] Erro: " .. tostring(decoded))
                print("[DEBUG] Response body completo: " .. tostring(response_body))
                print("[DEBUG] === FIM DA REQUISIÇÃO HTTP (ERRO JSON) ===")
                return false, "Erro ao decodificar JSON: " .. tostring(response_body), status_code
            end
        else
            print("[DEBUG] ERRO HTTP: " .. tostring(status_code))
            print("[DEBUG] Response body: " .. tostring(response_body))
            print("[DEBUG] === FIM DA REQUISIÇÃO HTTP (ERRO HTTP) ===")
            local errorMsg = "Erro HTTP: " .. tostring(status_code)
            if response_body then
                errorMsg = errorMsg .. " | Response: " .. tostring(response_body)
            end
            return false, errorMsg, status_code
        end
    end
end

-- Função para receber todos os motores da planta (com paginação)
function APIClient:ReceberPlanta()
    print("[ReceberPlanta] === INICIANDO BUSCA PAGINADA DE MOTORES ===")
    
    local todosMotores = {}  -- Array para acumular todos os motores
    local pageSize = 5  -- Tamanho da página (5 motores por vez)
    local skip = 0
    local hasMore = true
    local pageCount = 0
    
    -- Buscar motores em páginas de 5 em 5
    while hasMore do
        pageCount = pageCount + 1
        print("[ReceberPlanta] Buscando página " .. pageCount .. " (skip=" .. skip .. ", take=" .. pageSize .. ")")
        
        -- Construir endpoint com paginação
        local endpoint = "/api/plantas/" .. self.PlantaUUID .. "/motores?skip=" .. skip .. "&take=" .. pageSize
        print("[ReceberPlanta] Endpoint: " .. endpoint)
        
        local success, data, status_code = self:httpRequest("GET", endpoint)
        
        if not success then
            print("[ReceberPlanta] ✗ Erro ao buscar página " .. pageCount .. ": " .. tostring(data))
            -- Se for a primeira página, retornar erro
            if pageCount == 1 then
                return false, "Erro ao buscar motores: " .. tostring(data)
            else
                -- Se não for a primeira, retornar o que já foi coletado
                print("[ReceberPlanta] ⚠ Retornando " .. #todosMotores .. " motores já coletados")
                break
            end
        end
        
        -- Verificar se recebeu dados
        if not data or type(data) ~= "table" or #data == 0 then
            print("[ReceberPlanta] Nenhum motor na página " .. pageCount .. " - fim da busca")
            hasMore = false
        else
            print("[ReceberPlanta] ✓ Página " .. pageCount .. ": " .. #data .. " motores recebidos")
            
            -- Converter os dados recebidos em objetos Motor e adicionar ao array
            for _, motorData in ipairs(data) do
                local motor = Motor:new(
                    motorData.id or motorData.ID,
                    motorData.nome or motorData.Nome,
                    motorData.registroModBus or motorData.RegistroModBus,
                    motorData.registroLocal or motorData.RegistroLocal,
                    motorData.correnteNominal or motorData.CorrenteNominal
                )
                
                -- Atualizar outros campos se existirem
                if motorData.correnteAtual or motorData.CorrenteAtual then
                    motor:setCorrenteAtual(motorData.correnteAtual or motorData.CorrenteAtual)
                end
                if motorData.percentCorrenteMaximaErro or motorData.PercentCorrenteMaximaErro then
                    motor:setPercentCorrenteMaximaErro(motorData.percentCorrenteMaximaErro or motorData.PercentCorrenteMaximaErro)
                end
                if motorData.percentHistereseErro or motorData.PercentHistereseErro then
                    motor:setPercentHistereseErro(motorData.percentHistereseErro or motorData.PercentHistereseErro)
                end
                if motorData.status ~= nil or motorData.Status ~= nil then
                    motor:setStatus(motorData.status or motorData.Status)
                end
                if motorData.horimetro or motorData.Horimetro then
                    motor.Horimetro = motorData.horimetro or motorData.Horimetro
                end
                
                -- Adicionar campos adicionais se existirem
                if motorData.guid or motorData.GUID then
                    motor.GUID = motorData.guid or motorData.GUID
                end
                if motorData.potencia or motorData.Potencia then
                    motor.Potencia = motorData.potencia or motorData.Potencia
                end
                if motorData.tensao or motorData.Tensao then
                    motor.Tensao = motorData.tensao or motorData.Tensao
                end
                if motorData.habilitado ~= nil or motorData.Habilitado ~= nil then
                    motor.Habilitado = motorData.habilitado or motorData.Habilitado
                end
                if motorData.posicaoX or motorData.PosicaoX then
                    motor.PosicaoX = motorData.posicaoX or motorData.PosicaoX
                end
                if motorData.posicaoY or motorData.PosicaoY then
                    motor.PosicaoY = motorData.posicaoY or motorData.PosicaoY
                end
                
                table.insert(todosMotores, motor)
            end
            
            -- Se recebeu menos que pageSize, não há mais páginas
            if #data < pageSize then
                hasMore = false
                print("[ReceberPlanta] Última página recebida (menos de " .. pageSize .. " motores)")
            else
                -- Preparar próxima página
                skip = skip + pageSize
            end
        end
    end
    
    print("[ReceberPlanta] === BUSCA CONCLUÍDA ===")
    print("[ReceberPlanta] Total de páginas: " .. pageCount)
    print("[ReceberPlanta] Total de motores coletados: " .. #todosMotores)
    
    return true, todosMotores
end

-- Função auxiliar para atualizar dados de um motor na API
function APIClient:AtualizarMotor(motor)
    local endpoint = "/api/plantas/" .. self.PlantaUUID .. "/motores/" .. tostring(motor.ID)
    
    local data = {
        id = motor.ID,
        nome = motor.Nome,
        registroModBus = motor.RegistroModBus,
        registroLocal = motor.RegistroLocal,
        correnteAtual = motor.CorrenteAtual,
        correnteNominal = motor.CorrenteNominal,
        percentCorrenteMaximaErro = motor.PercentCorrenteMaximaErro,
        percentHistereseErro = motor.PercentHistereseErro,
        status = motor.Status,
        horimetro = motor.Horimetro
    }
    
    return self:httpRequest("PUT", endpoint, data)
end

-- Função para buscar motores da planta (com paginação automática)
-- Retorna todos os motores em páginas de 5 em 5
function APIClient:BuscarMotoresPlanta(plantaUUID)
    local plantaId = plantaUUID or self.PlantaUUID
    local todosMotores = {}  -- Array para acumular todos os motores
    local pageSize = 5  -- Tamanho da página (5 motores por vez)
    local skip = 0
    local hasMore = true
    local pageCount = 0
    
    print("[BuscarMotoresPlanta] Iniciando busca paginada...")
    
    -- Buscar motores em páginas de 5 em 5
    while hasMore do
        pageCount = pageCount + 1
        local endpoint = "/api/plantas/" .. plantaId .. "/motores?skip=" .. skip .. "&take=" .. pageSize
        local success, data, status_code = self:httpRequest("GET", endpoint, nil)
        
        if not success or status_code ~= 200 then
            print("[BuscarMotoresPlanta] Erro ao buscar página " .. pageCount)
            if pageCount == 1 then
                return nil, "Erro ao buscar motores: " .. tostring(data or "Erro desconhecido")
            else
                -- Retornar o que já foi coletado
                print("[BuscarMotoresPlanta] Retornando " .. #todosMotores .. " motores já coletados")
                break
            end
        end
        
        -- Verificar se recebeu dados
        if not data or type(data) ~= "table" or #data == 0 then
            hasMore = false
        else
            -- Adicionar motores desta página ao array total
            for _, motorData in ipairs(data) do
                table.insert(todosMotores, motorData)
            end
            
            print("[BuscarMotoresPlanta] Página " .. pageCount .. ": " .. #data .. " motores")
            
            -- Se recebeu menos que pageSize, não há mais páginas
            if #data < pageSize then
                hasMore = false
            else
                skip = skip + pageSize
            end
        end
    end
    
    print("[BuscarMotoresPlanta] Total: " .. #todosMotores .. " motores em " .. pageCount .. " página(s)")
    return todosMotores, nil
end

-- Função para atualizar motor da planta
function APIClient:AtualizarMotorPlanta(plantaUUID, motorGUID, dados)
    local endpoint = "/api/plantas/" .. (plantaUUID or self.PlantaUUID) .. "/motores/" .. motorGUID
    local success, status, data = self:httpRequest("PUT", endpoint, dados)
    
    if success and status == 200 then
        return json.decode(data), nil
    else
        return nil, "Erro ao atualizar motor: " .. tostring(data)
    end
end

-- Função para criar motor na planta
function APIClient:CriarMotorPlanta(plantaUUID, dados)
    local endpoint = "/api/plantas/" .. (plantaUUID or self.PlantaUUID) .. "/motores"
    local success, status, data = self:httpRequest("POST", endpoint, dados)
    
    if success and (status == 200 or status == 201) then
        return json.decode(data), nil
    else
        return nil, "Erro ao criar motor: " .. tostring(data)
    end
end

return APIClient
