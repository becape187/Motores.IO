using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Motores.IO.server.API.Migrations
{
    /// <inheritdoc />
    public partial class AdicionarHorimetroCalculadoEZeramento : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "DataCalculoHorimetro",
                table: "Motores",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "DataZeramentoHorimetro",
                table: "Motores",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "HorimetroCalculado",
                table: "Motores",
                type: "numeric(10,2)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DataCalculoHorimetro",
                table: "Motores");

            migrationBuilder.DropColumn(
                name: "DataZeramentoHorimetro",
                table: "Motores");

            migrationBuilder.DropColumn(
                name: "HorimetroCalculado",
                table: "Motores");
        }
    }
}
