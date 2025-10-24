# Script para iniciar la API en entorno CASA
# Ejecutar desde PowerShell

Write-Host ""
Write-Host "INICIANDO API - ENTORNO CASA" -ForegroundColor Green
Write-Host "=============================" -ForegroundColor Green
Write-Host ""

$apiPath = "G:\ProyectoFinalCSharp\ProyectoFinalDAM2\ACEXAPI"

Write-Host "Configuracion:" -ForegroundColor Yellow
Write-Host "  Servidor: localhost\SQLEXPRESS" -ForegroundColor White
Write-Host "  Base de datos: ACEXAPI" -ForegroundColor White
Write-Host ""

Set-Location $apiPath

# Verificar SQL Server
Write-Host "Verificando SQL Server..." -ForegroundColor Yellow
try {
    $sqlTest = sqlcmd -S "localhost\SQLEXPRESS" -U sa -P "Semicrol_10" -Q "SELECT 1" -h -1 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SQL Server OK" -ForegroundColor Green
    } else {
        Write-Host "Error: SQL Server no esta respondiendo" -ForegroundColor Red
        Read-Host "Presiona Enter para salir"
        exit 1
    }
} catch {
    Write-Host "Error al conectar con SQL Server" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host ""
Write-Host "Iniciando API..." -ForegroundColor Cyan
Write-Host ""

# Iniciar la API con el entorno Casa
$env:ASPNETCORE_ENVIRONMENT = "Casa"
dotnet run
