using System.Text;
using ACEXAPI.Data;
using ACEXAPI.Middleware;
using ACEXAPI.ModelBinders;
using ACEXAPI.Services;
using Azure.Storage.Blobs;
using FluentValidation;
using FluentValidation.AspNetCore;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Builder;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Microsoft.Extensions.FileProviders;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers(options =>
{
    // Agregar el model binder personalizado para decimales
    // Esto asegura que los decimales siempre se parseen con InvariantCulture (punto como decimal)
    // independientemente de la configuración regional del servidor
    options.ModelBinderProviders.Insert(0, new DecimalModelBinderProvider());
})
    .AddJsonOptions(options =>
    {
        // Configurar UTF-8 para caracteres especiales (tildes, ñ, etc.)
        options.JsonSerializerOptions.Encoder = System.Text.Encodings.Web.JavaScriptEncoder.UnsafeRelaxedJsonEscaping;
    });
builder.Services.AddEndpointsApiExplorer();

// Swagger con soporte para JWT
builder.Services.AddSwaggerGen(options =>
{
    options.SwaggerDoc("v1", new OpenApiInfo
    {
        Title = "ACEX API - Gesti�n de Actividades Extraescolares",
        Version = "v1",
        Description = "API para la gesti�n de actividades extraescolares del centro educativo",
        Contact = new OpenApiContact
        {
            Name = "Equipo A1DAM",
            Email = "contacto@acexapi.com"
        }
    });

    options.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Description = "JWT Authorization header usando el esquema Bearer. Ejemplo: \"Authorization: Bearer {token}\"",
        Name = "Authorization",
        In = ParameterLocation.Header,
        Type = SecuritySchemeType.ApiKey,
        Scheme = "Bearer"
    });

    options.AddSecurityRequirement(new OpenApiSecurityRequirement
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

    // Incluir comentarios XML si existen
    var xmlFile = $"{System.Reflection.Assembly.GetExecutingAssembly().GetName().Name}.xml";
    var xmlPath = Path.Combine(AppContext.BaseDirectory, xmlFile);
    if (File.Exists(xmlPath))
    {
        options.IncludeXmlComments(xmlPath);
    }
});

// Database
var dbConnectionString = builder.Configuration.GetConnectionString("DefaultConnection");
Console.WriteLine($"============================================");
Console.WriteLine($"ENTORNO: {builder.Environment.EnvironmentName}");
Console.WriteLine($"CONNECTION STRING: {dbConnectionString}");
Console.WriteLine($"============================================");

builder.Services.AddDbContext<ApplicationDbContext>(options =>
    options.UseSqlServer(dbConnectionString));

// Registrar el servicio de notificaciones (debe estar DESPUÉS del DbContext)
builder.Services.AddScoped<INotificationService, NotificationService>();

// JWT Authentication
var jwtKey = builder.Configuration["Jwt:Key"]!;
var key = Encoding.UTF8.GetBytes(jwtKey);

builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.RequireHttpsMetadata = false; // En producci�n debe ser true
    options.SaveToken = true;
    options.TokenValidationParameters = new TokenValidationParameters
    {
        ValidateIssuerSigningKey = true,
        IssuerSigningKey = new SymmetricSecurityKey(key),
        ValidateIssuer = true,
        ValidIssuer = builder.Configuration["Jwt:Issuer"],
        ValidateAudience = true,
        ValidAudience = builder.Configuration["Jwt:Audience"],
        ValidateLifetime = true,
        ClockSkew = TimeSpan.Zero
    };
});

builder.Services.AddAuthorization();

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowFlutterApp", policy =>
    {
        var allowedOrigins = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>() ?? new[] { "*" };
        
        if (builder.Environment.IsDevelopment() || 
            builder.Environment.EnvironmentName == "Trabajo" || 
            builder.Environment.EnvironmentName == "Casa")
        {
            // En desarrollo, trabajo y casa, permitir cualquier origen para facilitar testing
            policy.AllowAnyOrigin()
                  .AllowAnyMethod()
                  .AllowAnyHeader();
        }
        else
        {
            // En producción real, usar orígenes específicos
            policy.WithOrigins(allowedOrigins)
                  .AllowAnyMethod()
                  .AllowAnyHeader()
                  .AllowCredentials();
        }
    });
});

// Memory Cache
builder.Services.AddMemoryCache();
builder.Services.AddResponseCaching();

