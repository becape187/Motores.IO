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
    public DbSet<Cliente> Clientes { get; set; }
    public DbSet<Planta> Plantas { get; set; }
    public DbSet<UsuarioPlanta> UsuariosPlantas { get; set; }
    public DbSet<TemaCliente> TemasCliente { get; set; }
    public DbSet<TemaUsuario> TemasUsuario { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Configuração do Motor
        modelBuilder.Entity<Motor>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()");
            
            entity.HasIndex(e => e.Nome).IsUnique();
            
            entity.Property(e => e.Nome)
                .IsRequired()
                .HasMaxLength(200);
            
            entity.Property(e => e.Potencia)
                .IsRequired()
                .HasColumnType("decimal(10,2)");
            
            entity.Property(e => e.Tensao)
                .IsRequired()
                .HasColumnType("decimal(10,2)");
            
            entity.Property(e => e.CorrenteNominal)
                .IsRequired()
                .HasColumnType("decimal(10,2)");
            
            entity.Property(e => e.PercentualCorrenteMaxima)
                .IsRequired()
                .HasColumnType("decimal(5,2)");
            
            entity.Property(e => e.Histerese)
                .IsRequired()
                .HasColumnType("decimal(5,2)");
            
            entity.Property(e => e.RegistroModBus)
                .HasMaxLength(100);
            
            entity.Property(e => e.RegistroLocal)
                .HasMaxLength(100);
            
            entity.Property(e => e.Status)
                .IsRequired()
                .HasMaxLength(50)
                .HasDefaultValue("desligado");
            
            entity.Property(e => e.Horimetro)
                .IsRequired()
                .HasColumnType("decimal(10,2)");
            
            entity.Property(e => e.Habilitado)
                .IsRequired()
                .HasDefaultValue(true);
            
            entity.Property(e => e.PosicaoX)
                .HasColumnType("decimal(10,2)");
            
            entity.Property(e => e.PosicaoY)
                .HasColumnType("decimal(10,2)");
            
            entity.Property(e => e.HorimetroProximaManutencao)
                .HasColumnType("decimal(10,2)");
            
            entity.Property(e => e.DataCriacao)
                .IsRequired()
                .HasDefaultValueSql("NOW()");
        });

        // Configuração do HistoricoMotor
        modelBuilder.Entity<HistoricoMotor>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()");
            
            entity.HasIndex(e => e.MotorId);
            entity.HasIndex(e => e.Timestamp);
            
            entity.Property(e => e.MotorId)
                .IsRequired();
            
            entity.Property(e => e.Timestamp)
                .IsRequired();
            
            entity.Property(e => e.Corrente)
                .IsRequired()
                .HasColumnType("decimal(10,2)");
            
            entity.Property(e => e.Tensao)
                .IsRequired()
                .HasColumnType("decimal(10,2)");
            
            entity.Property(e => e.Temperatura)
                .IsRequired()
                .HasColumnType("decimal(10,2)");
            
            entity.Property(e => e.Status)
                .IsRequired()
                .HasMaxLength(50);
            
            entity.HasOne(e => e.Motor)
                .WithMany(m => m.Historicos)
                .HasForeignKey(e => e.MotorId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configuração do Alarme
        modelBuilder.Entity<Alarme>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()");
            
            entity.HasIndex(e => e.MotorId);
            entity.HasIndex(e => e.Timestamp);
            entity.HasIndex(e => e.Reconhecido);
            
            entity.Property(e => e.MotorId)
                .IsRequired();
            
            entity.Property(e => e.MotorNome)
                .IsRequired()
                .HasMaxLength(200);
            
            entity.Property(e => e.Tipo)
                .IsRequired()
                .HasMaxLength(50);
            
            entity.Property(e => e.Mensagem)
                .IsRequired()
                .HasMaxLength(500);
            
            entity.Property(e => e.Timestamp)
                .IsRequired();
            
            entity.Property(e => e.Reconhecido)
                .IsRequired()
                .HasDefaultValue(false);
            
            entity.HasOne(e => e.Motor)
                .WithMany(m => m.Alarmes)
                .HasForeignKey(e => e.MotorId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configuração do Usuario
        modelBuilder.Entity<Usuario>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()");
            
            entity.HasIndex(e => e.Email).IsUnique();
            
            entity.Property(e => e.Nome)
                .IsRequired()
                .HasMaxLength(200);
            
            entity.Property(e => e.Email)
                .IsRequired()
                .HasMaxLength(200);
            
            entity.Property(e => e.SenhaHash)
                .IsRequired()
                .HasMaxLength(500);
            
            entity.Property(e => e.Perfil)
                .IsRequired()
                .HasMaxLength(50)
                .HasDefaultValue("visualizador");
            
            entity.Property(e => e.Ativo)
                .IsRequired()
                .HasDefaultValue(true);
            
            entity.Property(e => e.ClienteId)
                .IsRequired();
            
            entity.Property(e => e.DataCriacao)
                .IsRequired()
                .HasDefaultValueSql("NOW()");
            
            entity.HasOne(e => e.Cliente)
                .WithMany()
                .HasForeignKey(e => e.ClienteId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // Configuração da OrdemServico
        modelBuilder.Entity<OrdemServico>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()");
            
            entity.HasIndex(e => e.MotorId);
            entity.HasIndex(e => e.NumeroOS).IsUnique();
            entity.HasIndex(e => e.Status);
            
            entity.Property(e => e.MotorId)
                .IsRequired();
            
            entity.Property(e => e.NumeroOS)
                .IsRequired()
                .HasMaxLength(50);
            
            entity.Property(e => e.DataAbertura)
                .IsRequired();
            
            entity.Property(e => e.Status)
                .IsRequired()
                .HasMaxLength(50);
            
            entity.Property(e => e.Descricao)
                .IsRequired()
                .HasMaxLength(1000);
            
            entity.Property(e => e.Tipo)
                .IsRequired()
                .HasMaxLength(50);
            
            entity.HasOne(e => e.Motor)
                .WithMany(m => m.OrdensServico)
                .HasForeignKey(e => e.MotorId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configuração do RelatorioOS
        modelBuilder.Entity<RelatorioOS>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()");
            
            entity.HasIndex(e => e.OSId);
            
            entity.Property(e => e.OSId)
                .IsRequired();
            
            entity.Property(e => e.Data)
                .IsRequired();
            
            entity.Property(e => e.Tecnico)
                .IsRequired()
                .HasMaxLength(200);
            
            entity.Property(e => e.Descricao)
                .IsRequired()
                .HasMaxLength(2000);
            
            entity.Property(e => e.Observacoes)
                .HasMaxLength(2000);
            
            entity.Property(e => e.Anexos)
                .HasColumnType("text");
            
            entity.HasOne(e => e.OrdemServico)
                .WithMany(os => os.Relatorios)
                .HasForeignKey(e => e.OSId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configuração do Cliente
        modelBuilder.Entity<Cliente>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()");
            
            entity.HasIndex(e => e.Cnpj).IsUnique();
            
            entity.Property(e => e.Nome)
                .IsRequired()
                .HasMaxLength(200);
            
            entity.Property(e => e.Cnpj)
                .HasMaxLength(18);
            
            entity.Property(e => e.Email)
                .HasMaxLength(200);
            
            entity.Property(e => e.Telefone)
                .HasMaxLength(20);
            
            entity.Property(e => e.Ativo)
                .IsRequired()
                .HasDefaultValue(true);
            
            entity.Property(e => e.DataCriacao)
                .IsRequired()
                .HasDefaultValueSql("NOW()");
            
            entity.HasOne(e => e.Tema)
                .WithOne(t => t.Cliente)
                .HasForeignKey<TemaCliente>(t => t.ClienteId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configuração da Planta
        modelBuilder.Entity<Planta>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()");
            
            entity.HasIndex(e => new { e.ClienteId, e.Codigo }).IsUnique();
            
            entity.Property(e => e.Nome)
                .IsRequired()
                .HasMaxLength(200);
            
            entity.Property(e => e.Codigo)
                .HasMaxLength(50);
            
            entity.Property(e => e.Endereco)
                .HasMaxLength(500);
            
            entity.Property(e => e.Cidade)
                .HasMaxLength(100);
            
            entity.Property(e => e.Estado)
                .HasMaxLength(2);
            
            entity.Property(e => e.Ativo)
                .IsRequired()
                .HasDefaultValue(true);
            
            entity.Property(e => e.DataCriacao)
                .IsRequired()
                .HasDefaultValueSql("NOW()");
            
            entity.Property(e => e.ClienteId)
                .IsRequired();
            
            entity.HasOne(e => e.Cliente)
                .WithMany(c => c.Plantas)
                .HasForeignKey(e => e.ClienteId)
                .OnDelete(DeleteBehavior.Restrict);
        });

        // Configuração do UsuarioPlanta (tabela de junção)
        modelBuilder.Entity<UsuarioPlanta>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()");
            
            entity.HasIndex(e => new { e.UsuarioId, e.PlantaId }).IsUnique();
            
            entity.Property(e => e.UsuarioId)
                .IsRequired();
            
            entity.Property(e => e.PlantaId)
                .IsRequired();
            
            entity.Property(e => e.DataCriacao)
                .IsRequired()
                .HasDefaultValueSql("NOW()");
            
            entity.HasOne(e => e.Usuario)
                .WithMany(u => u.UsuariosPlantas)
                .HasForeignKey(e => e.UsuarioId)
                .OnDelete(DeleteBehavior.Cascade);
            
            entity.HasOne(e => e.Planta)
                .WithMany(p => p.UsuariosPlantas)
                .HasForeignKey(e => e.PlantaId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Configuração do TemaCliente
        modelBuilder.Entity<TemaCliente>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()");
            
            entity.HasIndex(e => e.ClienteId).IsUnique();
            
            entity.Property(e => e.ClienteId)
                .IsRequired();
            
            entity.Property(e => e.ConfiguracaoJson)
                .IsRequired()
                .HasColumnType("text");
            
            entity.Property(e => e.DataCriacao)
                .IsRequired()
                .HasDefaultValueSql("NOW()");
        });

        // Configuração do TemaUsuario
        modelBuilder.Entity<TemaUsuario>(entity =>
        {
            entity.HasKey(e => e.Id);
            
            entity.Property(e => e.Id)
                .HasDefaultValueSql("gen_random_uuid()");
            
            entity.HasIndex(e => e.UsuarioId).IsUnique();
            
            entity.Property(e => e.UsuarioId)
                .IsRequired();
            
            entity.Property(e => e.ConfiguracaoJson)
                .IsRequired()
                .HasColumnType("text");
            
            entity.Property(e => e.DataCriacao)
                .IsRequired()
                .HasDefaultValueSql("NOW()");
            
            entity.HasOne(e => e.Usuario)
                .WithOne(u => u.Tema)
                .HasForeignKey<TemaUsuario>(t => t.UsuarioId)
                .OnDelete(DeleteBehavior.Cascade);
        });

        // Atualizar configuração do Motor para incluir PlantaId
        modelBuilder.Entity<Motor>(entity =>
        {
            entity.HasOne(e => e.Planta)
                .WithMany(p => p.Motores)
                .HasForeignKey(e => e.PlantaId)
                .OnDelete(DeleteBehavior.SetNull);
        });
    }
}
