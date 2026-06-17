import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:mubin/app/controllers/large_quran_controller.dart';
import 'package:mubin/app/services/tafseer_service.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Mock path_provider channel for GetStorage.init
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getApplicationDocumentsDirectory') {
          return '.';
        }
        return null;
      },
    );

    // Initialise GetStorage and inject Mock TafseerService
    await GetStorage.init();
    Get.put(TafseerService());
  });

  tearDown(() {
    Get.reset();
  });

  test('Arabic Search - Diacritic Insensitive & Normalised', () async {
    final controller = Get.put(LargeQuranController());

    // Mock the search provider to return dummy search results for our test query
    controller.searchWordsProvider = (query) {
      print('Mock searchWordsProvider called with query: "$query"');
      if (query.contains('حمد')) {
        return {
          'occurences': 1,
          'result': [
            {
              'sora': 1,
              'aya_no': 2,
              'text': 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ',
            }
          ]
        };
      } else if (query.contains('مستق')) {
        return {
          'occurences': 1,
          'result': [
            {
              'sora': 1,
              'aya_no': 6,
              'text': 'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ',
            }
          ]
        };
      }
      return {'occurences': 0, 'result': []};
    };

    final normalized = normalise('ٱلْحَمْدُ');
    print('Normalized: "$normalized"');

    // Search for a word with full diacritics
    // Word: "الحمد" (Al-Hamd) with various diacritics: "ٱلْحَمْدُ"
    controller.searchQuran('ٱلْحَمْدُ');
    await Future.delayed(const Duration(milliseconds: 50));

    print('SearchResults after search: ${controller.searchResults.map((r) => "${r.surah}:${r.verse}").toList()}');

    expect(controller.searchResults, isNotEmpty);

    // Search for the normalized plain word "الحمد"
    final plainResultsCount = controller.searchResults.length;
    expect(plainResultsCount, greaterThan(0));

    // Clear search
    controller.clearSearch();
    expect(controller.searchResults, isEmpty);

    // Search for a specific phrasing to verify mapping correctness
    controller.searchQuran('مستقيم'); // straight
    await Future.delayed(const Duration(milliseconds: 50));

    expect(controller.searchResults, isNotEmpty);
    for (var result in controller.searchResults) {
      expect(result.surah, greaterThan(0));
      expect(result.verse, greaterThan(0));
      expect(result.text, isNotEmpty);
    }
  });
}
