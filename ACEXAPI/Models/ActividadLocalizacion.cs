using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
namespace ACEXAPI.Models
{
    [Table("ActividadLocalizaciones")]
    public class ActividadLocalizacion
    {
        [Key]
        public int Id { get; set; }
        [Required]
        public int ActividadId { get; set; }
        [Required]
        public int LocalizacionId { get; set; }
        public bool EsPrincipal { get; set; } = false;
        public int Orden { get; set; } = 0;
        [StringLength(500)]
        public string? Descripcion { get; set; }
        [StringLength(50)]
        public string? TipoLocalizacion { get; set; }
        public DateTime FechaAsignacion { get; set; } = DateTime.UtcNow;
        [ForeignKey("ActividadId")]
        public virtual Actividad? Actividad { get; set; }
        [ForeignKey("LocalizacionId")]
        public virtual Localizacion? Localizacion { get; set; }
    }
}