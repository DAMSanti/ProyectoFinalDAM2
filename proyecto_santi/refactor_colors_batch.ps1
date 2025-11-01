# Script para refactorizar colores hardcodeados por AppColors
# Encoding UTF-8 sin BOM

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Archivos a refactorizar
$files = @(
    "lib\views\activityDetail\sections\locations_section.dart",
    "lib\views\activityDetail\sections\images_section.dart",
    "lib\views\activityDetail\sections\header_section.dart",
    "lib\views\activityDetail\widgets\lists\profesor_list.dart",
    "lib\views\activityDetail\widgets\lists\grupo_list.dart",
    "lib\views\activityDetail\dialogs\widgets\multi_select_cursos_list.dart",
    "lib\views\activityDetail\widgets\locations\localizacion_widgets.dart",
    "lib\views\activityDetail\widgets\locations\localizacion_card.dart"
)

function Add-ThemeImport {
    param([string]$filePath)
    
    $content = Get-Content $filePath -Raw -Encoding UTF8
    
    # Verificar si ya tiene el import
    if ($content -match "import 'package:proyecto_santi/tema/tema\.dart';") {
        Write-Host "  [OK] Ya tiene el import de tema" -ForegroundColor Green
        return
    }
    
    # Buscar la última línea de import
    $lines = Get-Content $filePath -Encoding UTF8
    $lastImportIndex = -1
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match "^import ") {
            $lastImportIndex = $i
        }
    }
    
    if ($lastImportIndex -ge 0) {
        # Insertar después del último import
        $lines = @($lines[0..$lastImportIndex]) + @("import 'package:proyecto_santi/tema/tema.dart';") + @($lines[($lastImportIndex + 1)..($lines.Count - 1)])
        $lines | Set-Content $filePath -Encoding UTF8
        Write-Host "  [OK] Import anadido" -ForegroundColor Green
    }
}

