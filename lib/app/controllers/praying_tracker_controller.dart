import 'dart:async';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../services/native_prayer_service.dart';
import '../services/prayer_fsm.dart';
import '../data/models/analysis_report.dart';
import '../views/praying_tracker/prayer_report_view.dart';
import '../controllers/home_controller.dart';

class PrayingTrackerController extends GetxController {
  final NativePrayerService _nativeService = NativePrayerService();
  StreamSubscription? _postureSubscription;
  Timer? _sessionTimer;
  int _elapsedSeconds = 0;
  PrayerFSM? _activeFsm;

  var isCameraInitialized = false.obs;
  var isRecording = false.obs;
  var cameraPermissionGranted = false.obs;

  // Real-time inference stats
  var activePose = "Waiting...".obs;
  var activeConfidence = "0.0%".obs;
  var activeInferenceTime = "0ms".obs;

  // Report/Session Data
  var prayerDuration = "00:00".obs;
  var rakatsCount = 0.obs;
  var movementScore = 0.obs;

  // Video testing stats
  var isAnalyzingVideo = false.obs;
  var videoAnalysisProgress = 0.0.obs;

  // Last completed session report
  var lastReport = AnalysisReport.empty().obs;

  // Selected prayer for custom state transitions
  var selectedPrayer = "Fajr".obs;

  @override
  void onInit() {
    super.onInit();
    // Do NOT initialize camera here on startup to prevent it from opening on app launch.
    // Instead, check the permission status so the UI knows if it needs to prompt the user.
    _checkPermissionStatus();
    _defaultToNextPrayer();
  }

