# Script para mover datos de Docker WSL 2 a otra unidad
# EJECUTAR COMO ADMINISTRADOR
# Usa este script DESPUES de instalar Docker Desktop

param(
    [string]$TargetDrive = "G:"
)

Write-Host ""
Write-Host "MOVER DATOS DE DOCKER A $TargetDrive" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que se ejecuta como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Este script debe ejecutarse como Administrador" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

# Verificar que Docker Desktop esta instalado
Write-Host "Verificando Docker Desktop..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "Docker instalado: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "Docker no esta instalado o no esta en el PATH" -ForegroundColor Red
    Write-Host "   Instala Docker Desktop primero" -ForegroundColor Yellow
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host ""

# Advertencia
Write-Host "IMPORTANTE:" -ForegroundColor Yellow
Write-Host "   Este proceso movera TODOS los datos de Docker (imagenes, contenedores, volumenes)" -ForegroundColor Yellow
Write-Host "   desde C: a $TargetDrive" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Requerimientos:" -ForegroundColor Cyan
Write-Host "   - Docker Desktop debe estar CERRADO" -ForegroundColor White
Write-Host "   - Espacio suficiente en $TargetDrive (al menos 5 GB)" -ForegroundColor White
Write-Host "   - Este proceso puede tardar 10-20 minutos" -ForegroundColor White
Write-Host ""

