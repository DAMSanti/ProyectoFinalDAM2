# Script para iniciar la API en entorno TRABAJO
# Ejecutar desde PowerShell

Write-Host ""
Write-Host "INICIANDO API - ENTORNO TRABAJO" -ForegroundColor Blue
Write-Host "================================" -ForegroundColor Blue
Write-Host ""

$apiPath = "G:\ProyectoFinalCSharp\ProyectoFinalDAM2\ACEXAPI"

Write-Host "IMPORTANTE: Actualiza appsettings.Trabajo.json con tu configuracion del trabajo" -ForegroundColor Yellow
Write-Host ""
Write-Host "Configuracion actual:" -ForegroundColor Yellow
Write-Host "  Servidor: TU_SERVIDOR_TRABAJO\SQLEXPRESS" -ForegroundColor White
Write-Host "  Base de datos: ACEXAPI" -ForegroundColor White
Write-Host ""

$continuar = Read-Host "Has actualizado la configuracion? (S/N)"
if ($continuar -ne "S" -and $continuar -ne "s") {
    Write-Host "Cancelado. Actualiza appsettings.Trabajo.json primero" -ForegroundColor Red
    exit 0
}

Set-Location $apiPath

Write-Host ""
Write-Host "Iniciando API..." -ForegroundColor Cyan
Write-Host ""

# Iniciar la API con el entorno Trabajo
$env:ASPNETCORE_ENVIRONMENT = "Trabajo"
dotnet run