  void _defaultToNextPrayer() {
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        final nextPrayer = homeController.nextPrayerName.value;
        if (nextPrayer.isNotEmpty) {
          selectedPrayer.value = nextPrayer;
        }
      }
    } catch (e) {
      debugPrint("Failed to default to next prayer: $e");
    }
  }

  Future<void> _checkPermissionStatus() async {
    final status = await Permission.camera.status;
    cameraPermissionGranted.value = status.isGranted;
  }

  Future<void> requestCameraPermission() async {
    final status = await Permission.camera.request();
    cameraPermissionGranted.value = status.isGranted;

    if (status.isGranted) {
      await initializeCamera();
    } else if (status.isPermanentlyDenied) {
      Get.snackbar(
        'Permission Denied',
        'Camera permission is permanently denied. Please enable it in settings.',
      );
      await openAppSettings();
    }
  }

  Future<void> initializeCamera() async {
    if (isCameraInitialized.value) return; // Prevent re-initialization

    final status = await Permission.camera.status;
    cameraPermissionGranted.value = status.isGranted;
    if (!status.isGranted) {
      debugPrint("Camera permission is not granted. Cannot initialize camera.");
      return;
    }

    try {
      // Just toggle the camera state to true since the AndroidView mounts and starts the camera
      isCameraInitialized.value = true;
      cameraPermissionGranted.value = true;
    } catch (e) {
      debugPrint("Camera initialization error: $e");
    }
  }

  Future<void> disposeCamera() async {
    isCameraInitialized.value = false;
    await _nativeService.stopInference();
  }

  void startSession() {
    isRecording.value = true;
    _elapsedSeconds = 0;
    prayerDuration.value = "00:00";
    rakatsCount.value = 0;
    movementScore.value = 0;
    activePose.value = "Waiting...";
    activeConfidence.value = "0.0%";
    activeInferenceTime.value = "0ms";

    _activeFsm = PrayerFSM(prayerName: selectedPrayer.value);
    final stopwatch = Stopwatch()..start();

    // Start timer for duration
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _elapsedSeconds++;
      final minutes = (_elapsedSeconds ~/ 60).toString().padLeft(2, '0');
      final seconds = (_elapsedSeconds % 60).toString().padLeft(2, '0');
      prayerDuration.value = "$minutes:$seconds";
    });

    // Start native ML inference
    _nativeService.startInference();

    // Listen to real-time pose results
    _postureSubscription = _nativeService.postureStream.listen((result) {
      activePose.value = result.label;
      activeConfidence.value = "${(result.confidence * 100).toStringAsFixed(1)}%";
      activeInferenceTime.value = "${result.inferenceTime}ms";

      // Parse pose string to Pose enum
      Pose pose = Pose.unknown;
      if (result.label == "Qayyam") {
        pose = Pose.qayyam;
      } else if (result.label == "Ruku") {
        pose = Pose.ruku;
      } else if (result.label == "Sujud") {
        pose = Pose.sujud;
      } else if (result.label == "Tashahhud") {
        pose = Pose.tashahhud;
      }

      if (_activeFsm != null) {
        _activeFsm!.update(pose, stopwatch.elapsed, result.confidence);
        final report = _activeFsm!.generateReport();
        lastReport.value = report;
        rakatsCount.value = report.totalRakahs;
        movementScore.value = (100 - report.mistakes.length * 10).clamp(0, 100).toInt();
      }
    });
  }

  void stopSession() {
    isRecording.value = false;
    _sessionTimer?.cancel();
    _sessionTimer = null;
    _postureSubscription?.cancel();
    _postureSubscription = null;

    if (_activeFsm != null) {
      _activeFsm!.completeSessionIfPending(Duration(seconds: _elapsedSeconds));
      final report = _activeFsm!.generateReport();
      lastReport.value = report;
      rakatsCount.value = report.totalRakahs;
      movementScore.value = (100 - report.mistakes.length * 10).clamp(0, 100).toInt();
    }

    if (rakatsCount.value == 0) {
      movementScore.value = 0;
    } else {
      movementScore.value = movementScore.value.clamp(50, 100).toInt();
    }

    _nativeService.stopInference();
  }

  Future<void> pickAndAnalyzeVideo() async {
    try {
      final picker = ImagePicker();
      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
      if (video == null) return;

      isAnalyzingVideo.value = true;
      videoAnalysisProgress.value = 0.0;

      // Listen to postureStream to show live progress to the user
      StreamSubscription? progressSub;
      progressSub = _nativeService.postureStream.listen((event) {
        videoAnalysisProgress.value = event.progress;
      });

      // Call native analysis
      final results = await _nativeService.analyzeVideo(video.path);

      // Cancel progress subscription
      await progressSub.cancel();

      if (results.isEmpty) {
        isAnalyzingVideo.value = false;
        Get.snackbar(
          "Analysis Failed",
          "Could not extract or analyze any frames from the selected video.",
          backgroundColor: Colors.black87,
          colorText: Colors.white,
        );
        return;
      }

      // Feed results to FSM to build the report
      final fsm = PrayerFSM(prayerName: selectedPrayer.value);
      int maxTimestamp = 0;
      for (var result in results) {
        Pose pose = Pose.unknown;
        if (result.label == "Qayyam") {
          pose = Pose.qayyam;
        } else if (result.label == "Ruku") {
          pose = Pose.ruku;
        } else if (result.label == "Sujud") {
          pose = Pose.sujud;
        } else if (result.label == "Tashahhud") {
          pose = Pose.tashahhud;
        }
        fsm.update(pose, Duration(milliseconds: result.timestampMs), result.confidence);
        if (result.timestampMs > maxTimestamp) {
          maxTimestamp = result.timestampMs;
        }
      }

      fsm.completeSessionIfPending(Duration(milliseconds: maxTimestamp));
      final report = fsm.generateReport();
      lastReport.value = report;
      
      // Populate controller variables so the ReportView displays them
      final minutes = (maxTimestamp ~/ 60000).toString().padLeft(2, '0');
      final seconds = ((maxTimestamp % 60000) ~/ 1000).toString().padLeft(2, '0');
      prayerDuration.value = "$minutes:$seconds";
      rakatsCount.value = report.totalRakahs;
      movementScore.value = (100 - report.mistakes.length * 10).clamp(0, 100).toInt();

      isAnalyzingVideo.value = false;

      // Navigate to Report View
      Get.to(() => const PrayerReportView());
    } catch (e) {
      isAnalyzingVideo.value = false;
      debugPrint("Error analyzing video: $e");
      Get.snackbar(
        "Error",
        "An error occurred during video analysis.",
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );
    }
  }

  @override
  void onClose() {
    _sessionTimer?.cancel();
    _postureSubscription?.cancel();
    _nativeService.stopInference();
    super.onClose();
  }
}
