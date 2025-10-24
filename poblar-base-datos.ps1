# Script para poblar la base de datos ACEXAPI con datos de ejemplo
# Ejecutar desde PowerShell

Write-Host ""
Write-Host "POBLAR BASE DE DATOS ACEXAPI" -ForegroundColor Cyan
Write-Host "=============================" -ForegroundColor Cyan
Write-Host ""

$scriptPath = "G:\ProyectoFinalCSharp\ProyectoFinalDAM2\DB\PoblarBaseDatosSimple.sql"
$servidor = "localhost\SQLEXPRESS"
$usuario = "sa"
$password = "Semicrol_10"

# Verificar que existe el archivo SQL
if (-Not (Test-Path $scriptPath)) {
    Write-Host "ERROR: No se encuentra el archivo PoblarBaseDatos.sql" -ForegroundColor Red
    Write-Host "Ruta esperada: $scriptPath" -ForegroundColor Yellow
    Read-Host "Presiona Enter para cerrar"
    exit 1
}

Write-Host "Verificando conexión a SQL Server..." -ForegroundColor Yellow

# Verificar conexión
try {
    $testConnection = sqlcmd -S $servidor -U $usuario -P $password -Q "SELECT 1" -h -1 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: No se puede conectar a SQL Server" -ForegroundColor Red
        Write-Host "Verifica que SQL Server esté ejecutándose" -ForegroundColor Yellow
        Read-Host "Presiona Enter para cerrar"
        exit 1
    }
    Write-Host "✓ Conexión exitosa" -ForegroundColor Green
} catch {
    Write-Host "ERROR: No se puede conectar a SQL Server" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
    Read-Host "Presiona Enter para cerrar"
    exit 1
}

Write-Host ""
Write-Host "Ejecutando script de población..." -ForegroundColor Yellow
Write-Host ""

# Ejecutar el script SQL
try {
    sqlcmd -S $servidor -U $usuario -P $password -i $scriptPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✓ BASE DE DATOS POBLADA EXITOSAMENTE!" -ForegroundColor Green
        Write-Host ""
        Write-Host "Datos insertados:" -ForegroundColor Cyan
        Write-Host "  - Departamentos" -ForegroundColor White
        Write-Host "  - Cursos y Grupos" -ForegroundColor White
        Write-Host "  - Profesores" -ForegroundColor White
        Write-Host "  - Localizaciones" -ForegroundColor White
        Write-Host "  - Empresas de Transporte" -ForegroundColor White
        Write-Host "  - Actividades (futuras, pasadas y pendientes)" -ForegroundColor White
        Write-Host "  - Grupos participantes" -ForegroundColor White
        Write-Host "  - Profesores responsables y participantes" -ForegroundColor White
        Write-Host "  - Contratos de transporte" -ForegroundColor White
        Write-Host ""
        Write-Host "Ahora puedes iniciar la aplicación y ver las actividades." -ForegroundColor Yellow
    } else {
        Write-Host ""
        Write-Host "ERROR: Hubo un problema al ejecutar el script" -ForegroundColor Red
    }
} catch {
    Write-Host "ERROR: Excepción al ejecutar el script" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Presiona Enter para cerrar"
