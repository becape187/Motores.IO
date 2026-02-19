import { ReactNode, useState, useEffect, useRef } from 'react';
import { Link, useLocation } from 'react-router-dom';
import { 
  LayoutDashboard, 
  Cog, 
  History, 
  AlertTriangle, 
  Users, 
  Menu, 
  X,
  LogOut,
  Bell,
  Wrench,
  Building2,
  ChevronDown,
  Key,
  Terminal,
  File,
  Database
} from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { api } from '../services/api';
import ConsoleHistoryListener from './ConsoleHistoryListener';
import './Layout.css';

interface LayoutProps {
  children: ReactNode;
  onLogout: () => void;
}

function Layout({ children, onLogout }: LayoutProps) {
  const location = useLocation();
  const { user, plantaSelecionada, clienteSelecionado, clientesSelecionados, setPlantaSelecionada, setClientesSelecionados } = useAuth();
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);
  const [isClienteDropdownOpen, setIsClienteDropdownOpen] = useState(false);
  const [isUserMenuOpen, setIsUserMenuOpen] = useState(false);
  const [clientes, setClientes] = useState<Array<{id: string; nome: string; ativo: boolean}>>([]);
  const [plantasDoCliente, setPlantasDoCliente] = useState<Array<{id: string; nome: string; codigo?: string; clienteId: string; clienteNome: string}>>([]);
  const [isDesktop, setIsDesktop] = useState(typeof window !== 'undefined' && window.innerWidth > 1200);
  const sidebarCollapseTimerRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // Nomes de exibição: Sigil pedreira -> Morro Grande, PADRAO -> Sigil
  const nomeExibicaoCliente = (nome: string) => {
    if (!nome) return nome;
    const n = nome.trim();
    if (n.toLowerCase().includes('sigil')) return 'Morro Grande';
    if (n === 'PADRAO' || n.toLowerCase().includes('morro grande')) return 'Sigil';
    return nome;
  };

  // Fechar sidebar ao clicar em um item no mobile
  const handleNavClick = () => {
    if (window.innerWidth <= 1200) {
      setIsSidebarOpen(false);
    }
  };

  // Ajustar sidebar ao redimensionar: desktop = sem botão, mobile = com botão
  useEffect(() => {
    const handleResize = () => {
      const desktop = window.innerWidth > 1200;
      setIsDesktop(desktop);
      if (!desktop) {
        setIsSidebarOpen(false);
        if (sidebarCollapseTimerRef.current) {
          clearTimeout(sidebarCollapseTimerRef.current);
          sidebarCollapseTimerRef.current = null;
        }
      }
    };
    handleResize();
    window.addEventListener('resize', handleResize);
    return () => {
      window.removeEventListener('resize', handleResize);
      if (sidebarCollapseTimerRef.current) clearTimeout(sidebarCollapseTimerRef.current);
    };
  }, []);

  // Mobile: travar scroll da página quando a sidebar estiver aberta (evita rolagem "atravessar" a barra)
  useEffect(() => {
    const isMobile = !isDesktop;
    if (isMobile && isSidebarOpen) {
      document.body.classList.add('sidebar-open-mobile');
    } else {
      document.body.classList.remove('sidebar-open-mobile');
    }
    return () => document.body.classList.remove('sidebar-open-mobile');
  }, [isDesktop, isSidebarOpen]);

  // PC: expandir ao passar o mouse na sidebar; colapsar 5s após sair ou ao clicar fora
  const handleSidebarMouseEnter = () => {
    if (!isDesktop) return;
    if (sidebarCollapseTimerRef.current) {
      clearTimeout(sidebarCollapseTimerRef.current);
      sidebarCollapseTimerRef.current = null;
    }
    setIsSidebarOpen(true);
  };
  const handleSidebarMouseLeave = () => {
    if (!isDesktop) return;
    if (sidebarCollapseTimerRef.current) clearTimeout(sidebarCollapseTimerRef.current);
    sidebarCollapseTimerRef.current = setTimeout(() => setIsSidebarOpen(false), 5000);
  };
  const handleSidebarClick = () => {
    if (isDesktop && !isSidebarOpen) setIsSidebarOpen(true);
  };
  const handleMainContentClick = () => {
    if (isDesktop && isSidebarOpen) {
      if (sidebarCollapseTimerRef.current) clearTimeout(sidebarCollapseTimerRef.current);
      setIsSidebarOpen(false);
    }
  };

  // Carregar clientes se perfil for global
  useEffect(() => {
    if (user?.perfil === 'global') {
      api.getClientes(true).then(setClientes).catch(console.error);
    }
  }, [user]);

  // Carregar plantas de todos os clientes selecionados (quando múltiplos, busca de todos e seleciona a primeira disponível)
  useEffect(() => {
    if (user?.perfil === 'global') {
      if (clientesSelecionados.length > 0) {
        // Buscar plantas de todos os clientes selecionados
        Promise.all(
          clientesSelecionados
            .filter(c => c.id)
            .map(cliente => 
              api.getPlantasPorCliente(cliente.id)
                .then(plantas => ({ cliente, plantas: Array.isArray(plantas) ? plantas : [] }))
                .catch(err => {
                  console.error(`Erro ao carregar plantas do cliente ${cliente.nome}:`, err);
                  return { cliente, plantas: [] };
                })
            )
        )
          .then(resultados => {
            // Juntar todas as plantas encontradas
            const todasPlantas = resultados.flatMap(r => r.plantas);
            setPlantasDoCliente(todasPlantas);
            // Selecionar a primeira planta disponível (de qualquer cliente)
            if (todasPlantas.length > 0) {
              setPlantaSelecionada(todasPlantas[0]);
            } else {
              setPlantaSelecionada(null);
            }
          });
      } else {
        setPlantasDoCliente([]);
        setPlantaSelecionada(null);
      }
    } else if (user?.perfil !== 'global') {
      setPlantasDoCliente(user?.plantas || []);
    }
  }, [clientesSelecionados, user]);

  // Se não for global e não tiver cliente selecionado, usar primeira planta do usuário
  useEffect(() => {
    if (user?.perfil !== 'global' && user?.plantas && user.plantas.length > 0 && !plantaSelecionada) {
      setPlantaSelecionada(user.plantas[0]);
    } else if (user?.perfil !== 'global' && plantasDoCliente.length > 0 && !plantaSelecionada) {
      // Se não for global e tiver plantas carregadas mas nenhuma selecionada, selecionar a primeira
      setPlantaSelecionada(plantasDoCliente[0]);
    }
  }, [user, plantaSelecionada, plantasDoCliente]);

  const menuItems = [
    { path: '/', icon: LayoutDashboard, label: 'Principal' },
    { path: '/motors', icon: Cog, label: 'Motores' },
    { path: '/history', icon: History, label: 'Histórico' },
    { path: '/maintenance', icon: Wrench, label: 'Manutenção' },
    { path: '/alarms', icon: AlertTriangle, label: 'Alarmes' },
    { path: '/users', icon: Users, label: 'Usuários' },
  ];

  // Menu Avançado (apenas para usuários global)
  const advancedMenuItems = user?.perfil === 'global' ? [
    { path: '/tokens', icon: Key, label: 'Tokens de API' },
    { path: '/console', icon: Terminal, label: 'Console' },
    { path: '/files', icon: File, label: 'Arquivos' },
    { path: '/database', icon: Database, label: 'Banco de Dados' },
  ] : [];

  return (
    <div className="layout">
      {/* Componente invisível para manter histórico do console sempre atualizado */}
      <ConsoleHistoryListener />
      
      {/* Overlay para mobile: bloqueia toque/scroll na página; só fecha ao tocar no overlay */}
      {isSidebarOpen && (
        <div
          className="sidebar-overlay"
          onClick={() => setIsSidebarOpen(false)}
          onTouchMove={(e) => e.preventDefault()}
          role="button"
          tabIndex={-1}
          aria-label="Fechar menu"
        />
      )}

      {/* Sidebar */}
      <aside
        className={`sidebar ${isSidebarOpen ? 'open' : 'closed'} ${isDesktop ? 'sidebar--desktop' : ''}`}
        onMouseEnter={handleSidebarMouseEnter}
        onMouseLeave={handleSidebarMouseLeave}
        onClick={handleSidebarClick}
      >
        <div className="sidebar-header">
          <div className="sidebar-logo">
            <div className="logo-icon">
              <Cog size={32} />
            </div>
            {isSidebarOpen && (
              <div className="logo-text">
                <h2>Pedreira</h2>
                <span>Monitoring</span>
              </div>
            )}
          </div>
        </div>

        <nav className="sidebar-nav">
          {menuItems.map((item) => {
            const Icon = item.icon;
            const isActive = location.pathname === item.path;
            
            return (
              <Link
                key={item.path}
                to={item.path}
                className={`nav-item ${isActive ? 'active' : ''}`}
                title={!isSidebarOpen ? item.label : undefined}
                onClick={handleNavClick}
              >
                <Icon size={22} />
                {isSidebarOpen && <span>{item.label}</span>}
                {isActive && <div className="active-indicator"></div>}
              </Link>
            );
          })}

          {/* Menu Avançado (apenas para usuários global) */}
          {advancedMenuItems.length > 0 && (
            <>
              {isSidebarOpen && (
                <div className="menu-divider">
                  <span>Avançado</span>
                </div>
              )}
              {advancedMenuItems.map((item) => {
                const Icon = item.icon;
                const isActive = location.pathname === item.path;
                
                return (
                  <Link
                    key={item.path}
                    to={item.path}
                    className={`nav-item ${isActive ? 'active' : ''}`}
                    title={!isSidebarOpen ? item.label : undefined}
                    onClick={handleNavClick}
                  >
                    <Icon size={22} />
                    {isSidebarOpen && <span>{item.label}</span>}
                    {isActive && <div className="active-indicator"></div>}
                  </Link>
                );
              })}
            </>
          )}
        </nav>
      </aside>

      {/* Main Content - clique fora colapsa sidebar no PC */}
      <div className="main-content" onClick={handleMainContentClick}>
        {/* Header */}
        <header className="header">
          <div className="header-left">
            {!isDesktop && (
              <button
                className="menu-toggle"
                onClick={() => setIsSidebarOpen(!isSidebarOpen)}
                aria-label={isSidebarOpen ? 'Fechar menu' : 'Abrir menu'}
              >
                {isSidebarOpen ? <X size={24} /> : <Menu size={24} />}
              </button>
            )}
            <h1 className="page-title">
              {[...menuItems, ...advancedMenuItems].find(item => item.path === location.pathname)?.label || 'Dashboard'}
            </h1>
          </div>

          <div className="header-right">
            {/* Dropdown de Cliente (apenas para perfil global) - multi-select, sem dropdown de planta */}
            {user?.perfil === 'global' && (
              <div className="cliente-selector" style={{ position: 'relative' }}>
                <button
                  className="cliente-selector-btn"
                  onClick={() => setIsClienteDropdownOpen(!isClienteDropdownOpen)}
                  style={{
                    background: 'var(--primary-color, #3498db)',
                    color: 'white',
                    border: 'none',
                    borderRadius: '8px',
                    cursor: 'pointer',
                    fontWeight: '500'
                  }}
                >
                  <Building2 size={18} className="cliente-selector-icon" />
                  <span>
                    {clientesSelecionados.length === 0 && 'Selecione o cliente'}
                    {clientesSelecionados.length === 1 && nomeExibicaoCliente(clientesSelecionados[0].nome)}
                    {clientesSelecionados.length >= 2 && clientesSelecionados.map(c => nomeExibicaoCliente(c.nome)).join(' e ')}
                  </span>
                  <ChevronDown size={16} />
                </button>
                {isClienteDropdownOpen && (
                  <>
                    <div
                      style={{
                        position: 'fixed',
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        zIndex: 998
                      }}
                      onClick={() => setIsClienteDropdownOpen(false)}
                    />
                    <div
                      style={{
                        position: 'absolute',
                        top: '100%',
                        right: 0,
                        marginTop: '0.5rem',
                        background: 'white',
                        borderRadius: '8px',
                        boxShadow: '0 4px 12px rgba(0,0,0,0.15)',
                        minWidth: '250px',
                        zIndex: 999,
                        overflow: 'hidden',
                        maxHeight: '300px',
                        overflowY: 'auto'
                      }}
                    >
                      {clientes.map((cliente) => {
                        const selected = clientesSelecionados.some(c => c.id === cliente.id);
                        return (
                          <label
                            key={cliente.id}
                            style={{
                              display: 'flex',
                              alignItems: 'center',
                              gap: '0.75rem',
                              width: '100%',
                              padding: '0.75rem 1rem',
                              cursor: 'pointer',
                              fontSize: '0.9rem',
                              background: selected ? 'rgba(52, 126, 38, 0.1)' : 'transparent',
                              color: 'var(--text-color, #333)',
                              transition: 'all 0.2s',
                              border: 'none',
                              boxSizing: 'border-box'
                            }}
                            onMouseEnter={(e) => {
                              if (!selected) e.currentTarget.style.background = '#f5f5f5';
                            }}
                            onMouseLeave={(e) => {
                              if (!selected) e.currentTarget.style.background = 'transparent';
                            }}
                          >
                            <input
                              type="checkbox"
                              checked={selected}
                              onChange={() => {
                                const newList = selected
                                  ? clientesSelecionados.filter(c => c.id !== cliente.id)
                                  : [...clientesSelecionados, cliente];
                                setClientesSelecionados(newList);
                              }}
                              style={{ width: '18px', height: '18px', accentColor: 'var(--primary-color)' }}
                            />
                            {nomeExibicaoCliente(cliente.nome)}
                          </label>
                        );
                      })}
                    </div>
                  </>
                )}
              </div>
            )}
            
            <button className="header-icon-btn" title="Notificações">
              <Bell size={20} />
              <span className="notification-badge">3</span>
            </button>
            <div className="user-profile-wrapper" style={{ position: 'relative' }}>
              <button
                type="button"
                className="user-profile"
                onClick={() => setIsUserMenuOpen(!isUserMenuOpen)}
                aria-expanded={isUserMenuOpen}
                aria-haspopup="true"
                aria-label="Menu do usuário"
              >
                <img
                  src={`https://ui-avatars.com/api/?name=${encodeURIComponent(user?.nome || 'User')}&background=347e26&color=fff`}
                  alt=""
                />
                <div className="user-info">
                  <span className="user-name">{user?.nome || 'Usuário'}</span>
                  <span className="user-role">{user?.perfil || 'Usuário'}</span>
                </div>
                <ChevronDown size={18} className="user-profile-chevron" aria-hidden />
              </button>
              {isUserMenuOpen && (
                <>
                  <div
                    style={{
                      position: 'fixed',
                      top: 0,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      zIndex: 998,
                    }}
                    onClick={() => setIsUserMenuOpen(false)}
                    aria-hidden="true"
                  />
                  <div className="user-menu-dropdown">
                    <button
                      type="button"
                      className="user-menu-dropdown-item"
                      onClick={() => {
                        setIsUserMenuOpen(false);
                        onLogout();
                      }}
                    >
                      <LogOut size={18} />
                      <span>Sair</span>
                    </button>
                  </div>
                </>
              )}
            </div>
          </div>
        </header>

        {/* Page Content */}
        <main className="page-content">
          {children}
        </main>
      </div>
    </div>
  );
}

export default Layout;
