# Script para iniciar todo el proyecto ACEXAPI
# EJECUTAR COMO ADMINISTRADOR

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   INICIANDO PROYECTO ACEXAPI COMPLETO  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que se ejecuta como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Este script debe ejecutarse como Administrador" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

$projectRoot = "G:\ProyectoFinalCSharp\ProyectoFinalDAM2"

# PASO 1: Verificar SQL Server
Write-Host "PASO 1: Verificando SQL Server..." -ForegroundColor Yellow
Write-Host ""

$sqlService = Get-Service -Name "MSSQL`$SQLEXPRESS" -ErrorAction SilentlyContinue
if ($sqlService -and $sqlService.Status -eq "Running") {
    Write-Host "   SQL Server esta corriendo" -ForegroundColor Green
} else {
    Write-Host "   Iniciando SQL Server..." -ForegroundColor Cyan
    Start-Service -Name "MSSQL`$SQLEXPRESS" -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 3
    Write-Host "   SQL Server iniciado" -ForegroundColor Green
}

Write-Host ""

# PASO 2: Crear/Actualizar base de datos
Write-Host "PASO 2: Creando/Actualizando base de datos..." -ForegroundColor Yellow
Write-Host ""

Set-Location "$projectRoot\ACEXAPI"

Write-Host "   Restaurando paquetes NuGet..." -ForegroundColor Cyan
dotnet restore

Write-Host ""
Write-Host "   Aplicando migraciones de Entity Framework..." -ForegroundColor Cyan
dotnet ef database update

if ($LASTEXITCODE -eq 0) {
    Write-Host "   Base de datos creada/actualizada correctamente!" -ForegroundColor Green
} else {
    Write-Host "   Error al crear la base de datos" -ForegroundColor Red
    Write-Host "   Revisa los errores arriba" -ForegroundColor Yellow
    Read-Host "Presiona Enter para continuar de todos modos"
}

Write-Host ""

# PASO 3: Lanzar API en segundo plano
Write-Host "PASO 3: Lanzando API..." -ForegroundColor Yellow
Write-Host ""

Set-Location "$projectRoot\ACEXAPI"

Write-Host "   Compilando API..." -ForegroundColor Cyan
dotnet build

Write-Host "   Iniciando API en segundo plano..." -ForegroundColor Cyan
Write-Host "   URL: https://localhost:7139" -ForegroundColor White
Write-Host "        http://localhost:5139" -ForegroundColor White

# Iniciar API en nueva ventana de PowerShell
$apiCommand = "cd '$projectRoot\ACEXAPI'; dotnet run"
Start-Process powershell -ArgumentList "-NoExit", "-Command", $apiCommand

Write-Host "   API lanzada en nueva ventana!" -ForegroundColor Green
Write-Host "   Esperando 5 segundos a que la API inicie..." -ForegroundColor Gray
Start-Sleep -Seconds 5

Write-Host ""

# PASO 4: Lanzar aplicacion Flutter
Write-Host "PASO 4: Lanzando aplicacion Flutter..." -ForegroundColor Yellow
Write-Host ""

Set-Location "$projectRoot\proyecto_santi"

Write-Host "   Obteniendo dependencias de Flutter..." -ForegroundColor Cyan
flutter pub get

Write-Host ""
Write-Host "   Dispositivos disponibles:" -ForegroundColor Cyan
flutter devices

Write-Host ""
Write-Host "   Selecciona que plataforma quieres lanzar:" -ForegroundColor Yellow
Write-Host "   1) Windows (Escritorio)" -ForegroundColor White
Write-Host "   2) Chrome (Web)" -ForegroundColor White
Write-Host "   3) Android (Emulador/Dispositivo)" -ForegroundColor White
Write-Host "   4) Todas las anteriores" -ForegroundColor White
Write-Host ""

$opcion = Read-Host "Opcion (1/2/3/4)"

switch ($opcion) {
    "1" {
        Write-Host ""
        Write-Host "   Lanzando en Windows..." -ForegroundColor Cyan
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot\proyecto_santi'; flutter run -d windows"
        Write-Host "   App de Windows lanzada!" -ForegroundColor Green
    }
    "2" {
        Write-Host ""
        Write-Host "   Lanzando en Chrome..." -ForegroundColor Cyan
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot\proyecto_santi'; flutter run -d chrome"
        Write-Host "   App Web lanzada!" -ForegroundColor Green
    }
    "3" {
        Write-Host ""
        Write-Host "   Lanzando en Android..." -ForegroundColor Cyan
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot\proyecto_santi'; flutter run -d android"
        Write-Host "   App Android lanzada!" -ForegroundColor Green
    }
    "4" {
        Write-Host ""
        Write-Host "   Lanzando en todas las plataformas..." -ForegroundColor Cyan
        
        # Windows
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot\proyecto_santi'; flutter run -d windows"
        Start-Sleep -Seconds 2
        
        # Chrome
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot\proyecto_santi'; flutter run -d chrome"
        Start-Sleep -Seconds 2
        
        # Android
        Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectRoot\proyecto_santi'; flutter run -d android"
        
        Write-Host "   Todas las apps lanzadas!" -ForegroundColor Green
    }
    default {
        Write-Host "   Opcion no valida, saltando..." -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "   PROYECTO INICIADO COMPLETAMENTE!    " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "SERVICIOS CORRIENDO:" -ForegroundColor Cyan
Write-Host ""
Write-Host "  API Backend:" -ForegroundColor Yellow
Write-Host "    - https://localhost:7139" -ForegroundColor White
Write-Host "    - http://localhost:5139" -ForegroundColor White
Write-Host ""
Write-Host "  Base de datos:" -ForegroundColor Yellow
Write-Host "    - localhost\SQLEXPRESS" -ForegroundColor White
Write-Host "    - Database: ACEXAPI" -ForegroundColor White
Write-Host ""
Write-Host "  Aplicaciones Flutter:" -ForegroundColor Yellow
Write-Host "    - Segun tu seleccion" -ForegroundColor White
Write-Host ""
Write-Host "PARA DETENER TODO:" -ForegroundColor Red
Write-Host "  - Cierra las ventanas de PowerShell que se abrieron" -ForegroundColor White
Write-Host "  - O ejecuta: .\detener-proyecto.ps1" -ForegroundColor White
Write-Host ""

Read-Host "Presiona Enter para cerrar esta ventana"
