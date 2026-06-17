import 'package:get/get.dart';
import '../controllers/counter_controller.dart';
import '../controllers/azkar_controller.dart';
import '../controllers/home_controller.dart';

import '../views/counter_view.dart';
import '../views/qibla_view.dart';
import '../views/azkar/azkar_category_view.dart';
import '../views/azkar/azkar_detail_view.dart';
import '../views/stats_view.dart';
import '../controllers/stats_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../views/dashboard_view.dart';
import '../views/quran_reading/normal_quran_view.dart';
import '../views/quran_reading/large_quran_view.dart';
import '../views/quran_reading/tafseer_view.dart';
import '../views/quran_reading/bookmarks_view.dart';
import '../views/quran_reading/image_quran_view.dart';
import '../views/quran_reading/image_surah_list_view.dart';
import '../views/praying_tracker/prayer_report_view.dart';
import '../views/auth/login_view.dart';
import '../views/auth/register_view.dart';
import '../controllers/auth_controller.dart';
import '../views/onboarding/onboarding_view.dart';
import '../controllers/onboarding_controller.dart';
import '../views/profile/profile_view.dart';
import '../controllers/profile_controller.dart';
import '../views/settings/settings_view.dart';
import '../controllers/settings_controller.dart';
import '../views/quran_audio/quran_audio_view.dart';

class AppRoutes {
  static const home = '/home'; // Now mapped to DashboardView
  static const counter = '/counter';
  static const qibla = '/qibla';
  static const azkar = '/azkar';
  static const azkarDetail = '/azkar/detail';
  static const stats = '/stats';
  static const quranNormal = '/quran/normal';
  static const quranLarge = '/quran/large';
  static const quranTafseer = '/quran/tafseer';
  static const quranBookmarks = '/quran/bookmarks';
  static const quranImage = '/quran/image';
  static const prayerReport = '/praying/report';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const quranAudio = '/quran/audio';
}

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.home,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.put(DashboardController());
        Get.put(
          HomeController(),
        ); // Ensure HomeController is available for HomeView tab
        Get.put(ProfileController());
        Get.put(StatsController());
      }),
    ),
    GetPage(
      name: AppRoutes.counter,
      page: () => const CounterView(),
      binding: BindingsBuilder(() {
        Get.put(CounterController());
      }),
    ),
    GetPage(name: AppRoutes.qibla, page: () => const QiblaView()),
    GetPage(
      name: AppRoutes.azkar,
      page: () => const AzkarCategoryView(),
      binding: BindingsBuilder(() {
        Get.put(AzkarController());
      }),
    ),
    GetPage(name: AppRoutes.azkarDetail, page: () => const AzkarDetailView()),
    GetPage(
      name: AppRoutes.stats,
      page: () => const StatsView(),
      binding: BindingsBuilder(() {
        Get.put(StatsController());
      }),
    ),
    GetPage(name: AppRoutes.quranNormal, page: () => const NormalQuranView()),
    GetPage(name: AppRoutes.quranLarge, page: () => const LargeQuranView()),
    GetPage(name: AppRoutes.quranTafseer, page: () => const TafseerView()),
    GetPage(name: AppRoutes.quranBookmarks, page: () => const BookmarksView()),
    GetPage(name: AppRoutes.quranImage, page: () => const ImageSurahListView()),
    GetPage(name: AppRoutes.prayerReport, page: () => const PrayerReportView()),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: BindingsBuilder(() {
        Get.put(OnboardingController());
      }),
    ),
    GetPage(
      name: '/profile',
      page: () => const ProfileView(),
      binding: BindingsBuilder(() {
        Get.put(ProfileController());
      }),
    ),
    GetPage(
      name: '/settings',
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.put(SettingsController());
      }),
    ),
    GetPage(
      name: '/settings',
      page: () => const SettingsView(),
      binding: BindingsBuilder(() {
        Get.put(SettingsController());
      }),
    ),
    GetPage(
      name: AppRoutes.quranAudio,
      page: () => const QuranAudioView(),
      // QuranAudioView initializes its own controller in build method,
      // but we can bind it here if needed.
      // For now, let's stick to how it was implemented previously or standard GetX way.
      // The view uses Get.put(QuranAudioController()) inside build based on previous view_file.
      // So no binding needed here unless we refactor the view.
    ),
  ];
}
