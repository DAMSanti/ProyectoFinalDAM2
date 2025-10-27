# Script para iniciar la API en entorno TRABAJO desde la raíz del proyecto
# Ejecutar: .\start-api-trabajo.ps1

Write-Host ""
Write-Host "================================================" -ForegroundColor Blue
Write-Host "  INICIANDO API - ENTORNO TRABAJO" -ForegroundColor Blue
Write-Host "================================================" -ForegroundColor Blue
Write-Host ""

# Navegar al directorio de la API
$apiPath = Join-Path $PSScriptRoot "ACEXAPI"
Set-Location $apiPath

Write-Host "IMPORTANTE: Verifica que appsettings.Trabajo.json tenga tu configuración" -ForegroundColor Yellow
Write-Host ""
Write-Host "Configuración:" -ForegroundColor Yellow
Write-Host "  Entorno: Trabajo" -ForegroundColor White
Write-Host "  Archivo: appsettings.Trabajo.json" -ForegroundColor White
Write-Host "  Puerto: 5000" -ForegroundColor White
Write-Host ""

$continuar = Read-Host "¿Continuar? (S/N)"
if ($continuar -ne "S" -and $continuar -ne "s") {
    Write-Host "Cancelado" -ForegroundColor Red
    exit 0
}

Write-Host ""
Write-Host "Iniciando API..." -ForegroundColor Cyan
Write-Host ""

# Establecer variable de entorno y ejecutar
$env:ASPNETCORE_ENVIRONMENT = "Trabajo"
dotnet run

Write-Host ""
Write-Host "API detenida" -ForegroundColor Yellow
