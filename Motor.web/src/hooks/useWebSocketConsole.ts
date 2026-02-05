import { useEffect, useRef, useState } from 'react';

export interface ConsoleMessage {
  tipo: 'log' | 'error' | 'warn' | 'info';
  mensagem: string;
  timestamp: number;
  nivel: string;
  plantaId?: string;
}

export function useWebSocketConsole(
  plantaId: string | undefined,
  onMessage: (message: ConsoleMessage) => void
) {
  const [isConnected, setIsConnected] = useState(false);
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const reconnectAttempts = useRef(0);
  const shouldReconnect = useRef(true);

  useEffect(() => {
    // Construir URL do WebSocket (pode receber de todas as plantas se não especificar)
    const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    const wsHost = import.meta.env.VITE_WS_URL || 'api.motores.automais.io';
    const wsUrl = plantaId 
      ? `${wsProtocol}//${wsHost}/api/websocket/console?plantaId=${plantaId}`
      : `${wsProtocol}//${wsHost}/api/websocket/console?plantaId=all`;

    const connect = () => {
      if (!shouldReconnect.current) {
        console.log('[Console WebSocket] Reconexão desabilitada');
        return;
      }

      try {
        const ws = new WebSocket(wsUrl);
        wsRef.current = ws;

        ws.onopen = () => {
          console.log('[Console WebSocket] Conectado para planta:', plantaId || 'todas');
          setIsConnected(true);
          reconnectAttempts.current = 0;
        };

        ws.onmessage = (event) => {
          try {
            const message: ConsoleMessage = JSON.parse(event.data);
            onMessage(message);
          } catch (err) {
            console.error('[Console WebSocket] Erro ao processar mensagem:', err);
          }
        };

        ws.onerror = (error) => {
          console.error('[Console WebSocket] Erro na conexão:', error);
          setIsConnected(false);
        };

        ws.onclose = () => {
          console.log('[Console WebSocket] Conexão fechada');
          setIsConnected(false);
          
          // Tentar reconectar
          if (shouldReconnect.current) {
            reconnectAttempts.current++;
            const delay = Math.min(1000 * Math.pow(2, Math.min(reconnectAttempts.current, 5)), 30000);
            console.log(`[Console WebSocket] Tentando reconectar em ${delay}ms (tentativa ${reconnectAttempts.current})`);
            
            reconnectTimeoutRef.current = setTimeout(() => {
              if (shouldReconnect.current) {
                connect();
              }
            }, delay);
          }
        };
      } catch (err) {
        console.error('[Console WebSocket] Erro ao criar conexão:', err);
        setIsConnected(false);
        
        if (shouldReconnect.current) {
          reconnectAttempts.current++;
          const delay = Math.min(1000 * Math.pow(2, Math.min(reconnectAttempts.current, 5)), 30000);
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
      shouldReconnect.current = false;
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
  }, [plantaId, onMessage]);

  return { isConnected };
}
