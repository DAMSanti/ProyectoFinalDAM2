// Programa simple para generar hash BCrypt
using System;

class HashGenerator
{
    static void Main(string[] args)
    {
        string password = args.Length > 0 ? args[0] : "admin123";
        string hash = BCrypt.Net.BCrypt.HashPassword(password, 11);
        Console.WriteLine(hash);
    }
}
