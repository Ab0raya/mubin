import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mubin/app/controllers/settings_controller.dart';
import 'package:mubin/utils/colors.dart';

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
              Obx(
                () => _buildSwitchTile(
                  'dark_mode'.tr,
                  'easy_on_eyes'.tr,
                  controller.isDarkMode.value,
                  (val) => controller.updateDarkMode(val),
                ),
              ),
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
            ]),

            const SizedBox(height: 24),
            _buildSectionHeader('quran_reading'.tr),
            _buildSettingsCard([
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
              _buildColorPickerTile(
                title: 'reading_bg_color'.tr,
                colors: const [
                  0xFF121212, // Dark Charcoal
                  0xFF0F251D, // Deep Green
                  0xFFF4ECD8, // Warm Sepia
                  0xFFFFFFFF, // White
                ],
                selectedValue: controller.readingBgColor,
                onSelected: (val) => controller.updateReadingBgColor(val),
              ),
              _buildColorPickerTile(
                title: 'reading_text_color'.tr,
                colors: const [
                  0xFFFFFFFF, // White
                  0xFF111111, // Black
                ],
                selectedValue: controller.readingTextColor,
                onSelected: (val) => controller.updateReadingTextColor(val),
              ),
              _buildFavModeTile(),
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
              _buildTile(
                'test_azan_alarm'.tr,
                'test_azan_alarm_desc'.tr,
                Icons.volume_up,
                onTap: () => controller.triggerTestAzan(),
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

  Widget _buildFavModeTile() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(
        'fav_reading_mode'.tr,
        style: const TextStyle(color: Colors.white, fontSize: 16),
      ),
      trailing: Obx(
        () => DropdownButton<String>(
          value: controller.favReadingMode.value,
          dropdownColor: AppColors.card,
          underline: const SizedBox(),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          style: const TextStyle(color: Colors.white),
          items: [
            DropdownMenuItem(value: 'normal', child: Text('mode_normal'.tr)),
            DropdownMenuItem(value: 'image', child: Text('mode_images'.tr)),
            DropdownMenuItem(value: 'large', child: Text('mode_large'.tr)),
          ],
          onChanged: (val) {
            if (val != null) controller.updateFavReadingMode(val);
          },
        ),
      ),
    );
  }

  Widget _buildColorPickerTile({
    required String title,
    required List<int> colors,
    required RxInt selectedValue,
    required Function(int) onSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 12),
          child: Obx(
            () => Row(
              children: colors.map((colorVal) {
                final isSelected = selectedValue.value == colorVal;
                final color = Color(colorVal);
                
                // For white or cream backgrounds, show a subtle border if not selected
                final showBorder = colorVal == 0xFFFFFFFF || colorVal == 0xFFF4ECD8;

                return GestureDetector(
                  onTap: () => onSelected(colorVal),
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.secondary
                            : (showBorder ? Colors.white30 : Colors.transparent),
                        width: isSelected ? 3 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.5),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(
                            Icons.check,
                            color: colorVal == 0xFFFFFFFF || colorVal == 0xFFF4ECD8
                                ? Colors.black
                                : Colors.white,
                            size: 16,
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
