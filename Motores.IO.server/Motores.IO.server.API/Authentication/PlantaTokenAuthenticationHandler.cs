using System.Security.Claims;
using System.Text.Encodings.Web;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using Motores.IO.server.API.Data;

namespace Motores.IO.server.API.Authentication;

public class PlantaTokenAuthenticationHandler : AuthenticationHandler<AuthenticationSchemeOptions>
{
    private readonly ApplicationDbContext _context;

    public PlantaTokenAuthenticationHandler(
        IOptionsMonitor<AuthenticationSchemeOptions> options,
        ILoggerFactory logger,
        UrlEncoder encoder,
        ApplicationDbContext context)
        : base(options, logger, encoder)
    {
        _context = context;
    }

    protected override async Task<AuthenticateResult> HandleAuthenticateAsync()
    {
        // Verificar se o header Authorization está presente
        if (!Request.Headers.ContainsKey("Authorization"))
        {
            return AuthenticateResult.NoResult();
        }

        var authHeader = Request.Headers["Authorization"].ToString();
        
        // Verificar se começa com "Bearer "
        if (!authHeader.StartsWith("Bearer ", StringComparison.OrdinalIgnoreCase))
        {
            return AuthenticateResult.NoResult();
        }

        var token = authHeader.Substring("Bearer ".Length).Trim();

        // Se o token estiver vazio, não é um token de planta
        if (string.IsNullOrWhiteSpace(token))
        {
            return AuthenticateResult.NoResult();
        }

        // Buscar todas as plantas ativas e verificar o token usando BCrypt
        var plantas = await _context.Plantas
            .Where(p => p.Ativo && !string.IsNullOrEmpty(p.ApiToken))
            .ToListAsync();

        Models.Planta? planta = null;
        foreach (var p in plantas)
        {
            // Verificar se o token corresponde ao hash armazenado
            try
            {
                if (BCrypt.Net.BCrypt.Verify(token, p.ApiToken!))
                {
                    planta = p;
                    break;
                }
            }
            catch
            {
                // Se houver erro na verificação (token antigo em texto plano), tentar comparação direta
                // Isso permite migração gradual de tokens antigos
                if (p.ApiToken == token)
                {
                    // Migrar token antigo para hash (apenas se ainda estiver em texto plano)
                    p.ApiToken = BCrypt.Net.BCrypt.HashPassword(token);
                    await _context.SaveChangesAsync();
                    planta = p;
                    break;
                }
            }
        }

        if (planta == null)
        {
            return AuthenticateResult.NoResult();
        }

        // Criar claims para a planta
        var claims = new[]
        {
            new Claim(ClaimTypes.NameIdentifier, planta.Id.ToString()),
            new Claim("PlantaId", planta.Id.ToString()),
            new Claim("PlantaNome", planta.Nome),
            new Claim(ClaimTypes.Role, "Planta"),
            new Claim("AuthType", "PlantaToken")
        };

        var identity = new ClaimsIdentity(claims, Scheme.Name);
        var principal = new ClaimsPrincipal(identity);
        var ticket = new AuthenticationTicket(principal, Scheme.Name);

        return AuthenticateResult.Success(ticket);
    }
}
