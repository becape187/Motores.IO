import { useState, useMemo, useEffect, useCallback, useRef } from 'react';
import { Calendar, Download, Filter, Loader } from 'lucide-react';
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer, Brush } from 'recharts';
import { format, subDays, subWeeks, subMonths } from 'date-fns';
import { ptBR } from 'date-fns/locale';
import { useAuth } from '../contexts/AuthContext';
import { useMotorsCache } from '../contexts/MotorsCacheContext';
import { api } from '../services/api';
import { Motor } from '../types';
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

interface HistoricoMotor {
  id: string;
  motorId: string;
  timestamp: string;
  corrente: number;
  tensao: number;
  temperatura: number;
  status: string;
}

function History() {
  const { plantaSelecionada } = useAuth();
  const { getMotors } = useMotorsCache();
  const [motors, setMotors] = useState<Motor[]>([]);
  const [historico, setHistorico] = useState<HistoricoMotor[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [selectedMotors, setSelectedMotors] = useState<string[]>([]);
  const [motorColors, setMotorColors] = useState<Record<string, string>>({});
  const [timeFilter, setTimeFilter] = useState<TimeFilter>('24h');
  const [customStartDate, setCustomStartDate] = useState('');
  const [customEndDate, setCustomEndDate] = useState(format(new Date(), "yyyy-MM-dd'T'HH:mm"));
  const [autoUpdate, setAutoUpdate] = useState(false);
  const [zoomStartIndex, setZoomStartIndex] = useState<number | null>(null);
  const [zoomEndIndex, setZoomEndIndex] = useState<number | null>(null);
  const brushDebounceRef = useRef<ReturnType<typeof setTimeout> | null>(null);

  // Carregar motores ao montar componente ou trocar planta
  useEffect(() => {
    const loadMotors = async () => {
      if (!plantaSelecionada) {
        setMotors([]);
        setSelectedMotors([]);
        return;
      }

      try {
        const motorsData = await getMotors(plantaSelecionada.id, { useCache: true });
        setMotors(motorsData);
        
        // Não selecionar nenhum motor por padrão - usuário deve selecionar manualmente
      } catch (err: any) {
        setError(err.message || 'Erro ao carregar motores');
        console.error('Erro ao carregar motores:', err);
      }
    };

    loadMotors();
  }, [plantaSelecionada, getMotors]);

  const getDateRange = useCallback((): { start: Date; end: Date } => {
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
  }, [timeFilter, customStartDate, customEndDate]);

  // Função para carregar histórico (reutilizável)
  const loadHistorico = useCallback(async (silent = false) => {
    if (!plantaSelecionada || selectedMotors.length === 0) {
      setHistorico([]);
      return;
    }

    if (!silent) {
      setLoading(true);
    }
    setError(null);

    try {
      const { start, end } = getDateRange();
      
      // Buscar histórico para cada motor selecionado
      const promises = selectedMotors.map(motorId =>
        api.getHistorico(motorId, start, end)
      );
      
      const results = await Promise.all(promises);
      
      // Combinar todos os resultados
      const allHistorico: HistoricoMotor[] = results.flat();
      
      // Converter timestamp string para Date e ordenar
      const historicoComData = allHistorico.map(h => ({
        ...h,
        timestampDate: new Date(h.timestamp),
      })).sort((a, b) => b.timestampDate.getTime() - a.timestampDate.getTime());
      
      setHistorico(historicoComData.map(({ timestampDate, ...rest }) => rest));
    } catch (err: any) {
      setError(err.message || 'Erro ao carregar histórico');
      console.error('Erro ao carregar histórico:', err);
    } finally {
      if (!silent) {
        setLoading(false);
      }
    }
  }, [plantaSelecionada, selectedMotors, getDateRange]);

  // Carregar histórico quando mudar filtros ou motores selecionados
  useEffect(() => {
    loadHistorico();
  }, [loadHistorico]);

  // Auto-update: atualizar histórico a cada 1 minuto quando habilitado
  useEffect(() => {
    if (!autoUpdate || !plantaSelecionada || selectedMotors.length === 0) {
      return;
    }

    const interval = setInterval(() => {
      loadHistorico(true); // Atualização silenciosa (sem mostrar loading)
    }, 60000); // 1 minuto

    return () => clearInterval(interval);
  }, [autoUpdate, plantaSelecionada, selectedMotors, loadHistorico]);

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


  const filteredHistory = useMemo(() => {
    return historico.filter(h => {
      const timestamp = new Date(h.timestamp);
      const { start, end } = getDateRange();
      return timestamp >= start && timestamp <= end;
    });
  }, [historico, timeFilter, customStartDate, customEndDate]);

  const chartData = useMemo(() => {
    const groupedByTime = filteredHistory.reduce((acc, item) => {
      const timestamp = new Date(item.timestamp);
      const timeKey = format(timestamp, 'yyyy-MM-dd HH:mm');
      if (!acc[timeKey]) {
        acc[timeKey] = { timestamp: timeKey, date: timestamp };
      }
      const motor = motors.find(m => m.id === item.motorId);
      if (motor) {
        // Converter corrente de centésimos para amperes (ex: 2153 -> 21.53)
        const correnteAmperes = Number(item.corrente) / 100;
        acc[timeKey][`motor_${item.motorId}`] = correnteAmperes;
      }
      return acc;
    }, {} as Record<string, any>);

    return Object.values(groupedByTime).sort((a: any, b: any) => a.date.getTime() - b.date.getTime());
  }, [filteredHistory, motors]);

  const isZoomed = zoomStartIndex !== null && zoomEndIndex !== null && chartData.length > 1 && (zoomStartIndex > 0 || zoomEndIndex < chartData.length - 1);
  
  // Decimação simples e rápida (step uniforme) para melhor performance
  const decimateData = useCallback((data: any[], maxPoints: number): any[] => {
    if (data.length <= maxPoints) return data;
    const step = data.length / maxPoints;
    const decimated: any[] = [data[0]];
    for (let i = 1; i < maxPoints; i++) {
      const idx = Math.min(Math.floor(i * step), data.length - 1);
      decimated.push(data[idx]);
    }
    if (data.length > 1) decimated.push(data[data.length - 1]);
    return decimated;
  }, []);

  // Limites de pontos: menos = mais fluido
  const MAX_POINTS_INITIAL = 250;
  const MAX_POINTS_ZOOMED = 500;
  const MAX_POINTS_BRUSH = 100;

  const chartDataSlice = useMemo(() => {
    if (chartData.length === 0) return chartData;
    let dataToShow: any[];
    if (isZoomed) {
      const start = Math.max(0, Math.min(zoomStartIndex!, zoomEndIndex!));
      const end = Math.min(chartData.length - 1, Math.max(zoomStartIndex!, zoomEndIndex!));
      const zoomedData = chartData.slice(start, end + 1);
      dataToShow = zoomedData.length > MAX_POINTS_ZOOMED
        ? decimateData(zoomedData, MAX_POINTS_ZOOMED)
        : zoomedData;
    } else {
      dataToShow = chartData.length > MAX_POINTS_INITIAL
        ? decimateData(chartData, MAX_POINTS_INITIAL)
        : chartData;
    }
    return dataToShow;
  }, [chartData, isZoomed, zoomStartIndex, zoomEndIndex, decimateData]);

  // Dados do Brush: sempre decimados para o strip não pesar (indices em espaço "brush")
  const brushData = useMemo(() => {
    if (chartData.length <= MAX_POINTS_BRUSH) return chartData;
    return decimateData(chartData, MAX_POINTS_BRUSH);
  }, [chartData, decimateData]);

  const brushLength = brushData.length;
  const chartLength = chartData.length;

  // Mapear índices do chart completo para índices do brush (espaço decimado)
  const brushStartIndex = useMemo(() => {
    if (zoomStartIndex == null || chartLength <= 1 || brushLength <= 1) return 0;
    return Math.min(
      Math.floor((zoomStartIndex / (chartLength - 1)) * (brushLength - 1)),
      brushLength - 1
    );
  }, [zoomStartIndex, chartLength, brushLength]);
  const brushEndIndex = useMemo(() => {
    if (zoomEndIndex == null || chartLength <= 1 || brushLength <= 1) return Math.max(0, brushLength - 1);
    return Math.min(
      Math.ceil((zoomEndIndex / (chartLength - 1)) * (brushLength - 1)),
      brushLength - 1
    );
  }, [zoomEndIndex, chartLength, brushLength]);

  const applyBrushRange = useCallback((start: number, end: number) => {
    if (brushLength <= 1 || chartLength <= 1) return;
    const b = brushLength - 1;
    const c = chartLength - 1;
    const newStart = Math.floor((start / b) * c);
    const newEnd = Math.ceil((end / b) * c);
    setZoomStartIndex(Math.max(0, newStart));
    setZoomEndIndex(Math.min(chartLength - 1, newEnd));
  }, [brushLength, chartLength]);

  const handleBrushChange = useCallback((range: { startIndex?: number; endIndex?: number } | null) => {
    if (range == null || range.startIndex == null || range.endIndex == null) {
      setZoomStartIndex(null);
      setZoomEndIndex(null);
      return;
    }
    if (brushDebounceRef.current) clearTimeout(brushDebounceRef.current);
    const start = range.startIndex;
    const end = range.endIndex;
    brushDebounceRef.current = setTimeout(() => {
      applyBrushRange(start, end);
      brushDebounceRef.current = null;
    }, 80);
  }, [applyBrushRange]);

  useEffect(() => () => {
    if (brushDebounceRef.current) clearTimeout(brushDebounceRef.current);
  }, []);

  const xAxisTickFormatter = useCallback((value: string) => {
    const date = new Date(value);
    return timeFilter === '24h' ? format(date, 'HH:mm') : format(date, 'dd/MM HH:mm');
  }, [timeFilter]);
  const tooltipLabelFormatter = useCallback((value: string) => {
    return format(new Date(value), "dd/MM/yyyy 'às' HH:mm", { locale: ptBR });
  }, []);
  const tooltipFormatter = useCallback((value: any, name?: string) => {
    const motorId = (name || '').replace('motor_', '');
    const motor = motors.find(m => m.id === motorId);
    return [`${Number(value).toFixed(1)}A`, motor?.nome || motorId];
  }, [motors]);
  const legendFormatter = useCallback((value: string) => {
    const motorId = value.replace('motor_', '');
    const motor = motors.find(m => m.id === motorId);
    return motor?.nome || motorId;
  }, [motors]);


  const exportData = () => {
    const csvContent = [
      ['Timestamp', 'Motor', 'Corrente (A)', 'Tensão (V)', 'Temperatura (°C)', 'Status'].join(','),
      ...filteredHistory.map(h => {
        const motor = motors.find(m => m.id === h.motorId);
        const timestamp = new Date(h.timestamp);
        // Converter corrente de centésimos para amperes
        const correnteAmperes = Number(h.corrente) / 100;
        return [
          format(timestamp, 'dd/MM/yyyy HH:mm:ss'),
          motor?.nome || h.motorId,
          correnteAmperes.toFixed(2),
          Number(h.tensao).toFixed(1),
          Number(h.temperatura).toFixed(1),
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

  if (!plantaSelecionada) {
    return (
      <div className="history-page fade-in">
        <div style={{ textAlign: 'center', padding: '2rem' }}>
          <p>Selecione uma planta para visualizar o histórico</p>
        </div>
      </div>
    );
  }

  return (
    <div className="history-page fade-in">
      {error && (
        <div className="error-message" style={{ margin: '1rem', padding: '1rem', background: '#fee', color: '#c33', borderRadius: '8px' }}>
          {error}
        </div>
      )}

      {/* Filters */}
      <div className="history-header">
        <div className="motor-selector">
          <h3>Selecione os Motores</h3>
          {loading && motors.length === 0 ? (
            <div style={{ display: 'flex', alignItems: 'center', gap: '0.5rem', padding: '1rem' }}>
              <Loader className="spin" size={20} />
              <span>Carregando motores...</span>
            </div>
          ) : (
            <div className="motor-chips">
              {motors.length === 0 ? (
                <p style={{ padding: '1rem', color: '#666' }}>Nenhum motor cadastrado</p>
              ) : (
                motors.map((motor) => {
                  const isSelected = selectedMotors.includes(motor.id);
                  return (
                    <div
                      key={motor.id}
                      className={`motor-chip ${isSelected ? 'selected' : ''}`}
                      onClick={() => handleMotorToggle(motor.id)}
                    >
                      <span className="chip-label">{motor.nome}</span>
                      {isSelected && (
                        <input
                          type="color"
                          value={motorColors[motor.id] || CHART_COLORS[0]}
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
                })
              )}
            </div>
          )}
        </div>

        <div className="time-filters">
          <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
            <h3 style={{ margin: 0 }}>Período</h3>
            <label style={{ display: 'flex', alignItems: 'center', gap: '8px', cursor: 'pointer', userSelect: 'none' }}>
              <input
                type="checkbox"
                checked={autoUpdate}
                onChange={(e) => setAutoUpdate(e.target.checked)}
                style={{ width: '18px', height: '18px', cursor: 'pointer' }}
              />
              <span style={{ fontSize: '14px', fontWeight: 600, color: 'var(--text-dark)' }}>
                Auto-atualizar (1 min)
              </span>
            </label>
          </div>
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

        <button className="btn-export" onClick={exportData} disabled={filteredHistory.length === 0}>
          <Download size={20} />
          Exportar CSV
        </button>
      </div>

      {/* Chart */}
      <div className="chart-section">
        <div className="chart-header">
          <h3>Gráfico de Corrente</h3>
          {loading ? (
            <span className="data-points">
              <Loader className="spin" size={16} style={{ display: 'inline-block', marginRight: '0.5rem' }} />
              Carregando...
            </span>
          ) : (
            <span className="data-points">{chartData.length} pontos de dados</span>
          )}
        </div>
        <div className="chart-container">
          {loading ? (
            <div className="no-data">
              <Loader className="spin" size={64} />
              <h3>Carregando dados...</h3>
            </div>
          ) : selectedMotors.length === 0 ? (
            <div className="no-data">
              <Filter size={64} />
              <h3>Nenhum motor selecionado</h3>
              <p>Selecione pelo menos um motor para visualizar o gráfico</p>
            </div>
          ) : chartData.length === 0 ? (
            <div className="no-data">
              <Filter size={64} />
              <h3>Nenhum dado encontrado</h3>
              <p>Não há registros de histórico para o período selecionado</p>
            </div>
          ) : (
            <>
              <div className="chart-main-wrap">
                <ResponsiveContainer width="100%" height="100%">
                  <LineChart data={chartDataSlice} margin={{ top: 8, right: 8, left: 8, bottom: 8 }} isAnimationActive={false}>
                    <CartesianGrid strokeDasharray="3 3" stroke="#e0e0e0" />
                    <XAxis
                      dataKey="timestamp"
                      tick={{ fontSize: 12 }}
                      tickFormatter={xAxisTickFormatter}
                      interval="preserveStartEnd"
                    />
                    <YAxis
                      label={{ value: 'Corrente (A)', angle: -90, position: 'insideLeft' }}
                      tick={{ fontSize: 12 }}
                      width={42}
                    />
                    <Tooltip
                      contentStyle={{
                        background: 'white',
                        border: '1px solid #e0e0e0',
                        borderRadius: '8px',
                        boxShadow: '0 4px 12px rgba(0,0,0,0.1)',
                      }}
                      labelFormatter={tooltipLabelFormatter}
                      formatter={tooltipFormatter}
                      isAnimationActive={false}
                    />
                    <Legend formatter={legendFormatter} />
                    {selectedMotors.map((motorId) => (
                      <Line
                        key={motorId}
                        type="monotone"
                        dataKey={`motor_${motorId}`}
                        stroke={motorColors[motorId] || CHART_COLORS[0]}
                        strokeWidth={2}
                        dot={false}
                        activeDot={{ r: 4 }}
                        isAnimationActive={false}
                        connectNulls
                      />
                    ))}
                  </LineChart>
                </ResponsiveContainer>
              </div>
              {chartData.length > 1 && (
                <div className="chart-brush-wrap">
                  <ResponsiveContainer width="100%" height={40}>
                    <LineChart data={brushData} margin={{ top: 0, right: 8, left: 8, bottom: 0 }}>
                      <XAxis dataKey="timestamp" hide />
                      <YAxis hide domain={['auto', 'auto']} />
                      {selectedMotors.map((motorId) => (
                        <Line
                          key={motorId}
                          type="monotone"
                          dataKey={`motor_${motorId}`}
                          stroke={motorColors[motorId] || CHART_COLORS[0]}
                          strokeWidth={1}
                          dot={false}
                          isAnimationActive={false}
                        />
                      ))}
                      <Brush
                        dataKey="timestamp"
                        height={32}
                        stroke="var(--primary-color)"
                        fill="var(--background-color)"
                        startIndex={brushStartIndex}
                        endIndex={brushEndIndex}
                        onChange={(range) => {
                          if (range?.startIndex != null && range?.endIndex != null) {
                            handleBrushChange({ startIndex: range.startIndex, endIndex: range.endIndex });
                          }
                        }}
                        tickFormatter={xAxisTickFormatter}
                      />
                    </LineChart>
                  </ResponsiveContainer>
                </div>
              )}
            </>
          )}
        </div>
      </div>

      {/* History Table */}
      <div className="history-table-section">
        <div className="table-header">
          <h3>Histórico Detalhado</h3>
          {loading ? (
            <span className="record-count">
              <Loader className="spin" size={14} style={{ display: 'inline-block', marginRight: '0.5rem' }} />
              Carregando...
            </span>
          ) : (
            <span className="record-count">{filteredHistory.length} registros</span>
          )}
        </div>
        <div className="table-wrapper">
          {loading ? (
            <div style={{ padding: '2rem', textAlign: 'center' }}>
              <Loader className="spin" size={32} />
              <p style={{ marginTop: '1rem' }}>Carregando histórico...</p>
            </div>
          ) : filteredHistory.length === 0 ? (
            <div style={{ padding: '2rem', textAlign: 'center', color: '#666' }}>
              <p>Nenhum registro encontrado para o período selecionado</p>
            </div>
          ) : (
            <>
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
                    .slice(0, 100)
                    .map((record, index) => {
                      const motor = motors.find(m => m.id === record.motorId);
                      const timestamp = new Date(record.timestamp);
                      // Converter corrente de centésimos para amperes
                      const correnteAmperes = Number(record.corrente) / 100;
                      return (
                        <tr key={record.id || index}>
                          <td className="timestamp">
                            {format(timestamp, "dd/MM/yyyy 'às' HH:mm:ss", { locale: ptBR })}
                          </td>
                          <td>
                            <span
                              className="motor-indicator"
                              style={{ background: motorColors[record.motorId] || CHART_COLORS[0] }}
                            ></span>
                            {motor?.nome || record.motorId}
                          </td>
                          <td className="value">{correnteAmperes.toFixed(2)} A</td>
                          <td className="value">{Number(record.tensao).toFixed(1)} V</td>
                          <td className="value">{Number(record.temperatura).toFixed(1)} °C</td>
                          <td>
                            <span className={`status-indicator status-${record.status.toLowerCase()}`}>
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
            </>
          )}
        </div>
      </div>
    </div>
  );
}

export default History;
