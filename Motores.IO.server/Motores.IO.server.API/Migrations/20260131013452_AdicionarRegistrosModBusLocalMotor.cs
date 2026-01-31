using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Motores.IO.server.API.Migrations
{
    /// <inheritdoc />
    public partial class AdicionarRegistrosModBusLocalMotor : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "RegistroLocal",
                table: "Motores",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "RegistroModBus",
                table: "Motores",
                type: "character varying(100)",
                maxLength: 100,
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "RegistroLocal",
                table: "Motores");

            migrationBuilder.DropColumn(
                name: "RegistroModBus",
                table: "Motores");
        }
    }
}
