import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';
import 'package:quran/quran.dart' as quran;
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/colors.dart';
import '../../controllers/large_quran_controller.dart';
import 'widgets/verse_action_sheet.dart';
import 'widgets/surah_selection_sheet.dart';
import '../../controllers/settings_controller.dart';

class NormalQuranView extends StatefulWidget {
  final int? initialPage;
  const NormalQuranView({super.key, this.initialPage});

  @override
  State<NormalQuranView> createState() => _NormalQuranViewState();
}

class _NormalQuranViewState extends State<NormalQuranView> {
  late PageController _pageController;
  late LargeQuranController _largeQuranController;
  late SettingsController _settingsController;
  int _currentPage = 1;
  bool _showControls = false;
  int _currentQuarter = 1;

  @override
  void initState() {
    super.initState();
    _largeQuranController = Get.put(LargeQuranController());
    _settingsController = Get.find<SettingsController>();
    _currentPage = widget.initialPage ?? 1;
    _currentQuarter = _getQuarterForPage(_currentPage);

    // Page index is 0-indexed in PageController
    final startPage = _currentPage - 1;
    _pageController = PageController(initialPage: startPage);

    // Save last read position for the initial page at startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveProgressForPage(_currentPage);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _saveProgressForPage(int pageNumber) {
    int foundSurah = 1;
    int foundVerse = 1;
    bool found = false;
    for (int s = 1; s <= 114; s++) {
      int count = quran.getVerseCount(s);
      for (int v = 1; v <= count; v++) {
        if (quran.getPageNumber(s, v) == pageNumber) {
          foundSurah = s;
          foundVerse = v;
          found = true;
          break;
        }
      }
      if (found) break;
    }
    _largeQuranController.saveLastReadPosition(
      surah: foundSurah,
      verse: foundVerse,
      page: pageNumber,
    );
  }

  int _getSurahForPage(int pageNumber) {
    int foundSurah = 1;
    bool found = false;
    for (int s = 1; s <= 114; s++) {
      int count = quran.getVerseCount(s);
      for (int v = 1; v <= count; v++) {
        if (quran.getPageNumber(s, v) == pageNumber) {
          foundSurah = s;
          found = true;
          break;
        }
      }
      if (found) break;
    }
    return foundSurah;
  }

  int _getJuzForPage(int pageNumber) {
    int foundSurah = 1;
    int foundVerse = 1;
    bool found = false;
    for (int s = 1; s <= 114; s++) {
      int count = quran.getVerseCount(s);
      for (int v = 1; v <= count; v++) {
        if (quran.getPageNumber(s, v) == pageNumber) {
          foundSurah = s;
          foundVerse = v;
          found = true;
          break;
        }
      }
      if (found) break;
    }
    return quran.getJuzNumber(foundSurah, foundVerse);
  }

  int _getQuarterForPage(int pageNumber) {
    int foundSurah = 1;
    int foundVerse = 1;
    bool found = false;
    for (int s = 1; s <= 114; s++) {
      int count = quran.getVerseCount(s);
      for (int v = 1; v <= count; v++) {
        if (quran.getPageNumber(s, v) == pageNumber) {
          foundSurah = s;
          foundVerse = v;
          found = true;
          break;
        }
      }
      if (found) break;
    }
    return getQuarterNumber(foundSurah, foundVerse);
  }

