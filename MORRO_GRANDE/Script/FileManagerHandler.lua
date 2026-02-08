-- Hander para processar comandos de arquivo recebidos via socket
-- Integra FileMaager com SocketClient para comunicação bidirecional
FileManagerHandler = {}
FileManagerHandler.__index = FileManagerHandler

-- Construtor
function FileManagerHandler:new(fileManager, socketClient)
    local obj = {}
    setmetatable(obj, FileManagerHandler)
    
    obj.FileManager = fileManager
    obj.SocketClient = socketClient
    
    return obj
end

-- Função auxiliar para codificar string em Base64
-- Necessário para enviar conteúdo binário via JSON
function FileManagerHandler:Base64Encode(data)
    -- Tabela Base64
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    local result = {}
    local dataLen = string.len(data)
    
    -- Processar em grupos de 3 bytes
    for i = 1, dataLen, 3 do
        local byte1 = string.byte(data, i) or 0
        local byte2 = string.byte(data, i + 1) or 0
        local byte3 = string.byte(data, i + 2) or 0
        
        -- Combinar os 3 bytes em um número de 24 bits
        local combined = byte1 * 65536 + byte2 * 256 + byte3
        
        -- Extrair 4 grupos de 6 bits cada
        local b1 = math.floor(combined / 262144) % 64 + 1
        local b2 = math.floor(combined / 4096) % 64 + 1
        local b3 = math.floor(combined / 64) % 64 + 1
        local b4 = combined % 64 + 1
        
        -- Converter para caracteres Base64
        table.insert(result, string.sub(b, b1, b1))
        table.insert(result, string.sub(b, b2, b2))
        
        if i + 1 <= dataLen then
            table.insert(result, string.sub(b, b3, b3))
        else
            table.insert(result, '=')
        end
        
        if i + 2 <= dataLen then
            table.insert(result, string.sub(b, b4, b4))
        else
            table.insert(result, '=')
        end
    end
    
    return table.concat(result)
end

