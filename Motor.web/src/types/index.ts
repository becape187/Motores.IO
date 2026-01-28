export type Motor = {
  id: string;
  nome: string;
  potencia: number;
  tensao: number;
  correnteNominal: number;
  percentualCorrenteMaxima: number;
  histerese: number;
  correnteInicial: number;
  status: 'ligado' | 'desligado' | 'alerta' | 'alarme' | 'pendente';
  horimetro: number;
  correnteAtual: number;
  posicaoX?: number;
  posicaoY?: number;
  // Dados de manutenção
  horimetroProximaManutencao?: number;
  dataEstimadaProximaManutencao?: Date;
  totalOS?: number;
  mediaHorasDia?: number;
  mediaHorasSemana?: number;
  mediaHorasMes?: number;
};

export type HistoricoMotor = {
  id: string;
  motorId: string;
  timestamp: Date;
  corrente: number;
  tensao: number;
  temperatura: number;
  status: string;
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
  perfil: 'admin' | 'operador' | 'visualizador';
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
