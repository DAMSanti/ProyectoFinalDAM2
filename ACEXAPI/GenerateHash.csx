using System;
using BCrypt.Net;

// Generar hash BCrypt para "admin123"
string password = "admin123";
string hash = BCrypt.Net.BCrypt.HashPassword(password, 11);

Console.WriteLine($"Password: {password}");
Console.WriteLine($"Hash: {hash}");
Console.WriteLine();
Console.WriteLine("SQL para insertar:");
Console.WriteLine($"INSERT INTO Usuarios (Id, Email, NombreCompleto, Password, Rol, FechaCreacion, Activo) VALUES (NEWID(), 'admin@acexapi.com', 'Administrador del Sistema', '{hash}', 'Admin', GETDATE(), 1);");
