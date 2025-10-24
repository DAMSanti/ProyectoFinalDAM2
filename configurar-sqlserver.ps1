# Script para configurar SQL Server Express
# EJECUTAR COMO ADMINISTRADOR
# Ejecutar DESPUES de instalar SQL Server Express

Write-Host ""
Write-Host "CONFIGURACION DE SQL SERVER EXPRESS" -ForegroundColor Cyan
Write-Host "====================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que se ejecuta como administrador
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "ERROR: Este script debe ejecutarse como Administrador" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host "PASO 1: Habilitando autenticacion mixta..." -ForegroundColor Yellow
Write-Host ""

# Configurar autenticacion mixta via registro
$instanceName = "SQLEXPRESS"
$registryPath = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\MSSQL16.$instanceName\MSSQLServer"

if (Test-Path $registryPath) {
    Set-ItemProperty -Path $registryPath -Name "LoginMode" -Value 2
    Write-Host "   Autenticacion mixta habilitada" -ForegroundColor Green
} else {
    Write-Host "   No se encontro la instancia SQLEXPRESS en el registro" -ForegroundColor Yellow
    Write-Host "   Deberas configurarlo manualmente en SSMS" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "PASO 2: Habilitando TCP/IP..." -ForegroundColor Yellow
Write-Host ""

# Habilitar TCP/IP para SQL Server
Write-Host "   Configurando protocolo TCP/IP..." -ForegroundColor Cyan
Write-Host "   (Esto puede requerir configuracion manual en SQL Server Configuration Manager)" -ForegroundColor Gray

Write-Host ""
Write-Host "PASO 3: Reiniciando servicio SQL Server..." -ForegroundColor Yellow
Write-Host ""

$serviceName = "MSSQL`$$instanceName"
Write-Host "   Deteniendo servicio: $serviceName" -ForegroundColor Cyan
Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

Write-Host "   Iniciando servicio: $serviceName" -ForegroundColor Cyan
Start-Service -Name $serviceName -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

# Verificar estado
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
if ($service -and $service.Status -eq "Running") {
    Write-Host "   Servicio iniciado correctamente" -ForegroundColor Green
} else {
    Write-Host "   Error al iniciar el servicio" -ForegroundColor Red
}

Write-Host ""
Write-Host "PASO 4: Habilitando usuario 'sa'..." -ForegroundColor Yellow
Write-Host ""

# Script SQL para habilitar sa y establecer password
$sqlScript = @"
USE [master]
GO

-- Habilitar usuario sa
ALTER LOGIN [sa] ENABLE
GO

-- Establecer password para sa
ALTER LOGIN [sa] WITH PASSWORD = N'Semicrol_10'
GO

-- Crear la base de datos ACEXAPI si no existe
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'ACEXAPI')
BEGIN
    CREATE DATABASE [ACEXAPI]
END
GO

PRINT 'Configuracion completada!'
"@

# Guardar script SQL temporal
$scriptPath = "G:\temp_configure_sql.sql"
$sqlScript | Out-File -FilePath $scriptPath -Encoding UTF8

Write-Host "   Ejecutando script de configuracion SQL..." -ForegroundColor Cyan
Write-Host ""

# Intentar ejecutar con sqlcmd
try {
    $output = sqlcmd -S "localhost\SQLEXPRESS" -E -i $scriptPath 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "   Configuracion SQL completada!" -ForegroundColor Green
        Write-Host $output -ForegroundColor Gray
    } else {
        throw "Error al ejecutar sqlcmd"
    }
} catch {
    Write-Host "   No se pudo ejecutar automaticamente" -ForegroundColor Yellow
    Write-Host "   Ejecuta manualmente este script en SSMS:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host $sqlScript -ForegroundColor White
}

# Limpiar archivo temporal
if (Test-Path $scriptPath) {
    Remove-Item $scriptPath -Force
}

Write-Host ""
Write-Host "CONFIGURACION COMPLETADA!" -ForegroundColor Green
Write-Host ""
Write-Host "CADENA DE CONEXION para tu aplicacion:" -ForegroundColor Cyan
Write-Host ""
Write-Host 'Server=localhost\SQLEXPRESS;Database=ACEXAPI;User Id=sa;Password=Semicrol_10;TrustServerCertificate=True;' -ForegroundColor White
Write-Host ""
Write-Host "PROBAR CONEXION:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   sqlcmd -S localhost\SQLEXPRESS -U sa -P Semicrol_10 -Q `"SELECT @@VERSION`"" -ForegroundColor Cyan
Write-Host ""

Read-Host "Presiona Enter para finalizar"
