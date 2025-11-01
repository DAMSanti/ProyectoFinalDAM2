# Script focalizado para corregir errores especificos del script anterior
# Solo procesa 5 archivos problematicos

$archivos = @(
    "proyecto_santi\lib\views\activityDetail\widgets\budget\budget_sections.dart",
    "proyecto_santi\lib\views\activityDetail\dialogs\folleto_upload_dialog.dart",
    "proyecto_santi\lib\views\activityDetail\widgets\lists\grupo_list.dart",
    "proyecto_santi\lib\views\activityDetail\widgets\lists\profesor_list.dart",
    "proyecto_santi\lib\views\activityDetail\dialogs\layouts\edit_localizacion_portrait_layout.dart"
)

$reemplazos = @(
    @{ Pattern = '\bbackgroundColor: Colors\.purple\b'; Replacement = 'backgroundColor: AppColors.tipoComplementaria'; Descripcion = 'Tipo Complementaria (morado)' },
    @{ Pattern = '\bbackgroundColor: Colors\.teal\b'; Replacement = 'backgroundColor: AppColors.presupuestoAlojamiento'; Descripcion = 'Presupuesto Alojamiento (teal)' },
    @{ Pattern = '\bbackgroundColor: Colors\.red\b'; Replacement = 'backgroundColor: AppColors.estadoRechazado'; Descripcion = 'Estado Rechazado (rojo)' },
    @{ Pattern = '\bactiveColor: Colors\.red\b'; Replacement = 'activeColor: AppColors.estadoRechazado'; Descripcion = 'Active Color Rechazado' }
)

Write-Host "Iniciando correccion de errores especificos..."
$totalArchivos = 0
$totalReemplazos = 0

foreach ($archivo in $archivos) {
    if (Test-Path $archivo) {
        $contenido = Get-Content $archivo -Raw -Encoding UTF8
        $modificado = $false
        
        foreach ($reemplazo in $reemplazos) {
            if ($contenido -match $reemplazo.Pattern) {
                $contenido = $contenido -replace $reemplazo.Pattern, $reemplazo.Replacement
                $modificado = $true
                $totalReemplazos++
                Write-Host "  OK $($archivo.Split('\')[-1]): $($reemplazo.Descripcion)"
            }
        }
        
        if ($modificado) {
            $contenido | Set-Content $archivo -Encoding UTF8 -NoNewline
            $totalArchivos++
        }
    }
}

Write-Host "`nArchivos procesados: $totalArchivos"
Write-Host "Total de reemplazos: $totalReemplazos"
Write-Host "`nEjecuta 'flutter analyze' para verificar"
