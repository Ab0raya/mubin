import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import '../../utils/constants.dart';
import '../routes/app_routes.dart';

class BackendService extends GetxService {
  late final Dio _dio;
  final _box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(
      BaseOptions(
        baseUrl: Constants.backendBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Request interceptor to dynamically inject authorization token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _box.read(Constants.keyAuthToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            debugPrint("Unauthorized request (401). Clearing local auth...");
            _clearAuth();
            
            // Redirect to login if user is logged out unexpectedly
            if (Get.currentRoute != AppRoutes.login) {
              Get.offAllNamed(AppRoutes.login);
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  void _clearAuth() {
    _box.remove(Constants.keyAuthToken);
    _box.write(Constants.keyIsLoggedIn, false);
  }

  // --- Auth Endpoints ---

  Future<Response> register({
    required String username,
    required String email,
    required String password,
  }) async {
    return await _dio.post('/register', data: {
      'username': username,
      'email': email,
      'password': password,
    });
  }

  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await _dio.post('/login', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response> getMe() async {
    return await _dio.get('/me');
  }

  Future<Response> logout() async {
    try {
      final response = await _dio.post('/logout');
      _clearAuth();
      return response;
    } catch (e) {
      _clearAuth(); // Still clear local session if server fails
      rethrow;
    }
  }

  // --- Password Reset Endpoints ---

  Future<Response> forgotPassword(String email) async {
    return await _dio.post('/password/forget', data: {
      'email': email,
    });
  }

  Future<Response> resetPassword({
    required String email,
    required String otp,
    required String password,
  }) async {
    return await _dio.post('/password/reset', data: {
      'email': email,
      'otp': otp,
      'password': password,
    });
  }

  // --- Points Endpoints ---

  Future<Response> logPoints({
    required String type,
    required int amount,
  }) async {
    return await _dio.post('/points', data: {
      'type': type,
      'amount': amount,
    });
  }

  // --- Leaderboard Endpoints ---

  Future<Response> getLeaderboard(String period) async {
    // period can be 'all', 'day', 'week', 'month'
    final path = '/points/$period';
    return await _dio.get(path);
  }
}
