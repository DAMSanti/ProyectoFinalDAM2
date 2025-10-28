namespace ACEXAPI.DTOs
{
    public class GastoPersonalizadoDto
    {
        public int Id { get; set; }
        public int ActividadId { get; set; }
        public string Concepto { get; set; } = string.Empty;
        public decimal Cantidad { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }

    public class CreateGastoPersonalizadoDto
    {
        public int ActividadId { get; set; }
        public string Concepto { get; set; } = string.Empty;
        public decimal Cantidad { get; set; }
    }
}
