using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Motores.IO.server.API.Data;
using Motores.IO.server.API.DTOs;
using Motores.IO.server.API.Models;

namespace Motores.IO.server.API.Services;

public class AuthService : IAuthService
{
    private readonly ApplicationDbContext _context;
    private readonly IConfiguration _configuration;

    public AuthService(ApplicationDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    public async Task<LoginResponse?> AutenticarAsync(string email, string senha)
    {
        var usuario = await _context.Usuarios
            .FirstOrDefaultAsync(u => u.Email == email && u.Ativo);

        if (usuario == null)
            return null;

        // Verificar senha usando BCrypt
        if (!BCrypt.Net.BCrypt.Verify(senha, usuario.SenhaHash))
            return null;

        // Atualizar último acesso
        usuario.UltimoAcesso = DateTime.UtcNow;
        await _context.SaveChangesAsync();

        // Buscar plantas do usuário
        var plantas = await _context.UsuariosPlantas
            .Where(up => up.UsuarioId == usuario.Id)
            .Include(up => up.Planta)
                .ThenInclude(p => p.Cliente)
            .Select(up => new PlantaDto
            {
                Id = up.Planta.Id,
                Nome = up.Planta.Nome,
                Codigo = up.Planta.Codigo,
                ClienteId = up.Planta.ClienteId,
                ClienteNome = up.Planta.Cliente.Nome
            })
            .ToListAsync();

        // Buscar tema do cliente (primeira planta do usuário)
        TemaConfiguracaoDto? temaCliente = null;
        if (plantas.Any())
        {
            var primeiraPlanta = plantas.First();
            var cliente = await _context.Clientes
                .Include(c => c.Tema)
                .FirstOrDefaultAsync(c => c.Id == primeiraPlanta.ClienteId);

            if (cliente?.Tema != null)
            {
                var config = cliente.Tema.ObterConfiguracao();
                if (config != null)
                {
                    temaCliente = new TemaConfiguracaoDto
                    {
                        LogoPath = config.LogoPath,
                        CorPrimaria = config.CorPrimaria,
                        CorSecundaria = config.CorSecundaria,
                        CorTerciaria = config.CorTerciaria,
                        CorFundo = config.CorFundo,
                        CorTexto = config.CorTexto,
                        CoresCustomizadas = config.CoresCustomizadas,
                        EstilosCSS = config.EstilosCSS
                    };
                }
            }
        }

        // Buscar tema do usuário
        TemaConfiguracaoDto? temaUsuario = null;
        var temaUsuarioEntity = await _context.TemasUsuario
            .FirstOrDefaultAsync(t => t.UsuarioId == usuario.Id);

        if (temaUsuarioEntity != null)
        {
            var config = temaUsuarioEntity.ObterConfiguracao();
            if (config != null)
            {
                temaUsuario = new TemaConfiguracaoDto
                {
                    LogoPath = config.LogoPath,
                    CorPrimaria = config.CorPrimaria,
                    CorSecundaria = config.CorSecundaria,
                    CorTerciaria = config.CorTerciaria,
                    CorFundo = config.CorFundo,
                    CorTexto = config.CorTexto,
                    CoresCustomizadas = config.CoresCustomizadas,
                    EstilosCSS = config.EstilosCSS
                };
            }
        }

        // Gerar token
        var token = GerarToken(usuario.Id, usuario.Email, usuario.Perfil);

        return new LoginResponse
        {
            Token = token,
            UsuarioId = usuario.Id,
            Nome = usuario.Nome,
            Email = usuario.Email,
            Perfil = usuario.Perfil,
            Plantas = plantas,
            TemaCliente = temaCliente,
            TemaUsuario = temaUsuario
        };
    }

    public string GerarToken(Guid usuarioId, string email, string perfil)
    {
        var secretKey = _configuration["Jwt:SecretKey"] ?? "MinhaChaveSecretaSuperSeguraParaJWT2024!@#$%";
        var issuer = _configuration["Jwt:Issuer"] ?? "MotoresIO";
        var audience = _configuration["Jwt:Audience"] ?? "MotoresIO";
        var expirationMinutes = int.Parse(_configuration["Jwt:ExpirationMinutes"] ?? "1440"); // 24 horas padrão

        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, usuarioId.ToString()),
            new Claim(ClaimTypes.Email, email),
            new Claim(ClaimTypes.Role, perfil),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var token = new JwtSecurityToken(
            issuer: issuer,
            audience: audience,
            claims: claims,
            expires: DateTime.UtcNow.AddMinutes(expirationMinutes),
            signingCredentials: credentials
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}
