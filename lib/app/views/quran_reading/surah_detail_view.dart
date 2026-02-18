import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import '../../../utils/colors.dart';
import '../../controllers/large_quran_controller.dart';
import '../../controllers/settings_controller.dart';
import 'widgets/verse_action_sheet.dart';

class SurahDetailView extends GetView<LargeQuranController> {
  final int surahNumber;
  final int? initialVerse; // Add initialVerse

  const SurahDetailView({
    super.key,
    required this.surahNumber,
    this.initialVerse,
  });

  @override
  Widget build(BuildContext context) {
    // Save last read position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.saveLastRead(surahNumber);
    });

    final ItemScrollController itemScrollController = ItemScrollController();
    final ItemPositionsListener itemPositionsListener =
        ItemPositionsListener.create();

    // Scroll to initial verse if provided
    if (initialVerse != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Index is verseNumber - 1
        int index = initialVerse! - 1;
        if (index >= 0 && index < controller.getVerseCount(surahNumber)) {
          itemScrollController.jumpTo(index: index);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.getSurahName(controller.currentSurahNumber.value),
            style: GoogleFonts.amiri(fontWeight: FontWeight.bold, fontSize: 24),
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.gold,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 20),
            onPressed: () => controller.previousSurah(),
            tooltip: 'Previous Surah',
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 20),
            onPressed: () => controller.nextSurah(),
            tooltip: 'Next Surah',
          ),
        ],
      ),
      backgroundColor: AppColors.background,
      body: ScrollablePositionedList.separated(
        itemScrollController: itemScrollController,
        itemPositionsListener: itemPositionsListener,
        padding: const EdgeInsets.all(16),
        itemCount: controller.getVerseCount(surahNumber),
        separatorBuilder: (context, index) =>
            const Divider(color: Colors.white12),
        itemBuilder: (context, index) {
          int verseNumber = index + 1;
          final verseText = controller.getVerse(surahNumber, verseNumber);

          return Obx(() {
            final isPlaying =
                controller.currentPlayingVerse.value == verseNumber &&
                controller.isPlaying.value;
            // Highlight the initial bookmark verse as well if needed,
            // but for now scrolling to it is the main feature.

            return InkWell(
              onTap: () {
                Get.bottomSheet(
                  VerseActionSheet(
                    surahNumber: surahNumber,
                    verseNumber: verseNumber,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                decoration: BoxDecoration(
                  color: isPlaying
                      ? AppColors.secondary.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(() {
                      final settingsController = Get.find<SettingsController>();
                      return Text(
                        verseText,
                        textAlign: TextAlign.justify,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          fontSize: settingsController.quranFontSize.value,
                          color: Colors.white,
                          height: 2.0,
                        ),
                      );
                    }),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.5),
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$verseNumber',
                            style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isPlaying)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(
                              Icons.volume_up,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
  }
}
