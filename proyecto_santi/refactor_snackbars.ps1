# Script para refactorizar SnackBars por SnackBarHelper
# Encoding UTF-8 sin BOM

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "`n=== Iniciando refactorizacion de SnackBars ===" -ForegroundColor Magenta

# Buscar todos los archivos de activityDetail
$files = Get-ChildItem -Path "lib\views\activityDetail" -Recurse -Filter "*.dart" | Where-Object { 
    $_.FullName -notmatch "\\test\\" 
}

Write-Host "Archivos encontrados: $($files.Count)`n" -ForegroundColor Cyan

$totalReplacements = 0
$filesModified = 0

foreach ($file in $files) {
    $filePath = $file.FullName
    $content = Get-Content $filePath -Raw -Encoding UTF8
    $originalContent = $content
    $fileReplacements = 0
    
    # Verificar si el archivo usa ScaffoldMessenger
    if ($content -notmatch "ScaffoldMessenger\.of\(context\)\.showSnackBar") {
        continue
    }
    
    Write-Host "[*] $($file.Name)" -ForegroundColor White
    
    # Añadir import si no existe
    if ($content -notmatch "import 'package:proyecto_santi/tema/tema\.dart';") {
        # Buscar la última línea de import
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
    
    # Patrón 1: Error con texto entre comillas simples
    # ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('mensaje')))
    $pattern1 = "ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\('([^']+)'\)\s*\)\s*\)"
    $matches = [regex]::Matches($content, $pattern1)
    if ($matches.Count -gt 0) {
        foreach ($match in $matches) {
            $mensaje = $match.Groups[1].Value
            # Determinar el tipo basado en palabras clave
            if ($mensaje -match "(?i)(error|fallo|fall|incorrecto)") {
                $replacement = "SnackBarHelper.showError(context, '$mensaje')"
            } elseif ($mensaje -match "(?i)(agregado|guardado|actualizado|eliminado|completado|xito)") {
                $replacement = "SnackBarHelper.showSuccess(context, '$mensaje')"
            } else {
                $replacement = "SnackBarHelper.show(context, '$mensaje')"
            }
            $content = $content -replace [regex]::Escape($match.Value), $replacement
            $fileReplacements++
        }
    }
    
    # Patrón 2: Mensajes con interpolación
    # ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')))
    $pattern2 = "ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\('([^']*\$[^']+)'\)\s*\)\s*\)"
    $matches2 = [regex]::Matches($content, $pattern2)
    if ($matches2.Count -gt 0) {
        foreach ($match in $matches2) {
            $mensaje = $match.Groups[1].Value
            if ($mensaje -match "(?i)(error|fallo)") {
                $replacement = "SnackBarHelper.showError(context, '$mensaje')"
            } else {
                $replacement = "SnackBarHelper.show(context, '$mensaje')"
            }
            $content = $content -replace [regex]::Escape($match.Value), $replacement
            $fileReplacements++
        }
    }
    
    # Patrón 3: Mensajes con comillas dobles
    $pattern3 = 'ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\("([^"]+)"\)\s*\)\s*\)'
    $matches3 = [regex]::Matches($content, $pattern3)
    if ($matches3.Count -gt 0) {
        foreach ($match in $matches3) {
            $mensaje = $match.Groups[1].Value
            if ($mensaje -match "(?i)(error|fallo|fall|incorrecto)") {
                $replacement = "SnackBarHelper.showError(context, '$mensaje')"
            } elseif ($mensaje -match "(?i)(agregado|guardado|actualizado|eliminado|completado|xito)") {
                $replacement = "SnackBarHelper.showSuccess(context, '$mensaje')"
            } else {
                $replacement = "SnackBarHelper.show(context, '$mensaje')"
            }
            $content = $content -replace [regex]::Escape($match.Value), $replacement
            $fileReplacements++
        }
    }
    
    # Patrón 4: SnackBar multilínea (más complejo)
    $pattern4 = "ScaffoldMessenger\.of\(context\)\.showSnackBar\(\s*SnackBar\(\s*content:\s*Text\(\s*'([^']+)'\s*\),?\s*\)\s*,?\s*\)"
    $matches4 = [regex]::Matches($content, $pattern4)
    if ($matches4.Count -gt 0) {
        foreach ($match in $matches4) {
            if ($match.Value -notmatch "SnackBarHelper") {  # Evitar reemplazar lo ya reemplazado
                $mensaje = $match.Groups[1].Value
                if ($mensaje -match "(?i)(error|fallo)") {
                    $replacement = "SnackBarHelper.showError(context, '$mensaje')"
                } elseif ($mensaje -match "(?i)(agregado|guardado|actualizado|eliminado|completado|xito)") {
                    $replacement = "SnackBarHelper.showSuccess(context, '$mensaje')"
                } else {
                    $replacement = "SnackBarHelper.show(context, '$mensaje')"
                }
                $content = $content -replace [regex]::Escape($match.Value), $replacement
                $fileReplacements++
            }
        }
    }
    
    # Guardar si hubo cambios
    if ($content -ne $originalContent) {
        $content | Set-Content $filePath -Encoding UTF8 -NoNewline
        Write-Host "  [OK] $fileReplacements reemplazos realizados" -ForegroundColor Green
        $totalReplacements += $fileReplacements
        $filesModified++
    } else {
        Write-Host "  [-] Sin cambios" -ForegroundColor Yellow
    }
    
    Write-Host ""
}

Write-Host "=== Resumen ===" -ForegroundColor Magenta
Write-Host "Archivos modificados: $filesModified" -ForegroundColor Green
Write-Host "Total de reemplazos: $totalReplacements" -ForegroundColor Green
Write-Host "`n[OK] Refactorizacion completada" -ForegroundColor Green
Write-Host "`nEjecuta 'flutter analyze' para verificar que no hay errores." -ForegroundColor Yellow
