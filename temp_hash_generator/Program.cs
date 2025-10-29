string password = args.Length > 0 ? args[0] : "admin123";
string hash = BCrypt.Net.BCrypt.HashPassword(password);
Console.WriteLine(hash);


