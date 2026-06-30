import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import '../../../utils/constants.dart';
import '../../../utils/startup_profiler.dart';
import '../../routes/app_routes.dart';
import '../../services/backend_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Allow animation to play and visually brand the app
    await Future.delayed(const Duration(milliseconds: 1200));

    // Measure time up to navigation (First Frame is displayed now)
    StartupProfiler.log("Splash Screen Exit");
    StartupProfiler.printReport();

    final box = GetStorage();
    bool isOnboardingComplete = box.read(Constants.keyOnboardingComplete) == true;

    if (!isOnboardingComplete) {
      Get.offAllNamed(AppRoutes.onboarding);
      return;
    }

    bool isLoggedIn = box.read(Constants.keyIsLoggedIn) == true;
    final token = box.read(Constants.keyAuthToken);

    if (isLoggedIn && token != null) {
      try {
        final backendService = Get.find<BackendService>();
        await backendService.getMe();
        Get.offAllNamed(AppRoutes.home);
      } catch (e) {
        if (e is DioException && 
            (e.type == DioExceptionType.connectionTimeout || 
             e.type == DioExceptionType.receiveTimeout || 
             e.type == DioExceptionType.connectionError)) {
          debugPrint("Network error during splash token validation, bypassing to home.");
          Get.offAllNamed(AppRoutes.home);
        } else {
          debugPrint("Auth token validation failed: $e. Routing to login.");
          Get.offAllNamed(AppRoutes.login);
        }
      }
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
