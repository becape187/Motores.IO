import { useRef, useCallback } from 'react';
import { getWebSocketUrl } from '../utils/config';

interface TabelaInfo {
  nome: string;
  linhas: number;
}

interface QueryResult {
  dados: any[];
  colunas: string[];
  totalLinhas: number;
}

export function useWebSocketDatabase(plantaId: string | undefined) {
  const wsRef = useRef<WebSocket | null>(null);
  const pendingRequests = useRef<Map<string, {
    resolve: (value: any) => void;
    reject: (error: Error) => void;
  }>>(new Map());
  const requestIdCounter = useRef(0);

  const connect = useCallback((): Promise<WebSocket> => {
    return new Promise((resolve, reject) => {
      if (!plantaId) {
        reject(new Error('Planta não selecionada'));
        return;
      }

      if (wsRef.current?.readyState === WebSocket.OPEN) {
        resolve(wsRef.current);
        return;
      }

      const wsUrl = getWebSocketUrl('console', plantaId);
      const ws = new WebSocket(wsUrl);

      ws.onopen = () => {
        wsRef.current = ws;
        resolve(ws);
      };

      ws.onerror = () => {
        reject(new Error('Erro ao conectar WebSocket'));
      };

      ws.onmessage = (event) => {
        try {
          const message = JSON.parse(event.data);
          
          if (message.requestId && pendingRequests.current.has(message.requestId)) {
            const { resolve, reject } = pendingRequests.current.get(message.requestId)!;
            pendingRequests.current.delete(message.requestId);
            
            if (message.erro || !message.sucesso) {
              reject(new Error(message.erro || 'Erro ao executar comando'));
            } else {
              resolve(message);
            }
          }
        } catch (err) {
          console.error('[Database WebSocket] Erro ao processar mensagem:', err);
        }
      };

      ws.onclose = () => {
        wsRef.current = null;
      };
    });
  }, [plantaId]);

  const sendCommand = useCallback(async (acao: string, params: any = {}): Promise<any> => {
    try {
      const ws = await connect();
      const requestId = `db_${++requestIdCounter.current}_${Date.now()}`;

      return new Promise((resolve, reject) => {
        pendingRequests.current.set(requestId, { resolve, reject });

        const comando = {
          tipo: 'database',
          acao,
          requestId,
          ...params
        };

        ws.send(JSON.stringify(comando));

        // Timeout de 10 segundos
        setTimeout(() => {
          if (pendingRequests.current.has(requestId)) {
            pendingRequests.current.delete(requestId);
            reject(new Error('Timeout ao executar comando'));
          }
        }, 10000);
      });
    } catch (err: any) {
      throw new Error(err.message || 'Erro ao enviar comando');
    }
  }, [connect]);

  const listarTabelas = useCallback(async (): Promise<{ tabelas: TabelaInfo[] }> => {
    return await sendCommand('listarTabelas');
  }, [sendCommand]);

  const consultarTabela = useCallback(async (
    nomeTabela: string,
    pagina: number = 1,
    tamanhoPagina: number = 50
  ): Promise<QueryResult> => {
    return await sendCommand('consultarTabela', {
      tabela: nomeTabela,
      pagina,
      tamanhoPagina
    });
  }, [sendCommand]);

  const isConnected = wsRef.current?.readyState === WebSocket.OPEN;

  return {
    isConnected,
    listarTabelas,
    consultarTabela
  };
}
