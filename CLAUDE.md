# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Instruções do dono do repositório (vêm dos arquivos `INSTRUCOES PARA OS AGENTES DE IA.md`)

- As instruções de cada pasta-mãe são **isoladas**: ao trabalhar em `Motor.web`, `Motores.IO.server` ou nos projetos de IHM, siga a instrução daquela pasta e não misture.
- **Não criar** documentação/`.md`, arquivos ou programas de exemplo sem o usuário pedir.
- Pode (e deve) **compilar** o projeto para verificar erros.
- **Migrations**: o usuário cria e aplica as migrations manualmente. Não rode `dotnet ef database update`/`migrations add` por conta própria.
- `Motor.web`: **não** alterar cores, layouts existentes, a tela de Login (em nada), nem UX/estética já pronta.
- O usuário escreve e espera respostas em **português (Brasil)**.

## Visão geral da arquitetura

Monorepo de um sistema de monitoramento de motores industriais em pedreiras. Quatro componentes, um fluxo de dados:

```
IHM WECON (pedreira)            Servidor (api.automais.io / 68.183.131.175)        Navegador
─────────────────────          ──────────────────────────────────────────        ─────────
HMIProject / SIGIL_PRINCIPAL    Motores.IO.server (ASP.NET Core 8)                 Motor.web
/ MORRO_GRANDE (Lua + telas) ─► TCP socket :5055 (SocketServerService) ──┐         (React/Vite)
  lê corrente dos registros     REST :5000 (Controllers, EF/PostgreSQL)  │ WebSocket ─► tempo real
  Modbus, SQLite local          InfluxDB (histórico de corrente)         └─► /api/websocket/*
  sincroniza via REST           Horímetro (integração da corrente)
```

- **`HMIProject/`** — projeto-template da IHM WECON PIStudio (`.pi`/`.pi2`/`.wmt3` + telas `.hsc` + scripts Lua em `Script/`). `HMIProject` é o template/base; **`SIGIL_PRINCIPAL/`** e **`MORRO_GRANDE/`** são as duas plantas reais em produção (cada uma com seu `Script/` e `PLANTA_UUID` próprio em `Script/Script_BG.lua`). UUIDs: Sigil = `661e8415-65eb-4821-86e9-462d7ad57c9e` (código 1), Morro Grande = `6e1c1fd1-f104-4172-bbd9-1f5a7e90e874` (código 2).
- **`Motores.IO.server/Motores.IO.server.API/`** — API ASP.NET Core 8 + EF Core (PostgreSQL) + InfluxDB. Sobe **dois listeners**: REST/WebSocket na :5000 (Kestrel) e o **TCP socket bruto na :5055** (`SocketServerService`, um `BackgroundService` singleton) que as IHMs usam.
- **`Motor.web/`** — SPA React 19 + TypeScript + Vite 7. `src/services/api.ts` faz REST (JWT no `localStorage`); `src/hooks/useWebSocket*.ts` consomem os WebSockets de tempo real; `src/utils/config.ts` decide URLs por ambiente (localhost/IP privado = dev).
- **`HMIProject/docs/`** — referência das APIs Lua do PIStudio (`we_bas_*`, LuaSocket/HTTP, SQLite, JSON). Consulte antes de mexer nos scripts Lua das IHMs.

### Fluxo de dados e pontos críticos

