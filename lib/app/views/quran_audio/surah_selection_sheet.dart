import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quran/quran.dart' as quran;
import '../../controllers/quran_audio_controller.dart';
import '../../data/models/reciter.dart';
import '../../../utils/colors.dart';

class SurahSelectionSheet extends StatelessWidget {
  final QuranAudioController controller;

  const SurahSelectionSheet({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: Get.height * 0.85,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'holy_quran'.tr, // Use existing key or "Quran List"
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Tab Bar
            TabBar(
              indicatorColor: AppColors.primary,
              indicatorWeight: 3,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              tabs: [
                Tab(text: "surah".tr + "s"), // "Surahs"
                Tab(text: "downloaded".tr),
                Tab(text: "favorites".tr),
              ],
            ),
            const SizedBox(height: 8),
            // Tab View
            Expanded(
              child: TabBarView(
                children: [
                  _buildAllSurahsList(),
                  _buildDownloadedList(),
                  _buildFavoritesList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllSurahsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 114,
      itemBuilder: (context, index) {
        final surahIndex = index + 1;
        return Obx(() {
          final isPlaying =
              controller.currentSurahIndex.value == surahIndex &&
              controller.playbackSource.value == AudioPlaybackSource.all;
          final isDownloaded = controller.isSurahDownloaded(surahIndex);
          final isDownloading = controller.downloadProgress.containsKey(
            surahIndex,
          );
          final isFavorite = controller.isFavorite(surahIndex);

          return Card(
            color: isPlaying
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.card,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isPlaying
                  ? const BorderSide(color: AppColors.primary, width: 1)
                  : BorderSide.none,
            ),
            child: ListTile(
              leading: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isPlaying ? AppColors.primary : Colors.white12,
                  ),
                ),
                child: Text(
                  '$surahIndex',
                  style: TextStyle(
                    color: isPlaying ? AppColors.primary : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                Get.locale?.languageCode == 'ar'
                    ? quran.getSurahNameArabic(surahIndex)
                    : "Surah ${quran.getSurahName(surahIndex)}",
                style: TextStyle(
                  color: isPlaying ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
              ),
              subtitle: Text(
                quran.getSurahNameEnglish(surahIndex),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Favorite Toggle
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                    onPressed: () => controller.toggleFavorite(surahIndex),
                  ),

                  // Download Action
                  if (isDownloading)
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        value: controller.downloadProgress[surahIndex],
                        strokeWidth: 2,
                        color: AppColors.secondary,
                      ),
                    )
                  else if (isDownloaded)
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.secondary,
                      size: 24,
                    )
                  else
                    IconButton(
                      icon: const Icon(
                        Icons.download_rounded,
                        color: Colors.grey,
                        size: 24,
                      ),
                      onPressed: () => controller.downloadSurah(surahIndex),
                    ),
                ],
              ),
              onTap: () {
                controller.playbackSource.value = AudioPlaybackSource.all;
                controller.playSurah(surahIndex);
                Get.back();
              },
            ),
          );
        });
      },
    );
  }

  Widget _buildDownloadedList() {
    return Obx(() {
      if (controller.downloadedSurahs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 60,
                color: Colors.white.withOpacity(0.2),
              ),
              const SizedBox(height: 16),
              Text(
                "no_downloads".tr, // Add key if missing, or use default
                style: const TextStyle(color: Colors.white54),
              ),
            ],
          ),
        );
      }

      final sortedDownloads = controller.downloadedSurahs.toList()..sort();

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: sortedDownloads.length,
        itemBuilder: (context, index) {
          final surahIndex = sortedDownloads[index];
          final isPlaying =
              controller.currentSurahIndex.value == surahIndex &&
              controller.playbackSource.value == AudioPlaybackSource.downloaded;

          return Card(
            color: isPlaying
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.card,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isPlaying
                  ? const BorderSide(color: AppColors.primary, width: 1)
                  : BorderSide.none,
            ),
            child: ListTile(
              leading: const Icon(
                Icons.download_done,
                color: AppColors.secondary,
              ),
              title: Text(
                Get.locale?.languageCode == 'ar'
                    ? quran.getSurahNameArabic(surahIndex)
                    : "Surah ${quran.getSurahName(surahIndex)}",
                style: TextStyle(
                  color: isPlaying ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.play_arrow_rounded,
                  color: isPlaying ? AppColors.primary : Colors.white,
                ),
                onPressed: () {
                  controller.playDownloadedTrack(surahIndex);
                  Get.back();
                },
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildFavoritesList() {
    return Obx(() {
      if (controller.favoriteTracks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 60,
                color: Colors.white.withOpacity(0.2),
              ),
              const SizedBox(height: 16),
              const Text(
                "No favorites yet", // Localize later if needed
                style: TextStyle(color: Colors.white54),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: controller.favoriteTracks.length,
        itemBuilder: (context, index) {
          final track = controller.favoriteTracks[index];
          final surahIndex = track.surahIndex;

          // Check if playing from favorites
          final isPlaying =
              controller.currentSurahIndex.value == surahIndex &&
              controller.currentReciter.value.name == track.reciterName &&
              controller.playbackSource.value == AudioPlaybackSource.favorites;

          return Card(
            color: isPlaying
                ? AppColors.primary.withOpacity(0.1)
                : AppColors.card,
            margin: const EdgeInsets.only(bottom: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: isPlaying
                  ? const BorderSide(color: AppColors.primary, width: 1)
                  : BorderSide.none,
            ),
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: Text(
                Get.locale?.languageCode == 'ar'
                    ? quran.getSurahNameArabic(surahIndex)
                    : "Surah ${quran.getSurahName(surahIndex)}",
                style: TextStyle(
                  color: isPlaying ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Amiri',
                ),
              ),
              subtitle: Text(
                Get.locale?.languageCode == 'ar'
                    ? Reciter.reciters
                          .firstWhere(
                            (r) => r.name == track.reciterName,
                            orElse: () => Reciter.reciters.first,
                          )
                          .arabicName
                    : track.reciterName,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.play_arrow_rounded,
                  color: isPlaying ? AppColors.primary : AppColors.primary,
                ),
                onPressed: () {
                  controller.playFavoriteTrack(track);
                  Get.back();
                },
              ),
            ),
          );
        },
      );
    });
  }
}