function Replace-Colors {
    param([string]$filePath)
    
    $content = Get-Content $filePath -Raw -Encoding UTF8
    $originalContent = $content
    
    # Contador de reemplazos
    $count = 0
    
    # Reemplazos específicos primero (de más específico a más general)
    
    # Opacidades específicas
    $replacements = @(
        @{ Pattern = 'Color\(0xFF1976d2\)\.withOpacity\(0\.95\)'; Replace = 'AppColors.primaryOpacity95'; Name = '.withOpacity(0.95)' },
        @{ Pattern = 'Color\(0xFF1976d2\)\.withOpacity\(0\.9\)'; Replace = 'AppColors.primaryOpacity90'; Name = '.withOpacity(0.9)' },
        @{ Pattern = 'Color\(0xFF1976d2\)\.withOpacity\(0\.8\)'; Replace = 'AppColors.primaryOpacity80'; Name = '.withOpacity(0.8)' },
        @{ Pattern = 'Color\(0xFF1976d2\)\.withOpacity\(0\.5\)'; Replace = 'AppColors.primaryOpacity50'; Name = '.withOpacity(0.5)' },
        @{ Pattern = 'Color\(0xFF1976d2\)\.withOpacity\(0\.4\)'; Replace = 'AppColors.primaryOpacity40'; Name = '.withOpacity(0.4)' },
        @{ Pattern = 'Color\(0xFF1976d2\)\.withOpacity\(0\.3\)'; Replace = 'AppColors.primaryOpacity30'; Name = '.withOpacity(0.3)' },
        @{ Pattern = 'Color\(0xFF1976d2\)\.withOpacity\(0\.2\)'; Replace = 'AppColors.primaryOpacity20'; Name = '.withOpacity(0.2)' },
        @{ Pattern = 'Color\(0xFF1976d2\)\.withOpacity\(0\.15\)'; Replace = 'AppColors.primaryOpacity15'; Name = '.withOpacity(0.15)' },
        @{ Pattern = 'Color\(0xFF1976d2\)\.withOpacity\(0\.1\)'; Replace = 'AppColors.primaryOpacity10'; Name = '.withOpacity(0.1)' },
        
        @{ Pattern = 'Color\(0xFF1565c0\)\.withOpacity\(0\.95\)'; Replace = 'AppColors.primaryDarkOpacity95'; Name = 'Dark .withOpacity(0.95)' },
        @{ Pattern = 'Color\(0xFF1565c0\)\.withOpacity\(0\.9\)'; Replace = 'AppColors.primaryDarkOpacity90'; Name = 'Dark .withOpacity(0.9)' },
        @{ Pattern = 'Color\(0xFF1565c0\)\.withOpacity\(0\.8\)'; Replace = 'AppColors.primaryDarkOpacity80'; Name = 'Dark .withOpacity(0.8)' },
        @{ Pattern = 'Color\(0xFF1565c0\)\.withOpacity\(0\.5\)'; Replace = 'AppColors.primaryDarkOpacity50'; Name = 'Dark .withOpacity(0.5)' },
        @{ Pattern = 'Color\(0xFF1565c0\)\.withOpacity\(0\.4\)'; Replace = 'AppColors.primaryDarkOpacity40'; Name = 'Dark .withOpacity(0.4)' },
        @{ Pattern = 'Color\(0xFF1565c0\)\.withOpacity\(0\.3\)'; Replace = 'AppColors.primaryDarkOpacity30'; Name = 'Dark .withOpacity(0.3)' },
        @{ Pattern = 'Color\(0xFF1565c0\)\.withOpacity\(0\.2\)'; Replace = 'AppColors.primaryDarkOpacity20'; Name = 'Dark .withOpacity(0.2)' },
        @{ Pattern = 'Color\(0xFF1565c0\)\.withOpacity\(0\.15\)'; Replace = 'AppColors.primaryDarkOpacity15'; Name = 'Dark .withOpacity(0.15)' },
        @{ Pattern = 'Color\(0xFF1565c0\)\.withOpacity\(0\.1\)'; Replace = 'AppColors.primaryDarkOpacity10'; Name = 'Dark .withOpacity(0.1)' },
        
        # Gradientes (arrays de colores)
        @{ Pattern = '\[[\s\n]*Color\(0xFF1976d2\)\.withOpacity\(0\.8\),[\s\n]*Color\(0xFF1565c0\)\.withOpacity\(0\.9\),?[\s\n]*\]'; Replace = 'AppColors.primaryGradient'; Name = 'gradient [0.8, 0.9]' },
        @{ Pattern = '\[[\s\n]*Color\(0xFF1976d2\),[\s\n]*Color\(0xFF1565c0\),?[\s\n]*\]'; Replace = 'AppColors.primaryGradient'; Name = 'gradient basic' },
        
        # Colores base
        @{ Pattern = 'Color\(0xFF1976d2\)'; Replace = 'AppColors.primary'; Name = 'base primary' },
        @{ Pattern = 'Color\(0xFF1565c0\)'; Replace = 'AppColors.primaryDark'; Name = 'base primaryDark' }
    )
    
    foreach ($rep in $replacements) {
        $matches = [regex]::Matches($content, $rep.Pattern)
        if ($matches.Count -gt 0) {
            $content = $content -replace $rep.Pattern, $rep.Replace
            $count += $matches.Count
            Write-Host "    • $($matches.Count)x $($rep.Name)" -ForegroundColor Cyan
        }
    }
    
    # Solo escribir si hubo cambios
    if ($content -ne $originalContent) {
        $content | Set-Content $filePath -Encoding UTF8 -NoNewline
        Write-Host "  [OK] $count reemplazos realizados" -ForegroundColor Green
        return $count
    } else {
        Write-Host "  - Sin cambios necesarios" -ForegroundColor Yellow
        return 0
    }
}

# Procesar cada archivo
$totalReplacements = 0

Write-Host "`n=== Iniciando refactorización de colores ===" -ForegroundColor Magenta
Write-Host "Archivos a procesar: $($files.Count)`n" -ForegroundColor Magenta

foreach ($file in $files) {
    $fullPath = Join-Path $PSScriptRoot $file
    
    if (Test-Path $fullPath) {
        Write-Host "[*] $file" -ForegroundColor White
        
        # Añadir import
        Add-ThemeImport -filePath $fullPath
        
        # Reemplazar colores
        $replacements = Replace-Colors -filePath $fullPath
        $totalReplacements += $replacements
        
        Write-Host ""
    } else {
        Write-Host "[ERROR] No encontrado: $file" -ForegroundColor Red
        Write-Host ""
    }
}

Write-Host "=== Resumen ===" -ForegroundColor Magenta
Write-Host "Total de reemplazos: $totalReplacements" -ForegroundColor Green
Write-Host "`n[OK] Refactorizacion completada" -ForegroundColor Green
Write-Host "`nEjecuta 'flutter analyze' para verificar que no hay errores." -ForegroundColor Yellow
