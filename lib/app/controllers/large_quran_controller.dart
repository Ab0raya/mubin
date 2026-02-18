import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;
import 'package:just_audio/just_audio.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:get_storage/get_storage.dart';
import '../services/tafseer_service.dart';

class LargeQuranController extends GetxController {
  TafseerService get _tafseerService => Get.find<TafseerService>();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScreenshotController screenshotController = ScreenshotController();
  final GetStorage _storage = GetStorage();

  // State
  var currentSurahNumber = 1.obs;
  var isPlaying = false.obs;
  var currentPlayingVerse = (-1).obs; // -1 means no verse is playing
  var lastBookmark = Rx<String?>(null); // Stores "surah:verse" string or null

  @override
  void onInit() {
    super.onInit();
    loadBookmark();
  }

  // --- Persistence ---

  void saveLastRead(int surahNumber) {
    _storage.write('last_read_surah', surahNumber);
  }

  int getLastReadSurah() {
    return _storage.read('last_read_surah') ?? 1;
  }

  // --- Bookmark (Single) ---

  void loadBookmark() {
    String? stored = _storage.read('last_bookmark');
    lastBookmark.value = stored;
  }

  void saveBookmark(int surahNumber, int verseNumber) {
    String key = '$surahNumber:$verseNumber';
    lastBookmark.value = key;
    _storage.write('last_bookmark', key);
    Get.snackbar(
      'Bookmark Saved',
      'Bookmark updated to $surahNumber:$verseNumber',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
    );
  }

  void removeBookmark() {
    lastBookmark.value = null;
    _storage.remove('last_bookmark');
  }

  bool isBookmarked(int surahNumber, int verseNumber) {
    return lastBookmark.value == '$surahNumber:$verseNumber';
  }

  void toggleBookmark(int surahNumber, int verseNumber) {
    if (isBookmarked(surahNumber, verseNumber)) {
      removeBookmark();
    } else {
      saveBookmark(surahNumber, verseNumber);
    }
  }

  // --- Data Access ---
  int get totalSurahs => quran.totalSurahCount;

  String getSurahName(int surahNumber) {
    return quran.getSurahNameArabic(surahNumber);
  }

  String getSurahNameEnglish(int surahNumber) {
    return quran.getSurahName(surahNumber);
  }

  int getVerseCount(int surahNumber) {
    return quran.getVerseCount(surahNumber);
  }

  String getVerse(int surahNumber, int verseNumber) {
    String verse = quran.getVerse(surahNumber, verseNumber);
    if (surahNumber != 1 && verseNumber == 1) {
      // Using the exact Bismillah string that quran package likely uses or standard one
      // "بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ"
      // We will try to match start and remove it.
      const bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ';
      if (verse.startsWith(bismillah)) {
        verse = verse.substring(bismillah.length).trim();
      } else if (verse.startsWith(quran.basmala)) {
        verse = verse.substring(quran.basmala.length).trim();
      }
    }
    return verse;
  }

  void nextSurah() {
    if (currentSurahNumber.value < 114) {
      currentSurahNumber.value++;
    }
  }

  void previousSurah() {
    if (currentSurahNumber.value > 1) {
      currentSurahNumber.value--;
    }
  }

  // --- Features ---

  // 1. Get Tafseer
  String getTafseer(int surahNumber, int verseNumber) {
    return _tafseerService.getTafseer(surahNumber, verseNumber);
  }

