-- Hanler para processar comandos de banco de dados recebidos via socket
-- Integra SQLiteDB com SocketClient para comunicação bidirecional
DatabaseHandler = {}
DatabaseHandler.__index = DatabaseHandler

-- Construor
function DatabaseHandler:new(sqliteDB, socketClient)
    local obj = {}
    setmetatable(obj, DatabaseHandler)
    
    obj.SQLiteDB = sqliteDB
    obj.SocketClient = socketClient
    
    return obj
end

-- Função para processar comando recebido via socket
-- Recebe comando já decodificado (tabela Lua)
function DatabaseHandler:ProcessarComando(comando)
    if not comando then
        return {
            sucesso = false,
            erro = "Comando vazio",
            requestId = ""
        }
    end
    
    -- Se receber string JSON, decodificar
    if type(comando) == "string" then
        local decoded, err = json.decode(comando)
        if not decoded then
            return {
                sucesso = false,
                erro = "Erro ao decodificar JSON: " .. tostring(err),
                requestId = ""
            }
        end
        comando = decoded
    end
    
    if not comando.acao then
        return {
            sucesso = false,
            erro = "Comando sem ação especificada",
            requestId = comando.requestId or ""
        }
    end
    
    local acao = comando.acao
    print("[DatabaseHandler] Processando comando: " .. tostring(acao) .. " (RequestId: " .. tostring(comando.requestId or "sem ID") .. ")")
    
    local resultado = {}
    resultado.acao = acao
    resultado.requestId = comando.requestId or ""
    resultado.sucesso = false
    
    -- Processar diferentes ações
    if acao == "listarTabelas" then
        print("[DatabaseHandler] Listando tabelas do banco...")
        local tabelas = self.SQLiteDB:ListarTabelasComQuantidade()
        if tabelas then
            resultado.sucesso = true
            resultado.tabelas = tabelas
            resultado.caminhoBanco = self.SQLiteDB:ObterCaminhoBanco()
            print("[DatabaseHandler] ✓ Encontradas " .. (#tabelas or 0) .. " tabelas")
            print("[DatabaseHandler] Caminho do banco: " .. tostring(resultado.caminhoBanco))
        else
            resultado.sucesso = false
            resultado.erro = "Erro ao listar tabelas"
            print("[DatabaseHandler] ✗ Erro ao listar tabelas")
        end
        
    elseif acao == "consultarTabela" then
        local nomeTabela = comando.tabela
        local pagina = comando.pagina or 1
        local tamanhoPagina = comando.tamanhoPagina or 50
        
        if not nomeTabela or nomeTabela == "" then
            resultado.sucesso = false
            resultado.erro = "Nome da tabela não especificado"
            print("[DatabaseHandler] ✗ Erro: Nome da tabela não especificado")
        else
            print(string.format("[DatabaseHandler] Consultando tabela: %s (página %d, tamanho %d)", nomeTabela, pagina, tamanhoPagina))
            local resultadoQuery, err = self.SQLiteDB:ConsultarTabela(nomeTabela, pagina, tamanhoPagina)
            if resultadoQuery then
                resultado.sucesso = true
                resultado.dados = resultadoQuery.dados
                resultado.colunas = resultadoQuery.colunas
                resultado.totalLinhas = resultadoQuery.totalLinhas
                print(string.format("[DatabaseHandler] ✓ Consulta concluída: %d linhas retornadas de %d total", 
                    #resultadoQuery.dados, resultadoQuery.totalLinhas))
            else
                resultado.sucesso = false
                resultado.erro = tostring(err) or "Erro ao consultar tabela"
                print("[DatabaseHandler] ✗ Erro ao consultar: " .. tostring(err))
            end
        end
        
    else
        resultado.sucesso = false
        resultado.erro = "Ação não reconhecida: " .. tostring(acao)
        print("[DatabaseHandler] ✗ Ação não reconhecida: " .. tostring(acao))
    end
    
    return resultado
end

return DatabaseHandler
