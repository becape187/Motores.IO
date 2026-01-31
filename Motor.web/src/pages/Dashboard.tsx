import { useState, useEffect, useRef } from 'react';
import { Activity, TrendingUp, AlertCircle, Power, Edit2 } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { useMotorsCache } from '../contexts/MotorsCacheContext';
import { api } from '../services/api';
import { Motor } from '../types';
import WelcomeModal from '../components/WelcomeModal';
import './Dashboard.css';

function Dashboard() {
  const { plantaSelecionada, user } = useAuth();
  const { getMotors, invalidateCache } = useMotorsCache();
  const [motors, setMotors] = useState<Motor[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isEditMode, setIsEditMode] = useState(false);
  const [draggedMotor, setDraggedMotor] = useState<string | null>(null);
  const [savingPosition, setSavingPosition] = useState<string | null>(null);
  const [showWelcomeModal, setShowWelcomeModal] = useState(false);
  const svgRef = useRef<SVGSVGElement>(null);

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


  // Verificar se deve mostrar o modal de boas-vindas
  useEffect(() => {
    const shouldShowWelcome = localStorage.getItem('showWelcomeModal');
    if (shouldShowWelcome === 'true' && user) {
      setShowWelcomeModal(true);
      // Remover o flag para não mostrar novamente
      localStorage.removeItem('showWelcomeModal');
    }
  }, [user]);

  // Buscar motores usando cache
  useEffect(() => {
    const loadMotors = async () => {
      if (!plantaSelecionada) {
        setMotors([]);
        setLoading(false);
        return;
      }

      try {
        setError(null);
        // Tentar carregar do cache primeiro (retorna imediatamente se tiver cache)
        const motorsData = await getMotors(plantaSelecionada.id, { useCache: true });
        setMotors(motorsData);
        setLoading(false);
      } catch (err: any) {
        setError(err.message || 'Erro ao carregar motores');
        console.error('Erro ao carregar motores:', err);
        setLoading(false);
      }
    };

    loadMotors();
  }, [plantaSelecionada, getMotors]);

  // Atualização em background - atualiza dados dinâmicos periodicamente
  useEffect(() => {
    if (!plantaSelecionada || isEditMode) return;

    const updateMotorsData = async () => {
      try {
        // Atualizar cache em background
        const updatedMotors = await getMotors(plantaSelecionada.id, { useCache: false });
        
        // Atualizar apenas dados dinâmicos sem recriar o array completo
        setMotors(prevMotors => {
          const motorsMap = new Map(prevMotors.map(m => [m.id, m]));
          
          return updatedMotors.map(m => {
            const existing = motorsMap.get(m.id);
            if (existing) {
              // Atualizar apenas campos dinâmicos, mantendo o resto (incluindo posição)
              return {
                ...existing,
                status: m.status,
                correnteAtual: m.correnteAtual,
                horimetro: m.horimetro,
                // Preservar posição existente se não vier do servidor
                posicaoX: m.posicaoX ?? existing.posicaoX,
                posicaoY: m.posicaoY ?? existing.posicaoY,
              };
            } else {
              // Novo motor - adicionar
              return m;
            }
          });
        });
      } catch (err: any) {
        console.error('Erro ao atualizar motores:', err);
      }
    };

    const interval = setInterval(updateMotorsData, 10000); // Atualizar a cada 10 segundos
    return () => clearInterval(interval);
  }, [plantaSelecionada, isEditMode, getMotors]);

  if (loading) {
    return (
      <div className="dashboard fade-in">
        <div style={{ textAlign: 'center', padding: '2rem' }}>
          <p>Carregando motores...</p>
        </div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="dashboard fade-in">
        <div style={{ textAlign: 'center', padding: '2rem', color: '#e74c3c' }}>
          <p>Erro: {error}</p>
        </div>
      </div>
    );
  }

  if (!plantaSelecionada) {
    return (
      <div className="dashboard fade-in">
        <div style={{ textAlign: 'center', padding: '2rem' }}>
          <p>Selecione uma planta para visualizar os motores</p>
        </div>
      </div>
    );
  }

  // Função para obter coordenadas do SVG a partir do evento do mouse
  const getSVGCoordinates = (e: React.MouseEvent<SVGSVGElement> | MouseEvent): { x: number; y: number } | null => {
    if (!svgRef.current) return null;
    const svg = svgRef.current;
    const point = svg.createSVGPoint();
    point.x = e.clientX;
    point.y = e.clientY;
    const svgPoint = point.matrixTransform(svg.getScreenCTM()?.inverse());
    return { x: svgPoint.x, y: svgPoint.y };
  };

  // Handlers para drag and drop
  const handleMotorMouseDown = (e: React.MouseEvent, motorId: string) => {
    if (!isEditMode) return;
    e.preventDefault();
    setDraggedMotor(motorId);
  };

  const handleSVGMouseMove = (e: React.MouseEvent<SVGSVGElement>) => {
    if (!isEditMode || !draggedMotor) return;
    
    const coords = getSVGCoordinates(e);
    if (!coords) return;

    // Atualizar posição do motor sendo arrastado
    setMotors(prevMotors =>
      prevMotors.map(motor =>
        motor.id === draggedMotor
          ? { ...motor, posicaoX: coords.x, posicaoY: coords.y }
          : motor
      )
    );
  };

  const handleSVGMouseUp = async () => {
    if (!draggedMotor || !plantaSelecionada) return;
    
    const motor = motors.find(m => m.id === draggedMotor);
    if (motor && motor.posicaoX !== undefined && motor.posicaoY !== undefined) {
      // Salvar posição no banco usando endpoint específico
      try {
        setSavingPosition(draggedMotor);
        await api.updateMotorPosicao(draggedMotor, {
          posicaoX: motor.posicaoX,
          posicaoY: motor.posicaoY,
        });
      } catch (err: any) {
        console.error('Erro ao salvar posição:', err);
        alert('Erro ao salvar posição do motor');
      } finally {
        setSavingPosition(null);
      }
    }
    
    setDraggedMotor(null);
  };

  // Adicionar motor à planta (clicar no SVG em modo de edição)
  const handleSVGClick = async (e: React.MouseEvent<SVGSVGElement>) => {
    if (!isEditMode || draggedMotor || !plantaSelecionada) return; // Não adicionar se estiver arrastando
    
    // Verificar se o clique foi em um motor existente (não adicionar nesse caso)
    const target = e.target as SVGElement;
    if (target.closest('g[key]')) return;
    
    const coords = getSVGCoordinates(e);
    if (!coords) return;

    // Mostrar lista de motores sem posição para adicionar
    const motoresSemPosicao = motors.filter(m => !m.posicaoX || !m.posicaoY);
    
    if (motoresSemPosicao.length > 0) {
      // Adiciona o primeiro motor sem posição
      // TODO: Futuramente mostrar um modal para selecionar qual motor adicionar
      const motorParaAdicionar = motoresSemPosicao[0];
      
      try {
        setSavingPosition(motorParaAdicionar.id);
        
        // Primeiro, garantir que o motor tem o plantaid definido
        // Se o motor não tem plantaid, atualizar a configuração primeiro
        // (isso pode acontecer se o motor foi criado sem plantaid ou de outra planta)
        const motorAtual = await api.getMotor(motorParaAdicionar.id);
        if (!motorAtual.plantaId || motorAtual.plantaId !== plantaSelecionada.id) {
          // Atualizar configuração para definir o plantaid
          await api.updateMotorConfiguracao(motorParaAdicionar.id, {
            nome: motorParaAdicionar.nome ?? '',
            potencia: motorParaAdicionar.potencia ?? 0,
            tensao: motorParaAdicionar.tensao ?? 380,
            correnteNominal: motorParaAdicionar.correnteNominal ?? 0,
            percentualCorrenteMaxima: motorParaAdicionar.percentualCorrenteMaxima ?? 110,
            histerese: motorParaAdicionar.histerese ?? 5,
            habilitado: motorParaAdicionar.habilitado ?? true,
            plantaId: plantaSelecionada.id,
          });
        }
        
        // Agora atualizar a posição
        await api.updateMotorPosicao(motorParaAdicionar.id, {
          posicaoX: coords.x,
          posicaoY: coords.y,
        });
        
        // Invalidar cache e recarregar motores
        invalidateCache(plantaSelecionada.id);
        const updatedMotors = await getMotors(plantaSelecionada.id, { useCache: false });
        setMotors(updatedMotors);
      } catch (err: any) {
        console.error('Erro ao adicionar motor à planta:', err);
        console.error('Detalhes do erro:', err.message);
        alert('Erro ao adicionar motor à planta: ' + (err.message || 'Erro desconhecido'));
      } finally {
        setSavingPosition(null);
      }
    } else {
      alert('Não há motores sem posição para adicionar ao mapa');
    }
  };

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
          <div style={{ display: 'flex', gap: '16px', alignItems: 'center', flexWrap: 'wrap' }}>
            <label style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer' }}>
              <input
                type="checkbox"
                checked={isEditMode}
                onChange={(e) => setIsEditMode(e.target.checked)}
              />
              <Edit2 size={18} />
              <span>Editar</span>
            </label>
            {isEditMode && (
              <>
                <div style={{ 
                  padding: '4px 12px', 
                  background: '#f39c12', 
                  color: 'white', 
                  borderRadius: '4px',
                  fontSize: '12px',
                  fontWeight: '600'
                }}>
                  Modo de Edição Ativo
                </div>
                {motors.filter(m => !m.posicaoX || !m.posicaoY).length > 0 && (
                  <div style={{ 
                    padding: '4px 12px', 
                    background: '#3498db', 
                    color: 'white', 
                    borderRadius: '4px',
                    fontSize: '12px',
                    fontWeight: '600'
                  }}>
                    {motors.filter(m => !m.posicaoX || !m.posicaoY).length} motor(es) sem posição - Clique no mapa para adicionar
                  </div>
                )}
              </>
            )}
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
        </div>

        <div className="plant-container">
          <svg 
            ref={svgRef}
            className="plant-svg" 
            viewBox="0 0 900 600"
            onMouseMove={handleSVGMouseMove}
            onMouseUp={handleSVGMouseUp}
            onMouseLeave={handleSVGMouseUp}
            onClick={handleSVGClick}
            style={{ cursor: isEditMode ? 'crosshair' : 'default' }}
          >
            {/* Background */}
            <rect x="0" y="0" width="900" height="600" fill="#f8f9fa" />
            
            {/* Grid */}
            <defs>
              <pattern id="grid" width="50" height="50" patternUnits="userSpaceOnUse">
                <path d="M 50 0 L 0 0 0 50" fill="none" stroke="#e0e0e0" strokeWidth="0.5"/>
              </pattern>
            </defs>
            <rect width="900" height="600" fill="url(#grid)" />

            {/* Instrução em modo de edição */}
            {isEditMode && (
              <text 
                x="450" 
                y="30" 
                textAnchor="middle" 
                fill="#f39c12" 
                fontSize="14" 
                fontWeight="600"
                style={{ pointerEvents: 'none' }}
              >
                {draggedMotor ? 'Arraste para posicionar' : 'Clique para adicionar motor | Arraste para mover'}
              </text>
            )}

            {/* Motores - apenas habilitados e com posição */}
            {motors
              .filter(m => m.habilitado && m.posicaoX !== undefined && m.posicaoY !== undefined)
              .map((motor) => (
              <g key={motor.id}>
                {/* Motor Indicator - 50% menor */}
                <circle
                  cx={motor.posicaoX}
                  cy={motor.posicaoY}
                  r="10"
                  fill={getStatusColor(motor.status)}
                  opacity={savingPosition === motor.id ? 0.5 : 1}
                  stroke={isEditMode ? "#3498db" : "#fff"}
                  strokeWidth={isEditMode ? 2 : 1.5}
                  strokeDasharray={isEditMode ? "3,3" : "none"}
                  onMouseDown={(e) => {
                    if (isEditMode) {
                      handleMotorMouseDown(e, motor.id);
                    }
                  }}
                  style={{ cursor: isEditMode ? 'move' : 'default' }}
                />

                {/* Nome e Corrente - Texto simples sem cards */}
                <text
                  x={motor.posicaoX}
                  y={motor.posicaoY! + 25}
                  textAnchor="middle"
                  fill="#333"
                  fontSize="11"
                  fontWeight="500"
                  style={{ pointerEvents: 'none' }}
                >
                  {motor.nome}
                </text>
                <text
                  x={motor.posicaoX}
                  y={motor.posicaoY! + 38}
                  textAnchor="middle"
                  fill="#666"
                  fontSize="10"
                  style={{ pointerEvents: 'none' }}
                >
                  {motor.correnteAtual.toFixed(1)}A
                </text>
              </g>
            ))}
          </svg>
        </div>
      </div>

      {/* Modal de boas-vindas */}
      {showWelcomeModal && user && (
        <WelcomeModal 
          userName={user.nome || 'Usuário'} 
          onClose={() => setShowWelcomeModal(false)} 
        />
      )}
    </div>
  );
}

export default Dashboard;
