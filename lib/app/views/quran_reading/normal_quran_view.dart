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
import '../../data/font_manager.dart';

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
  bool _isLoadingFonts = true;

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

    _isLoadingFonts = !FontManager.isLoaded;
    if (_isLoadingFonts) {
      _loadFonts();
    }

    // Save last read position for the initial page at startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _saveProgressForPage(_currentPage);
    });
  }

  Future<void> _loadFonts() async {
    await FontManager.ensureLoaded();
    if (mounted) {
      setState(() {
        _isLoadingFonts = false;
      });
    }
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
          child: _isLoadingFonts
              ? _buildLoadingScreen(context)
              : Stack(
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

  Widget _buildLoadingScreen(BuildContext context) {
    final isDark = _settingsController.isDarkMode.value;
    final bgColor = isDark ? AppColors.background : const Color(0xFFF9F6F0);
    final cardColor = isDark ? AppColors.card : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1B4D3E);
    final subTextColor = isDark ? Colors.white.withValues(alpha: 0.5) : const Color(0xFF556B2F);
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.05);
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03);
    final gradientColors = isDark 
        ? [AppColors.primary, AppColors.gold]
        : [const Color(0xFF2E7D32), AppColors.gold];

    return Container(
      color: bgColor,
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const _PulsingIcon(),
              const SizedBox(height: 40),
              
              Text(
                'MUBIN',
                style: GoogleFonts.outfit(
                  color: AppColors.gold,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                  shadows: [
                    Shadow(
                      color: shadowColor,
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Preparing Mushaf Pages...',
                style: GoogleFonts.outfit(
                  color: subTextColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 48),

              // Progress Card with glassmorphism style
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: isDark ? 0.7 : 0.9),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: borderCol,
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ValueListenableBuilder<double>(
                  valueListenable: FontManager.loadingProgress,
                  builder: (context, progress, child) {
                    final percentage = (progress * 100).toStringAsFixed(0);
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Loading Fonts',
                              style: GoogleFonts.outfit(
                                color: textColor.withValues(alpha: 0.9),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              '$percentage%',
                              style: GoogleFonts.outfit(
                                color: AppColors.gold,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Custom Linear Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 8,
                            width: double.infinity,
                            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: progress.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: gradientColors,
                                    ),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Optimizing font files for smooth rendering',
                          style: GoogleFonts.outfit(
                            color: subTextColor.withValues(alpha: 0.8),
                            fontSize: 11,
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsingIcon extends StatefulWidget {
  const _PulsingIcon();

  @override
  State<_PulsingIcon> createState() => _PulsingIconState();
}

class _PulsingIconState extends State<_PulsingIcon> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _animation,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: 0.15),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: const Icon(
          Icons.menu_book_rounded,
          color: AppColors.gold,
          size: 72,
        ),
      ),
    );
  }
}
