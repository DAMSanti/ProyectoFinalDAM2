# Script para generar hash BCrypt de "admin123"
# Este hash se puede usar directamente en la base de datos

$projectPath = "G:\ProyectoFinalCSharp\ProyectoFinalDAM2\ACEXAPI"
$code = @"
using System;
using BCrypt.Net;

class Program
{
    static void Main()
    {
        string password = "admin123";
        string hash = BCrypt.HashPassword(password, 11);
        Console.WriteLine(hash);
    }
}
"@

# Guardar el código en archivo temporal
$tempFile = [System.IO.Path]::GetTempFileName()
$csFile = $tempFile -replace '\.tmp$', '.cs'
Move-Item $tempFile $csFile -Force

Set-Content -Path $csFile -Value $code

Write-Host "Generando hash BCrypt para 'admin123'..." -ForegroundColor Cyan

# Compilar y ejecutar usando el proyecto que ya tiene BCrypt.Net
$output = dotnet script $csFile --project $projectPath 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "`nHash generado exitosamente:" -ForegroundColor Green
    Write-Host $output -ForegroundColor Yellow
    
    # Crear script SQL para actualizar
    $sqlScript = @"
-- Actualizar contraseña del usuario admin
USE ACEXAPI;
GO

UPDATE Usuarios 
SET Password = '$output'
WHERE NombreUsuario = 'admin';
GO

-- Verificar
SELECT Id, NombreUsuario, Rol, ProfesorUuid, 
       LEFT(Password, 20) + '...' as PasswordHash
FROM Usuarios 
WHERE NombreUsuario = 'admin';
GO
"@
    
    $sqlFile = "G:\ProyectoFinalCSharp\ProyectoFinalDAM2\DB\update_admin_password_bcrypt.sql"
    Set-Content -Path $sqlFile -Value $sqlScript
    Write-Host "`nScript SQL creado en: $sqlFile" -ForegroundColor Green
} else {
    Write-Host "Error al generar hash: $output" -ForegroundColor Red
}

# Limpiar
Remove-Item $csFile -Force
