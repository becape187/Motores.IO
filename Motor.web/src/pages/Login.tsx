import { useState } from 'react';
import { Lock, User, Eye, EyeOff } from 'lucide-react';
import './Login.css';

interface LoginProps {
  onLogin: () => void;
}

function Login({ onLogin }: LoginProps) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [emailFocused, setEmailFocused] = useState(false);
  const [passwordFocused, setPasswordFocused] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [isLoading, setIsLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setIsLoading(true);
    
    // Simular autenticação
    setTimeout(() => {
      setIsLoading(false);
      onLogin();
    }, 1000);
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
    </div>
  );
}

export default Login;
