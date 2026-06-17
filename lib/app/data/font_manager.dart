import 'package:flutter/foundation.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import '../../utils/startup_profiler.dart';

class FontManager {
  static bool _loaded = false;
  static Future<void>? _loadingFuture;

  static bool get isLoaded => _loaded;

  static Future<void> ensureLoaded() {
    if (_loaded) return Future.value();
    
    _loadingFuture ??= _loadFonts();
    return _loadingFuture!;
  }

  static Future<void> _loadFonts() async {
    try {
      debugPrint("FontManager: Starting QCF fonts setup...");
      final stopwatch = Stopwatch()..start();
      
      await QcfFontLoader.setupFontsAtStartup(
        onProgress: (_) {},
      );
      
      stopwatch.stop();
      _loaded = true;
      debugPrint("FontManager: QCF fonts loaded in ${stopwatch.elapsedMilliseconds}ms");
      StartupProfiler.log("QCF Fonts Loaded");
    } catch (e) {
      debugPrint("FontManager: Error loading fonts: $e");
      _loaded = false;
      _loadingFuture = null; // Allow retry on failure
    }
  }
}
