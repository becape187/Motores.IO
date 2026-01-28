import { useState } from 'react';
import { AlertTriangle, CheckCircle, Info, XCircle, Bell, BellOff, Trash2 } from 'lucide-react';
import { format } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { mockAlarms } from '../data/mockData';
import { Alarme } from '../types';
import './Alarms.css';

function Alarms() {
  const [alarms, setAlarms] = useState<Alarme[]>(mockAlarms);
  const [filterType, setFilterType] = useState<string>('all');
  const [filterStatus, setFilterStatus] = useState<string>('all');

  const handleAcknowledge = (alarmId: string) => {
    setAlarms(alarms.map(alarm =>
      alarm.id === alarmId ? { ...alarm, reconhecido: true } : alarm
    ));
  };

  const handleDelete = (alarmId: string) => {
    if (window.confirm('Tem certeza que deseja excluir este alarme?')) {
      setAlarms(alarms.filter(alarm => alarm.id !== alarmId));
    }
  };

  const handleAcknowledgeAll = () => {
    setAlarms(alarms.map(alarm => ({ ...alarm, reconhecido: true })));
  };

  const getAlarmIcon = (tipo: string) => {
    switch (tipo) {
      case 'erro':
        return <XCircle size={24} />;
      case 'alerta':
        return <AlertTriangle size={24} />;
      case 'info':
        return <Info size={24} />;
      default:
        return <Bell size={24} />;
    }
  };

  const getAlarmColor = (tipo: string) => {
    switch (tipo) {
      case 'erro':
        return '#e74c3c';
      case 'alerta':
        return '#f39c12';
      case 'info':
        return '#3498db';
      default:
        return '#95a5a6';
    }
  };

  const filteredAlarms = alarms.filter(alarm => {
    const matchesType = filterType === 'all' || alarm.tipo === filterType;
    const matchesStatus = filterStatus === 'all' ||
      (filterStatus === 'pending' && !alarm.reconhecido) ||
      (filterStatus === 'acknowledged' && alarm.reconhecido);
    return matchesType && matchesStatus;
  });

  const stats = {
    total: alarms.length,
    pending: alarms.filter(a => !a.reconhecido).length,
    erro: alarms.filter(a => a.tipo === 'erro' && !a.reconhecido).length,
    alerta: alarms.filter(a => a.tipo === 'alerta' && !a.reconhecido).length,
  };

  return (
    <div className="alarms-page fade-in">
      {/* Stats */}
      <div className="alarm-stats">
        <div className="stat-item stat-total">
          <Bell size={28} />
          <div className="stat-info">
            <span className="stat-label">Total de Alarmes</span>
            <span className="stat-value">{stats.total}</span>
          </div>
        </div>
        <div className="stat-item stat-pending">
          <AlertTriangle size={28} />
          <div className="stat-info">
            <span className="stat-label">Não Reconhecidos</span>
            <span className="stat-value">{stats.pending}</span>
          </div>
        </div>
        <div className="stat-item stat-error">
          <XCircle size={28} />
          <div className="stat-info">
            <span className="stat-label">Erros Ativos</span>
            <span className="stat-value">{stats.erro}</span>
          </div>
        </div>
        <div className="stat-item stat-warning">
          <AlertTriangle size={28} />
          <div className="stat-info">
            <span className="stat-label">Alertas Ativos</span>
            <span className="stat-value">{stats.alerta}</span>
          </div>
        </div>
      </div>

      {/* Filters and Actions */}
      <div className="alarms-controls">
        <div className="filter-group">
          <div className="filter-item">
            <label>Tipo:</label>
            <select value={filterType} onChange={(e) => setFilterType(e.target.value)}>
              <option value="all">Todos</option>
              <option value="erro">Erros</option>
              <option value="alerta">Alertas</option>
              <option value="info">Informações</option>
            </select>
          </div>
          <div className="filter-item">
            <label>Status:</label>
            <select value={filterStatus} onChange={(e) => setFilterStatus(e.target.value)}>
              <option value="all">Todos</option>
              <option value="pending">Não Reconhecidos</option>
              <option value="acknowledged">Reconhecidos</option>
            </select>
          </div>
        </div>
        {stats.pending > 0 && (
          <button className="btn-acknowledge-all" onClick={handleAcknowledgeAll}>
            <CheckCircle size={20} />
            Reconhecer Todos ({stats.pending})
          </button>
        )}
      </div>

      {/* Alarms List */}
      <div className="alarms-list">
        {filteredAlarms.length === 0 ? (
          <div className="no-alarms">
            <BellOff size={64} />
            <h3>Nenhum alarme encontrado</h3>
            <p>Não há alarmes que correspondam aos filtros selecionados</p>
          </div>
        ) : (
          filteredAlarms
            .sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime())
            .map((alarm) => (
              <div
                key={alarm.id}
                className={`alarm-card ${alarm.reconhecido ? 'acknowledged' : 'pending'}`}
                style={{ borderLeftColor: getAlarmColor(alarm.tipo) }}
              >
                <div className="alarm-icon" style={{ background: getAlarmColor(alarm.tipo) }}>
                  {getAlarmIcon(alarm.tipo)}
                </div>
                <div className="alarm-content">
                  <div className="alarm-header">
                    <div className="alarm-info">
                      <span className="alarm-type" style={{ color: getAlarmColor(alarm.tipo) }}>
                        {alarm.tipo.toUpperCase()}
                      </span>
                      <span className="alarm-motor">{alarm.motorNome}</span>
                    </div>
                    <span className="alarm-time">
                      {format(alarm.timestamp, "dd/MM/yyyy 'às' HH:mm", { locale: ptBR })}
                    </span>
                  </div>
                  <p className="alarm-message">{alarm.mensagem}</p>
                  {alarm.reconhecido && (
                    <div className="alarm-acknowledged">
                      <CheckCircle size={16} />
                      <span>Reconhecido</span>
                    </div>
                  )}
                </div>
                <div className="alarm-actions">
                  {!alarm.reconhecido && (
                    <button
                      className="btn-action btn-acknowledge"
                      onClick={() => handleAcknowledge(alarm.id)}
                      title="Reconhecer"
                    >
                      <CheckCircle size={18} />
                    </button>
                  )}
                  <button
                    className="btn-action btn-delete"
                    onClick={() => handleDelete(alarm.id)}
                    title="Excluir"
                  >
                    <Trash2 size={18} />
                  </button>
                </div>
              </div>
            ))
        )}
      </div>
    </div>
  );
}

export default Alarms;
