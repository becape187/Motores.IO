-- Classe de teste apenas para verificar se prints funcionam
-- Não usar return para ficar disponível globalmente no PIStudio
TestePrints = {}
TestePrints.__index = TestePrints

-- Construtor
function TestePrints:new()
    local obj = {}
    setmetatable(obj, TestePrints)
    print("[TestePrints] Construtor chamado")
    return obj
end

-- Função de teste simples
function TestePrints:testar()
    print("========================================")
    print("[TestePrints] === INÍCIO DO TESTE ===")
    print("========================================")
    
    print("[TestePrints] Passo 1: Iniciando teste...")
    
    print("[TestePrints] Passo 2: Testando print simples")
    print("Mensagem de teste")
    
    print("[TestePrints] Passo 3: Testando concatenação")
    local texto = "Teste " .. "de " .. "concatenação"
    print(texto)
    
    print("[TestePrints] Passo 4: Testando número")
    local numero = 500
    print("Número: " .. tostring(numero))
    
    print("[TestePrints] Passo 5: Testando tabela")
    local tabela = {a = 1, b = 2}
    print("Tabela: " .. tostring(tabela))
    
    print("[TestePrints] Passo 6: Testando múltiplos prints")
    for i = 1, 5 do
        print("[TestePrints] Loop " .. i)
    end
    
    print("========================================")
    print("[TestePrints] === FIM DO TESTE ===")
    print("========================================")
    
    return true, "Teste concluído"
end
