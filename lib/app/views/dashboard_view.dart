import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import 'home_view.dart';
import 'quran_reading/quran_view.dart';
// import 'community_view.dart';
import 'stats_view.dart';
import 'profile/profile_view.dart';
import 'praying_tracker/praying_tracker_view.dart';
import 'widgets/custom_bottom_nav.dart';
import '../../utils/colors.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            const HomeView(),
            const QuranView(),
            const PrayingTrackerView(),
            const StatsView(),
            const ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => CustomBottomNav(
          selectedIndex: controller.currentIndex.value,
          onTap: controller.changeIndex,
        ),
      ),
    );
  }
}
