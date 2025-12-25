import 'package:dio/dio.dart';


class OpenMapStreetApi {
  OpenMapStreetApi({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: 'https://nominatim.openstreetmap.org',
              connectTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
              headers: const {
                'User-Agent': 'rentverse-app/1.0 (flutter)',
                'Accept': 'application/json',
              },
            ),
          );

  final Dio _dio;

  Dio get client => _dio;

  Future<Response<dynamic>> reverseGeocode({
    required double lat,
    required double lon,
  }) async {
    return _dio.get(
      '/reverse',
      queryParameters: {
        'format': 'jsonv2',
        'lat': lat,
        'lon': lon,
        'addressdetails': 1,
      },
    );
  }
}
