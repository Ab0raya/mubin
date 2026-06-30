import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:hijri/hijri_calendar.dart';
import '../services/backend_service.dart';

class ProfileController extends GetxController {
  final box = GetStorage();

  // User Stats
  var userName = 'Abdullah'.obs;
  var joinedDate = 'Ramadan 1445'.obs;
  var imanLevel = 1.obs;
  var currentStreak = 0.obs;
  var totalPrayers = 0.obs;
  var quranPagesRead = 0.obs;

  // Heatmap Data (Mock for now - 1: Low, 2: Med, 3: High)
  var activityData = <DateTime, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
    _generateMockHeatmap();
  }

  Future<void> fetchProfile() async {
    try {
      final backendService = Get.find<BackendService>();
      final response = await backendService.getMe();
      final userData = response.data;

      // Extract user info
      userName.value = userData['username'] ?? 'User';
      
      // Streak and points
      final int points = userData['points'] ?? 0;
      currentStreak.value = userData['current_streak'] ?? 0;
      
      // Iman Level dynamically calculated from total points
      imanLevel.value = (points / 100).floor() + 1;

      // Format created_at to Hijri date
      if (userData['created_at'] != null) {
        try {
          final DateTime createdAt = DateTime.parse(userData['created_at']);
          final hijri = HijriCalendar.fromDate(createdAt);
          // Set to Arabic or English based on app setting if needed
          final currentLang = box.read('language') ?? 'en';
          HijriCalendar.setLocal(currentLang);
          joinedDate.value = hijri.toFormat("MMMM yyyy");
        } catch (e) {
          debugPrint("Error formatting Hijri date: $e");
          joinedDate.value = 'Ramadan 1445'; // Fallback
        }
      }

      // Persist totalPrayers and quranPagesRead locally using GetStorage
      totalPrayers.value = box.read('total_prayers') ?? 142;
      quranPagesRead.value = box.read('quran_pages_read') ?? 89;

    } catch (e) {
      debugPrint("Error fetching user profile: $e");
      userName.value = box.read('username') ?? 'User';
      totalPrayers.value = box.read('total_prayers') ?? 142;
      quranPagesRead.value = box.read('quran_pages_read') ?? 89;
    }
  }

  void _generateMockHeatmap() {
    // Generate dummy data for the last 60 days
    final now = DateTime.now();
    for (int i = 0; i < 60; i++) {
      final date = now.subtract(Duration(days: i));
      if (i % 7 != 0) {
        activityData[DateTime(date.year, date.month, date.day)] = (i % 4) + 1;
      }
    }
  }
}
