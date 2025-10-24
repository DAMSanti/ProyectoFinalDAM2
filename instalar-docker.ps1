# Script de configuracion de Docker en G:
# Ejecutar como Administrador
# Clic derecho en PowerShell > Ejecutar como administrador

param(
    [string]$TargetDrive = "G:",
    [string]$DockerInstallerPath = ""
)

Write-Host ""
Write-Host "CONFIGURACION DE DOCKER EN OTRA UNIDAD" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que se ejecuta como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Este script debe ejecutarse como Administrador" -ForegroundColor Red
    Write-Host ""
    Write-Host "Clic derecho en PowerShell > Ejecutar como administrador" -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host "Ejecutando como Administrador" -ForegroundColor Green
Write-Host ""

# Verificar espacio disponible
$targetDriveLetter = $TargetDrive.TrimEnd(':')
$drive = Get-PSDrive -Name $targetDriveLetter -ErrorAction SilentlyContinue
if ($drive) {
    $freeSpaceGB = [math]::Round($drive.Free / 1GB, 2)
    Write-Host "Espacio disponible en ${TargetDrive} -> $freeSpaceGB GB" -ForegroundColor Cyan
    
    if ($freeSpaceGB -lt 10) {
        Write-Host "ADVERTENCIA: Se recomienda tener al menos 10 GB libres" -ForegroundColor Yellow
        Write-Host "Tienes $freeSpaceGB GB disponibles" -ForegroundColor Yellow
        $continue = Read-Host "Deseas continuar de todos modos? (S/N)"
        if ($continue -ne "S" -and $continue -ne "s") {
            Write-Host "Operacion cancelada" -ForegroundColor Yellow
            exit 0
        }
    }
} else {
    Write-Host "ERROR: La unidad $TargetDrive no existe" -ForegroundColor Red
    exit 1
}

Write-Host ""

# PASO 1: Verificar/Habilitar WSL 2
Write-Host "PASO 1: Verificando WSL 2..." -ForegroundColor Yellow
Write-Host ""

$wslInstalled = $false
try {
    wsl --status 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "WSL ya esta instalado" -ForegroundColor Green
        $wslInstalled = $true
    }
} catch {
    Write-Host "WSL no detectado" -ForegroundColor Gray
}

if (-not $wslInstalled) {
    Write-Host "Instalando WSL 2..." -ForegroundColor Yellow
    Write-Host ""
    
    Write-Host "Habilitando caracteristica WSL..." -ForegroundColor Gray
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    
    Write-Host "Habilitando Plataforma de Maquina Virtual..." -ForegroundColor Gray
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    
    Write-Host ""
    Write-Host "WSL 2 configurado" -ForegroundColor Green
    Write-Host "IMPORTANTE: Debes REINICIAR el PC antes de continuar" -ForegroundColor Yellow
    Write-Host ""
    $restart = Read-Host "Deseas reiniciar ahora? (S/N)"
    if ($restart -eq "S" -or $restart -eq "s") {
        Write-Host "Reiniciando en 10 segundos..." -ForegroundColor Cyan
        Start-Sleep -Seconds 10
        Restart-Computer
        exit 0
    } else {
        Write-Host ""
        Write-Host "Recuerda reiniciar el PC antes de instalar Docker" -ForegroundColor Yellow
        Write-Host "Despues del reinicio, ejecuta este script nuevamente" -ForegroundColor Yellow
        Read-Host "Presiona Enter para salir"
        exit 0
    }
}

# Establecer WSL 2 como predeterminado
Write-Host "Configurando WSL 2 como predeterminado..." -ForegroundColor Gray
wsl --set-default-version 2

Write-Host ""

# PASO 2: Crear estructura de carpetas
Write-Host "PASO 2: Creando estructura de carpetas en ${TargetDrive}..." -ForegroundColor Yellow
Write-Host ""

$folders = @(
    "$TargetDrive\Docker",
    "$TargetDrive\DockerData",
    "$TargetDrive\DockerData\docker-desktop",
    "$TargetDrive\DockerData\docker-desktop-data",
    "$TargetDrive\SqlServerData",
    "$TargetDrive\Backups"
)

foreach ($folder in $folders) {
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Force -Path $folder | Out-Null
        Write-Host "Creado: $folder" -ForegroundColor Green
    } else {
        Write-Host "Ya existe: $folder" -ForegroundColor Gray
    }
}

Write-Host ""

# PASO 3: Verificar instalador de Docker
Write-Host "PASO 3: Verificando instalador de Docker Desktop..." -ForegroundColor Yellow
Write-Host ""

