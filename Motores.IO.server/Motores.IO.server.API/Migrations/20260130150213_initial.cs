using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Motores.IO.server.API.Migrations
{
    /// <inheritdoc />
    public partial class initial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Motores",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Nome = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Potencia = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    Tensao = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    CorrenteNominal = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    PercentualCorrenteMaxima = table.Column<decimal>(type: "numeric(5,2)", nullable: false),
                    Histerese = table.Column<decimal>(type: "numeric(5,2)", nullable: false),
                    CorrenteInicial = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    Status = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false, defaultValue: "desligado"),
                    Horimetro = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    CorrenteAtual = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    PosicaoX = table.Column<decimal>(type: "numeric(10,2)", nullable: true),
                    PosicaoY = table.Column<decimal>(type: "numeric(10,2)", nullable: true),
                    HorimetroProximaManutencao = table.Column<decimal>(type: "numeric(10,2)", nullable: true),
                    DataEstimadaProximaManutencao = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    TotalOS = table.Column<int>(type: "integer", nullable: false),
                    MediaHorasDia = table.Column<decimal>(type: "numeric(10,2)", nullable: true),
                    MediaHorasSemana = table.Column<decimal>(type: "numeric(10,2)", nullable: true),
                    MediaHorasMes = table.Column<decimal>(type: "numeric(10,2)", nullable: true),
                    DataCriacao = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    DataAtualizacao = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Motores", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Usuarios",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Nome = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Email = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    SenhaHash = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Perfil = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Ativo = table.Column<bool>(type: "boolean", nullable: false, defaultValue: true),
                    UltimoAcesso = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    DataCriacao = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    DataAtualizacao = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Usuarios", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Alarmes",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    MotorId = table.Column<Guid>(type: "uuid", nullable: false),
                    MotorNome = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Tipo = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Mensagem = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    Timestamp = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Reconhecido = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    DataReconhecimento = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    UsuarioReconhecimentoId = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Alarmes", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Alarmes_Motores_MotorId",
                        column: x => x.MotorId,
                        principalTable: "Motores",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "HistoricosMotores",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    MotorId = table.Column<Guid>(type: "uuid", nullable: false),
                    Timestamp = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Corrente = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    Tensao = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    Temperatura = table.Column<decimal>(type: "numeric(10,2)", nullable: false),
                    Status = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_HistoricosMotores", x => x.Id);
                    table.ForeignKey(
                        name: "FK_HistoricosMotores_Motores_MotorId",
                        column: x => x.MotorId,
                        principalTable: "Motores",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "OrdensServico",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    MotorId = table.Column<Guid>(type: "uuid", nullable: false),
                    NumeroOS = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    DataAbertura = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    DataEncerramento = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    DataPrevista = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    Status = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false),
                    Descricao = table.Column<string>(type: "character varying(1000)", maxLength: 1000, nullable: false),
                    Tipo = table.Column<string>(type: "character varying(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_OrdensServico", x => x.Id);
                    table.ForeignKey(
                        name: "FK_OrdensServico_Motores_MotorId",
                        column: x => x.MotorId,
                        principalTable: "Motores",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "RelatoriosOS",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    OSId = table.Column<Guid>(type: "uuid", nullable: false),
                    Data = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    Tecnico = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
                    Descricao = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: false),
                    Observacoes = table.Column<string>(type: "character varying(2000)", maxLength: 2000, nullable: true),
                    Anexos = table.Column<string>(type: "text", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RelatoriosOS", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RelatoriosOS_OrdensServico_OSId",
                        column: x => x.OSId,
                        principalTable: "OrdensServico",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Alarmes_MotorId",
                table: "Alarmes",
                column: "MotorId");

            migrationBuilder.CreateIndex(
                name: "IX_Alarmes_Reconhecido",
                table: "Alarmes",
                column: "Reconhecido");

            migrationBuilder.CreateIndex(
                name: "IX_Alarmes_Timestamp",
                table: "Alarmes",
                column: "Timestamp");

            migrationBuilder.CreateIndex(
                name: "IX_HistoricosMotores_MotorId",
                table: "HistoricosMotores",
                column: "MotorId");

            migrationBuilder.CreateIndex(
                name: "IX_HistoricosMotores_Timestamp",
                table: "HistoricosMotores",
                column: "Timestamp");

            migrationBuilder.CreateIndex(
                name: "IX_Motores_Nome",
                table: "Motores",
                column: "Nome",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_OrdensServico_MotorId",
                table: "OrdensServico",
                column: "MotorId");

            migrationBuilder.CreateIndex(
                name: "IX_OrdensServico_NumeroOS",
                table: "OrdensServico",
                column: "NumeroOS",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_OrdensServico_Status",
                table: "OrdensServico",
                column: "Status");

            migrationBuilder.CreateIndex(
                name: "IX_RelatoriosOS_OSId",
                table: "RelatoriosOS",
                column: "OSId");

            migrationBuilder.CreateIndex(
                name: "IX_Usuarios_Email",
                table: "Usuarios",
                column: "Email",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Alarmes");

            migrationBuilder.DropTable(
                name: "HistoricosMotores");

            migrationBuilder.DropTable(
                name: "RelatoriosOS");

            migrationBuilder.DropTable(
                name: "Usuarios");

            migrationBuilder.DropTable(
                name: "OrdensServico");

            migrationBuilder.DropTable(
                name: "Motores");
        }
    }
}
