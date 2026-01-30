import { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { api } from '../services/api';

interface Planta {
  id: string;
  nome: string;
  codigo?: string;
  clienteId: string;
  clienteNome: string;
}

interface TemaConfiguracao {
  logoPath?: string;
  corPrimaria?: string;
  corSecundaria?: string;
  corTerciaria?: string;
  corFundo?: string;
  corTexto?: string;
  coresCustomizadas?: Record<string, string>;
  estilosCSS?: Record<string, string>;
}

interface User {
  id: string;
  nome: string;
  email: string;
  perfil: string;
  plantas: Planta[];
  temaCliente?: TemaConfiguracao;
  temaUsuario?: TemaConfiguracao;
}

interface AuthContextType {
  user: User | null;
  plantaSelecionada: Planta | null;
  isAuthenticated: boolean;
  login: (email: string, senha: string) => Promise<void>;
  logout: () => void;
  setPlantaSelecionada: (planta: Planta | null) => void;
  aplicarTemas: () => void;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [plantaSelecionada, setPlantaSelecionada] = useState<Planta | null>(null);

  useEffect(() => {
    // Carregar dados do localStorage ao iniciar
    const token = localStorage.getItem('token');
    const userStr = localStorage.getItem('user');
    const plantaStr = localStorage.getItem('plantaSelecionada');

    if (token && userStr) {
      try {
        const userData = JSON.parse(userStr);
        setUser(userData);
        
        if (plantaStr) {
          const planta = JSON.parse(plantaStr);
          setPlantaSelecionada(planta);
        } else if (userData.plantas && userData.plantas.length > 0) {
          // Selecionar primeira planta por padrão
          setPlantaSelecionada(userData.plantas[0]);
          localStorage.setItem('plantaSelecionada', JSON.stringify(userData.plantas[0]));
        }
      } catch (error) {
        console.error('Erro ao carregar dados do localStorage:', error);
        localStorage.clear();
      }
    }
  }, []);

  useEffect(() => {
    if (user) {
      aplicarTemas();
    }
  }, [user, plantaSelecionada]);

  const aplicarTemas = () => {
    if (!user) return;

    const root = document.documentElement;
    
    // Aplicar tema do usuário primeiro (tem prioridade)
    if (user.temaUsuario) {
      aplicarTema(user.temaUsuario, root);
    }
    
    // Depois aplicar tema do cliente (pode ser sobrescrito pelo tema do usuário)
    if (user.temaCliente) {
      aplicarTema(user.temaCliente, root, false);
    }
  };

  const aplicarTema = (tema: TemaConfiguracao, root: HTMLElement, sobrescrever: boolean = true) => {
    if (tema.corPrimaria && (sobrescrever || !root.style.getPropertyValue('--primary-color'))) {
      root.style.setProperty('--primary-color', tema.corPrimaria);
    }
    if (tema.corSecundaria && (sobrescrever || !root.style.getPropertyValue('--secondary-color'))) {
      root.style.setProperty('--secondary-color', tema.corSecundaria);
    }
    if (tema.corTerciaria && (sobrescrever || !root.style.getPropertyValue('--tertiary-color'))) {
      root.style.setProperty('--tertiary-color', tema.corTerciaria);
    }
    if (tema.corFundo && (sobrescrever || !root.style.getPropertyValue('--bg-color'))) {
      root.style.setProperty('--bg-color', tema.corFundo);
    }
    if (tema.corTexto && (sobrescrever || !root.style.getPropertyValue('--text-color'))) {
      root.style.setProperty('--text-color', tema.corTexto);
    }

    // Aplicar cores customizadas
    if (tema.coresCustomizadas) {
      Object.entries(tema.coresCustomizadas).forEach(([key, value]) => {
        if (sobrescrever || !root.style.getPropertyValue(`--${key}`)) {
          root.style.setProperty(`--${key}`, value);
        }
      });
    }

    // Aplicar estilos CSS customizados
    if (tema.estilosCSS) {
      Object.entries(tema.estilosCSS).forEach(([key, value]) => {
        const element = document.querySelector(key);
        if (element && element instanceof HTMLElement) {
          Object.entries(value).forEach(([prop, val]) => {
            element.style.setProperty(prop, val);
          });
        }
      });
    }
  };

  const login = async (email: string, senha: string) => {
    const response = await api.login(email, senha);
    
    const userData: User = {
      id: response.usuarioId,
      nome: response.nome,
      email: response.email,
      perfil: response.perfil,
      plantas: response.plantas,
      temaCliente: response.temaCliente,
      temaUsuario: response.temaUsuario,
    };

    localStorage.setItem('token', response.token);
    localStorage.setItem('user', JSON.stringify(userData));
    
    if (userData.plantas && userData.plantas.length > 0) {
      const primeiraPlanta = userData.plantas[0];
      setPlantaSelecionada(primeiraPlanta);
      localStorage.setItem('plantaSelecionada', JSON.stringify(primeiraPlanta));
    }

    setUser(userData);
  };

  const logout = () => {
    localStorage.removeItem('token');
    localStorage.removeItem('user');
    localStorage.removeItem('plantaSelecionada');
    setUser(null);
    setPlantaSelecionada(null);
    
    // Resetar estilos CSS customizados
    const root = document.documentElement;
    root.style.removeProperty('--primary-color');
    root.style.removeProperty('--secondary-color');
    root.style.removeProperty('--tertiary-color');
    root.style.removeProperty('--bg-color');
    root.style.removeProperty('--text-color');
  };

  const handleSetPlantaSelecionada = (planta: Planta | null) => {
    setPlantaSelecionada(planta);
    if (planta) {
      localStorage.setItem('plantaSelecionada', JSON.stringify(planta));
    } else {
      localStorage.removeItem('plantaSelecionada');
    }
  };

  return (
    <AuthContext.Provider
      value={{
        user,
        plantaSelecionada,
        isAuthenticated: !!user,
        login,
        logout,
        setPlantaSelecionada: handleSetPlantaSelecionada,
        aplicarTemas,
      }}
    >
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth deve ser usado dentro de um AuthProvider');
  }
  return context;
}