  void _showQuarterPopup(int quarterNumber) {
    int hizb = ((quarterNumber - 1) ~/ 4) + 1;
    int localQuarter = (quarterNumber - 1) % 4 + 1;

    String arabicTitle = '';
    String englishTitle = '';

    switch (localQuarter) {
      case 1:
        arabicTitle = 'بداية الحزب $hizb';
        englishTitle = 'Beginning of Hizb $hizb';
        break;
      case 2:
        arabicTitle = 'ربع الحزب $hizb';
        englishTitle = 'First Quarter of Hizb $hizb';
        break;
      case 3:
        arabicTitle = 'نصف الحزب $hizb';
        englishTitle = 'Half of Hizb $hizb';
        break;
      case 4:
        arabicTitle = 'ثلاثة أرباع الحزب $hizb';
        englishTitle = 'Three-Quarters of Hizb $hizb';
        break;
    }

    Get.closeAllSnackbars();

    Get.rawSnackbar(
      titleText: Text(
        arabicTitle,
        textAlign: TextAlign.center,
        style: GoogleFonts.amiri(
          color: AppColors.gold,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      messageText: Text(
        englishTitle,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: AppColors.card.withValues(alpha: 0.95),
      borderRadius: 15,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      animationDuration: const Duration(milliseconds: 400),
      boxShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.5),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
      borderColor: AppColors.gold.withValues(alpha: 0.3),
      borderWidth: 1,
    );
  }

  Widget _buildQuarterDots(int quarterNumber) {
    int activeDots = (quarterNumber - 1) % 4 + 1;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(4, (index) {
        bool isActive = index < activeDots;
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive
                ? AppColors.gold
                : Colors.white.withValues(alpha: 0.2),
            border: Border.all(
              color: isActive
                  ? AppColors.gold
                  : Colors.white.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int currentSurah = _getSurahForPage(_currentPage);
    final String surahNameArabic = quran.getSurahNameArabic(currentSurah);
    final int juz = _getJuzForPage(_currentPage);

    return Obx(
      () => Scaffold(
        backgroundColor: Color(_settingsController.readingBgColor.value),
        body: SafeArea(
          child: Stack(
            children: [
              // Quran page reader with tap gesture detector
              GestureDetector(
                onTap: () {
                  setState(() {
                    _showControls = !_showControls;
                  });
                },
                behavior: HitTestBehavior.translucent,
                child: QuranPageView(
                  highlights: [],
                  pageController: _pageController,
                  isDarkMode: _settingsController.isDarkMode.value,
                  isTajweed: false,
                  pageBackgroundColor: Color(
                    _settingsController.readingBgColor.value,
                  ),
                  ayahStyle: TextStyle(
                    color: Color(_settingsController.readingTextColor.value),
                  ),
                  onPageChanged: (pageNumber) {
                    final newQuarter = _getQuarterForPage(pageNumber);
                    if (newQuarter != _currentQuarter) {
                      _currentQuarter = newQuarter;
                      _showQuarterPopup(newQuarter);
                    }
                    setState(() {
                      _currentPage = pageNumber;
                    });
                    _saveProgressForPage(pageNumber);
                  },
                  onLongPress: (surahNumber, verseNumber, details) {
                    Get.bottomSheet(
                      VerseActionSheet(
                        surahNumber: surahNumber,
                        verseNumber: verseNumber,
                      ),
                      isScrollControlled: true,
                    );
                  },
                ),
              ),

              // Top Floating Widget (Header)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                top: _showControls ? 16 : -100,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              quran.getPlaceOfRevelation(currentSurah),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Juz $juz',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.5),
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.bottomSheet(
                            SurahSelectionSheet(
                              onSurahSelected: (surahNumber) {
                                int page = quran.getPageNumber(surahNumber, 1);
                                _pageController.jumpToPage(page - 1);
                                setState(() {
                                  _currentPage = page;
                                });
                                _saveProgressForPage(page);
                              },
                            ),
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                          );
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              surahNameArabic,
                              style: GoogleFonts.amiri(
                                color: AppColors.gold,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.gold,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Floating Widget (Footer)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                bottom: _showControls ? 16 : -100,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Icon
                      _buildQuarterDots(_getQuarterForPage(_currentPage)),

                      // Divider
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),

                      // Center Number
                      Text(
                        '$_currentPage',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      // Divider
                      Container(
                        width: 1,
                        height: 40,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),

                      // Book icon indicating even/odd page layout
                      _currentPage % 2 == 0
                          ? const Icon(
                              Icons.menu_book_rounded,
                              color: AppColors.gold,
                              size: 28,
                            )
                          : Transform.flip(
                              flipX: true,
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: AppColors.gold,
                                size: 28,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
