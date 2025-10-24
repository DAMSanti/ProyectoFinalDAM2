# Script para instalar SQL Server en Docker
# Guarda los datos en G:\SqlServerData

param(
    [string]$TargetDrive = "G:",
    [string]$SqlPassword = "Semicrol_10"
)

Write-Host ""
Write-Host "🗄️ INSTALACIÓN DE SQL SERVER EN DOCKER" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar Docker
Write-Host "🔍 Verificando Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "✅ Docker: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker no está instalado o no está corriendo" -ForegroundColor Red
    Write-Host ""
    Write-Host "Asegúrate de que Docker Desktop esté iniciado" -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Verificar que Docker está corriendo
Write-Host ""
Write-Host "🔍 Verificando que Docker está corriendo..." -ForegroundColor Yellow
try {
    docker ps | Out-Null
    Write-Host "✅ Docker está corriendo correctamente" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker no está corriendo" -ForegroundColor Red
    Write-Host ""
    Write-Host "Inicia Docker Desktop y espera a que esté completamente listo" -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host ""

# Crear carpeta para datos de SQL Server
$sqlDataPath = "$TargetDrive\SqlServerData"
Write-Host "📁 Creando carpeta para datos: $sqlDataPath" -ForegroundColor Yellow

if (-not (Test-Path $sqlDataPath)) {
    New-Item -ItemType Directory -Force -Path $sqlDataPath | Out-Null
    Write-Host "✅ Carpeta creada" -ForegroundColor Green
} else {
    Write-Host "✅ Carpeta ya existe" -ForegroundColor Green
}

Write-Host ""

# Verificar si ya existe un contenedor con el nombre 'sqlserver'
Write-Host "🔍 Verificando contenedor existente..." -ForegroundColor Yellow
$existingContainer = docker ps -a --filter "name=sqlserver" --format "{{.Names}}"

if ($existingContainer -eq "sqlserver") {
    Write-Host "⚠️  Ya existe un contenedor llamado 'sqlserver'" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Opciones:" -ForegroundColor Cyan
    Write-Host "  1) Eliminar el contenedor existente y crear uno nuevo" -ForegroundColor White
    Write-Host "  2) Iniciar el contenedor existente" -ForegroundColor White
    Write-Host "  3) Cancelar" -ForegroundColor White
    Write-Host ""
    
    $option = Read-Host "Selecciona una opción (1-3)"
    
    switch ($option) {
        "1" {
            Write-Host ""
            Write-Host "⚠️  Eliminando contenedor existente..." -ForegroundColor Yellow
            docker stop sqlserver 2>$null
            docker rm sqlserver 2>$null
            Write-Host "✅ Contenedor eliminado" -ForegroundColor Green
        }
        "2" {
            Write-Host ""
            Write-Host "🚀 Iniciando contenedor existente..." -ForegroundColor Cyan
            docker start sqlserver
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ SQL Server iniciado correctamente" -ForegroundColor Green
                Write-Host ""
                Write-Host "📋 INFORMACIÓN DE CONEXIÓN:" -ForegroundColor Cyan
                Write-Host "   Servidor: 127.0.0.1,1433" -ForegroundColor White
                Write-Host "   Usuario: sa" -ForegroundColor White
                Write-Host "   Contraseña: $SqlPassword" -ForegroundColor White
                Write-Host ""
                
                # Actualizar appsettings.json
                Write-Host "📝 Recuerda actualizar appsettings.json con:" -ForegroundColor Yellow
                Write-Host '   "Server=127.0.0.1,1433;Database=ACEXAPI;User Id=sa;Password=' + $SqlPassword + ';..."' -ForegroundColor Cyan
                Write-Host ""
                
                Read-Host "Presiona Enter para finalizar"
                exit 0
            } else {
                Write-Host "❌ Error al iniciar el contenedor" -ForegroundColor Red
                exit 1
            }
        }
        "3" {
            Write-Host "Operación cancelada" -ForegroundColor Yellow
            exit 0
        }
        default {
            Write-Host "Opción no válida" -ForegroundColor Red
            exit 1
        }
    }
}

Write-Host ""

# Descargar imagen de SQL Server
Write-Host "📦 Descargando imagen de SQL Server 2022..." -ForegroundColor Yellow
Write-Host "   (Primera vez: ~1.5 GB, puede tardar varios minutos)" -ForegroundColor Gray
Write-Host ""

docker pull mcr.microsoft.com/mssql/server:2022-latest

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Error al descargar la imagen de SQL Server" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host ""
Write-Host "✅ Imagen descargada correctamente" -ForegroundColor Green
Write-Host ""

# Crear y ejecutar contenedor de SQL Server
Write-Host "🚀 Creando y ejecutando contenedor de SQL Server..." -ForegroundColor Cyan
Write-Host ""
Write-Host "   Configuración:" -ForegroundColor Yellow
Write-Host "   • Nombre: sqlserver" -ForegroundColor White
Write-Host "   • Puerto: 1433" -ForegroundColor White
Write-Host "   • Contraseña SA: $SqlPassword" -ForegroundColor White
Write-Host "   • Datos en: $sqlDataPath" -ForegroundColor White
Write-Host "   • Edición: Express (gratis)" -ForegroundColor White
Write-Host "   • Reinicio automático: Sí" -ForegroundColor White
Write-Host ""

