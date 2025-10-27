namespace ACEXAPI.DTOs;

using ACEXAPI.Models;

public class FotoDto
{
    public int Id { get; set; }
    public int ActividadId { get; set; }
    public string Url { get; set; } = string.Empty;
    public string? UrlThumbnail { get; set; }
    public string? Descripcion { get; set; }
    public DateTime FechaSubida { get; set; }
    public long TamanoBytes { get; set; }

    public static FotoDto FromEntity(Foto foto)
    {
        return new FotoDto
        {
            Id = foto.Id,
            ActividadId = foto.ActividadId,
            Url = foto.Url,
            UrlThumbnail = foto.UrlThumbnail,
            Descripcion = foto.Descripcion,
            FechaSubida = foto.FechaSubida,
            TamanoBytes = foto.TamanoBytes
        };
    }
}

public class FotoUploadDto
{
    public int ActividadId { get; set; }
    public string? Descripcion { get; set; }
}
