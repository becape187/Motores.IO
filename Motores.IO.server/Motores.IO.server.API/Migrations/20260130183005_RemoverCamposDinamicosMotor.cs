using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Motores.IO.server.API.Migrations
{
    /// <inheritdoc />
    public partial class RemoverCamposDinamicosMotor : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CorrenteAtual",
                table: "Motores");

            migrationBuilder.DropColumn(
                name: "CorrenteInicial",
                table: "Motores");

            migrationBuilder.DropColumn(
                name: "MediaHorasDia",
                table: "Motores");

            migrationBuilder.DropColumn(
                name: "MediaHorasMes",
                table: "Motores");

            migrationBuilder.DropColumn(
                name: "MediaHorasSemana",
                table: "Motores");

            migrationBuilder.DropColumn(
                name: "TotalOS",
                table: "Motores");

            migrationBuilder.AddColumn<bool>(
                name: "Habilitado",
                table: "Motores",
                type: "boolean",
                nullable: false,
                defaultValue: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "Habilitado",
                table: "Motores");

            migrationBuilder.AddColumn<decimal>(
                name: "CorrenteAtual",
                table: "Motores",
                type: "numeric(10,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "CorrenteInicial",
                table: "Motores",
                type: "numeric(10,2)",
                nullable: false,
                defaultValue: 0m);

            migrationBuilder.AddColumn<decimal>(
                name: "MediaHorasDia",
                table: "Motores",
                type: "numeric(10,2)",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "MediaHorasMes",
                table: "Motores",
                type: "numeric(10,2)",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "MediaHorasSemana",
                table: "Motores",
                type: "numeric(10,2)",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "TotalOS",
                table: "Motores",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }
    }
}
