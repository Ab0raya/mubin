import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mubin/app/controllers/home_controller.dart';
import 'package:mubin/app/views/widgets/header_widget.dart';
import 'package:mubin/app/views/widgets/menu_grid_widget.dart';
import 'package:mubin/app/views/widgets/prayer_schedule_widget.dart';
import 'package:mubin/app/views/widgets/quran_progress_widget.dart';

import '../../utils/colors.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.primary, // Dark Green top
            AppColors.background, // Darker bottom
          ],
          stops: [0.0, 0.4],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Header Row
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Obx(
                        () => Text(
                          controller.userName.value.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Obx(
                        () => Text(
                          controller.hijriDateString.value.isEmpty
                              ? 'loading'.tr
                              : controller.hijriDateString.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const CircleAvatar(
                      backgroundColor: AppColors.primary, // Theme color
                      child: Icon(Icons.settings, color: Colors.white),
                    ),
                    onPressed: () => Get.toNamed('/settings'),
                  ),
                ],
              ),
            ),

            // Expanded content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const HeaderWidget(),
                    const SizedBox(height: 30),
                    const QuranProgressWidget(),
                    const SizedBox(height: 30),
                    const MenuGridWidget(),
                    const SizedBox(height: 30),
                    const PrayerScheduleWidget(),
                    const SizedBox(height: 100), // Spacing for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
