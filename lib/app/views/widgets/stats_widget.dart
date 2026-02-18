import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class StatsWidget extends GetView<HomeController> {
  const StatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF141F1B),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      height: 70,
                      width: 70,
                      child: Obx(
                        () => CircularProgressIndicator(
                          value: (controller.prayedCount.value / 5).clamp(
                            0.0,
                            1.0,
                          ),
                          backgroundColor: Colors.white10,
                          color: const Color(0xFF00E676),
                          strokeWidth: 4,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Obx(
                          () => Text(
                            '${controller.prayedCount.value}/5',
                            style: const TextStyle(
                              color: Color(0xFF00E676),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          'prayed'.tr.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 8,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Container(
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFF141F1B),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: Color(0xFFFFD700),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LONDON, UK',
                        style: TextStyle(
                          color: const Color(0xFFFFD700).withValues(alpha: 0.8),
                          fontSize: 10,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const Text(
                    '18:42',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'sunset_time'.tr.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
