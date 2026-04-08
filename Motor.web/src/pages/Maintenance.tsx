import { useState, useEffect, useCallback } from 'react';
import { Calendar, Clock, FileText, AlertCircle, CheckCircle, Clock3, Hourglass, ArrowLeft, Loader, Wrench, AlertTriangle, Send, History } from 'lucide-react';
import { format, differenceInDays } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { useAuth } from '../contexts/AuthContext';
import { useMotorsCache } from '../contexts/MotorsCacheContext';
import { api } from '../services/api';
import { Motor, OrdemServico } from '../types';
import { horimetroInteiro } from '../utils/horimetroDisplay';
import './Maintenance.css';

type TabType = 'manutencao' | 'historico';

interface HistoricoItem {
  id: string;
  numeroOS: string;
  motorId: string;
  motorNome: string;
  tipo: string;
  status: string;
  descricao: string;
  dataAbertura: string;
  dataEncerramento: string;
  dataPrevista?: string;
  relatorios: Array<{
    id: string;
    data: string;
    tecnico: string;
    descricao: string;
    observacoes?: string;
  }>;
}

function Maintenance() {
  const { plantaSelecionada } = useAuth();
  const { getMotors } = useMotorsCache();
  const [activeTab, setActiveTab] = useState<TabType>('manutencao');
  const [motors, setMotors] = useState<Motor[]>([]);
  const [ordensServico, setOrdensServico] = useState<OrdemServico[]>([]);
  const [historico, setHistorico] = useState<HistoricoItem[]>([]);
  const [loading, setLoading] = useState(false);
  const [loadingOS, setLoadingOS] = useState(false);
  const [loadingHistorico, setLoadingHistorico] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [successMsg, setSuccessMsg] = useState<string | null>(null);
  const [selectedMotor, setSelectedMotor] = useState<Motor | null>(null);
  const [showDetails, setShowDetails] = useState(false);

  // Estado do fluxo de fechar manutenção
  const [fechandoOS, setFechandoOS] = useState<OrdemServico | null>(null);
  const [relatorioTexto, setRelatorioTexto] = useState('');
  const [submitting, setSubmitting] = useState(false);

  // Histórico: detalhes expandido
  const [expandedHistoricoId, setExpandedHistoricoId] = useState<string | null>(null);

  const loadMotors = useCallback(async () => {
    if (!plantaSelecionada) {
      setMotors([]);
      return;
    }

    setLoading(true);
    setError(null);
    try {
      const motorsData = await getMotors(plantaSelecionada.id, { useCache: false });
      setMotors(motorsData);
    } catch (err: any) {
      setError(err.message || 'Erro ao carregar motores');
    } finally {
      setLoading(false);
    }
  }, [plantaSelecionada, getMotors]);

  useEffect(() => {
    loadMotors();
  }, [loadMotors]);

  const loadOrdensServico = useCallback(async (motor: Motor) => {
    if (!plantaSelecionada) return;

    setLoadingOS(true);
    try {
      const ordens = await api.getOrdensServico(motor.id);
      const ordensFormatadas: OrdemServico[] = ordens.map((os: any) => ({
        id: os.id,
        numeroOS: os.numeroOS || `OS-${os.id.substring(0, 8)}`,
        motorId: os.motorId || motor.id,
        tipo: os.tipo || 'preventiva',
        status: os.status || 'aberta',
        descricao: os.descricao || 'Sem descrição',
        dataAbertura: new Date(os.dataAbertura || new Date()),
        dataEncerramento: os.dataEncerramento ? new Date(os.dataEncerramento) : undefined,
        dataPrevista: os.dataPrevista ? new Date(os.dataPrevista) : undefined,
        relatorios: os.relatorios || [],
      }));
      setOrdensServico(ordensFormatadas);
    } catch (err: any) {
      console.error('Erro ao carregar ordens de serviço:', err);
      setOrdensServico([]);
    } finally {
      setLoadingOS(false);
    }
  }, [plantaSelecionada]);

  const loadHistorico = useCallback(async () => {
    if (!plantaSelecionada) {
      setHistorico([]);
      return;
    }

    setLoadingHistorico(true);
    try {
      const data = await api.getHistoricoManutencoes(plantaSelecionada.id);
      setHistorico(data);
    } catch (err: any) {
      console.error('Erro ao carregar histórico:', err);
      setHistorico([]);
    } finally {
      setLoadingHistorico(false);
    }
  }, [plantaSelecionada]);

  useEffect(() => {
    if (selectedMotor && plantaSelecionada) {
      loadOrdensServico(selectedMotor);
    } else {
      setOrdensServico([]);
    }
  }, [selectedMotor, plantaSelecionada, loadOrdensServico]);

  useEffect(() => {
    if (activeTab === 'historico') {
      loadHistorico();
    }
  }, [activeTab, loadHistorico]);

  // Motores com ciclo de manutenção configurado
  const motorsComManutencao = motors.filter(motor => {
    return motor.cicloManutencao != null && motor.cicloManutencao > 0;
  }).sort((a, b) => {
    const aPendente = a.horimetroProximaManutencao != null && a.horimetro >= a.horimetroProximaManutencao;
    const bPendente = b.horimetroProximaManutencao != null && b.horimetro >= b.horimetroProximaManutencao;
    if (aPendente && !bPendente) return -1;
    if (!aPendente && bPendente) return 1;

    if (a.dataEstimadaProximaManutencao && b.dataEstimadaProximaManutencao) {
      return new Date(a.dataEstimadaProximaManutencao).getTime() - new Date(b.dataEstimadaProximaManutencao).getTime();
    }
    if (a.dataEstimadaProximaManutencao) return -1;
    if (b.dataEstimadaProximaManutencao) return 1;
    return 0;
  });

  const isMotorPendente = (motor: Motor) => {
    return motor.horimetroProximaManutencao != null && motor.horimetro >= motor.horimetroProximaManutencao;
  };

  const getProgresso = (motor: Motor) => {
    if (motor.cicloManutencao == null || motor.horimetroProximaManutencao == null) return 0;
    const base = motor.horimetroProximaManutencao - motor.cicloManutencao;
    const usado = motor.horimetro - base;
    const total = motor.cicloManutencao;
    if (total <= 0) return 0;
    return Math.min(100, Math.max(0, (usado / total) * 100));
  };

  const handleSelectMotor = (motor: Motor) => {
    setSelectedMotor(motor);
    setFechandoOS(null);
    setRelatorioTexto('');
    setShowDetails(true);
    setSuccessMsg(null);
  };

  const handleBackToList = () => {
    setShowDetails(false);
    setSelectedMotor(null);
    setFechandoOS(null);
    setRelatorioTexto('');
    setSuccessMsg(null);
  };

  const handleFecharManutencao = (os: OrdemServico) => {
    setFechandoOS(os);
    setRelatorioTexto('');
    setSuccessMsg(null);
  };

  const handleConfirmarFechamento = async () => {
    if (!fechandoOS || !relatorioTexto.trim()) return;

    setSubmitting(true);
    setError(null);
    try {
      await api.fecharManutencao(fechandoOS.id, relatorioTexto.trim());
      setSuccessMsg(`Manutenção ${fechandoOS.numeroOS} fechada com sucesso. Contador reiniciado.`);
      setFechandoOS(null);
      setRelatorioTexto('');

      await loadMotors();
      if (selectedMotor) {
        const motorAtualizado = motors.find(m => m.id === selectedMotor.id);
        if (motorAtualizado) {
          await loadOrdensServico(motorAtualizado);
        } else {
          await loadOrdensServico(selectedMotor);
        }
      }
    } catch (err: any) {
      setError(err.message || 'Erro ao fechar manutenção');
    } finally {
      setSubmitting(false);
    }
  };

  const handleCancelarFechamento = () => {
    setFechandoOS(null);
    setRelatorioTexto('');
  };

  const handleTabChange = (tab: TabType) => {
    setActiveTab(tab);
    setShowDetails(false);
    setSelectedMotor(null);
    setFechandoOS(null);
    setError(null);
    setSuccessMsg(null);
  };

  const getOSStatusColor = (status: string) => {
    switch (status) {
      case 'aberta': return '#3498db';
      case 'concluida': return '#27ae60';
      case 'atrasada': return '#e74c3c';
      case 'pendente': return '#f39c12';
      default: return '#95a5a6';
    }
  };

  const getOSStatusIcon = (status: string) => {
    switch (status) {
      case 'aberta': return <Clock3 size={16} />;
      case 'concluida': return <CheckCircle size={16} />;
      case 'atrasada': return <AlertCircle size={16} />;
      case 'pendente': return <Hourglass size={16} />;
      default: return <Clock size={16} />;
    }
  };

  const getOSStatusLabel = (status: string) => {
    switch (status) {
      case 'aberta': return 'Aberta';
      case 'concluida': return 'Concluída';
      case 'atrasada': return 'Atrasada';
      case 'pendente': return 'Pendente';
      default: return status;
    }
  };

  const getDiasRestantes = (data?: Date) => {
    if (!data) return null;
    return differenceInDays(new Date(data), new Date());
  };

  const pendentesCount = motorsComManutencao.filter(isMotorPendente).length;

  if (!plantaSelecionada) {
    return (
      <div className="maintenance-page fade-in">
        <div style={{ textAlign: 'center', padding: '2rem' }}>
          <p>Selecione uma planta para visualizar a manutenção</p>
        </div>
      </div>
    );
  }

  return (
    <div className="maintenance-page fade-in">
      {error && (
        <div className="maintenance-alert maintenance-alert-error">
          <AlertCircle size={18} />
          {error}
          <button onClick={() => setError(null)} style={{ marginLeft: 'auto', background: 'none', border: 'none', cursor: 'pointer', color: 'inherit', fontSize: '16px' }}>&times;</button>
        </div>
      )}

      {successMsg && (
        <div className="maintenance-alert maintenance-alert-success">
          <CheckCircle size={18} />
          {successMsg}
          <button onClick={() => setSuccessMsg(null)} style={{ marginLeft: 'auto', background: 'none', border: 'none', cursor: 'pointer', color: 'inherit', fontSize: '16px' }}>&times;</button>
        </div>
      )}

      <div className="maintenance-header">
        <h2>Manutenção Preventiva</h2>
        <p>Controle de manutenção preventiva por horímetro</p>
      </div>

      {/* Tabs */}
      <div className="maintenance-tabs">
        <button
          className={`maintenance-tab ${activeTab === 'manutencao' ? 'active' : ''}`}
          onClick={() => handleTabChange('manutencao')}
        >
          <Wrench size={18} />
          Manutenção
          {pendentesCount > 0 && (
            <span className="tab-badge-pendente">{pendentesCount}</span>
          )}
        </button>
        <button
          className={`maintenance-tab ${activeTab === 'historico' ? 'active' : ''}`}
          onClick={() => handleTabChange('historico')}
        >
          <History size={18} />
          Histórico
        </button>
      </div>

      {/* Tab: Manutenção */}
      {activeTab === 'manutencao' && (
        <div className="maintenance-container">
          {!showDetails ? (
            <div className="motors-maintenance-list visible">
              <div className="list-header">
                <h3>Motores com Manutenção Configurada</h3>
                {loading ? (
                  <span className="badge-count">
                    <Loader className="spin" size={14} style={{ display: 'inline-block', marginRight: '0.5rem' }} />
                    Carregando...
                  </span>
                ) : (
                  <span className="badge-count">{motorsComManutencao.length}</span>
                )}
              </div>

              <div className="motors-list-content">
                {loading ? (
                  <div className="no-data">
                    <Loader className="spin" size={48} />
                    <p>Carregando motores...</p>
                  </div>
                ) : motorsComManutencao.length === 0 ? (
                  <div className="no-data">
                    <Wrench size={48} />
                    <p>Nenhum motor com manutenção configurada</p>
                    <p style={{ fontSize: '12px', marginTop: '8px', color: '#95a5a6' }}>
                      Configure o ciclo de manutenção na tela de Motores ({motors.length} motores)
                    </p>
                  </div>
                ) : (
                  motorsComManutencao.map((motor) => {
                    const pendente = isMotorPendente(motor);
                    const diasRestantes = getDiasRestantes(motor.dataEstimadaProximaManutencao);
                    const isUrgente = !pendente && diasRestantes !== null && diasRestantes <= 7;
                    const progresso = getProgresso(motor);

                    return (
                      <div
                        key={motor.id}
                        className={`motor-maintenance-card ${pendente ? 'pendente' : ''} ${isUrgente ? 'urgent' : ''}`}
                        onClick={() => handleSelectMotor(motor)}
                      >
                        <div className="motor-card-header">
                          <h4>{motor.nome}</h4>
                          {pendente ? (
                            <span className="pendente-badge">
                              <AlertTriangle size={12} />
                              Manutenção Pendente
                            </span>
                          ) : isUrgente ? (
                            <span className="urgent-badge">Urgente</span>
                          ) : null}
                        </div>

                        <div className="motor-card-info">
                          <div className="info-row">
                            <span className="label">Horímetro Atual:</span>
                            <span className="value">{horimetroInteiro(motor.horimetro)}h</span>
                          </div>
                          <div className="info-row">
                            <span className="label">Próxima Manutenção:</span>
                            <span className={`value ${pendente ? 'urgent-text' : ''}`}>
                              {motor.horimetroProximaManutencao != null ? `${horimetroInteiro(motor.horimetroProximaManutencao)}h` : 'N/A'}
                            </span>
                          </div>
                          <div className="info-row">
                            <span className="label">Ciclo:</span>
                            <span className="value">{motor.cicloManutencao}h</span>
                          </div>
                          {!pendente && motor.dataEstimadaProximaManutencao && (
                            <div className="info-row">
                              <span className="label">Data Estimada:</span>
                              <span className={`value ${isUrgente ? 'urgent-text' : ''}`}>
                                {format(new Date(motor.dataEstimadaProximaManutencao), 'dd/MM/yyyy', { locale: ptBR })}
                                {diasRestantes !== null && ` (${diasRestantes}d)`}
                              </span>
                            </div>
                          )}
                        </div>

                        {!pendente && (
                          <div className="progresso-bar-container">
                            <div className="progresso-bar" style={{ width: `${progresso}%`, background: progresso > 80 ? '#e74c3c' : progresso > 60 ? '#f39c12' : 'var(--primary-color)' }} />
                          </div>
                        )}
                      </div>
                    );
                  })
                )}
              </div>
            </div>
          ) : (
            <div className={`maintenance-details ${showDetails ? 'visible' : 'hidden'}`}>
              {selectedMotor && (
                <>
                  <button className="btn-back" onClick={handleBackToList}>
                    <ArrowLeft size={20} />
                    Voltar
                  </button>

                  <div className="motor-details-section">
                    <h3>{selectedMotor.nome}</h3>
                    <div className="details-grid">
                      <div className="detail-item">
                        <span className="detail-label">Horímetro Atual</span>
                        <span className="detail-value">{horimetroInteiro(selectedMotor.horimetro)}h</span>
                      </div>
                      <div className="detail-item">
                        <span className="detail-label">Próxima Manutenção</span>
                        <span className={`detail-value ${isMotorPendente(selectedMotor) ? 'urgent-text' : ''}`}>
                          {selectedMotor.horimetroProximaManutencao != null ? `${horimetroInteiro(selectedMotor.horimetroProximaManutencao)}h` : 'N/A'}
                        </span>
                      </div>
                      <div className="detail-item">
                        <span className="detail-label">Ciclo de Manutenção</span>
                        <span className="detail-value">{selectedMotor.cicloManutencao ?? 'N/A'}h</span>
                      </div>
                      <div className="detail-item">
                        <span className="detail-label">Data Estimada</span>
                        <span className="detail-value">
                          {selectedMotor.dataEstimadaProximaManutencao
                            ? format(new Date(selectedMotor.dataEstimadaProximaManutencao), 'dd/MM/yyyy', { locale: ptBR })
                            : 'Calculando...'}
                        </span>
                      </div>
                    </div>
                  </div>

                  {isMotorPendente(selectedMotor) && (
                    <div className="pendente-alert">
                      <AlertTriangle size={20} />
                      <div>
                        <strong>Manutenção Pendente!</strong>
                        <p>
                          O horímetro ({horimetroInteiro(selectedMotor.horimetro)}h) atingiu ou ultrapassou o limiar
                          ({selectedMotor.horimetroProximaManutencao != null ? horimetroInteiro(selectedMotor.horimetroProximaManutencao) : '?'}h).
                          Feche a manutenção abaixo para reiniciar o contador.
                        </p>
                      </div>
                    </div>
                  )}

                  {fechandoOS && (
                    <div className="fechar-manutencao-form">
                      <h4>Fechar Manutenção - {fechandoOS.numeroOS}</h4>
                      <p className="fechar-subtitle">
                        Descreva o que foi realizado e o que não foi feito nesta manutenção.
                        Ao fechar, o contador será reiniciado automaticamente.
                      </p>
                      <div className="form-group">
                        <label>Relatório de Manutenção *</label>
                        <textarea
                          value={relatorioTexto}
                          onChange={(e) => setRelatorioTexto(e.target.value)}
                          placeholder="Descreva os serviços realizados, peças trocadas, pendências para a próxima manutenção..."
                          rows={5}
                          disabled={submitting}
                        />
                      </div>
                      <div className="form-actions">
                        <button className="btn-cancel" onClick={handleCancelarFechamento} disabled={submitting}>
                          Cancelar
                        </button>
                        <button
                          className="btn-fechar-manutencao"
                          onClick={handleConfirmarFechamento}
                          disabled={submitting || !relatorioTexto.trim()}
                        >
                          {submitting ? (
                            <Loader className="spin" size={16} />
                          ) : (
                            <Send size={16} />
                          )}
                          {submitting ? 'Fechando...' : 'Confirmar Fechamento'}
                        </button>
                      </div>
                    </div>
                  )}

                  <div className="os-list-section">
                    <h3>Ordens de Serviço</h3>
                    {loadingOS ? (
                      <div className="no-os">
                        <Loader className="spin" size={48} />
                        <p>Carregando ordens de serviço...</p>
                      </div>
                    ) : (
                      <div className="os-list">
                        {ordensServico.filter(os => os.motorId === selectedMotor.id).length === 0 ? (
                          <div className="no-os">
                            <FileText size={48} />
                            <p>Nenhuma ordem de serviço registrada</p>
                            {isMotorPendente(selectedMotor) && (
                              <p style={{ fontSize: '12px', marginTop: '8px', color: '#95a5a6' }}>
                                Aguardando geração automática de OS...
                              </p>
                            )}
                          </div>
                        ) : (
                          ordensServico
                            .filter(os => os.motorId === selectedMotor.id)
                            .sort((a, b) => new Date(b.dataAbertura).getTime() - new Date(a.dataAbertura).getTime())
                            .map((os) => {
                              const isPendenteOS = os.status === 'pendente' || os.status === 'aberta';
                              return (
                                <div key={os.id} className={`os-card ${isPendenteOS ? 'os-card-pendente' : ''}`}>
                                  <div className="os-header">
                                    <div className="os-number">{os.numeroOS}</div>
                                    <span className="os-status" style={{ background: getOSStatusColor(os.status) }}>
                                      {getOSStatusIcon(os.status)}
                                      {getOSStatusLabel(os.status)}
                                    </span>
                                  </div>
                                  <div className="os-info">
                                    <p className="os-description">{os.descricao}</p>
                                    <div className="os-dates">
                                      <span>
                                        <Calendar size={14} />
                                        Abertura: {format(new Date(os.dataAbertura), 'dd/MM/yyyy', { locale: ptBR })}
                                      </span>
                                      {os.dataEncerramento && (
                                        <span>
                                          <CheckCircle size={14} />
                                          Encerramento: {format(new Date(os.dataEncerramento), 'dd/MM/yyyy', { locale: ptBR })}
                                        </span>
                                      )}
                                    </div>
                                    <div className="os-type">
                                      Tipo: <strong>{os.tipo === 'preventiva' ? 'Preventiva' : os.tipo === 'corretiva' ? 'Corretiva' : 'Preditiva'}</strong>
                                    </div>

                                    {os.relatorios && os.relatorios.length > 0 && (
                                      <div className="os-relatorios-inline">
                                        {os.relatorios.map((rel: any) => (
                                          <div key={rel.id} className="relatorio-inline">
                                            <span className="relatorio-inline-date">
                                              {format(new Date(rel.data), 'dd/MM/yyyy', { locale: ptBR })}
                                            </span>
                                            <span className="relatorio-inline-texto">{rel.descricao}</span>
                                          </div>
                                        ))}
                                      </div>
                                    )}
                                  </div>

                                  {isPendenteOS && fechandoOS?.id !== os.id && (
                                    <button
                                      className="btn-fechar-os"
                                      onClick={(e) => { e.stopPropagation(); handleFecharManutencao(os); }}
                                    >
                                      <Wrench size={16} />
                                      Fechar Manutenção
                                    </button>
                                  )}
                                </div>
                              );
                            })
                        )}
                      </div>
                    )}
                  </div>
                </>
              )}
            </div>
          )}
        </div>
      )}

      {/* Tab: Histórico */}
      {activeTab === 'historico' && (
        <div className="maintenance-container">
          <div className="motors-maintenance-list visible">
            <div className="list-header">
              <h3>Histórico de Manutenções Realizadas</h3>
              {loadingHistorico ? (
                <span className="badge-count">
                  <Loader className="spin" size={14} style={{ display: 'inline-block', marginRight: '0.5rem' }} />
                  Carregando...
                </span>
              ) : (
                <span className="badge-count">{historico.length}</span>
              )}
            </div>

            <div className="motors-list-content">
              {loadingHistorico ? (
                <div className="no-data">
                  <Loader className="spin" size={48} />
                  <p>Carregando histórico...</p>
                </div>
              ) : historico.length === 0 ? (
                <div className="no-data">
                  <History size={48} />
                  <p>Nenhuma manutenção concluída registrada</p>
                  <p style={{ fontSize: '12px', marginTop: '8px', color: '#95a5a6' }}>
                    O histórico será preenchido à medida que manutenções forem fechadas
                  </p>
                </div>
              ) : (
                historico.map((item) => {
                  const isExpanded = expandedHistoricoId === item.id;
                  return (
                    <div
                      key={item.id}
                      className={`historico-card ${isExpanded ? 'expanded' : ''}`}
                      onClick={() => setExpandedHistoricoId(isExpanded ? null : item.id)}
                    >
                      <div className="historico-card-header">
                        <div className="historico-card-left">
                          <span className="historico-os-number">{item.numeroOS}</span>
                          <span className="historico-motor-nome">{item.motorNome}</span>
                        </div>
                        <div className="historico-card-right">
                          <span className="os-status" style={{ background: '#27ae60' }}>
                            <CheckCircle size={14} />
                            Concluída
                          </span>
                        </div>
                      </div>

                      <div className="historico-card-dates">
                        <span>
                          <Calendar size={14} />
                          Abertura: {format(new Date(item.dataAbertura), 'dd/MM/yyyy', { locale: ptBR })}
                        </span>
                        {item.dataEncerramento && (
                          <span>
                            <CheckCircle size={14} />
                            Fechamento: {format(new Date(item.dataEncerramento), "dd/MM/yyyy 'às' HH:mm", { locale: ptBR })}
                          </span>
                        )}
                      </div>

                      <p className="historico-descricao">{item.descricao}</p>

                      {isExpanded && item.relatorios && item.relatorios.length > 0 && (
                        <div className="historico-relatorios">
                          <h5>Relatório da Manutenção</h5>
                          {item.relatorios.map((rel) => (
                            <div key={rel.id} className="historico-relatorio-item">
                              <div className="historico-relatorio-header">
                                <span className="historico-relatorio-data">
                                  <Calendar size={14} />
                                  {format(new Date(rel.data), "dd/MM/yyyy 'às' HH:mm", { locale: ptBR })}
                                </span>
                                {rel.tecnico && (
                                  <span className="historico-relatorio-tecnico">{rel.tecnico}</span>
                                )}
                              </div>
                              <p className="historico-relatorio-descricao">{rel.descricao}</p>
                              {rel.observacoes && (
                                <p className="historico-relatorio-obs">{rel.observacoes}</p>
                              )}
                            </div>
                          ))}
                        </div>
                      )}

                      {isExpanded && (!item.relatorios || item.relatorios.length === 0) && (
                        <div className="historico-relatorios">
                          <p style={{ color: '#95a5a6', fontSize: '13px', margin: 0 }}>Nenhum relatório registrado</p>
                        </div>
                      )}
                    </div>
                  );
                })
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}

export default Maintenance;
