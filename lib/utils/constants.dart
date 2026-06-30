import 'dart:io';
import 'package:flutter/foundation.dart';

// Define constants here
class Constants {
  static const String appName = "Mubin";
  static const String apiUrl = "https://api.aladhan.com/v1";

  static String get backendBaseUrl {
    if (!kIsWeb && Platform.isAndroid) {
      return "http://10.0.2.2:8000/api/v1";
    }
    return "http://127.0.0.1:8000/api/v1";
  }

  static const String city = 'Cairo';
  static const String country = 'Egypt';
  static const int method = 5;

  // Storage Keys
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyLanguage = 'language';
  static const String keyCalculationMethod = 'calculation_method';
  static const String keyLatitude = 'latitude';
  static const String keyLongitude = 'longitude';
  static const String keyCityName = 'city_name';
  static const String keyIsLoggedIn = 'is_logged_in';
  static const String keyAzanType = 'azan_type';
  static const String keyAuthToken = 'auth_token';
}
