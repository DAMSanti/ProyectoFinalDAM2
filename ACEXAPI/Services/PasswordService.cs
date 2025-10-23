using System.Security.Cryptography;
using System.Text;

namespace ACEXAPI.Services;

public class PasswordService : IPasswordService
{
    public string HashPassword(string password)
    {
        if (string.IsNullOrWhiteSpace(password))
        {
            throw new ArgumentException("La contraseña no puede estar vacía", nameof(password));
        }
        
        // Usar BCrypt para hashear contraseñas de forma segura
        return BCrypt.Net.BCrypt.HashPassword(password);
    }

    public bool VerifyPassword(string password, string hash)
    {
        // Si el hash está vacío, la contraseña no está configurada
        if (string.IsNullOrWhiteSpace(hash))
        {
            return false;
        }
        
        // Verificar contraseña con BCrypt
        try
        {
            return BCrypt.Net.BCrypt.Verify(password, hash);
        }
        catch (Exception)
        {
            // Si el hash no es válido, devolver false
            return false;
        }
    }
}
