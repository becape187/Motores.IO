using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Motores.IO.server.API.Migrations
{
    /// <inheritdoc />
    public partial class AdicionarApiTokenPlanta : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "ApiToken",
                table: "Plantas",
                type: "character varying(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ApiTokenGeradoEm",
                table: "Plantas",
                type: "timestamp with time zone",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "IX_Plantas_ApiToken",
                table: "Plantas",
                column: "ApiToken",
                unique: true,
                filter: "\"ApiToken\" IS NOT NULL");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "IX_Plantas_ApiToken",
                table: "Plantas");

            migrationBuilder.DropColumn(
                name: "ApiToken",
                table: "Plantas");

            migrationBuilder.DropColumn(
                name: "ApiTokenGeradoEm",
                table: "Plantas");
        }
    }
}
