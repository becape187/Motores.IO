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
  status: 'ligado' | 'desligado' | 'alerta' | 'alarme' | 'pendente';
  horimetro: number;
  correnteAtual: number; // Dinâmico, recebido via socket futuramente
  posicaoX?: number;
  posicaoY?: number;
  habilitado: boolean; // Para esconder do mapa, alarmes, etc
  // Dados de manutenção
  horimetroProximaManutencao?: number;
  dataEstimadaProximaManutencao?: Date;
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
