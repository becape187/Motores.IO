import { useEffect, useCallback } from 'react';
import { ConsoleMessage } from './useWebSocketConsole';

const CONSOLE_HISTORY_KEY = 'console_history';
const MAX_HISTORY_SIZE = 1000; // Limitar a 1000 mensagens

export function useConsoleHistory() {
  // Carregar histórico do localStorage
  const loadHistory = useCallback((): ConsoleMessage[] => {
    try {
      const stored = localStorage.getItem(CONSOLE_HISTORY_KEY);
      if (stored) {
        const history = JSON.parse(stored);
        // Garantir que é um array
        return Array.isArray(history) ? history : [];
      }
    } catch (err) {
      console.error('[Console History] Erro ao carregar histórico:', err);
    }
    return [];
  }, []);

  // Salvar mensagem no histórico
  const saveMessage = useCallback((message: ConsoleMessage) => {
    try {
      const history = loadHistory();
      
      // Adicionar nova mensagem
      history.push(message);
      
      // Limitar tamanho do histórico (manter apenas as últimas MAX_HISTORY_SIZE mensagens)
      if (history.length > MAX_HISTORY_SIZE) {
        const excess = history.length - MAX_HISTORY_SIZE;
        history.splice(0, excess);
      }
      
      // Salvar no localStorage
      localStorage.setItem(CONSOLE_HISTORY_KEY, JSON.stringify(history));
    } catch (err) {
      console.error('[Console History] Erro ao salvar mensagem:', err);
    }
  }, [loadHistory]);

  // Limpar histórico
  const clearHistory = useCallback(() => {
    try {
      localStorage.removeItem(CONSOLE_HISTORY_KEY);
    } catch (err) {
      console.error('[Console History] Erro ao limpar histórico:', err);
    }
  }, []);

  return {
    loadHistory,
    saveMessage,
    clearHistory
  };
}

// Hook para salvar mensagens automaticamente (pode ser usado fora do componente Console)
export function useConsoleHistoryAutoSave() {
  const { saveMessage } = useConsoleHistory();

  // Criar um listener global para mensagens do console WebSocket
  useEffect(() => {
    // Esta função será chamada sempre que uma mensagem chegar
    // Mesmo quando a página do console não está aberta
    const handleStorageMessage = (_event: StorageEvent) => {
      // Não fazer nada aqui, apenas garantir que o listener existe
      // As mensagens serão salvas diretamente no hook useWebSocketConsole
    };

    window.addEventListener('storage', handleStorageMessage);

    return () => {
      window.removeEventListener('storage', handleStorageMessage);
    };
  }, []);

  return { saveMessage };
}
