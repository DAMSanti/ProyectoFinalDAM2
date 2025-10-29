# Script PowerShell para corregir codificación UTF-8
$connectionString = "Server=64.226.85.100,1433;Initial Catalog=ACEXAPI;User ID=SA;Password=Semicrol_10!;MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;"

Write-Host "Conectando a la base de datos..." -ForegroundColor Cyan

$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()

Write-Host "✓ Conectado exitosamente" -ForegroundColor Green
Write-Host ""

# Actividades a corregir
$actividades = @(
    @{Id=31; Nombre="Excursión a Parque Natural"},
    @{Id=32; Nombre="Jornada de Orientación Académica"},
    @{Id=33; Nombre="Torneo de Fútbol Sala"}
)

foreach ($act in $actividades) {
    $command = $connection.CreateCommand()
    $command.CommandText = "UPDATE Actividades SET Nombre = @Nombre WHERE Id = @Id"
    
    $paramId = $command.Parameters.Add("@Id", [System.Data.SqlDbType]::Int)
    $paramId.Value = $act.Id
    
    $paramNombre = $command.Parameters.Add("@Nombre", [System.Data.SqlDbType]::NVarChar, 200)
    $paramNombre.Value = $act.Nombre
    
    $affected = $command.ExecuteNonQuery()
    Write-Host "✓ Actualizado ID $($act.Id): $($act.Nombre) ($affected fila)" -ForegroundColor Green
}

Write-Host ""
Write-Host "=== Verificando resultados ===" -ForegroundColor Yellow
Write-Host ""

$commandVerify = $connection.CreateCommand()
$commandVerify.CommandText = "SELECT Id, Nombre FROM Actividades WHERE Id IN (31, 32, 33) ORDER BY Id"
$reader = $commandVerify.ExecuteReader()

while ($reader.Read()) {
    Write-Host "ID: $($reader['Id']) - Nombre: $($reader['Nombre'])" -ForegroundColor White
}

$reader.Close()
$connection.Close()

Write-Host ""
Write-Host "✓ Corrección completada" -ForegroundColor Green
