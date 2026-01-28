import { useState, useEffect } from 'react';
import { Activity, TrendingUp, AlertCircle, Power } from 'lucide-react';
import { mockMotors } from '../data/mockData';
import { Motor } from '../types';
import './Dashboard.css';

function Dashboard() {
  const [motors, setMotors] = useState<Motor[]>(mockMotors);

  const stats = {
    total: motors.length,
    online: motors.filter(m => m.status === 'ligado').length,
    alerta: motors.filter(m => m.status === 'alerta' || m.status === 'alarme').length,
    offline: motors.filter(m => m.status === 'desligado').length,
    consumoTotal: motors.reduce((acc, m) => acc + (m.status === 'ligado' ? m.correnteAtual : 0), 0),
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'ligado': return '#27ae60';
      case 'desligado': return '#95a5a6';
      case 'alerta': return '#f39c12';
      case 'alarme': return '#e74c3c';
      case 'pendente': return '#9b59b6';
      default: return '#95a5a6';
    }
  };

  const getStatusLabel = (status: string) => {
    switch (status) {
      case 'ligado': return 'Ligado';
      case 'desligado': return 'Desligado';
      case 'alerta': return 'Alerta';
      case 'alarme': return 'Alarme';
      case 'pendente': return 'Pendente';
      default: return 'Desconhecido';
    }
  };

  // Simular atualização em tempo real
  useEffect(() => {
    const interval = setInterval(() => {
        setMotors(prevMotors =>
        prevMotors.map(motor => ({
          ...motor,
          correnteAtual: motor.status === 'ligado' 
            ? motor.correnteNominal + (Math.random() * 20 - 10)
            : 0,
        }))
      );
    }, 3000);

    return () => clearInterval(interval);
  }, []);

  return (
    <div className="dashboard fade-in">
      {/* Stats Cards */}
      <div className="stats-grid">
        <div className="stat-card stat-card-blue">
          <div className="stat-icon" style={{ background: 'linear-gradient(135deg, #5dade2, #3498db)' }}>
            <Power size={28} />
          </div>
          <div className="stat-content">
            <h3>Total de Motores</h3>
            <p className="stat-value">{stats.total}</p>
            <span className="stat-label">Equipamentos</span>
          </div>
        </div>

        <div className="stat-card stat-card-green">
          <div className="stat-icon" style={{ background: 'linear-gradient(135deg, #58d68d, #27ae60)' }}>
            <Activity size={28} />
          </div>
          <div className="stat-content">
            <h3>Motores Ligados</h3>
            <p className="stat-value">{stats.online}</p>
            <span className="stat-label">Operando normalmente</span>
          </div>
        </div>

        <div className="stat-card stat-card-orange">
          <div className="stat-icon" style={{ background: 'linear-gradient(135deg, #f7dc6f, #f39c12)' }}>
            <AlertCircle size={28} />
          </div>
          <div className="stat-content">
            <h3>Em Alerta</h3>
            <p className="stat-value">{stats.alerta}</p>
            <span className="stat-label">Requer atenção</span>
          </div>
        </div>

        <div className="stat-card stat-card-primary">
          <div className="stat-icon" style={{ background: 'linear-gradient(135deg, #7fb3d3, var(--primary-color))' }}>
            <TrendingUp size={28} />
          </div>
          <div className="stat-content">
            <h3>Consumo Total</h3>
            <p className="stat-value">{stats.consumoTotal.toFixed(0)}A</p>
            <span className="stat-label">Corrente total</span>
          </div>
        </div>
      </div>

      {/* Planta Baixa */}
      <div className="plant-section">
        <div className="section-header">
          <h2>Planta Baixa da Pedreira</h2>
          <div className="legend">
            <div className="legend-item">
              <span className="legend-dot" style={{ background: '#27ae60' }}></span>
              <span>Ligado</span>
            </div>
            <div className="legend-item">
              <span className="legend-dot" style={{ background: '#95a5a6' }}></span>
              <span>Desligado</span>
            </div>
            <div className="legend-item">
              <span className="legend-dot" style={{ background: '#f39c12' }}></span>
              <span>Alerta</span>
            </div>
            <div className="legend-item">
              <span className="legend-dot" style={{ background: '#e74c3c' }}></span>
              <span>Alarme</span>
            </div>
            <div className="legend-item">
              <span className="legend-dot" style={{ background: '#9b59b6' }}></span>
              <span>Pendente</span>
            </div>
          </div>
        </div>

        <div className="plant-container">
          <svg className="plant-svg" viewBox="0 0 900 600">
            {/* Background */}
            <rect x="0" y="0" width="900" height="600" fill="#f8f9fa" />
            
            {/* Grid */}
            <defs>
              <pattern id="grid" width="50" height="50" patternUnits="userSpaceOnUse">
                <path d="M 50 0 L 0 0 0 50" fill="none" stroke="#e0e0e0" strokeWidth="0.5"/>
              </pattern>
            </defs>
            <rect width="900" height="600" fill="url(#grid)" />

            {/* Estruturas da Pedreira */}
            {/* Britador */}
            <rect x="200" y="150" width="120" height="80" fill="#496263" opacity="0.3" stroke="#496263" strokeWidth="2"/>
            <text x="260" y="195" textAnchor="middle" fill="#496263" fontSize="12" fontWeight="600">BRITADOR</text>

            {/* Esteiras */}
            <rect x="350" y="175" width="180" height="40" fill="#496263" opacity="0.2" stroke="#496263" strokeWidth="2"/>
            <text x="440" y="200" textAnchor="middle" fill="#496263" fontSize="11">ESTEIRA 01</text>
            
            <rect x="560" y="195" width="180" height="40" fill="#496263" opacity="0.2" stroke="#496263" strokeWidth="2"/>
            <text x="650" y="220" textAnchor="middle" fill="#496263" fontSize="11">ESTEIRA 02</text>

            {/* Peneira */}
            <rect x="330" y="320" width="140" height="80" fill="#496263" opacity="0.3" stroke="#496263" strokeWidth="2"/>
            <text x="400" y="365" textAnchor="middle" fill="#496263" fontSize="12" fontWeight="600">PENEIRA</text>

            {/* Elevador */}
            <rect x="670" y="250" width="80" height="100" fill="#496263" opacity="0.3" stroke="#496263" strokeWidth="2"/>
            <text x="710" y="305" textAnchor="middle" fill="#496263" fontSize="11">ELEVADOR</text>

            {/* Sistema de Água */}
            <circle cx="170" cy="450" r="40" fill="#3498db" opacity="0.2" stroke="#3498db" strokeWidth="2"/>
            <text x="170" y="455" textAnchor="middle" fill="#3498db" fontSize="11">BOMBA</text>

            {/* Motores */}
            {motors.map((motor) => (
              <g key={motor.id}>
                {/* Motor Indicator */}
                <circle
                  cx={motor.posicaoX}
                  cy={motor.posicaoY}
                  r="20"
                  fill={getStatusColor(motor.status)}
                  opacity="0.9"
                  stroke="#fff"
                  strokeWidth="3"
                  className="motor-indicator"
                />
                
                {/* Pulse Animation for Ligado Motors */}
                {motor.status === 'ligado' && (
                  <circle
                    cx={motor.posicaoX}
                    cy={motor.posicaoY}
                    r="20"
                    fill={getStatusColor(motor.status)}
                    opacity="0.5"
                    className="motor-pulse"
                  />
                )}

                {/* Motor Info Card */}
                <foreignObject
                  x={motor.posicaoX! - 70}
                  y={motor.posicaoY! + 30}
                  width="140"
                  height="80"
                >
                  <div className="motor-label">
                    <div className="motor-label-header">
                      <span className="motor-label-id">M{motor.id}</span>
                      <span 
                        className="motor-label-status"
                        style={{ background: getStatusColor(motor.status) }}
                      >
                        {getStatusLabel(motor.status)}
                      </span>
                    </div>
                    <div className="motor-label-name">{motor.nome}</div>
                    <div className="motor-label-data">
                      <div className="motor-label-item">
                        <span className="label">Corrente:</span>
                        <span className="value">{motor.correnteAtual.toFixed(1)}A</span>
                      </div>
                      <div className="motor-label-item">
                        <span className="label">Potência:</span>
                        <span className="value">{motor.potencia}kW</span>
                      </div>
                    </div>
                  </div>
                </foreignObject>
              </g>
            ))}
          </svg>
        </div>
      </div>

    </div>
  );
}

export default Dashboard;