$continue = Read-Host "Deseas continuar? (S/N)"
if ($continue -ne "S" -and $continue -ne "s") {
    Write-Host "Operacion cancelada" -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# PASO 1: Cerrar Docker Desktop
Write-Host "PASO 1: Cerrando Docker Desktop..." -ForegroundColor Yellow
Write-Host ""

$dockerProcesses = Get-Process | Where-Object { $_.ProcessName -like "*Docker*" }
if ($dockerProcesses) {
    Write-Host "   Deteniendo procesos de Docker..." -ForegroundColor Gray
    Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "com.docker.backend" -Force -ErrorAction SilentlyContinue
    Stop-Process -Name "com.docker.proxy" -Force -ErrorAction SilentlyContinue
    
    Write-Host "   Esperando a que Docker se cierre completamente..." -ForegroundColor Gray
    Start-Sleep -Seconds 5
    
    Write-Host "Docker Desktop cerrado" -ForegroundColor Green
} else {
    Write-Host "Docker Desktop ya estaba cerrado" -ForegroundColor Green
}

# Detener WSL
Write-Host "   Deteniendo WSL..." -ForegroundColor Gray
wsl --shutdown
Start-Sleep -Seconds 3

Write-Host ""

# PASO 2: Crear carpetas en destino
Write-Host "PASO 2: Creando carpetas en $TargetDrive..." -ForegroundColor Yellow
Write-Host ""

$dockerDataPath = "$TargetDrive\DockerData"
if (-not (Test-Path $dockerDataPath)) {
    New-Item -ItemType Directory -Force -Path $dockerDataPath | Out-Null
    Write-Host "Carpeta creada: $dockerDataPath" -ForegroundColor Green
} else {
    Write-Host "Carpeta ya existe: $dockerDataPath" -ForegroundColor Green
}

Write-Host ""

# PASO 3: Exportar distribuciones WSL
Write-Host "PASO 3: Exportando distribuciones WSL de Docker..." -ForegroundColor Yellow
Write-Host ""

$distributions = @("docker-desktop", "docker-desktop-data")

foreach ($dist in $distributions) {
    Write-Host "   Exportando $dist..." -ForegroundColor Cyan
    $tarPath = "$dockerDataPath\$dist.tar"
    
    try {
        wsl --export $dist $tarPath
        
        if (Test-Path $tarPath) {
            $sizeGB = [math]::Round((Get-Item $tarPath).Length / 1GB, 2)
            Write-Host "   Exportado: $dist ($sizeGB GB)" -ForegroundColor Green
        } else {
            Write-Host "   No se pudo exportar $dist (puede no existir)" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "   Error al exportar $dist : $_" -ForegroundColor Yellow
    }
}

Write-Host ""

# PASO 4: Desregistrar distribuciones originales
Write-Host "PASO 4: Desregistrando distribuciones originales..." -ForegroundColor Yellow
Write-Host ""

foreach ($dist in $distributions) {
    $tarPath = "$dockerDataPath\$dist.tar"
    if (Test-Path $tarPath) {
        Write-Host "   Desregistrando $dist..." -ForegroundColor Gray
        try {
            wsl --unregister $dist
            Write-Host "   Desregistrado: $dist" -ForegroundColor Green
        } catch {
            Write-Host "   Error al desregistrar $dist" -ForegroundColor Yellow
        }
    }
}

Write-Host ""

# PASO 5: Importar distribuciones en nueva ubicacion
Write-Host "PASO 5: Importando distribuciones en $TargetDrive..." -ForegroundColor Yellow
Write-Host ""

foreach ($dist in $distributions) {
    $tarPath = "$dockerDataPath\$dist.tar"
    $importPath = "$dockerDataPath\$dist"
    
    if (Test-Path $tarPath) {
        Write-Host "   Importando $dist a $importPath..." -ForegroundColor Cyan
        Write-Host "   (Esto puede tardar varios minutos...)" -ForegroundColor Gray
        
        try {
            wsl --import $dist $importPath $tarPath --version 2
            Write-Host "   Importado: $dist" -ForegroundColor Green
        } catch {
            Write-Host "   Error al importar $dist : $_" -ForegroundColor Red
        }
    } else {
        Write-Host "   Archivo no encontrado: $tarPath" -ForegroundColor Yellow
    }
}

Write-Host ""

# PASO 6: Limpiar archivos .tar
Write-Host "PASO 6: Limpiando archivos temporales..." -ForegroundColor Yellow
Write-Host ""

$cleanUp = Read-Host "Deseas eliminar los archivos .tar de exportacion? (S/N)"
if ($cleanUp -eq "S" -or $cleanUp -eq "s") {
    foreach ($dist in $distributions) {
        $tarPath = "$dockerDataPath\$dist.tar"
        if (Test-Path $tarPath) {
            Remove-Item $tarPath -Force
            Write-Host "   Eliminado: $dist.tar" -ForegroundColor Green
        }
    }
} else {
    Write-Host "   Archivos .tar conservados en $dockerDataPath" -ForegroundColor Cyan
    Write-Host "   Puedes eliminarlos manualmente despues de verificar que todo funciona" -ForegroundColor Gray
}

Write-Host ""

# PASO 7: Verificar migracion
Write-Host "PASO 7: Verificando migracion..." -ForegroundColor Yellow
Write-Host ""

Write-Host "   Distribuciones WSL registradas:" -ForegroundColor Cyan
wsl --list --verbose

Write-Host ""

# Verificar espacio liberado en C:
$cDrive = Get-PSDrive -Name "C"
$cFreeSpaceGB = [math]::Round($cDrive.Free / 1GB, 2)
Write-Host "   Espacio libre en C: -> $cFreeSpaceGB GB" -ForegroundColor Cyan

# Verificar espacio usado en destino
$targetDriveLetter = $TargetDrive.TrimEnd(':')
$targetDriveInfo = Get-PSDrive -Name $targetDriveLetter
$targetFreeSpaceGB = [math]::Round($targetDriveInfo.Free / 1GB, 2)
Write-Host "   Espacio libre en $TargetDrive -> $targetFreeSpaceGB GB" -ForegroundColor Cyan

Write-Host ""

# PASO 8: Reiniciar Docker Desktop
Write-Host "PASO 8: Deseas iniciar Docker Desktop ahora?" -ForegroundColor Yellow
$startDocker = Read-Host "(S/N)"

if ($startDocker -eq "S" -or $startDocker -eq "s") {
    Write-Host ""
    Write-Host "   Iniciando Docker Desktop..." -ForegroundColor Cyan
    
    $dockerPath = "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    if (Test-Path $dockerPath) {
        Start-Process $dockerPath
        Write-Host "   Docker Desktop iniciandose..." -ForegroundColor Green
        Write-Host "   Espera unos minutos a que inicie completamente" -ForegroundColor Yellow
    } else {
        Write-Host "   No se encontro Docker Desktop en la ubicacion esperada" -ForegroundColor Yellow
        Write-Host "   Inicialo manualmente desde el menu de inicio" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "MIGRACION COMPLETADA!" -ForegroundColor Green
Write-Host ""
Write-Host "RESUMEN:" -ForegroundColor Cyan
Write-Host "   - Datos de Docker movidos a: $dockerDataPath" -ForegroundColor White
Write-Host "   - Espacio liberado en C:" -ForegroundColor White
Write-Host "   - Docker Desktop debe funcionar normalmente" -ForegroundColor White
Write-Host ""
Write-Host "VERIFICACION:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   Una vez Docker Desktop haya iniciado, ejecuta:" -ForegroundColor White
Write-Host "   docker --version" -ForegroundColor Cyan
Write-Host "   docker ps" -ForegroundColor Cyan
Write-Host ""
Write-Host "SIGUIENTE PASO: Instalar SQL Server" -ForegroundColor Yellow
Write-Host ""
$sqlCommand = "docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=Semicrol_10' -e 'MSSQL_PID=Express' -p 1433:1433 --name sqlserver --restart always -v '${TargetDrive}/SqlServerData:/var/opt/mssql' -d mcr.microsoft.com/mssql/server:2022-latest"
Write-Host $sqlCommand -ForegroundColor White
Write-Host ""

Read-Host "Presiona Enter para finalizar"
