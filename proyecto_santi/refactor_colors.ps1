# Script para refactorizar colores hardcodeados a AppColors
# Procesa todos los archivos de activityDetail

$files = @(
    "lib\views\activityDetail\dialogs\edit_localizacion_dialog.dart",
    "lib\shared\widgets\dialog_header.dart",
    "lib\shared\widgets\dialog_footer.dart",
    "lib\views\activityDetail\dialogs\widgets\multi_select_cursos_list.dart",
    "lib\views\activityDetail\dialogs\widgets\image_description_field.dart",
    "lib\views\activityDetail\dialogs\layouts\multi_select_portrait_layout.dart",
    "lib\views\activityDetail\dialogs\layouts\multi_select_landscape_layout.dart",
    "lib\views\activityDetail\dialogs\layouts\image_preview_portrait_layout.dart",
    "lib\views\activityDetail\dialogs\layouts\image_preview_landscape_layout.dart",
    "lib\views\activityDetail\dialogs\layouts\add_localizacion_portrait_layout.dart",
    "lib\views\activityDetail\widgets\locations\localizacion_widgets.dart",
    "lib\views\activityDetail\widgets\locations\localizacion_card.dart",
    "lib\views\activityDetail\widgets\lists\profesor_list.dart",
    "lib\views\activityDetail\widgets\lists\grupo_list.dart",
    "lib\views\activityDetail\widgets\forms\status_and_type_form.dart",
    "lib\views\activityDetail\widgets\cards\info_card.dart",
    "lib\views\activityDetail\widgets\cards\departamento_card.dart",
    "lib\views\activityDetail\widgets\budget\budget_sections.dart",
    "lib\views\activityDetail\sections\locations_section.dart",
    "lib\views\activityDetail\sections\images_section.dart",
    "lib\views\activityDetail\sections\header_section.dart",
    "lib\views\activityDetail\sections\detail_info_section.dart",
    "lib\views\activityDetail\sections\budget_section.dart",
    "lib\views\activityDetail\helpers\image_picker_helper.dart",
    "lib\views\activityDetail\helpers\dialog_form_helpers.dart",
    "lib\views\activityDetail\utils\detail_bar.dart"
)

$replacements = @{
    'Color\(0xFF1976d2\)\.withOpacity\(0\.95\)' = 'AppColors.primaryOpacity95'
    'Color\(0xFF1976d2\)\.withOpacity\(0\.9\)' = 'AppColors.primaryOpacity90'
    'Color\(0xFF1976d2\)\.withOpacity\(0\.8\)' = 'AppColors.primaryOpacity80'
    'Color\(0xFF1976d2\)\.withOpacity\(0\.7\)' = 'AppColors.primaryOpacity70'
    'Color\(0xFF1976d2\)\.withOpacity\(0\.5\)' = 'AppColors.primaryOpacity50'
    'Color\(0xFF1976d2\)\.withOpacity\(0\.4\)' = 'AppColors.primaryOpacity40'
    'Color\(0xFF1976d2\)\.withOpacity\(0\.3\)' = 'AppColors.primaryOpacity30'
    'Color\(0xFF1976d2\)\.withOpacity\(0\.2\)' = 'AppColors.primaryOpacity20'
    'Color\(0xFF1976d2\)\.withOpacity\(0\.15\)' = 'AppColors.primaryOpacity15'
    'Color\(0xFF1976d2\)\.withOpacity\(0\.1\)' = 'AppColors.primaryOpacity10'
    'Color\(0xFF1976d2\)\.withOpacity\(0\.08\)' = 'AppColors.primaryOpacity08'
    'Color\(0xFF1565c0\)\.withOpacity\(0\.95\)' = 'AppColors.primaryDarkOpacity95'
    'Color\(0xFF1565c0\)\.withOpacity\(0\.9\)' = 'AppColors.primaryDarkOpacity90'
    'Color\(0xFF1565c0\)\.withOpacity\(0\.8\)' = 'AppColors.primaryDarkOpacity80'
    'Color\(0xFF1565c0\)\.withOpacity\(0\.15\)' = 'AppColors.primaryDarkOpacity15'
    'Color\(0xFF1565c0\)\.withOpacity\(0\.1\)' = 'AppColors.primaryDarkOpacity10'
    '\[Color\(0xFF1976d2\), Color\(0xFF1565c0\)\]' = 'AppColors.primaryGradient'
    'Color\(0xFF1976d2\)' = 'AppColors.primary'
    'Color\(0xFF1565c0\)' = 'AppColors.primaryDark'
}

foreach ($file in $files) {
    $fullPath = "g:\ProyectoFinalCSharp\ProyectoFinalDAM2\proyecto_santi\$file"
    
    if (Test-Path $fullPath) {
        Write-Host "Procesando: $file"
        
        # Leer contenido
        $content = Get-Content $fullPath -Raw -Encoding UTF8
        
        # Añadir import si no existe
        if ($content -notmatch "import 'package:proyecto_santi/tema/tema.dart';") {
            $content = $content -replace "(import 'package:flutter/material.dart';)", "`$1`nimport 'package:proyecto_santi/tema/tema.dart';"
        }
        
        # Aplicar reemplazos en orden (más específico primero)
        foreach ($pattern in $replacements.Keys) {
            $replacement = $replacements[$pattern]
            $content = $content -replace $pattern, $replacement
        }
        
        # Guardar
        $content | Set-Content $fullPath -Encoding UTF8 -NoNewline
        Write-Host "  ✓ Completado"
    } else {
        Write-Host "  ✗ No encontrado: $file"
    }
}

Write-Host "`nRefactorización completada!"
