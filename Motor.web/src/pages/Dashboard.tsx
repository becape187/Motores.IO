import { useState, useEffect, useRef, useCallback, useMemo } from 'react';
import { Activity, TrendingUp, AlertCircle, Power, Edit2, Wifi, WifiOff, MousePointer2, Trash2, AlignCenterVertical, AlignCenterHorizontal, Plus } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { useMotorsCache } from '../contexts/MotorsCacheContext';
import { api } from '../services/api';
import { Motor } from '../types';
import { useWebSocketCorrentes } from '../hooks/useWebSocketCorrentes';
import './Dashboard.css';

function Dashboard() {
  const { plantaSelecionada } = useAuth();
  const { getMotors, invalidateCache } = useMotorsCache();
  const [motors, setMotors] = useState<Motor[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isEditMode, setIsEditMode] = useState(false);
  const [draggedMotor, setDraggedMotor] = useState<string | null>(null);
  const [savingPosition, setSavingPosition] = useState<string | null>(null);
  const svgRef = useRef<SVGSVGElement>(null);

  // Modo "Adicionar motores": lista abaixo, arrastar para o mapa
  const [isAddMotorMode, setIsAddMotorMode] = useState(false);
  // Modo "Selecionar motores": seleção por clique, arraste (retângulo), mover múltiplos
  const [isSelectionMode, setIsSelectionMode] = useState(false);
  const [selectedMotorIds, setSelectedMotorIds] = useState<string[]>([]);
  const [boxSelectStart, setBoxSelectStart] = useState<{ x: number; y: number } | null>(null);
  const [boxSelectCurrent, setBoxSelectCurrent] = useState<{ x: number; y: number } | null>(null);
  const pendingMotorClickRef = useRef<string | null>(null);
  const dragStartCoordsRef = useRef<{ x: number; y: number } | null>(null);
  const initialMotorPositionsRef = useRef<Record<string, { x: number; y: number }>>({});
  const lastTapMotorRef = useRef<{ id: string; time: number } | null>(null);
  const ignoreNextClickRef = useRef(false);
  const [showConfirmDeleteModal, setShowConfirmDeleteModal] = useState(false);
  // Mobile: toque na lista depois no mapa para adicionar (arrastar não funciona em touch)
  const [motorToAddFromList, setMotorToAddFromList] = useState<string | null>(null);

  // Zoom apenas na área da planta baixa (roda do mouse + pinch no mobile)
  const [plantZoom, setPlantZoom] = useState(1);
  const plantZoomRef = useRef<HTMLDivElement>(null);
  const lastPinchDistanceRef = useRef<number | null>(null);
  const lastPinchZoomRef = useRef<number>(1);
  const MIN_ZOOM = 0.5;
  const MAX_ZOOM = 3;
  const clampZoom = (z: number) => Math.min(MAX_ZOOM, Math.max(MIN_ZOOM, z));

  // Zoom só na tela de edição: ao sair, volta para 1
  useEffect(() => {
    if (!isEditMode) setPlantZoom(1);
  }, [isEditMode]);

  // Ao entrar em edição: nenhum motor selecionado, nenhum modo ativo
  useEffect(() => {
    if (isEditMode) {
      setSelectedMotorIds([]);
      setIsSelectionMode(false);
      setIsAddMotorMode(false);
    }
  }, [isEditMode]);

  // Roda do mouse: zoom só em modo edição e só dentro da planta
  useEffect(() => {
    if (!plantaSelecionada || !isEditMode) return;
    let cleanup: (() => void) | null = null;
    const id = requestAnimationFrame(() => {
      const el = plantZoomRef.current;
      if (!el) return;
      const onWheel = (e: WheelEvent) => {
        e.preventDefault();
        e.stopPropagation();
        setPlantZoom(z => clampZoom(z - e.deltaY * 0.002));
      };
      el.addEventListener('wheel', onWheel, { passive: false, capture: true });
      cleanup = () => el.removeEventListener('wheel', onWheel, { capture: true });
    });
    return () => {
      cancelAnimationFrame(id);
      cleanup?.();
    };
  }, [plantaSelecionada, isEditMode]);

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

  // WebSocket para atualização em tempo real das correntes
  const handleCorrentesUpdate = useCallback((correntesMap: Map<string, import('../hooks/useWebSocketCorrentes').MotorCorrenteData>) => {
    setMotors(prevMotors => 
      prevMotors.map(motor => {
        const dadosCorrente = correntesMap.get(motor.id);
        if (dadosCorrente !== undefined) {
          return { 
            ...motor, 
            correnteAtual: dadosCorrente.correnteAtual,
            correnteMedia: dadosCorrente.correnteMedia,
            correnteMaxima: dadosCorrente.correnteMaxima,
            correnteMinima: dadosCorrente.correnteMinima,
            status: dadosCorrente.status as Motor['status'] || motor.status,
          };
        }
        return motor;
      })
    );
  }, []);

  const { isConnected: wsConnected } = useWebSocketCorrentes(
    plantaSelecionada?.id,
    handleCorrentesUpdate
  );

  // Atualização em background - atualiza dados dinâmicos periodicamente (apenas status e horimetro)
  useEffect(() => {
    if (!plantaSelecionada || isEditMode) return;

    const updateMotorsData = async () => {
      try {
        // Atualizar cache em background
        const updatedMotors = await getMotors(plantaSelecionada.id, { useCache: false });
        
        // Atualizar apenas dados dinâmicos sem recriar o array completo
        // NOTA: correnteAtual agora vem via WebSocket, não via polling
        setMotors(prevMotors => {
          const motorsMap = new Map(prevMotors.map(m => [m.id, m]));
          
          return updatedMotors.map(m => {
            const existing = motorsMap.get(m.id);
            if (existing) {
              // Atualizar apenas status e horimetro, mantendo correnteAtual do WebSocket
              return {
                ...existing,
                status: m.status,
                horimetro: m.horimetro,
                // Preservar posição existente se não vier do servidor
                posicaoX: m.posicaoX ?? existing.posicaoX,
                posicaoY: m.posicaoY ?? existing.posicaoY,
                // Manter correnteAtual existente (vem do WebSocket)
                correnteAtual: existing.correnteAtual,
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

    const interval = setInterval(updateMotorsData, 30000); // Atualizar a cada 30 segundos (apenas status/horimetro)
    return () => clearInterval(interval);
  }, [plantaSelecionada, isEditMode, getMotors]);

  // Hooks precisam rodar em todo render (antes de qualquer return condicional) para não quebrar ao selecionar cliente/planta
  const selectedMotorIdsUnique = useMemo(() => [...new Set(selectedMotorIds)], [selectedMotorIds]);
  const placeMotorOnMap = useCallback(async (motorId: string, coords: { x: number; y: number }) => {
    if (!plantaSelecionada) return;
    const motor = motors.find(m => m.id === motorId);
    if (!motor) return;
    try {
      setSavingPosition(motorId);
      const motorAtual = await api.getMotor(motorId);
      if (!motorAtual.plantaId || motorAtual.plantaId !== plantaSelecionada.id) {
        await api.updateMotorConfiguracao(motorId, {
          nome: motor.nome ?? '',
          potencia: motor.potencia ?? 0,
          tensao: motor.tensao ?? 380,
          correnteNominal: motor.correnteNominal ?? 0,
          percentualCorrenteMaxima: motor.percentualCorrenteMaxima ?? 110,
          histerese: motor.histerese ?? 5,
          habilitado: motor.habilitado ?? true,
          plantaId: plantaSelecionada.id,
        });
      }
      await api.updateMotorPosicao(motorId, { posicaoX: coords.x, posicaoY: coords.y });
      invalidateCache(plantaSelecionada.id);
      const updatedMotors = await getMotors(plantaSelecionada.id, { useCache: false });
      setMotors(updatedMotors);
    } catch (err: any) {
      console.error('Erro ao adicionar motor à planta:', err);
      alert('Erro ao adicionar motor à planta: ' + (err.message || 'Erro desconhecido'));
    } finally {
      setSavingPosition(null);
    }
  }, [plantaSelecionada, motors, invalidateCache, getMotors]);

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

  // Sem planta selecionada: não renderiza nada (sem mensagem)
  if (!plantaSelecionada) {
    return null;
  }

  // Função para obter coordenadas do SVG (mouse ou touch)
  const getSVGCoordinatesFromClient = (clientX: number, clientY: number): { x: number; y: number } | null => {
    if (!svgRef.current) return null;
    const svg = svgRef.current;
    const point = svg.createSVGPoint();
    point.x = clientX;
    point.y = clientY;
    const ctm = svg.getScreenCTM?.();
    if (!ctm) return null;
    const svgPoint = point.matrixTransform(ctm.inverse());
    return { x: svgPoint.x, y: svgPoint.y };
  };
  const getSVGCoordinates = (e: React.MouseEvent<SVGSVGElement> | MouseEvent): { x: number; y: number } | null =>
    getSVGCoordinatesFromClient(e.clientX, e.clientY);

  // Helpers para modo seleção (lista única já definida acima antes dos returns)
  const motorsComPosicao = motors.filter(m => m.habilitado && m.posicaoX !== undefined && m.posicaoY !== undefined);
  const isMotorInBox = (mx: number, my: number, boxA: { x: number; y: number }, boxB: { x: number; y: number }) => {
    const minX = Math.min(boxA.x, boxB.x);
    const maxX = Math.max(boxA.x, boxB.x);
    const minY = Math.min(boxA.y, boxB.y);
    const maxY = Math.max(boxA.y, boxB.y);
    return mx >= minX && mx <= maxX && my >= minY && my <= maxY;
  };

  const handleMotorMouseDown = (e: React.MouseEvent, motorId: string) => {
    if (!isEditMode) return;
    e.preventDefault();
    e.stopPropagation();
    // Só seleção e arraste quando modo Selecionar estiver ativo
    if (!isSelectionMode) return;
    // Marcar seleção na hora para o círculo aparecer logo (evita perder seleção com movimento mínimo)
    setSelectedMotorIds(prev => [...new Set(prev.includes(motorId) ? prev : [...prev, motorId])]);
    pendingMotorClickRef.current = motorId;
  };

  const handleSVGMouseDown = (e: React.MouseEvent<SVGSVGElement>) => {
    if (!isEditMode || !isSelectionMode) return;
    const target = e.target as SVGElement;
    if (target.closest('g[data-motor-id]')) return; // clique em cima de motor
    const coords = getSVGCoordinates(e);
    if (coords) {
      setBoxSelectStart(coords);
      setBoxSelectCurrent(null);
    }
  };

  const handleSVGMouseMove = (e: React.MouseEvent<SVGSVGElement>) => {
    const coords = getSVGCoordinates(e);
    if (!coords) return;

    if (isEditMode && isSelectionMode && boxSelectStart) {
      setBoxSelectCurrent(coords);
      return;
    }

    if (isEditMode && pendingMotorClickRef.current) {
      setDraggedMotor(pendingMotorClickRef.current);
      const motorId = pendingMotorClickRef.current;
      const toMove = selectedMotorIds.includes(motorId) ? selectedMotorIds : [motorId];
      const positions: Record<string, { x: number; y: number }> = {};
      motorsComPosicao.forEach(m => {
        if (toMove.includes(m.id) && m.posicaoX != null && m.posicaoY != null) {
          positions[m.id] = { x: m.posicaoX, y: m.posicaoY };
        }
      });
      dragStartCoordsRef.current = coords;
      initialMotorPositionsRef.current = positions;
      pendingMotorClickRef.current = null;
    }

    if (!isEditMode || !draggedMotor) return;

    if (!dragStartCoordsRef.current) {
      dragStartCoordsRef.current = coords;
      const toMove = selectedMotorIds.includes(draggedMotor) && selectedMotorIds.length > 0 ? selectedMotorIds : [draggedMotor];
      initialMotorPositionsRef.current = Object.fromEntries(
        toMove.map(id => {
          const m = motors.find(mo => mo.id === id)!;
          return [id, { x: m.posicaoX!, y: m.posicaoY! }];
        })
      );
    }
    const start = dragStartCoordsRef.current;
    if (!start) return;
    const initialPositions = initialMotorPositionsRef.current;
    const toMove = selectedMotorIds.includes(draggedMotor) && selectedMotorIds.length > 0 ? selectedMotorIds : [draggedMotor];
    const deltaX = coords.x - start.x;
    const deltaY = coords.y - start.y;

    setMotors(prevMotors =>
      prevMotors.map(motor => {
        if (!toMove.includes(motor.id)) return motor;
        const init = initialPositions[motor.id];
        if (!init) return motor;
        return {
          ...motor,
          posicaoX: init.x + deltaX,
          posicaoY: init.y + deltaY,
        };
      })
    );
  };

  const handleSVGMouseUp = async () => {
    if (isEditMode && isSelectionMode) {
      if (pendingMotorClickRef.current) {
        const id = pendingMotorClickRef.current;
        setSelectedMotorIds(prev => [...new Set(prev.includes(id) ? prev : [...prev, id])]);
        pendingMotorClickRef.current = null;
      }
      if (boxSelectStart !== null) {
        if (boxSelectCurrent !== null) {
          const ids = motorsComPosicao.filter(m =>
            m.posicaoX != null && m.posicaoY != null && isMotorInBox(m.posicaoX, m.posicaoY, boxSelectStart!, boxSelectCurrent!)
          ).map(m => m.id);
          setSelectedMotorIds(prev => [...new Set([...prev, ...ids])]);
        } else {
          setSelectedMotorIds([]);
        }
        setBoxSelectStart(null);
        setBoxSelectCurrent(null);
      }
    }

    if (!draggedMotor || !plantaSelecionada) return;

    const toSave = selectedMotorIds.includes(draggedMotor) && selectedMotorIds.length > 0 ? selectedMotorIds : [draggedMotor];
    for (const id of toSave) {
      const motor = motors.find(m => m.id === id);
      if (motor && motor.posicaoX !== undefined && motor.posicaoY !== undefined) {
        try {
          setSavingPosition(id);
          await api.updateMotorPosicao(id, { posicaoX: motor.posicaoX, posicaoY: motor.posicaoY });
        } catch (err: any) {
          console.error('Erro ao salvar posição:', err);
        } finally {
          setSavingPosition(null);
        }
      }
    }
    setDraggedMotor(null);
    dragStartCoordsRef.current = null;
    initialMotorPositionsRef.current = {};
  };

  const handleMotorDoubleClick = (e: React.MouseEvent, motorId: string) => {
    e.stopPropagation();
    if (isEditMode && isSelectionMode) {
      setSelectedMotorIds(prev => prev.filter(id => id !== motorId));
    }
  };

  // Handlers de touch para mobile (reutilizam a mesma lógica com clientX/clientY)
  const getTouchCoords = (e: React.TouchEvent) => {
    const t = e.type === 'touchend' || e.type === 'touchcancel' ? e.changedTouches[0] : e.touches[0];
    return t ? getSVGCoordinatesFromClient(t.clientX, t.clientY) : null;
  };

  const getTouchDistance = (e: React.TouchEvent) => {
    if (e.touches.length < 2) return 0;
    const a = e.touches[0], b = e.touches[1];
    return Math.hypot(b.clientX - a.clientX, b.clientY - a.clientY);
  };

  const handleSVGTouchStart = (e: React.TouchEvent<SVGSVGElement>) => {
    if (e.touches.length === 2 && isEditMode) {
      lastPinchDistanceRef.current = getTouchDistance(e);
      lastPinchZoomRef.current = plantZoom;
      return;
    }
    if (!isEditMode) return;
    const coords = getTouchCoords(e);
    if (!coords) return;
    const target = e.target as SVGElement;
    if (target.closest('g[data-motor-id]')) return;
    if (isSelectionMode) {
      setBoxSelectStart(coords);
      setBoxSelectCurrent(null);
    }
  };

  const handleSVGTouchMove = (e: React.TouchEvent<SVGElement>) => {
    if (e.touches.length === 0) return;
    if (e.touches.length === 2 && isEditMode && lastPinchDistanceRef.current != null) {
      const dist = getTouchDistance(e);
      if (dist > 0) {
        const newZoom = clampZoom(lastPinchZoomRef.current * (dist / lastPinchDistanceRef.current));
        setPlantZoom(newZoom);
        lastPinchZoomRef.current = newZoom;
        lastPinchDistanceRef.current = dist;
      }
      return;
    }
    lastPinchDistanceRef.current = null;
    const coords = getSVGCoordinatesFromClient(e.touches[0].clientX, e.touches[0].clientY);
    if (!coords) return;
    if (isEditMode && isSelectionMode && boxSelectStart) {
      setBoxSelectCurrent(coords);
      return;
    }
    if (isEditMode && pendingMotorClickRef.current) {
      setDraggedMotor(pendingMotorClickRef.current);
      const motorId = pendingMotorClickRef.current;
      const toMove = selectedMotorIds.includes(motorId) ? selectedMotorIds : [motorId];
      const positions: Record<string, { x: number; y: number }> = {};
      motorsComPosicao.forEach(m => {
        if (toMove.includes(m.id) && m.posicaoX != null && m.posicaoY != null) {
          positions[m.id] = { x: m.posicaoX, y: m.posicaoY };
        }
      });
      dragStartCoordsRef.current = coords;
      initialMotorPositionsRef.current = positions;
      pendingMotorClickRef.current = null;
    }
    if (!isEditMode || !draggedMotor) return;
    if (!dragStartCoordsRef.current) {
      dragStartCoordsRef.current = coords;
      const toMove = selectedMotorIds.includes(draggedMotor) && selectedMotorIds.length > 0 ? selectedMotorIds : [draggedMotor];
      initialMotorPositionsRef.current = Object.fromEntries(
        toMove.map(id => {
          const m = motors.find(mo => mo.id === id)!;
          return [id, { x: m.posicaoX!, y: m.posicaoY! }];
        })
      );
    }
    const start = dragStartCoordsRef.current;
    if (!start) return;
    const initialPositions = initialMotorPositionsRef.current;
    const toMove = selectedMotorIds.includes(draggedMotor) && selectedMotorIds.length > 0 ? selectedMotorIds : [draggedMotor];
    const deltaX = coords.x - start.x;
    const deltaY = coords.y - start.y;
    setMotors(prevMotors =>
      prevMotors.map(motor => {
        if (!toMove.includes(motor.id)) return motor;
        const init = initialPositions[motor.id];
        if (!init) return motor;
        return { ...motor, posicaoX: init.x + deltaX, posicaoY: init.y + deltaY };
      })
    );
  };

  const handleSVGTouchEnd = async (e: React.TouchEvent<SVGSVGElement>) => {
    if (e.touches.length < 2) lastPinchDistanceRef.current = null;
    const coords = getTouchCoords(e);
    // Mobile: colocar motor no mapa após toque na lista e depois toque no mapa
    if (isEditMode && isAddMotorMode && motorToAddFromList && !draggedMotor && e.changedTouches.length === 1) {
      const touch = e.changedTouches[0];
      const target = document.elementFromPoint(touch.clientX, touch.clientY);
      if (target && !(target as Element).closest?.('g[data-motor-id]') && coords) {
        e.preventDefault();
        const idToPlace = motorToAddFromList;
        setMotorToAddFromList(null); // limpa logo para o clique sintético não posicionar de novo
        await placeMotorOnMap(idToPlace, coords);
        return;
      }
    }
    if (isEditMode && isSelectionMode) {
      if (pendingMotorClickRef.current) {
        const id = pendingMotorClickRef.current;
        setSelectedMotorIds(prev => [...new Set(prev.includes(id) ? prev : [...prev, id])]);
        pendingMotorClickRef.current = null;
      }
      if (boxSelectStart !== null) {
        if (boxSelectCurrent !== null && coords) {
          const ids = motorsComPosicao.filter(m =>
            m.posicaoX != null && m.posicaoY != null && isMotorInBox(m.posicaoX, m.posicaoY, boxSelectStart!, boxSelectCurrent!)
          ).map(m => m.id);
          setSelectedMotorIds(prev => [...new Set([...prev, ...ids])]);
        } else {
          setSelectedMotorIds([]);
          ignoreNextClickRef.current = true; // evita clique sintético no mobile mover motor
        }
        setBoxSelectStart(null);
        setBoxSelectCurrent(null);
      }
    }
    if (!draggedMotor || !plantaSelecionada) return;
    const toSave = selectedMotorIds.includes(draggedMotor) && selectedMotorIds.length > 0 ? selectedMotorIds : [draggedMotor];
    for (const id of toSave) {
      const motor = motors.find(m => m.id === id);
      if (motor && motor.posicaoX !== undefined && motor.posicaoY !== undefined) {
        try {
          setSavingPosition(id);
          await api.updateMotorPosicao(id, { posicaoX: motor.posicaoX, posicaoY: motor.posicaoY });
        } catch (err: any) {
          console.error('Erro ao salvar posição:', err);
        } finally {
          setSavingPosition(null);
        }
      }
    }
    setDraggedMotor(null);
    dragStartCoordsRef.current = null;
    initialMotorPositionsRef.current = {};
  };

  const handleMotorTouchStart = (e: React.TouchEvent, motorId: string) => {
    if (!isEditMode) return;
    e.stopPropagation();
    // Só seleção e arraste quando modo Selecionar estiver ativo
    if (!isSelectionMode) return;
    const now = Date.now();
    if (lastTapMotorRef.current?.id === motorId && now - lastTapMotorRef.current.time < 400) {
      setSelectedMotorIds(prev => prev.filter(id => id !== motorId));
      lastTapMotorRef.current = null;
      return;
    }
    lastTapMotorRef.current = { id: motorId, time: now };
    setSelectedMotorIds(prev => [...new Set(prev.includes(motorId) ? prev : [...prev, motorId])]);
    pendingMotorClickRef.current = motorId;
  };

  // Remover motores da visualização da planta (limpa posição; motor continua no sistema e pode ser adicionado de novo)
  const handleConfirmExcluir = async () => {
    if (!plantaSelecionada || selectedMotorIdsUnique.length === 0) return;
    const idsUnicos = selectedMotorIdsUnique;
    try {
      for (const id of idsUnicos) {
        await api.clearMotorPosicao(id);
      }
      setMotors(prev => prev.map(m => idsUnicos.includes(m.id) ? { ...m, posicaoX: undefined, posicaoY: undefined } : m));
      setSelectedMotorIds([]);
      setShowConfirmDeleteModal(false);
      invalidateCache(plantaSelecionada.id);
    } catch (err: any) {
      console.error('Erro ao remover da planta:', err);
      alert('Erro ao remover da planta: ' + (err.message || 'Erro desconhecido'));
    }
  };

  // Alinhar motores selecionados na vertical (mesmo X do primeiro motor selecionado)
  const handleAlignVertical = async () => {
    const toAlign = motors.filter(m => selectedMotorIds.includes(m.id) && m.posicaoX != null && m.posicaoY != null);
    if (toAlign.length < 2) return;
    const firstId = selectedMotorIds[0];
    const first = toAlign.find(m => m.id === firstId) ?? toAlign[0];
    const refX = first.posicaoX!;
    try {
      for (const m of toAlign) {
        await api.updateMotorPosicao(m.id, { posicaoX: refX, posicaoY: m.posicaoY! });
      }
      setMotors(prev => prev.map(m => (selectedMotorIds.includes(m.id) && m.posicaoX != null && m.posicaoY != null) ? { ...m, posicaoX: refX } : m));
      if (plantaSelecionada) invalidateCache(plantaSelecionada.id);
    } catch (err: any) {
      console.error('Erro ao alinhar:', err);
      alert('Erro ao alinhar: ' + (err.message || 'Erro desconhecido'));
    }
  };

  // Alinhar motores selecionados na horizontal (mesmo Y do primeiro motor selecionado)
  const handleAlignHorizontal = async () => {
    const toAlign = motors.filter(m => selectedMotorIds.includes(m.id) && m.posicaoX != null && m.posicaoY != null);
    if (toAlign.length < 2) return;
    const firstId = selectedMotorIds[0];
    const first = toAlign.find(m => m.id === firstId) ?? toAlign[0];
    const refY = first.posicaoY!;
    try {
      for (const m of toAlign) {
        await api.updateMotorPosicao(m.id, { posicaoX: m.posicaoX!, posicaoY: refY });
      }
      setMotors(prev => prev.map(m => (selectedMotorIds.includes(m.id) && m.posicaoX != null && m.posicaoY != null) ? { ...m, posicaoY: refY } : m));
      if (plantaSelecionada) invalidateCache(plantaSelecionada.id);
    } catch (err: any) {
      console.error('Erro ao alinhar:', err);
      alert('Erro ao alinhar: ' + (err.message || 'Erro desconhecido'));
    }
  };

  // Clique no SVG: no modo Adicionar, colocar motor escolhido da lista (mobile usa toque, PC pode usar clique após escolher)
  const handleSVGClick = async (e: React.MouseEvent<SVGSVGElement>) => {
    if (ignoreNextClickRef.current) {
      ignoreNextClickRef.current = false;
      e.preventDefault();
      e.stopPropagation();
      return;
    }
    if (!isEditMode || draggedMotor) return;
    if (isEditMode && isSelectionMode) return;
    // Modo Adicionar com motor escolhido da lista: posicionar no clique
    if (isEditMode && isAddMotorMode && motorToAddFromList) {
      const target = e.target as SVGElement;
      if (!target.closest?.('g[data-motor-id]')) {
        const coords = getSVGCoordinates(e);
        if (coords) {
          await placeMotorOnMap(motorToAddFromList, coords);
          setMotorToAddFromList(null);
        }
      }
      return;
    }
  };

  // Adicionar motor à planta: lista e handlers (placeMotorOnMap já definido acima)
  const motoresSemPosicao = motors.filter(m => m.habilitado && (!m.posicaoX || !m.posicaoY));
  const handleMapDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'move';
  };
  const handleMapDrop = async (e: React.DragEvent) => {
    e.preventDefault();
    const motorId = e.dataTransfer.getData('motorId');
    if (!motorId) return;
    const coords = getSVGCoordinatesFromClient(e.clientX, e.clientY);
    if (!coords) return;
    await placeMotorOnMap(motorId, coords);
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
            {/* Indicador de status do WebSocket de Correntes */}
            {plantaSelecionada && (
              <div className={`connection-status ${wsConnected ? 'connected' : 'disconnected'}`}>
                {wsConnected ? (
                  <>
                    <Wifi size={16} />
                    <span>Correntes em tempo real</span>
                  </>
                ) : (
                  <>
                    <WifiOff size={16} />
                    <span>Correntes desconectado</span>
                  </>
                )}
              </div>
            )}
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

        <div className="plant-container plant-container--with-edit">
          {/* Barra de menu lateral (modo editar) - canto superior direito */}
          {isEditMode && (
            <div className="plant-edit-sidebar">
              <div className="plant-edit-sidebar-header">
                <span>Edição</span>
              </div>
              <nav className="plant-edit-sidebar-nav">
                <button
                  type="button"
                  className={`plant-edit-sidebar-btn ${isAddMotorMode ? 'active' : ''}`}
                  onClick={() => {
                    setIsAddMotorMode(v => !v);
                    if (!isAddMotorMode) setIsSelectionMode(false);
                    if (isAddMotorMode) setMotorToAddFromList(null);
                  }}
                  title="Adicionar motores ao mapa (arraste da lista para o mapa)"
                >
                  <Plus size={22} />
                  <span>Adicionar</span>
                </button>
                <button
                  type="button"
                  className={`plant-edit-sidebar-btn ${isSelectionMode ? 'active' : ''}`}
                  onClick={() => {
                    setIsSelectionMode(v => !v);
                    if (!isSelectionMode) setIsAddMotorMode(false);
                  }}
                  title="Selecionar motores"
                >
                  <MousePointer2 size={22} />
                  <span>Selecionar</span>
                </button>
                {isSelectionMode && selectedMotorIdsUnique.length >= 1 && (
                  <>
                    <button
                      type="button"
                      className="plant-edit-sidebar-btn plant-edit-sidebar-btn--danger"
                      onClick={() => setShowConfirmDeleteModal(true)}
                      title="Remover motor(es) da planta (podem ser adicionados de novo)"
                    >
                      <Trash2 size={22} />
                      <span>Remover da planta</span>
                    </button>
                    {selectedMotorIdsUnique.length > 1 && (
                      <>
                        <button
                          type="button"
                          className="plant-edit-sidebar-btn"
                          onClick={handleAlignVertical}
                          title="Alinhar na vertical (mesmo X)"
                        >
                          <AlignCenterVertical size={22} />
                          <span>Alinhar vertical</span>
                        </button>
                        <button
                          type="button"
                          className="plant-edit-sidebar-btn"
                          onClick={handleAlignHorizontal}
                          title="Alinhar na horizontal (mesmo Y)"
                        >
                          <AlignCenterHorizontal size={22} />
                          <span>Alinhar horizontal</span>
                        </button>
                      </>
                    )}
                  </>
                )}
              </nav>
              {/* Lista de motores para adicionar ao mapa (arrastar para o mapa) */}
              {isAddMotorMode && (
                <div className="plant-edit-sidebar-list">
                  <div className="plant-edit-sidebar-list-title">
                    {motorToAddFromList ? 'Toque no mapa para posicionar' : 'Toque no motor ou arraste'}
                  </div>
                  <div className="plant-edit-sidebar-list-scroll">
                    {motoresSemPosicao.length === 0 ? (
                      <div className="plant-edit-sidebar-list-empty">Todos já estão no mapa</div>
                    ) : (
                      motoresSemPosicao.map(m => (
                        <div
                          key={m.id}
                          className={`plant-edit-sidebar-list-item ${motorToAddFromList === m.id ? 'plant-edit-sidebar-list-item--selected' : ''}`}
                          draggable
                          onDragStart={e => {
                            e.dataTransfer.setData('motorId', m.id);
                            e.dataTransfer.effectAllowed = 'move';
                          }}
                          onClick={() => setMotorToAddFromList(prev => (prev === m.id ? null : m.id))}
                        >
                          {m.nome}
                          {m.registroModBus ? ` (${m.registroModBus})` : ''}
                        </div>
                      ))
                    )}
                  </div>
                </div>
              )}
            </div>
          )}
          {/* Viewport de zoom: roda do mouse e pinch só afetam esta área */}
          <div
            ref={plantZoomRef}
            className={`plant-zoom-viewport ${isEditMode ? 'plant-zoom-viewport--edit' : ''}`}
          >
            <div
              className="plant-zoom-content"
              style={{
                transform: isEditMode ? `scale(${plantZoom})` : 'scale(1)',
                transformOrigin: 'center center',
              }}
              onDragOver={isEditMode && isAddMotorMode ? handleMapDragOver : undefined}
              onDrop={isEditMode && isAddMotorMode ? handleMapDrop : undefined}
            >
          <svg 
            ref={svgRef}
            className="plant-svg plant-svg-touch"
            viewBox="0 0 900 600"
            onMouseDown={handleSVGMouseDown}
            onMouseMove={handleSVGMouseMove}
            onMouseUp={handleSVGMouseUp}
            onMouseLeave={handleSVGMouseUp}
            onClick={handleSVGClick}
            onTouchStart={handleSVGTouchStart}
            onTouchMove={handleSVGTouchMove}
            onTouchEnd={handleSVGTouchEnd}
            onTouchCancel={handleSVGTouchEnd}
            style={{ cursor: isEditMode ? 'crosshair' : 'default', touchAction: isEditMode ? 'none' : 'auto' }}
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

            {/* Retângulo de seleção por arraste */}
            {boxSelectStart && boxSelectCurrent && (
              <rect
                x={Math.min(boxSelectStart.x, boxSelectCurrent.x)}
                y={Math.min(boxSelectStart.y, boxSelectCurrent.y)}
                width={Math.abs(boxSelectCurrent.x - boxSelectStart.x)}
                height={Math.abs(boxSelectCurrent.y - boxSelectStart.y)}
                fill="rgba(52, 152, 219, 0.15)"
                stroke="#3498db"
                strokeWidth={1.5}
                strokeDasharray="4,2"
                style={{ pointerEvents: 'none' }}
              />
            )}

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
                {isAddMotorMode
                  ? (motorToAddFromList ? 'Toque no mapa onde deseja colocar o motor' : 'Toque no motor na lista e depois no mapa (ou arraste no PC)')
                  : isSelectionMode
                    ? (draggedMotor ? 'Arraste para mover' : 'Clique ou arraste para selecionar | Duplo clique para desmarcar')
                    : 'Ative "Adicionar" ou "Selecionar" na barra ao lado'}
              </text>
            )}

            {/* Motores - apenas habilitados e com posição */}
            {motorsComPosicao.map((motor) => (
              <g key={motor.id} data-motor-id={motor.id}>
                {/* Círculo de destaque quando selecionado */}
                {selectedMotorIds.includes(motor.id) && (
                  <circle
                    cx={motor.posicaoX}
                    cy={motor.posicaoY}
                    r="16"
                    fill="none"
                    stroke="#3498db"
                    strokeWidth={2.5}
                    strokeDasharray="4,3"
                    style={{ pointerEvents: 'none' }}
                  />
                )}
                {/* Motor Indicator */}
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
                    if (isEditMode) handleMotorMouseDown(e, motor.id);
                  }}
                  onDoubleClick={(e) => handleMotorDoubleClick(e, motor.id)}
                  onTouchStart={(e) => handleMotorTouchStart(e, motor.id)}
                  onTouchMove={handleSVGTouchMove}
                  style={{ cursor: isEditMode ? 'move' : 'default', touchAction: isEditMode ? 'none' : 'auto' }}
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
        </div>
      </div>

      {/* Modal de confirmação para excluir motor(es) */}
      {showConfirmDeleteModal && (
        <div className="plant-confirm-modal-overlay" onClick={() => setShowConfirmDeleteModal(false)}>
          <div className="plant-confirm-modal" onClick={e => e.stopPropagation()}>
            <h3>Remover da planta</h3>
            <p>
              Remover {selectedMotorIdsUnique.length === 1 ? 'o motor selecionado' : `${selectedMotorIdsUnique.length} motores selecionados`} da visualização da planta?
              Eles continuarão no sistema e poderão ser adicionados novamente clicando no mapa.
            </p>
            <div className="plant-confirm-modal-actions">
              <button type="button" className="plant-confirm-modal-btn plant-confirm-modal-btn--cancel" onClick={() => setShowConfirmDeleteModal(false)}>
                Cancelar
              </button>
              <button type="button" className="plant-confirm-modal-btn plant-confirm-modal-btn--danger" onClick={handleConfirmExcluir}>
                Remover
              </button>
            </div>
          </div>
        </div>
      )}

    </div>
  );
}

export default Dashboard;
