import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors.dart';
import '../../routes/app_routes.dart';

class MenuGridWidget extends StatelessWidget {
  const MenuGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMenuItem(
            icon: Icons.explore,
            label: 'qibla'.tr,
            color: AppColors.gold, // Gold
            onTap: () => Get.toNamed(AppRoutes.qibla),
          ),
          _buildVerticalDivider(),
          _buildMenuItem(
            icon: Icons.menu_book,
            label: 'azkar'.tr,
            color: AppColors.secondary, // Green
            onTap: () => Get.toNamed(AppRoutes.azkar),
          ),
          _buildVerticalDivider(),
          _buildMenuItem(
            icon: Icons.fingerprint,
            label: 'counter'.tr,
            color: AppColors.blue, // Blue
            onTap: () => Get.toNamed(AppRoutes.counter),
          ),
          _buildVerticalDivider(),
          _buildMenuItem(
            icon: Icons.headphones,
            label: 'quran_audio'.tr,
            color: AppColors.orange, // Orange
            onTap: () => Get.toNamed(AppRoutes.quranAudio),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 40,
      width: 1,
      color: Colors.white.withValues(alpha: 0.1),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
