import { useEffect, useRef, useState } from 'react';
import { getWebSocketUrl } from '../utils/config';

interface MotorCorrente {
  id: string;
  correnteAtual: number;
}

interface CorrentesMessage {
  tipo: string;
  plantaId: string;
  motores: MotorCorrente[];
  timestamp: number;
}

export function useWebSocketCorrentes(
  plantaId: string | undefined,
  onCorrentesUpdate: (correntes: Map<string, number>) => void
) {
  const [isConnected, setIsConnected] = useState(false);
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const reconnectAttempts = useRef(0);
  const shouldReconnect = useRef(true); // Flag para controlar se deve reconectar

  useEffect(() => {
    if (!plantaId) {
      // Desconectar se não houver planta selecionada
      shouldReconnect.current = false;
      if (wsRef.current) {
        wsRef.current.close();
        wsRef.current = null;
        setIsConnected(false);
      }
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
        reconnectTimeoutRef.current = null;
      }
      return;
    }

    // Habilitar reconexão quando houver planta selecionada
    shouldReconnect.current = true;

    // Usar função inteligente para construir URL do WebSocket
    const wsUrl = getWebSocketUrl('correntes', plantaId);
    
    console.log('[WebSocket Correntes] URL:', wsUrl);
    console.log('[WebSocket Correntes] Ambiente:', window.location.hostname === 'localhost' ? 'Desenvolvimento' : 'Produção');

    const connect = () => {
      if (!shouldReconnect.current) {
        console.log('[WebSocket] Reconexão desabilitada');
        return;
      }

      try {
        const ws = new WebSocket(wsUrl);
        wsRef.current = ws;

        ws.onopen = () => {
          console.log('[WebSocket] Conectado para planta:', plantaId);
          setIsConnected(true);
          reconnectAttempts.current = 0; // Resetar contador ao conectar com sucesso
        };

        ws.onmessage = (event) => {
          try {
            const message: CorrentesMessage = JSON.parse(event.data);
            
            if (message.tipo === 'correntes' && message.motores) {
              // Criar um Map com UUID -> correnteAtual
              const correntesMap = new Map<string, number>();
              message.motores.forEach((motor) => {
                correntesMap.set(motor.id, motor.correnteAtual);
              });
              
              // Chamar callback para atualizar estado
              onCorrentesUpdate(correntesMap);
            }
          } catch (err) {
            console.error('[WebSocket] Erro ao processar mensagem:', err);
          }
        };

        ws.onerror = (error) => {
          console.error('[WebSocket] Erro na conexão:', error);
          setIsConnected(false);
        };

        ws.onclose = () => {
          console.log('[WebSocket] Conexão fechada');
          setIsConnected(false);
          
          // Tentar reconectar infinitamente se ainda houver planta selecionada e flag ativa
          if (plantaId && shouldReconnect.current) {
            reconnectAttempts.current++;
            // Backoff exponencial com limite máximo de 30 segundos
            const delay = Math.min(1000 * Math.pow(2, Math.min(reconnectAttempts.current, 5)), 30000);
            console.log(`[WebSocket] Tentando reconectar em ${delay}ms (tentativa ${reconnectAttempts.current})`);
            
            reconnectTimeoutRef.current = setTimeout(() => {
              if (shouldReconnect.current) {
                connect();
              }
            }, delay);
          }
        };
      } catch (err) {
        console.error('[WebSocket] Erro ao criar conexão:', err);
        setIsConnected(false);
        
        // Tentar reconectar mesmo em caso de erro na criação
        if (plantaId && shouldReconnect.current) {
          reconnectAttempts.current++;
          const delay = Math.min(1000 * Math.pow(2, Math.min(reconnectAttempts.current, 5)), 30000);
          console.log(`[WebSocket] Tentando reconectar após erro em ${delay}ms (tentativa ${reconnectAttempts.current})`);
          
          reconnectTimeoutRef.current = setTimeout(() => {
            if (shouldReconnect.current) {
              connect();
            }
          }, delay);
        }
      }
    };

    connect();

    // Cleanup
    return () => {
      shouldReconnect.current = false; // Desabilitar reconexão no cleanup
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
        reconnectTimeoutRef.current = null;
      }
      if (wsRef.current) {
        wsRef.current.close();
        wsRef.current = null;
      }
      setIsConnected(false);
    };
  }, [plantaId, onCorrentesUpdate]);

  return { isConnected };
}
