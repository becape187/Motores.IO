using System.Text;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Motores.IO.server.API.Authentication;
using Motores.IO.server.API.Data;
using Motores.IO.server.API.Services;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();

// Configurar Swagger com suporte a JWT
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "Motores.IO API", Version = "v1" });
    
    // Adicionar suporte a JWT no Swagger
    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header usando o esquema Bearer. Exemplo: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });
    
    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

// Configurar Entity Framework com PostgreSQL
var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseNpgsql(connectionString));

// Configurar ForwardedHeaders para funcionar com nginx
builder.Services.Configure<ForwardedHeadersOptions>(options =>
{
    options.ForwardedHeaders = ForwardedHeaders.XForwardedFor | 
                               ForwardedHeaders.XForwardedProto | 
                               ForwardedHeaders.XForwardedHost;
    options.KnownNetworks.Clear();
    options.KnownProxies.Clear();
});

// Configurar CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
              .AllowAnyMethod()
              .AllowAnyHeader();
    });
});

// Registrar serviços
builder.Services.AddScoped<IAuthService, AuthService>();

// Registrar Socket Server Service
// Registra como Singleton para ISocketServerService e como HostedService para BackgroundService
builder.Services.AddSingleton<SocketServerService>();
builder.Services.AddSingleton<ISocketServerService>(provider => 
    provider.GetRequiredService<SocketServerService>());
builder.Services.AddHostedService(provider => 
    provider.GetRequiredService<SocketServerService>());

// Registrar WebSocket Hub
builder.Services.AddSingleton<IWebSocketHub, WebSocketHub>();

// Configurar JWT Authentication
var jwtSecretKey = builder.Configuration["Jwt:SecretKey"] ?? "MinhaChaveSecretaSuperSeguraParaJWT2024!@#$%";
var jwtIssuer = builder.Configuration["Jwt:Issuer"] ?? "MotoresIO";
var jwtAudience = builder.Configuration["Jwt:Audience"] ?? "MotoresIO";

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = "JWT_OR_PLANTA_TOKEN";
    options.DefaultChallengeScheme = "JWT_OR_PLANTA_TOKEN";
})
.AddJwtBearer("JWT", options =>
{
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidateLifetime = true,
        ValidateIssuerSigningKey = true,
        ValidIssuer = jwtIssuer,
        ValidAudience = jwtAudience,
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtSecretKey)),
        ClockSkew = TimeSpan.Zero
    };
})
.AddScheme<Microsoft.AspNetCore.Authentication.AuthenticationSchemeOptions, PlantaTokenAuthenticationHandler>("PlantaToken", null)
.AddPolicyScheme("JWT_OR_PLANTA_TOKEN", "JWT_OR_PLANTA_TOKEN", options =>
{
    options.ForwardDefaultSelector = context =>
    {
        string? authorization = context.Request.Headers.Authorization;
        if (!string.IsNullOrEmpty(authorization) && authorization.StartsWith("Bearer "))
        {
            var token = authorization.Substring("Bearer ".Length).Trim();
            // Se o token parece ser um JWT (contém pontos), tenta JWT primeiro
            // Caso contrário, tenta PlantaToken
            if (token.Contains('.'))
            {
                return "JWT";
            }
            return "PlantaToken";
        }
        return "JWT";
    };
});

builder.Services.AddAuthorization();

var app = builder.Build();

// Usar ForwardedHeaders antes de outros middlewares
app.UseForwardedHeaders();

// Configure the HTTP request pipeline.
// Swagger disponível em todos os ambientes
app.UseSwagger();
app.UseSwaggerUI(c =>
{
    c.SwaggerEndpoint("/swagger/v1/swagger.json", "Motores.IO API V1");
    c.RoutePrefix = "swagger";
});

if (app.Environment.IsDevelopment())
{
    app.UseHttpsRedirection();
}

app.UseCors("AllowAll");
app.UseAuthentication();
app.UseAuthorization();
app.MapControllers();

// Aplicar migrations automaticamente (apenas para desenvolvimento)
if (app.Environment.IsDevelopment())
{
    using (var scope = app.Services.CreateScope())
    {
        var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        dbContext.Database.Migrate();
    }
}

app.Run();
