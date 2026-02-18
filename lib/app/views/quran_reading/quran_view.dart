import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/colors.dart';
import '../../routes/app_routes.dart';
import '../widgets/quran_option_card.dart';
import 'package:quran/quran.dart' as quran;
import '../../controllers/large_quran_controller.dart';
import 'normal_quran_view.dart';
import 'surah_detail_view.dart';
import 'normal_surah_list_view.dart';
import '../../controllers/quran_image_controller.dart';

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
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: controller.searchResults.length,
                      itemBuilder: (context, index) {
                        final result = controller.searchResults[index];
                        return Card(
                          color: AppColors.card,
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
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
                                _showDownloadDialog(context, imageController);
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
            Text(
              'open_verse_in'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.menu_book, color: AppColors.gold),
              title: Text(
                'mode_normal_label'.tr,
                style: const TextStyle(color: Colors.white),
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
              title: Text(
                'mode_large_label'.tr,
                style: const TextStyle(color: Colors.white),
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

  void _showDownloadDialog(
    BuildContext context,
    QuranImageController controller,
  ) {
    Get.dialog(
      PopScope(
        canPop: false, // Prevent dismissal while downloading
        child: Dialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Obx(() {
              bool downloading = controller.isDownloading.value;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.download_rounded,
                    color: AppColors.gold,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'download_images_title'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    downloading
                        ? 'downloading_file'.tr
                        : 'download_images_desc'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  if (downloading) ...[
                    LinearProgressIndicator(
                      value: controller.downloadProgress.value,
                      backgroundColor: Colors.white12,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(controller.downloadProgress.value * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () => controller.cancelDownload(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                      ),
                      child: Text('download_cancel'.tr),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'download_not_now'.tr,
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => controller.downloadQuranImages(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.background,
                          ),
                          child: Text('download_all'.tr),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}
