-- Classe APIClient para consultar a API
APIClient = {}
APIClient.__index = APIClient

-- Carregar módulos conforme documentação do PIStudio
local http = require("socket.http") -- Load the http module and everything it needs
local ltn12 = require("ltn12") -- Auxiliary module for http requests

-- UUID da planta (hardcoded)
local PLANTA_UUID = "6e1c1fd1-f104-4172-bbd9-1f5a7e90e874" -- TODO: Definir UUID real da planta

-- Token da API da planta (deve ser configurado)
local PLANTA_API_TOKEN = nil -- TODO: Configurar o token gerado na API

-- Construtor
function APIClient:new(baseURL, apiToken)
    local obj = {}
    setmetatable(obj, APIClient)
    
    obj.BaseURL = baseURL or "https://api.motores.automais.io"
    obj.PlantaUUID = PLANTA_UUID
    obj.ApiToken = apiToken or PLANTA_API_TOKEN
    obj.Timeout = 30 -- segundos
    
    return obj
end

-- Função para fazer requisição HTTP (usando API do PIStudio)
function APIClient:httpRequest(method, endpoint, data)
    -- Conforme documentação do PIStudio: local http = require("socket.http")
    -- json.encode e json.decode estão disponíveis globalmente no PIStudio
    
    local url = self.BaseURL .. endpoint
    local request_data = ""
    
    if data then
        -- Usando json.encode global do PIStudio
        request_data = json.encode(data)
    end
    
    -- Preparar headers conforme API do PIStudio
    local headers = {
        ["Content-Type"] = "application/json"
    }
    
    -- Adicionar token de autenticação se disponível
    if self.ApiToken and string.len(self.ApiToken) > 0 then
        headers["Authorization"] = "Bearer " .. self.ApiToken
    end
    
    if request_data and string.len(request_data) > 0 then
        headers["Content-Length"] = string.len(request_data)
    end
    
    -- Usar http.request() do módulo socket.http
    -- A API do PIStudio pode usar formato similar ao LuaSocket padrão
    local status_code, response_body_str, response_headers
    
    if not http or not http.request then
        return false, "Módulo HTTP não foi carregado corretamente"
    end
    
    -- Usar http.request() conforme documentação do PIStudio
    -- Formato padrão do LuaSocket: http.request{url=..., method=..., headers=..., source=..., sink=...}
    -- Retorno: body, code, headers, status
    local response_body = {}
    
    local body_result, code_result, headers_result, status_result = http.request{
        url = url,
        method = method,
        headers = headers,
        source = request_data and ltn12.source.string(request_data) or nil,
        sink = ltn12.sink.table(response_body)
    }
    
    -- http.request retorna: body (ou 1 se sucesso com sink), code, headers, status
    -- Com sink.table, body_result será 1 se sucesso, e os dados estarão em response_body
    if body_result == 1 then
        -- Sucesso - dados estão em response_body
        status_code = code_result or 200
        response_body_str = table.concat(response_body)
        response_headers = headers_result
    else
        -- Erro na requisição
        return false, "Erro na requisição HTTP: " .. tostring(code_result or "desconhecido")
    end
    
    if status_code == 200 or status_code == 201 then
        local response_text = response_body_str or ""
        local success, decoded = pcall(json.decode, response_text)
        if success and decoded then
            return true, decoded, status_code
        else
            return false, "Erro ao decodificar JSON: " .. response_text, status_code
        end
    else
        return false, "Erro HTTP: " .. tostring(status_code), status_code
    end
end

-- Função para receber todos os motores da planta
function APIClient:ReceberPlanta()
    local endpoint = "/api/plantas/" .. self.PlantaUUID .. "/motores"
    
    local success, data, status_code = self:httpRequest("GET", endpoint)
    
    if success then
        -- Converter os dados recebidos em objetos Motor
        local motores = {}
        if data and type(data) == "table" then
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
        end
        return true, motores
    else
        return false, data -- data contém a mensagem de erro
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
