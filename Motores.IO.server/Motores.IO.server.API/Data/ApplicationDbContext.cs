using Microsoft.EntityFrameworkCore;
using Motores.IO.server.API.Models;

namespace Motores.IO.server.API.Data;

public class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public DbSet<Motor> Motores { get; set; }
    public DbSet<HistoricoMotor> HistoricosMotores { get; set; }
    public DbSet<Alarme> Alarmes { get; set; }
    public DbSet<Usuario> Usuarios { get; set; }
    public DbSet<OrdemServico> OrdensServico { get; set; }
    public DbSet<RelatorioOS> RelatoriosOS { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configuração do Motor
        modelBuilder.Entity<Motor>(entity =>
        {
            entity.HasIndex(e => e.Nome).IsUnique();
            entity.Property(e => e.Status).HasDefaultValue("desligado");
        });

        // Configuração do HistoricoMotor
        modelBuilder.Entity<HistoricoMotor>(entity =>
        {
            entity.HasIndex(e => e.MotorId);
            entity.HasIndex(e => e.Timestamp);
            entity.HasOne(e => e.Motor)
                .WithMany(m => m.Historicos)
                .HasForeignKey(e => e.MotorId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configuração do Alarme
        modelBuilder.Entity<Alarme>(entity =>
        {
            entity.HasIndex(e => e.MotorId);
            entity.HasIndex(e => e.Timestamp);
            entity.HasIndex(e => e.Reconhecido);
            entity.HasOne(e => e.Motor)
                .WithMany(m => m.Alarmes)
                .HasForeignKey(e => e.MotorId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configuração do Usuario
        modelBuilder.Entity<Usuario>(entity =>
        {
            entity.HasIndex(e => e.Email).IsUnique();
            entity.Property(e => e.Ativo).HasDefaultValue(true);
        });

        // Configuração da OrdemServico
        modelBuilder.Entity<OrdemServico>(entity =>
        {
            entity.HasIndex(e => e.MotorId);
            entity.HasIndex(e => e.NumeroOS).IsUnique();
            entity.HasIndex(e => e.Status);
            entity.HasOne(e => e.Motor)
                .WithMany(m => m.OrdensServico)
                .HasForeignKey(e => e.MotorId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configuração do RelatorioOS
        modelBuilder.Entity<RelatorioOS>(entity =>
        {
            entity.HasIndex(e => e.OSId);
            entity.HasOne(e => e.OrdemServico)
                .WithMany(os => os.Relatorios)
                .HasForeignKey(e => e.OSId)
                .OnDelete(DeleteBehavior.Cascade);
        });
    }
}