// File Storage Service
if (builder.Configuration.GetValue<bool>("Azure:BlobStorage:Enabled"))
{
    var connectionString = builder.Configuration["Azure:BlobStorage:ConnectionString"];
    builder.Services.AddSingleton(x => new BlobServiceClient(connectionString));
    builder.Services.AddScoped<IFileStorageService, AzureBlobStorageService>();
}
else
{
    builder.Services.AddScoped<IFileStorageService, LocalFileStorageService>();
}

// Application Services
builder.Services.AddScoped<IJwtService, JwtService>();
builder.Services.AddScoped<IPasswordService, PasswordService>();
builder.Services.AddScoped<IActividadService, ActividadService>();

// FluentValidation
builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddValidatorsFromAssemblyContaining<Program>();

// HTTP Client para notificaciones push (futuro)
builder.Services.AddHttpClient();

var app = builder.Build();

// Configure the HTTP request pipeline.

// Middleware de manejo de errores global
app.UseErrorHandling();

// Habilitar Swagger en Development, Trabajo y Casa (no en Production real)
if (app.Environment.IsDevelopment() || 
    app.Environment.EnvironmentName == "Trabajo" || 
    app.Environment.EnvironmentName == "Casa")
{
    app.UseSwagger();
    app.UseSwaggerUI(c =>
    {
        c.SwaggerEndpoint("/swagger/v1/swagger.json", "ACEX API v1");
        c.RoutePrefix = string.Empty; // Swagger en la raíz
    });
}

// Solo redirigir a HTTPS si estamos en un entorno con HTTPS configurado
if (app.Environment.IsProduction() && app.Environment.EnvironmentName != "Casa" && app.Environment.EnvironmentName != "Trabajo")
{
    app.UseHttpsRedirection();
}

// CORS debe ir ANTES de UseStaticFiles para que funcione con las imágenes
app.UseCors("AllowFlutterApp");

// Servir archivos estáticos desde wwwroot (por defecto)
app.UseStaticFiles();

// Servir archivos estáticos desde la carpeta wwwroot/uploads con ruta /uploads
var uploadsPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "uploads");
if (!Directory.Exists(uploadsPath))
{
    Directory.CreateDirectory(uploadsPath);
}

app.UseStaticFiles(new Microsoft.AspNetCore.Builder.StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(uploadsPath),
    RequestPath = "/uploads",
    OnPrepareResponse = ctx =>
    {
        // Agregar headers CORS manualmente para archivos estáticos
        ctx.Context.Response.Headers.Append("Access-Control-Allow-Origin", "*");
        ctx.Context.Response.Headers.Append("Access-Control-Allow-Methods", "GET");
        ctx.Context.Response.Headers.Append("Access-Control-Allow-Headers", "Content-Type");
    }
});

// Servir archivos de chat desde wwwroot/chat_media con ruta /chat_media
var chatMediaPath = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot", "chat_media");
if (!Directory.Exists(chatMediaPath))
{
    Directory.CreateDirectory(chatMediaPath);
}

app.UseStaticFiles(new StaticFileOptions
{
    FileProvider = new PhysicalFileProvider(chatMediaPath),
    RequestPath = "/chat_media",
    OnPrepareResponse = ctx =>
    {
        // Agregar headers CORS manualmente para archivos de chat
        ctx.Context.Response.Headers.Append("Access-Control-Allow-Origin", "*");
        ctx.Context.Response.Headers.Append("Access-Control-Allow-Methods", "GET");
        ctx.Context.Response.Headers.Append("Access-Control-Allow-Headers", "Content-Type");
        // Cache de 1 hora para multimedia
        ctx.Context.Response.Headers.Append("Cache-Control", "public, max-age=3600");
    }
});

app.UseAuthentication();
app.UseAuthorization();

app.UseResponseCaching();

app.MapControllers();

// Crear base de datos si no existe (Development, Trabajo, Casa)
// Comentado porque las tablas ya están creadas
// Descomentar solo si necesitas recrear la base de datos
/*
if (app.Environment.IsDevelopment() || 
    app.Environment.EnvironmentName == "Trabajo" || 
    app.Environment.EnvironmentName == "Casa")
{
    using var scope = app.Services.CreateScope();
    var context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
    await context.Database.EnsureCreatedAsync();
}
*/

app.Run();