- **Sincronização de motores (IHM ↔ API)**: `Script/MotorSync.lua` faz sync bidirecional por timestamp (`dataAtualizacao`). A IHM **nunca cria** motores na API — só recebe; a criação é sempre pela API/web.
- **Corrente em tempo real**: `MotorCurrentReader.lua` lê o registro Modbus local (`RegistroLocal`, ex. `@HDW_W_0000100`) a cada 1 s e manda um array `tipo:"correntes"` pelo socket. O servidor (`ProcessCorrentesArrayAsync`) **apenas retransmite via WebSocket** — **não persiste** corrente nem status no banco.
- **Status do motor (`ligado`/`desligado`)**: campo dinâmico. Só é gravado no Postgres pelos handlers `ProcessMotorDataAsync`/`ProcessHistoricoMotorAsync` (mensagens `tipo:"motor"`/`tipo:"historico"`, ~1/min). Em `Motor.lua`, `setCorrenteAtual` define `Status=true` quando `valor > 200` (registro esperado em **centésimos de A** → 2,00 A). `CorrenteAtual` **foi removido** do modelo `Motor` no banco (migration `RemoverCamposDinamicosMotor`) — a corrente exibida vem **só** do WebSocket em tempo real.
- **Horímetro**: única fonte calculada; `HorimetroService` / `AtualizarHorimetroInline` integram tempo com corrente ≥ `5.0 A` (`CorrenteLimite`), `MaxGapSegundos = 600`. É gravado no histórico.
- **Frontend `Dashboard.tsx`**: "online"/contagem de rodando = `motors.filter(m => m.status === 'ligado')` — depende do **status persistido no banco (REST)**, não da corrente ao vivo. Status do banco congelado ⇒ motor aparece "rodando" mesmo com 0.0 A.
- **Autenticação**: esquema `JWT_OR_PLANTA_TOKEN` (`Program.cs`). Token com `.` → JWT (web/usuários); sem `.` → `PlantaTokenAuthenticationHandler` (token por planta, usado pelas IHMs no REST). Migrations não-dev **não** rodam automaticamente; só em `Development`.

## Comandos

### Servidor (`Motores.IO.server/Motores.IO.server.API/`)
```powershell
dotnet restore
dotnet build --configuration Release          # compilar / checar erros
dotnet run                                    # local: :5000 (REST/WS) + :5055 (socket)
# Swagger: /swagger  (habilitado em todos os ambientes)
# Migrations são responsabilidade do usuário — NÃO executar.
```

### Web (`Motor.web/`)
```powershell
npm install
npm run dev          # Vite dev server (porta 5173)
npm run build        # tsc + vite build  -> dist/  (também valida tipos)
npm run preview
```
> Não há `lint` configurado (apesar de o README antigo citar `npm run lint`); a checagem de tipos acontece no `npm run build`.

### IHM (PIStudio)
Sem build via CLI. Editado no WECON PIStudio; scripts Lua em `<PLANTA>/Script/*.lua`; telas em `screens/*.hsc`.

## Deploy (GitHub Actions, `.github/workflows/`)

`push` em `main`/`master` dispara por path:
- `Motor.web/**` → `deploy-motor-web.yml`: `npm ci && npm run build`, envia `dist/` para `/var/www/html` no servidor.
- `Motores.IO.server/**` → `deploy-motores-io-server.yml`: `dotnet publish`, extrai em `/home/Motores.IO`, gerencia o systemd `motores-io.service` (`ASPNETCORE_ENVIRONMENT=Production`, `:5000`).

Servidor de produção: `68.183.131.175`. Postgres local (`Database=MotoresIO`, user `automais`), InfluxDB local (org `automais`, bucket `motores_historico`). A skill `deploy-automais-env` cobre a publicação do `.env`/restart dos serviços.

## Convenções

- Código, comentários, logs, nomes de campo e mensagens de UI em **português**. DTOs/JSON usam `camelCase` (via `[JsonPropertyName]`); entidades EF usam `PascalCase` (colunas Postgres entre aspas, case-sensitive).
- Scripts Lua das IHMs são **classes com metatables** (`Obj = {}; Obj.__index = Obj; function Obj:new()`), dirigidas por `we_bg_poll()` chamando `:Loop()` de cada módulo, com gating por `we_bas_gettickcount()`. Atenção à semântica Lua de `a and b or c` e à verdade de strings (qualquer string ≠ `nil`/`false` é verdadeira).
- `appsettings.json` e `cloud/cloud.xml` contêm segredos reais (JWT, senha do banco, token InfluxDB) versionados — não introduza novos segredos; trate o repo como privado.
