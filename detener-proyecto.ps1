# Script para detener todos los servicios del proyecto
# EJECUTAR COMO ADMINISTRADOR

Write-Host ""
Write-Host "========================================" -ForegroundColor Red
Write-Host "   DETENIENDO PROYECTO ACEXAPI         " -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""

# Verificar que se ejecuta como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ADVERTENCIA: Se recomienda ejecutar como Administrador" -ForegroundColor Yellow
}

Write-Host "Deteniendo procesos..." -ForegroundColor Yellow
Write-Host ""

# Detener procesos de .NET (API)
Write-Host "   Deteniendo API (.NET)..." -ForegroundColor Cyan
Get-Process | Where-Object {$_.ProcessName -like "*dotnet*" -or $_.MainWindowTitle -like "*ACEXAPI*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "   API detenida" -ForegroundColor Green

# Detener procesos de Flutter
Write-Host "   Deteniendo aplicaciones Flutter..." -ForegroundColor Cyan
Get-Process | Where-Object {$_.ProcessName -like "*flutter*" -or $_.ProcessName -like "*proyecto_santi*"} | Stop-Process -Force -ErrorAction SilentlyContinue
Write-Host "   Aplicaciones Flutter detenidas" -ForegroundColor Green

# Opcional: Detener SQL Server (comentado por defecto)
# Write-Host "   Deteniendo SQL Server..." -ForegroundColor Cyan
# Stop-Service -Name "MSSQL`$SQLEXPRESS" -Force -ErrorAction SilentlyContinue
# Write-Host "   SQL Server detenido" -ForegroundColor Green

Write-Host ""
Write-Host "PROYECTO DETENIDO!" -ForegroundColor Green
Write-Host ""
Write-Host "NOTA: SQL Server sigue corriendo (esto es normal)" -ForegroundColor Yellow
Write-Host "Si quieres detenerlo, ejecuta:" -ForegroundColor Gray
Write-Host "  Stop-Service -Name 'MSSQL`$SQLEXPRESS' -Force" -ForegroundColor White
Write-Host ""

Read-Host "Presiona Enter para cerrar"
