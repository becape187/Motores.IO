import { useState } from 'react';
import { Calendar, Clock, FileText, Plus, X, Save, AlertCircle, CheckCircle, Clock3, Hourglass, ArrowLeft } from 'lucide-react';
import { format, differenceInDays } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { mockMotors, mockOrdensServico } from '../data/mockData';
import { Motor, OrdemServico, RelatorioOS } from '../types';
import './Maintenance.css';

function Maintenance() {
  const [motors] = useState<Motor[]>(mockMotors);
  const [ordensServico, setOrdensServico] = useState<OrdemServico[]>(mockOrdensServico);
  const [selectedMotor, setSelectedMotor] = useState<Motor | null>(null);
  const [selectedOS, setSelectedOS] = useState<OrdemServico | null>(null);
  const [isAddingRelatorio, setIsAddingRelatorio] = useState(false);
  const [showDetails, setShowDetails] = useState(false);
  const [showOSDetails, setShowOSDetails] = useState(false);
  const [relatorioForm, setRelatorioForm] = useState<Partial<RelatorioOS>>({
    tecnico: '',
    descricao: '',
    observacoes: '',
  });

  // Filtrar motores com manutenção à vencer (próximos 30 dias ou já vencidos)
  // Por enquanto, mostrar todos os motores que têm data de manutenção
  const motorsManutencaoVencer = motors.filter(motor => {
    return motor.dataEstimadaProximaManutencao !== undefined && motor.dataEstimadaProximaManutencao !== null;
  }).sort((a, b) => {
    if (!a.dataEstimadaProximaManutencao || !b.dataEstimadaProximaManutencao) return 0;
    return a.dataEstimadaProximaManutencao.getTime() - b.dataEstimadaProximaManutencao.getTime();
  });

  // Debug: verificar se há motores
  console.log('Total de motores:', motors.length);
  console.log('Motores com manutenção:', motorsManutencaoVencer.length);
  console.log('showDetails:', showDetails);

  const handleSelectMotor = (motor: Motor) => {
    setSelectedMotor(motor);
    setSelectedOS(null);
    setIsAddingRelatorio(false);
    setShowDetails(true);
    setShowOSDetails(false);
  };

  const handleBackToList = () => {
    setShowDetails(false);
    setShowOSDetails(false);
    setSelectedMotor(null);
    setSelectedOS(null);
  };

  const handleSelectOS = (os: OrdemServico) => {
    setSelectedOS(os);
    setIsAddingRelatorio(false);
    setShowOSDetails(true);
  };

  const handleBackToMotor = () => {
    setShowOSDetails(false);
    setSelectedOS(null);
  };

  const handleAddRelatorio = () => {
    setIsAddingRelatorio(true);
    setRelatorioForm({
      tecnico: '',
      descricao: '',
      observacoes: '',
    });
  };

  const handleSaveRelatorio = () => {
    if (!selectedOS || !relatorioForm.tecnico || !relatorioForm.descricao) return;

    const newRelatorio: RelatorioOS = {
      id: `rel-${Date.now()}`,
      osId: selectedOS.id,
      data: new Date(),
      tecnico: relatorioForm.tecnico,
      descricao: relatorioForm.descricao,
      observacoes: relatorioForm.observacoes || '',
    };

    setOrdensServico(ordensServico.map(os =>
      os.id === selectedOS.id
        ? { ...os, relatorios: [...os.relatorios, newRelatorio] }
        : os
    ));

    setSelectedOS({
      ...selectedOS,
      relatorios: [...selectedOS.relatorios, newRelatorio],
    });

    setIsAddingRelatorio(false);
    setRelatorioForm({
      tecnico: '',
      descricao: '',
      observacoes: '',
    });
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
      case 'aberta': return <Clock3 size={18} />;
      case 'concluida': return <CheckCircle size={18} />;
      case 'atrasada': return <AlertCircle size={18} />;
      case 'pendente': return <Hourglass size={18} />;
      default: return <Clock size={18} />;
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

  const getMotorOS = (motorId: string) => {
    return ordensServico.filter(os => os.motorId === motorId)
      .sort((a, b) => b.dataAbertura.getTime() - a.dataAbertura.getTime());
  };

  const getDiasRestantes = (data?: Date) => {
    if (!data) return null;
    const dias = differenceInDays(data, new Date());
    return dias;
  };

  return (
    <div className="maintenance-page fade-in">
      <div className="maintenance-header">
        <h2>Manutenção de Motores</h2>
        <p>Gestão de manutenções preventivas e corretivas</p>
      </div>

      <div className="maintenance-container">
        {/* Lista de Motores */}
        {!showDetails ? (
          <div className="motors-maintenance-list visible">
            <div className="list-header">
              <h3>Motores com Manutenção à Vencer</h3>
              <span className="badge-count">{motorsManutencaoVencer.length}</span>
            </div>

            <div className="motors-list-content">
            {motorsManutencaoVencer.length === 0 ? (
              <div className="no-data">
                <CheckCircle size={48} />
                <p>Nenhum motor com manutenção à vencer</p>
                <p style={{ fontSize: '12px', marginTop: '8px', color: '#95a5a6' }}>
                  Total de motores: {motors.length}
                </p>
              </div>
            ) : (
              motorsManutencaoVencer.map((motor) => {
                const diasRestantes = getDiasRestantes(motor.dataEstimadaProximaManutencao);
                const isUrgente = diasRestantes !== null && diasRestantes <= 7;
                
                return (
                  <div
                    key={motor.id}
                    className={`motor-maintenance-card ${selectedMotor?.id === motor.id ? 'selected' : ''} ${isUrgente ? 'urgent' : ''}`}
                    onClick={() => handleSelectMotor(motor)}
                  >
                    <div className="motor-card-header">
                      <h4>{motor.nome}</h4>
                      {isUrgente && (
                        <span className="urgent-badge">Urgente</span>
                      )}
                    </div>
                    
                    <div className="motor-card-info">
                      <div className="info-row">
                        <span className="label">Horímetro Atual:</span>
                        <span className="value">{motor.horimetro}h</span>
                      </div>
                      <div className="info-row">
                        <span className="label">Próxima Manutenção:</span>
                        <span className="value">{motor.horimetroProximaManutencao}h</span>
                      </div>
                      <div className="info-row">
                        <span className="label">Data Estimada:</span>
                        <span className="value">
                          {motor.dataEstimadaProximaManutencao
                            ? format(motor.dataEstimadaProximaManutencao, 'dd/MM/yyyy', { locale: ptBR })
                            : 'N/A'}
                        </span>
                      </div>
                      {diasRestantes !== null && (
                        <div className="info-row">
                          <span className="label">Dias Restantes:</span>
                          <span className={`value ${isUrgente ? 'urgent-text' : ''}`}>
                            {diasRestantes} dias
                          </span>
                        </div>
                      )}
                      <div className="info-row">
                        <span className="label">Total de OS:</span>
                        <span className="value">{motor.totalOS || 0}</span>
                      </div>
                    </div>

                    <div className="motor-card-stats">
                      <div className="stat-item">
                        <span className="stat-label">Média/Dia</span>
                        <span className="stat-value">{motor.mediaHorasDia?.toFixed(1) || 0}h</span>
                      </div>
                      <div className="stat-item">
                        <span className="stat-label">Média/Semana</span>
                        <span className="stat-value">{motor.mediaHorasSemana?.toFixed(1) || 0}h</span>
                      </div>
                      <div className="stat-item">
                        <span className="stat-label">Média/Mês</span>
                        <span className="stat-value">{motor.mediaHorasMes?.toFixed(1) || 0}h</span>
                      </div>
                    </div>
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
              {/* Botão Voltar */}
              <button className="btn-back" onClick={handleBackToList}>
                <ArrowLeft size={20} />
                Voltar
              </button>

              {/* Informações do Motor */}
              <div className="motor-details-section">
                <h3>{selectedMotor.nome}</h3>
                <div className="details-grid">
                  <div className="detail-item">
                    <span className="detail-label">Horímetro Atual</span>
                    <span className="detail-value">{selectedMotor.horimetro}h</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Horímetro Próxima Manutenção</span>
                    <span className="detail-value">{selectedMotor.horimetroProximaManutencao || 'N/A'}h</span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Data Estimada</span>
                    <span className="detail-value">
                      {selectedMotor.dataEstimadaProximaManutencao
                        ? format(selectedMotor.dataEstimadaProximaManutencao, 'dd/MM/yyyy', { locale: ptBR })
                        : 'N/A'}
                    </span>
                  </div>
                  <div className="detail-item">
                    <span className="detail-label">Total de OS</span>
                    <span className="detail-value">{selectedMotor.totalOS || 0}</span>
                  </div>
                </div>
              </div>

              {/* Lista de OS */}
              {!showOSDetails ? (
                <div className="os-list-section">
                  <h3>Ordens de Serviço</h3>
                  <div className="os-list">
                    {getMotorOS(selectedMotor.id).length === 0 ? (
                      <div className="no-os">
                        <FileText size={48} />
                        <p>Nenhuma ordem de serviço registrada</p>
                      </div>
                    ) : (
                      getMotorOS(selectedMotor.id).map((os) => (
                        <div
                          key={os.id}
                          className="os-card"
                          onClick={() => handleSelectOS(os)}
                        >
                        <div className="os-header">
                          <div className="os-number">{os.numeroOS}</div>
                          <span
                            className="os-status"
                            style={{ background: getOSStatusColor(os.status) }}
                          >
                            {getOSStatusIcon(os.status)}
                            {getOSStatusLabel(os.status)}
                          </span>
                        </div>
                        <div className="os-info">
                          <p className="os-description">{os.descricao}</p>
                          <div className="os-dates">
                            <span>
                              <Calendar size={14} />
                              Abertura: {format(os.dataAbertura, 'dd/MM/yyyy', { locale: ptBR })}
                            </span>
                            {os.dataEncerramento && (
                              <span>
                                <CheckCircle size={14} />
                                Encerramento: {format(os.dataEncerramento, 'dd/MM/yyyy', { locale: ptBR })}
                              </span>
                            )}
                            {os.dataPrevista && (
                              <span>
                                <Clock size={14} />
                                Prevista: {format(os.dataPrevista, 'dd/MM/yyyy', { locale: ptBR })}
                              </span>
                            )}
                          </div>
                          <div className="os-type">
                            Tipo: <strong>{os.tipo === 'preventiva' ? 'Preventiva' : os.tipo === 'corretiva' ? 'Corretiva' : 'Preditiva'}</strong>
                          </div>
                        </div>
                        </div>
                      ))
                    )}
                  </div>
                </div>
              ) : (
                selectedOS && (
                  <div className="os-details-section">
                    <button className="btn-back-os" onClick={handleBackToMotor}>
                      <ArrowLeft size={20} />
                      Voltar para OS
                    </button>
                    <div className="os-details-header">
                      <h3>{selectedOS.numeroOS}</h3>
                    </div>

                  <div className="os-details-content">
                    <div className="os-details-info">
                      <div className="info-item">
                        <span className="info-label">Status:</span>
                        <span
                          className="info-badge"
                          style={{ background: getOSStatusColor(selectedOS.status) }}
                        >
                          {getOSStatusIcon(selectedOS.status)}
                          {getOSStatusLabel(selectedOS.status)}
                        </span>
                      </div>
                      <div className="info-item">
                        <span className="info-label">Tipo:</span>
                        <span className="info-value">
                          {selectedOS.tipo === 'preventiva' ? 'Preventiva' : selectedOS.tipo === 'corretiva' ? 'Corretiva' : 'Preditiva'}
                        </span>
                      </div>
                      <div className="info-item">
                        <span className="info-label">Descrição:</span>
                        <span className="info-value">{selectedOS.descricao}</span>
                      </div>
                      <div className="info-item">
                        <span className="info-label">Data de Abertura:</span>
                        <span className="info-value">
                          {format(selectedOS.dataAbertura, "dd/MM/yyyy 'às' HH:mm", { locale: ptBR })}
                        </span>
                      </div>
                      {selectedOS.dataEncerramento && (
                        <div className="info-item">
                          <span className="info-label">Data de Encerramento:</span>
                          <span className="info-value">
                            {format(selectedOS.dataEncerramento, "dd/MM/yyyy 'às' HH:mm", { locale: ptBR })}
                          </span>
                        </div>
                      )}
                      {selectedOS.dataPrevista && (
                        <div className="info-item">
                          <span className="info-label">Data Prevista:</span>
                          <span className="info-value">
                            {format(selectedOS.dataPrevista, "dd/MM/yyyy 'às' HH:mm", { locale: ptBR })}
                          </span>
                        </div>
                      )}
                    </div>

                    {/* Relatórios */}
                    <div className="relatorios-section">
                      <div className="relatorios-header">
                        <h4>Relatórios ({selectedOS.relatorios.length})</h4>
                        <button className="btn-add-relatorio" onClick={handleAddRelatorio}>
                          <Plus size={18} />
                          Adicionar Relatório
                        </button>
                      </div>

                      {isAddingRelatorio && (
                        <div className="relatorio-form">
                          <div className="form-group">
                            <label>Técnico *</label>
                            <input
                              type="text"
                              value={relatorioForm.tecnico}
                              onChange={(e) => setRelatorioForm({ ...relatorioForm, tecnico: e.target.value })}
                              placeholder="Nome do técnico"
                            />
                          </div>
                          <div className="form-group">
                            <label>Descrição *</label>
                            <input
                              type="text"
                              value={relatorioForm.descricao}
                              onChange={(e) => setRelatorioForm({ ...relatorioForm, descricao: e.target.value })}
                              placeholder="Descrição do relatório"
                            />
                          </div>
                          <div className="form-group">
                            <label>Observações</label>
                            <textarea
                              value={relatorioForm.observacoes}
                              onChange={(e) => setRelatorioForm({ ...relatorioForm, observacoes: e.target.value })}
                              placeholder="Observações detalhadas..."
                              rows={4}
                            />
                          </div>
                          <div className="form-actions">
                            <button className="btn-cancel" onClick={() => setIsAddingRelatorio(false)}>
                              <X size={18} />
                              Cancelar
                            </button>
                            <button className="btn-save" onClick={handleSaveRelatorio}>
                              <Save size={18} />
                              Salvar
                            </button>
                          </div>
                        </div>
                      )}

                      <div className="relatorios-list">
                        {selectedOS.relatorios.length === 0 ? (
                          <div className="no-relatorios">
                            <FileText size={32} />
                            <p>Nenhum relatório registrado</p>
                          </div>
                        ) : (
                          selectedOS.relatorios
                            .sort((a, b) => b.data.getTime() - a.data.getTime())
                            .map((relatorio) => (
                              <div key={relatorio.id} className="relatorio-card">
                                <div className="relatorio-header">
                                  <div className="relatorio-date">
                                    <Calendar size={16} />
                                    {format(relatorio.data, "dd/MM/yyyy 'às' HH:mm", { locale: ptBR })}
                                  </div>
                                  <div className="relatorio-tecnico">
                                    <strong>{relatorio.tecnico}</strong>
                                  </div>
                                </div>
                                <div className="relatorio-content">
                                  <h5>{relatorio.descricao}</h5>
                                  {relatorio.observacoes && (
                                    <p className="relatorio-observacoes">{relatorio.observacoes}</p>
                                  )}
                                </div>
                              </div>
                            ))
                        )}
                      </div>
                    </div>
                  </div>
                  </div>
                )
              )}
            </>
            )}
          </div>
        )}
      </div>
    </div>
  );
}

export default Maintenance;
