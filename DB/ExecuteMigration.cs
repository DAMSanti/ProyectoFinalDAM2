using System;
using System.IO;
using Microsoft.Data.SqlClient;

class Program
{
    static async Task Main(string[] args)
    {
        if (args.Length == 0)
        {
            Console.WriteLine("Uso: dotnet run <archivo.sql>");
            return;
        }

        string scriptPath = args[0];
        if (!File.Exists(scriptPath))
        {
            Console.WriteLine($"Error: No se encontró el archivo {scriptPath}");
            return;
        }

        string connectionString = "Server=64.226.85.100,1433;Initial Catalog=ACEXAPI;User ID=SA;Password=Semicrol_10!;Encrypt=True;TrustServerCertificate=True;Connection Timeout=30;";

        Console.WriteLine("Conectando a la base de datos remota...");
        
        try
        {
            using var connection = new SqlConnection(connectionString);
            await connection.OpenAsync();
            Console.WriteLine("✓ Conectado");

            string sql = await File.ReadAllTextAsync(scriptPath);
            
            // Dividir por GO
            var batches = sql.Split(new[] { "\nGO", "\r\nGO" }, StringSplitOptions.RemoveEmptyEntries);

            Console.WriteLine($"Ejecutando {batches.Length} batch(es)...\n");

            foreach (var batch in batches)
            {
                if (string.IsNullOrWhiteSpace(batch)) continue;

                using var command = new SqlCommand(batch, connection);
                command.CommandTimeout = 120;
                
                try
                {
                    await command.ExecuteNonQueryAsync();
                    Console.WriteLine("✓ Batch ejecutado");
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"✗ Error en batch: {ex.Message}");
                }
            }

            Console.WriteLine("\n✅ Migración completada");
        }
        catch (Exception ex)
        {
            Console.WriteLine($"❌ Error: {ex.Message}");
        }
    }
}
