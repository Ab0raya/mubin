import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';
import '../../utils/colors.dart';
import '../../utils/constants.dart';
import '../services/backend_service.dart';
import 'profile_controller.dart';
import 'stats_controller.dart';

class CounterController extends GetxController {
  final box = GetStorage();
  var count = 0.obs;
  var dhikrText = 'سبحان الله'.obs;

  final List<String> dhikrTemplates = [
    'سبحان الله',
    'الحمد لله',
    'لا إله إلا الله',
    'الله أكبر',
    'لا حول ولا قوة إلا بالله',
    'سبحان الله وبحمده',
    'سبحان الله العظيم',
    'أستغفر الله',
    'اللهم صل على محمد',
  ];

  @override
  void onInit() {
    super.onInit();
    // Load persisted data
    if (box.hasData('count')) {
      count.value = box.read('count');
    }
    if (box.hasData('dhikrText')) {
      dhikrText.value = box.read('dhikrText');
    }

    // Listen to changes and persist
    ever(count, (value) => box.write('count', value));
    ever(dhikrText, (value) => box.write('dhikrText', value));
  }

  void increment() {
    count.value++;
    HapticFeedback.lightImpact();

    // Automatically sync points to backend on cycles of 33
    if (count.value > 0 && count.value % 33 == 0) {
      _syncPointsToBackend();
    }
  }

  Future<void> _syncPointsToBackend() async {
    if (box.read(Constants.keyIsLoggedIn) != true) return;

    try {
      final backendService = Get.find<BackendService>();
      await backendService.logPoints(type: 'zikr', amount: 10);
      
      Get.snackbar(
        'Barakah Earned',
        '+10 points logged to your spiritual sanctuary!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.gold,
        colorText: Colors.black,
        duration: const Duration(seconds: 2),
      );

      // Dynamically update profile and leaderboard states
      if (Get.isRegistered<ProfileController>()) {
        Get.find<ProfileController>().fetchProfile();
      }
      if (Get.isRegistered<StatsController>()) {
        Get.find<StatsController>().loadStats();
      }
    } catch (e) {
      debugPrint("Failed to log zikr points: $e");
    }
  }

  void reset() {
    count.value = 0;
    HapticFeedback.mediumImpact();
  }

  void updateDhikr(String text) {
    if (text.isNotEmpty) {
      dhikrText.value = text;
    }
  }
}
