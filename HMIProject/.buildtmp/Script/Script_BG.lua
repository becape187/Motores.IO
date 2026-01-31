Script_BG_limits = 11

-- Variável local do módulo para armazenar o motor
local motor1

function we_bg_init()
    -- Cria o motor apenas uma vez na inicialização
    motor1 = Motor:new(1, "Motor 1", 100, 1, 50.0) -- correnteNominal = 50.0A
end

function we_bg_poll()
  
end