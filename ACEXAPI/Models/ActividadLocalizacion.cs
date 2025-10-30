using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ACEXAPI.Models
{
    /// <summary>
    /// Tabla intermedia para la relación muchos-a-muchos entre Actividades y Localizaciones
    /// </summary>
    [Table("ActividadLocalizaciones")]
    public class ActividadLocalizacion
    {
        [Key]
        public int Id { get; set; }

        [Required]
        public int ActividadId { get; set; }

        [Required]
        public int LocalizacionId { get; set; }

        /// <summary>
        /// Indica si esta es la localización principal de la actividad
        /// </summary>
        public bool EsPrincipal { get; set; } = false;

        /// <summary>
        /// Orden de la localización en la lista (para itinerarios)
        /// </summary>
        public int Orden { get; set; } = 0;

        /// <summary>
        /// Descripción o comentario sobre esta localización en el contexto de la actividad
        /// </summary>
        [StringLength(500)]
        public string? Descripcion { get; set; }

        /// <summary>
        /// Tipo de localización: "Punto de salida", "Punto de llegada", "Alojamiento", "Actividad"
        /// </summary>
        [StringLength(50)]
        public string? TipoLocalizacion { get; set; }

        /// <summary>
        /// Fecha en la que se asignó esta localización a la actividad
        /// </summary>
        public DateTime FechaAsignacion { get; set; } = DateTime.UtcNow;

        // Relaciones
        [ForeignKey("ActividadId")]
        public virtual Actividad? Actividad { get; set; }

        [ForeignKey("LocalizacionId")]
        public virtual Localizacion? Localizacion { get; set; }
    }
}
