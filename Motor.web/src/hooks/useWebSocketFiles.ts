import { useEffect, useRef, useState } from 'react';
import { getWebSocketUrl } from '../utils/config';

export interface FileCommandResponse {
  sucesso: boolean;
  erro?: string;
  dados?: any;
  acao: string;
  requestId: string;
}

export function useWebSocketFiles(
  plantaId: string | undefined,
  onResponse?: (response: FileCommandResponse) => void
) {
  const [isConnected, setIsConnected] = useState(false);
  const wsRef = useRef<WebSocket | null>(null);
  const reconnectTimeoutRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const reconnectAttempts = useRef(0);
  const shouldReconnect = useRef(true);
  const isMountedRef = useRef(true);
  const isConnectingRef = useRef(false);
  const onResponseRef = useRef(onResponse);
  const pendingRequests = useRef<Map<string, (response: FileCommandResponse) => void>>(new Map());

  // Atualizar referência do callback sem causar re-render
  useEffect(() => {
    onResponseRef.current = onResponse;
  }, [onResponse]);

  useEffect(() => {
    // Verificar se já está conectando para evitar múltiplas conexões
    if (isConnectingRef.current) {
      console.log('[Files WebSocket] Já está conectando, ignorando nova tentativa');
      return;
    }

    if (!plantaId) {
      shouldReconnect.current = false;
      if (wsRef.current) {
        wsRef.current.close();
        wsRef.current = null;
        setIsConnected(false);
      }
      return;
    }

    // Resetar flag de montagem
    isMountedRef.current = true;
    shouldReconnect.current = true;
    isConnectingRef.current = true;
    
    // Usar função inteligente para construir URL do WebSocket
    // Por enquanto, vamos usar o endpoint de console para verificar conexão
    // Ou podemos criar um endpoint específico para arquivos
    const wsUrl = getWebSocketUrl('console', plantaId);

    console.log('[Files WebSocket] Conectando ao endpoint:', wsUrl);
    console.log('[Files WebSocket] PlantaId:', plantaId);

    const connect = () => {
      // Verificar se ainda está montado e se deve reconectar
      if (!isMountedRef.current || !shouldReconnect.current) {
        console.log('[Files WebSocket] Reconexão desabilitada ou componente desmontado');
        return;
      }

      try {
        const ws = new WebSocket(wsUrl);
        wsRef.current = ws;

        ws.onopen = () => {
          console.log('[Files WebSocket] ✓ Conectado com sucesso para planta:', plantaId);
          setIsConnected(true);
          reconnectAttempts.current = 0;
          isConnectingRef.current = false;
        };

        ws.onmessage = (event) => {
          try {
            const data = JSON.parse(event.data);
            
            // Verificar se é mensagem de PING - apenas atualizar status
            const mensagemUpper = (data.mensagem || '').trim().toUpperCase();
            if (mensagemUpper.includes('PING')) {
              // PING indica que a conexão está ativa
              return;
            }
            
            // Verificar se é resposta de comando de arquivo
            if (data.requestId && data.acao) {
              const response: FileCommandResponse = {
                sucesso: data.sucesso || false,
                erro: data.erro,
                dados: data.dados,
                acao: data.acao,
                requestId: data.requestId
              };

              // Verificar se há callback pendente para este requestId
              const callback = pendingRequests.current.get(data.requestId);
              if (callback) {
                callback(response);
                pendingRequests.current.delete(data.requestId);
              }

              // Chamar callback geral se configurado
              if (onResponseRef.current) {
                onResponseRef.current(response);
              }
            }
          } catch (err) {
            console.error('[Files WebSocket] Erro ao processar mensagem:', err);
            console.error('[Files WebSocket] Dados recebidos:', event.data);
          }
        };

        ws.onerror = (error) => {
          console.error('[Files WebSocket] ✗ Erro na conexão:', error);
          setIsConnected(false);
          isConnectingRef.current = false;
        };

        ws.onclose = (event) => {
          console.log('[Files WebSocket] Conexão fechada. Code:', event.code, 'Reason:', event.reason);
          setIsConnected(false);
          isConnectingRef.current = false;
          
          // Limpar callbacks pendentes
          pendingRequests.current.clear();
          
          // Tentar reconectar apenas se ainda estiver montado e flag ativa
          // E se não foi um fechamento intencional (code 1000)
          if (isMountedRef.current && shouldReconnect.current && event.code !== 1000) {
            reconnectAttempts.current++;
            const delay = Math.min(1000 * Math.pow(2, Math.min(reconnectAttempts.current, 5)), 30000);
            console.log(`[Files WebSocket] Tentando reconectar em ${delay}ms (tentativa ${reconnectAttempts.current})`);
            
            reconnectTimeoutRef.current = setTimeout(() => {
              if (isMountedRef.current && shouldReconnect.current && !isConnectingRef.current) {
                isConnectingRef.current = true;
                connect();
              }
            }, delay);
          } else {
            console.log('[Files WebSocket] Não reconectando - componente desmontado, flag desabilitada ou fechamento intencional');
          }
        };
      } catch (err) {
        console.error('[Files WebSocket] Erro ao criar conexão:', err);
        setIsConnected(false);
        isConnectingRef.current = false;
        
        if (isMountedRef.current && shouldReconnect.current) {
          reconnectAttempts.current++;
          const delay = Math.min(1000 * Math.pow(2, Math.min(reconnectAttempts.current, 5)), 30000);
          console.log(`[Files WebSocket] Tentando reconectar após erro em ${delay}ms (tentativa ${reconnectAttempts.current})`);
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
      console.log('[Files WebSocket] Cleanup: Desabilitando reconexão e fechando conexão');
      isMountedRef.current = false;
      shouldReconnect.current = false;
      isConnectingRef.current = false;
      
      // Limpar callbacks pendentes
      pendingRequests.current.clear();
      
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
          console.error('[Files WebSocket] Erro ao fechar WebSocket:', err);
        }
        wsRef.current = null;
      }
      
      setIsConnected(false);
    };
  }, [plantaId]); // Removido onResponse das dependências - usando ref

  // Função para enviar comando via WebSocket (opcional, para uso futuro)
  const sendCommand = (command: any, callback?: (response: FileCommandResponse) => void): boolean => {
    if (!wsRef.current || wsRef.current.readyState !== WebSocket.OPEN) {
      console.error('[Files WebSocket] WebSocket não está conectado');
      return false;
    }

    const requestId = command.requestId || crypto.randomUUID();
    command.requestId = requestId;

    if (callback) {
      pendingRequests.current.set(requestId, callback);
    }

    try {
      wsRef.current.send(JSON.stringify(command));
      return true;
    } catch (err) {
      console.error('[Files WebSocket] Erro ao enviar comando:', err);
      pendingRequests.current.delete(requestId);
      return false;
    }
  };

  return { isConnected, sendCommand };
}
