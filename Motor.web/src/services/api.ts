const API_BASE_URL = import.meta.env.VITE_API_URL || 'https://api.motores.automais.io/api';

class ApiService {
  private getToken(): string | null {
    return localStorage.getItem('token');
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const token = this.getToken();
    
    // Criar headers de forma type-safe usando Record
    const headersObj: Record<string, string> = {
      'Content-Type': 'application/json',
    };
    
    if (token) {
      headersObj['Authorization'] = `Bearer ${token}`;
    }
    
    // Mesclar headers existentes se houver
    if (options.headers) {
      const existingHeaders = options.headers as Record<string, string>;
      Object.keys(existingHeaders).forEach((key) => {
        headersObj[key] = existingHeaders[key];
      });
    }

    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      ...options,
      headers: headersObj,
    });

    if (!response.ok) {
      if (response.status === 401) {
        // Token inválido ou expirado
        localStorage.removeItem('token');
        localStorage.removeItem('user');
        localStorage.removeItem('plantas');
        window.location.href = '/login';
        throw new Error('Sessão expirada. Por favor, faça login novamente.');
      }
      const error = await response.json().catch(() => ({ message: 'Erro na requisição' }));
      throw new Error(error.message || `Erro: ${response.status}`);
    }

    // Se a resposta for 204 No Content ou não tiver conteúdo, retornar void
    if (response.status === 204 || response.headers.get('content-length') === '0') {
      return undefined as T;
    }

    // Verificar se há conteúdo antes de fazer parse
    const contentType = response.headers.get('content-type');
    if (contentType && contentType.includes('application/json')) {
      const text = await response.text();
      return text ? JSON.parse(text) : undefined as T;
    }

    return undefined as T;
  }

  // Auth
  async login(email: string, senha: string) {
    return this.request<{
      token: string;
      usuarioId: string;
      nome: string;
      email: string;
      perfil: string;
      plantas: Array<{
        id: string;
        nome: string;
        codigo?: string;
        clienteId: string;
        clienteNome: string;
      }>;
      temaCliente?: {
        logoPath?: string;
        corPrimaria?: string;
        corSecundaria?: string;
        corTerciaria?: string;
        corFundo?: string;
        corTexto?: string;
        coresCustomizadas?: Record<string, string>;
        estilosCSS?: Record<string, string>;
      };
      temaUsuario?: {
        logoPath?: string;
        corPrimaria?: string;
        corSecundaria?: string;
        corTerciaria?: string;
        corFundo?: string;
        corTexto?: string;
        coresCustomizadas?: Record<string, string>;
        estilosCSS?: Record<string, string>;
      };
    }>('/auth/login', {
      method: 'POST',
      body: JSON.stringify({ email, senha }),
    });
  }

  // Motores
  async getMotores(plantaId?: string) {
    const query = plantaId ? `?plantaId=${plantaId}` : '';
    return this.request<Array<any>>(`/motors${query}`);
  }

  async getMotor(id: string) {
    return this.request<any>(`/motors/${id}`);
  }

  async createMotor(motor: any) {
    return this.request<any>('/motors', {
      method: 'POST',
      body: JSON.stringify(motor),
    });
  }

  // Atualizar motor completo (DEPRECATED - usar endpoints específicos)
  async updateMotor(id: string, motor: any) {
    return this.request<any>(`/motors/${id}`, {
      method: 'PUT',
      body: JSON.stringify(motor),
    });
  }

  // Atualizar apenas configuração do motor
  async updateMotorConfiguracao(id: string, configuracao: {
    nome: string;
    potencia: number;
    tensao: number;
    correnteNominal: number;
    percentualCorrenteMaxima: number;
    histerese: number;
    registroModBus?: string;
    registroLocal?: string;
    habilitado: boolean;
    plantaId?: string;
  }) {
    return this.request<void>(`/motors/${id}/configuracao`, {
      method: 'PATCH',
      body: JSON.stringify(configuracao),
    });
  }

  // Atualizar apenas posição do motor
  async updateMotorPosicao(id: string, posicao: {
    posicaoX?: number;
    posicaoY?: number;
  }) {
    return this.request<void>(`/motors/${id}/posicao`, {
      method: 'PATCH',
      body: JSON.stringify(posicao),
    });
  }

  // Atualizar apenas dados de manutenção
  async updateMotorManutencao(id: string, manutencao: {
    horimetroProximaManutencao?: number;
    dataEstimadaProximaManutencao?: Date;
  }) {
    return this.request<void>(`/motors/${id}/manutencao`, {
      method: 'PATCH',
      body: JSON.stringify(manutencao),
    });
  }

  async deleteMotor(id: string) {
    return this.request<void>(`/motors/${id}`, {
      method: 'DELETE',
    });
  }

  // Plantas
  async getPlantasPorUsuario() {
    return this.request<Array<{
      id: string;
      nome: string;
      codigo?: string;
      clienteId: string;
      cliente: {
        id: string;
        nome: string;
      };
    }>>('/plantas/por-usuario');
  }

  // Alarmes
  async getAlarmes(reconhecido?: boolean) {
    const query = reconhecido !== undefined ? `?reconhecido=${reconhecido}` : '';
    return this.request<Array<any>>(`/alarms${query}`);
  }

  // Histórico
  async getHistorico(motorId?: string, dataInicio?: Date, dataFim?: Date) {
    const params = new URLSearchParams();
    if (motorId) params.append('motorId', motorId);
    if (dataInicio) params.append('dataInicio', dataInicio.toISOString());
    if (dataFim) params.append('dataFim', dataFim.toISOString());
    const query = params.toString() ? `?${params.toString()}` : '';
    return this.request<Array<any>>(`/history${query}`);
  }

  // Manutenção
  async getOrdensServico(motorId?: string, status?: string) {
    const params = new URLSearchParams();
    if (motorId) params.append('motorId', motorId);
    if (status) params.append('status', status);
    const query = params.toString() ? `?${params.toString()}` : '';
    return this.request<Array<any>>(`/maintenance/orders${query}`);
  }

  // Usuários
  async getUsuarios(ativo?: boolean) {
    const query = ativo !== undefined ? `?ativo=${ativo}` : '';
    return this.request<Array<any>>(`/users${query}`);
  }

  async getUsuario(id: string) {
    return this.request<any>(`/users/${id}`);
  }

  async createUsuario(usuario: {
    nome: string;
    email: string;
    senha: string;
    perfil: string;
    ativo: boolean;
    clienteId: string;
    plantaIds?: string[];
  }) {
    return this.request<any>('/users', {
      method: 'POST',
      body: JSON.stringify(usuario),
    });
  }

  async updateUsuario(id: string, usuario: {
    id: string;
    nome: string;
    email: string;
    senha?: string;
    perfil: string;
    ativo: boolean;
    clienteId: string;
    plantaIds?: string[];
  }) {
    return this.request<void>(`/users/${id}`, {
      method: 'PUT',
      body: JSON.stringify(usuario),
    });
  }

  async deleteUsuario(id: string) {
    return this.request<void>(`/users/${id}`, {
      method: 'DELETE',
    });
  }

  // Clientes
  async getClientes(ativo?: boolean) {
    const query = ativo !== undefined ? `?ativo=${ativo}` : '';
    return this.request<Array<{
      id: string;
      nome: string;
      cnpj?: string;
      email?: string;
      telefone?: string;
      ativo: boolean;
    }>>(`/clientes${query}`);
  }

  // Plantas por cliente
  async getPlantasPorCliente(clienteId: string) {
    const plantas = await this.request<Array<{
      id: string;
      nome: string;
      codigo?: string;
      clienteId: string;
      cliente?: {
        id: string;
        nome: string;
      };
    }>>(`/plantas?clienteId=${clienteId}&ativo=true`);
    
    // Converter para o formato esperado pelo frontend
    return plantas?.map(p => ({
      id: p.id,
      nome: p.nome,
      codigo: p.codigo,
      clienteId: p.clienteId,
      clienteNome: p.cliente?.nome || '',
    })) || [];
  }

  // Plantas disponíveis para admin associar a usuários
  async getPlantasDisponiveis(clienteId?: string) {
    const query = clienteId ? `?clienteId=${clienteId}` : '';
    return this.request<Array<{
      id: string;
      nome: string;
      codigo?: string;
      clienteId: string;
    }>>(`/users/plantas-disponiveis${query}`);
  }

  // Tokens de Planta
  async gerarTokenPlanta(plantaId: string) {
    return this.request<{
      token: string;
      geradoEm: string;
      mensagem: string;
    }>(`/plantas/${plantaId}/gerar-token`, {
      method: 'POST',
    });
  }

  async verificarTokenPlanta(plantaId: string) {
    return this.request<{
      possuiToken: boolean;
      tokenOculto?: string;
      geradoEm?: string;
    }>(`/plantas/${plantaId}/token`);
  }
}

export const api = new ApiService();
