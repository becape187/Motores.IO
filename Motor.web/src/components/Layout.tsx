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
  Wrench
} from 'lucide-react';
import './Layout.css';

interface LayoutProps {
  children: ReactNode;
  onLogout: () => void;
}

function Layout({ children, onLogout }: LayoutProps) {
  const location = useLocation();
  const [isSidebarOpen, setIsSidebarOpen] = useState(true);

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

  const menuItems = [
    { path: '/', icon: LayoutDashboard, label: 'Principal' },
    { path: '/motors', icon: Cog, label: 'Motores' },
    { path: '/history', icon: History, label: 'Histórico' },
    { path: '/maintenance', icon: Wrench, label: 'Manutenção' },
    { path: '/alarms', icon: AlertTriangle, label: 'Alarmes' },
    { path: '/users', icon: Users, label: 'Usuários' },
  ];

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
              {menuItems.find(item => item.path === location.pathname)?.label || 'Dashboard'}
            </h1>
          </div>

          <div className="header-right">
            <button className="header-icon-btn" title="Notificações">
              <Bell size={20} />
              <span className="notification-badge">3</span>
            </button>
            <button className="header-icon-btn" title="Configurações">
              <Settings size={20} />
            </button>
            <div className="user-profile">
              <img 
                src="https://ui-avatars.com/api/?name=Admin&background=347e26&color=fff" 
                alt="User" 
              />
              <div className="user-info">
                <span className="user-name">Administrador</span>
                <span className="user-role">Admin</span>
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
