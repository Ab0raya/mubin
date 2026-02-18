import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:mubin/utils/constants.dart';
import 'package:mubin/app/routes/app_routes.dart';
import 'package:permission_handler/permission_handler.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final box = GetStorage();

  // Observable State
  var currentPage = 0.obs;
  var selectedLanguage = 'en'.obs; // Default English
  var isLocationGranted = false.obs;
  var isNotificationGranted = false.obs;
  var isCameraGranted = false.obs;
  var selectedCalculationMethod =
      5.obs; // Default: Egyptian General Authority of Survey
  var isLoading = false.obs;

  // Location Data
  double? latitude;
  double? longitude;

  @override
  void onInit() {
    super.onInit();
    // Check initial permissions status without requesting
    _checkPermissionsStatus();
  }

  Future<void> _checkPermissionsStatus() async {
    // Check Location
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      isLocationGranted.value = true;
      _getCurrentLocation();
    }

    // Check Notification
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    isNotificationGranted.value = isAllowed;

    // Check Camera
    var cameraStatus = await Permission.camera.status;
    isCameraGranted.value = cameraStatus.isGranted;
  }

  void nextPage() {
    if (currentPage.value < 3) {
      // 0: Intro/Lang, 1: Permissions, 2: Calculation, 3: Final
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value++;
    } else {
      finishOnboarding();
    }
  }

  void previousPage() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value--;
    }
  }

  // --- Logic Steps ---

  // 1. Language Selection
  void setLanguage(String langCode) {
    selectedLanguage.value = langCode;
    var locale = Locale(langCode, langCode == 'ar' ? 'SA' : 'US');
    Get.updateLocale(locale);
  }

  // 2. Permissions
  Future<void> requestLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Location Service', 'Please enable location services.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Permission Denied',
          'Location permission is required for accurate prayer times.',
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Permission Denied',
        'Location permission is permanently denied. Please enable it in settings.',
      );
      return;
    }

    isLocationGranted.value = true;
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      latitude = position.latitude;
      longitude = position.longitude;
      debugPrint("Location obtained: $latitude, $longitude");
    } catch (e) {
      debugPrint("Error getting location: $e");
    }
  }

  Future<void> requestNotification() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications()
          .requestPermissionToSendNotifications();
    }
    isNotificationGranted.value = isAllowed;
  }

  Future<void> requestCamera() async {
    var status = await Permission.camera.request();
    isCameraGranted.value = status.isGranted;

    if (status.isPermanentlyDenied) {
      Get.snackbar(
        'Permission Denied',
        'Camera permission is permanently denied. Please enable it in settings.',
      );
      openAppSettings();
    }
  }

  // 3. Calculation Method
  void setCalculationMethod(int methodId) {
    selectedCalculationMethod.value = methodId;
  }

  // 4. Finish
  Future<void> finishOnboarding() async {
    isLoading.value = true;

    // Save all preferences
    box.write(Constants.keyOnboardingComplete, true);
    box.write(Constants.keyLanguage, selectedLanguage.value);
    box.write(Constants.keyCalculationMethod, selectedCalculationMethod.value);

    if (latitude != null && longitude != null) {
      box.write(Constants.keyLatitude, latitude);
      box.write(Constants.keyLongitude, longitude);
    }

    // Simulate setup delay
    await Future.delayed(const Duration(seconds: 1));

    isLoading.value = false;
    Get.offAllNamed(AppRoutes.home); // Navigate to Home
  }
}
