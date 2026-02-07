import { useEffect, useRef, useState } from 'react';
import { getWebSocketUrl } from '../utils/config';

export interface ConsoleMessage {
  tipo: 'log' | 'error' | 'warn' | 'info';
  mensagem: string;
  timestamp: number;
  nivel: string;
  plantaId?: string;
}

// Função para salvar mensagem no histórico (pode ser chamada mesmo fora do componente)
function saveMessageToHistory(message: ConsoleMessage) {
  try {
    const CONSOLE_HISTORY_KEY = 'console_history';
    const MAX_HISTORY_SIZE = 1000;
    
    const stored = localStorage.getItem(CONSOLE_HISTORY_KEY);
    const history: ConsoleMessage[] = stored ? JSON.parse(stored) : [];
    
    // Filtrar mensagens de PING antes de salvar
    const mensagemUpper = (message.mensagem || '').trim().toUpperCase();
    if (mensagemUpper.includes('PING')) {
      return; // Não salvar PINGs no histórico
    }
    
    history.push(message);
    
    // Limitar tamanho do histórico
    if (history.length > MAX_HISTORY_SIZE) {
      const excess = history.length - MAX_HISTORY_SIZE;
      history.splice(0, excess);
    }
    
    localStorage.setItem(CONSOLE_HISTORY_KEY, JSON.stringify(history));
  } catch (err) {
    console.error('[Console WebSocket] Erro ao salvar no histórico:', err);
  }
}

export function useWebSocketConsole(
  plantaId: string | undefined,
  onMessage: (message: ConsoleMessage) => void
) {
  const [isConnected, setIsConnected] = useState(false);
  const [lastPing, setLastPing] = useState<number | null>(null);
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const reconnectAttempts = useRef(0);
  const shouldReconnect = useRef(true);
  const isMountedRef = useRef(true);
  const onMessageRef = useRef(onMessage);
  const isConnectingRef = useRef(false);

  // Atualizar referência do callback sem causar re-render
  useEffect(() => {
    onMessageRef.current = onMessage;
  }, [onMessage]);

  useEffect(() => {
    // Verificar se já está conectando para evitar múltiplas conexões
    if (isConnectingRef.current) {
      console.log('[Console WebSocket] Já está conectando, ignorando nova tentativa');
      return;
    }

    // Resetar flag de montagem
    isMountedRef.current = true;
    shouldReconnect.current = true;
    isConnectingRef.current = true;
    
    // Usar função inteligente para construir URL do WebSocket
    const finalPlantaId = plantaId || 'all';
    const wsUrl = getWebSocketUrl('console', finalPlantaId);

    console.log('[Console WebSocket] Conectando ao endpoint de console:', wsUrl);
    console.log('[Console WebSocket] PlantaId:', finalPlantaId);
    console.log('[Console WebSocket] Ambiente:', window.location.hostname === 'localhost' ? 'Desenvolvimento' : 'Produção');

    const connect = () => {
      // Verificar se ainda está montado e se deve reconectar
      if (!isMountedRef.current || !shouldReconnect.current) {
        console.log('[Console WebSocket] Reconexão desabilitada ou componente desmontado');
        return;
      }

      try {
        const ws = new WebSocket(wsUrl);
        wsRef.current = ws;

        ws.onopen = () => {
          console.log('[Console WebSocket] ✓ Conectado com sucesso para planta:', plantaId || 'todas');
          setIsConnected(true);
          reconnectAttempts.current = 0;
          isConnectingRef.current = false;
        };

        ws.onmessage = (event) => {
          try {
            const data = JSON.parse(event.data);
            
            // Verificar se é mensagem de PING - não enviar para o console, apenas atualizar timestamp
            // PING pode vir como "PING" ou "PING - Sistema ativo e conectado"
            const mensagemUpper = (data.mensagem || '').trim().toUpperCase();
            if (mensagemUpper.includes('PING')) {
              setLastPing(Date.now());
              console.log('[Console WebSocket] PING recebido, atualizando heart-beat');
              return; // Não processar PING como mensagem do console
            }
            
            // Endpoint de console só recebe mensagens de console
            // Mensagens de console têm: tipo, mensagem, timestamp, nivel, plantaId
            const message: ConsoleMessage = {
              tipo: data.tipo,
              mensagem: data.mensagem,
              timestamp: data.timestamp,
              nivel: data.nivel || data.tipo,
              plantaId: data.plantaId
            };
            console.log('[Console WebSocket] Mensagem de console recebida:', message);
            
            // Salvar no histórico (mesmo quando a página do console não está aberta)
            saveMessageToHistory(message);
            
            // Usar ref para evitar dependência do callback
            onMessageRef.current(message);
          } catch (err) {
            console.error('[Console WebSocket] Erro ao processar mensagem:', err);
            console.error('[Console WebSocket] Dados recebidos:', event.data);
          }
        };

        ws.onerror = (error) => {
          console.error('[Console WebSocket] ✗ Erro na conexão:', error);
          console.error('[Console WebSocket] URL tentada:', wsUrl);
          setIsConnected(false);
          isConnectingRef.current = false;
        };

        ws.onclose = (event) => {
          console.log('[Console WebSocket] Conexão fechada. Code:', event.code, 'Reason:', event.reason);
          setIsConnected(false);
          isConnectingRef.current = false;
          
          // Tentar reconectar apenas se ainda estiver montado e flag ativa
          // E se não foi um fechamento intencional (code 1000)
          if (isMountedRef.current && shouldReconnect.current && event.code !== 1000) {
            reconnectAttempts.current++;
            const delay = Math.min(1000 * Math.pow(2, Math.min(reconnectAttempts.current, 5)), 30000);
            console.log(`[Console WebSocket] Tentando reconectar em ${delay}ms (tentativa ${reconnectAttempts.current})`);
            
            reconnectTimeoutRef.current = setTimeout(() => {
              if (isMountedRef.current && shouldReconnect.current && !isConnectingRef.current) {
                isConnectingRef.current = true;
                connect();
              }
            }, delay);
          } else {
            console.log('[Console WebSocket] Não reconectando - componente desmontado, flag desabilitada ou fechamento intencional');
          }
        };
      } catch (err) {
        console.error('[Console WebSocket] Erro ao criar conexão:', err);
        setIsConnected(false);
        isConnectingRef.current = false;
        
        if (isMountedRef.current && shouldReconnect.current) {
          reconnectAttempts.current++;
          const delay = Math.min(1000 * Math.pow(2, Math.min(reconnectAttempts.current, 5)), 30000);
          console.log(`[Console WebSocket] Tentando reconectar após erro em ${delay}ms (tentativa ${reconnectAttempts.current})`);
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
      console.log('[Console WebSocket] Cleanup: Desabilitando reconexão e fechando conexão');
      isMountedRef.current = false;
      shouldReconnect.current = false;
      isConnectingRef.current = false;
      
      if (reconnectTimeoutRef.current) {
        clearTimeout(reconnectTimeoutRef.current);
        reconnectTimeoutRef.current = null;
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
          console.error('[Console WebSocket] Erro ao fechar WebSocket:', err);
        }
        wsRef.current = null;
      }
      
      setIsConnected(false);
    };
  }, [plantaId]); // Removido onMessage das dependências - usando ref

  return { isConnected, lastPing };
}
