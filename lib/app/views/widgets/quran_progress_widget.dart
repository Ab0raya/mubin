import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import '../../../utils/colors.dart';
import '../../controllers/large_quran_controller.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/quran_image_controller.dart';
import '../quran_reading/normal_quran_view.dart';
import '../quran_reading/image_quran_view.dart';
import '../quran_reading/surah_detail_view.dart';

class QuranProgressWidget extends StatelessWidget {
  const QuranProgressWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure LargeQuranController is registered
    final controller = Get.put(LargeQuranController());

    return Obx(() {
      int lastReadPage = controller.lastReadPage.value;
      int lastReadSurah = controller.lastReadSurah.value;
      int lastReadVerse = controller.lastReadVerse.value;

      bool isFromBookmark = false;

      // Fallback to bookmark if lastReadPage is 1 (default) but bookmark is set
      if (lastReadPage == 1 && controller.lastBookmark.value != null) {
        final parts = controller.lastBookmark.value!.split(':');
        if (parts.length == 2) {
          final s = int.tryParse(parts[0]) ?? 1;
          final v = int.tryParse(parts[1]) ?? 1;
          lastReadPage = quran.getPageNumber(s, v);
          lastReadSurah = s;
          lastReadVerse = v;
          isFromBookmark = true;
        }
      }

      final surahNameEnglish = controller.getSurahNameEnglish(lastReadSurah);
      final surahNameArabic = controller.getSurahName(lastReadSurah);
      final progress = lastReadPage / 604.0;
      final percentage = (progress * 100).toStringAsFixed(0);

      final isArabic = Get.locale?.languageCode == 'ar';

      return Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
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
                Get.to(() => NormalQuranView(initialPage: lastReadPage));
              }
            },
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: AppColors.gold,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isFromBookmark
                                    ? 'mode_bookmarks'.tr.toUpperCase()
                                    : 'last_read'.tr.toUpperCase(),
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'resume_reading'.tr,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Arrow button indicator
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Surah details Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            surahNameEnglish,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isArabic
                                ? 'الصفحة $lastReadPage من ٦٠٤ • آية $lastReadVerse'
                                : 'Page $lastReadPage of 604 • Verse $lastReadVerse',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        surahNameArabic,
                        style: GoogleFonts.amiri(
                          color: AppColors.gold,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Progress indicator row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'quran_reading_progress'.tr,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        '$percentage%',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Horizontal progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white10,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.secondary,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
