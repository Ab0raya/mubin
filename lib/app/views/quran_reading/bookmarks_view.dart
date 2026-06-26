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
        title: const Text('Bookmarks & Last Read'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.gold,
      ),
      backgroundColor: AppColors.background,
      body: Obx(() {
        final lastReadSurah = controller.lastReadSurah.value;
        final lastReadVerse = controller.lastReadVerse.value;
        final lastReadPage = controller.lastReadPage.value;

        final hasBookmark = controller.lastBookmark.value != null;
        int bookmarkSurah = 1;
        int bookmarkVerse = 1;
        int bookmarkPage = 1;

        if (hasBookmark) {
          final parts = controller.lastBookmark.value!.split(':');
          if (parts.length == 2) {
            bookmarkSurah = int.tryParse(parts[0]) ?? 1;
            bookmarkVerse = int.tryParse(parts[1]) ?? 1;
            bookmarkPage = quran.getPageNumber(bookmarkSurah, bookmarkVerse);
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Last Page Opened Section ---
              const Text(
                'Last Page Opened',
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
                  side: BorderSide(color: AppColors.gold.withValues(alpha: 0.3), width: 1),
                ),
                child: InkWell(
                  onTap: () {
                    final settingsController = Get.put(SettingsController());
                    final imageController = Get.put(QuranImageController());
                    final largeQuranController = Get.find<LargeQuranController>();
                    final favMode = settingsController.favReadingMode.value;

                    if (favMode == 'image') {
                      if (imageController.isDownloaded.value) {
                        Get.to(() => ImageQuranView(initialPage: lastReadPage));
                      } else {
                        imageController.showDownloadDialog(onSuccess: () {
                          Get.to(() => ImageQuranView(initialPage: lastReadPage));
                        });
                      }
                    } else if (favMode == 'large') {
                      largeQuranController.currentSurahNumber.value = lastReadSurah;
                      Get.to(() => SurahDetailView(
                            surahNumber: lastReadSurah,
                            initialVerse: lastReadVerse,
                          ));
                    } else {
                      Get.to(() => NormalQuranView(
                            initialPage: lastReadPage,
                            initialSurah: lastReadSurah,
                            initialVerse: lastReadVerse,
                          ));
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
                              'Page $lastReadPage • Verse $lastReadVerse',
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              controller.getSurahNameEnglish(lastReadSurah),
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
                          controller.getVerse(lastReadSurah, lastReadVerse),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                          style: GoogleFonts.amiri(
                            color: Colors.white70,
                            fontSize: 20,
                            height: 1.8,
                          ),
                        ),
                        const SizedBox(height: 12),
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

              const SizedBox(height: 24),

              // --- Bookmarks Section ---
              const Text(
                'Saved Bookmark',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (!hasBookmark)
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.bookmark_border_rounded,
                          size: 40,
                          color: Colors.white24,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'No bookmark saved yet.\nLong press any verse while reading to bookmark it.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white30,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
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

                      if (favMode == 'image') {
                        if (imageController.isDownloaded.value) {
                          Get.to(() => ImageQuranView(initialPage: bookmarkPage));
                        } else {
                          imageController.showDownloadDialog(onSuccess: () {
                            Get.to(() => ImageQuranView(initialPage: bookmarkPage));
                          });
                        }
                      } else if (favMode == 'large') {
                        largeQuranController.currentSurahNumber.value = bookmarkSurah;
                        Get.to(() => SurahDetailView(
                              surahNumber: bookmarkSurah,
                              initialVerse: bookmarkVerse,
                            ));
                      } else {
                        Get.to(() => NormalQuranView(
                              initialPage: bookmarkPage,
                              initialSurah: bookmarkSurah,
                              initialVerse: bookmarkVerse,
                            ));
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
                                'Verse $bookmarkVerse',
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                controller.getSurahNameEnglish(bookmarkSurah),
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
                            controller.getVerse(bookmarkSurah, bookmarkVerse),
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
                                'Tap to open bookmarked verse',
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
