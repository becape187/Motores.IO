# Motores.IO.server

API REST desenvolvida em ASP.NET Core 8.0 para gerenciamento de motores industriais.

## Estrutura do Projeto

```-
Motores.IO.server/
├── Motores.IO.server.API/          # Projeto principal da API
│   ├── Controllers/                # Controllers da API
│   │   ├── MotorsController.cs
│   │   ├── AlarmsController.cs
│   │   ├── HistoryController.cs
│   │   ├── UsersController.cs
│   │   └── MaintenanceController.cs
│   ├── Data/                       # Contexto do Entity Framework
│   │   └── ApplicationDbContext.cs
│   ├── Models/                     # Modelos de dados
│   │   ├── Motor.cs
│   │   ├── HistoricoMotor.cs
│   │   ├── Alarme.cs
│   │   ├── Usuario.cs
│   │   ├── OrdemServico.cs
│   │   └── RelatorioOS.cs
│   ├── Services/                   # Serviços (para futuras implementações)
│   ├── DTOs/                       # Data Transfer Objects (para futuras implementações)
│   ├── Program.cs                  # Configuração da aplicação
│   └── appsettings.json            # Configurações
└── Motores.IO.server.sln           # Solution file
```

## Tecnologias Utilizadas

- **.NET 8.0** - Framework principal
- **ASP.NET Core Web API** - Framework para criação da API REST
- **Entity Framework Core 8.0** - ORM para acesso ao banco de dados
- **PostgreSQL** - Banco de dados relacional
- **Npgsql.EntityFrameworkCore.PostgreSQL** - Provider do EF Core para PostgreSQL
- **Swagger/OpenAPI** - Documentação da API

## Pré-requisitos

- .NET 8.0 SDK ou superior
- PostgreSQL 12 ou superior
- Visual Studio 2022 ou VS Code (opcional)

## Configuração

### 1. Configurar Connection String

Edite o arquivo `appsettings.json` e configure a connection string do PostgreSQL:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Host=localhost;Port=5432;Database=MotoresIO;Username=seu_usuario;Password=sua_senha"
  }
}
```

### 2. Criar o Banco de Dados

Execute as migrations do Entity Framework:

```bash
cd Motores.IO.server.API
dotnet ef migrations add InitialCreate
dotnet ef database update
```

**Nota:** Se você não tiver o EF Core Tools instalado globalmente, instale com:

```bash
dotnet tool install --global dotnet-ef
```

### 3. Executar a Aplicação

```bash
cd Motores.IO.server.API
dotnet run
```

A API estará disponível em:
- HTTP: `http://localhost:5000`
- HTTPS: `https://localhost:5001`
- Swagger UI: `https://localhost:5001/swagger`

## Endpoints da API

### Motores
- `GET /api/motors` - Lista todos os motores
- `GET /api/motors/{id}` - Obtém um motor específico
- `POST /api/motors` - Cria um novo motor
- `PUT /api/motors/{id}` - Atualiza um motor
- `DELETE /api/motors/{id}` - Remove um motor

### Alarmes
- `GET /api/alarms` - Lista todos os alarmes
- `GET /api/alarms/{id}` - Obtém um alarme específico
- `GET /api/alarms/motor/{motorId}` - Lista alarmes de um motor
- `POST /api/alarms` - Cria um novo alarme
- `PUT /api/alarms/{id}/reconhecer` - Reconhece um alarme
- `DELETE /api/alarms/{id}` - Remove um alarme

### Histórico
- `GET /api/history` - Lista histórico de motores
- `GET /api/history/{id}` - Obtém um registro específico
- `POST /api/history` - Cria um novo registro de histórico
- `DELETE /api/history/{id}` - Remove um registro

### Usuários
- `GET /api/users` - Lista todos os usuários
- `GET /api/users/{id}` - Obtém um usuário específico
- `POST /api/users` - Cria um novo usuário
- `PUT /api/users/{id}` - Atualiza um usuário
- `DELETE /api/users/{id}` - Remove um usuário

### Manutenção
- `GET /api/maintenance/orders` - Lista ordens de serviço
- `GET /api/maintenance/orders/{id}` - Obtém uma ordem de serviço
- `POST /api/maintenance/orders` - Cria uma nova ordem de serviço
- `PUT /api/maintenance/orders/{id}` - Atualiza uma ordem de serviço
- `DELETE /api/maintenance/orders/{id}` - Remove uma ordem de serviço
- `GET /api/maintenance/reports` - Lista relatórios de OS
- `POST /api/maintenance/reports` - Cria um novo relatório

## Modelos de Dados

### Motor
- Informações básicas do motor (nome, potência, tensão, corrente, etc.)
- Status atual (ligado, desligado, alerta, alarme, pendente)
- Dados de manutenção e horímetro

### HistoricoMotor
- Registros históricos de corrente, tensão, temperatura
- Timestamp de cada registro
- Status no momento do registro

### Alarme
- Alarmes gerados pelos motores
- Tipos: erro, alerta, info
- Sistema de reconhecimento

### Usuario
- Usuários do sistema
- Perfis: admin, operador, visualizador
- Autenticação (senha hash)

### OrdemServico
- Ordens de serviço de manutenção
- Tipos: preventiva, corretiva, preditiva
- Status: aberta, concluída, atrasada, pendente

### RelatorioOS
- Relatórios de execução das ordens de serviço
- Informações do técnico e observações

## Desenvolvimento

### Adicionar Nova Migration

```bash
dotnet ef migrations add NomeDaMigration --project Motores.IO.server.API
```

### Aplicar Migrations

```bash
dotnet ef database update --project Motores.IO.server.API
```

### Reverter Migration

```bash
dotnet ef database update NomeDaMigrationAnterior --project Motores.IO.server.API
```

## Próximos Passos

- [ ] Implementar autenticação e autorização (JWT)
- [ ] Adicionar validações mais robustas
- [ ] Implementar DTOs para melhor separação de responsabilidades
- [ ] Adicionar logging estruturado
- [ ] Implementar testes unitários e de integração
- [ ] Adicionar documentação XML para Swagger
- [ ] Implementar paginação nas listagens
- [ ] Adicionar filtros avançados

## Licença

Este projeto é privado e de uso interno.
