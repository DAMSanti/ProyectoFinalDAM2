import 'package:proyecto_santi/services/chat/backend_storage_service.dart';
import 'package:proyecto_santi/config.dart';

/// Servicio para manejar subida de archivos (usa backend C# en lugar de Firebase Storage)
class FirebaseStorageService {
  late final BackendStorageService _backendStorage;

  FirebaseStorageService() {
    // Obtener la URL base del backend desde la configuración
    // Eliminar el '/api' del final porque BackendStorageService lo agrega
    final baseUrl = AppConfig.apiBaseUrl.replaceAll('/api', '');
    _backendStorage = BackendStorageService(
      baseUrl: baseUrl,
    );
  }

  /// Sube una imagen al backend y devuelve la URL
  Future<String> uploadImage({
    required String actividadId,
    required String userId,
    required dynamic imageFile, // File (mobile) o Uint8List (web)
    String? fileName,
    Function(double)? onProgress,
  }) async {
    return await _backendStorage.uploadImage(
      actividadId: actividadId,
      userId: userId,
      imageFile: imageFile,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  /// Sube un video al backend y devuelve la URL
  Future<String> uploadVideo({
    required String actividadId,
    required String userId,
    required dynamic videoFile, // File (mobile) o Uint8List (web)
    String? fileName,
    Function(double)? onProgress,
  }) async {
    return await _backendStorage.uploadVideo(
      actividadId: actividadId,
      userId: userId,
      videoFile: videoFile,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  /// Sube un audio al backend y devuelve la URL
  Future<String> uploadAudio({
    required String actividadId,
    required String userId,
    required dynamic audioFile, // File (mobile) o Uint8List (web)
    String? fileName,
    Function(double)? onProgress,
  }) async {
    return await _backendStorage.uploadAudio(
      actividadId: actividadId,
      userId: userId,
      audioFile: audioFile,
      fileName: fileName,
      onProgress: onProgress,
    );
  }

  /// Elimina un archivo del backend dada su URL
  Future<void> deleteFile(String fileUrl) async {
    try {
      // Extraer actividadId y fileName de la URL
      // Ejemplo: http://localhost:5000/chat_media/123/user_abc.jpg
      final uri = Uri.parse(fileUrl);
      final pathSegments = uri.pathSegments;
      
      if (pathSegments.length >= 3 && pathSegments[0] == 'chat_media') {
        final actividadId = pathSegments[1];
        final fileName = pathSegments[2];
        
        await _backendStorage.deleteFile(
          actividadId: actividadId,
          fileName: fileName,
        );
      } else {
        throw Exception('URL de archivo inválida');
      }
    } catch (e) {
      throw Exception('Error al eliminar archivo: $e');
    }
  }

  /// Obtiene el progreso de una subida (no implementado para backend, retorna stream vacío)
  Stream<double> getUploadProgress(dynamic task) {
    // Esta funcionalidad ya no aplica con el backend
    // El progreso se maneja con callbacks en los métodos upload
    return Stream.value(1.0);
  }
}
