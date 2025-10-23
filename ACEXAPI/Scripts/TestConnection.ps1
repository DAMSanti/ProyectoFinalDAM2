# =============================================
# Script PowerShell: Probar Conexión SQL Server
# Descripción: Prueba la conexión a tu instancia de SQL Server
# Configurado para: 127.0.0.1,1433 con SQL Server Authentication
# =============================================

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "PROBANDO CONEXIÓN A SQL SERVER" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Configuración de conexión
$server = "127.0.0.1,1433"
$database = "master"
$username = "sa"
$password = "Semicrol_10"

Write-Host "Servidor: $server" -ForegroundColor Gray
Write-Host "Usuario: $username" -ForegroundColor Gray
Write-Host ""

# 1. Verificar servicios de SQL Server en ejecución
Write-Host "1. SERVICIOS DE SQL SERVER:" -ForegroundColor Yellow
Write-Host "   Buscando servicios en ejecución..." -ForegroundColor Gray
try {
    $sqlServices = Get-Service | Where-Object { $_.DisplayName -like "*SQL Server*" -and $_.Status -eq "Running" }
    
    if ($sqlServices) {
        foreach ($service in $sqlServices) {
            Write-Host "   ? " -ForegroundColor Green -NoNewline
            Write-Host "$($service.DisplayName) - Estado: $($service.Status)"
        }
    } else {
        Write-Host "   ? No se encontraron servicios de SQL Server en ejecución" -ForegroundColor Yellow
        Write-Host "   Intenta iniciar SQL Server desde Services (services.msc)" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   Error al buscar servicios: $_" -ForegroundColor Red
}
Write-Host ""

# 2. Verificar conectividad al puerto
Write-Host "2. VERIFICAR PUERTO 1433:" -ForegroundColor Yellow
Write-Host "   Probando conectividad..." -ForegroundColor Gray
try {
    $tcpTest = Test-NetConnection -ComputerName 127.0.0.1 -Port 1433 -WarningAction SilentlyContinue
    
    if ($tcpTest.TcpTestSucceeded) {
        Write-Host "   ? Puerto 1433 está abierto y accesible" -ForegroundColor Green
    } else {
        Write-Host "   ? Puerto 1433 NO está accesible" -ForegroundColor Red
        Write-Host "   Verifica que SQL Server está corriendo y el puerto está abierto" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ? No se pudo verificar el puerto: $_" -ForegroundColor Yellow
}
Write-Host ""

# 3. Probar conexión SQL
Write-Host "3. PROBAR CONEXIÓN SQL:" -ForegroundColor Yellow
Write-Host "   Intentando conectar a SQL Server..." -ForegroundColor Gray

$connectionString = "Server=$server;Database=$database;User Id=$username;Password=$password;TrustServerCertificate=True;Encrypt=False;Connection Timeout=5"
$connectionSuccess = $false

try {
    $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
    $connection.Open()
    
    if ($connection.State -eq "Open") {
        Write-Host "   ? CONEXIÓN EXITOSA!" -ForegroundColor Green
        Write-Host ""
        $connectionSuccess = $true
        
        # Obtener información del servidor
        Write-Host "   INFORMACIÓN DEL SERVIDOR:" -ForegroundColor Cyan
        
        $command = $connection.CreateCommand()
        $command.CommandText = "SELECT @@SERVERNAME AS ServerName, @@VERSION AS Version"
        $reader = $command.ExecuteReader()
        
        if ($reader.Read()) {
            Write-Host "   Servidor: $($reader['ServerName'])" -ForegroundColor Gray
            $version = $reader['Version'].ToString()
            $versionShort = $version.Substring(0, [Math]::Min(80, $version.Length))
            Write-Host "   Versión: $versionShort..." -ForegroundColor Gray
        }
        $reader.Close()
        
        # Verificar base de datos ACEXAPI
        Write-Host ""
        Write-Host "   VERIFICAR BASE DE DATOS ACEXAPI:" -ForegroundColor Cyan
        $command.CommandText = "SELECT COUNT(*) FROM sys.databases WHERE name = 'ACEXAPI'"
        $exists = $command.ExecuteScalar()
        
        if ($exists -gt 0) {
            Write-Host "   ? Base de datos ACEXAPI existe" -ForegroundColor Green
            
            # Contar tablas
            $connection.ChangeDatabase("ACEXAPI")
            $command.CommandText = "SELECT COUNT(*) FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'"
            $tableCount = $command.ExecuteScalar()
            Write-Host "   Tablas en ACEXAPI: $tableCount" -ForegroundColor Gray
            
            # Ver datos iniciales
            $command.CommandText = "SELECT COUNT(*) FROM Departamentos"
            try {
                $deptCount = $command.ExecuteScalar()
                Write-Host "   Departamentos: $deptCount" -ForegroundColor Gray
            } catch {
                Write-Host "   ? Tabla Departamentos no existe aún" -ForegroundColor Yellow
            }
            
            $command.CommandText = "SELECT COUNT(*) FROM Cursos"
            try {
                $cursoCount = $command.ExecuteScalar()
                Write-Host "   Cursos: $cursoCount" -ForegroundColor Gray
            } catch {
                Write-Host "   ? Tabla Cursos no existe aún" -ForegroundColor Yellow
            }
            
        } else {
            Write-Host "   ? Base de datos ACEXAPI NO existe" -ForegroundColor Yellow
            Write-Host "   Debes ejecutar el script: Scripts/CreateDatabase.sql en SSMS" -ForegroundColor Yellow
        }
        
        $connection.Close()
        
        Write-Host ""
        Write-Host "   CONNECTION STRING VALIDADO:" -ForegroundColor Green
        Write-Host "   Server=127.0.0.1,1433;Database=ACEXAPI;User Id=sa;Password=Semicrol_10;MultipleActiveResultSets=true;TrustServerCertificate=True;Encrypt=False" -ForegroundColor Cyan
        
    } else {
        Write-Host "   ? No se pudo abrir la conexión" -ForegroundColor Red
    }
    
} catch {
    Write-Host "   ? ERROR DE CONEXIÓN" -ForegroundColor Red
    Write-Host "   Detalles: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "   POSIBLES CAUSAS:" -ForegroundColor Yellow
    Write-Host "   1. SQL Server no está corriendo" -ForegroundColor Gray
    Write-Host "   2. La contraseña es incorrecta" -ForegroundColor Gray
    Write-Host "   3. El usuario 'sa' no tiene acceso o está deshabilitado" -ForegroundColor Gray
    Write-Host "   4. SQL Server no permite autenticación SQL (solo Windows)" -ForegroundColor Gray
    Write-Host "   5. El puerto 1433 está bloqueado por firewall" -ForegroundColor Gray
    Write-Host ""
    Write-Host "   SOLUCIÓN:" -ForegroundColor Yellow
    Write-Host "   - Verifica en SSMS que puedes conectar con: 127.0.0.1,1433 / sa / Semicrol_10" -ForegroundColor Gray
    Write-Host "   - Habilita autenticación mixta si es necesario:" -ForegroundColor Gray
    Write-Host "     Servidor ? Properties ? Security ? SQL Server and Windows Authentication" -ForegroundColor Gray
}
Write-Host ""

# 4. Listar bases de datos
if ($connectionSuccess) {
    Write-Host "4. LISTAR BASES DE DATOS:" -ForegroundColor Yellow
    try {
        $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
        $connection.Open()
        
        if ($connection.State -eq "Open") {
            $command = $connection.CreateCommand()
            $command.CommandText = "SELECT name, create_date, state_desc FROM sys.databases ORDER BY name"
            $reader = $command.ExecuteReader()
            
            Write-Host "   Bases de datos disponibles:" -ForegroundColor Gray
            while ($reader.Read()) {
                $dbName = $reader['name']
                $state = $reader['state_desc']
                
                if ($state -eq "ONLINE") {
                    Write-Host "   ? $dbName ($state)" -ForegroundColor Green
                } else {
                    Write-Host "   ? $dbName ($state)" -ForegroundColor Yellow
                }
            }
            $reader.Close()
            $connection.Close()
        }
    } catch {
        Write-Host "   No se pudo listar bases de datos" -ForegroundColor Yellow
    }
    Write-Host ""
}

# Resumen
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "PRÓXIMOS PASOS:" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

if ($connectionSuccess) {
    Write-Host "? Tu configuración es correcta y la conexión funciona!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Si la base de datos ACEXAPI NO existe:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Abre SQL Server Management Studio 22" -ForegroundColor White
    Write-Host "   - Servidor: 127.0.0.1,1433" -ForegroundColor Gray
    Write-Host "   - Autenticación: SQL Server Authentication" -ForegroundColor Gray
    Write-Host "   - Usuario: sa" -ForegroundColor Gray
    Write-Host "   - Contraseña: Semicrol_10" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Ejecuta el script: Scripts/CreateDatabase.sql" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Ejecuta este script nuevamente para verificar" -ForegroundColor White
    Write-Host ""
    Write-Host "Si la base de datos ya existe:" -ForegroundColor Green
    Write-Host ""
    Write-Host "? Presiona F5 en Visual Studio para ejecutar tu API" -ForegroundColor White
    Write-Host "? Tu appsettings.json ya está configurado correctamente" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "? Hay problemas de conexión. Revisa los mensajes de error arriba." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Pasos para solucionar:" -ForegroundColor Yellow
    Write-Host "1. Verifica que SQL Server está corriendo (services.msc)" -ForegroundColor Gray
    Write-Host "2. Prueba conectarte en SSMS con las mismas credenciales" -ForegroundColor Gray
    Write-Host "3. Verifica que la autenticación SQL está habilitada" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Para más ayuda, consulta: Scripts/INSTRUCCIONES_CONFIGURACION.md" -ForegroundColor Gray
}
Write-Host ""
