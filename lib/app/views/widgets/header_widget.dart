import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class HeaderWidget extends GetView<HomeController> {
  const HeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => Text(
            '${"next".tr.toUpperCase()}: ${controller.nextPrayerName.value.toLowerCase().tr.toUpperCase()}',
            style: const TextStyle(
              color: Color(0xFF00E676),
              letterSpacing: 2,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Text(
            controller.timeUntilNextPrayer.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 64,
              fontWeight: FontWeight.w200,
              fontFamily: 'Roboto',
            ),
          ),
        ),
        Text(
          'until_adhan'.tr.toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            letterSpacing: 2,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
