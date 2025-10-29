using System;
using System.Data.SqlClient;

// Script para corregir codificación UTF-8 en actividades
var connectionString = "Server=64.226.85.100,1433;Initial Catalog=ACEXAPI;User ID=SA;Password=Semicrol_10!;MultipleActiveResultSets=True;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;";

using (var connection = new SqlConnection(connectionString))
{
    connection.Open();
    Console.WriteLine("✓ Conectado a la base de datos");

    var updates = new[]
    {
        new { Id = 31, Nombre = "Excursión a Parque Natural" },
        new { Id = 32, Nombre = "Jornada de Orientación Académica" },
        new { Id = 33, Nombre = "Torneo de Fútbol Sala" }
    };

    foreach (var update in updates)
    {
        using (var command = new SqlCommand("UPDATE Actividades SET Nombre = @Nombre WHERE Id = @Id", connection))
        {
            command.Parameters.AddWithValue("@Id", update.Id);
            command.Parameters.AddWithValue("@Nombre", update.Nombre);
            
            var affected = command.ExecuteNonQuery();
            Console.WriteLine($"✓ Actualizado: {update.Nombre} ({affected} fila)");
        }
    }

    Console.WriteLine("\n=== Verificando resultados ===");
    using (var command = new SqlCommand("SELECT Id, Nombre FROM Actividades WHERE Id IN (31, 32, 33) ORDER BY Id", connection))
    using (var reader = command.ExecuteReader())
    {
        while (reader.Read())
        {
            Console.WriteLine($"ID: {reader.GetInt32(0)} - Nombre: {reader.GetString(1)}");
        }
    }
}

Console.WriteLine("\n✓ Corrección completada");
