# Script para iniciar proyecto ACEXAPI
# Ejecutar desde PowerShell

Write-Host ""
Write-Host "INICIANDO PROYECTO ACEXAPI" -ForegroundColor Cyan
Write-Host "==========================" -ForegroundColor Cyan
Write-Host ""

$projectRoot = "G:\ProyectoFinalCSharp\ProyectoFinalDAM2"

# Verificar SQL Server
Write-Host "Verificando SQL Server..." -ForegroundColor Yellow
try {
    $sqlTest = sqlcmd -S "localhost\SQLEXPRESS" -U sa -P "Semicrol_10" -Q "SELECT 1" -h -1 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SQL Server OK" -ForegroundColor Green
    } else {
        Write-Host "Iniciando SQL Server..." -ForegroundColor Yellow
        Start-Service -Name "MSSQL`$SQLEXPRESS" -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 3
    }
} catch {
    Write-Host "Advertencia: No se pudo verificar SQL Server" -ForegroundColor Yellow
}

Write-Host ""

# Crear/Actualizar base de datos
Write-Host "Creando base de datos..." -ForegroundColor Yellow
Set-Location "$projectRoot\ACEXAPI"
dotnet ef database update

Write-Host ""

# Lanzar API
Write-Host "Lanzando API..." -ForegroundColor Yellow
$apiCmd = "Set-Location '$projectRoot\ACEXAPI'; dotnet run"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $apiCmd

Write-Host "API lanzada en nueva ventana" -ForegroundColor Green
Start-Sleep -Seconds 3

Write-Host ""

# Lanzar Flutter
Write-Host "Preparando Flutter..." -ForegroundColor Yellow
Set-Location "$projectRoot\proyecto_santi"
flutter pub get

Write-Host ""
Write-Host "Selecciona plataforma:" -ForegroundColor Cyan
Write-Host "1 - Windows" -ForegroundColor White
Write-Host "2 - Web (Chrome)" -ForegroundColor White
Write-Host "3 - Android" -ForegroundColor White
Write-Host ""

$opcion = Read-Host "Opcion"

switch ($opcion) {
    "1" {
        $flutterCmd = "Set-Location '$projectRoot\proyecto_santi'; flutter run -d windows"
        Start-Process powershell -ArgumentList "-NoExit", "-Command", $flutterCmd
    }
    "2" {
        $flutterCmd = "Set-Location '$projectRoot\proyecto_santi'; flutter run -d chrome"
        Start-Process powershell -ArgumentList "-NoExit", "-Command", $flutterCmd
    }
    "3" {
        $flutterCmd = "Set-Location '$projectRoot\proyecto_santi'; flutter run"
        Start-Process powershell -ArgumentList "-NoExit", "-Command", $flutterCmd
    }
    default {
        Write-Host "Opcion no valida" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "PROYECTO INICIADO!" -ForegroundColor Green
Write-Host ""
Write-Host "API: https://localhost:7139" -ForegroundColor Cyan
Write-Host ""

Read-Host "Presiona Enter para cerrar"
