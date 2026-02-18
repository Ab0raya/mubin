import 'package:dio/dio.dart';
import '../../utils/constants.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
    ),
  );

  Future<Response> getPrayerTimes(String date) async {
    return await _dio.get(
      '${Constants.apiUrl}/timingsByCity/$date',
      queryParameters: {
        'city': Constants.city,
        'country': Constants.country,
        'method': Constants.method,
      },
    );
  }

  Future<Response> getPrayerTimesByCoordinates(
    double lat,
    double lng,
    int method,
    String date,
  ) async {
    return await _dio.get(
      '${Constants.apiUrl}/timings/$date',
      queryParameters: {'latitude': lat, 'longitude': lng, 'method': method},
    );
  }
}
