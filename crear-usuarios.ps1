# Script para crear usuarios de prueba usando la API
# Ejecutar después de iniciar la API

Write-Host ""
Write-Host "CREAR USUARIOS DE PRUEBA" -ForegroundColor Cyan
Write-Host "========================" -ForegroundColor Cyan
Write-Host ""

$apiUrl = "https://localhost:7139"

# Ignorar errores de certificado SSL
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

# Función para verificar si la API está disponible
function Test-ApiAvailable {
    try {
        $null = Invoke-RestMethod -Uri "$apiUrl/api/dev/list-users" -Method Get -ErrorAction SilentlyContinue -TimeoutSec 3
        return $true
    } catch {
        return $false
    }
}

# Verificar si la API está corriendo
Write-Host "Verificando API en $apiUrl..." -ForegroundColor Yellow

$maxAttempts = 3
$attempt = 0
$apiAvailable = $false

while ($attempt -lt $maxAttempts -and -not $apiAvailable) {
    $attempt++
    Write-Host "Intento $attempt de $maxAttempts..." -ForegroundColor Gray
    
    $apiAvailable = Test-ApiAvailable
    
    if (-not $apiAvailable -and $attempt -lt $maxAttempts) {
        Write-Host "API no disponible, esperando 3 segundos..." -ForegroundColor Yellow
        Start-Sleep -Seconds 3
    }
}

if (-not $apiAvailable) {
    Write-Host ""
    Write-Host "ERROR: La API no está disponible en $apiUrl" -ForegroundColor Red
    Write-Host ""
    Write-Host "Asegúrate de que la API esté corriendo:" -ForegroundColor Yellow
    Write-Host "  cd ACEXAPI" -ForegroundColor White
    Write-Host "  dotnet run" -ForegroundColor White
    Write-Host ""
    Read-Host "Presiona Enter para cerrar"
    exit 1
}

Write-Host "✓ API disponible" -ForegroundColor Green
Write-Host ""

# Crear usuarios de prueba usando el endpoint de desarrollo
Write-Host "Creando usuarios de prueba..." -ForegroundColor Yellow

try {
    $response = Invoke-RestMethod -Uri "$apiUrl/api/dev/seed-users" -Method Post
    
    Write-Host ""
    Write-Host "✓ USUARIOS CREADOS EXITOSAMENTE!" -ForegroundColor Green
    Write-Host ""
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "USUARIOS DE PRUEBA DISPONIBLES:" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    
    foreach ($usuario in $response.usuarios) {
        Write-Host "Email: $($usuario.email)" -ForegroundColor White
        Write-Host "Nombre: $($usuario.nombreCompleto)" -ForegroundColor Gray
        Write-Host "Rol: $($usuario.rol)" -ForegroundColor Yellow
        Write-Host "Password: $($usuario.passwordHint)" -ForegroundColor Green
        Write-Host ""
    }
    
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Ahora puedes iniciar sesión en la aplicación" -ForegroundColor Yellow
    Write-Host "con cualquiera de estos usuarios." -ForegroundColor Yellow
    Write-Host ""
    
} catch {
    Write-Host ""
    Write-Host "ERROR al crear usuarios: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Detalles del error:" -ForegroundColor Yellow
    Write-Host $_.Exception.Message -ForegroundColor Gray
    Write-Host ""
}

Read-Host "Presiona Enter para cerrar"
