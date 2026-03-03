using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Motores.IO.server.API.Migrations
{
    /// <inheritdoc />
    public partial class AlterarUniqueIndexMotorNomePorPlanta : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Motores_Nome",
                table: "Motores");

            migrationBuilder.DropIndex(
                name: "IX_Motores_PlantaId",
                table: "Motores");

            migrationBuilder.CreateIndex(
                name: "IX_Motores_PlantaId_Nome",
                table: "Motores",
                columns: new[] { "PlantaId", "Nome" },
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Motores_PlantaId_Nome",
                table: "Motores");

            migrationBuilder.CreateIndex(
                name: "IX_Motores_Nome",
                table: "Motores",
                column: "Nome",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Motores_PlantaId",
                table: "Motores",
                column: "PlantaId");
        }
    }
}
