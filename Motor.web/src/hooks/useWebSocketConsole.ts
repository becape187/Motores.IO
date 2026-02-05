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
    // TESTE: Usar o mesmo endpoint de correntes que funciona
    // Filtrar mensagens de console na camada de aplicação
    const wsProtocol = window.location.protocol === 'https:' ? 'wss:' : 'ws:';
    // Usar a mesma base URL da API se disponível
    const apiBaseUrl = import.meta.env.VITE_API_URL || 'https://api.motores.automais.io/api';
    // Extrair o host da API (remover /api do final se existir)
    let wsHost = import.meta.env.VITE_WS_URL;
    if (!wsHost) {
      // Extrair host da URL da API
      const url = new URL(apiBaseUrl.replace(/\/api$/, ''));
      wsHost = url.host;
    }
    
    // Usar endpoint de correntes (que sabemos que funciona)
    const wsUrl = plantaId 
      ? `${wsProtocol}//${wsHost}/api/websocket/correntes?plantaId=${plantaId}`
      : `${wsProtocol}//${wsHost}/api/websocket/correntes?plantaId=all`;

    console.log('[Console WebSocket] TESTE: Usando endpoint de correntes:', wsUrl);
    console.log('[Console WebSocket] Filtrando mensagens de console na camada de aplicação');

    const connect = () => {
      if (!shouldReconnect.current) {
        console.log('[Console WebSocket] Reconexão desabilitada');
        return;
      }

      try {
        const ws = new WebSocket(wsUrl);
        wsRef.current = ws;

        ws.onopen = () => {
          console.log('[Console WebSocket] ✓ Conectado com sucesso para planta:', plantaId || 'todas');
          setIsConnected(true);
          reconnectAttempts.current = 0;
        };

        ws.onmessage = (event) => {
          try {
            const data = JSON.parse(event.data);
            
            // Filtrar apenas mensagens de console (tipo: log, error, warn, info)
            // Mensagens de console têm: tipo, mensagem, timestamp, nivel, plantaId
            // Mensagens de correntes têm: tipo: "correntes", motores, plantaId
            if (data.tipo === 'log' || data.tipo === 'error' || data.tipo === 'warn' || data.tipo === 'info') {
              // É uma mensagem de console
              const message: ConsoleMessage = {
                tipo: data.tipo,
                mensagem: data.mensagem,
                timestamp: data.timestamp,
                nivel: data.nivel || data.tipo,
                plantaId: data.plantaId
              };
              console.log('[Console WebSocket] Mensagem de console recebida:', message);
              onMessage(message);
            } else {
              // É uma mensagem de correntes ou outro tipo, ignorar
              console.log('[Console WebSocket] Mensagem ignorada (não é console):', data.tipo);
            }
          } catch (err) {
            console.error('[Console WebSocket] Erro ao processar mensagem:', err);
            console.error('[Console WebSocket] Dados recebidos:', event.data);
          }
        };

        ws.onerror = (error) => {
          console.error('[Console WebSocket] ✗ Erro na conexão:', error);
          console.error('[Console WebSocket] URL tentada:', wsUrl);
          setIsConnected(false);
        };

        ws.onclose = (event) => {
          console.log('[Console WebSocket] Conexão fechada. Code:', event.code, 'Reason:', event.reason);
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
