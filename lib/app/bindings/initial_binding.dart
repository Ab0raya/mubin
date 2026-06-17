import 'package:get/get.dart';
import '../services/api_service.dart';
import '../controllers/settings_controller.dart';
import '../services/tafseer_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<TafseerService>(() => TafseerService(), fenix: true);
  }
}