  // 2. Copy Verse
  void copyVerse(int surahNumber, int verseNumber) {
    String text =
        '${getVerse(surahNumber, verseNumber)} \n[${getSurahNameEnglish(surahNumber)}:$verseNumber]';
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      'Verse copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // 3. Play Audio
  Future<void> playAudio(int surahNumber, int verseNumber) async {
    try {
      if (currentPlayingVerse.value == verseNumber && isPlaying.value) {
        await _audioPlayer.pause();
        isPlaying.value = false;
        return;
      }

      // If resuming same verse
      if (currentPlayingVerse.value == verseNumber && !isPlaying.value) {
        await _audioPlayer.play();
        isPlaying.value = true;
        return;
      }

      // New verse
      currentPlayingVerse.value = verseNumber;
      isPlaying.value = true;

      // Calculate absolute verse number is tricky because audio URL might rely on Surah/Verse logic or absolute.
      // The user request says: https://cdn.islamic.network/quran/audio/128/ar.alafasy/$absoluteVerseNumber.mp3
      // We need a way to get absolute verse number.
      // quran package doesn't seem to have direct absolute verse util locally exposed in common docs,
      // but we can calculate it or use the package if it has it.
      // Let's implement a helper or assume standard count.

      int absoluteVerse = 0;
      for (int i = 1; i < surahNumber; i++) {
        absoluteVerse += quran.getVerseCount(i);
      }
      absoluteVerse += verseNumber;

      String url =
          'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$absoluteVerse.mp3';

      await _audioPlayer.setUrl(url);
      await _audioPlayer.play();

      _audioPlayer.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          isPlaying.value = false;
          currentPlayingVerse.value = -1;
        }
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not play audio',
        snackPosition: SnackPosition.BOTTOM,
      );
      isPlaying.value = false;
      print(e);
    }
  }

  // 4. Share Image
  Future<void> shareVerseAsImage(int surahNumber, int verseNumber) async {
    try {
      final verseText = getVerse(surahNumber, verseNumber);
      final surahName = getSurahNameEnglish(surahNumber);

      // Create a widget to capture
      final widgetToCapture = Container(
        padding: const EdgeInsets.all(20),
        color: const Color(0xFF0D1211), // App background color
        width: 600, // Fixed width for consistent image
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '﷽',
              style: TextStyle(
                fontFamily: 'Amiri', // Assuming font is available
                fontSize: 20,
                color: Color(0xFFD4AF37), // Gold
              ),
            ),
            const SizedBox(height: 20),
            Text(
              verseText,
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 32,
                color: Colors.white,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              '[$surahName : $verseNumber]',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Shared via Mubin App',
              style: TextStyle(
                color: Color(0xFF00E676), // Secondary color
                fontSize: 12,
              ),
            ),
          ],
        ),
      );

      final Uint8List imageBytes = await screenshotController.captureFromWidget(
        widgetToCapture,
        delay: const Duration(milliseconds: 10),
      );

      final directory = (await getApplicationDocumentsDirectory()).path;
      String fileName =
          'verse_share_${DateTime.now().millisecondsSinceEpoch}.png';
      String path = '$directory/$fileName';

      final File file = File(path);
      await file.writeAsBytes(imageBytes);

      await Share.shareXFiles([
        XFile(path),
      ], text: 'Mubin App - $surahName:$verseNumber');
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not share image: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
      print(e);
    }
  }

  // --- Search Feature ---

  final TextEditingController searchController = TextEditingController();
  var searchQuery = ''.obs;
  var searchResults = <QuranSearchResult>[].obs;
  var isSearching = false.obs;

  void searchQuran(String query) async {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isSearching.value = true;
    searchResults.clear();

    List<QuranSearchResult> results = [];

    // Run search in a future to avoid blocking UI immediately
    await Future.delayed(Duration.zero);

    for (int surah = 1; surah <= 114; surah++) {
      int verseCount = quran.getVerseCount(surah);
      for (int verse = 1; verse <= verseCount; verse++) {
        String text = getVerse(surah, verse);
        // Simple case-insensitive search (though Arabic usually matches directly)
        if (text.contains(query)) {
          results.add(
            QuranSearchResult(surah: surah, verse: verse, text: text),
          );
        }
      }
    }

    searchResults.assignAll(results);
    isSearching.value = false;
  }

  void clearSearch() {
    searchController.clear();
    searchQuery.value = '';
    searchResults.clear();
    isSearching.value = false;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}

class QuranSearchResult {
  final int surah;
  final int verse;
  final String text;

  QuranSearchResult({
    required this.surah,
    required this.verse,
    required this.text,
  });
}
