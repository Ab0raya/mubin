import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mubin/app/controllers/settings_controller.dart';
import 'package:mubin/utils/colors.dart';
import 'package:mubin/utils/constants.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text('settings'.tr, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSectionHeader('appearance_language'.tr),
            _buildSettingsCard([
              _buildLanguageTile(),
              _buildSwitchTile(
                'dark_mode'.tr,
                'easy_on_eyes'.tr,
                controller.isDarkMode.value,
                (val) {},
              ), // Mock for now
            ]),

            const SizedBox(height: 24),
            _buildSectionHeader('worship_ibadah'.tr),
            _buildSettingsCard([
              _buildTile(
                'calculation_method'.tr,
                "Egyptian General Authority", // This might need dynamic value based on selection
                Icons.access_time,
              ),
              _buildTile(
                'asr_method'.tr,
                'standard_method'.tr,
                Icons.accessibility_new,
              ),
              _buildTile(
                'quran_reciter'.tr,
                controller.quranReciter.value,
                Icons.mic,
              ),
              Obx(
                () => _buildSliderTile(
                  'quran_font_size'.tr,
                  'adjust_font_size'.tr,
                  controller.quranFontSize.value,
                  (val) => controller.updateQuranFontSize(val),
                  min: 20,
                  max: 60,
                ),
              ),
            ]),

            const SizedBox(height: 24),
            _buildSectionHeader('notifications'.tr),
            _buildSettingsCard([
              Obx(
                () => _buildSwitchTile(
                  'adhan_notifications'.tr,
                  'notify_every_prayer'.tr,
                  controller.enableNotifications.value,
                  controller.toggleNotifications,
                ),
              ),
              _buildTile(
                'pre_prayer_reminder'.tr,
                'minutes_before'.tr,
                Icons.alarm,
              ),
            ]),

            const SizedBox(height: 24),
            Text(
              "${'version'.tr} 1.0.0",
              style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 48),

            // Sign Out
            TextButton(
              onPressed: () {
                // Get.offAllNamed('/auth/login');
              },
              child: Text(
                'sign_out'.tr,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        bottom: 12,
        left: 4,
        right: 4,
      ), // Added right padding for RTL
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.secondary.withOpacity(0.8),
          fontSize: 14,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: children.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget w = entry.value;
          return Column(
            children: [
              w,
              if (idx != children.length - 1)
                Divider(
                  height: 1,
                  color: Colors.white.withOpacity(0.05),
                  indent: 16,
                  endIndent: 16,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTile(
    String title,
    String subtitle,
    IconData icon, {
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Colors.grey,
        size: 14,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: onTap ?? () {},
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.secondary,
        activeTrackColor: AppColors.secondary.withOpacity(0.3),
        inactiveThumbColor: Colors.grey,
        inactiveTrackColor: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        'language'.tr,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: Obx(
        () => DropdownButton<String>(
          value: controller.currentLanguage.value,
          dropdownColor: AppColors.card,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          style: const TextStyle(color: Colors.white),
          items: [
            DropdownMenuItem(value: 'en', child: Text('english'.tr)),
            DropdownMenuItem(value: 'ar', child: Text('arabic'.tr)),
          ],
          onChanged: (val) {
            if (val != null) controller.updateLanguage(val);
          },
        ),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    double value,
    Function(double) onChanged, {
    double min = 0.0,
    double max = 1.0,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          trailing: Text(
            "${value.toInt()}",
            style: const TextStyle(
              color: AppColors.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          activeColor: AppColors.secondary,
          inactiveColor: Colors.white.withOpacity(0.1),
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
