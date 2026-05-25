export type Motor = {
  id: string;
  nome: string;
  potencia: number;
  tensao: number;
  correnteNominal: number;
  percentualCorrenteMaxima: number;
  histerese: number;
  registroModBus?: string;
  registroLocal?: string;
  // Status persistido — espelho do último valor visto. NÃO usar em decisões da UI:
  // status visível na tela é DERIVADO da corrente atual (utils/motorStatus.ts).
  status: 'ligado' | 'desligado' | 'alerta' | 'alarme' | 'pendente';
  // Horímetro de OPERAÇÃO — incrementa em tempo real; é o usado por manutenção;
  // botão "Zerar Horímetro" o reseta.
  horimetro: number;
  horimetroTs?: number;
  // Horímetro CALCULADO — só atualizado quando o usuário clica em "Calcular do Histórico".
  horimetroCalculado?: number;
  dataCalculoHorimetro?: Date;
  dataZeramentoHorimetro?: Date;
  correnteAtual: number; // Em Amperes, recebido via socket (IHM já aplica raw/100)
  correnteMedia?: number; // Média da janela (1 min)
  correnteMaxima?: number; // Máximo registrado na janela
  correnteMinima?: number; // Mínimo registrado na janela
  posicaoX?: number;
  posicaoY?: number;
  habilitado: boolean; // Para esconder do mapa, alarmes, etc
  ordem?: number;
  // Dados de manutenção
  cicloManutencao?: number;
  horimetroProximaManutencao?: number;
  dataEstimadaProximaManutencao?: Date;
  dataUltimaManutencao?: Date;
};

export type HistoricoMotor = {
  id: string;
  motorId: string;
  timestamp: Date;
  corrente: number;
  tensao: number;
  temperatura: number;
  status: string;
  correnteMedia?: number;
  correnteMaxima?: number;
  correnteMinima?: number;
  horimetro: number;
};

export type Alarme = {
  id: string;
  motorId: string;
  motorNome: string;
  tipo: 'erro' | 'alerta' | 'info';
  mensagem: string;
  timestamp: Date;
  reconhecido: boolean;
};

export type Usuario = {
  id: string;
  nome: string;
  email: string;
  perfil: 'admin' | 'operador' | 'visualizador' | 'global';
  ativo: boolean;
  ultimoAcesso?: Date;
};

export type DashboardData = {
  totalMotores: number;
  motoresOnline: number;
  motoresAlerta: number;
  motoresErro: number;
  consumoTotal: number;
};

export type OrdemServico = {
  id: string;
  motorId: string;
  numeroOS: string;
  dataAbertura: Date;
  dataEncerramento?: Date;
  dataPrevista?: Date;
  status: 'aberta' | 'concluida' | 'atrasada' | 'pendente';
  descricao: string;
  tipo: 'preventiva' | 'corretiva' | 'preditiva';
  relatorios: RelatorioOS[];
};

export type RelatorioOS = {
  id: string;
  osId: string;
  data: Date;
  tecnico: string;
  descricao: string;
  observacoes: string;
  anexos?: string[];
};
