import { useState } from 'react';
import { Plus, Edit2, Trash2, Save, X, Search, Filter, ArrowLeft, Cog } from 'lucide-react';
import { mockMotors } from '../data/mockData';
import { Motor } from '../types';
import './Motors.css';

function Motors() {
  const [motors, setMotors] = useState<Motor[]>(mockMotors);
  const [selectedMotor, setSelectedMotor] = useState<Motor | null>(null);
  const [isEditing, setIsEditing] = useState(false);
  const [isAdding, setIsAdding] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [showDetails, setShowDetails] = useState(false);
  
  const [formData, setFormData] = useState<Partial<Motor>>({
    nome: '',
    potencia: 0,
    tensao: 380,
    correnteNominal: 0,
    percentualCorrenteMaxima: 110,
    histerese: 5,
    correnteInicial: 0,
    status: 'desligado',
    horimetro: 0,
    correnteAtual: 0,
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
      correnteInicial: 0,
      status: 'desligado',
      horimetro: 0,
      correnteAtual: 0,
    });
  };

  const handleEdit = () => {
    setIsEditing(true);
  };

  const handleCancel = () => {
    setIsEditing(false);
    setIsAdding(false);
    if (selectedMotor) {
      setFormData(selectedMotor);
    }
  };

  const handleSave = () => {
    if (isAdding) {
      const newMotor: Motor = {
        ...formData as Motor,
        id: String(motors.length + 1),
      };
      setMotors([...motors, newMotor]);
      setSelectedMotor(newMotor);
    } else if (selectedMotor) {
      setMotors(motors.map(m => 
        m.id === selectedMotor.id ? { ...formData as Motor, id: selectedMotor.id } : m
      ));
      setSelectedMotor({ ...formData as Motor, id: selectedMotor.id });
    }
    setIsEditing(false);
    setIsAdding(false);
  };

  const handleDelete = (motorId: string) => {
    if (window.confirm('Tem certeza que deseja excluir este motor?')) {
      setMotors(motors.filter(m => m.id !== motorId));
      if (selectedMotor?.id === motorId) {
        setSelectedMotor(null);
      }
    }
  };

  const handleInputChange = (field: keyof Motor, value: any) => {
    setFormData({ ...formData, [field]: value });
  };


  const filteredMotors = motors.filter(motor => {
    const matchesSearch = motor.nome.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         motor.id.includes(searchTerm);
    const matchesFilter = filterStatus === 'all' || motor.status === filterStatus;
    return matchesSearch && matchesFilter;
  });

  return (
    <div className="motors-page fade-in">
      <div className="motors-header">
        <div className="header-actions">
          <div className="search-box">
            <Search size={20} />
            <input
              type="text"
              placeholder="Buscar motor..."
              value={searchTerm}
              onChange={(e) => setSearchTerm(e.target.value)}
            />
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
                            <span className="motor-id">M{motor.id}</span>
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
                            <span className="detail-value">
                              {motor.correnteAtual.toFixed(1)}A / {motor.correnteNominal}A
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
                <button className="btn-back" onClick={handleBackToList}>
                  <ArrowLeft size={20} />
                  Voltar
                </button>
                <h3>{isAdding ? 'Novo Motor' : isEditing ? 'Editar Motor' : 'Detalhes do Motor'}</h3>
                {!isAdding && !isEditing && (
                  <div className="header-actions">
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
                    <button className="btn-primary" onClick={handleSave}>
                      <Save size={18} />
                      Salvar
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
                      <label>Status</label>
                      <select
                        value={formData.status}
                        onChange={(e) => handleInputChange('status', e.target.value)}
                        disabled={!isEditing && !isAdding}
                      >
                        <option value="ligado">Ligado</option>
                        <option value="desligado">Desligado</option>
                        <option value="alerta">Alerta</option>
                        <option value="alarme">Alarme</option>
                        <option value="pendente">Pendente</option>
                      </select>
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

                    <div className="form-field">
                      <label>Corrente Atual (A)</label>
                      <input
                        type="number"
                        step="0.1"
                        value={formData.correnteAtual}
                        onChange={(e) => handleInputChange('correnteAtual', Number(e.target.value))}
                        disabled={!isEditing && !isAdding}
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
                      <label>Corrente Inicial (A) *</label>
                      <input
                        type="number"
                        value={formData.correnteInicial}
                        onChange={(e) => handleInputChange('correnteInicial', Number(e.target.value))}
                        disabled={!isEditing && !isAdding}
                        placeholder="50"
                      />
                      <span className="field-hint">
                        Corrente de partida mínima
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
