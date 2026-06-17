import 'package:flutter/foundation.dart';

class StartupProfiler {
  static final Stopwatch _stopwatch = Stopwatch();
  static final Map<String, int> _timings = {};
  static bool _hasPrintedReport = false;

  static void start() {
    _stopwatch.reset();
    _stopwatch.start();
    _timings.clear();
    _hasPrintedReport = false;
  }

  static void log(String stepName) {
    if (_stopwatch.isRunning) {
      _timings[stepName] = _stopwatch.elapsedMilliseconds;
    }
  }

  static void printReport() {
    if (_hasPrintedReport) return;
    _hasPrintedReport = true;
    _stopwatch.stop();

    debugPrint("╔══════════════════════════════════════════╗");
    debugPrint("║       STARTUP PERFORMANCE REPORT         ║");
    debugPrint("╠══════════════════════════════════════════╣");
    _timings.forEach((step, time) {
      final label = step.padRight(25);
      final value = "${time}ms".padLeft(8);
      debugPrint("║ $label : $value ║");
    });
    final totalLabel = "Total App Startup".padRight(25);
    final totalValue = "${_stopwatch.elapsedMilliseconds}ms".padLeft(8);
    debugPrint("╠══════════════════════════════════════════╣");
    debugPrint("║ $totalLabel : $totalValue ║");
    debugPrint("╚══════════════════════════════════════════╝");
  }
}
