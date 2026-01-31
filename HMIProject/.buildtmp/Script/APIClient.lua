-- Classe APIClient para consultar a API
APIClient = {}
APIClient.__index = APIClient

-- Carregar módulos conforme documentação do PIStudio
-- Usando apenas HTTP (HTTPS não é suportado)
local http = require("socket.http") -- Para requisições HTTP

-- UUID da planta (hardcoded)
local PLANTA_UUID = "6e1c1fd1-f104-4172-bbd9-1f5a7e90e874" -- TODO: Definir UUID real da planta

-- Token da API da planta (deve ser configurado)
local PLANTA_API_TOKEN = "T7pcp1FXmE65nBM35fQgRQ-zZu1-6ndwUeS5g1Ijx7opQ" -- TODO: Configurar o token gerado na API

-- Construtor
function APIClient:new(baseURL, apiToken)
    print("[DEBUG] === INÍCIO DA CRIACAO API ===")
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
    print("[DEBUG] === INÍCIO DA REQUISIÇÃO HTTP ===")
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
    
    -- Para GET: usar sintaxe completa com headers (sem source/sink = sem ltn12)
    if method == "GET" then
        print("[DEBUG] Preparando requisição GET...")
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
            method = "GET",
            headers = headers
        }
        
        print("[DEBUG] Resposta recebida:")
        print("[DEBUG]   Status Code: " .. tostring(status_code))
        print("[DEBUG]   Status: " .. tostring(status))
        print("[DEBUG]   Response Body (primeiros 200 chars): " .. string.sub(tostring(response_body or ""), 1, 200))
        
        if status_code == 200 or status_code == 201 then
            print("[DEBUG] Status OK, tentando decodificar JSON...")
            local success, decoded = pcall(json.decode, response_body or "")
            if success and decoded then
                print("[DEBUG] JSON decodificado com sucesso")
                print("[DEBUG] === FIM DA REQUISIÇÃO HTTP (SUCESSO) ===")
                return true, decoded, status_code
            else
                print("[DEBUG] ERRO ao decodificar JSON")
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
        
        print("[DEBUG] Resposta recebida:")
        print("[DEBUG]   Status Code: " .. tostring(status_code))
        print("[DEBUG]   Status: " .. tostring(status))
        print("[DEBUG]   Response Body (primeiros 200 chars): " .. string.sub(tostring(response_body or ""), 1, 200))
        
        if status_code == 200 or status_code == 201 then
            print("[DEBUG] Status OK, tentando decodificar JSON...")
            local success, decoded = pcall(json.decode, response_body or "")
            if success and decoded then
                print("[DEBUG] JSON decodificado com sucesso")
                print("[DEBUG] === FIM DA REQUISIÇÃO HTTP (SUCESSO) ===")
                return true, decoded, status_code
            else
                print("[DEBUG] ERRO ao decodificar JSON")
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

-- Função para receber todos os motores da planta
function APIClient:ReceberPlanta()
    print("=== TESTE DE API ===")
    print("[ReceberPlanta] Iniciando...")
    
    local endpoint = "/api/plantas/" .. self.PlantaUUID .. "/motores"
    print("[ReceberPlanta] Endpoint: " .. endpoint)
    print("[ReceberPlanta] URL completa: " .. self.BaseURL .. endpoint)
    print("[ReceberPlanta] Token: " .. (self.ApiToken and string.sub(self.ApiToken, 1, 10) .. "..." or "Não configurado"))
    print("[ReceberPlanta] Chamando httpRequest...")
    
    local success, data, status_code = self:httpRequest("GET", endpoint)
    
    print("[ReceberPlanta] httpRequest retornou:")
    print("[ReceberPlanta]   success: " .. tostring(success))
    print("[ReceberPlanta]   status_code: " .. tostring(status_code))
    print("[ReceberPlanta]   data type: " .. type(data))
    if type(data) == "string" then
        print("[ReceberPlanta]   data (primeiros 200 chars): " .. string.sub(data, 1, 200))
    end
    
    if success then
        -- Converter os dados recebidos em objetos Motor
        local motores = {}
        if data and type(data) == "table" then
            print("Resposta recebida: " .. tostring(#data) .. " motores")
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
                
                table.insert(motores, motor)
            end
        else
            print("AVISO: Resposta não é uma tabela. Tipo: " .. type(data))
        end
        return true, motores
    else
        -- Tratamento de erros com mensagens detalhadas
        print("[ReceberPlanta] ERRO DETECTADO!")
        print("[ReceberPlanta] data type: " .. type(data))
        print("[ReceberPlanta] data value: " .. tostring(data))
        print("[ReceberPlanta] status_code: " .. tostring(status_code))
        
        local errorMsg = tostring(data or "Erro desconhecido")
        print("[ReceberPlanta] ERRO HTTP " .. tostring(status_code or "?") .. ": " .. errorMsg)
        
        if type(data) == "string" then
            print("[ReceberPlanta] Analisando mensagem de erro...")
            if string.find(data, "401") or string.find(data, "Unauthorized") then
                errorMsg = errorMsg .. " (Token inválido ou ausente)"
            elseif string.find(data, "404") or string.find(data, "Not Found") then
                errorMsg = errorMsg .. " (Endpoint não encontrado - verifique UUID da planta)"
            elseif string.find(data, "500") or string.find(data, "Internal Server Error") then
                errorMsg = errorMsg .. " (Erro no servidor - verifique logs da API)"
            end
        end
        
        print("[ReceberPlanta] Retornando erro: " .. errorMsg)
        return false, errorMsg
    end
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

return APIClient
