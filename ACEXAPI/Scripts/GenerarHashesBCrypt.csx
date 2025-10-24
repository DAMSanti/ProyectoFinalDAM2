using System;

// Script simple para generar hashes BCrypt
// Compilar y ejecutar: dotnet run

Console.WriteLine("Generando hashes BCrypt...");
Console.WriteLine();

var passwords = new Dictionary<string, string>
{
    { "admin123", "Administrador" },
    { "coord123", "Coordinador" },
    { "profesor123", "Profesor" },
    { "usuario123", "Usuario" }
};

foreach (var kvp in passwords)
{
    var hash = BCrypt.Net.BCrypt.HashPassword(kvp.Key);
    Console.WriteLine($"{kvp.Value}:");
    Console.WriteLine($"  Password: {kvp.Key}");
    Console.WriteLine($"  Hash: {hash}");
    Console.WriteLine();
}

Console.WriteLine("Presiona Enter para salir...");
Console.ReadLine();
