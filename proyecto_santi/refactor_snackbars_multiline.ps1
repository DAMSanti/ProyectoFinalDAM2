# Script mejorado para refactorizar SnackBars multilínea
$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n=== Refactorizando SnackBars multilinea ===" -ForegroundColor Magenta

$files = @(
    "lib\views\activityDetail\dialogs\edit_activity_dialog.dart",
    "lib\views\activityDetail\sections\locations_section.dart",
    "lib\views\activityDetail\dialogs\folleto_upload_dialog.dart",
    "lib\views\activityDetail\dialogs\add_custom_expense_dialog.dart",
    "lib\views\activityDetail\widgets\lists\profesor_list.dart",
    "lib\views\activityDetail\widgets\lists\grupo_list.dart",
    "lib\views\activityDetail\sections\images_section.dart"
)

$totalReplacements = 0

foreach ($filePath in $files) {
    if (-not (Test-Path $filePath)) {
        continue
    }
    
    Write-Host "`n[*] $(Split-Path $filePath -Leaf)" -ForegroundColor White
    
    $content = Get-Content $filePath -Raw -Encoding UTF8
    $originalContent = $content
    
    # Añadir import si no existe
    if ($content -notmatch "import 'package:proyecto_santi/tema/tema\.dart';") {
        $lines = $content -split "`n"
        $lastImportIndex = -1
        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match "^import ") {
                $lastImportIndex = $i
            }
        }
        
        if ($lastImportIndex -ge 0) {
            $lines = @($lines[0..$lastImportIndex]) + @("import 'package:proyecto_santi/tema/tema.dart';") + @($lines[($lastImportIndex + 1)..($lines.Count - 1)])
            $content = $lines -join "`n"
            Write-Host "  [+] Import anadido" -ForegroundColor Green
        }
    }
    
    # Patrón para SnackBar multilínea con backgroundColor
    $pattern = "ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\('([^']+)'\),\s*backgroundColor:\s*Colors\.(red|green|orange|blue)[^)]*\),?\s*\)"
    $content = $content -replace $pattern, {
        param($match)
        $mensaje = $match.Groups[1].Value
        $color = $match.Groups[2].Value
        
        $method = switch ($color) {
            "red"    { "showError" }
            "green"  { "showSuccess" }
            "orange" { "showWarning" }
            "blue"   { "showInfo" }
            default  { "show" }
        }
        
        "SnackBarHelper.$method(context, '$mensaje')"
    }
    
    # Patrón para SnackBar simple multilínea sin backgroundColor
    $pattern2 = "ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\('([^']+)'\)\s*\)\s*\)"
    $content = $content -replace $pattern2, "SnackBarHelper.show(context, '`$1')"
    
    # Patrón para mensajes con interpolación y backgroundColor
    $pattern3 = "ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\('([^']*\$[^']+)'\),\s*backgroundColor:\s*Colors\.(red|green|orange|blue)[^)]*\),?\s*\)"
    $content = $content -replace $pattern3, {
        param($match)
        $mensaje = $match.Groups[1].Value
        $color = $match.Groups[2].Value
        
        $method = switch ($color) {
            "red"    { "showError" }
            "green"  { "showSuccess" }
            "orange" { "showWarning" }
            "blue"   { "showInfo" }
            default  { "show" }
        }
        
        "SnackBarHelper.$method(context, '$mensaje')"
    }
    
    if ($content -ne $originalContent) {
        $replacements = ([regex]::Matches($originalContent, "ScaffoldMessenger\.of\(context\)\.showSnackBar")).Count - ([regex]::Matches($content, "ScaffoldMessenger\.of\(context\)\.showSnackBar")).Count
        $content | Set-Content $filePath -Encoding UTF8 -NoNewline
        Write-Host "  [OK] $replacements reemplazos realizados" -ForegroundColor Green
        $totalReplacements += $replacements
    } else {
        Write-Host "  [-] Sin cambios automaticos, requiere revision manual" -ForegroundColor Yellow
    }
}

Write-Host "`n=== Resumen ===" -ForegroundColor Magenta
Write-Host "Total de reemplazos: $totalReplacements" -ForegroundColor Green
Write-Host "`n[OK] Refactorizacion completada" -ForegroundColor Green
