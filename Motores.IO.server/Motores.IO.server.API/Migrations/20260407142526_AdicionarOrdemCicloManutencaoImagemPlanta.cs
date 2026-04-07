using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Motores.IO.server.API.Migrations
{
    /// <inheritdoc />
    public partial class AdicionarOrdemCicloManutencaoImagemPlanta : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ImagemPlantaBase64",
                table: "Plantas",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "CicloManutencao",
                table: "Motores",
                type: "numeric",
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "Ordem",
                table: "Motores",
                type: "integer",
                nullable: false,
                defaultValue: 0);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ImagemPlantaBase64",
                table: "Plantas");

            migrationBuilder.DropColumn(
                name: "CicloManutencao",
                table: "Motores");

            migrationBuilder.DropColumn(
                name: "Ordem",
                table: "Motores");
        }
    }
}
