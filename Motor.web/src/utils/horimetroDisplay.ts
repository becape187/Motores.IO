/** Formata horímetro decimal (em horas) para "HH:mm" — horas e minutos de funcionamento. */
export function horimetroHHmm(value: number | undefined | null): string {
  const n = Number(value);
  if (!Number.isFinite(n) || n < 0) return '00:00';
  const totalMinutos = Math.floor(n * 60);
  const horas = Math.floor(totalMinutos / 60);
  const minutos = totalMinutos % 60;
  return `${horas}:${String(minutos).padStart(2, '0')}`;
}
