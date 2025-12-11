import 'dart:io';
import 'dart:typed_data';
import 'package:proyecto_santi/services/chat/backend_storage_service.dart';
import 'package:proyecto_santi/config.dart';
class FirebaseStorageService {
  late final BackendStorageService _backendStorage;
  FirebaseStorageService() {
    final baseUrl = AppConfig.apiBaseUrl.replaceAll('/api', '');
    _backendStorage = BackendStorageService(
      baseUrl: baseUrl,
    );
  }
  Future<String> uploadImage({
    required String actividadId,
    required String userId,
    required dynamic imageFile, 
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
  Future<String> uploadVideo({
    required String actividadId,
    required String userId,
    required dynamic videoFile, 
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
  Future<String> uploadAudio({
    required String actividadId,
    required String userId,
    required dynamic audioFile, 
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
  Future<void> deleteFile(String fileUrl) async {
    try {
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
  Stream<double> getUploadProgress(dynamic task) {
    return Stream.value(1.0);
  }
}