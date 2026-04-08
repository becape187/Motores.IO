-- =========================
-- Integração com Wecon
-- =========================
Script_BG_limits = 11

function we_bg_init()
    print("\n" .. string.rep("=", 60))
    print("  SISTEMA DE MONITORAMENTO - VERSÃO SIMPLIFICADA v5.0")
    print("  Wecon PI8150IG - PLANTA SIGIL")
    print("  22 MOTORES: Horímetro + Configurações")
    print(string.rep("=", 60))
    print("\n📋 FUNCIONALIDADES:")
    print("  ✓ Horímetro individual por motor (HORAS INTEIRAS)")
    print("  ✓ Configurações persistentes (setpoints)")
    print("  ✓ Salvamento automático a cada 10s")
    print("  ✓ Botão de zerar horímetro individual")
    print("  ✓ Sincronização de registradores")
    print("\n🏭 MOTORES MONITORADOS:")
    print("  AV01, AV02")
    print("  BRT01, BRT02, BRT03")
    print("  TC01-TC14 (14 motores)")
    print("  PV01, PV02, PV03")
    print("\n📊 REGISTRADORES POR MOTOR:")
    print("  Corrente           = Endereço específico")
    print("  Setpoint Alarme    = HAW0-HAW21 (escrita)")
    print("  Setpoint Nominal   = HAW30-HAW51 (escrita)")
    print("  Alarme Efetivo     = HAW60-HAW81 (leitura)")
    print("  Nominal Efetivo    = HAW90-HAW111 (leitura)")
    print("  Horímetro          = HAW200-HAW242 (HORAS)")
    print("\n🔘 BOTÕES POR MOTOR:")
    print("  Zerar horímetro = HDX6.0-HDX6.15, HDX7.0-HDX7.5")
    print(string.rep("=", 60) .. "\n")
    print("⏳ Aguarde a inicialização...\n")
end

function we_bg_poll()
    LoopPrincipal()
end

-- =========================
-- Finalização
-- =========================
function we_bg_exit()
    print("\n" .. string.rep("=", 50))
    print("FINALIZANDO SISTEMA")
    print(string.rep("=", 50))
    
    -- Salvar horímetros de todos os motores
    if bancoInicializado then
        print("💾 Salvando horímetros finais...")
        local salvos = 0
        
        for i, motor in ipairs(MOTORES) do
            local estado = estadoMotores[motor.tag]
            if estado.horimetroSegundos > 0 then
                if SalvarHorimetro(motor, estado.horimetroSegundos) then
                    salvos = salvos + 1
                end
            end
        end
        
        print("✓ " .. salvos .. " horímetros salvos")
    end
    
    print("\n🔚 Sistema finalizado com segurança")
    print(string.rep("=", 50) .. "\n")
end