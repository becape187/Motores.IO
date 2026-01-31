-- Script para testar prints via botão
-- Colar este código no evento "On Click" ou "Lua Script" de um botão

print(">>> INICIANDO TESTE DE PRINTS <<<")
local teste = TestePrints:new()
print(">>> TestePrints criado <<<")
local success, resultado = teste:testar()
print(">>> testar() retornou <<<")
print("Success: " .. tostring(success))
print("Resultado: " .. tostring(resultado))
print(">>> FIM DO TESTE DE PRINTS <<<")
