import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class SettingsController extends GetxController {
  final box = GetStorage();

  // Settings State
  var isDarkMode = true.obs;
  var enableNotifications = true.obs;
  var prayerCalculationMethod = 5.obs; // Egypt
  var asrCalculationMethod = 0.obs; // Shafii (Standard)
  var quranReciter = 'Mishary Rashid Alafasy'.obs;
  var currentLanguage = 'en'.obs;
  var quranFontSize = 28.0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    // Load from storage or use defaults
    // enableNotifications.value = box.read('notifications') ?? true;
    quranFontSize.value = box.read('quranFontSize') ?? 28.0;
  }

  void updateQuranFontSize(double value) {
    quranFontSize.value = value;
    box.write('quranFontSize', value);
  }

  void toggleNotifications(bool value) {
    enableNotifications.value = value;
    box.write('notifications', value);
  }

  void updateCalculationMethod(int value) {
    prayerCalculationMethod.value = value;
    box.write('calc_method', value);
  }

  void updateLanguage(String value) {
    currentLanguage.value = value;
    var locale = Locale(value, value == 'ar' ? 'SA' : 'US');
    Get.updateLocale(locale);
    box.write('language', value);
  }
}
