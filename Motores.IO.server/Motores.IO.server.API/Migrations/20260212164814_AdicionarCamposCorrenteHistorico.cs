using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Motores.IO.server.API.Migrations
{
    /// <inheritdoc />
    public partial class AdicionarCamposCorrenteHistorico : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<decimal>(
                name: "CorrenteMaxima",
                table: "HistoricosMotores",
                type: "numeric(10,2)",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "CorrenteMedia",
                table: "HistoricosMotores",
                type: "numeric(10,2)",
                nullable: true);

            migrationBuilder.AddColumn<decimal>(
                name: "CorrenteMinima",
                table: "HistoricosMotores",
                type: "numeric(10,2)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "CorrenteMaxima",
                table: "HistoricosMotores");

            migrationBuilder.DropColumn(
                name: "CorrenteMedia",
                table: "HistoricosMotores");

            migrationBuilder.DropColumn(
                name: "CorrenteMinima",
                table: "HistoricosMotores");
        }
    }
}
