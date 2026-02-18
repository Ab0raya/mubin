import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter/services.dart';

class CounterController extends GetxController {
  final box = GetStorage();
  var count = 0.obs;
  var dhikrText = 'سبحان الله'.obs;

  final List<String> dhikrTemplates = [
    'سبحان الله',
    'الحمد لله',
    'لا إله إلا الله',
    'الله أكبر',
    'لا حول ولا قوة إلا بالله',
    'سبحان الله وبحمده',
    'سبحان الله العظيم',
    'أستغفر الله',
    'اللهم صل على محمد',
  ];

  @override
  void onInit() {
    super.onInit();
    // Load persisted data
    if (box.hasData('count')) {
      count.value = box.read('count');
    }
    if (box.hasData('dhikrText')) {
      dhikrText.value = box.read('dhikrText');
    }

    // Listen to changes and persist
    ever(count, (value) => box.write('count', value));
    ever(dhikrText, (value) => box.write('dhikrText', value));
  }

  void increment() {
    count.value++;
    HapticFeedback.lightImpact();
  }

  void reset() {
    count.value = 0;
    HapticFeedback.mediumImpact();
  }

  void updateDhikr(String text) {
    if (text.isNotEmpty) {
      dhikrText.value = text;
    }
  }
}
