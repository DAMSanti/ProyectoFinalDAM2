$file = 'proyecto_santi\lib\services\api_service.dart'
$content = Get-Content $file -Raw

# Eliminar el método duplicado y los caracteres problemáticos
$content = $content -replace '  Future<void> deleteFolleto\(int actividadId\) async \{[^}]*\} n  \}\s*\n\s*\n\s*Future<void> deleteFolleto\(int actividadId\) async \{[^}]*\} n  \}', @'
  Future<void> deleteFolleto(int actividadId) async {
    try {
      print('[API] Deleting folleto for actividad $actividadId');
      
      final response = await _dio.delete('/Actividad/$actividadId/folleto');
      
      if (response.statusCode != 200) {
        throw Exception('Error al eliminar el folleto');
      }
    } catch (e) {
      print('[API ERROR] deleteFolleto: $e');
      throw _handleError(e);
    }
  }
'@

Set-Content $file -Value $content -NoNewline
Write-Host "Archivo corregido correctamente"
