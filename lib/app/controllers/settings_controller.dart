import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../../utils/constants.dart';
import 'home_controller.dart';

class SettingsController extends GetxController {
  final box = GetStorage();

  // Settings State
  var isDarkMode = true.obs;
  var enableNotifications = true.obs;
  var azanType = 'full'.obs; // 'full', 'half', 'notification'
  var prayerCalculationMethod = 5.obs; // Egypt
  var asrCalculationMethod = 0.obs; // Shafii (Standard)
  var quranReciter = 'Mishary Rashid Alafasy'.obs;
  var currentLanguage = 'en'.obs;
  var quranFontSize = 28.0.obs;
  var readingBgColor = 0xFF121212.obs; // Default dark charcoal
  var readingTextColor = 0xFFFFFFFF.obs; // Default white
  var favReadingMode = 'normal'.obs; // 'normal', 'image', 'large'

  @override
  void onInit() {
    super.onInit();
    _loadSettings();
  }

  void _loadSettings() {
    // Load from storage or use defaults
    // enableNotifications.value = box.read('notifications') ?? true;
    isDarkMode.value = box.read('isDarkMode') ?? true;
    quranFontSize.value = box.read('quranFontSize') ?? 28.0;
    readingBgColor.value = box.read('readingBgColor') ?? 0xFF121212;
    readingTextColor.value = box.read('readingTextColor') ?? 0xFFFFFFFF;
    favReadingMode.value = box.read('favReadingMode') ?? 'normal';
    azanType.value = box.read(Constants.keyAzanType) ?? 'full';
  }

  void updateFavReadingMode(String value) {
    favReadingMode.value = value;
    box.write('favReadingMode', value);
  }

  void updateQuranFontSize(double value) {
    quranFontSize.value = value;
    box.write('quranFontSize', value);
  }

  void updateReadingBgColor(int value) {
    readingBgColor.value = value;
    box.write('readingBgColor', value);
  }

  void updateReadingTextColor(int value) {
    readingTextColor.value = value;
    box.write('readingTextColor', value);
    // Link with isDarkMode attribute: White text implies dark mode, black text implies light mode
    bool isDark = value == 0xFFFFFFFF;
    isDarkMode.value = isDark;
    box.write('isDarkMode', isDark);
  }

  void updateDarkMode(bool value) {
    isDarkMode.value = value;
    box.write('isDarkMode', value);
    // Link with reading text color: dark mode implies white text, light mode implies black text
    int textColor = value ? 0xFFFFFFFF : 0xFF111111;
    readingTextColor.value = textColor;
    box.write('readingTextColor', textColor);
  }

  void toggleNotifications(bool value) {
    enableNotifications.value = value;
    box.write('notifications', value);
  }

  void updateAzanType(String value) {
    azanType.value = value;
    box.write(Constants.keyAzanType, value);
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.box.remove('last_notification_schedule_date');
        homeController.schedulePrayerNotifications(DateTime.now());
      }
    } catch (e) {
      debugPrint("Failed to reschedule notifications on azan type change: $e");
    }
  }

  void updateCalculationMethod(int value) {
    prayerCalculationMethod.value = value;
    box.write('calc_method', value);
  }

  void updateLanguage(String value) {
    currentLanguage.value = value;
    var locale = Locale(value, value == 'ar' ? 'SA' : 'US');
    Get.updateLocale(locale);
    box.write('language', value);
  }

  void triggerTestAzan() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    if (!isAllowed) {
      Get.snackbar(
        'permission'.tr,
        'notification_permission'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
      return;
    }

    try {
      String testChannelKey = 'prayer_channel_full';
      if (azanType.value == 'half') {
        testChannelKey = 'prayer_channel_half';
      } else if (azanType.value == 'notification') {
        testChannelKey = 'prayer_channel_default';
      }

      final String timeZone = await AwesomeNotifications().getLocalTimeZoneIdentifier();

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 999, // Unique test ID
          channelKey: testChannelKey,
          title: 'Test Azan Alarm',
          body: 'This is a test of the offline Azan notification.',
          notificationLayout: NotificationLayout.Default,
          wakeUpScreen: true,
          category: NotificationCategory.Alarm,
          criticalAlert: true,
        ),
        schedule: NotificationCalendar.fromDate(
          date: DateTime.now().add(const Duration(seconds: 5)),
          // timeZone: timeZone,

        ),
      );
      Get.snackbar(
        'test_azan_alarm'.tr,
        'test_alarm_scheduled'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0F251D),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.8),
        colorText: Colors.white,
      );
    }
  }
}
