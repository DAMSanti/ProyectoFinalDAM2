namespace ACEXAPI.DTOs;

public class FotoDto
{
    public int Id { get; set; }
    public int ActividadId { get; set; }
    public string Url { get; set; } = string.Empty;
    public string? UrlThumbnail { get; set; }
    public string? Descripcion { get; set; }
    public DateTime FechaSubida { get; set; }
    public long TamanoBytes { get; set; }
}

public class FotoUploadDto
{
    public int ActividadId { get; set; }
    public string? Descripcion { get; set; }
}
