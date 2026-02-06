import { useState, useRef, useEffect, useCallback } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { useWebSocketConsole, ConsoleMessage } from '../hooks/useWebSocketConsole';
import { Terminal, Trash2, Download, Wifi, WifiOff } from 'lucide-react';
import './Console.css';

export default function Console() {
  const { plantaSelecionada } = useAuth();
  const [messages, setMessages] = useState<ConsoleMessage[]>([]);
  const [autoScroll, setAutoScroll] = useState(true);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const messagesContainerRef = useRef<HTMLDivElement>(null);

  // Usar useCallback para estabilizar a função e evitar re-renders
  const handleMessage = useCallback((message: ConsoleMessage) => {
    // Filtrar mensagens de PING - não devem aparecer no console
    // PING pode vir como "PING" ou "PING - Sistema ativo e conectado"
    const mensagemUpper = (message.mensagem || '').trim().toUpperCase();
    if (mensagemUpper.includes('PING')) {
      return; // Ignorar mensagens de PING
    }
    setMessages((prev) => [...prev, message]);
  }, []);

  const { isConnected, lastPing } = useWebSocketConsole(
    plantaSelecionada?.id,
    handleMessage
  );

  // Estado para controlar a animação da bolinha de ping
  const [pingActive, setPingActive] = useState(false);

  // Quando receber um novo ping, ativar a bolinha por 1 segundo
  useEffect(() => {
    if (lastPing) {
      setPingActive(true);
      const timer = setTimeout(() => {
        setPingActive(false);
      }, 1000);
      return () => clearTimeout(timer);
    }
  }, [lastPing]);

  // Log de debug no console do navegador
  useEffect(() => {
    console.log('[Console] Planta selecionada:', plantaSelecionada?.id);
    console.log('[Console] Status conexão:', isConnected);
  }, [plantaSelecionada, isConnected]);

  // Auto-scroll quando novas mensagens chegarem
  useEffect(() => {
    if (autoScroll && messagesEndRef.current) {
      messagesEndRef.current.scrollIntoView({ behavior: 'smooth' });
    }
  }, [messages, autoScroll]);

  // Detectar quando usuário rola manualmente
  const handleScroll = () => {
    if (messagesContainerRef.current) {
      const { scrollTop, scrollHeight, clientHeight } = messagesContainerRef.current;
      const isAtBottom = scrollHeight - scrollTop - clientHeight < 50;
      setAutoScroll(isAtBottom);
    }
  };

  const clearMessages = () => {
    setMessages([]);
  };

  const downloadLogs = () => {
    const logText = messages
      .map((msg) => {
        const date = new Date(msg.timestamp * 1000).toISOString();
        return `[${date}] [${msg.tipo.toUpperCase()}] ${msg.mensagem}`;
      })
      .join('\n');
    
    const blob = new Blob([logText], { type: 'text/plain' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `console-log-${new Date().toISOString().split('T')[0]}.txt`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
  };

  const getMessageClass = (tipo: string) => {
    switch (tipo) {
      case 'error':
        return 'console-message-error';
      case 'warn':
        return 'console-message-warn';
      case 'info':
        return 'console-message-info';
      default:
        return 'console-message-log';
    }
  };

  const formatTimestamp = (timestamp: number) => {
    const date = new Date(timestamp * 1000);
    return date.toLocaleTimeString('pt-BR', { 
      hour: '2-digit', 
      minute: '2-digit', 
      second: '2-digit',
      fractionalSecondDigits: 3
    });
  };


  return (
    <div className="console-page">
      <div className="console-header">
        <div className="console-title">
          <Terminal size={24} />
          <h2>Console</h2>
          <div className={`connection-status ${isConnected ? 'connected' : 'disconnected'}`}>
            {isConnected ? (
              <>
                <Wifi size={16} />
                <span>Conectado</span>
                <span className={`ping-indicator ${pingActive ? 'active' : ''}`}></span>
              </>
            ) : (
              <>
                <WifiOff size={16} />
                <span>Desconectado</span>
                {!plantaSelecionada && (
                  <span className="connection-warning"> (Selecione uma planta)</span>
                )}
              </>
            )}
          </div>
        </div>
        <div className="console-actions">
          <label className="auto-scroll-checkbox">
            <input
              type="checkbox"
              checked={autoScroll}
              onChange={(e) => setAutoScroll(e.target.checked)}
            />
            <span>Auto-scroll</span>
          </label>
          <button onClick={clearMessages} className="btn-icon" title="Limpar console">
            <Trash2 size={18} />
            Limpar
          </button>
          <button onClick={downloadLogs} className="btn-icon" title="Baixar logs">
            <Download size={18} />
            Baixar
          </button>
        </div>
      </div>

      <div 
        className="console-messages" 
        ref={messagesContainerRef}
        onScroll={handleScroll}
      >
        {messages.length === 0 ? (
          <div className="console-empty">
            <Terminal size={48} />
            <p>Nenhuma mensagem ainda</p>
            <span>As mensagens do console aparecerão aqui em tempo real</span>
          </div>
        ) : (
          messages.map((message, index) => (
            <div key={index} className={`console-message ${getMessageClass(message.tipo)}`}>
              <span className="console-timestamp">{formatTimestamp(message.timestamp)}</span>
              <span className="console-type">[{message.tipo.toUpperCase()}]</span>
              <span className="console-text">{message.mensagem}</span>
            </div>
          ))
        )}
        <div ref={messagesEndRef} />
      </div>

      <div className="console-footer">
        <span className="console-count">
          {messages.length} mensagem{messages.length !== 1 ? 's' : ''}
        </span>
        {plantaSelecionada && (
          <span className="console-planta">
            Planta: {plantaSelecionada.nome}
          </span>
        )}
      </div>
    </div>
  );
}
