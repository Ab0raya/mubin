import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import '../../../../utils/colors.dart';
import '../../controllers/large_quran_controller.dart';
import '../../controllers/settings_controller.dart';
import 'surah_detail_view.dart';
import 'normal_quran_view.dart';
import 'image_quran_view.dart';
import '../../controllers/quran_image_controller.dart';

class BookmarksView extends StatelessWidget {
  const BookmarksView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is found or initialized
    final controller = Get.put(LargeQuranController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.gold,
      ),
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.lastBookmark.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.bookmark_border,
                  size: 60,
                  color: Colors.white24,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No bookmark saved',
                  style: TextStyle(color: Colors.white54, fontSize: 18),
                ),
              ],
            ),
          );
        }

        String key = controller.lastBookmark.value!;
        List<String> parts = key.split(':');
        int surahNumber = int.parse(parts[0]);
        int verseNumber = int.parse(parts[1]);

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Last Read Position',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: AppColors.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.gold, width: 1),
                ),
                child: InkWell(
                  onTap: () {
                    final settingsController = Get.put(SettingsController());
                    final imageController = Get.put(QuranImageController());
                    final largeQuranController = Get.find<LargeQuranController>();
                    final favMode = settingsController.favReadingMode.value;
                    final page = quran.getPageNumber(surahNumber, verseNumber);

                    if (favMode == 'image') {
                      if (imageController.isDownloaded.value) {
                        Get.to(() => ImageQuranView(initialPage: page));
                      } else {
                        imageController.showDownloadDialog(onSuccess: () {
                          Get.to(() => ImageQuranView(initialPage: page));
                        });
                      }
                    } else if (favMode == 'large') {
                      largeQuranController.currentSurahNumber.value = surahNumber;
                      Get.to(() => SurahDetailView(
                            surahNumber: surahNumber,
                            initialVerse: verseNumber,
                          ));
                    } else {
                      Get.to(() => NormalQuranView(initialPage: page));
                    }
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Verse $verseNumber',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              controller.getSurahNameEnglish(surahNumber),
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          controller.getVerse(surahNumber, verseNumber),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiri(
                            color: Colors.white,
                            fontSize: 22,
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.touch_app,
                              color: Colors.white54,
                              size: 16,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Tap to continue reading',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

}
