using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Motores.IO.server.API.Migrations
{
    /// <inheritdoc />
    public partial class RemoverHistoricosMotores : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // IF EXISTS: não falha se a tabela já foi renomeada/apagada manualmente no PostgreSQL.
            migrationBuilder.Sql(@"DROP TABLE IF EXISTS ""HistoricosMotores"" CASCADE;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            // Histórico de séries temporais fica apenas no InfluxDB; não recriamos a tabela legada.
        }
    }
}
