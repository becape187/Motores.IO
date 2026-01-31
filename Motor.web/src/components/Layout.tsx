import { ReactNode, useState, useEffect } from 'react';
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
  Settings,
  Wrench,
  Building2,
  ChevronDown,
  Settings2,
  Key
} from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { api } from '../services/api';
import './Layout.css';

interface LayoutProps {
  children: ReactNode;
  onLogout: () => void;
}

function Layout({ children, onLogout }: LayoutProps) {
  const location = useLocation();
  const { user, plantaSelecionada, clienteSelecionado, setPlantaSelecionada, setClienteSelecionado } = useAuth();
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);
  const [isPlantaDropdownOpen, setIsPlantaDropdownOpen] = useState(false);
  const [isClienteDropdownOpen, setIsClienteDropdownOpen] = useState(false);
  const [clientes, setClientes] = useState<Array<{id: string; nome: string; ativo: boolean}>>([]);
  const [plantasDoCliente, setPlantasDoCliente] = useState<Array<{id: string; nome: string; codigo?: string; clienteId: string; clienteNome: string}>>([]);

  // Fechar sidebar ao clicar em um item no mobile
  const handleNavClick = () => {
    if (window.innerWidth <= 1200) {
      setIsSidebarOpen(false);
    }
  };

  // Ajustar sidebar ao redimensionar a janela
  useEffect(() => {
    const handleResize = () => {
      if (window.innerWidth > 1200) {
        setIsSidebarOpen(true);
      } else {
        setIsSidebarOpen(false);
      }
    };

    // Verificar tamanho inicial
    if (window.innerWidth <= 1200) {
      setIsSidebarOpen(false);
    }

    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  // Carregar clientes se perfil for global
  useEffect(() => {
    if (user?.perfil === 'global') {
      api.getClientes(true).then(setClientes).catch(console.error);
    }
  }, [user]);

  // Carregar plantas do cliente selecionado quando trocar de cliente
  useEffect(() => {
    if (user?.perfil === 'global') {
      if (clienteSelecionado) {
        api.getPlantasPorCliente(clienteSelecionado.id).then(plantas => {
          setPlantasDoCliente(plantas);
          // Selecionar primeira planta automaticamente
          if (plantas.length > 0) {
            setPlantaSelecionada(plantas[0]);
          } else {
            // Limpar planta selecionada se não houver plantas
            setPlantaSelecionada(null);
          }
        }).catch(console.error);
      } else {
        // Se não houver cliente selecionado, limpar plantas
        setPlantasDoCliente([]);
        setPlantaSelecionada(null);
      }
    } else if (user?.perfil !== 'global') {
      // Se não for global, usar plantas do usuário
      setPlantasDoCliente(user?.plantas || []);
    }
  }, [clienteSelecionado, user]);

  // Se não for global e não tiver cliente selecionado, usar primeira planta do usuário
  useEffect(() => {
    if (user?.perfil !== 'global' && user?.plantas && user.plantas.length > 0 && !plantaSelecionada) {
      setPlantaSelecionada(user.plantas[0]);
    }
  }, [user, plantaSelecionada]);

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
  ] : [];

  return (
    <div className="layout">
      {/* Overlay para mobile */}
      {isSidebarOpen && (
        <div 
          className="sidebar-overlay"
          onClick={() => setIsSidebarOpen(false)}
        />
      )}

      {/* Sidebar */}
      <aside className={`sidebar ${isSidebarOpen ? 'open' : 'closed'}`}>
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

        <div className="sidebar-footer">
          <button 
            className="nav-item" 
            onClick={onLogout}
            title={!isSidebarOpen ? 'Sair' : undefined}
          >
            <LogOut size={22} />
            {isSidebarOpen && <span>Sair</span>}
          </button>
        </div>
      </aside>

      {/* Main Content */}
      <div className="main-content">
        {/* Header */}
        <header className="header">
          <div className="header-left">
            <button 
              className="menu-toggle"
              onClick={() => setIsSidebarOpen(!isSidebarOpen)}
            >
              {isSidebarOpen ? <X size={24} /> : <Menu size={24} />}
            </button>
            <h1 className="page-title">
              {[...menuItems, ...advancedMenuItems].find(item => item.path === location.pathname)?.label || 'Dashboard'}
            </h1>
          </div>

          <div className="header-right">
            {/* Dropdown de Cliente (apenas para perfil global) */}
            {user?.perfil === 'global' && (
              <div className="cliente-selector" style={{ position: 'relative', marginRight: '1rem' }}>
                <button
                  className="cliente-selector-btn"
                  onClick={() => setIsClienteDropdownOpen(!isClienteDropdownOpen)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.5rem',
                    padding: '0.5rem 1rem',
                    background: 'var(--primary-color, #3498db)',
                    color: 'white',
                    border: 'none',
                    borderRadius: '8px',
                    cursor: 'pointer',
                    fontSize: '0.9rem',
                    fontWeight: '500'
                  }}
                >
                  <Building2 size={18} />
                  <span>{clienteSelecionado?.nome || 'Selecione um cliente'}</span>
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
                      {clientes.map((cliente) => (
                        <button
                          key={cliente.id}
                          onClick={() => {
                            setClienteSelecionado(cliente);
                            setIsClienteDropdownOpen(false);
                          }}
                          style={{
                            width: '100%',
                            padding: '0.75rem 1rem',
                            textAlign: 'left',
                            border: 'none',
                            background: clienteSelecionado?.id === cliente.id ? 'var(--primary-color, #3498db)' : 'transparent',
                            color: clienteSelecionado?.id === cliente.id ? 'white' : 'var(--text-color, #333)',
                            cursor: 'pointer',
                            fontSize: '0.9rem',
                            transition: 'all 0.2s'
                          }}
                          onMouseEnter={(e) => {
                            if (clienteSelecionado?.id !== cliente.id) {
                              e.currentTarget.style.background = '#f5f5f5';
                            }
                          }}
                          onMouseLeave={(e) => {
                            if (clienteSelecionado?.id !== cliente.id) {
                              e.currentTarget.style.background = 'transparent';
                            }
                          }}
                        >
                          {cliente.nome}
                        </button>
                      ))}
                    </div>
                  </>
                )}
              </div>
            )}

            {/* Dropdown de Plantas */}
            {user && (
              <div className="planta-selector" style={{ position: 'relative', marginRight: '1rem' }}>
                <button
                  className="planta-selector-btn"
                  onClick={() => setIsPlantaDropdownOpen(!isPlantaDropdownOpen)}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: '0.5rem',
                    padding: '0.5rem 1rem',
                    background: 'var(--secondary-color, #347e26)',
                    color: 'white',
                    border: 'none',
                    borderRadius: '8px',
                    cursor: 'pointer',
                    fontSize: '0.9rem',
                    fontWeight: '500'
                  }}
                >
                  <Building2 size={18} />
                  <span>{plantaSelecionada?.nome || 'Selecione uma planta'}</span>
                  <ChevronDown size={16} />
                </button>
                {isPlantaDropdownOpen && (
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
                      onClick={() => setIsPlantaDropdownOpen(false)}
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
                        overflow: 'hidden'
                      }}
                    >
                      {(user.perfil === 'global' ? plantasDoCliente : user.plantas || []).length > 0 ? (
                        (user.perfil === 'global' ? plantasDoCliente : user.plantas || []).map((planta) => (
                          <button
                            key={planta.id}
                            onClick={() => {
                              setPlantaSelecionada(planta);
                              setIsPlantaDropdownOpen(false);
                            }}
                            style={{
                              width: '100%',
                              padding: '0.75rem 1rem',
                              textAlign: 'left',
                              border: 'none',
                              background: plantaSelecionada?.id === planta.id ? 'var(--secondary-color, #347e26)' : 'transparent',
                              color: plantaSelecionada?.id === planta.id ? 'white' : 'var(--text-color, #333)',
                              cursor: 'pointer',
                              fontSize: '0.9rem',
                              transition: 'all 0.2s'
                            }}
                            onMouseEnter={(e) => {
                              if (plantaSelecionada?.id !== planta.id) {
                                e.currentTarget.style.background = '#f5f5f5';
                              }
                            }}
                            onMouseLeave={(e) => {
                              if (plantaSelecionada?.id !== planta.id) {
                                e.currentTarget.style.background = 'transparent';
                              }
                            }}
                          >
                            {planta.nome}
                          </button>
                        ))
                      ) : (
                        <div style={{
                          padding: '1rem',
                          textAlign: 'center',
                          color: '#666',
                          fontSize: '0.9rem'
                        }}>
                          {user.perfil === 'global' 
                            ? (clienteSelecionado ? 'Nenhuma planta disponível para este cliente' : 'Selecione um cliente primeiro')
                            : 'Nenhuma planta disponível'}
                        </div>
                      )}
                    </div>
                  </>
                )}
              </div>
            )}
            
            <button className="header-icon-btn" title="Notificações">
              <Bell size={20} />
              <span className="notification-badge">3</span>
            </button>
            <button className="header-icon-btn" title="Configurações">
              <Settings size={20} />
            </button>
            <div className="user-profile">
              <img 
                src={`https://ui-avatars.com/api/?name=${encodeURIComponent(user?.nome || 'User')}&background=347e26&color=fff`}
                alt="User" 
              />
              <div className="user-info">
                <span className="user-name">{user?.nome || 'Usuário'}</span>
                <span className="user-role">{user?.perfil || 'Usuário'}</span>
              </div>
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
