# Script para iniciar la API en entorno DEVELOPMENT desde la raíz del proyecto
# Ejecutar: .\start-api-dev.ps1

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  INICIANDO API - ENTORNO DEVELOPMENT" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Navegar al directorio de la API
$apiPath = Join-Path $PSScriptRoot "ACEXAPI"
Set-Location $apiPath

Write-Host "Configuración:" -ForegroundColor Yellow
Write-Host "  Entorno: Development" -ForegroundColor White
Write-Host "  Archivo: appsettings.Development.json" -ForegroundColor White
Write-Host "  Puerto: 5000" -ForegroundColor White
Write-Host ""

Write-Host "Iniciando API..." -ForegroundColor Cyan
Write-Host ""

# Establecer variable de entorno y ejecutar
$env:ASPNETCORE_ENVIRONMENT = "Development"
dotnet run

Write-Host ""
Write-Host "API detenida" -ForegroundColor Yellow
