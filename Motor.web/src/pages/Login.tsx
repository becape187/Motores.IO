import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Lock, User, Eye, EyeOff, AlertCircle } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import './Login.css';

function Login() {
  const navigate = useNavigate();
  const { login } = useAuth();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [emailFocused, setEmailFocused] = useState(false);
  const [passwordFocused, setPasswordFocused] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');
  const [showModalSemPlantas, setShowModalSemPlantas] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);
    
    try {
      await login(email, password);
      // Marcar que acabou de fazer login para mostrar o modal no Dashboard
      localStorage.setItem('showWelcomeModal', 'true');
      // Navegar para o dashboard
      navigate('/');
    } catch (err: any) {
      if (err.message === 'SEM_PLANTAS') {
        setShowModalSemPlantas(true);
      } else {
        setError(err.message || 'Erro ao fazer login. Verifique suas credenciais.');
      }
    } finally {
      setIsLoading(false);
    }
  };


  return (
    <div className="login-container">
      <div className="login-background">
        <div className="login-overlay"></div>
      </div>
      
      <div className="login-card fade-in">
        <div className="login-header">
          <div className="logo-container">
            <div className="logo-circle">
              <Lock size={40} />
            </div>
          </div>
          <h1>Sistema de Monitoramento</h1>
          <p>Pedreira - Controle de Motores</p>
        </div>

        <form className="login-form" onSubmit={handleSubmit}>
          <div className="form-group">
            <div className={`input-wrapper ${email || emailFocused ? 'no-icon' : ''}`}>
              {!(email || emailFocused) && <User className="input-icon" size={20} />}
              <input
                id="email"
                type="email"
                placeholder=""
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                onFocus={() => setEmailFocused(true)}
                onBlur={() => setEmailFocused(false)}
                required
                aria-label="E-mail"
              />
              <label htmlFor="email" className={`floating-label ${email ? 'filled' : ''}`}>E-mail</label>
            </div>
          </div>

          <div className="form-group">
            <div className={`input-wrapper ${password || passwordFocused ? 'no-icon' : ''}`}>
              {!(password || passwordFocused) && <Lock className="input-icon" size={20} />}
              <input
                id="password"
                type={showPassword ? 'text' : 'password'}
                placeholder=""
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                onFocus={() => setPasswordFocused(true)}
                onBlur={() => setPasswordFocused(false)}
                required
                aria-label="Senha"
              />
              <label htmlFor="password" className={`floating-label ${password ? 'filled' : ''}`}>Senha</label>
              <button
                type="button"
                className="password-toggle"
                onClick={() => setShowPassword(!showPassword)}
              >
                {showPassword ? <EyeOff size={20} /> : <Eye size={20} />}
              </button>
            </div>
          </div>

          <div className="form-options">
            <label className="checkbox-label">
              <input type="checkbox" />
              <span>Lembrar-me</span>
            </label>
            <a href="#" className="forgot-password">Esqueceu a senha?</a>
          </div>

          {error && (
            <div className="error-message" style={{ color: '#e74c3c', marginBottom: '1rem', textAlign: 'center' }}>
              {error}
            </div>
          )}

          <button type="submit" className="login-button" disabled={isLoading}>
            {isLoading ? (
              <span className="loading-spinner"></span>
            ) : (
              'Entrar'
            )}
          </button>
        </form>

        <div className="login-footer">
          <p>© 2026 Pedreira Monitoring System</p>
          <p className="demo-credentials">Demo: admin@pedreira.com / admin123</p>
        </div>
      </div>

      {/* Modal de aviso quando usuário não tem plantas */}
      {showModalSemPlantas && (
        <div
          style={{
            position: 'fixed',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            backgroundColor: 'rgba(0, 0, 0, 0.5)',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
            zIndex: 10000,
          }}
          onClick={() => setShowModalSemPlantas(false)}
        >
          <div
            style={{
              background: 'white',
              borderRadius: '16px',
              padding: '2rem',
              maxWidth: '500px',
              width: '90%',
              boxShadow: '0 20px 60px rgba(0, 0, 0, 0.3)',
            }}
            onClick={(e) => e.stopPropagation()}
          >
            <div style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '1.5rem' }}>
              <div
                style={{
                  width: '48px',
                  height: '48px',
                  borderRadius: '50%',
                  background: '#f39c12',
                  display: 'flex',
                  alignItems: 'center',
                  justifyContent: 'center',
                  color: 'white',
                }}
              >
                <AlertCircle size={24} />
              </div>
              <h2 style={{ margin: 0, color: '#333' }}>Acesso não disponível</h2>
            </div>
            <p style={{ color: '#666', lineHeight: '1.6', marginBottom: '1.5rem' }}>
              Você não tem acesso a nenhuma planta. Contate o seu gestor para solicitar acesso.
            </p>
            <button
              onClick={() => setShowModalSemPlantas(false)}
              style={{
                width: '100%',
                padding: '0.75rem',
                background: 'var(--primary-color, #3498db)',
                color: 'white',
                border: 'none',
                borderRadius: '8px',
                fontSize: '1rem',
                fontWeight: '600',
                cursor: 'pointer',
              }}
            >
              Entendi
            </button>
          </div>
        </div>
      )}
    </div>
  );
}

export default Login;
