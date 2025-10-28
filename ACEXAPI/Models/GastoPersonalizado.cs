using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ACEXAPI.Models
{
    [Table("GastosPersonalizados")]
    public class GastoPersonalizado
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int ActividadId { get; set; }

        [Required]
        [StringLength(200)]
        public string Concepto { get; set; } = string.Empty;

        [Required]
        [Column(TypeName = "decimal(18,2)")]
        public decimal Cantidad { get; set; }

        public DateTime FechaCreacion { get; set; } = DateTime.Now;

        // Navegación
        [ForeignKey("ActividadId")]
        public virtual Actividad? Actividad { get; set; }
    }
}
