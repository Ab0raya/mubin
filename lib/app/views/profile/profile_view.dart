import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mubin/app/controllers/profile_controller.dart';
import 'package:mubin/utils/colors.dart';
// import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart'; // Will use custom grid if package not available

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'my_sanctuary'.tr,
          style: const TextStyle(color: AppColors.gold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildStatsOverview(),
            const SizedBox(height: 32),
            _buildIbadahHeatmap(),
            const SizedBox(height: 32),
            _buildBadges(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.gold, width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.gold.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.card,
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => Text(
            controller.userName.value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Obx(
          () => Text(
            "${'level_prefix'.tr} ${controller.imanLevel.value} • ${'scholar_in_training'.tr}",
            style: TextStyle(
              fontSize: 14,
              color: AppColors.secondary.withOpacity(0.8),
              letterSpacing: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsOverview() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _statCard(
          'streak'.tr,
          '${controller.currentStreak.value}',
          Icons.local_fire_department,
          AppColors.orange,
        ),
        _statCard(
          'prayers_stat'.tr,
          '${controller.totalPrayers.value}',
          Icons.mosque,
          AppColors.secondary,
        ),
        _statCard(
          'quran_stat'.tr,
          '${controller.quranPagesRead.value}',
          Icons.menu_book,
          AppColors.blue,
        ),
      ],
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIbadahHeatmap() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "ibadah_consistency".tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Simple grid for visual demo without external package dependency for now
              // Assuming 7 rows (days) and X columns (weeks)
              // double itemSize = (constraints.maxWidth - 40) / 10;
              return Wrap(
                spacing: 4,
                runSpacing: 4,
                children: List.generate(60, (index) {
                  // Mock intensity
                  bool isActive = index % 3 != 0;
                  int intensity = index % 4;
                  return Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.secondary.withOpacity(
                              0.2 + (intensity * 0.2),
                            )
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBadges() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "achievements".tr,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _badgeItem(Icons.sunny, "achievement_early_bird".tr, true),
            const SizedBox(width: 16),
            _badgeItem(Icons.nights_stay, "achievement_night_owl".tr, true),
            const SizedBox(width: 16),
            _badgeItem(Icons.book, "achievement_hafiz".tr, false),
          ],
        ),
      ],
    );
  }

  Widget _badgeItem(IconData icon, String label, bool unlocked) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: unlocked
                ? AppColors.gold.withOpacity(0.2)
                : Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: unlocked ? AppColors.gold : Colors.white.withOpacity(0.1),
            ),
          ),
          child: Icon(
            icon,
            color: unlocked ? AppColors.gold : Colors.grey,
            size: 32,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: unlocked ? Colors.white : Colors.grey,
            fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
