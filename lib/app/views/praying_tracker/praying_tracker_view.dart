import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/praying_tracker_controller.dart';
import '../../../utils/colors.dart';
import 'prayer_report_view.dart';
import 'native_camera_preview.dart';

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
      body: Obx(() {
        final Widget content = !controller.cameraPermissionGranted.value
            ? _buildPermissionPrompt(controller)
            : Stack(
                children: [
                  // Camera Preview (Native platform view)
                  if (controller.isCameraInitialized.value)
                    const SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: NativeCameraPreview(),
                    )
                  else
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),

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
                                    const Icon(Icons.circle, color: Colors.red, size: 12),
                                    const SizedBox(width: 8),
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
                              if (controller.isRecording.value)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Rakah: ${controller.rakatsCount.value}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // AI Overlay Placeholder (Face/Body outline and real-time classifications)
                        Expanded(
                          child: Center(
                            child: Container(
                              width: 250,
                              height: 400,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: controller.isRecording.value
                                      ? AppColors.secondary.withOpacity(0.6)
                                      : Colors.white.withOpacity(0.3),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (controller.isRecording.value) ...[
                                      Text(
                                        controller.activePose.value,
                                        style: const TextStyle(
                                          color: AppColors.secondary,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        "Confidence: ${controller.activeConfidence.value}",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Latency: ${controller.activeInferenceTime.value}",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ] else ...[
                                      Text(
                                        'align_self'.tr,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ],
                                  ],
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
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!controller.isRecording.value) ...[
                                Obx(() => Container(
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.primary.withOpacity(0.5)),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: controller.selectedPrayer.value,
                                      dropdownColor: Colors.black87,
                                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                      icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                                      items: <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']
                                          .map<DropdownMenuItem<String>>((String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      onChanged: (String? newValue) {
                                        if (newValue != null) {
                                          controller.selectedPrayer.value = newValue;
                                        }
                                      },
                                    ),
                                  ),
                                )),
                              ],
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  if (!controller.isRecording.value) ...[
                                    const SizedBox(width: 48),
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
                                    ),
                                    IconButton(
                                      onPressed: controller.pickAndAnalyzeVideo,
                                      icon: const Icon(
                                        Icons.video_library_rounded,
                                        color: Colors.white,
                                        size: 36,
                                      ),
                                      tooltip: "Import Video for Testing",
                                    ),
                                  ] else
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
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );

        return Stack(
          children: [
            content,
            if (controller.isAnalyzingVideo.value)
              Container(
                color: Colors.black.withOpacity(0.85),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      const SizedBox(height: 24),
                      Text(
                        "Analyzing Video: ${(controller.videoAnalysisProgress.value * 100).toStringAsFixed(0)}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Please keep the app open...",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildPermissionPrompt(PrayingTrackerController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 64,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'camera_permission'.tr,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'camera_subtitle'.tr,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Select prayer dropdown
            Obx(() => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedPrayer.value,
                  dropdownColor: Colors.black87,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                  items: <String>['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      controller.selectedPrayer.value = newValue;
                    }
                  },
                ),
              ),
            )),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: controller.requestCameraPermission,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.secondary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: AppColors.secondary.withOpacity(0.4),
                ),
                child: Text(
                  'grant_camera'.tr,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: controller.pickAndAnalyzeVideo,
                icon: const Icon(Icons.video_library_rounded, color: AppColors.primary),
                label: const Text(
                  'IMPORT VIDEO FOR TESTING',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                    letterSpacing: 1.5,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
