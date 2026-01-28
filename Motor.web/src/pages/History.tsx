import { useState, useMemo } from 'react';
import { Calendar, Download, Filter } from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts';
import { format, subDays, subWeeks, subMonths, startOfDay, endOfDay } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { mockMotors, mockHistory } from '../data/mockData';
import { Motor, HistoricoMotor } from '../types';
import './History.css';

const CHART_COLORS = [
  '#496263',
  '#3498db',
  '#f39c12',
  '#e74c3c',
  '#9b59b6',
  '#1abc9c',
];

type TimeFilter = '24h' | '7d' | '30d' | 'custom';

function History() {
  const [selectedMotors, setSelectedMotors] = useState<string[]>([mockMotors[0].id]);
  const [motorColors, setMotorColors] = useState<Record<string, string>>({
    [mockMotors[0].id]: CHART_COLORS[0],
  });
  const [timeFilter, setTimeFilter] = useState<TimeFilter>('24h');
  const [customStartDate, setCustomStartDate] = useState('');
  const [customEndDate, setCustomEndDate] = useState(format(new Date(), "yyyy-MM-dd'T'HH:mm"));

  const handleMotorToggle = (motorId: string) => {
    if (selectedMotors.includes(motorId)) {
      setSelectedMotors(selectedMotors.filter(id => id !== motorId));
      const newColors = { ...motorColors };
      delete newColors[motorId];
      setMotorColors(newColors);
    } else {
      const colorIndex = selectedMotors.length % CHART_COLORS.length;
      setSelectedMotors([...selectedMotors, motorId]);
      setMotorColors({
        ...motorColors,
        [motorId]: CHART_COLORS[colorIndex],
      });
    }
  };

  const handleColorChange = (motorId: string, color: string) => {
    setMotorColors({
      ...motorColors,
      [motorId]: color,
    });
  };

  const getDateRange = (): { start: Date; end: Date } => {
    const now = new Date();
    switch (timeFilter) {
      case '24h':
        return { start: subDays(now, 1), end: now };
      case '7d':
        return { start: subWeeks(now, 1), end: now };
      case '30d':
        return { start: subMonths(now, 1), end: now };
      case 'custom':
        return {
          start: customStartDate ? new Date(customStartDate) : subDays(now, 1),
          end: customEndDate ? new Date(customEndDate) : now,
        };
      default:
        return { start: subDays(now, 1), end: now };
    }
  };

  const filteredHistory = useMemo(() => {
    const { start, end } = getDateRange();
    return mockHistory.filter(h => {
      const inTimeRange = h.timestamp >= start && h.timestamp <= end;
      const inSelectedMotors = selectedMotors.includes(h.motorId);
      return inTimeRange && inSelectedMotors;
    });
  }, [selectedMotors, timeFilter, customStartDate, customEndDate]);

  const chartData = useMemo(() => {
    const groupedByTime = filteredHistory.reduce((acc, item) => {
      const timeKey = format(item.timestamp, 'yyyy-MM-dd HH:mm');
      if (!acc[timeKey]) {
        acc[timeKey] = { timestamp: timeKey, date: item.timestamp };
      }
      const motor = mockMotors.find(m => m.id === item.motorId);
      if (motor) {
        acc[timeKey][`motor_${item.motorId}`] = item.corrente;
      }
      return acc;
    }, {} as Record<string, any>);

    return Object.values(groupedByTime).sort((a: any, b: any) => a.date - b.date);
  }, [filteredHistory]);

  const exportData = () => {
    const csvContent = [
      ['Timestamp', 'Motor', 'Corrente (A)', 'Tensão (V)', 'Temperatura (°C)', 'Status'].join(','),
      ...filteredHistory.map(h => {
        const motor = mockMotors.find(m => m.id === h.motorId);
        return [
          format(h.timestamp, 'dd/MM/yyyy HH:mm:ss'),
          motor?.nome || h.motorId,
          h.corrente.toFixed(2),
          h.tensao.toFixed(2),
          h.temperatura.toFixed(2),
          h.status,
        ].join(',');
      }),
    ].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.download = `historico_motores_${format(new Date(), 'yyyyMMdd_HHmmss')}.csv`;
    link.click();
  };

  return (
    <div className="history-page fade-in">
      {/* Filters */}
      <div className="history-header">
        <div className="motor-selector">
          <h3>Selecione os Motores</h3>
          <div className="motor-chips">
            {mockMotors.map((motor) => {
              const isSelected = selectedMotors.includes(motor.id);
              return (
                <div
                  key={motor.id}
                  className={`motor-chip ${isSelected ? 'selected' : ''}`}
                  onClick={() => handleMotorToggle(motor.id)}
                >
                  <input
                    type="checkbox"
                    checked={isSelected}
                    onChange={() => {}}
                    onClick={(e) => e.stopPropagation()}
                  />
                  <span className="chip-label">{motor.nome}</span>
                  {isSelected && (
                    <input
                      type="color"
                      value={motorColors[motor.id]}
                      onChange={(e) => {
                        e.stopPropagation();
                        handleColorChange(motor.id, e.target.value);
                      }}
                      onClick={(e) => e.stopPropagation()}
                      className="color-picker"
                      title="Escolher cor"
                    />
                  )}
                </div>
              );
            })}
          </div>
        </div>

        <div className="time-filters">
          <h3>Período</h3>
          <div className="filter-buttons">
            <button
              className={`filter-btn ${timeFilter === '24h' ? 'active' : ''}`}
              onClick={() => setTimeFilter('24h')}
            >
              Últimas 24h
            </button>
            <button
              className={`filter-btn ${timeFilter === '7d' ? 'active' : ''}`}
              onClick={() => setTimeFilter('7d')}
            >
              Última Semana
            </button>
            <button
              className={`filter-btn ${timeFilter === '30d' ? 'active' : ''}`}
              onClick={() => setTimeFilter('30d')}
            >
              Último Mês
            </button>
            <button
              className={`filter-btn ${timeFilter === 'custom' ? 'active' : ''}`}
              onClick={() => setTimeFilter('custom')}
            >
              <Calendar size={16} />
              Personalizado
            </button>
          </div>

          {timeFilter === 'custom' && (
            <div className="custom-date-range">
              <div className="date-input">
                <label>Data/Hora Inicial</label>
                <input
                  type="datetime-local"
                  value={customStartDate}
                  onChange={(e) => setCustomStartDate(e.target.value)}
                />
              </div>
              <div className="date-input">
                <label>Data/Hora Final</label>
                <input
                  type="datetime-local"
                  value={customEndDate}
                  onChange={(e) => setCustomEndDate(e.target.value)}
                />
              </div>
            </div>
          )}
        </div>

        <button className="btn-export" onClick={exportData}>
          <Download size={20} />
          Exportar CSV
        </button>
      </div>

      {/* Chart */}
      <div className="chart-section">
        <div className="chart-header">
          <h3>Gráfico de Corrente</h3>
          <span className="data-points">{chartData.length} pontos de dados</span>
        </div>
        <div className="chart-container">
          {selectedMotors.length > 0 ? (
            <ResponsiveContainer width="100%" height="100%">
              <LineChart data={chartData}>
                <CartesianGrid strokeDasharray="3 3" stroke="#e0e0e0" />
                <XAxis
                  dataKey="timestamp"
                  tick={{ fontSize: 12 }}
                  tickFormatter={(value) => {
                    const date = new Date(value);
                    return timeFilter === '24h'
                      ? format(date, 'HH:mm')
                      : format(date, 'dd/MM HH:mm');
                  }}
                />
                <YAxis
                  label={{ value: 'Corrente (A)', angle: -90, position: 'insideLeft' }}
                  tick={{ fontSize: 12 }}
                />
                <Tooltip
                  contentStyle={{
                    background: 'white',
                    border: '1px solid #e0e0e0',
                    borderRadius: '8px',
                    boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
                  }}
                  labelFormatter={(value) => {
                    const date = new Date(value);
                    return format(date, "dd/MM/yyyy 'às' HH:mm", { locale: ptBR });
                  }}
                  formatter={(value: any, name: string) => {
                    const motorId = name.replace('motor_', '');
                    const motor = mockMotors.find(m => m.id === motorId);
                    return [`${Number(value).toFixed(1)}A`, motor?.nome || motorId];
                  }}
                />
                <Legend
                  formatter={(value) => {
                    const motorId = value.replace('motor_', '');
                    const motor = mockMotors.find(m => m.id === motorId);
                    return motor?.nome || motorId;
                  }}
                />
                {selectedMotors.map((motorId) => (
                  <Line
                    key={motorId}
                    type="monotone"
                    dataKey={`motor_${motorId}`}
                    stroke={motorColors[motorId]}
                    strokeWidth={2}
                    dot={false}
                    activeDot={{ r: 6 }}
                  />
                ))}
              </LineChart>
            </ResponsiveContainer>
          ) : (
            <div className="no-data">
              <Filter size={64} />
              <h3>Nenhum motor selecionado</h3>
              <p>Selecione pelo menos um motor para visualizar o gráfico</p>
            </div>
          )}
        </div>
      </div>

      {/* History Table */}
      <div className="history-table-section">
        <div className="table-header">
          <h3>Histórico Detalhado</h3>
          <span className="record-count">{filteredHistory.length} registros</span>
        </div>
        <div className="table-wrapper">
          <table className="history-table">
            <thead>
              <tr>
                <th>Data/Hora</th>
                <th>Motor</th>
                <th>Corrente</th>
                <th>Tensão</th>
                <th>Temperatura</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {filteredHistory
                .sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime())
                .slice(0, 100)
                .map((record, index) => {
                  const motor = mockMotors.find(m => m.id === record.motorId);
                  return (
                    <tr key={index}>
                      <td className="timestamp">
                        {format(record.timestamp, "dd/MM/yyyy 'às' HH:mm:ss", { locale: ptBR })}
                      </td>
                      <td>
                        <span
                          className="motor-indicator"
                          style={{ background: motorColors[record.motorId] }}
                        ></span>
                        {motor?.nome || record.motorId}
                      </td>
                      <td className="value">{record.corrente.toFixed(2)} A</td>
                      <td className="value">{record.tensao.toFixed(1)} V</td>
                      <td className="value">{record.temperatura.toFixed(1)} °C</td>
                      <td>
                        <span className={`status-indicator status-${record.status}`}>
                          {record.status}
                        </span>
                      </td>
                    </tr>
                  );
                })}
            </tbody>
          </table>
          {filteredHistory.length > 100 && (
            <div className="table-footer">
              Mostrando os 100 registros mais recentes de {filteredHistory.length}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default History;