$volumePath = $sqlDataPath -replace '\\', '/'
$dockerCommand = "docker run -e `"ACCEPT_EULA=Y`" -e `"SA_PASSWORD=$SqlPassword`" -e `"MSSQL_PID=Express`" -p 1433:1433 --name sqlserver --restart always -v `"${volumePath}:/var/opt/mssql`" -d mcr.microsoft.com/mssql/server:2022-latest"

Write-Host "Ejecutando..." -ForegroundColor Gray
Invoke-Expression $dockerCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ ¡SQL Server creado e iniciado correctamente!" -ForegroundColor Green
    Write-Host ""
    
    # Esperar a que SQL Server inicie
    Write-Host "⏳ Esperando a que SQL Server inicie completamente..." -ForegroundColor Yellow
    Write-Host "   (Esto puede tardar 15-30 segundos)" -ForegroundColor Gray
    
    $maxAttempts = 30
    $attempt = 0
    $sqlReady = $false
    
    while ($attempt -lt $maxAttempts -and -not $sqlReady) {
        Start-Sleep -Seconds 2
        $attempt++
        Write-Host "." -NoNewline -ForegroundColor Gray
        
        $logs = docker logs sqlserver 2>&1 | Out-String
        if ($logs -match "SQL Server is now ready for client connections") {
            $sqlReady = $true
        }
    }
    
    Write-Host ""
    
    if ($sqlReady) {
        Write-Host ""
        Write-Host "✅ SQL Server está listo para recibir conexiones!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "⚠️  SQL Server todavía está iniciando. Espera un momento más." -ForegroundColor Yellow
    }
    
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "📋 INFORMACIÓN DE CONEXIÓN" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   Servidor: " -NoNewline -ForegroundColor White
    Write-Host "127.0.0.1,1433" -ForegroundColor Green
    Write-Host "   Usuario: " -NoNewline -ForegroundColor White
    Write-Host "sa" -ForegroundColor Green
    Write-Host "   Contraseña: " -NoNewline -ForegroundColor White
    Write-Host $SqlPassword -ForegroundColor Green
    Write-Host ""
    Write-Host "   Datos guardados en: $sqlDataPath" -ForegroundColor Gray
    Write-Host ""
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    
    # Probar conexión
    Write-Host "🧪 VERIFICACIÓN DE CONEXIÓN" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Probando conexión con sqlcmd..." -ForegroundColor Gray
    
    try {
        $testQuery = "SELECT @@VERSION"
        $result = sqlcmd -S "127.0.0.1,1433" -U sa -P $SqlPassword -Q $testQuery -h -1 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Conexión exitosa!" -ForegroundColor Green
            Write-Host ""
            Write-Host "Versión de SQL Server:" -ForegroundColor Cyan
            Write-Host $result -ForegroundColor White
        } else {
            Write-Host "⚠️  No se pudo conectar aún (SQL Server todavía está iniciando)" -ForegroundColor Yellow
            Write-Host "   Espera 30 segundos más y prueba con:" -ForegroundColor Gray
            Write-Host "   sqlcmd -S `"127.0.0.1,1433`" -U sa -P `"$SqlPassword`" -Q `"SELECT @@VERSION`"" -ForegroundColor Cyan
        }
    } catch {
        Write-Host "⚠️  sqlcmd no está instalado o no está en el PATH" -ForegroundColor Yellow
        Write-Host "   Puedes instalar SQL Server Command Line Tools desde:" -ForegroundColor Gray
        Write-Host "   https://aka.ms/ssmsfullsetup" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "📝 ACTUALIZAR CONFIGURACIÓN DEL PROYECTO" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Edita el archivo: ACEXAPI\appsettings.json" -ForegroundColor White
    Write-Host ""
    Write-Host "La conexión ya está configurada correctamente:" -ForegroundColor Green
    Write-Host ""
    Write-Host '  "ConnectionStrings": {' -ForegroundColor Cyan
    Write-Host '    "DefaultConnection": "Server=127.0.0.1,1433;Database=ACEXAPI;User Id=sa;Password=' + $SqlPassword + ';MultipleActiveResultSets=true;TrustServerCertificate=True;Encrypt=False"' -ForegroundColor Cyan
    Write-Host '  }' -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "🎯 SIGUIENTES PASOS" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Crear la base de datos ACEXAPI:" -ForegroundColor White
    Write-Host "   cd ACEXAPI" -ForegroundColor Cyan
    Write-Host "   dotnet ef database update" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "2. O ejecutar el script SQL:" -ForegroundColor White
    Write-Host "   sqlcmd -S `"127.0.0.1,1433`" -U sa -P `"$SqlPassword`" -i `"ACEXAPI\Scripts\CreateDatabase.sql`"" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3. Iniciar tu aplicación:" -ForegroundColor White
    Write-Host "   cd ACEXAPI" -ForegroundColor Cyan
    Write-Host "   dotnet run" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "🛠️  COMANDOS ÚTILES" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ver contenedores:" -ForegroundColor White
    Write-Host "  docker ps" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ver logs de SQL Server:" -ForegroundColor White
    Write-Host "  docker logs sqlserver" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Detener SQL Server:" -ForegroundColor White
    Write-Host "  docker stop sqlserver" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Iniciar SQL Server:" -ForegroundColor White
    Write-Host "  docker start sqlserver" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Reiniciar SQL Server:" -ForegroundColor White
    Write-Host "  docker restart sqlserver" -ForegroundColor Cyan
    Write-Host ""
    
} else {
    Write-Host ""
    Write-Host "❌ Error al crear el contenedor de SQL Server" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifica los logs con:" -ForegroundColor Yellow
    Write-Host "  docker logs sqlserver" -ForegroundColor Cyan
}

Write-Host ""
Read-Host "Presiona Enter para finalizar"
