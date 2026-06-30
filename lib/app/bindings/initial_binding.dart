import 'package:get/get.dart';
import '../services/api_service.dart';
import '../controllers/settings_controller.dart';
import '../services/tafseer_service.dart';
import '../services/backend_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService(), fenix: true);
    Get.lazyPut<BackendService>(() => BackendService(), fenix: true);
    Get.lazyPut<SettingsController>(() => SettingsController(), fenix: true);
    Get.lazyPut<TafseerService>(() => TafseerService(), fenix: true);
  }
}
