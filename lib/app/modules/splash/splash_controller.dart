import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../utils/constants.dart';
import '../../../utils/startup_profiler.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNextScreen();
  }

  void _navigateToNextScreen() async {
    // Allow animation to play and visually brand the app
    await Future.delayed(const Duration(milliseconds: 1200));

    // Measure time up to navigation (First Frame is displayed now)
    StartupProfiler.log("Splash Screen Exit");
    StartupProfiler.printReport();

    final box = GetStorage();
    bool isOnboardingComplete = box.read(Constants.keyOnboardingComplete) == true;

    if (!isOnboardingComplete) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }
}
