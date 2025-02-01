import 'package:dio/dio.dart';
import 'package:proyecto_santi/models/actividad.dart';
import 'package:proyecto_santi/models/profesor.dart';
import 'package:proyecto_santi/models/photo.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://4.233.223.75:8080/api/'));

  Future<Response> getData(String endpoint) async {
    try {
      Response response = await _dio.get(endpoint);
      return response;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<Response> postData(String endpoint, Map<String, dynamic> data) async {
    try {
      Response response = await _dio.post(endpoint, data: data);
      return response;
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Future<Profesor?> authenticate(String email, String password) async {
    try {
      Response response = await _dio.get('/profesor');
      if (response.statusCode == 200 && response.data.isNotEmpty) {
        final profesores = response.data as List;
        final profesorData = profesores.firstWhere(
          (prof) =>
              prof['correo'] == email &&
              prof['password'] == password &&
              prof['activo'] == 1,
          orElse: () => null,
        );
        if (profesorData != null) {
          return Profesor.fromJson(profesorData);
        }
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<List<Actividad>> fetchActivities() async {
    try {
      final response = await _dio.get('/actividad');
      if (response.statusCode == 500) {
        throw Exception("Internal Server Error. Please try again later.");
      } else if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        final currentDate = DateTime.now();
        return data.map((json) => Actividad.fromJson(json)).where((actividad) {
          final activityDate = DateTime.parse(actividad.fini);
          return activityDate.isAfter(currentDate);
        }).toList();
      } else {
        throw Exception("Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Exception: ${e.toString()}");
    }
  }

  Future<Actividad?> fetchActivityById(int id) async {
    try {
      final response = await _dio.get('/actividad/$id');
      if (response.statusCode == 200) {
        return Actividad.fromJson(response.data);
      } else {
        throw Exception("Error: ${response.statusCode}");
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<List<Photo>> fetchPhotos() async {
    try {
      final response = await _dio.get('/foto');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Photo.fromJson(json)).toList();
      } else {
        throw Exception("Error: ${response.statusCode}");
      }
    } catch (e) {
      print('Error: $e');
      throw Exception("Exception: ${e.toString()}");
    }
  }

  Future<List<Photo>> fetchPhotosByActivityId(int activityId) async {
    final allPhotos = await fetchPhotos();
    return allPhotos.where((photo) => photo.actividad.id == activityId).toList();
  }
  // Puedes agregar más métodos para PUT, DELETE, etc.
}
