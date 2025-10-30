#!/usr/bin/env pwsh
# Script de diagnóstico completo para el sistema de notificaciones

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "DIAGNÓSTICO DEL SISTEMA DE NOTIFICACIONES" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 1. Verificar archivo de credenciales
Write-Host "1. Verificando archivo de credenciales de Firebase..." -ForegroundColor Yellow
$credentialsExist = Test-Path ".\ACEXAPI\firebase-credentials.json"
if ($credentialsExist) {
    Write-Host "   ✓ firebase-credentials.json existe" -ForegroundColor Green
    $content = Get-Content ".\ACEXAPI\firebase-credentials.json" | ConvertFrom-Json
    Write-Host "   ✓ Project ID: $($content.project_id)" -ForegroundColor Green
} else {
    Write-Host "   ✗ firebase-credentials.json NO existe" -ForegroundColor Red
    Write-Host "   → Descárgalo de: https://console.firebase.google.com" -ForegroundColor Yellow
}
Write-Host ""

# 2. Verificar que el backend compile
Write-Host "2. Verificando compilación del backend..." -ForegroundColor Yellow
Push-Location ACEXAPI
$buildResult = dotnet build --no-restore 2>&1
$buildSuccess = $LASTEXITCODE -eq 0
Pop-Location

if ($buildSuccess) {
    Write-Host "   ✓ Backend compila correctamente" -ForegroundColor Green
} else {
    Write-Host "   ✗ Error de compilación" -ForegroundColor Red
    Write-Host $buildResult -ForegroundColor Red
}
Write-Host ""

# 3. Verificar tabla FcmTokens
Write-Host "3. Verificando tabla FcmTokens en la BD..." -ForegroundColor Yellow
$sqlQuery = @"
SET NOCOUNT ON;
SELECT COUNT(*) as Total FROM FcmTokens WHERE Activo = 1;
"@

try {
    $result = Invoke-Sqlcmd -ServerInstance "64.226.85.100,1433" `
                           -Database "ACEXAPI" `
                           -Username "SA" `
                           -Password "Semicrol_10!" `
                           -Query $sqlQuery `
                           -ErrorAction Stop

    $tokenCount = $result.Total
    if ($tokenCount -gt 0) {
        Write-Host "   ✓ Hay $tokenCount token(s) FCM registrado(s)" -ForegroundColor Green
    } else {
        Write-Host "   ✗ NO hay tokens FCM registrados" -ForegroundColor Red
        Write-Host "   → Inicia sesión desde la app para registrar el token" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ✗ Error conectando a la BD: $_" -ForegroundColor Red
}
Write-Host ""

# 4. Verificar detalles de tokens
Write-Host "4. Detalles de tokens registrados..." -ForegroundColor Yellow
$detailQuery = @"
SET NOCOUNT ON;
SELECT TOP 5
    u.NombreUsuario,
    t.DeviceType,
    LEFT(t.Token, 20) + '...' as TokenPreview,
    t.FechaCreacion,
    t.Activo
FROM FcmTokens t
LEFT JOIN Usuarios u ON t.UsuarioId = u.Id
ORDER BY t.FechaCreacion DESC;
"@

try {
    $details = Invoke-Sqlcmd -ServerInstance "64.226.85.100,1433" `
                             -Database "ACEXAPI" `
                             -Username "SA" `
                             -Password "Semicrol_10!" `
                             -Query $detailQuery `
                             -ErrorAction Stop

    if ($details) {
        $details | Format-Table -AutoSize
    } else {
        Write-Host "   → No hay tokens registrados aún" -ForegroundColor Yellow
    }
} catch {
    Write-Host "   ✗ Error: $_" -ForegroundColor Red
}
Write-Host ""

# 5. Verificar estructura del proyecto Flutter
Write-Host "5. Verificando estructura del proyecto Flutter..." -ForegroundColor Yellow
$flutterFiles = @(
    "proyecto_santi\lib\services\notification_service.dart",
    "proyecto_santi\lib\services\chat\firebase_chat_service.dart",
    "proyecto_santi\pubspec.yaml"
)

foreach ($file in $flutterFiles) {
    if (Test-Path $file) {
        Write-Host "   ✓ $file" -ForegroundColor Green
    } else {
        Write-Host "   ✗ $file NO encontrado" -ForegroundColor Red
    }
}
Write-Host ""

# 6. Verificar google-services.json (Android)
Write-Host "6. Verificando configuración de Firebase en Android..." -ForegroundColor Yellow
$googleServicesPath = "proyecto_santi\android\app\google-services.json"
if (Test-Path $googleServicesPath) {
    Write-Host "   ✓ google-services.json configurado" -ForegroundColor Green
} else {
    Write-Host "   ✗ google-services.json NO encontrado" -ForegroundColor Red
    Write-Host "   → Descárgalo desde Firebase Console" -ForegroundColor Yellow
}
Write-Host ""

# 7. Verificar permisos en AndroidManifest
Write-Host "7. Verificando permisos en AndroidManifest.xml..." -ForegroundColor Yellow
$manifestPath = "proyecto_santi\android\app\src\main\AndroidManifest.xml"
if (Test-Path $manifestPath) {
    $manifest = Get-Content $manifestPath -Raw
    $hasInternet = $manifest -match "android.permission.INTERNET"
    $hasNotifications = $manifest -match "android.permission.POST_NOTIFICATIONS"
    
    if ($hasInternet) {
        Write-Host "   ✓ Permiso INTERNET" -ForegroundColor Green
    } else {
        Write-Host "   ✗ Falta permiso INTERNET" -ForegroundColor Red
    }
    
    if ($hasNotifications) {
        Write-Host "   ✓ Permiso POST_NOTIFICATIONS" -ForegroundColor Green
    } else {
        Write-Host "   ⚠ Falta permiso POST_NOTIFICATIONS (Android 13+)" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ✗ AndroidManifest.xml no encontrado" -ForegroundColor Red
}
Write-Host ""

# Resumen
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "RESUMEN Y PRÓXIMOS PASOS" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Si no llegan notificaciones, verifica:" -ForegroundColor Yellow
Write-Host "1. Tokens FCM registrados en BD (debe haber al menos 1)" -ForegroundColor White
Write-Host "2. Firebase credentials configurado correctamente" -ForegroundColor White
Write-Host "3. google-services.json en Android" -ForegroundColor White
Write-Host "4. Permisos de notificación habilitados en el dispositivo" -ForegroundColor White
Write-Host "5. Logs del backend al enviar mensajes de chat" -ForegroundColor White
Write-Host ""
Write-Host "Para probar AHORA:" -ForegroundColor Cyan
Write-Host "  1. cd ACEXAPI" -ForegroundColor White
Write-Host "  2. dotnet run" -ForegroundColor White
Write-Host "  3. Desde la app, iniciar sesión" -ForegroundColor White
Write-Host "  4. Enviar un mensaje en el chat" -ForegroundColor White
Write-Host "  5. Revisar logs del backend" -ForegroundColor White
Write-Host ""
