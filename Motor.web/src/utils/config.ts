/**
 * Configuração inteligente de URLs baseada no ambiente
 * Detecta automaticamente se está em desenvolvimento (localhost) ou produção
 */

/**
 * Detecta se está rodando em desenvolvimento local
 */
function isDevelopment(): boolean {
  // Verificar se está em localhost ou IP local
  if (typeof window !== 'undefined') {
    const hostname = window.location.hostname;
    // localhost ou 127.0.0.1 = desenvolvimento
    if (hostname === 'localhost' || hostname === '127.0.0.1') {
      return true;
    }
    // IPs privados (192.168.x.x, 10.x.x.x, 172.16-31.x.x) = desenvolvimento
    if (hostname.startsWith('192.168.') || 
        hostname.startsWith('10.') || 
        (hostname.startsWith('172.') && /^172\.(1[6-9]|2[0-9]|3[0-1])\./.test(hostname))) {
      return true;
    }
  }
  // Verificar variável de ambiente do Vite
  return import.meta.env.DEV || import.meta.env.MODE === 'development';
}

/**
 * Obtém a URL base da API
 */
export function getApiBaseUrl(): string {
  // Se tiver variável de ambiente, usar ela
  const envUrl = import.meta.env.VITE_API_URL;
  if (envUrl) {
    return envUrl;
  }

  // Se estiver em desenvolvimento, usar localhost
  if (isDevelopment()) {
    return 'http://localhost:5000/api';
  }

  // Produção: usar a API do servidor
  return 'https://api.motores.automais.io/api';
}

/**
 * Obtém o host para WebSocket
 */
export function getWebSocketHost(): string {
  // Se tiver variável de ambiente, usar ela
  const envHost = import.meta.env.VITE_WS_URL;
  if (envHost) {
    return envHost;
  }

  // Se estiver em desenvolvimento, usar localhost
  if (isDevelopment()) {
    return 'localhost:5000';
  }

  // Produção: usar o host da API
  return 'api.motores.automais.io';
}

/**
 * Obtém o protocolo WebSocket baseado no protocolo atual
 */
export function getWebSocketProtocol(): string {
  return window.location.protocol === 'https:' ? 'wss:' : 'ws:';
}

/**
 * Constrói a URL completa do WebSocket
 */
export function getWebSocketUrl(endpoint: string, plantaId?: string): string {
  const protocol = getWebSocketProtocol();
  const host = getWebSocketHost();
  const plantaParam = plantaId ? `?plantaId=${plantaId}` : '?plantaId=all';
  return `${protocol}//${host}/api/websocket/${endpoint}${plantaParam}`;
}
