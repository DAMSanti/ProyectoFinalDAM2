#!/usr/bin/env pwsh
# Script para diagnosticar el sistema de notificaciones

Write-Host "=== DIAGNÓSTICO DEL SISTEMA DE NOTIFICACIONES ===" -ForegroundColor Cyan
Write-Host ""

# 1. Login para obtener token
Write-Host "1. Obteniendo token JWT..." -ForegroundColor Yellow
$loginBody = @{
    nombreUsuario = "admin"
    password = "Admin123!"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-RestMethod -Uri "http://localhost:5000/api/Auth/login" `
                                       -Method Post `
                                       -Body $loginBody `
                                       -ContentType "application/json"
    
    $token = $loginResponse.token
    Write-Host "   ✓ Token obtenido exitosamente" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "   ✗ Error al hacer login: $_" -ForegroundColor Red
    Write-Host "   → Asegúrate de que el backend esté corriendo en http://localhost:5000" -ForegroundColor Yellow
    exit 1
}

# 2. Llamar al endpoint de diagnóstico
Write-Host "2. Obteniendo diagnóstico del sistema..." -ForegroundColor Yellow
$headers = @{
    "Authorization" = "Bearer $token"
}

try {
    $diagnostics = Invoke-RestMethod -Uri "http://localhost:5000/api/Notification/diagnostics" `
                                     -Method Get `
                                     -Headers $headers
    
    Write-Host "   ✓ Diagnóstico obtenido" -ForegroundColor Green
    Write-Host ""
    
    # Mostrar resultados
    Write-Host "=== RESULTADOS ===" -ForegroundColor Cyan
    Write-Host ""
    
    Write-Host "Firebase:" -ForegroundColor Yellow
    Write-Host "  Status: $($diagnostics.firebase.status)" -ForegroundColor $(if($diagnostics.firebase.initialized){"Green"}else{"Red"})
    Write-Host "  Initialized: $($diagnostics.firebase.initialized)" -ForegroundColor $(if($diagnostics.firebase.initialized){"Green"}else{"Red"})
    Write-Host ""
    
    Write-Host "Tokens FCM:" -ForegroundColor Yellow
    Write-Host "  Total tokens activos: $($diagnostics.tokens.total)" -ForegroundColor $(if($diagnostics.tokens.total -gt 0){"Green"}else{"Red"})
    Write-Host "  Usuarios con tokens: $($diagnostics.tokens.usuarios)" -ForegroundColor $(if($diagnostics.tokens.usuarios -gt 0){"Green"}else{"Red"})
    Write-Host ""
    
    if ($diagnostics.usuario) {
        Write-Host "Tu usuario:" -ForegroundColor Yellow
        Write-Host "  Tokens registrados: $($diagnostics.usuario.tokensRegistrados)" -ForegroundColor $(if($diagnostics.usuario.tokensRegistrados -gt 0){"Green"}else{"Red"})
        
        if ($diagnostics.usuario.dispositivos -and $diagnostics.usuario.dispositivos.Count -gt 0) {
            Write-Host "  Dispositivos:" -ForegroundColor Yellow
            foreach ($device in $diagnostics.usuario.dispositivos) {
                Write-Host "    - Tipo: $($device.DeviceType), ID: $($device.DeviceId)" -ForegroundColor White
                Write-Host "      Token: $($device.TokenPreview)" -ForegroundColor Gray
                Write-Host "      Registrado: $($device.FechaCreacion)" -ForegroundColor Gray
            }
        }
    }
    Write-Host ""
    
    # Análisis
    Write-Host "=== ANÁLISIS ===" -ForegroundColor Cyan
    Write-Host ""
    
    $hasIssues = $false
    
    if (-not $diagnostics.firebase.initialized) {
        Write-Host "✗ PROBLEMA: Firebase NO está inicializado" -ForegroundColor Red
        Write-Host "  → Verifica que firebase-credentials.json exista y sea válido" -ForegroundColor Yellow
        $hasIssues = $true
    } else {
        Write-Host "✓ Firebase está inicializado correctamente" -ForegroundColor Green
    }
    
    if ($diagnostics.tokens.total -eq 0) {
        Write-Host "✗ PROBLEMA: No hay tokens FCM registrados" -ForegroundColor Red
        Write-Host "  → Inicia sesión desde la app móvil para registrar el token" -ForegroundColor Yellow
        $hasIssues = $true
    } else {
        Write-Host "✓ Hay tokens FCM registrados" -ForegroundColor Green
    }
    
    if ($diagnostics.usuario -and $diagnostics.usuario.tokensRegistrados -eq 0) {
        Write-Host "⚠ Tu usuario no tiene tokens registrados" -ForegroundColor Yellow
        Write-Host "  → Inicia sesión desde la app para registrar tu token" -ForegroundColor Yellow
    }
    
    Write-Host ""
    
    if (-not $hasIssues) {
        Write-Host "=== ✓ SISTEMA LISTO ===" -ForegroundColor Green
        Write-Host "El sistema de notificaciones está configurado correctamente." -ForegroundColor Green
        Write-Host "Si no recibes notificaciones, verifica:" -ForegroundColor Yellow
        Write-Host "  1. Permisos de notificación en el dispositivo" -ForegroundColor White
        Write-Host "  2. google-services.json en Android" -ForegroundColor White
        Write-Host "  3. Que envíes mensajes desde un usuario diferente" -ForegroundColor White
    } else {
        Write-Host "=== ✗ HAY PROBLEMAS ===" -ForegroundColor Red
        Write-Host "Revisa los problemas indicados arriba." -ForegroundColor Red
    }
    
} catch {
    Write-Host "   ✗ Error al obtener diagnóstico: $_" -ForegroundColor Red
    Write-Host "   Respuesta: $($_.Exception.Response)" -ForegroundColor Gray
}

Write-Host ""
