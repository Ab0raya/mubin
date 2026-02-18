import 'package:get/get.dart';

import '../controllers/praying_tracker_controller.dart';

class DashboardController extends GetxController {
  var currentIndex = 0.obs;

  void changeIndex(int index) {
    currentIndex.value = index;

    // Manage Camera Lifecycle
    if (Get.isRegistered<PrayingTrackerController>()) {
      final trackerController = Get.find<PrayingTrackerController>();
      if (index == 2) {
        // Tab 2 is PrayingTracker / AI Monitor
        trackerController.initializeCamera();
      } else {
        trackerController.disposeCamera();
      }
    }
  }
}
