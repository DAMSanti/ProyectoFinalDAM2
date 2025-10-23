# Script para iniciar la API ACEXAPI correctamente
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Iniciando API ACEXAPI" -ForegroundColor Yellow
Write-Host " Puerto: 5000 (todas las interfaces)" -ForegroundColor Green
Write-Host " Swagger: http://192.168.9.190:5000/" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# Cambiar al directorio de la API
Set-Location "C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI"

# Verificar si el puerto 5000 está en uso
$port5000 = Get-NetTCPConnection -LocalPort 5000 -ErrorAction SilentlyContinue
if ($port5000) {
    Write-Host "⚠️  El puerto 5000 ya está en uso. Cerrando proceso..." -ForegroundColor Yellow
    $processId = $port5000[0].OwningProcess
    Stop-Process -Id $processId -Force
    Start-Sleep -Seconds 2
    Write-Host "✅ Proceso cerrado" -ForegroundColor Green
    Write-Host ""
}

# Iniciar la API con el perfil http
Write-Host "🚀 Iniciando API..." -ForegroundColor Cyan
dotnet run --launch-profile http
