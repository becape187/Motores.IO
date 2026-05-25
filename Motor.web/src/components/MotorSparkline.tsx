import type { SparkPoint } from '../hooks/useMotorSparklines';

interface Props {
  points: SparkPoint[];
  color: string;
}

const W = 100;
const H = 32;
const WINDOW_MS = 60 * 60 * 1000;

export function MotorSparkline({ points, color }: Props) {
  if (!points || points.length < 2) return null;

  const now = Date.now();
  const windowStart = now - WINDOW_MS;

  const vals = points.map(p => p.valor);
  const minV = Math.min(...vals);
  const maxV = Math.max(...vals);
  // Garante uma "linha de base" se a corrente estiver constante (range zero).
  const baseMin = Math.min(minV, 0);
  const range = Math.max(maxV - baseMin, 1);

  const coords = points.map(p => {
    const x = Math.max(0, Math.min(1, (p.ts - windowStart) / WINDOW_MS)) * W;
    const y = H - ((p.valor - baseMin) / range) * H;
    return [x, y] as const;
  });

  const linePath = coords
    .map(([x, y], i) => `${i === 0 ? 'M' : 'L'} ${x.toFixed(2)} ${y.toFixed(2)}`)
    .join(' ');
  const areaPath =
    `M ${coords[0][0].toFixed(2)} ${H} ` +
    coords.map(([x, y]) => `L ${x.toFixed(2)} ${y.toFixed(2)}`).join(' ') +
    ` L ${coords[coords.length - 1][0].toFixed(2)} ${H} Z`;

  return (
    <svg
      className="motor-sparkline"
      viewBox={`0 0 ${W} ${H}`}
      preserveAspectRatio="none"
      aria-hidden="true"
      focusable="false"
    >
      <path d={areaPath} fill={color} fillOpacity="0.12" />
      <path
        d={linePath}
        fill="none"
        stroke={color}
        strokeOpacity="0.55"
        strokeWidth="1.2"
        vectorEffect="non-scaling-stroke"
      />
    </svg>
  );
}
