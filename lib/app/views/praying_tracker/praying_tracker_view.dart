import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import '../../controllers/praying_tracker_controller.dart';
import '../../routes/app_routes.dart';
import '../../../utils/colors.dart';
import 'prayer_report_view.dart';

class PrayingTrackerView extends StatelessWidget {
  const PrayingTrackerView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inject controller if not already present
    final PrayingTrackerController controller = Get.put(
      PrayingTrackerController(),
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Obx(() {
            if (controller.isCameraInitialized.value &&
                controller.cameraController != null) {
              return SizedBox(
                height: double.infinity,
                width: double.infinity,
                child: CameraPreview(controller.cameraController!),
              );
            } else {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }
          }),

          // Overlay
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.circle, color: Colors.red, size: 12),
                            SizedBox(width: 8),
                            Text(
                              'ai_monitor_active'.tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // AI Overlay Placeholder (Face/Body outline)
                Expanded(
                  child: Center(
                    child: Container(
                      width: 250,
                      height: 400,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          'align_self'.tr,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Bottom Controls
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 100,
                    left: 20,
                    right: 20,
                  ),
                  child: Obx(
                    () => Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        if (!controller.isRecording.value)
                          GestureDetector(
                            onTap: controller.startSession,
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withOpacity(0.5),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.black,
                                size: 40,
                              ),
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () {
                              controller.stopSession();
                              Get.to(() => const PrayerReportView());
                            },
                            child: Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.5),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.stop,
                                color: Colors.white,
                                size: 40,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
