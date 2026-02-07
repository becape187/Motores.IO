import { useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useWebSocketConsole, ConsoleMessage } from '../hooks/useWebSocketConsole';

/**
 * Componente invisível que mantém o WebSocket do console conectado
 * apenas para salvar mensagens no histórico, mesmo quando a página
 * do console não está aberta.
 */
export default function ConsoleHistoryListener() {
  const { plantaSelecionada } = useAuth();

  // Callback que apenas salva no histórico (não precisa fazer nada mais)
  const handleMessage = (message: ConsoleMessage) => {
    // A função saveMessageToHistory já é chamada automaticamente
    // no useWebSocketConsole, então não precisamos fazer nada aqui
    // Este componente apenas mantém o WebSocket conectado
  };

  // Manter WebSocket conectado sempre (mesmo quando Console não está aberto)
  useWebSocketConsole(plantaSelecionada?.id, handleMessage);

  // Componente invisível (não renderiza nada)
  return null;
}
