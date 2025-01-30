import 'package:dio/dio.dart';

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

  Future<Map<String, dynamic>?> authenticate(
      String email, String password) async {
    try {
      Response response = await _dio.get('/profesor');
      if (response.statusCode == 200 && response.data.isNotEmpty) {
        final profesores = response.data as List;
        final profesor = profesores.firstWhere(
          (prof) =>
              prof['correo'] == email &&
              prof['password'] == password &&
              prof['activo'] == 1,
          orElse: () => null,
        );
        return profesor;
      }
      return null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
  // Puedes agregar más métodos para PUT, DELETE, etc.
}
