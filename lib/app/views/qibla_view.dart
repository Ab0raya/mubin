import 'dart:async';
import 'dart:math' show pi;

import 'package:flutter/material.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';

class QiblaView extends StatefulWidget {
  const QiblaView({super.key});

  @override
  State<QiblaView> createState() => _QiblaViewState();
}

class _QiblaViewState extends State<QiblaView> {
  final _deviceSupport = FlutterQiblah.androidDeviceSensorSupport();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.background],
            stops: [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'qibla'.tr.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for back button
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder(
                  future: _deviceSupport,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.gold),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "${'error'.tr} ${snapshot.error.toString()}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    if (snapshot.data == true) {
                      return const QiblahCompassWidget();
                    } else {
                      return Center(
                        child: Text(
                          "device_not_supported".tr,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QiblahCompassWidget extends StatefulWidget {
  const QiblahCompassWidget({super.key});

  @override
  State<QiblahCompassWidget> createState() => _QiblahCompassWidgetState();
}

class _QiblahCompassWidgetState extends State<QiblahCompassWidget>
    with SingleTickerProviderStateMixin {
  final _locationStreamController =
      StreamController<LocationStatus>.broadcast();

  get stream => _locationStreamController.stream;

  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }

  @override
  void dispose() {
    _locationStreamController.close();
    super.dispose();
  }

  Future<void> _checkLocationStatus() async {
    // Check initial status
    await _updateStatus();

    // Listen for changes (Using periodic check as a simple fallback or if geolocator stream available)
    // Note: Permission_handler doesn't have a stream for status changes in all versions,
    // but Geolocator does for service status.
    // For simplicity and robustness, we check periodically if waiting.
    Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      await _updateStatus();
    });
  }

  Future<void> _updateStatus() async {
    var status = await Permission.location.status;
    bool enabled = await Permission.location.serviceStatus.isEnabled;
    debugPrint("Qibla Location Status: $status, Service Enabled: $enabled");

    if (status.isGranted && enabled) {
      _locationStreamController.sink.add(
        LocationStatus(enabled: true, granted: true),
      );
    } else {
      if (status.isDenied) {
        // Don't auto-request continuously, but check
      }
      _locationStreamController.sink.add(
        LocationStatus(enabled: enabled, granted: status.isGranted),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LocationStatus>(
      stream: stream,
      builder: (context, statusSnapshot) {
        final status = statusSnapshot.data;

        // If we don't know status yet, show loading
        if (status == null) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }

        if (status.enabled && status.granted) {
          return const QiblahViewContent();
        }

        // Otherwise show diagnostic/request UI
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.explore_off, size: 50, color: Colors.white54),
              const SizedBox(height: 20),
              Text(
                'waiting_compass_data'.tr,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildStatusRow('location_service'.tr, status.enabled),
              _buildStatusRow('permission'.tr, status.granted),
              const SizedBox(height: 20),
              if (!status.granted)
                ElevatedButton(
                  onPressed: () => Permission.location.request().then(
                    (_) => _updateStatus(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                  ),
                  child: Text('grant_permission'.tr),
                ),
              if (status.granted && !status.enabled)
                ElevatedButton(
                  onPressed: () => Geolocator.openLocationSettings().then(
                    (_) => _updateStatus(),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    foregroundColor: Colors.black,
                  ),
                  child: Text('open_location_settings'.tr),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusRow(String label, bool isOk) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          const SizedBox(width: 10),
          Icon(
            isOk ? Icons.check_circle : Icons.cancel,
            color: isOk ? Colors.green : Colors.red,
            size: 20,
          ),
          const SizedBox(width: 5),
          Text(
            isOk ? 'ok'.tr : 'issue'.tr,
            style: TextStyle(
              color: isOk ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class QiblahViewContent extends StatefulWidget {
  const QiblahViewContent({super.key});

  @override
  State<QiblahViewContent> createState() => _QiblahViewContentState();
}

class _QiblahViewContentState extends State<QiblahViewContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  double _begin = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween(begin: 0.0, end: 0.0).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QiblahDirection>(
      stream: FlutterQiblah.qiblahStream,
      builder: (context, snapshot) {
        debugPrint(
          "Qiblah Stream State: ${snapshot.connectionState}, Error: ${snapshot.error}, Data: ${snapshot.data}",
        );
        if (snapshot.connectionState == ConnectionState.waiting) {
          // We are valid and waiting for first data
          return const Center(
            child: CircularProgressIndicator(color: AppColors.gold),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "${'error'.tr} ${snapshot.error}",
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          final qiblahDirection = snapshot.data!;
          _animation = Tween(
            begin: _begin,
            end: (qiblahDirection.qiblah * (pi / 180) * -1),
          ).animate(_animationController);
          _begin = (qiblahDirection.qiblah * (pi / 180) * -1);
          _animationController.forward(from: 0);

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Angle: ${(qiblahDirection.qiblah).toStringAsFixed(1)}°",
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _animation.value,
                      child: Padding(
                        // Remove debug padding later
                        padding: const EdgeInsets.all(30.0),
                        child: SvgPicture.asset(
                          'assets/images/qiblah.svg',
                          // colorFilter removed to debug visibility
                          height: 300,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          return Center(
            child: Text(
              'waiting_compass_data'.tr,
              style: const TextStyle(color: Colors.white),
            ),
          );
        }
      },
    );
  }
}

class LocationStatus {
  final bool enabled;
  final bool granted;

  LocationStatus({required this.enabled, required this.granted});
}
