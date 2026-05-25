// Limiar (em Amperes) usado para considerar o motor "ligado" — bate com
// `CorrenteLimite = 5.0` no backend (HorimetroService.cs / SocketServerService.cs).
// Se mudar este valor, mudar lá também — eles precisam ser iguais para que o
// status mostrado na tela e o horímetro contado pelo backend usem a mesma regra.
export const LIMIAR_LIGADO_AMPERES = 5.0;

export type StatusMotor = 'ligado' | 'desligado' | 'alerta' | 'alarme' | 'pendente';

/**
 * Status derivado da corrente atual. Não depende do campo `motor.status` do banco
 * (status persistido é só o último valor visto — não tem regra de negócio em cima).
 */
export function derivarStatus(correnteAtual: number | undefined | null): StatusMotor {
  const n = Number(correnteAtual);
  if (!Number.isFinite(n)) return 'desligado';
  return n >= LIMIAR_LIGADO_AMPERES ? 'ligado' : 'desligado';
}
