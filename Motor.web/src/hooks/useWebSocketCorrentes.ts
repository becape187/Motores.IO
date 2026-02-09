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
  const heartbeatTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const reconnectAttempts = useRef(0);
  const shouldReconnect = useRef(true);
  const isMountedRef = useRef(true);
  const isConnectingRef = useRef(false);
  const lastMessageTimeRef = useRef<number | null>(null);
  const onCorrentesUpdateRef = useRef(onCorrentesUpdate);

  // Atualizar referência do callback sem causar re-render
  useEffect(() => {
    onCorrentesUpdateRef.current = onCorrentesUpdate;
  }, [onCorrentesUpdate]);

  useEffect(() => {
    // Verificar se já está conectando para evitar múltiplas conexões
    if (isConnectingRef.current) {
      console.log('[WebSocket Correntes] Já está conectando, ignorando nova tentativa');
      return;
    }

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
      if (heartbeatTimeoutRef.current) {
        clearTimeout(heartbeatTimeoutRef.current);
        heartbeatTimeoutRef.current = null;
      }
      return;
    }

    // Resetar flag de montagem
    isMountedRef.current = true;
    shouldReconnect.current = true;
    isConnectingRef.current = true;

    // Usar função inteligente para construir URL do WebSocket
    const wsUrl = getWebSocketUrl('correntes', plantaId);
    
    console.log('[WebSocket Correntes] URL:', wsUrl);
    console.log('[WebSocket Correntes] Ambiente:', window.location.hostname === 'localhost' ? 'Desenvolvimento' : 'Produção');

    // Função para verificar se está recebendo mensagens (heartbeat)
    const startHeartbeatCheck = () => {
      // Limpar timeout anterior se existir
      if (heartbeatTimeoutRef.current) {
        clearTimeout(heartbeatTimeoutRef.current);
      }

      // Verificar a cada 5 segundos se recebeu mensagem
      heartbeatTimeoutRef.current = setTimeout(() => {
        const now = Date.now();
        const lastMessage = lastMessageTimeRef.current;

        // Se está conectado mas não recebeu mensagem nos últimos 5 segundos
        if (wsRef.current?.readyState === WebSocket.OPEN && lastMessage !== null) {
          const timeSinceLastMessage = now - lastMessage;
          
          if (timeSinceLastMessage > 5000) {
            console.log('[WebSocket Correntes] ⚠️ Sem mensagens há mais de 5 segundos, reconectando...');
            // Fechar conexão atual para forçar reconexão
            if (wsRef.current) {
              wsRef.current.close();
            }
            return;
          }
        }

        // Se ainda está conectado, continuar verificando
        if (wsRef.current?.readyState === WebSocket.OPEN && isMountedRef.current && shouldReconnect.current) {
          startHeartbeatCheck();
        }
      }, 5000);
    };

    const connect = () => {
      // Verificar se ainda está montado e se deve reconectar
      if (!isMountedRef.current || !shouldReconnect.current) {
        console.log('[WebSocket Correntes] Reconexão desabilitada ou componente desmontado');
        return;
      }

      try {
        const ws = new WebSocket(wsUrl);
        wsRef.current = ws;

        ws.onopen = () => {
          console.log('[WebSocket Correntes] ✓ Conectado com sucesso para planta:', plantaId);
          setIsConnected(true);
          reconnectAttempts.current = 0;
          isConnectingRef.current = false;
          lastMessageTimeRef.current = Date.now(); // Inicializar timestamp
          startHeartbeatCheck(); // Iniciar verificação de heartbeat
        };

        ws.onmessage = (event) => {
          try {
            // Atualizar timestamp da última mensagem recebida
            lastMessageTimeRef.current = Date.now();

            const message: CorrentesMessage = JSON.parse(event.data);
            
            if (message.tipo === 'correntes' && message.motores) {
              // Criar um Map com UUID -> correnteAtual
              const correntesMap = new Map<string, number>();
              message.motores.forEach((motor) => {
                correntesMap.set(motor.id, motor.correnteAtual);
              });
              
              // Chamar callback para atualizar estado
              onCorrentesUpdateRef.current(correntesMap);
            }
          } catch (err) {
            console.error('[WebSocket Correntes] Erro ao processar mensagem:', err);
          }
        };

        ws.onerror = (error) => {
          console.error('[WebSocket Correntes] ✗ Erro na conexão:', error);
          setIsConnected(false);
          isConnectingRef.current = false;
        };

        ws.onclose = (event) => {
          console.log('[WebSocket Correntes] Conexão fechada. Code:', event.code, 'Reason:', event.reason);
          setIsConnected(false);
          isConnectingRef.current = false;
          lastMessageTimeRef.current = null;

          // Limpar heartbeat check
          if (heartbeatTimeoutRef.current) {
            clearTimeout(heartbeatTimeoutRef.current);
            heartbeatTimeoutRef.current = null;
          }
          
          // Tentar reconectar infinitamente se ainda houver planta selecionada e flag ativa
          // E se não foi um fechamento intencional (code 1000)
          if (isMountedRef.current && shouldReconnect.current && event.code !== 1000) {
            reconnectAttempts.current++;
            // Backoff exponencial com limite máximo de 30 segundos
            const delay = Math.min(1000 * Math.pow(2, Math.min(reconnectAttempts.current, 5)), 30000);
            console.log(`[WebSocket Correntes] Tentando reconectar em ${delay}ms (tentativa ${reconnectAttempts.current})`);
            
            reconnectTimeoutRef.current = setTimeout(() => {
              if (isMountedRef.current && shouldReconnect.current && !isConnectingRef.current) {
                isConnectingRef.current = true;
                connect();
              }
            }, delay);
          } else {
            console.log('[WebSocket Correntes] Não reconectando - componente desmontado, flag desabilitada ou fechamento intencional');
          }
        };
      } catch (err) {
        console.error('[WebSocket Correntes] Erro ao criar conexão:', err);
        setIsConnected(false);
        isConnectingRef.current = false;
        
        // Tentar reconectar mesmo em caso de erro na criação
        if (isMountedRef.current && shouldReconnect.current) {
          reconnectAttempts.current++;
          const delay = Math.min(1000 * Math.pow(2, Math.min(reconnectAttempts.current, 5)), 30000);
          console.log(`[WebSocket Correntes] Tentando reconectar após erro em ${delay}ms (tentativa ${reconnectAttempts.current})`);
          
          reconnectTimeoutRef.current = setTimeout(() => {
            if (isMountedRef.current && shouldReconnect.current && !isConnectingRef.current) {
              isConnectingRef.current = true;
              connect();
            }
          }, delay);
        }
      }
    };

    connect();

    // Cleanup
    return () => {
      console.log('[WebSocket Correntes] Cleanup: Desabilitando reconexão e fechando conexão');
      isMountedRef.current = false;
      shouldReconnect.current = false;
      isConnectingRef.current = false;
      
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
        reconnectTimeoutRef.current = null;
      }
      
      if (heartbeatTimeoutRef.current) {
        clearTimeout(heartbeatTimeoutRef.current);
        heartbeatTimeoutRef.current = null;
      }
      
      if (wsRef.current) {
        try {
          // Remover listeners antes de fechar
          wsRef.current.onopen = null;
          wsRef.current.onmessage = null;
          wsRef.current.onerror = null;
          wsRef.current.onclose = null;
          
          if (wsRef.current.readyState === WebSocket.OPEN || wsRef.current.readyState === WebSocket.CONNECTING) {
            wsRef.current.close(1000, 'Componente desmontado');
          }
        } catch (err) {
          console.error('[WebSocket Correntes] Erro ao fechar WebSocket:', err);
        }
        wsRef.current = null;
      }
      
      setIsConnected(false);
    };
  }, [plantaId]); // Removido onCorrentesUpdate das dependências - usando ref

  return { isConnected };
}
