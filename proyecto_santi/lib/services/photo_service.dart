import 'package:dio/dio.dart';
import 'package:proyecto_santi/models/photo.dart';
import 'package:proyecto_santi/services/api_service.dart';
import 'package:proyecto_santi/config.dart';
class PhotoService {
  final ApiService _apiService;
  PhotoService(this._apiService);
  Future<List<Photo>> fetchPhotos() async {
    try {
      final response = await _apiService.getData(AppConfig.fotoEndpoint);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Photo.fromJson(json)).toList();
      }
      throw ApiException('Error al obtener fotos', statusCode: response.statusCode);
    } catch (e) {
      print('[PhotoService ERROR] fetchPhotos: $e');
      rethrow;
    }
  }
  Future<List<Photo>> fetchPhotosByActivityId(int activityId) async {
    try {
      final response = await _apiService.getData('${AppConfig.fotoEndpoint}/actividad/$activityId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Photo.fromJson(json)).toList();
      }
      throw ApiException('Error al obtener fotos', statusCode: response.statusCode);
    } catch (e) {
      print('[PhotoService ERROR] fetchPhotosByActivityId: $e');
      rethrow;
    }
  }
  Future<bool> uploadPhotos({
    required int activityId,
    required List<String> filePaths,
    String? descripcion,
  }) async {
    try {
      FormData formData = FormData.fromMap({
        'actividadId': activityId,
        'descripcion': descripcion ?? '',
        'fotos': filePaths.map((path) => MultipartFile.fromFileSync(path)).toList(),
      });
      final response = await _apiService.dio.post(
        '${AppConfig.fotoEndpoint}/upload',
        data: formData,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('[PhotoService ERROR] uploadPhotos: $e');
      rethrow;
    }
  }
  Future<bool> uploadPhotosFromBytes({
    required int activityId,
    required List<int> bytes,
    required String filename,
    String? descripcion,
  }) async {
    try {
      final multipartFile = MultipartFile.fromBytes(
        bytes,
        filename: filename,
      );
      FormData formData = FormData.fromMap({
        'actividadId': activityId,
        'descripcion': descripcion ?? '',
        'fotos': [multipartFile], 
      });
      final response = await _apiService.dio.post(
        '${AppConfig.fotoEndpoint}/upload',
        data: formData,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('[PhotoService ERROR] uploadPhotosFromBytes: $e');
      rethrow;
    }
  }
  Future<bool> deletePhoto(int id) async {
    try {
      final response = await _apiService.deleteData('${AppConfig.fotoEndpoint}/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('[PhotoService ERROR] deletePhoto: $e');
      rethrow;
    }
  }
  Future<bool> updatePhotoDescription(int photoId, String? descripcion) async {
    try {
      final response = await _apiService.dio.patch(
        '${AppConfig.fotoEndpoint}/$photoId/descripcion',
        data: {
          'descripcion': descripcion ?? '',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      print('[PhotoService ERROR] updatePhotoDescription: $e');
      rethrow;
    }
  }
}