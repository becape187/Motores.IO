const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://127.0.0.1:5000/api';

class ApiService {
  private getToken(): string | null {
    return localStorage.getItem('token');
  }

  private async request<T>(
    endpoint: string,
    options: RequestInit = {}
  ): Promise<T> {
    const token = this.getToken();
    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      ...(options.headers as Record<string, string>),
    };

    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const response = await fetch(`${API_BASE_URL}${endpoint}`, {
      ...options,
      headers,
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

    return response.json();
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

  async updateMotor(id: string, motor: any) {
    return this.request<any>(`/motors/${id}`, {
      method: 'PUT',
      body: JSON.stringify(motor),
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
}

export const api = new ApiService();
