import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;
import 'package:mubin/utils/colors.dart';
import '../../controllers/quran_image_controller.dart';
import '../../controllers/large_quran_controller.dart';

class ImageQuranView extends StatefulWidget {
  final int? initialPage;
  const ImageQuranView({super.key, this.initialPage});

  @override
  State<ImageQuranView> createState() => _ImageQuranViewState();
}

class _ImageQuranViewState extends State<ImageQuranView> {
  late PageController _pageController;
  final QuranImageController imageController = Get.find<QuranImageController>();
  // We might need LargeQuranController for bookmarking if we want to reuse its logic
  final LargeQuranController largeQuranController = Get.put(
    LargeQuranController(),
  );

  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: (widget.initialPage ?? 1) - 1,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  void _saveBookmark(int pageIndex) {
    // pageIndex is 0-based, quran pages are 1-based
    int pageNumber = pageIndex + 1;
    // Get surah and verse for this page to be compatible with existing bookmark system
    // quran package has getVersesTextByPage, or we can just pick the first surah/verse on page
    // getSurahAndVersesFromPage returns Map<int, List<int>> (Surah number -> list of verses)
    // We'll take the first one.

    int foundSurah = 1;
    int foundVerse = 1;
    bool found = false;

    // Search for first verse on page
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

    if (found) {
      largeQuranController.saveBookmark(foundSurah, foundVerse);

      Get.snackbar(
        'Bookmark Saved',
        'Page $pageNumber saved as bookmark',
        backgroundColor: AppColors.secondary,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 1),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: _toggleControls,
              child: PageView.builder(
                controller: _pageController,
                itemCount: 604,
                reverse:
                    true, // Quran is RTL, so swiping right should go to next page (lower number? or higher?)
                // Usually Arabic books: Right to Left.
                // Page 1 is on the right. Swipe Right->Left to go to Page 2.
                // PageView reverse: true means index 0 is at right.
                // Scanning direction is 1 -> 2.
                // TextDirection.rtl?

                // Let's try simple PageView with reverse: true.
                // logical index 0 -> Page 1.
                // In RTL, 0 is rightmost.
                // Swipe Left (<-) reveals index 1 (Page 2). Correct.
                itemBuilder: (context, index) {
                  int pageNumber = index + 1;
                  File? imageFile = imageController.getPageImageFile(
                    pageNumber,
                  );

                  if (imageFile == null) {
                    return const Center(
                      child: Text(
                        'Image not found',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return Image.file(imageFile, fit: BoxFit.contain);
                },
              ),
            ),

            // Top Bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: _showControls ? 0 : -80,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.black54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Get.back(),
                    ),
                    const Text(
                      'Quran Images',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.bookmark_border,
                        color: AppColors.gold,
                      ),
                      onPressed: () {
                        int currentPage = (_pageController.page?.round() ?? 0);
                        _saveBookmark(currentPage);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Bar (Page Info)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              bottom: _showControls ? 0 : -80,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.black54,
                child: Center(
                  child: ListenableBuilder(
                    listenable: _pageController,
                    builder: (context, child) {
                      int p =
                          (_pageController.hasClients &&
                              _pageController.position.haveDimensions)
                          ? (_pageController.page?.round() ?? 0) + 1
                          : (widget.initialPage ?? 1);
                      return Text(
                        'Page $p',
                        style: const TextStyle(color: Colors.white),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
