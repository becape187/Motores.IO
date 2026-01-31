import { useEffect, useState } from 'react';
import { createPortal } from 'react-dom';
import { Sparkles, Star } from 'lucide-react';
import './WelcomeModal.css';

interface WelcomeModalProps {
  userName: string;
  onClose: () => void;
}

function WelcomeModal({ userName, onClose }: WelcomeModalProps) {
  const [isVisible, setIsVisible] = useState(false);
  const [showConfetti, setShowConfetti] = useState(false);

  useEffect(() => {
    // Forçar renderização imediata do overlay
    setIsVisible(true);
    
    // Pequeno delay para animação do modal
    setTimeout(() => setShowConfetti(true), 300);
    
    // Auto-fechar após 4 segundos
    const timer = setTimeout(() => {
      setIsVisible(false);
      setTimeout(onClose, 500); // Aguardar animação de saída
    }, 4000);

    return () => clearTimeout(timer);
  }, [onClose, userName]);

  const modalContent = (
    <div className={`welcome-modal-overlay ${isVisible ? 'visible' : ''}`} onClick={onClose}>
      <div className={`welcome-modal ${isVisible ? 'visible' : ''}`} onClick={(e) => e.stopPropagation()}>
        {/* Confetti animado */}
        {showConfetti && (
          <>
            {[...Array(50)].map((_, i) => (
              <div
                key={i}
                className={`confetti confetti-${i % 5}`}
                style={{
                  left: `${Math.random() * 100}%`,
                  animationDelay: `${Math.random() * 0.5}s`,
                  backgroundColor: ['#FF6B6B', '#4ECDC4', '#FFE66D', '#FF6B9D', '#C44569', '#F8B500', '#6C5CE7'][i % 7],
                }}
              />
            ))}
          </>
        )}

        {/* Ícones decorativos */}
        <div className="welcome-icon-container">
          <div className="welcome-icon-circle">
            <Star size={80} className="welcome-icon" fill="white" />
          </div>
          <Sparkles size={40} className="sparkle sparkle-1" />
          <Sparkles size={35} className="sparkle sparkle-2" />
          <Sparkles size={45} className="sparkle sparkle-3" />
          <Sparkles size={30} className="sparkle sparkle-4" />
        </div>

        {/* Texto principal */}
        <h1 className="welcome-title">
          <span className="welcome-text-1">Seja</span>
          <span className="welcome-text-2">Bem-vindo</span>
          <span className="welcome-text-3">!</span>
        </h1>

        <h2 className="welcome-name">{userName}!!!</h2>

        {/* Efeito de brilho pulsante */}
        <div className="welcome-glow"></div>

        {/* Botão de fechar (opcional) */}
        <button className="welcome-close-btn" onClick={onClose}>
          Continuar
        </button>
      </div>
    </div>
  );

  return createPortal(modalContent, document.body);
}

export default WelcomeModal;
