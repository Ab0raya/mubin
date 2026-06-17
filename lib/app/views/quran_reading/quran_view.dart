import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/colors.dart';
import '../../routes/app_routes.dart';
import '../widgets/quran_option_card.dart';
import 'package:quran/quran.dart' as quran;
import '../../controllers/large_quran_controller.dart';
import '../../controllers/settings_controller.dart';
import 'normal_quran_view.dart';
import 'surah_detail_view.dart';
import 'normal_surah_list_view.dart';
import 'image_quran_view.dart';
import '../../controllers/quran_image_controller.dart';
import 'package:qcf_quran_plus/qcf_quran_plus.dart';

class QuranView extends StatelessWidget {
  const QuranView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LargeQuranController());
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.background],
            stops: [0.0, 0.3],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header and Search
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'quran_reading_header'.tr.toUpperCase(),
                      style:
                          TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 14,
                            letterSpacing: 2,
                          ).copyWith(
                            fontFeatures: [const FontFeature.enable('smcp')],
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'choose_mode'.tr,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Global Search Bar
                    TextField(
                      controller:
                          controller.searchController, // Reusing controller
                      style: const TextStyle(color: Colors.white),
                      onChanged: (value) => controller.searchQuran(value),
                      decoration: InputDecoration(
                        hintText: 'search_quran_hint'.tr,
                        hintStyle: const TextStyle(color: Colors.white54),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: AppColors.gold,
                        ),
                        suffixIcon: Obx(
                          () => controller.searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.white54,
                                  ),
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
                  ],
                ),
              ),

              // Content Area (Grid or Search Results)
              Expanded(
                child: Obx(() {
                  // 1. Search Active -> Show Results
                  if (controller.isSearching.value ||
                      controller.searchQuery.isNotEmpty) {
                    if (controller.isSearching.value) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.gold),
                      );
                    }

                    if (controller.searchResults.isEmpty) {
                      return Center(
                        child: Text(
                          'no_verses_found'.tr,
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      itemCount: controller.searchResults.length,
                      itemBuilder: (context, index) {
                        final result = controller.searchResults[index];
                        final surahNameAr = quran.getSurahNameArabic(result.surah);
                        final surahNameEn = controller.getSurahNameEnglish(result.surah);
                        final juzNumber = quran.getJuzNumber(result.surah, result.verse);
                        final pageNumber = quran.getPageNumber(result.surah, result.verse);
                        final revelationPlace = quran.getPlaceOfRevelation(result.surah);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.card,
                                AppColors.card.withOpacity(0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.gold.withOpacity(0.15),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  final settingsController = Get.put(SettingsController());
                                  final imageController = Get.put(QuranImageController());
                                  final largeQuranController = Get.find<LargeQuranController>();
                                  final favMode = settingsController.favReadingMode.value;
                                  final page = quran.getPageNumber(result.surah, result.verse);

                                  if (favMode == 'image') {
                                    if (imageController.isDownloaded.value) {
                                      Get.to(() => ImageQuranView(initialPage: page));
                                    } else {
                                      imageController.showDownloadDialog(onSuccess: () {
                                        Get.to(() => ImageQuranView(initialPage: page));
                                      });
                                    }
                                  } else if (favMode == 'large') {
                                    largeQuranController.currentSurahNumber.value = result.surah;
                                    Get.to(() => SurahDetailView(
                                          surahNumber: result.surah,
                                          initialVerse: result.verse,
                                        ));
                                  } else {
                                    Get.to(() => NormalQuranView(initialPage: page));
                                  }
                                },
                                splashColor: AppColors.gold.withOpacity(0.08),
                                highlightColor: AppColors.gold.withOpacity(0.04),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      // Header Row (Surah Info and Verse badge)
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Left: Surah Title and Badge
                                          Row(
                                            children: [
                                              // Beautiful custom badge for Verse number
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                decoration: BoxDecoration(
                                                  color: AppColors.gold.withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(
                                                    color: AppColors.gold.withOpacity(0.3),
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Text(
                                                  '${'verse'.tr} ${result.verse}',
                                                  style: const TextStyle(
                                                    color: AppColors.gold,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              // Surah Name (English)
                                              Text(
                                                surahNameEn,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                          // Right: Surah Name (Arabic)
                                          Text(
                                            surahNameAr,
                                            style: GoogleFonts.amiri(
                                              color: AppColors.gold,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      const Divider(
                                        color: Colors.white10,
                                        height: 1,
                                        thickness: 1,
                                      ),
                                      const SizedBox(height: 12),
                                      // Middle: Quran Text with highlighting
                                      Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: _buildHighlightedText(
                                          result.text,
                                          controller.searchQuery.value,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      // Bottom: Metadata Tags (Juz, Page, Revelation type)
                                      Row(
                                        children: [
                                          _buildMetadataTag(
                                            icon: Icons.grid_3x3_rounded,
                                            label: '${'juz'.tr} $juzNumber',
                                          ),
                                          const SizedBox(width: 8),
                                          _buildMetadataTag(
                                            icon: Icons.auto_stories_rounded,
                                            label: '${'page'.tr} $pageNumber',
                                          ),
                                          const SizedBox(width: 8),
                                          _buildMetadataTag(
                                            icon: revelationPlace.toLowerCase() == 'makkah'
                                                ? Icons.location_on_rounded
                                                : Icons.location_city_rounded,
                                            label: revelationPlace.tr,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  // 2. Default -> Show Options Grid
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 0,
                    ),
                    children: [
                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.85,
                        children: [
                          QuranOptionCard(
                            title: 'mode_normal'.tr,
                            subtitle: 'mode_normal_desc'.tr,
                            icon: Icons.menu_book_rounded,
                            iconColor: AppColors.gold,
                            onTap: () =>
                                Get.to(() => const NormalSurahListView()),
                          ),
                          QuranOptionCard(
                            title: 'mode_large'.tr,
                            subtitle: 'mode_large_desc'.tr,
                            icon: Icons.format_size_rounded,
                            iconColor: AppColors.secondary,
                            onTap: () => Get.toNamed(AppRoutes.quranLarge),
                            gradientColors: [
                              AppColors.card,
                              AppColors.secondary.withOpacity(0.1),
                            ],
                          ),
                          QuranOptionCard(
                            title: 'mode_tafseer'.tr,
                            subtitle: 'mode_tafseer_desc'.tr,
                            icon: Icons.library_books_rounded,
                            iconColor: AppColors.blue,
                            onTap: () => Get.toNamed(AppRoutes.quranTafseer),
                            gradientColors: [
                              AppColors.card,
                              AppColors.blue.withOpacity(0.1),
                            ],
                          ),
                          QuranOptionCard(
                            title: 'mode_bookmarks'.tr,
                            subtitle: 'mode_bookmarks_desc'.tr,
                            icon: Icons.bookmark_rounded,
                            iconColor: AppColors.orange,
                            onTap: () => Get.toNamed(AppRoutes.quranBookmarks),
                            gradientColors: [
                              AppColors.card,
                              AppColors.orange.withOpacity(0.1),
                            ],
                          ),
                          QuranOptionCard(
                            title: 'mode_images'.tr,
                            subtitle: 'mode_images_desc'.tr,
                            icon: Icons.image_rounded,
                            iconColor: AppColors.secondary,
                            onTap: () {
                              final imageController = Get.put(
                                QuranImageController(),
                              );
                              if (imageController.isDownloaded.value) {
                                Get.toNamed(AppRoutes.quranImage);
                              } else {
                                imageController.showDownloadDialog();
                              }
                            },
                            gradientColors: [
                              AppColors.card,
                              AppColors.secondary.withOpacity(0.1),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 100), // Bottom padding
                    ],
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }




  Widget _buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return Text(
        text,
        textAlign: TextAlign.justify,
        style: GoogleFonts.amiri(
          color: Colors.white,
          fontSize: 20,
          height: 1.6,
        ),
      );
    }

    final normalizedQuery = normalise(query).toLowerCase().trim();
    final words = text.split(' ');
    final List<InlineSpan> spans = [];

    for (int i = 0; i < words.length; i++) {
      final word = words[i];
      final normalizedWord = normalise(word).toLowerCase().trim();
      final bool isMatch = normalizedWord.contains(normalizedQuery) ||
          normalizedQuery.contains(normalizedWord) && normalizedWord.isNotEmpty;

      spans.add(
        TextSpan(
          text: word + (i == words.length - 1 ? '' : ' '),
          style: TextStyle(
            color: isMatch ? AppColors.gold : Colors.white.withOpacity(0.9),
            fontWeight: isMatch ? FontWeight.bold : FontWeight.normal,
            backgroundColor: isMatch ? AppColors.gold.withOpacity(0.1) : null,
          ),
        ),
      );
    }

    return Text.rich(
      TextSpan(
        style: GoogleFonts.amiri(
          fontSize: 20,
          height: 1.6,
        ),
        children: spans,
      ),
      textAlign: TextAlign.justify,
    );
  }

  Widget _buildMetadataTag({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppColors.gold.withOpacity(0.8),
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
