-- ClasseFileManager para gerenciamento de arquivos na IHM
-- Funcionaides: listar, ler e apagar arquivos
-- Suporta paths especiais da IHM: sdcard:, udisk:, /flash
FileManager = {}
FileManager.__index = FileManager

-- Paths especiais da IHM conforme documentação do PIStudio
-- sdcard: - Cartão SD
-- udisk: - Disco USB
-- /flash - Flash interno

-- Construtor
function FileManager:new(basePath)
    local obj = {}
    setmetatable(obj, FileManager)
    
    -- Caminho base para operações d arquivo (padrão: /flash)
    -- Pode ser: /flash, sdcard:, udisk:, etc.
    obj.BasePath = basePath or "/flash"
    
    return obj
end

-- Função para verificar se path é especial da IHM (sdcard:, udisk:, /flash, etc.)
local function isSpecialPath(path)
    if not path then
        return false
    end
    
    -- Verificar se começa com prefixo especial (sdcard:, udisk:, flash:)
    local specialPrefixes = {"sdcard:", "udisk:", "flash:"}
    for i, prefix in ipairs(specialPrefixes) do
        if string.sub(path, 1, #prefix) == prefix then
            return true
        end
    end
    
    -- Verificar se começa com /flash (caminho absoluto do flash interno)
    if string.sub(path, 1, 6) == "/flash" then
        return true
    end
    
    return false
end

-- Função para normalizar caminho (suporta paths especiais da IHM)
local function normalizePath(path, basePath)
    if not path then
        return basePath or "/flash"
    end
    
    -- Se é path especial da IHM (sdcard:, udisk:, etc.), normalizar removendo barra após :
    if isSpecialPath(path) then
        -- Se tem barra após os dois pontos (ex: udisk:/arquivo), remover a barra
        -- Formato correto: udisk:arquivo (sem barra após :)
        if string.find(path, ":") then
            local prefix, rest = string.match(path, "([^:]+):(.*)")
            if rest and string.sub(rest, 1, 1) == "/" then
                -- Remover barra inicial após :
                rest = string.sub(rest, 2)
            end
            return prefix .. ":" .. (rest or "")
        end
        return path
    end
    
    -- Se o caminho já começa com /, usar diretamente
    if string.sub(path, 1, 1) == "/" then
        return path
    end
    
    -- Se basePath é especial, concatenar mantendo o prefixo
    if isSpecialPath(basePath) then
        -- Para paths especiais, usar : como separador (ex: sdcard:arquivo.db ou user:ftpTest.dll)
        -- Remover barra inicial do path se houver (ex: /motores.db -> motores.db)
        local cleanPath = path
        if string.sub(path, 1, 1) == "/" then
            cleanPath = string.sub(path, 2)
        end
        
        if string.find(basePath, ":") then
            local prefix, baseDir = string.match(basePath, "([^:]+):(.*)")
            if baseDir and baseDir ~= "" then
                -- Se baseDir termina com /, remover
                if string.sub(baseDir, -1) == "/" then
                    baseDir = string.sub(baseDir, 1, -2)
                end
                return prefix .. ":" .. baseDir .. "/" .. cleanPath
            else
                -- Exemplo: udisk: -> udisk:motores.db (sem barra após :)
                return prefix .. ":" .. cleanPath
            end
        else
            return basePath .. ":" .. cleanPath
        end
    end
    
    -- Caso contrário, concatenar com basePath normal
    local base = basePath or "/flash"
    if string.sub(base, -1) == "/" then
        return base .. path
    else
        return base .. "/" .. path
    end
end

-- Função para listar arquivos em um diretório
-- Retorna uma tabela com os nomes dos arquivos e diretórios
-- Suporta paths especiais: sdcard:, udisk:, /flash
function FileManager:ListarArquivos(path)
    path = normalizePath(path, self.BasePath)
    print("[FileManager] Listando arquivos em: " .. tostring(path))
    
    local arquivos = {}
    local diretorios = {}
    
    -- Para paths especiais (sdcard:, udisk:), usar flash.file_filter como alternativa
    -- pois lfs.dir pode não funcionar diretamente com esses paths
    if isSpecialPath(path) then
        -- Para paths especiais, tentar usar flash.file_filter com padrão *.*
        local success, resultado = pcall(function()
            return flash.file_filter(path, "*.*")
        end)
        
        if success and resultado then
            if type(resultado) == "table" then
                for i, nomeArquivo in ipairs(resultado) do
                    local itemPath = path
                    -- Para paths especiais, usar : como separador
                    if string.find(itemPath, ":") then
                        local prefix, baseDir = string.match(itemPath, "([^:]+):(.*)")
                        if baseDir and baseDir ~= "" then
                            itemPath = prefix .. ":" .. baseDir .. "/" .. nomeArquivo
                        else
                            itemPath = prefix .. ":" .. nomeArquivo
                        end
                    else
                        itemPath = itemPath .. ":" .. nomeArquivo
                    end
                    
                    local attrs = lfs.attributes(itemPath)
                    table.insert(arquivos, {
                        nome = nomeArquivo,
                        caminho = itemPath,
                        tipo = "arquivo",
                        tamanho = attrs and attrs.size or 0
                    })
                end
            end
        end
    else
        -- Para paths normais, usar lfs.dir
        local success, err = pcall(function()
            for item in lfs.dir(path) do
                -- Ignorar . e ..
                if item ~= "." and item ~= ".." then
                    local itemPath = path
                    if string.sub(itemPath, -1) ~= "/" then
                        itemPath = itemPath .. "/"
                    end
                    itemPath = itemPath .. item
                    
                    -- Verificar se é diretório ou arquivo
                    local attrs = lfs.attributes(itemPath)
                    if attrs then
                        if attrs.mode == "directory" then
                            table.insert(diretorios, {
                                nome = item,
                                caminho = itemPath,
                                tipo = "diretorio",
                                tamanho = 0
                            })
                        else
                            table.insert(arquivos, {
                                nome = item,
                                caminho = itemPath,
                                tipo = "arquivo",
                                tamanho = attrs.size or 0
                            })
                        end
                    else
                        -- Se não conseguir obter atributos, assumir que é arquivo
                        table.insert(arquivos, {
                            nome = item,
                            caminho = itemPath,
                            tipo = "arquivo",
                            tamanho = 0
                        })
                    end
                end
            end
        end)
        
        if not success then
            return nil, "Erro ao listar diretório: " .. tostring(err)
        end
    end
    
    local totalArquivos = #arquivos
    local totalDiretorios = #diretorios
    print("[FileManager] ✓ Listagem concluída: " .. totalArquivos .. " arquivos, " .. totalDiretorios .. " diretórios")
    
    return {
        arquivos = arquivos,
        diretorios = diretorios,
        totalArquivos = totalArquivos,
        totalDiretorios = totalDiretorios
    }
end

-- Função para listar arquivos com filtro (usando flash.file_filter)
-- Retorna apenas arquivos que correspondem ao padrão
function FileManager:ListarArquivosComFiltro(path, pattern)
    path = normalizePath(path, self.BasePath)
    
    -- Usar flash.file_filter para filtrar arquivos
    -- Conforme documentação: flash.file_filter(path, pattern)
    local success, resultado = pcall(function()
        return flash.file_filter(path, pattern)
    end)
    
    if not success then
        return nil, "Erro ao filtrar arquivos: " .. tostring(resultado)
    end
    
    if not resultado then
        return {}
    end
    
    -- Converter resultado em formato padronizado
    local arquivos = {}
    if type(resultado) == "table" then
        for i, nomeArquivo in ipairs(resultado) do
            local arquivoPath = path
            if string.sub(arquivoPath, -1) ~= "/" then
                arquivoPath = arquivoPath .. "/"
            end
            arquivoPath = arquivoPath .. nomeArquivo
            
            local attrs = lfs.attributes(arquivoPath)
            table.insert(arquivos, {
                nome = nomeArquivo,
                caminho = arquivoPath,
                tipo = "arquivo",
                tamanho = attrs and attrs.size or 0
            })
        end
    elseif type(resultado) == "string" then
        -- Se retornar string única, criar tabela com um item
        table.insert(arquivos, {
            nome = resultado,
            caminho = path .. "/" .. resultado,
            tipo = "arquivo",
            tamanho = 0
        })
    end
    
    return arquivos
end

-- Função para ler conteúdo de um arquivo
-- Retorna o conteúdo como string
function FileManager:LerArquivo(caminhoArquivo)
    -- Normalizar caminho
    caminhoArquivo = normalizePath(caminhoArquivo, self.BasePath)
    
    -- Validar que caminhoArquivo não é nil antes de usar
    if not caminhoArquivo or caminhoArquivo == "" then
        print("[FileManager] ✗ Caminho do arquivo é inválido (nil ou vazio)")
        return nil, "Caminho do arquivo é inválido"
    end
    
    print("[FileManager] Lendo arquivo: " .. tostring(caminhoArquivo))
    
    -- Verificar se o arquivo existe
    local attrs = lfs.attributes(caminhoArquivo)
    if not attrs then
        print("[FileManager] ✗ Arquivo não encontrado: " .. tostring(caminhoArquivo))
        return nil, "Arquivo não encontrado: " .. caminhoArquivo
    end
    
    if attrs.mode == "directory" then
        print("[FileManager] ✗ Caminho é um diretório: " .. tostring(caminhoArquivo))
        return nil, "Caminho é um diretório, não um arquivo: " .. caminhoArquivo
    end
    
    local tamanhoArquivo = attrs.size or 0
    print("[FileManager] Arquivo encontrado, tamanho: " .. tostring(tamanhoArquivo) .. " bytes")
    
    print("[FileManager] Caminho normalizado: " .. tostring(caminhoArquivo) .. " (tipo: " .. type(caminhoArquivo) .. ")")
    
    -- Validar caminho antes de chamar flash.file_atu8
    if not caminhoArquivo or type(caminhoArquivo) ~= "string" or caminhoArquivo == "" then
        print("[FileManager] ✗ Caminho inválido antes de ler: " .. tostring(caminhoArquivo))
        return nil, "Caminho do arquivo inválido"
    end
    
    print("[FileManager] Lendo arquivo com io.open: " .. tostring(caminhoArquivo))
    
    -- Usar io.open para ler arquivo (flash.file_atu8 é para conversão de charset, não para leitura)
    local success, conteudo = pcall(function()
        -- Garantir que é string válida
        local pathStr = tostring(caminhoArquivo)
        print("[FileManager] Path string: " .. pathStr .. " (tipo: " .. type(pathStr) .. ", tamanho: " .. string.len(pathStr) .. ")")
        
        -- Usar io.open para ler arquivo em modo binário
        if not io or not io.open then
            error("io.open não está disponível")
        end
        
        print("[FileManager] Abrindo arquivo com io.open: " .. pathStr)
        local file = io.open(pathStr, "rb")
        if not file then
            error("Não foi possível abrir o arquivo: " .. pathStr)
        end
        
        -- Ler todo o conteúdo do arquivo
        local resultado = file:read("*all")
        file:close()
        
        print("[FileManager] Arquivo lido (tipo: " .. type(resultado) .. ", tamanho: " .. (resultado and string.len(resultado) or 0) .. " bytes)")
        return resultado
    end)
    
    if not success then
        print("[FileManager] ✗ Erro ao ler arquivo: " .. tostring(conteudo))
        return nil, "Erro ao ler arquivo: " .. tostring(conteudo)
    end
    
    if not conteudo then
        print("[FileManager] ✗ Arquivo vazio ou erro ao ler: " .. tostring(caminhoArquivo))
        return nil, "Arquivo vazio ou erro ao ler: " .. caminhoArquivo
    end
    
    local tamanhoConteudo = type(conteudo) == "string" and string.len(conteudo) or 0
    print("[FileManager] ✓ Arquivo lido com sucesso: " .. tostring(tamanhoConteudo) .. " bytes")
    
    return conteudo
end

-- Função para ler arquivo como texto (converte de bytes para string)
function FileManager:LerArquivoTexto(caminhoArquivo)
    local conteudo, err = self:LerArquivo(caminhoArquivo)
    
    if not conteudo then
        return nil, err
    end
    
    -- Se já for string, retornar diretamente
    if type(conteudo) == "string" then
        return conteudo
    end
    
    -- Se for tabela de bytes, converter para string
    if type(conteudo) == "table" then
        local str = ""
        for i, byte in ipairs(conteudo) do
            str = str .. string.char(byte)
        end
        return str
    end
    
    return tostring(conteudo)
end

-- Função para verificar se arquivo existe
function FileManager:ArquivoExiste(caminhoArquivo)
    caminhoArquivo = normalizePath(caminhoArquivo, self.BasePath)
    
    local attrs = lfs.attributes(caminhoArquivo)
    return attrs ~= nil and attrs.mode ~= "directory"
end

-- Função para verificar se diretório existe
function FileManager:DiretorioExiste(caminhoDiretorio)
    caminhoDiretorio = normalizePath(caminhoDiretorio, self.BasePath)
    
    local attrs = lfs.attributes(caminhoDiretorio)
    return attrs ~= nil and attrs.mode == "directory"
end

-- Função para obter informações de um arquivo
function FileManager:ObterInformacoesArquivo(caminhoArquivo)
    caminhoArquivo = normalizePath(caminhoArquivo, self.BasePath)
    print("[FileManager] Obtendo informações: " .. tostring(caminhoArquivo))
    
    local attrs = lfs.attributes(caminhoArquivo)
    if not attrs then
        print("[FileManager] ✗ Arquivo/diretório não encontrado: " .. tostring(caminhoArquivo))
        return nil, "Arquivo ou diretório não encontrado: " .. caminhoArquivo
    end
    
    local info = {
        caminho = caminhoArquivo,
        nome = string.match(caminhoArquivo, "([^/]+)$") or caminhoArquivo,
        tipo = attrs.mode == "directory" and "diretorio" or "arquivo",
        tamanho = attrs.size or 0,
        modificado = attrs.modification or 0,
        atributos = attrs
    }
    
    print("[FileManager] ✓ Informações obtidas: " .. tostring(info.nome) .. " (" .. tostring(info.tipo) .. ", " .. tostring(info.tamanho) .. " bytes)")
    
    return info
end

-- Função para apagar um arquivo
-- Retorna true se sucesso, false e mensagem de erro caso contrário
function FileManager:ApagarArquivo(caminhoArquivo)
    caminhoArquivo = normalizePath(caminhoArquivo, self.BasePath)
    print("[FileManager] Apagando arquivo: " .. tostring(caminhoArquivo))
    
    -- Verificar se o arquivo existe
    local attrs = lfs.attributes(caminhoArquivo)
    if not attrs then
        print("[FileManager] ✗ Arquivo não encontrado: " .. tostring(caminhoArquivo))
        return false, "Arquivo não encontrado: " .. caminhoArquivo
    end
    
    if attrs.mode == "directory" then
        print("[FileManager] ✗ Caminho é um diretório: " .. tostring(caminhoArquivo))
        return false, "Não é possível apagar diretório com esta função. Use ApagarDiretorio()"
    end
    
    -- Usar flash.file_remove para apagar arquivo
    -- Conforme documentação: flash.file_remove(path)
    local success, resultado = pcall(function()
        return flash.file_remove(caminhoArquivo)
    end)
    
    if not success then
        print("[FileManager] ✗ Erro ao apagar arquivo: " .. tostring(resultado))
        return false, "Erro ao apagar arquivo: " .. tostring(resultado)
    end
    
    print("[FileManager] ✓ Arquivo apagado com sucesso: " .. tostring(caminhoArquivo))
    
    -- Verificar se realmente foi removido
    local aindaExiste = lfs.attributes(caminhoArquivo)
    if aindaExiste then
        return false, "Arquivo não foi removido completamente"
    end
    
    return true
end

-- Função para apagar múltiplos arquivos
function FileManager:ApagarArquivos(listaCaminhos)
    if not listaCaminhos or type(listaCaminhos) ~= "table" then
        return false, "Lista de caminhos inválida"
    end
    
    local sucessos = 0
    local falhas = 0
    local erros = {}
    
    for i, caminho in ipairs(listaCaminhos) do
        local success, err = self:ApagarArquivo(caminho)
        if success then
            sucessos = sucessos + 1
        else
            falhas = falhas + 1
            table.insert(erros, {
                arquivo = caminho,
                erro = err
            })
        end
    end
    
    return {
        sucessos = sucessos,
        falhas = falhas,
        total = #listaCaminhos,
        erros = erros
    }
end

-- Função para apagar arquivos por padrão (usando filtro)
function FileManager:ApagarArquivosPorPadrao(path, pattern)
    path = normalizePath(path, self.BasePath)
    
    -- Listar arquivos que correspondem ao padrão
    local arquivos, err = self:ListarArquivosComFiltro(path, pattern)
    if not arquivos then
        return false, err
    end
    
    if #arquivos == 0 then
        return true, "Nenhum arquivo encontrado com o padrão especificado"
    end
    
    -- Apagar cada arquivo
    local caminhos = {}
    for i, arquivo in ipairs(arquivos) do
        table.insert(caminhos, arquivo.caminho)
    end
    
    return self:ApagarArquivos(caminhos)
end

-- Função para obter tamanho total de um diretório
function FileManager:ObterTamanhoDiretorio(path)
    path = normalizePath(path, self.BasePath)
    
    local lista, err = self:ListarArquivos(path)
    if not lista then
        return nil, err
    end
    
    local tamanhoTotal = 0
    
    -- Somar tamanho dos arquivos
    for i, arquivo in ipairs(lista.arquivos) do
        tamanhoTotal = tamanhoTotal + arquivo.tamanho
    end
    
    -- Recursivamente somar tamanho dos subdiretórios
    for i, diretorio in ipairs(lista.diretorios) do
        local subTamanho, subErr = self:ObterTamanhoDiretorio(diretorio.caminho)
        if subTamanho then
            tamanhoTotal = tamanhoTotal + subTamanho
        end
    end
    
    return tamanhoTotal
end

-- Função para imprimir lista de arquivos formatada (útil para debug)
function FileManager:ImprimirListaArquivos(path)
    path = normalizePath(path, self.BasePath)
    
    local lista, err = self:ListarArquivos(path)
    if not lista then
        print("[FileManager] Erro: " .. tostring(err))
        return
    end
    
    print("[FileManager] Listando: " .. path)
    print("[FileManager] Total de arquivos: " .. lista.totalArquivos)
    print("[FileManager] Total de diretórios: " .. lista.totalDiretorios)
    
    if #lista.diretorios > 0 then
        print("\nDiretórios:")
        for i, dir in ipairs(lista.diretorios) do
            print("  [DIR] " .. dir.nome)
        end
    end
    
    if #lista.arquivos > 0 then
        print("\nArquivos:")
        for i, arquivo in ipairs(lista.arquivos) do
            print("  [FILE] " .. arquivo.nome .. " (" .. arquivo.tamanho .. " bytes)")
        end
    end
end

-- ============================================
-- FUNÇÕES ESPECÍFICAS PARA ARQUIVOS DE BANCO DE DADOS
-- ============================================

-- Função para listar arquivos de banco de dados (.db)
-- Busca em múltiplos locais: sdcard:, udisk:, /flash
function FileManager:ListarArquivosBancoDados()
    local todosArquivos = {}
    local locais = {"sdcard:", "udisk:", "/flash"}
    
    for i, localPath in ipairs(locais) do
        local lista, err = self:ListarArquivosComFiltro(localPath, "*.db")
        if lista and type(lista) == "table" then
            for j, arquivo in ipairs(lista) do
                -- Adicionar informação do local
                arquivo.localizacao = localPath
                table.insert(todosArquivos, arquivo)
            end
        end
    end
    
    return todosArquivos
end

-- Função para encontrar arquivo de banco de dados por nome
function FileManager:EncontrarArquivoBancoDados(nomeArquivo)
    -- Garantir extensão .db
    if not string.match(nomeArquivo, "%.db$") then
        nomeArquivo = nomeArquivo .. ".db"
    end
    
    local locais = {"sdcard:", "udisk:", "/flash"}
    
    for i, localPath in ipairs(locais) do
        local caminhoCompleto = normalizePath(nomeArquivo, localPath)
        if self:ArquivoExiste(caminhoCompleto) then
            local info = self:ObterInformacoesArquivo(caminhoCompleto)
            if info then
                info.localizacao = localPath
                return info
            end
        end
    end
    
    return nil, "Arquivo de banco de dados não encontrado: " .. nomeArquivo
end

-- Função para ler informações de arquivo de banco de dados
-- Retorna informações básicas sem precisar conectar ao SQLite
function FileManager:ObterInformacoesBancoDados(caminhoArquivo)
    caminhoArquivo = normalizePath(caminhoArquivo, self.BasePath)
    
    local info, err = self:ObterInformacoesArquivo(caminhoArquivo)
    if not info then
        return nil, err
    end
    
    -- Verificar se é arquivo .db
    if not string.match(info.nome, "%.db$") then
        return nil, "Arquivo não é um banco de dados (.db): " .. info.nome
    end
    
    -- Adicionar informações específicas de banco de dados
    info.tipoArquivo = "SQLite Database"
    info.tamanhoKB = string.format("%.2f", info.tamanho / 1024)
    info.tamanhoMB = string.format("%.2f", info.tamanho / (1024 * 1024))
    
    return info
end

-- Função para listar todos os arquivos de banco de dados com informações detalhadas
function FileManager:ListarBancosDadosDetalhado()
    local arquivos = self:ListarArquivosBancoDados()
    local detalhes = {}
    
    for i, arquivo in ipairs(arquivos) do
        local info = self:ObterInformacoesBancoDados(arquivo.caminho)
        if info then
            table.insert(detalhes, info)
        end
    end
    
    return detalhes
end

-- Função para apagar arquivo de banco de dados
-- ATENÇÃO: Esta função apaga o arquivo físico, não apenas os dados
function FileManager:ApagarArquivoBancoDados(caminhoArquivo)
    caminhoArquivo = normalizePath(caminhoArquivo, self.BasePath)
    
    -- Verificar se é arquivo .db
    if not string.match(caminhoArquivo, "%.db$") then
        return false, "Arquivo não é um banco de dados (.db)"
    end
    
    return self:ApagarArquivo(caminhoArquivo)
end

-- Função para copiar arquivo de banco de dados
function FileManager:CopiarArquivoBancoDados(origem, destino)
    origem = normalizePath(origem, self.BasePath)
    destino = normalizePath(destino, self.BasePath)
    
    -- Verificar se origem existe
    if not self:ArquivoExiste(origem) then
        return false, "Arquivo de origem não encontrado: " .. origem
    end
    
    -- Usar flash.file_copy conforme documentação
    local success, resultado = pcall(function()
        return flash.file_copy(origem, destino)
    end)
    
    if not success then
        return false, "Erro ao copiar arquivo: " .. tostring(resultado)
    end
    
    return true
end

-- Função para verificar integridade básica de arquivo de banco de dados
-- (verifica se o arquivo existe e tem tamanho > 0)
function FileManager:VerificarIntegridadeBancoDados(caminhoArquivo)
    caminhoArquivo = normalizePath(caminhoArquivo, self.BasePath)
    
    local info, err = self:ObterInformacoesBancoDados(caminhoArquivo)
    if not info then
        return false, err
    end
    
    if info.tamanho == 0 then
        return false, "Arquivo de banco de dados está vazio"
    end
    
    -- Tamanho mínimo esperado para um banco SQLite válido (header SQLite tem ~100 bytes)
    if info.tamanho < 100 then
        return false, "Arquivo de banco de dados parece corrompido (tamanho muito pequeno)"
    end
    
    return true, "Arquivo de banco de dados parece íntegro"
end

-- Função para imprimir lista de bancos de dados formatada
function FileManager:ImprimirListaBancosDados()
    print("[FileManager] === ARQUIVOS DE BANCO DE DADOS ===")
    
    local arquivos = self:ListarBancosDadosDetalhado()
    
    if #arquivos == 0 then
        print("[FileManager] Nenhum arquivo de banco de dados encontrado")
        return
    end
    
    print("[FileManager] Total de bancos de dados: " .. #arquivos)
    print("")
    
    for i, arquivo in ipairs(arquivos) do
        print(string.format("[%d] %s", i, arquivo.nome))
        print("    Localização: " .. (arquivo.localizacao or "desconhecida"))
        print("    Caminho: " .. arquivo.caminho)
        print("    Tamanho: " .. arquivo.tamanho .. " bytes (" .. arquivo.tamanhoKB .. " KB)")
        if arquivo.modificado then
            print("    Modificado: " .. tostring(arquivo.modificado))
        end
        print("")
    end
end

return FileManager
