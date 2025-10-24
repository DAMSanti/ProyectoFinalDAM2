# Script para iniciar la API en entorno TRABAJO
# Ejecutar desde PowerShell

Write-Host ""
Write-Host "INICIANDO API - ENTORNO TRABAJO" -ForegroundColor Blue
Write-Host "================================" -ForegroundColor Blue
Write-Host ""

$apiPath = "C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI"
$appsettingsPath = Join-Path $apiPath "appsettings.json"
$backupPath = Join-Path $apiPath "appsettings.backup.json"
$trabajoPath = Join-Path $apiPath "appsettings.Trabajo.json"

Write-Host "Configuracion actual:" -ForegroundColor Yellow
Write-Host "  Servidor: 127.0.0.1,1433" -ForegroundColor White
Write-Host "  Base de datos: ACEXAPI" -ForegroundColor White
Write-Host "  Autenticacion: SQL Server (sa)" -ForegroundColor White
Write-Host ""

Set-Location $apiPath

# Hacer backup del appsettings.json original
Write-Host "Creando backup de configuracion..." -ForegroundColor Cyan
Copy-Item $appsettingsPath $backupPath -Force

# Copiar la configuracion de trabajo
Write-Host "Aplicando configuracion de trabajo..." -ForegroundColor Cyan
Copy-Item $trabajoPath $appsettingsPath -Force

Write-Host ""
Write-Host "Iniciando API..." -ForegroundColor Cyan
Write-Host ""
Write-Host "IMPORTANTE: Al cerrar la API (Ctrl+C), se restaurara la configuracion original" -ForegroundColor Yellow
Write-Host ""

try {
    # Iniciar la API
    dotnet run --launch-profile http
}
finally {
    # Restaurar el appsettings.json original
    Write-Host ""
    Write-Host "Restaurando configuracion original..." -ForegroundColor Cyan
    Copy-Item $backupPath $appsettingsPath -Force
    Remove-Item $backupPath -Force
    Write-Host "Configuracion restaurada!" -ForegroundColor Green
}
