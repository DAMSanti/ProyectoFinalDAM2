# Script para crear usuario administrador con BCrypt hash correcto
$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "CREAR USUARIO ADMINISTRADOR" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$Server = "localhost\SQLEXPRESS"
$Database = "ACEXAPI"
$User = "sa"
$Password = "Semicrol_10"

# BCrypt hash para la password "admin123"
# Generado con workfactor 10
$bcryptHash = '$2a$10$N9qo8uLOickgx2ZMRZoMye/IjJZJdvVJ7RkW4yuHvJ.qZfD5Iz9sG'

$sqlContent = @"
USE ACEXAPI;
GO

-- Insertar usuario administrador
INSERT INTO Usuarios (Id, Email, NombreCompleto, Password, Rol, FechaCreacion, Activo, ProfesorUuid)
VALUES (
    NEWID(), 
    'admin@acexapi.com', 
    'Administrador del Sistema', 
    '$bcryptHash', 
    'Admin', 
    GETDATE(), 
    1,
    NULL
);
GO

-- Verificar que se creó correctamente
SELECT Id, Email, NombreCompleto, Rol, FechaCreacion, Activo
FROM Usuarios
WHERE Email = 'admin@acexapi.com';
GO

PRINT '';
PRINT 'Usuario administrador creado correctamente';
PRINT 'Email: admin@acexapi.com';
PRINT 'Password: admin123';
GO
"@

# Crear archivo temporal con UTF-8 BOM
$tempFile = [System.IO.Path]::GetTempFileName()
$utf8BOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText($tempFile, $sqlContent, $utf8BOM)

Write-Host "Creando usuario administrador..." -ForegroundColor Yellow
Write-Host "  Email: admin@acexapi.com" -ForegroundColor White
Write-Host "  Password: admin123" -ForegroundColor White
Write-Host ""

try {
    $output = sqlcmd -S $Server -U $User -P $Password -d $Database -i $tempFile -W -b 2>&1
    
    $output | ForEach-Object {
        Write-Host $_
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Green
        Write-Host "USUARIO ADMINISTRADOR CREADO" -ForegroundColor Green
        Write-Host "========================================" -ForegroundColor Green
        Write-Host ""
        Write-Host "Credenciales:" -ForegroundColor Cyan
        Write-Host "  Email: admin@acexapi.com" -ForegroundColor White
        Write-Host "  Password: admin123" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host ""
        Write-Host "ERROR: Hubo un problema al crear el usuario" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host ""
    Write-Host "ERROR: $_" -ForegroundColor Red
    exit 1
}
finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
}
