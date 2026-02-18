import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/colors.dart';
import '../../controllers/large_quran_controller.dart';
import 'package:quran/quran.dart' as quran;
import 'normal_quran_view.dart';
import 'surah_detail_view.dart';

class LargeQuranView extends StatelessWidget {
  const LargeQuranView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LargeQuranController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Large Font Quran'),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.gold,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: controller.searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) => controller.searchQuran(value),
              decoration: InputDecoration(
                hintText: 'Search Quran Verses...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                suffixIcon: Obx(
                  () => controller.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54),
                          onPressed: () => controller.clearSearch(),
                        )
                      : const SizedBox.shrink(),
                ),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
            ),
          ),

          // List Content
          Expanded(
            child: Obx(() {
              if (controller.isSearching.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.gold),
                );
              }

              // Show Search Results
              if (controller.searchQuery.isNotEmpty) {
                if (controller.searchResults.isEmpty) {
                  return const Center(
                    child: Text(
                      'No verses found',
                      style: TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: controller.searchResults.length,
                  itemBuilder: (context, index) {
                    final result = controller.searchResults[index];
                    return ListTile(
                      title: Text(
                        '${controller.getSurahNameEnglish(result.surah)} : ${result.verse}',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        result.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.rtl,
                        style: GoogleFonts.amiri(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                      onTap: () => _showNavigationChoice(
                        context,
                        result.surah,
                        result.verse,
                      ),
                    );
                  },
                );
              }

              // Show Default Surah List
              return ListView.builder(
                itemCount: controller.totalSurahs,
                itemBuilder: (context, index) {
                  int surahNumber = index + 1;
                  return ListTile(
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.5),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$surahNumber',
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      controller.getSurahNameEnglish(surahNumber),
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    subtitle: Text(
                      'Verses: ${controller.getVerseCount(surahNumber)}',
                      style: TextStyle(color: Colors.white.withOpacity(0.6)),
                    ),
                    trailing: Text(
                      controller.getSurahName(surahNumber),
                      style: GoogleFonts.amiri(
                        color: AppColors.gold,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      controller.currentSurahNumber.value = surahNumber;
                      Get.to(() => SurahDetailView(surahNumber: surahNumber));
                    },
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showNavigationChoice(BuildContext context, int surah, int verse) {
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
              'Open Verse In...',
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
                int page = quran.getPageNumber(surah, verse);
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
                final controller = Get.find<LargeQuranController>();
                controller.currentSurahNumber.value = surah;
                Get.to(
                  () =>
                      SurahDetailView(surahNumber: surah, initialVerse: verse),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
