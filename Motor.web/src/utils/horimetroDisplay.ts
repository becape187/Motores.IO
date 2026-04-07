/** Exibe horímetro apenas com parte inteira (horas), sem casas decimais na UI. */
export function horimetroInteiro(value: number | undefined | null): number {
  const n = Number(value);
  if (Number.isNaN(n)) return 0;
  return Math.floor(n);
}
