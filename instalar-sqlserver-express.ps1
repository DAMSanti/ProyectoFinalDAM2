# Script para instalar SQL Server Express en G:
# EJECUTAR COMO ADMINISTRADOR

param(
    [string]$InstallPath = "G:\SQLServer"
)

Write-Host ""
Write-Host "INSTALACION DE SQL SERVER EXPRESS EN G:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que se ejecuta como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Este script debe ejecutarse como Administrador" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host "PASO 1: Descargando SQL Server Express 2022..." -ForegroundColor Yellow
Write-Host ""

# URL de descarga de SQL Server Express 2022
$downloadUrl = "https://go.microsoft.com/fwlink/p/?linkid=2216019&clcid=0x409&culture=en-us&country=us"
$installerPath = "G:\Downloads\SQLServer2022-SSEI-Expr.exe"

# Crear carpeta de descargas si no existe
$downloadFolder = "G:\Downloads"
if (-not (Test-Path $downloadFolder)) {
    New-Item -ItemType Directory -Force -Path $downloadFolder | Out-Null
}

Write-Host "   Descargando instalador..." -ForegroundColor Cyan
Write-Host "   URL: $downloadUrl" -ForegroundColor Gray
Write-Host "   Destino: $installerPath" -ForegroundColor Gray
Write-Host ""

try {
    # Usar WebClient para descargar (más compatible)
    $webClient = New-Object System.Net.WebClient
    $webClient.DownloadFile($downloadUrl, $installerPath)
    Write-Host "   Descarga completada!" -ForegroundColor Green
} catch {
    Write-Host "   Error al descargar: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "   Descarga manual:" -ForegroundColor Yellow
    Write-Host "   1. Abre este enlace en tu navegador:" -ForegroundColor White
    Write-Host "      https://www.microsoft.com/es-es/sql-server/sql-server-downloads" -ForegroundColor Cyan
    Write-Host "   2. Descarga 'Express' (gratis)" -ForegroundColor White
    Write-Host "   3. Guardalo en: $installerPath" -ForegroundColor White
    Write-Host "   4. Vuelve a ejecutar este script" -ForegroundColor White
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host ""
Write-Host "PASO 2: Instalando SQL Server Express..." -ForegroundColor Yellow
Write-Host ""

# Crear carpeta de instalacion
if (-not (Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Force -Path $InstallPath | Out-Null
}

Write-Host "   Ruta de instalacion: $InstallPath" -ForegroundColor Cyan
Write-Host "   Esto puede tardar 10-15 minutos..." -ForegroundColor Yellow
Write-Host ""

# Ejecutar instalador en modo basico
# Esto abrira el instalador de SQL Server
Write-Host "   Abriendo instalador de SQL Server..." -ForegroundColor Cyan
Write-Host ""
Write-Host "   IMPORTANTE - Configuracion durante la instalacion:" -ForegroundColor Yellow
Write-Host "   1. Selecciona 'Basico' o 'Personalizado'" -ForegroundColor White
Write-Host "   2. CAMBIA la ruta de instalacion a: $InstallPath" -ForegroundColor White
Write-Host "   3. Acepta los terminos de licencia" -ForegroundColor White
Write-Host "   4. Espera a que termine la instalacion" -ForegroundColor White
Write-Host "   5. Anota la INSTANCIA que se crea (normalmente: SQLEXPRESS)" -ForegroundColor White
Write-Host ""

Start-Process -FilePath $installerPath -Wait

Write-Host ""
Write-Host "PASO 3: Configurando SQL Server..." -ForegroundColor Yellow
Write-Host ""

# Habilitar SQL Server Browser
Write-Host "   Habilitando SQL Server Browser..." -ForegroundColor Cyan
Set-Service -Name "SQLBrowser" -StartupType Automatic -ErrorAction SilentlyContinue
Start-Service -Name "SQLBrowser" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "INSTALACION COMPLETADA!" -ForegroundColor Green
Write-Host ""
Write-Host "SIGUIENTE PASO: Habilitar autenticacion SQL" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Abre SQL Server Management Studio (SSMS)" -ForegroundColor White
Write-Host "   O descargalo de: https://aka.ms/ssmsfullsetup" -ForegroundColor Cyan
Write-Host ""
Write-Host "2. Conectate a: localhost\SQLEXPRESS" -ForegroundColor White
Write-Host "   (Usa autenticacion de Windows)" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Click derecho en el servidor > Propiedades > Seguridad" -ForegroundColor White
Write-Host "   Selecciona: 'Modo de autenticacion de SQL Server y Windows'" -ForegroundColor White
Write-Host ""
Write-Host "4. Reinicia el servicio de SQL Server" -ForegroundColor White
Write-Host ""
Write-Host "5. Crea un usuario 'sa' con password: Semicrol_10" -ForegroundColor White
Write-Host ""
Write-Host "O ejecuta el siguiente script:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   .\configurar-sqlserver.ps1" -ForegroundColor Cyan
Write-Host ""

Read-Host "Presiona Enter para finalizar"
