# Script para poblar la base de datos con codificación UTF-8 correcta
# Ejecutar desde: G:\ProyectoFinalCSharp\ProyectoFinalDAM2

Write-Host ""
Write-Host "Poblando base de datos con UTF-8..." -ForegroundColor Cyan
Write-Host ""

# Leer el archivo SQL y ejecutarlo con codificación UTF-8
$sqlScript = Get-Content -Path "DB\PoblarBaseDatosSimple.sql" -Encoding UTF8 -Raw

# Guardar temporalmente con BOM UTF-8
$tempFile = [System.IO.Path]::GetTempFileName()
$utf8BOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText($tempFile, $sqlScript, $utf8BOM)

try {
    # Ejecutar el script con SQLCMD
    sqlcmd -S 'localhost\SQLEXPRESS' -U sa -P 'Semicrol_10' -i $tempFile -W
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "[OK] Base de datos poblada correctamente" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host "[ERROR] Hubo un error al poblar la base de datos" -ForegroundColor Red
    }
} finally {
    # Limpiar archivo temporal
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
}

Write-Host ""
