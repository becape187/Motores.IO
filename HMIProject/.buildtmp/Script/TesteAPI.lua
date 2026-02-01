-- Script para testar a chamada da AP
print(">>> INICIANDO TESTE <<<")
local apiClient = APIClient:new()
print(">>> APIClient criado <<<")
local success, resultado = apiClient:ReceberPlanta()
print(">>> ReceberPlanta retornou <<<")
if success then
    print("SUCESSO! Motores: " .. tostring(#resultado))
else
    print("ERRO: " .. tostring(resultado))
end
print(">>> FIM DO TESTE <<<")