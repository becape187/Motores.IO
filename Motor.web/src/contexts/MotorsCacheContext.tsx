import { createContext, useContext, ReactNode, useCallback } from 'react';
import { api } from '../services/api';
import { Motor } from '../types';

interface MotorsCacheContextType {
  getMotors: (plantaId: string, options?: { useCache?: boolean }) => Promise<Motor[]>;
  invalidateCache: (plantaId?: string) => void;
  refreshMotors: (plantaId: string) => Promise<Motor[]>;
}

const MotorsCacheContext = createContext<MotorsCacheContextType | undefined>(undefined);

// Cache global por planta
const motorsCache: Map<string, { motors: Motor[]; timestamp: number }> = new Map();
const CACHE_DURATION = 30000; // 30 segundos

const convertMotorData = (m: any): Motor => ({
  id: m.id,
  nome: m.nome,
  potencia: Number(m.potencia),
  tensao: Number(m.tensao),
  correnteNominal: Number(m.correnteNominal),
  percentualCorrenteMaxima: Number(m.percentualCorrenteMaxima),
  histerese: Number(m.histerese),
  registroModBus: m.registroModBus,
  registroLocal: m.registroLocal,
  status: m.status as Motor['status'],
  horimetro: Number(m.horimetro),
  // Converter correnteAtual: dividir por 100 (ex: 2153 -> 21.5)
  correnteAtual: (Number(m.correnteAtual || 0)) / 100,
  posicaoX: m.posicaoX ? Number(m.posicaoX) : undefined,
  posicaoY: m.posicaoY ? Number(m.posicaoY) : undefined,
  habilitado: m.habilitado !== undefined ? m.habilitado : true,
  horimetroProximaManutencao: m.horimetroProximaManutencao ? Number(m.horimetroProximaManutencao) : undefined,
  dataEstimadaProximaManutencao: m.dataEstimadaProximaManutencao ? new Date(m.dataEstimadaProximaManutencao) : undefined,
});

export function MotorsCacheProvider({ children }: { children: ReactNode }) {
  const refreshMotors = useCallback(async (plantaId: string): Promise<Motor[]> => {
    const data = await api.getMotores(plantaId);
    const motorsData: Motor[] = data.map(convertMotorData);
    
    // Atualizar cache
    motorsCache.set(plantaId, {
      motors: motorsData,
      timestamp: Date.now(),
    });

    return motorsData;
  }, []);

  const getMotors = useCallback(async (plantaId: string, options?: { useCache?: boolean }): Promise<Motor[]> => {
    const useCache = options?.useCache !== false;

    // Verificar cache primeiro
    if (useCache) {
      const cached = motorsCache.get(plantaId);
      if (cached && Date.now() - cached.timestamp < CACHE_DURATION) {
        // Retornar cache e atualizar em background
        refreshMotors(plantaId).catch(console.error);
        return cached.motors;
      }
    }

    // Buscar da API
    return await refreshMotors(plantaId);
  }, [refreshMotors]);

  const invalidateCache = useCallback((plantaId?: string) => {
    if (plantaId) {
      motorsCache.delete(plantaId);
    } else {
      motorsCache.clear();
    }
  }, []);

  return (
    <MotorsCacheContext.Provider
      value={{
        getMotors,
        invalidateCache,
        refreshMotors,
      }}
    >
      {children}
    </MotorsCacheContext.Provider>
  );
}

export function useMotorsCache() {
  const context = useContext(MotorsCacheContext);
  if (context === undefined) {
    throw new Error('useMotorsCache deve ser usado dentro de um MotorsCacheProvider');
  }
  return context;
}
