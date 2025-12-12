using Microsoft.AspNetCore.Mvc;
using System.IO;
using System.Threading.Tasks;
namespace ACEXAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ChatMediaController : ControllerBase
    {
        private readonly IWebHostEnvironment _environment;
        private readonly ILogger<ChatMediaController> _logger;
        public ChatMediaController(IWebHostEnvironment environment, ILogger<ChatMediaController> logger)
        {
            _environment = environment;
            _logger = logger;
        }
        [HttpPost("upload")]
        [Consumes("multipart/form-data")]
        public async Task<IActionResult> UploadFile(IFormFile file, [FromForm] string actividadId, [FromForm] string userId)
        {
            try
            {
                if (file == null || file.Length == 0)
                {
                    return BadRequest(new { error = "No se recibió ningún archivo" });
                }
                if (file.Length > 50 * 1024 * 1024)
                {
                    return BadRequest(new { error = "El archivo es demasiado grande. Máximo 50MB" });
                }
                var allowedTypes = new[] { "image/jpeg", "image/jpg", "image/png", "image/gif", "image/webp",
                                          "video/mp4", "video/webm", "video/quicktime",
                                          "audio/mpeg", "audio/mp4", "audio/m4a", "audio/wav", "audio/webm" };
                if (!allowedTypes.Contains(file.ContentType.ToLower()))
                {
                    return BadRequest(new { error = $"Tipo de archivo no permitido: {file.ContentType}" });
                }
                var uploadPath = Path.Combine(_environment.WebRootPath, "chat_media", actividadId);
                if (!Directory.Exists(uploadPath))
                {
                    Directory.CreateDirectory(uploadPath);
                }
                var fileExtension = Path.GetExtension(file.FileName);
                var uniqueFileName = $"{userId}_{Guid.NewGuid()}{fileExtension}";
                var filePath = Path.Combine(uploadPath, uniqueFileName);
                using (var stream = new FileStream(filePath, FileMode.Create))
                {
                    await file.CopyToAsync(stream);
                }
                var fileUrl = $"{Request.Scheme}://{Request.Host}/chat_media/{actividadId}/{uniqueFileName}";
                _logger.LogInformation($"Archivo subido correctamente: {fileUrl}");
                return Ok(new
                {
                    success = true,
                    url = fileUrl,
                    fileName = uniqueFileName,
                    contentType = file.ContentType,
                    size = file.Length
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al subir archivo: {ex.Message}");
                return StatusCode(500, new { error = "Error al subir el archivo", details = ex.Message });
            }
        }
        [HttpDelete("delete")]
        public IActionResult DeleteFile([FromQuery] string actividadId, [FromQuery] string fileName)
        {
            try
            {
                if (string.IsNullOrEmpty(actividadId) || string.IsNullOrEmpty(fileName))
                {
                    return BadRequest(new { error = "Faltan parámetros requeridos" });
                }
                var filePath = Path.Combine(_environment.WebRootPath, "chat_media", actividadId, fileName);
                if (!System.IO.File.Exists(filePath))
                {
                    return NotFound(new { error = "Archivo no encontrado" });
                }
                System.IO.File.Delete(filePath);
                _logger.LogInformation($"Archivo eliminado: {fileName}");
                return Ok(new { success = true, message = "Archivo eliminado correctamente" });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al eliminar archivo: {ex.Message}");
                return StatusCode(500, new { error = "Error al eliminar el archivo", details = ex.Message });
            }
        }
        [HttpGet("info")]
        public IActionResult GetFileInfo([FromQuery] string actividadId, [FromQuery] string fileName)
        {
            try
            {
                var filePath = Path.Combine(_environment.WebRootPath, "chat_media", actividadId, fileName);
                if (!System.IO.File.Exists(filePath))
                {
                    return NotFound(new { error = "Archivo no encontrado" });
                }
                var fileInfo = new FileInfo(filePath);
                return Ok(new
                {
                    fileName = fileName,
                    size = fileInfo.Length,
                    createdAt = fileInfo.CreationTime,
                    modifiedAt = fileInfo.LastWriteTime
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Error al obtener información del archivo: {ex.Message}");
                return StatusCode(500, new { error = "Error al obtener información", details = ex.Message });
            }
        }
    }
}