import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProfileController extends GetxController {
  final box = GetStorage();

  // User Stats
  var userName = 'Abdullah'.obs; // TODO: Fetch from Auth
  var joinedDate = 'Ramadan 1445'.obs;
  var imanLevel = 12.obs;
  var currentStreak = 5.obs;
  var totalPrayers = 142.obs;
  var quranPagesRead = 89.obs;

  // Heatmap Data (Mock for now - 1: Low, 2: Med, 3: High)
  // Map<DateTime, int>
  var activityData = <DateTime, int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
    _generateMockHeatmap();
  }

  void _loadUserProfile() {
    // In a real app, fetch from API or Local Auth Storage
    // userName.value = box.read('userName') ?? 'User';
  }

  void _generateMockHeatmap() {
    // Generate dummy data for the last 60 days
    final now = DateTime.now();
    for (int i = 0; i < 60; i++) {
      final date = now.subtract(Duration(days: i));
      // Random intensity 0-4
      if (i % 7 != 0) {
        // Skip some days
        activityData[DateTime(date.year, date.month, date.day)] = (i % 4) + 1;
      }
    }
  }
}
