import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:get_storage/get_storage.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:just_audio_background/just_audio_background.dart'; // Import this
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'app/translations/app_translations.dart';
import 'app/routes/app_routes.dart';
import 'app/services/api_service.dart';
import 'app/services/tafseer_service.dart';
import 'utils/colors.dart';
import 'utils/constants.dart';
import 'app/controllers/settings_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //tesr git 
  await GetStorage.init();

  // Initialize QCF Fonts at startup
  await QcfFontLoader.setupFontsAtStartup(
    onProgress: (double progress) {
      debugPrint('Font Loading Progress: ${(progress * 100).toStringAsFixed(1)}%');
    },
  );

  // Initialize JustAudioBackground
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );

  AwesomeNotifications().initialize(
    null, // icon: null means use the default app icon
    [
      NotificationChannel(
        channelGroupKey: 'basic_channel_group',
        channelKey: 'prayer_channel',
        channelName: 'Prayer Notifications',
        channelDescription: 'Notification channel for prayer times',
        defaultColor: const Color(0xFF0D1211),
        ledColor: const Color(0xFF00E676),
        importance: NotificationImportance.High,
        soundSource:
            'resource://raw/azan', // Uses android/app/src/main/res/raw/azan.mp3
        playSound: true,
        criticalAlerts: true,
      ),
      NotificationChannel(
        channelGroupKey: 'basic_channel_group',
        channelKey: 'download_channel',
        channelName: 'Download Notifications',
        channelDescription: 'Notification channel for downloads',
        defaultColor: const Color(0xFF0D1211),
        ledColor: const Color(0xFF00E676),
        importance:
            NotificationImportance.Low, // Low importance for progress updates
        playSound: false,
        enableVibration: false,
        locked: true, // Prevents dismissal while downloading
      ),
    ],
    channelGroups: [
      NotificationChannelGroup(
        channelGroupKey: 'basic_channel_group',
        channelGroupName: 'Basic group',
      ),
    ],
    debug: true,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Initialize Services
    Get.put(ApiService());
    Get.put(SettingsController());
    Get.putAsync(() => TafseerService().init());

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      onNotificationCreatedMethod:
          NotificationController.onNotificationCreatedMethod,
      onNotificationDisplayedMethod:
          NotificationController.onNotificationDisplayedMethod,
      onDismissActionReceivedMethod:
          NotificationController.onDismissActionReceivedMethod,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mubin',
      theme: ThemeData(
        colorScheme: const ColorScheme.dark().copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: const Color(0xFF0D1211),
          surfaceTint: AppColors.primary,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'TheYearofHandicrafts',
      ),
      translations: AppTranslations(),
      locale: _getSavedLocale(),
      fallbackLocale: const Locale('en', 'US'),
      initialRoute: _getInitialRoute(),
      getPages: AppPages.routes,
    );
  }

  String _getInitialRoute() {
    final box = GetStorage();
    bool isOnboardingComplete =
        box.read(Constants.keyOnboardingComplete) == true;

    if (!isOnboardingComplete) {
      return AppRoutes.onboarding;
    } else {
      return AppRoutes.home;
    }
  }

  Locale _getSavedLocale() {
    final box = GetStorage();
    String? langCode = box.read(Constants.keyLanguage);
    if (langCode == 'ar') {
      return const Locale('ar', 'SA');
    }
    return const Locale('en', 'US');
  }
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint("Notification created: ${receivedNotification.id}");
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {
    debugPrint("Notification displayed: ${receivedNotification.id}");
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint("Notification dismissed: ${receivedAction.id}");
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    debugPrint("Notification action received: ${receivedAction.id}");

    // Handle Media Actions - REMOVED (Handled by just_audio_background)
  }
}
