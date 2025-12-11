import 'package:dio/dio.dart';
class GeocodingResult {
  final String displayName;
  final double lat;
  final double lon;
  final String? road;
  final String? city;
  final String? state;
  final String? postcode;
  final String? type;
  final String? houseNumber;
  GeocodingResult({
    required this.displayName,
    required this.lat,
    required this.lon,
    this.road,
    this.city,
    this.state,
    this.postcode,
    this.type,
    this.houseNumber,
  });
  factory GeocodingResult.fromLocationIQ(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>?;
    return GeocodingResult(
      displayName: json['display_name'] as String,
      lat: double.parse(json['lat'].toString()),
      lon: double.parse(json['lon'].toString()),
      road: address?['road']?.toString(),
      city: address?['city']?.toString() ?? 
            address?['town']?.toString() ?? 
            address?['village']?.toString(),
      state: address?['state']?.toString(),
      postcode: address?['postcode']?.toString(),
      type: json['type']?.toString(),
      houseNumber: address?['house_number']?.toString(),
    );
  }
}
class GeocodingService {
  final Dio _dio;
  static const String _apiKey = 'pk.0f147952a41c555a5b70614039fd148b';
  GeocodingService() : _dio = Dio(BaseOptions(
    baseUrl: 'https:
    connectTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
  ));
  Future<List<GeocodingResult>> searchAddress(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }
    try {
      final searchQuery = query.contains('Cantabria') || query.contains('España')
          ? query
          : '$query, Cantabria, España';
      print('[GeocodingService] Buscando: $searchQuery');
      final response = await _dio.get(
        '/search.php',
        queryParameters: {
          'key': _apiKey,
          'q': searchQuery,
          'format': 'json',
          'addressdetails': 1,
          'limit': 15,
          'countrycodes': 'es',
          'viewbox': '-4.5,43.0,-3.5,43.7', 
          'bounded': 1,
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List;
        print('[GeocodingService] Resultados encontrados: ${data.length}');
        final results = data
            .map((json) => GeocodingResult.fromLocationIQ(json as Map<String, dynamic>))
            .toList();
        return _filterResults(results, query);
      }
      return [];
    } catch (e, stackTrace) {
      print('[GeocodingService ERROR] searchAddress: $e');
      return [];
    }
  }
  List<GeocodingResult> _filterResults(List<GeocodingResult> results, String query) {
    final filtered = <GeocodingResult>[];
    final seenLocations = <String>{};
    final normalizedQuery = query.toLowerCase().trim();
    for (var result in results) {
      final locationKey = '${result.lat.toStringAsFixed(4)}_${result.lon.toStringAsFixed(4)}';
      if (seenLocations.contains(locationKey)) continue;
      final hasNumberInQuery = RegExp(r'\d').hasMatch(normalizedQuery);
      if (hasNumberInQuery && result.houseNumber == null) {
        continue; 
      }
      filtered.add(result);
      seenLocations.add(locationKey);
      if (filtered.length >= 8) break;
    }
    filtered.sort((a, b) {
      if (a.houseNumber != null && b.houseNumber == null) return -1;
      if (a.houseNumber == null && b.houseNumber != null) return 1;
      return 0;
    });
    return filtered;
  }
  Future<GeocodingResult?> reverseGeocode(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '/reverse.php',
        queryParameters: {
          'key': _apiKey,
          'lat': lat.toString(),
          'lon': lon.toString(),
          'format': 'json',
          'addressdetails': 1,
        },
      );
      if (response.statusCode == 200) {
        return GeocodingResult.fromLocationIQ(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('[GeocodingService ERROR] reverseGeocode: $e');
      return null;
    }
  }
}