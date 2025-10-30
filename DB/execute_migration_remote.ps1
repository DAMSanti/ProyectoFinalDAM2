# Script para ejecutar migraciones en la base de datos remota de DigitalOcean
# Uso: .\execute_migration_remote.ps1 -MigrationFile "migration_add_descripcion_tipo_localizacion.sql"

param(
    [Parameter(Mandatory=$true)]
    [string]$MigrationFile,
    
    [string]$Server = "64.226.85.100,1433",
    [string]$Database = "ACEXAPI",
    [string]$Username = "SA",
    [string]$Password = "Semicrol_10!"
)

Write-Host ""
Write-Host "================================================" -ForegroundColor Blue
Write-Host "  EJECUTAR MIGRACION EN BASE DE DATOS REMOTA" -ForegroundColor Blue
Write-Host "================================================" -ForegroundColor Blue
Write-Host ""

# Verificar que el archivo de migración existe
$scriptPath = Join-Path $PSScriptRoot $MigrationFile
if (-not (Test-Path $scriptPath)) {
    Write-Host "ERROR: No se encontró el archivo: $scriptPath" -ForegroundColor Red
    exit 1
}

Write-Host "Servidor: $Server" -ForegroundColor Yellow
Write-Host "Base de datos: $Database" -ForegroundColor Yellow
Write-Host "Archivo: $MigrationFile" -ForegroundColor Yellow
Write-Host ""

$continuar = Read-Host "¿Deseas ejecutar esta migración? (S/N)"
if ($continuar -ne "S" -and $continuar -ne "s") {
    Write-Host "Operación cancelada" -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "Ejecutando migración..." -ForegroundColor Cyan
Write-Host ""

# Construir el comando sqlcmd
# Nota: Necesitas tener instalado sqlcmd en tu sistema
# Descarga: https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility

try {
    # Verificar si sqlcmd está instalado
    $sqlcmdPath = Get-Command sqlcmd -ErrorAction SilentlyContinue
    
    if (-not $sqlcmdPath) {
        Write-Host "ERROR: sqlcmd no está instalado en tu sistema" -ForegroundColor Red
        Write-Host ""
        Write-Host "Opciones:" -ForegroundColor Yellow
        Write-Host "1. Instalar SQL Server Command Line Tools desde:" -ForegroundColor White
        Write-Host "   https://learn.microsoft.com/en-us/sql/tools/sqlcmd/sqlcmd-utility" -ForegroundColor White
        Write-Host ""
        Write-Host "2. O ejecutar el script manualmente conectándote al servidor con:" -ForegroundColor White
        Write-Host "   - SQL Server Management Studio (SSMS)" -ForegroundColor White
        Write-Host "   - Azure Data Studio" -ForegroundColor White
        Write-Host "   - DBeaver" -ForegroundColor White
        exit 1
    }
    
    # Ejecutar el script
    sqlcmd -S $Server -d $Database -U $Username -P $Password -i $scriptPath -C
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ Migración ejecutada exitosamente" -ForegroundColor Green
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "❌ Error al ejecutar la migración (código: $LASTEXITCODE)" -ForegroundColor Red
        Write-Host ""
        exit $LASTEXITCODE
    }
    
} catch {
    Write-Host ""
    Write-Host "❌ Error: $_" -ForegroundColor Red
    Write-Host ""
    exit 1
}

Write-Host "Presiona Enter para salir..."
Read-Host
