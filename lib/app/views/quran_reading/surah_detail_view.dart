import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:quran/quran.dart' as quran;
import '../../../utils/colors.dart';
import '../../controllers/large_quran_controller.dart';
import '../../controllers/settings_controller.dart';
import 'widgets/verse_action_sheet.dart';

class SurahDetailView extends StatefulWidget {
  final int surahNumber;
  final int? initialVerse;
  final int? pageNumber;

  const SurahDetailView({
    super.key,
    required this.surahNumber,
    this.initialVerse,
    this.pageNumber,
  });

  @override
  State<SurahDetailView> createState() => _SurahDetailViewState();
}

class _SurahDetailViewState extends State<SurahDetailView> {
  final LargeQuranController controller = Get.find<LargeQuranController>();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener = ItemPositionsListener.create();
  late final Worker surahWorker;

  @override
  void initState() {
    super.initState();
    // Initialize controller's currentSurahNumber with current surah
    controller.currentSurahNumber.value = widget.surahNumber;

    // Listen to changes in currentSurahNumber to scroll back to top and update last read position
    surahWorker = ever(controller.currentSurahNumber, (int newSurah) {
      if (itemScrollController.isAttached) {
        itemScrollController.jumpTo(index: 0);
      }
      controller.saveLastReadPosition(
        // Let's verify: controller.saveLastReadPosition parameter name is:
        // void saveLastReadPosition({required int surah, required int verse, required int page})
        // So the parameter name is indeed: surah
        surah: newSurah,
        verse: 1,
        page: quran.getPageNumber(newSurah, 1),
      );
    });

    // Save initial read position on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      int startVerse = widget.initialVerse ?? 1;
      int page = widget.pageNumber ?? quran.getPageNumber(widget.surahNumber, startVerse);
      controller.saveLastReadPosition(
        surah: widget.surahNumber,
        verse: startVerse,
        page: page,
      );

      // Scroll to initial verse if provided
      if (widget.initialVerse != null) {
        int index = widget.initialVerse! - 1;
        if (index >= 0 && index < controller.getVerseCount(widget.surahNumber)) {
          itemScrollController.jumpTo(index: index);
        }
      }
    });
  }

  @override
  void dispose() {
    surahWorker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Obx(() {
        final currentSurah = controller.currentSurahNumber.value;
        final verseCount = controller.getVerseCount(currentSurah);

        return ScrollablePositionedList.separated(
          itemScrollController: itemScrollController,
          itemPositionsListener: itemPositionsListener,
          padding: const EdgeInsets.all(16),
          itemCount: verseCount,
          separatorBuilder: (context, index) =>
              const Divider(color: Colors.white12),
          itemBuilder: (context, index) {
            int verseNumber = index + 1;
            final verseText = controller.getVerse(currentSurah, verseNumber);

            return Obx(() {
              final isPlaying =
                  controller.currentPlayingVerse.value == verseNumber &&
                  controller.isPlaying.value;

              return InkWell(
                onTap: () {
                  controller.saveLastReadPosition(
                    surah: currentSurah,
                    verse: verseNumber,
                    page: widget.pageNumber ?? quran.getPageNumber(currentSurah, verseNumber),
                  );
                  Get.bottomSheet(
                    VerseActionSheet(
                      surahNumber: currentSurah,
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
        );
      }),
    );
  }
}
