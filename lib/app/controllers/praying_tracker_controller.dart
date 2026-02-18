import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class PrayingTrackerController extends GetxController {
  CameraController? cameraController;
  var isCameraInitialized = false.obs;
  var isRecording = false.obs;
  var cameraPermissionGranted = false.obs;

  // Report Data
  var prayerDuration = "00:00".obs;
  var rakatsCount = 0.obs;
  var movementScore = 0.obs;

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  Future<void> initializeCamera() async {
    if (isCameraInitialized.value) return; // Prevent re-initialization

    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        // Use front camera by default for user tracking
        final frontCamera = cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => cameras.first,
        );

        cameraController = CameraController(
          frontCamera,
          ResolutionPreset.medium,
          enableAudio: false,
        );

        await cameraController!.initialize();
        isCameraInitialized.value = true;
        cameraPermissionGranted.value = true;
      } else {
        Get.snackbar("Error", "No cameras found");
      }
    } catch (e) {
      debugPrint("Camera initialization error: $e");
      if (e is CameraException && e.code == 'CameraAccessDenied') {
        cameraPermissionGranted.value = false;
        Get.snackbar(
          "Permission Denied",
          "Camera access is needed for this feature.",
        );
      }
    }
  }

  Future<void> disposeCamera() async {
    if (cameraController != null) {
      await cameraController!.dispose();
      cameraController = null;
      isCameraInitialized.value = false;
    }
  }

  void startSession() {
    isRecording.value = true;
    // TODO: AI Model inference would start here
  }

  void stopSession() {
    isRecording.value = false;
    // Generate dummy report data
    prayerDuration.value = "05:30";
    rakatsCount.value = 4;
    movementScore.value = 95;

    // Navigate to report view
    // We will use a dialog or bottom sheet or navigation for now
    // Since we are inside a nested navigation in dashboard, we might want to show a full screen dialog or navigate
  }

  @override
  void onClose() {
    cameraController?.dispose();
    super.onClose();
  }
}
