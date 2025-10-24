# Script para mostrar cobertura de tests
# Uso: .\mostrar-cobertura.ps1

Write-Host "=== RESUMEN DE COBERTURA DE TESTS ===" -ForegroundColor Cyan
Write-Host ""

# Ejecutar tests con cobertura
Write-Host "Ejecutando tests con cobertura..." -ForegroundColor Yellow
flutter test --coverage | Out-Null

if ($LASTEXITCODE -eq 0) {
    Write-Host "OK Todos los tests pasaron" -ForegroundColor Green
} else {
    Write-Host "ERROR Algunos tests fallaron" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "=== COBERTURA POR ARCHIVO ===" -ForegroundColor Cyan
Write-Host ""

# Leer archivo lcov.info
$content = Get-Content coverage/lcov.info

$files = @()
$currentFile = ""
$totalLines = 0
$coveredLines = 0

foreach ($line in $content) {
    if ($line -match "^SF:lib\\(.+)$") {
        if ($currentFile -ne "") {
            $files += [PSCustomObject]@{
                File = $currentFile
                Total = $totalLines
                Covered = $coveredLines
                Percentage = if ($totalLines -gt 0) { [math]::Round(($coveredLines / $totalLines) * 100, 2) } else { 0 }
            }
        }
        $currentFile = $matches[1]
        $totalLines = 0
        $coveredLines = 0
    }
    elseif ($line -match "^LF:(\d+)$") {
        $totalLines = [int]$matches[1]
    }
    elseif ($line -match "^LH:(\d+)$") {
        $coveredLines = [int]$matches[1]
    }
}

# Agregar el último archivo
if ($currentFile -ne "") {
    $files += [PSCustomObject]@{
        File = $currentFile
        Total = $totalLines
        Covered = $coveredLines
        Percentage = if ($totalLines -gt 0) { [math]::Round(($coveredLines / $totalLines) * 100, 2) } else { 0 }
    }
}

# Mostrar resultados ordenados por porcentaje
$files | Sort-Object -Property Percentage -Descending | ForEach-Object {
    $color = if ($_.Percentage -ge 80) { "Green" } 
             elseif ($_.Percentage -ge 50) { "Yellow" } 
             else { "Red" }
    
    $bar = "█" * [int]($_.Percentage / 5)
    Write-Host ("{0,-50} {1,3}% {2,4}/{3,-4} {4}" -f $_.File, $_.Percentage, $_.Covered, $_.Total, $bar) -ForegroundColor $color
}

# Calcular totales
$globalTotal = ($files | Measure-Object -Property Total -Sum).Sum
$globalCovered = ($files | Measure-Object -Property Covered -Sum).Sum
$globalPercentage = if ($globalTotal -gt 0) { [math]::Round(($globalCovered / $globalTotal) * 100, 2) } else { 0 }

Write-Host ""
Write-Host "=== TOTAL GLOBAL ===" -ForegroundColor Cyan
$color = if ($globalPercentage -ge 80) { "Green" } 
         elseif ($globalPercentage -ge 50) { "Yellow" } 
         else { "Red" }

Write-Host ("Cobertura: {0}% ({1}/{2} lineas)" -f $globalPercentage, $globalCovered, $globalTotal) -ForegroundColor $color

# Calcular cuantas lineas faltan para 80%
$needed80 = [math]::Ceiling($globalTotal * 0.8) - $globalCovered
if ($needed80 -gt 0) {
    Write-Host ("Lineas necesarias para 80%: {0}" -f $needed80) -ForegroundColor Yellow
} else {
    Write-Host "OK Objetivo de 80% alcanzado!" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== ARCHIVOS CON MAYOR POTENCIAL DE MEJORA ===" -ForegroundColor Cyan
$files | Where-Object { $_.Percentage -lt 80 -and $_.Total -gt 20 } | Sort-Object -Property Total -Descending | Select-Object -First 5 | ForEach-Object {
    $uncovered = $_.Total - $_.Covered
    Write-Host ("  {0,-50} {1} lineas sin cubrir" -f $_.File, $uncovered) -ForegroundColor Yellow
}

Write-Host ""
