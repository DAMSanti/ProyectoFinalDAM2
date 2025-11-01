# Script para agregar salto de linea final a archivos .dart

$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse

foreach ($file in $dartFiles) {
    $content = Get-Content $file.FullName -Raw
    
    if (-not $content.EndsWith("`n")) {
        $content += "`n"
        Set-Content -Path $file.FullName -Value $content -NoNewline
    }
}

Write-Host "Archivos corregidos" -ForegroundColor Green
