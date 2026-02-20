import { useState, useEffect, useCallback } from 'react';
import { Plus, Edit2, Trash2, Save, X, Filter, Cog, Loader, Wifi, WifiOff, ArrowLeft } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { useMotorsCache } from '../contexts/MotorsCacheContext';
import { api } from '../services/api';
import { Motor } from '../types';
import { useWebSocketCorrentes } from '../hooks/useWebSocketCorrentes';
import './Motors.css';

function Motors() {
  const { plantaSelecionada } = useAuth();
  const { getMotors, invalidateCache } = useMotorsCache();
  const [motors, setMotors] = useState<Motor[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);
  const [selectedMotor, setSelectedMotor] = useState<Motor | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [isAdding, setIsAdding] = useState(false);
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [showDetails, setShowDetails] = useState(false);
  
  const [formData, setFormData] = useState<Partial<Motor>>({
    nome: '',
    potencia: 0,
    tensao: 380,
    correnteNominal: 0,
    percentualCorrenteMaxima: 110,
    histerese: 5,
    registroModBus: '',
    registroLocal: '',
    status: 'desligado',
    horimetro: 0,
    habilitado: true,
  });

  const handleSelectMotor = (motor: Motor) => {
    setSelectedMotor(motor);
    setFormData(motor);
    setIsEditing(false);
    setIsAdding(false);
    setShowDetails(true);
  };

  const handleBackToList = () => {
    setShowDetails(false);
    setSelectedMotor(null);
    setIsEditing(false);
    setIsAdding(false);
  };

  const handleAddNew = () => {
    setIsAdding(true);
    setIsEditing(true);
    setSelectedMotor(null);
    setShowDetails(true);
    setFormData({
      nome: '',
      potencia: 0,
      tensao: 380,
      correnteNominal: 0,
      percentualCorrenteMaxima: 110,
      histerese: 5,
      registroModBus: '',
      registroLocal: '',
      status: 'desligado',
      horimetro: 0,
      habilitado: true,
    });
  };

  const handleEdit = () => {
    setIsEditing(true);
  };

  const handleCancel = () => {
    if (isAdding) {
      handleBackToList();
      return;
    }
    setIsEditing(false);
    setIsAdding(false);
    if (selectedMotor) {
      setFormData(selectedMotor);
    }
  };

  // WebSocket para atualização em tempo real das correntes
  const handleCorrentesUpdate = useCallback((correntesMap: Map<string, import('../hooks/useWebSocketCorrentes').MotorCorrenteData>) => {
    setMotors(prevMotors => 
      prevMotors.map(motor => {
        const dadosCorrente = correntesMap.get(motor.id);
        if (dadosCorrente !== undefined) {
          const updatedMotor = { 
            ...motor, 
            correnteAtual: dadosCorrente.correnteAtual,
            correnteMedia: dadosCorrente.correnteMedia,
            correnteMaxima: dadosCorrente.correnteMaxima,
            correnteMinima: dadosCorrente.correnteMinima,
            status: dadosCorrente.status as Motor['status'] || motor.status,
          };
          // Atualizar motor selecionado se for o mesmo
          setSelectedMotor(prev => prev && prev.id === motor.id ? updatedMotor : prev);
          return updatedMotor;
        }
        return motor;
      })
    );
  }, []);

  const { isConnected: wsConnected } = useWebSocketCorrentes(
    plantaSelecionada?.id,
    handleCorrentesUpdate
  );

  // Buscar motores usando cache
  useEffect(() => {
    const loadMotors = async () => {
      if (!plantaSelecionada) {
        setMotors([]);
        setSelectedMotor(null);
        setShowDetails(false);
        return;
      }

      try {
        setError(null);
        // Carregar do cache (retorna imediatamente se tiver cache)
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

  const handleSave = async () => {
    if (!plantaSelecionada) {
      alert('Selecione uma planta primeiro');
      return;
    }

    try {
      setSaving(true);
      setError(null);

      if (isAdding) {
        // Criar novo motor
        const motorData = {
          nome: formData.nome,
          potencia: formData.potencia,
          tensao: formData.tensao,
          correnteNominal: formData.correnteNominal,
          percentualCorrenteMaxima: formData.percentualCorrenteMaxima,
          histerese: formData.histerese,
          registroModBus: formData.registroModBus,
          registroLocal: formData.registroLocal,
          horimetro: formData.horimetro || 0,
          habilitado: formData.habilitado !== undefined ? formData.habilitado : true,
          plantaId: plantaSelecionada.id,
        };
        
        const newMotor = await api.createMotor(motorData);
        const convertedMotor: Motor = {
          id: newMotor.id,
          nome: newMotor.nome,
          potencia: Number(newMotor.potencia),
          tensao: Number(newMotor.tensao),
          correnteNominal: Number(newMotor.correnteNominal),
          percentualCorrenteMaxima: Number(newMotor.percentualCorrenteMaxima),
          histerese: Number(newMotor.histerese),
          registroModBus: newMotor.registroModBus,
          registroLocal: newMotor.registroLocal,
          status: newMotor.status as Motor['status'],
          horimetro: Number(newMotor.horimetro),
          // Converter correnteAtual: dividir por 100 (ex: 2153 -> 21.5)
          correnteAtual: (Number(newMotor.correnteAtual || 0)) / 100,
          posicaoX: newMotor.posicaoX ? Number(newMotor.posicaoX) : undefined,
          posicaoY: newMotor.posicaoY ? Number(newMotor.posicaoY) : undefined,
          habilitado: newMotor.habilitado !== undefined ? newMotor.habilitado : true,
        };
        setMotors([...motors, convertedMotor]);
        setSelectedMotor(convertedMotor);
        // Invalidar cache para forçar atualização
        if (plantaSelecionada) {
          invalidateCache(plantaSelecionada.id);
        }
      } else if (selectedMotor) {
        // Atualizar apenas configuração do motor (preserva posição, status, horimetro, etc)
        await api.updateMotorConfiguracao(selectedMotor.id, {
          nome: formData.nome ?? '',
          potencia: formData.potencia ?? 0,
          tensao: formData.tensao ?? 380,
          correnteNominal: formData.correnteNominal ?? 0,
          percentualCorrenteMaxima: formData.percentualCorrenteMaxima ?? 110,
          histerese: formData.histerese ?? 5,
          registroModBus: formData.registroModBus ?? undefined,
          registroLocal: formData.registroLocal ?? undefined,
          habilitado: formData.habilitado ?? true,
          plantaId: plantaSelecionada.id,
        });
        
        // Buscar motor atualizado para atualizar o estado local
        const updatedMotor = await api.getMotor(selectedMotor.id);
        const convertedMotor: Motor = {
          id: updatedMotor.id || selectedMotor.id,
          nome: updatedMotor.nome,
          potencia: Number(updatedMotor.potencia),
          tensao: Number(updatedMotor.tensao),
          correnteNominal: Number(updatedMotor.correnteNominal),
          percentualCorrenteMaxima: Number(updatedMotor.percentualCorrenteMaxima),
          histerese: Number(updatedMotor.histerese),
          registroModBus: updatedMotor.registroModBus,
          registroLocal: updatedMotor.registroLocal,
          status: updatedMotor.status as Motor['status'],
          horimetro: Number(updatedMotor.horimetro),
          // Converter correnteAtual: dividir por 100 (ex: 2153 -> 21.5)
          correnteAtual: (Number(updatedMotor.correnteAtual || 0)) / 100,
          posicaoX: updatedMotor.posicaoX ? Number(updatedMotor.posicaoX) : undefined,
          posicaoY: updatedMotor.posicaoY ? Number(updatedMotor.posicaoY) : undefined,
          habilitado: updatedMotor.habilitado !== undefined ? updatedMotor.habilitado : true,
        };
        setMotors(motors.map(m => m.id === selectedMotor.id ? convertedMotor : m));
        setSelectedMotor(convertedMotor);
        // Invalidar cache para forçar atualização
        if (plantaSelecionada) {
          invalidateCache(plantaSelecionada.id);
        }
      }
      setIsEditing(false);
      setIsAdding(false);
    } catch (err: any) {
      setError(err.message || 'Erro ao salvar motor');
      console.error('Erro ao salvar motor:', err);
      alert('Erro ao salvar motor: ' + (err.message || 'Erro desconhecido'));
    } finally {
      setSaving(false);
    }
  };

  const handleDelete = async (motorId: string) => {
    if (!window.confirm('Tem certeza que deseja excluir este motor?')) {
      return;
    }

    try {
      setError(null);
      await api.deleteMotor(motorId);
      setMotors(motors.filter(m => m.id !== motorId));
      // Invalidar cache para forçar atualização
      if (plantaSelecionada) {
        invalidateCache(plantaSelecionada.id);
      }
      if (selectedMotor?.id === motorId) {
        setSelectedMotor(null);
        setShowDetails(false);
      }
    } catch (err: any) {
      setError(err.message || 'Erro ao excluir motor');
      console.error('Erro ao excluir motor:', err);
      alert('Erro ao excluir motor: ' + (err.message || 'Erro desconhecido'));
    }
  };

  const handleInputChange = (field: keyof Motor, value: any) => {
    setFormData({ ...formData, [field]: value });
  };


  const filteredMotors = motors.filter(motor =>
    filterStatus === 'all' || motor.status === filterStatus
  );

  if (loading) {
    return (
      <div className="motors-page fade-in">
        <div style={{ textAlign: 'center', padding: '2rem' }}>
          <Loader className="spin" size={32} />
          <p style={{ marginTop: '1rem' }}>Carregando motores...</p>
        </div>
      </div>
    );
  }

  if (!plantaSelecionada) {
    return (
      <div className="motors-page fade-in">
        <div style={{ textAlign: 'center', padding: '2rem' }}>
          <p>Selecione uma planta para visualizar os motores</p>
        </div>
      </div>
    );
  }

  return (
    <div className="motors-page fade-in">
      {error && (
        <div style={{ 
          background: '#fee', 
          color: '#c33', 
          padding: '1rem', 
          marginBottom: '1rem', 
          borderRadius: '8px' 
        }}>
          {error}
        </div>
      )}
      <div className="motors-header">
        <div className="header-actions motors-header-left">
          {/* Status da corrente em cima, filtro embaixo */}
          <div className="motors-status-and-filter">
            <div className={`connection-status ${wsConnected ? 'connected' : 'disconnected'}`} title={wsConnected ? 'Correntes em tempo real' : 'Correntes desconectado'}>
              {wsConnected ? (
                <>
                  <Wifi size={16} aria-hidden />
                  <span>Correntes em tempo real</span>
                </>
              ) : (
                <>
                  <WifiOff size={16} aria-hidden />
                  <span>Correntes desconectado</span>
                </>
              )}
            </div>
            <div className="filter-box">
              <Filter size={20} />
              <select value={filterStatus} onChange={(e) => setFilterStatus(e.target.value)}>
                <option value="all">Todos Status</option>
                <option value="ligado">Ligado</option>
                <option value="desligado">Desligado</option>
                <option value="alerta">Alerta</option>
                <option value="alarme">Alarme</option>
                <option value="pendente">Pendente</option>
              </select>
            </div>
          </div>
        </div>
        <button className="btn-primary" onClick={handleAddNew}>
          <Plus size={20} />
          Adicionar Motor
        </button>
      </div>

      <div className="motors-container">
        {/* Motors List */}
        {!showDetails ? (
          <div className={`motors-list ${showDetails ? 'hidden' : 'visible'}`}>
            {filteredMotors.length === 0 ? (
              <div className="no-motors">
                <Cog size={64} />
                <h3>Nenhum motor encontrado</h3>
                <p>Não há motores que correspondam aos filtros selecionados</p>
              </div>
            ) : (
              <div className="motors-cards-list">
                {filteredMotors.map((motor) => {
                  const statusConfig = {
                    ligado: { label: 'Ligado', color: '#27ae60' },
                    desligado: { label: 'Desligado', color: '#95a5a6' },
                    alerta: { label: 'Alerta', color: '#f39c12' },
                    alarme: { label: 'Alarme', color: '#e74c3c' },
                    pendente: { label: 'Pendente', color: '#9b59b6' },
                  };
                  const config = statusConfig[motor.status as keyof typeof statusConfig] || statusConfig.desligado;
                  
                  return (
                    <div
                      key={motor.id}
                      className="motor-card"
                      style={{ borderLeftColor: config.color }}
                      onClick={() => handleSelectMotor(motor)}
                    >
                      <div className="motor-card-icon" style={{ background: config.color }}>
                        <Cog size={24} />
                      </div>
                      <div className="motor-card-content">
                        <div className="motor-card-header">
                          <div className="motor-card-info">
                            <h4 className="motor-name">{motor.nome}</h4>
                          </div>
                          <span className="motor-status-badge" style={{ background: config.color }}>
                            {config.label}
                          </span>
                        </div>
                        <div className="motor-card-details">
                          <div className="detail-item">
                            <span className="detail-label">Horímetro:</span>
                            <span className="detail-value">{motor.horimetro}h</span>
                          </div>
                          <div className="detail-item">
                            <span className="detail-label">Corrente:</span>
                            <span className="detail-value" style={{ fontSize: '0.9rem', whiteSpace: 'nowrap' }}>
                              Inst: {motor.correnteAtual.toFixed(1)}A
                              {motor.correnteMedia !== undefined && ` média: ${motor.correnteMedia.toFixed(1)}A`}
                              {motor.correnteMaxima !== undefined && ` max: ${motor.correnteMaxima.toFixed(1)}A`}
                              {motor.correnteMinima !== undefined && ` min: ${motor.correnteMinima.toFixed(1)}A`}
                            </span>
                          </div>
                        </div>
                      </div>
                    </div>
                  );
                })}
              </div>
            )}
          </div>
        ) : (
          <div className={`motor-details ${showDetails ? 'visible' : 'hidden'}`}>
          {selectedMotor || isAdding ? (
            <>
              <div className="details-header">
                <h3>{isAdding ? 'Novo Motor' : isEditing ? 'Editar Motor' : 'Detalhes do Motor'}</h3>
                {!isAdding && !isEditing && (
                  <div className="header-actions">
                    <button className="btn-secondary" onClick={handleBackToList}>
                      <ArrowLeft size={18} />
                      Voltar
                    </button>
                    <button className="btn-secondary" onClick={handleEdit}>
                      <Edit2 size={18} />
                      Editar
                    </button>
                    <button
                      className="btn-danger"
                      onClick={() => selectedMotor && handleDelete(selectedMotor.id)}
                    >
                      <Trash2 size={18} />
                      Excluir
                    </button>
                  </div>
                )}
                {(isEditing || isAdding) && (
                  <div className="header-actions">
                    <button className="btn-secondary" onClick={handleCancel}>
                      <X size={18} />
                      Cancelar
                    </button>
                    <button 
                      className="btn-primary" 
                      onClick={handleSave}
                      disabled={saving}
                    >
                      {saving ? (
                        <>
                          <Loader className="spin" size={18} />
                          Salvando...
                        </>
                      ) : (
                        <>
                          <Save size={18} />
                          Salvar
                        </>
                      )}
                    </button>
                  </div>
                )}
              </div>

              <div className="details-form">
                <div className="form-section">
                  <h4>Informações Básicas</h4>
                  <div className="form-grid">
                    <div className="form-field">
                      <label>Nome do Motor *</label>
                      <input
                        type="text"
                        value={formData.nome}
                        onChange={(e) => handleInputChange('nome', e.target.value)}
                        disabled={!isEditing && !isAdding}
                        placeholder="Ex: Motor Britador Principal"
                      />
                    </div>

                    <div className="form-field">
                      <label>Horímetro (horas)</label>
                      <input
                        type="number"
                        value={formData.horimetro}
                        onChange={(e) => handleInputChange('horimetro', Number(e.target.value))}
                        disabled={!isEditing && !isAdding}
                      />
                    </div>

                    <div className="form-field">
                      <label>
                        <input
                          type="checkbox"
                          checked={formData.habilitado !== undefined ? formData.habilitado : true}
                          onChange={(e) => handleInputChange('habilitado', e.target.checked)}
                          disabled={!isEditing && !isAdding}
                        />
                        <span style={{ marginLeft: '8px' }}>Habilitado</span>
                      </label>
                      <span className="field-hint">
                        Motor habilitado aparece no mapa e recebe alarmes
                      </span>
                    </div>
                  </div>
                </div>

                <div className="form-section">
                  <h4>Especificações Elétricas</h4>
                  <div className="form-grid">
                    <div className="form-field">
                      <label>Potência do Motor (kW) *</label>
                      <input
                        type="number"
                        value={formData.potencia}
                        onChange={(e) => handleInputChange('potencia', Number(e.target.value))}
                        disabled={!isEditing && !isAdding}
                        placeholder="250"
                      />
                    </div>

                    <div className="form-field">
                      <label>Tensão de Alimentação (V) *</label>
                      <input
                        type="number"
                        value={formData.tensao}
                        onChange={(e) => handleInputChange('tensao', Number(e.target.value))}
                        disabled={!isEditing && !isAdding}
                        placeholder="380"
                      />
                    </div>

                    <div className="form-field">
                      <label>Corrente Nominal (A) *</label>
                      <input
                        type="number"
                        value={formData.correnteNominal}
                        onChange={(e) => handleInputChange('correnteNominal', Number(e.target.value))}
                        disabled={!isEditing && !isAdding}
                        placeholder="380"
                      />
                    </div>
                  </div>
                </div>

                <div className="form-section">
                  <h4>Parâmetros de Proteção</h4>
                  <div className="form-grid">
                    <div className="form-field">
                      <label>Percentual Corrente Máxima (%) *</label>
                      <input
                        type="number"
                        value={formData.percentualCorrenteMaxima}
                        onChange={(e) => handleInputChange('percentualCorrenteMaxima', Number(e.target.value))}
                        disabled={!isEditing && !isAdding}
                        placeholder="110"
                      />
                      <span className="field-hint">
                        Máximo: {((formData.correnteNominal || 0) * (formData.percentualCorrenteMaxima || 0) / 100).toFixed(1)}A
                      </span>
                    </div>

                    <div className="form-field">
                      <label>Histerese (%) *</label>
                      <input
                        type="number"
                        value={formData.histerese}
                        onChange={(e) => handleInputChange('histerese', Number(e.target.value))}
                        disabled={!isEditing && !isAdding}
                        placeholder="5"
                      />
                      <span className="field-hint">
                        Margem de erro para alarmes
                      </span>
                    </div>

                    <div className="form-field">
                      <label>Registro ModBus</label>
                      <input
                        type="text"
                        value={formData.registroModBus || ''}
                        onChange={(e) => handleInputChange('registroModBus', e.target.value)}
                        disabled={!isEditing && !isAdding}
                        placeholder="Ex: 40001"
                      />
                      <span className="field-hint">
                        Endereço do registro ModBus
                      </span>
                    </div>

                    <div className="form-field">
                      <label>Registro Local</label>
                      <input
                        type="text"
                        value={formData.registroLocal || ''}
                        onChange={(e) => handleInputChange('registroLocal', e.target.value)}
                        disabled={!isEditing && !isAdding}
                        placeholder="Ex: R001"
                      />
                      <span className="field-hint">
                        Identificação local do registro
                      </span>
                    </div>
                  </div>
                </div>

                {!isEditing && !isAdding && selectedMotor && (
                  <div className="form-section">
                    <h4>Informações de Operação</h4>
                    <div className="info-grid">
                      <div className="info-card">
                        <span className="info-label">Tempo de Operação</span>
                        <span className="info-value">{selectedMotor.horimetro} horas</span>
                      </div>
                      <div className="info-card">
                        <span className="info-label">Utilização</span>
                        <span className="info-value">
                          {((selectedMotor.correnteAtual / selectedMotor.correnteNominal) * 100).toFixed(1)}%
                        </span>
                      </div>
                      <div className="info-card">
                        <span className="info-label">Limite de Corrente</span>
                        <span className="info-value">
                          {((selectedMotor.correnteNominal * selectedMotor.percentualCorrenteMaxima) / 100).toFixed(1)}A
                        </span>
                      </div>
                      <div className="info-card">
                        <span className="info-label">Potência Consumida</span>
                        <span className="info-value">
                          {((selectedMotor.correnteAtual * selectedMotor.tensao * Math.sqrt(3)) / 1000).toFixed(1)}kW
                        </span>
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </>
          ) : null}
          </div>
        )}
      </div>
    </div>
  );
}

export default Motors;
