# Script para iniciar la API en entorno CASA desde la raíz del proyecto
# Ejecutar: .\start-api-casa.ps1

Write-Host ""
Write-Host "================================================" -ForegroundColor Green
Write-Host "  INICIANDO API - ENTORNO CASA" -ForegroundColor Green
Write-Host "================================================" -ForegroundColor Green
Write-Host ""

# Navegar al directorio de la API
$apiPath = Join-Path $PSScriptRoot "ACEXAPI"
Set-Location $apiPath

Write-Host "Configuración:" -ForegroundColor Yellow
Write-Host "  Entorno: Casa" -ForegroundColor White
Write-Host "  Servidor: localhost\SQLEXPRESS" -ForegroundColor White
Write-Host "  Base de datos: ACEXAPI" -ForegroundColor White
Write-Host "  Puerto: 5000" -ForegroundColor White
Write-Host ""

# Verificar SQL Server
Write-Host "Verificando SQL Server..." -ForegroundColor Yellow
try {
    $sqlTest = sqlcmd -S "localhost\SQLEXPRESS" -U sa -P "Semicrol_10" -Q "SELECT 1" -h -1 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "[OK] SQL Server OK" -ForegroundColor Green
    } else {
        Write-Host "[ERROR] SQL Server no esta respondiendo" -ForegroundColor Red
        Write-Host ""
        Write-Host "Intenta iniciar el servicio con:" -ForegroundColor Yellow
        Write-Host "  net start MSSQL`$SQLEXPRESS" -ForegroundColor White
        Write-Host ""
        Read-Host "Presiona Enter para salir"
        exit 1
    }
} catch {
    Write-Host "[ERROR] Error al conectar con SQL Server" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
    Write-Host ""
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host ""
Write-Host "Iniciando API..." -ForegroundColor Cyan
Write-Host ""

# Ejecutar con el perfil específico de Casa
dotnet run --launch-profile Casa

Write-Host ""
Write-Host "API detenida" -ForegroundColor Yellow
