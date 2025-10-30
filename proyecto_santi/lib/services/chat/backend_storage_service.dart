import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Servicio para subir archivos al backend C# (reemplaza Firebase Storage)
class BackendStorageService {
  final Dio _dio;
  final String _baseUrl;

  BackendStorageService({required String baseUrl})
      : _baseUrl = baseUrl,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
        ));

  /// Sube una imagen al backend y devuelve la URL
  Future<String> uploadImage({
    required String actividadId,
    required String userId,
    required dynamic imageFile, // File (mobile) o Uint8List (web)
    String? fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final formData = await _createFormData(
        file: imageFile,
        fileName: fileName ?? 'image.jpg',
        actividadId: actividadId,
        userId: userId,
      );

      final response = await _dio.post(
        '/api/ChatMedia/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null && total != -1) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['url'] as String;
      } else {
        throw Exception('Error al subir imagen: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  /// Sube un video al backend y devuelve la URL
  Future<String> uploadVideo({
    required String actividadId,
    required String userId,
    required dynamic videoFile, // File (mobile) o Uint8List (web)
    String? fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final formData = await _createFormData(
        file: videoFile,
        fileName: fileName ?? 'video.mp4',
        actividadId: actividadId,
        userId: userId,
      );

      final response = await _dio.post(
        '/api/ChatMedia/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null && total != -1) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['url'] as String;
      } else {
        throw Exception('Error al subir video: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al subir video: $e');
    }
  }

  /// Sube un audio al backend y devuelve la URL
  Future<String> uploadAudio({
    required String actividadId,
    required String userId,
    required dynamic audioFile, // File (mobile) o Uint8List (web)
    String? fileName,
    Function(double)? onProgress,
  }) async {
    try {
      final formData = await _createFormData(
        file: audioFile,
        fileName: fileName ?? 'audio.m4a',
        actividadId: actividadId,
        userId: userId,
      );

      final response = await _dio.post(
        '/api/ChatMedia/upload',
        data: formData,
        onSendProgress: (sent, total) {
          if (onProgress != null && total != -1) {
            onProgress(sent / total);
          }
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        return data['url'] as String;
      } else {
        throw Exception('Error al subir audio: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error al subir audio: $e');
    }
  }

  /// Elimina un archivo del backend
  Future<void> deleteFile({
    required String actividadId,
    required String fileName,
  }) async {
    try {
      await _dio.delete(
        '/api/ChatMedia/delete',
        queryParameters: {
          'actividadId': actividadId,
          'fileName': fileName,
        },
      );
    } catch (e) {
      throw Exception('Error al eliminar archivo: $e');
    }
  }

  /// Crea FormData compatible con Web y Mobile
  Future<FormData> _createFormData({
    required dynamic file,
    required String fileName,
    required String actividadId,
    required String userId,
  }) async {
    MultipartFile multipartFile;

    if (kIsWeb && file is Uint8List) {
      // Web: Usar bytes directamente
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
      multipartFile = MultipartFile.fromBytes(
        file,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      );
    } else if (file is File) {
      // Mobile/Desktop: Usar archivo
      final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
      multipartFile = await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      );
    } else if (file is Uint8List) {
      // Mobile pero con bytes (por ejemplo, de la cámara)
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
      multipartFile = MultipartFile.fromBytes(
        file,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      );
    } else {
      throw Exception('Tipo de archivo no soportado');
    }

    return FormData.fromMap({
      'file': multipartFile,
      'actividadId': actividadId,
      'userId': userId,
    });
  }

  /// Obtiene la información de un archivo
  Future<Map<String, dynamic>> getFileInfo({
    required String actividadId,
    required String fileName,
  }) async {
    try {
      final response = await _dio.get(
        '/api/ChatMedia/info',
        queryParameters: {
          'actividadId': actividadId,
          'fileName': fileName,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      } else {
        throw Exception('Error al obtener info del archivo');
      }
    } catch (e) {
      throw Exception('Error al obtener info del archivo: $e');
    }
  }
}