$installerLocations = @(
    "$TargetDrive\Downloads\Docker Desktop Installer.exe",
    "$TargetDrive\Docker Desktop Installer.exe",
    "$env:USERPROFILE\Downloads\Docker Desktop Installer.exe"
)

$installerPath = $null
foreach ($location in $installerLocations) {
    if (Test-Path $location) {
        $installerPath = $location
        Write-Host "Instalador encontrado: $installerPath" -ForegroundColor Green
        break
    }
}

if (-not $installerPath) {
    Write-Host "Instalador no encontrado" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Descarga Docker Desktop desde:" -ForegroundColor Cyan
    Write-Host "https://www.docker.com/products/docker-desktop/" -ForegroundColor White
    Write-Host ""
    Write-Host "Guardalo en: $TargetDrive\Downloads\" -ForegroundColor Cyan
    Write-Host ""
    
    $download = Read-Host "Deseas abrir el navegador para descargar? (S/N)"
    if ($download -eq "S" -or $download -eq "s") {
        Start-Process "https://www.docker.com/products/docker-desktop/"
    }
    
    Write-Host ""
    Write-Host "Ejecuta este script nuevamente despues de descargar el instalador" -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 0
}

Write-Host ""

# PASO 4: Instalar Docker Desktop
Write-Host "PASO 4: Deseas instalar Docker Desktop ahora?" -ForegroundColor Yellow
Write-Host ""
Write-Host "Se instalara en: $TargetDrive\Docker" -ForegroundColor Cyan
Write-Host ""

$install = Read-Host "Continuar con la instalacion? (S/N)"
if ($install -ne "S" -and $install -ne "s") {
    Write-Host "Instalacion cancelada" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Instalando Docker Desktop... (puede tardar 10-15 minutos)" -ForegroundColor Cyan
Write-Host ""

try {
    # Intentar instalacion con directorio personalizado
    $installArgs = "install --installation-dir=$TargetDrive\Docker"
    Start-Process -FilePath $installerPath -ArgumentList $installArgs -Wait -NoNewWindow
    
    Write-Host "Docker Desktop instalado correctamente" -ForegroundColor Green
} catch {
    Write-Host "Instalacion con directorio personalizado fallo" -ForegroundColor Yellow
    Write-Host "Intentando instalacion estandar..." -ForegroundColor Yellow
    
    try {
        Start-Process -FilePath $installerPath -ArgumentList "install" -Wait -NoNewWindow
        Write-Host "Docker Desktop instalado" -ForegroundColor Green
        Write-Host "Instalado en ubicacion predeterminada (C:)" -ForegroundColor Yellow
        Write-Host "Los datos se moveran a $TargetDrive en el siguiente paso" -ForegroundColor Cyan
    } catch {
        Write-Host "Error al instalar Docker Desktop" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        Read-Host "Presiona Enter para salir"
        exit 1
    }
}

Write-Host ""
Write-Host "INSTALACION COMPLETADA" -ForegroundColor Green
Write-Host ""
Write-Host "SIGUIENTES PASOS:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Abre Docker Desktop desde el menu de inicio" -ForegroundColor White
Write-Host "2. Espera a que Docker Desktop inicie completamente" -ForegroundColor White
Write-Host "3. Acepta los terminos de servicio si aparecen" -ForegroundColor White
Write-Host "4. Ejecuta el script: mover-docker-datos.ps1" -ForegroundColor White
Write-Host "   para mover los datos a $TargetDrive" -ForegroundColor White
Write-Host ""
Write-Host "Deseas que te muestre el comando para SQL Server?" -ForegroundColor Yellow
$showSql = Read-Host "(S/N)"

if ($showSql -eq "S" -or $showSql -eq "s") {
    Write-Host ""
    Write-Host "COMANDO PARA SQL SERVER:" -ForegroundColor Cyan
    Write-Host ""
    $sqlCommand = "docker run -e ACCEPT_EULA=Y -e SA_PASSWORD=Semicrol_10 -e MSSQL_PID=Express -p 1433:1433 --name sqlserver --restart always -v ${TargetDrive}/SqlServerData:/var/opt/mssql -d mcr.microsoft.com/mssql/server:2022-latest"
    Write-Host $sqlCommand -ForegroundColor White
    Write-Host ""
    Write-Host "Copia este comando y ejecutalo despues de que Docker Desktop este corriendo" -ForegroundColor Yellow
}

Write-Host ""
Read-Host "Presiona Enter para finalizar"
