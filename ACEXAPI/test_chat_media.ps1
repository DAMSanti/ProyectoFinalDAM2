# Script para probar el endpoint de chat media

# 1. Crear una imagen de prueba
echo "Creando imagen de prueba..."
$imagePath = "test_image.jpg"

# Crear una imagen simple de 1x1 pixel
Add-Type -AssemblyName System.Drawing
$bmp = New-Object System.Drawing.Bitmap(100, 100)
$graphics = [System.Drawing.Graphics]::FromImage($bmp)
$graphics.Clear([System.Drawing.Color]::Blue)
$bmp.Save($imagePath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$graphics.Dispose()
$bmp.Dispose()

Write-Host "✅ Imagen creada: $imagePath" -ForegroundColor Green

# 2. Probar el endpoint de subida
Write-Host "`nProbando endpoint POST /api/ChatMedia/upload..." -ForegroundColor Cyan

$url = "http://localhost:5000/api/ChatMedia/upload"
$actividadId = "test-actividad-123"
$userId = "user-001"

try {
    $response = Invoke-WebRequest -Uri $url -Method Post -Form @{
        file = Get-Item -Path $imagePath
        actividadId = $actividadId
        userId = $userId
    }
    
    $result = $response.Content | ConvertFrom-Json
    
    Write-Host "✅ ÉXITO - Archivo subido correctamente" -ForegroundColor Green
    Write-Host "URL del archivo: $($result.url)" -ForegroundColor Yellow
    Write-Host "Nombre del archivo: $($result.fileName)" -ForegroundColor Yellow
    Write-Host "Tamaño: $($result.size) bytes" -ForegroundColor Yellow
    
    # 3. Verificar que el archivo existe
    $expectedPath = "G:\ProyectoFinalCSharp\ProyectoFinalDAM2\ACEXAPI\wwwroot\chat_media\$actividadId\$($result.fileName)"
    
    if (Test-Path $expectedPath) {
        Write-Host "`n✅ Archivo guardado correctamente en: $expectedPath" -ForegroundColor Green
    } else {
        Write-Host "`n❌ ERROR: Archivo NO encontrado en: $expectedPath" -ForegroundColor Red
    }
    
} catch {
    Write-Host "❌ ERROR al subir archivo: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Detalles: $($_.ErrorDetails.Message)" -ForegroundColor Yellow
}

# Limpiar
Remove-Item $imagePath -ErrorAction SilentlyContinue

Write-Host "`n🎯 Prueba completada. Presiona Enter para continuar..." -ForegroundColor Cyan
Read-Host
