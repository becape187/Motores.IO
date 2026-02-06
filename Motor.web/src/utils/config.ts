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
  if (isDevelopment()) {
    const envUrl = import.meta.env.VITE_API_URL_DEV;
    if (envUrl) {
      return envUrl;
    }
  }
  const envUrl = import.meta.env.VITE_API_URL_PROD;
  if (envUrl) {
    return envUrl;
  }
  // Padrão para produção (sem porta, usa 443 para HTTPS)
  return 'https://api.motores.automais.io';
}

/**
 * Obtém o host para WebSocket
 */
export function getWebSocketHost(): string {
  // Se tiver variável de ambiente, usar ela
  if (isDevelopment()) {
    const envHost = import.meta.env.VITE_WS_URL_DEV;
    if (envHost) {
      return envHost;
    }
    // Padrão para desenvolvimento
    return 'localhost:5000';
  }
  const envHost = import.meta.env.VITE_WS_URL_PROD;
  if (envHost) {
    return envHost;
  }
  // Padrão para produção (sem porta, usa 443 para WSS)
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
