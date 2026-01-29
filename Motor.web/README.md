# 🏭 Sistema de Monitoramento de Motores - Pedreira

Sistema web profissional para monitoramento e controle de motores industriais em pedreira, desenvolvido com React.js, TypeScript e design moderno.

![Sistema de Monitoramento](https://img.shields.io/badge/React-18.3-blue)
![TypeScript](https://img.shields.io/badge/TypeScript-5.6-blue)
![Vite](https://img.shields.io/badge/Vite-6.0-purple)
![License](https://img.shields.io/badge/License-MIT-green)

## 📋 Índice.

- [Visão Geral](#visão-geral)
- [Funcionalidades](#funcionalidades)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Instalação](#instalação)
- [Como Usar](#como-usar)
- [Páginas do Sistema](#páginas-do-sistema)
- [Dados Mock](#dados-mock)
- [Personalização](#personalização)
- [Deploy](#deploy)

## 🎯 Visão Geral

O Sistema de Monitoramento de Motores foi desenvolvido especificamente para operações de pedreira, oferecendo uma interface moderna e intuitiva para:

- Monitoramento em tempo real de motores industriais
- Visualização de planta baixa com status dos equipamentos
- Histórico detalhado com gráficos interativos
- Gerenciamento de alarmes e notificações
- Controle de usuários e permissões

### 🎨 Paleta de Cores

O sistema utiliza as cores da marca do cliente:

- **Primary Color**: `#496263` (Cinza)
- **Secondary Color**: `#347e26` (Verde)
- **White Color**: `#ffffff` (Branco)

## ✨ Funcionalidades

### 🔐 Autenticação
- Tela de login moderna e responsiva
- Sistema de autenticação simulado
- Controle de sessão

### 📊 Dashboard (Principal)
- Cards estatísticos com métricas em tempo real
- Visualização de planta baixa interativa
- Indicadores visuais de status dos motores
- Animações de pulse para motores online
- Labels informativos sobre cada motor
- Grid de resumo rápido dos motores

### ⚙️ Motores
- **Listagem completa** de motores cadastrados
- **Busca e filtros** por nome, ID e status
- **Visualização detalhada** com todas as especificações
- **CRUD completo**:
  - ✅ Adicionar novo motor
  - ✅ Editar configurações
  - ✅ Excluir motor
- **Configurações disponíveis**:
  - ID e Nome
  - Potência do Motor (kW)
  - Tensão de Alimentação (V)
  - Corrente Nominal (A)
  - Percentual de Corrente Máxima (%)
  - Histerese (%)
  - Corrente Inicial (A)
  - Status operacional
  - Horímetro

### 📈 Histórico
- **Seleção múltipla** de motores para análise
- **Gráfico interativo** com biblioteca Recharts
- **Personalização de cores** para cada motor
- **Filtros de tempo pré-definidos**:
  - Últimas 24 horas
  - Última semana
  - Último mês
  - Período personalizado (data/hora inicial e final)
- **Tabela detalhada** com histórico de registros
- **Exportação** de dados em formato CSV
- Visualização de corrente, tensão e temperatura

### 🚨 Alarmes
- Listagem de todos os alarmes do sistema
- **Classificação por tipo**:
  - 🔴 Erro
  - 🟡 Alerta
  - 🔵 Informação
- **Filtros**:
  - Por tipo de alarme
  - Por status (reconhecido/não reconhecido)
- Reconhecimento individual ou em massa
- Exclusão de alarmes
- Cards estatísticos de alarmes ativos

### 👥 Usuários
- **Gerenciamento completo** de usuários
- **Perfis de acesso**:
  - 🛡️ **Administrador**: Acesso total ao sistema
  - 👤 **Operador**: Pode operar e configurar motores
  - 👁️ **Visualizador**: Apenas visualização
- **Funcionalidades**:
  - Adicionar novos usuários
  - Editar informações
  - Ativar/desativar contas
  - Visualizar último acesso
- Informações detalhadas de permissões por perfil

## 🛠️ Tecnologias Utilizadas

### Core
- **React 18.3** - Biblioteca JavaScript para interfaces
- **TypeScript 5.6** - Superset tipado do JavaScript
- **Vite 6.0** - Build tool moderna e rápida

### Bibliotecas Principais
- **React Router DOM** - Navegação e rotas
- **Recharts** - Gráficos interativos
- **date-fns** - Manipulação de datas
- **Lucide React** - Ícones modernos e customizáveis

### Estilização
- CSS Modules
- CSS Grid e Flexbox
- Animações CSS
- Design responsivo

## 📁 Estrutura do Projeto

```
Motor.web/
├── public/
│   └── vite.svg
├── src/
│   ├── components/          # Componentes reutilizáveis
│   │   ├── Layout.tsx       # Layout principal com sidebar
│   │   └── Layout.css
│   ├── pages/               # Páginas da aplicação
│   │   ├── Login.tsx        # Tela de login
│   │   ├── Login.css
│   │   ├── Dashboard.tsx    # Dashboard principal
│   │   ├── Dashboard.css
│   │   ├── Motors.tsx       # Gerenciamento de motores
│   │   ├── Motors.css
│   │   ├── History.tsx      # Histórico e gráficos
│   │   ├── History.css
│   │   ├── Alarms.tsx       # Gerenciamento de alarmes
│   │   ├── Alarms.css
│   │   ├── Users.tsx        # Gerenciamento de usuários
│   │   └── Users.css
│   ├── types/               # Tipos TypeScript
│   │   └── index.ts         # Interfaces e tipos
│   ├── data/                # Dados mock
│   │   └── mockData.ts      # Dados de exemplo
│   ├── App.tsx              # Componente principal
│   ├── App.css              # Estilos globais
│   ├── main.tsx             # Ponto de entrada
│   └── index.css            # Reset e fontes
├── package.json
├── tsconfig.json
├── vite.config.ts
└── README.md                # Esta documentação
```

## 🚀 Instalação

### Pré-requisitos

- Node.js 18+ instalado
- npm ou yarn

### Passos

1. **Clone ou navegue até o diretório do projeto**:
```bash
cd "C:\Users\berna\OneDrive\Projetos Becape\Pedreiras\Motor.web"
```

2. **Instale as dependências**:
```bash
npm install
```

3. **Inicie o servidor de desenvolvimento**:
```bash
npm run dev
```

4. **Acesse no navegador**:
```
http://localhost:5173
```

## 📖 Como Usar

### Login

1. Acesse a aplicação
2. Use as credenciais de demonstração:
   - **Email**: `admin@pedreira.com`
   - **Senha**: `admin123` (qualquer senha funciona na demo)
3. Clique em "Entrar"

### Navegação

O sistema possui um **menu lateral** com as seguintes opções:

- 🏠 **Principal** - Dashboard com visão geral
- ⚙️ **Motores** - Gerenciamento de motores
- 📊 **Histórico** - Análise histórica
- 🚨 **Alarmes** - Notificações e alertas
- 👥 **Usuários** - Gerenciamento de usuários

### Trabalhando com Motores

#### Adicionar Motor
1. Acesse a página "Motores"
2. Clique em "Adicionar Motor"
3. Preencha os campos obrigatórios (*)
4. Clique em "Salvar"

#### Editar Motor
1. Selecione um motor da lista
2. Clique em "Editar"
3. Modifique os campos desejados
4. Clique em "Salvar"

#### Excluir Motor
1. Selecione um motor da lista
2. Clique em "Excluir"
3. Confirme a ação

### Visualizando Histórico

1. Acesse a página "Histórico"
2. Selecione os motores desejados (múltipla seleção)
3. Escolha o período:
   - Últimas 24h
   - Última Semana
   - Último Mês
   - Personalizado
4. Visualize o gráfico e a tabela
5. Personalize as cores das linhas (opcional)
6. Exporte para CSV se necessário

### Gerenciando Alarmes

1. Acesse a página "Alarmes"
2. Filtre por tipo ou status
3. Reconheça alarmes individualmente ou todos de uma vez
4. Exclua alarmes resolvidos

### Gerenciando Usuários

1. Acesse a página "Usuários"
2. Adicione novos usuários com perfis específicos
3. Edite informações ou altere perfis
4. Ative/desative contas conforme necessário

## 📊 Dados Mock

O sistema utiliza dados mock para demonstração. Os dados incluem:

### Motores
- 6 motores pré-configurados
- Status variados (online, alerta, offline)
- Dados de corrente atualizados em tempo real (simulado)
- Posições na planta baixa

### Histórico
- 30 dias de histórico
- Registros a cada 2 horas
- Dados de corrente, tensão e temperatura

### Alarmes
- 5 alarmes de exemplo
- Diferentes tipos e status
- Timestamps variados

### Usuários
- 5 usuários com diferentes perfis
- Dados de último acesso

## 🎨 Personalização

### Alterando Cores

Edite o arquivo `src/App.css`:

```css
:root {
  --primary-color: #496263;    /* Cinza principal */
  --secondary-color: #347e26;  /* Verde secundário */
  --white-color: #ffffff;      /* Branco */
  /* Adicione suas cores personalizadas */
}
```

### Modificando a Planta Baixa

Edite o arquivo `src/pages/Dashboard.tsx` na seção do SVG para ajustar:
- Estruturas da pedreira
- Posições dos motores
- Layout da planta

### Conectando com API Real

1. Crie um serviço API em `src/services/api.ts`
2. Substitua os imports de `mockData.ts` pelas chamadas de API
3. Implemente autenticação real
4. Adicione tratamento de erros

## 📦 Build para Produção

```bash
npm run build
```

Os arquivos otimizados serão gerados na pasta `dist/`.

## 🚀 Deploy

### Opções de Deploy

1. **Vercel** (Recomendado)
```bash
npm install -g vercel
vercel
```

2. **Netlify**
```bash
npm run build
# Faça upload da pasta dist/ no Netlify
```

3. **Servidor próprio**
```bash
npm run build
# Sirva os arquivos da pasta dist/ com nginx ou Apache
```

## 🔒 Segurança

⚠️ **IMPORTANTE**: Este é um projeto de demonstração. Para uso em produção:

- Implemente autenticação real (JWT, OAuth, etc.)
- Use HTTPS
- Valide todas as entradas do usuário
- Implemente rate limiting
- Use variáveis de ambiente para dados sensíveis
- Adicione logs de auditoria

## 🤝 Contribuindo

Sugestões de melhorias:

1. Integração com WebSocket para dados em tempo real
2. PWA (Progressive Web App)
3. Modo escuro
4. Internacionalização (i18n)
5. Testes automatizados
6. Dashboard customizável
7. Relatórios em PDF

## 📝 Scripts Disponíveis

```bash
npm run dev          # Inicia servidor de desenvolvimento
npm run build        # Cria build de produção
npm run preview      # Preview do build de produção
npm run lint         # Executa linter
```

## 🐛 Troubleshooting

### Porta já em uso
Se a porta 5173 estiver em uso, o Vite automaticamente usará a próxima disponível.

### Erros de dependências
```bash
rm -rf node_modules package-lock.json
npm install
```

### Problemas de build
```bash
npm run build -- --mode development
```

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo LICENSE para mais detalhes.

## 👤 Autor

Desenvolvido com ❤️ para monitoramento de motores industriais em pedreira.

## 🎓 Recursos Adicionais

- [Documentação do React](https://react.dev)
- [Documentação do TypeScript](https://www.typescriptlang.org)
- [Documentação do Vite](https://vitejs.dev)
- [Recharts](https://recharts.org)
- [React Router](https://reactrouter.com)

---

**Nota**: Este sistema utiliza dados mock para demonstração. Para implementação em produção, conecte com APIs reais e implemente medidas de segurança adequadas.

## 🌟 Sugestões de IA/Agentes para Design

Para melhorar ainda mais o design da aplicação, você pode utilizar:

1. **v0.dev by Vercel** - IA especializada em criar componentes React com design moderno
2. **Figma AI** - Para criar protótipos e designs profissionais
3. **Midjourney** - Para gerar imagens e ilustrações personalizadas
4. **Framer** - Para animações e interações avançadas
5. **Uizard** - IA para transformar sketches em designs
6. **Adobe Sensei** - IA integrada com ferramentas Adobe

O design atual já utiliza as melhores práticas modernas, incluindo:
- ✅ Design System consistente
- ✅ Responsividade total
- ✅ Animações suaves
- ✅ Hierarquia visual clara
- ✅ Acessibilidade (cores contrastantes)
- ✅ UX intuitiva
- ✅ Performance otimizada

**Feito com dedicação para ser LINDO e PROFISSIONAL! 🎨✨**
