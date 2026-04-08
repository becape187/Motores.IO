using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Motores.IO.server.API.Migrations
{
    /// <inheritdoc />
    public partial class AdicionarDataUltimaManutencao : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<DateTime>(
                name: "DataUltimaManutencao",
                table: "Motores",
                type: "timestamp with time zone",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "DataUltimaManutencao",
                table: "Motores");
        }
    }
}
