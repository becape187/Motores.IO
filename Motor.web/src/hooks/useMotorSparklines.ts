import { useEffect, useState } from 'react';
import { api } from '../services/api';

export type SparkPoint = { ts: number; valor: number };

const WINDOW_MS = 60 * 60 * 1000;
const REFRESH_MS = 60 * 1000;
const STORAGE_PREFIX = 'motor-spark:';

function readCache(motorId: string): SparkPoint[] {
  try {
    const raw = localStorage.getItem(STORAGE_PREFIX + motorId);
    if (!raw) return [];
    const arr = JSON.parse(raw) as SparkPoint[];
    if (!Array.isArray(arr)) return [];
    const cutoff = Date.now() - WINDOW_MS;
    return arr
      .filter(p => p && typeof p.ts === 'number' && typeof p.valor === 'number' && p.ts >= cutoff)
      .sort((a, b) => a.ts - b.ts);
  } catch {
    return [];
  }
}

function writeCache(motorId: string, points: SparkPoint[]) {
  try {
    const cutoff = Date.now() - WINDOW_MS;
    const pruned = points.filter(p => p.ts >= cutoff);
    localStorage.setItem(STORAGE_PREFIX + motorId, JSON.stringify(pruned));
  } catch {
    // localStorage cheio ou indisponível — ignorar silenciosamente
  }
}

function mergeAndPrune(cached: SparkPoint[], novos: SparkPoint[]): SparkPoint[] {
  const merged = [...cached, ...novos].sort((a, b) => a.ts - b.ts);
  const dedup: SparkPoint[] = [];
  let lastTs = -1;
  for (const p of merged) {
    if (p.ts !== lastTs) {
      dedup.push(p);
      lastTs = p.ts;
    }
  }
  const cutoff = Date.now() - WINDOW_MS;
  return dedup.filter(p => p.ts >= cutoff);
}

/**
 * Mantém, para cada motor, uma janela rolante de 1h de corrente em localStorage.
 * Ao montar carrega do cache (render imediato), faz fetch incremental do que falta
 * a partir do timestamp do último ponto cacheado, e revisa a cada 1 min.
 */
export function useMotorSparklines(motorIds: string[]) {
  const idsKey = motorIds.join(',');
  const [data, setData] = useState<Map<string, SparkPoint[]>>(() => {
    const m = new Map<string, SparkPoint[]>();
    motorIds.forEach(id => m.set(id, readCache(id)));
    return m;
  });

  useEffect(() => {
    let cancelled = false;

    setData(prev => {
      const next = new Map(prev);
      motorIds.forEach(id => {
        if (!next.has(id)) next.set(id, readCache(id));
      });
      return next;
    });

    const fetchAll = async () => {
      if (motorIds.length === 0) return;
      const results = await Promise.allSettled(motorIds.map(async (id) => {
        const cached = readCache(id);
        const lastTs = cached.length > 0 ? cached[cached.length - 1].ts : Date.now() - WINDOW_MS;
        // só busca se houver pelo menos 30s desde o último ponto (Influx amostra a cada 1 min)
        if (Date.now() - lastTs < 30_000) {
          return { id, points: cached };
        }
        const start = new Date(lastTs + 1);
        const end = new Date();
        const fresh = await api.getHistorico(id, start, end);
        const novos: SparkPoint[] = (fresh ?? []).map((h: any) => ({
          ts: new Date(h.timestamp).getTime(),
          valor: Number(h.corrente ?? 0),
        }));
        const merged = mergeAndPrune(cached, novos);
        writeCache(id, merged);
        return { id, points: merged };
      }));
      if (cancelled) return;
      setData(prev => {
        const next = new Map(prev);
        for (const r of results) {
          if (r.status === 'fulfilled') {
            next.set(r.value.id, r.value.points);
          }
        }
        return next;
      });
    };

    fetchAll();
    const itv = setInterval(fetchAll, REFRESH_MS);
    return () => {
      cancelled = true;
      clearInterval(itv);
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [idsKey]);

  return data;
}