-- Função para processar comando recebido via socket
-- Recebe comando já decodificado (tabela Lua)
function FileManagerHandler:ProcessarComando(comando)
    if not comando then
        return {
            sucesso = false,
            erro = "Comando vazio"
        }
    end
    
    -- Se receber string JSON, decodificar
    if type(comando) == "string" then
        local decoded, err = json.decode(comando)
        if not decoded then
            return {
                sucesso = false,
                erro = "Erro ao decodificar JSON: " .. tostring(err)
            }
        end
        comando = decoded
    end
    
    if not comando.acao then
        return {
            sucesso = false,
            erro = "Comando sem ação especificada"
        }
    end
    
    local acao = comando.acao
    print("[FileManagerHandler] Processando comando: " .. tostring(acao) .. " (RequestId: " .. tostring(comando.requestId or "sem ID") .. ")")
    
    local resultado = {}
    resultado.acao = acao
    resultado.requestId = comando.requestId or ""
    resultado.sucesso = false
    
    -- Processar diferentes ações
    if acao == "listar" then
        -- Normalizar path recebido (pode vir como path, Path, ou caminho)
        local path = comando.path or comando.Path or comando.caminho or "/flash"
        
        -- Normalizar caminho considerando paths especiais da IHM (sdcard:, udisk:, /flash)
        -- O FileManager já faz isso internamente, mas vamos garantir que está correto
        print("[FileManagerHandler] Listando arquivos em: " .. tostring(path))
        local lista, err = self.FileManager:ListarArquivos(path)
        if lista then
            resultado.sucesso = true
            resultado.dados = {
                arquivos = lista.arquivos,
                diretorios = lista.diretorios,
                totalArquivos = lista.totalArquivos,
                totalDiretorios = lista.totalDiretorios
            }
            print("[FileManagerHandler] ✓ Listagem concluída: " .. lista.totalArquivos .. " arquivos, " .. lista.totalDiretorios .. " diretórios")
        else
            resultado.sucesso = false
            resultado.erro = tostring(err)
            print("[FileManagerHandler] ✗ Erro ao listar: " .. tostring(err))
        end
        
    elseif acao == "listar_bancos" then
        print("[FileManagerHandler] Listando bancos de dados...")
        local bancos = self.FileManager:ListarBancosDadosDetalhado()
        resultado.sucesso = true
        resultado.dados = bancos or {}
        print("[FileManagerHandler] ✓ Encontrados " .. (#bancos or 0) .. " bancos de dados")
        
    elseif acao == "ler" then
        -- Normalizar caminho (pode vir como caminho, Caminho, ou path)
        local caminho = comando.caminho or comando.Caminho or comando.path or comando.Path
        if not caminho then
            print("[FileManagerHandler] ✗ Erro: Caminho não especificado para leitura")
            resultado.sucesso = false
            resultado.erro = "Caminho não especificado"
        else
            print("[FileManagerHandler] Lendo arquivo: " .. tostring(caminho))
            -- FileManager já normaliza internamente, mas garantir que recebe o caminho correto
            local conteudo, err = self.FileManager:LerArquivoTexto(caminho)
            if conteudo then
                local tamanho = string.len(conteudo)
                print("[FileManagerHandler] ✓ Arquivo lido com sucesso: " .. tostring(tamanho) .. " bytes")
                
                -- Codificar conteúdo em Base64 para enviar via JSON (arquivos binários não podem ir direto no JSON)
                local conteudoBase64 = self:Base64Encode(conteudo)
                print("[FileManagerHandler] Conteúdo codificado em Base64: " .. tostring(string.len(conteudoBase64)) .. " caracteres")
                
                resultado.sucesso = true
                resultado.dados = {
                    caminho = caminho,
                    conteudo = conteudoBase64,  -- Enviar Base64 em vez de binário
                    tamanho = tamanho,
                    base64 = true  -- Flag para indicar que está em Base64
                }
            else
                print("[FileManagerHandler] ✗ Erro ao ler arquivo: " .. tostring(err))
                resultado.sucesso = false
                resultado.erro = tostring(err)
            end
        end
        
    elseif acao == "apagar" then
        -- Normalizar caminho (pode vir como caminho, Caminho, ou path)
        local caminho = comando.caminho or comando.Caminho or comando.path or comando.Path
        if not caminho then
            print("[FileManagerHandler] ✗ Erro: Caminho não especificado para apagar")
            resultado.sucesso = false
            resultado.erro = "Caminho não especificado"
        else
            print("[FileManagerHandler] Apagando arquivo: " .. tostring(caminho))
            local sucesso, err = self.FileManager:ApagarArquivo(caminho)
            resultado.sucesso = sucesso
            if not sucesso then
                print("[FileManagerHandler] ✗ Erro ao apagar arquivo: " .. tostring(err))
                resultado.erro = tostring(err)
            else
                print("[FileManagerHandler] ✓ Arquivo apagado com sucesso: " .. tostring(caminho))
                resultado.dados = { caminho = caminho }
            end
        end
        
    elseif acao == "salvar" then
        -- Normalizar caminho (pode vir como caminho, Caminho, ou path)
        local caminho = comando.caminho or comando.Caminho or comando.path or comando.Path
        local conteudo = comando.conteudo or comando.Conteudo
        if not caminho then
            print("[FileManagerHandler] ✗ Erro: Caminho não especificado para salvar")
            resultado.sucesso = false
            resultado.erro = "Caminho não especificado"
        elseif not conteudo then
            print("[FileManagerHandler] ✗ Erro: Conteúdo não especificado para salvar")
            resultado.sucesso = false
            resultado.erro = "Conteúdo não especificado"
        else
            local tamanhoConteudo = string.len(conteudo)
            print("[FileManagerHandler] Salvando arquivo: " .. tostring(caminho) .. " (" .. tostring(tamanhoConteudo) .. " bytes)")
            -- Usar flash.file_write para salvar arquivo
            -- Conforme documentação: flash.file_write(path, content)
            local success, err = pcall(function()
                return flash.file_write(caminho, conteudo)
            end)
            
            if success then
                print("[FileManagerHandler] ✓ Arquivo salvo com sucesso: " .. tostring(caminho))
                resultado.sucesso = true
                resultado.dados = { caminho = caminho }
            else
                print("[FileManagerHandler] ✗ Erro ao salvar arquivo: " .. tostring(err))
                resultado.sucesso = false
                resultado.erro = "Erro ao salvar arquivo: " .. tostring(err)
            end
        end
        
    elseif acao == "info" then
        -- Normalizar caminho (pode vir como caminho, Caminho, ou path)
        local caminho = comando.caminho or comando.Caminho or comando.path or comando.Path
        if not caminho then
            print("[FileManagerHandler] ✗ Erro: Caminho não especificado para obter informações")
            resultado.sucesso = false
            resultado.erro = "Caminho não especificado"
        else
            print("[FileManagerHandler] Obtendo informações do arquivo: " .. tostring(caminho))
            local info, err = self.FileManager:ObterInformacoesArquivo(caminho)
            if info then
                print("[FileManagerHandler] ✓ Informações obtidas: " .. tostring(info.nome) .. " (" .. tostring(info.tamanho) .. " bytes)")
                resultado.sucesso = true
                resultado.dados = info
            else
                print("[FileManagerHandler] ✗ Erro ao obter informações: " .. tostring(err))
                resultado.sucesso = false
                resultado.erro = tostring(err)
            end
        end
        
    else
        resultado.sucesso = false
        resultado.erro = "Ação não reconhecida: " .. tostring(acao)
    end
    
    return resultado
end

-- Função para enviar resposta via socket
function FileManagerHandler:EnviarResposta(resultado)
    if not self.SocketClient or not self.SocketClient:EstaConectado() then
        print("[FileManagerHandler] ⚠ Socket não conectado, não é possível enviar resposta")
        return false
    end
    
    local respostaJson = json.encode(resultado)
    local sucesso, err = self.SocketClient:EnviarMensagem(respostaJson)
    
    if not sucesso then
        print("[FileManagerHandler] ✗ Erro ao enviar resposta: " .. tostring(err))
    end
    
    return sucesso
end

return FileManagerHandler
