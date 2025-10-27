# Script para crear usuario admin con hash BCrypt correcto
Write-Host "Creando usuario admin..." -ForegroundColor Cyan

$sqlCommand = @"
USE ACEXAPI;
GO

-- Eliminar usuario admin si existe
DELETE FROM Usuarios WHERE Email = 'admin@acexapi.com';

-- Insertar usuario admin con hash BCrypt válido para 'admin123'
-- Hash generado con BCrypt online (workfactor 10)
INSERT INTO Usuarios (Id, Email, NombreCompleto, Password, Rol, FechaCreacion, Activo)
VALUES (
    NEWID(),
    'admin@acexapi.com',
    'Administrador del Sistema',
    '$2a$10$N9qo8uLOickgx2ZMRZoMye/IjJZJdvVJ7RkW4yuHvJ.qZfD5Iz9sG',
    'Admin',
    GETDATE(),
    1
);

PRINT 'Usuario admin creado correctamente';
PRINT 'Email: admin@acexapi.com';
PRINT 'Password: admin123';

SELECT * FROM Usuarios WHERE Email = 'admin@acexapi.com';
GO
"@

# Guardar temporalmente con UTF-8 BOM
$tempFile = [System.IO.Path]::GetTempFileName()
$utf8BOM = New-Object System.Text.UTF8Encoding $true
[System.IO.File]::WriteAllText($tempFile, $sqlCommand, $utf8BOM)

try {
    sqlcmd -S 'localhost\SQLEXPRESS' -U sa -P 'Semicrol_10' -i $tempFile -W
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "[OK] Usuario admin creado" -ForegroundColor Green
        Write-Host "Email: admin@acexapi.com" -ForegroundColor White
        Write-Host "Password: admin123" -ForegroundColor White
    }
} finally {
    if (Test-Path $tempFile) {
        Remove-Item $tempFile -Force
    }
}

Write-Host ""
