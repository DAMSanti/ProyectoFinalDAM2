# Script para poblar TODOS los datos de la base de datos ACEXAPI
$ErrorActionPreference = "Stop"

Write-Host "========================================"
Write-Host "POBLAR BASE DE DATOS COMPLETA - UTF-8"
Write-Host "========================================"
Write-Host ""

$Server = "localhost\SQLEXPRESS"
$Database = "ACEXAPI"
$User = "sa"
$Password = "Semicrol_10"
$SqlFile = "DB\PoblarBaseDatosSimple.sql"

if (-not (Test-Path $SqlFile)) {
    Write-Host "ERROR: No se encuentra el archivo $SqlFile"
    exit 1
}

Write-Host "Leyendo archivo SQL: $SqlFile"
$sqlContent = Get-Content -Path $SqlFile -Encoding UTF8 -Raw

$tempFile = [System.IO.Path]::GetTempFileName()
$utf8BOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText($tempFile, $sqlContent, $utf8BOM)

Write-Host "Ejecutando script SQL..."
Write-Host ""

try {
    $output = sqlcmd -S $Server -U $User -P $Password -d $Database -i $tempFile -W -b -u 2>&1
    
    $output | ForEach-Object {
        Write-Host $_
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================"
        Write-Host "BASE DE DATOS POBLADA CORRECTAMENTE"
        Write-Host "========================================"
    } else {
        Write-Host ""
        Write-Host "ERROR: Hubo un problema al ejecutar el script"
        exit 1
    }
}
catch {
    Write-Host ""
    Write-Host "ERROR: $_"
    exit 1
}
finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
}
