import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import '../../../../utils/colors.dart';
import '../../controllers/large_quran_controller.dart';
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
                    _showNavigationDialog(context, surahNumber, verseNumber);
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

  void _showNavigationDialog(
    BuildContext context,
    int surahNumber,
    int verseNumber,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Continue Reading',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.menu_book, color: AppColors.gold),
              title: const Text(
                'Normal Mode (Page View)',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                // Navigate to Normal Quran Mode
                int page = quran.getPageNumber(surahNumber, verseNumber);
                Get.to(() => NormalQuranView(initialPage: page));
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const Icon(Icons.format_size, color: AppColors.gold),
              title: const Text(
                'Large Font Mode (Scroll View)',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                // Navigate to Large Font Mode
                final controller = Get.find<LargeQuranController>();
                controller.currentSurahNumber.value = surahNumber;
                Get.to(
                  () => SurahDetailView(
                    surahNumber: surahNumber,
                    initialVerse: verseNumber,
                  ),
                );
              },
            ),
            const Divider(color: Colors.white12),
            ListTile(
              leading: const Icon(Icons.image, color: AppColors.gold),
              title: const Text(
                'Images Mode (Actual Page)',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Get.back();
                int page = quran.getPageNumber(surahNumber, verseNumber);
                // Check if downloaded? We should probably let the view handle it
                // or check controller here.
                // Ideally check controller.
                final imageController = Get.put(QuranImageController());
                if (imageController.isDownloaded.value) {
                  Get.to(() => ImageQuranView(initialPage: page));
                } else {
                  Get.snackbar(
                    'Download Required',
                    'Please download Quran images from the main Quran page first.',
                  );
                }
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
