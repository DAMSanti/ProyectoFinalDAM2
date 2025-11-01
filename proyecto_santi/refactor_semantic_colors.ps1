# Script para refactorizar colores semanticos hardcodeados en activityDetail
# Reemplaza Colors.orange/green/red/purple/teal con AppColors semanticos

$activityDetailPath = ".\lib\views\activityDetail"
$filesToProcess = Get-ChildItem -Path $activityDetailPath -Recurse -Filter "*.dart"

$replacements = @(
    # Estados de actividad
    @{
        Pattern = 'color:\s*Colors\.orange(?!\[)'
        Replacement = 'color: AppColors.estadoPendiente'
        Description = 'Estado Pendiente (naranja)'
    },
    @{
        Pattern = 'color:\s*Colors\.green(?!\[)'
        Replacement = 'color: AppColors.estadoAprobado'
        Description = 'Estado Aprobado (verde)'
    },
    @{
        Pattern = 'color:\s*Colors\.red(?!\[|\.)'
        Replacement = 'color: AppColors.estadoRechazado'
        Description = 'Estado Rechazado (rojo)'
    },
    
    # Tipos de actividad
    @{
        Pattern = 'color:\s*Colors\.purple(?!\[)'
        Replacement = 'color: AppColors.tipoComplementaria'
        Description = 'Tipo Complementaria (morado)'
    },
    
    # Presupuesto - Transporte y Alojamiento
    @{
        Pattern = 'color:\s*Colors\.teal(?!\[)'
        Replacement = 'color: AppColors.presupuestoAlojamiento'
        Description = 'Presupuesto Alojamiento (teal)'
    },
    
    # Acciones de eliminacion - Colors.red[700]
    @{
        Pattern = 'Colors\.red\[700\]'
        Replacement = 'AppColors.accionEliminar'
        Description = 'Accion Eliminar (rojo oscuro)'
    },
    
    # Acciones de edicion - Colors.blue[700]
    @{
        Pattern = 'Colors\.blue\[700\]'
        Replacement = 'AppColors.accionEditar'
        Description = 'Accion Editar (azul oscuro)'
    },
    
    # Gradientes de eliminacion
    @{
        Pattern = 'Colors\.red\[700\]!,\s*Colors\.red\[800\]!'
        Replacement = '...AppColors.eliminarGradient'
        Description = 'Gradiente Eliminar'
    },
    @{
        Pattern = '\[Colors\.red\[700\]!,\s*Colors\.red\[800\]!\]'
        Replacement = 'AppColors.eliminarGradient'
        Description = 'Gradiente Eliminar (array)'
    },
    
    # Iconos de advertencia - Icon(..., color: Colors.orange)
    @{
        Pattern = 'Icon\(Icons\.warning_amber_rounded,\s*color:\s*Colors\.orange\)'
        Replacement = 'Icon(Icons.warning_amber_rounded, color: AppColors.warning)'
        Description = 'Icono de advertencia'
    },
    
    # BackgroundColor en botones de eliminar
    @{
        Pattern = 'backgroundColor:\s*Colors\.red(?!\.)'
        Replacement = 'backgroundColor: AppColors.estadoRechazado'
        Description = 'Background rojo en botones'
    },
    
    # BackgroundColor con Colors.red[700]
    @{
        Pattern = 'backgroundColor:\s*Colors\.red\[700\]'
        Replacement = 'backgroundColor: AppColors.accionEliminar'
        Description = 'Background rojo oscuro'
    },
    
    # Transporte y alojamiento en budget_sections
    @{
        Pattern = 'backgroundColor:\s*Colors\.purple'
        Replacement = 'backgroundColor: AppColors.presupuestoTransporte'
        Description = 'Background morado transporte'
    },
    @{
        Pattern = 'backgroundColor:\s*Colors\.teal'
        Replacement = 'backgroundColor: AppColors.presupuestoAlojamiento'
        Description = 'Background teal alojamiento'
    },
    
    # Iconos con colores especificos
    @{
        Pattern = 'Icon\(Icons\.business_rounded,\s*size:\s*16,\s*color:\s*Colors\.purple\)'
        Replacement = 'Icon(Icons.business_rounded, size: 16, color: AppColors.presupuestoTransporte)'
        Description = 'Icono transporte'
    },
    @{
        Pattern = 'Icon\(Icons\.hotel_rounded,\s*size:\s*16,\s*color:\s*Colors\.teal\)'
        Replacement = 'Icon(Icons.hotel_rounded, size: 16, color: AppColors.presupuestoAlojamiento)'
        Description = 'Icono alojamiento'
    },
    
    # Gradientes de presupuesto
    @{
        Pattern = 'colors:\s*\[Colors\.orange\.shade400,\s*Colors\.orange\.shade600\]'
        Replacement = 'colors: [AppColors.presupuestoGastosVarios.shade400, AppColors.presupuestoGastosVarios.shade600]'
        Description = 'Gradiente gastos varios'
    },
    
    # Colores amber para gastos varios
    @{
        Pattern = 'Colors\.amber\[700\]'
        Replacement = 'AppColors.presupuestoGastosVarios.shade700'
        Description = 'Amber 700 gastos varios'
    },
    @{
        Pattern = 'Colors\.amber\[800\]'
        Replacement = 'AppColors.presupuestoGastosVarios.shade800'
        Description = 'Amber 800 gastos varios'
    },
    @{
        Pattern = 'color:\s*Colors\.amber\b'
        Replacement = 'color: AppColors.presupuestoGastosVarios'
        Description = 'Color amber base'
    }
)

$totalFiles = $filesToProcess.Count
$modifiedFiles = 0
$totalReplacements = 0
$fileReplacements = @{}

Write-Host "Iniciando refactorizacion de colores semanticos en activityDetail..." -ForegroundColor Cyan
Write-Host "Total de archivos a procesar: $totalFiles" -ForegroundColor Yellow
Write-Host ""

foreach ($file in $filesToProcess) {
    $content = Get-Content $file.FullName -Raw -Encoding UTF8
    $originalContent = $content
    $fileModified = $false
    $fileReplacementCount = 0
    
    foreach ($replacement in $replacements) {
        $matches = [regex]::Matches($content, $replacement.Pattern)
        if ($matches.Count -gt 0) {
            $content = $content -replace $replacement.Pattern, $replacement.Replacement
            $fileReplacementCount += $matches.Count
            $fileModified = $true
            
            Write-Host "  OK $($file.Name): $($matches.Count) x $($replacement.Description)" -ForegroundColor Green
        }
    }
    
    if ($fileModified) {
        # Guardar el archivo modificado
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
        $modifiedFiles++
        $totalReplacements += $fileReplacementCount
        $fileReplacements[$file.Name] = $fileReplacementCount
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RESUMEN DE REFACTORIZACION" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Archivos procesados: $totalFiles" -ForegroundColor Yellow
Write-Host "Archivos modificados: $modifiedFiles" -ForegroundColor Green
Write-Host "Total de reemplazos: $totalReplacements" -ForegroundColor Green
Write-Host ""

if ($modifiedFiles -gt 0) {
    Write-Host "Archivos modificados en detalle:" -ForegroundColor Yellow
    foreach ($file in $fileReplacements.GetEnumerator() | Sort-Object Value -Descending) {
        Write-Host "  - $($file.Key): $($file.Value) reemplazos" -ForegroundColor White
    }
}

Write-Host ""
Write-Host "Refactorizacion completada" -ForegroundColor Green
Write-Host "Ejecuta flutter analyze para verificar que no hay errores" -ForegroundColor Yellow
