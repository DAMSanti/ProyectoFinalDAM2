# Script para reemplazar .withOpacity() por .withValues(alpha:)

Write-Host "Iniciando reemplazo de withOpacity por withValues..." -ForegroundColor Cyan

$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse

$totalFiles = 0
$totalReplacements = 0

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    
    $pattern = '\.withOpacity\(([^)]+)\)'
    $replacement = '.withValues(alpha: $1)'
    
    $content = $content -replace $pattern, $replacement
    
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        
        $matches = [regex]::Matches($originalContent, $pattern)
        $replacementsInFile = $matches.Count
        
        $totalFiles++
        $totalReplacements += $replacementsInFile
        
        Write-Host "  OK $($file.Name): $replacementsInFile reemplazos" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Reemplazo completado: $totalFiles archivos, $totalReplacements reemplazos" -ForegroundColor Yellow
