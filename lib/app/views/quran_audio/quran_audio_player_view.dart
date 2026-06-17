import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import '../../controllers/quran_audio_controller.dart';
import '../../../utils/colors.dart';

class QuranAudioPlayerView extends StatefulWidget {
  const QuranAudioPlayerView({super.key});

  @override
  State<QuranAudioPlayerView> createState() => _QuranAudioPlayerViewState();
}

class _QuranAudioPlayerViewState extends State<QuranAudioPlayerView> with SingleTickerProviderStateMixin {
  late AnimationController _visualizerController;

  @override
  void initState() {
    super.initState();
    _visualizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _visualizerController.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
    }
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<QuranAudioController>();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF07241A), // Dark emerald top highlight
              Colors.black.withOpacity(0.95),
              Colors.black,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 1. Top Header Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 30),
                      onPressed: () => Get.back(),
                    ),
                    Column(
                      children: [
                        Text(
                          "now_playing".tr,
                          style: TextStyle(
                            color: AppColors.secondary.withOpacity(0.6),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "holy_quran".tr,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () => _showOptionsBottomSheet(context, controller),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // 2. Large Reciter Cover Image Card
              Obx(() {
                final reciter = controller.currentReciter.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 36),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.05),
                            blurRadius: 30,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Image.asset(
                          reciter.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.music_note_rounded, size: 64, color: AppColors.gold),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(flex: 2),

              // 3. Title & Artist Info
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Obx(() {
                      final surahIndex = controller.currentSurahIndex.value;
                      final surahNameEn = quran.getSurahNameEnglish(surahIndex);
                      final isArabic = Get.locale?.languageCode == 'ar';
                      final title = isArabic
                          ? quran.getSurahNameArabic(surahIndex)
                          : "Surah $surahNameEn";

                      return Text(
                        title,
                        textAlign: TextAlign.center,
                        style: isArabic
                            ? GoogleFonts.amiri(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              )
                            : const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                      );
                    }),
                    const SizedBox(height: 8),
                    Obx(() => Text(
                          controller.currentReciterNameLocalized,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.secondary, // Green emerald accent
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        )),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // 4. Progress Section (Slider & Timestamps)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Obx(() {
                  final position = controller.position.value;
                  final duration = controller.duration.value;

                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          activeTrackColor: AppColors.gold, // Gold accent progress
                          inactiveTrackColor: Colors.white.withOpacity(0.12),
                          thumbColor: AppColors.gold,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayColor: AppColors.gold.withOpacity(0.15),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                        ),
                        child: Slider(
                          value: position.inSeconds.toDouble().clamp(
                                0.0,
                                duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
                              ),
                          min: 0.0,
                          max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
                          onChanged: (value) {
                            controller.seek(Duration(seconds: value.toInt()));
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ),

              const Spacer(),

              // 5. Playback Controls Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Shuffle
                    Obx(() => IconButton(
                          icon: Icon(
                            Icons.shuffle_rounded,
                            color: controller.isShuffle.value ? AppColors.secondary : Colors.white.withOpacity(0.5),
                            size: 24,
                          ),
                          onPressed: controller.toggleShuffle,
                        )),

                    // Skip Previous
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 36),
                      onPressed: controller.prevSurah,
                    ),

                    // Play / Pause Circle
                    Obx(() {
                      final playing = controller.isPlaying.value;
                      final loading = controller.isLoading.value;

                      return GestureDetector(
                        onTap: controller.togglePlayPause,
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: AppColors.secondary, // Bright green accent circle
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.secondary.withOpacity(0.3),
                                blurRadius: 16,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: loading
                                ? const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      color: Colors.black,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : Icon(
                                    playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                    color: Colors.black,
                                    size: 38,
                                  ),
                          ),
                        ),
                      );
                    }),

                    // Skip Next
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 36),
                      onPressed: () => controller.nextSurah(),
                    ),

                    // Repeat Modes
                    Obx(() {
                      IconData icon;
                      Color color;
                      switch (controller.loopState.value) {
                        case LoopState.off:
                          icon = Icons.repeat_rounded;
                          color = Colors.white.withOpacity(0.5);
                          break;
                        case LoopState.all:
                          icon = Icons.repeat_rounded;
                          color = AppColors.secondary;
                          break;
                        case LoopState.one:
                          icon = Icons.repeat_one_rounded;
                          color = AppColors.secondary;
                          break;
                      }
                      return IconButton(
                        icon: Icon(icon, color: color, size: 24),
                        onPressed: controller.toggleLoop,
                      );
                    }),
                  ],
                ),
              ),

              const Spacer(flex: 2),

              // 6. Equalizer Visualizer Bars
              Obx(() {
                final isPlaying = controller.isPlaying.value;
                return SizedBox(
                  height: 30,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => AnimatedBuilder(
                        animation: _visualizerController,
                        builder: (context, child) {
                          double value = 1.0;
                          if (isPlaying) {
                            // Generate pseudo-random bar scaling based on sinus
                            final wave = index * 0.4;
                            value = (0.2 + 0.8 * (math.sin(_visualizerController.value * 2 * math.pi + wave).abs())).clamp(0.1, 1.0);
                          } else {
                            value = 0.15 + (index % 3) * 0.1;
                          }
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            width: 3.5,
                            height: 25 * value,
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(isPlaying ? 1.0 : 0.4),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              }),

              const Spacer(),

              // 7. Up Next Sheet Bar
              GestureDetector(
                onTap: () => _showUpNextBottomSheet(context, controller),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                    border: Border.all(color: Colors.white.withOpacity(0.03), width: 1),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "up_next".tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "view_all".tr,
                        style: TextStyle(
                          color: AppColors.secondary.withOpacity(0.9),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
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

  void _showUpNextBottomSheet(BuildContext context, QuranAudioController controller) {
    final isArabic = Get.locale?.languageCode == 'ar';
    Get.bottomSheet(
      Container(
        height: Get.height * 0.65,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "upcoming_surahs".tr,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.white12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: 114,
                itemBuilder: (context, index) {
                  final surahIndex = index + 1;
                  return Obx(() {
                    final isCurrent = controller.currentSurahIndex.value == surahIndex;
                    return ListTile(
                      leading: Text(
                        "$surahIndex",
                        style: TextStyle(
                          color: isCurrent ? AppColors.secondary : Colors.white38,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      title: Text(
                        quran.getSurahNameEnglish(surahIndex),
                        style: TextStyle(
                          color: isCurrent ? AppColors.secondary : Colors.white,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        isArabic
                            ? "${quran.getSurahNameArabic(surahIndex)} • ${quran.getVerseCount(surahIndex)} آية"
                            : "${quran.getSurahNameEnglish(surahIndex)} • ${quran.getVerseCount(surahIndex)} verses",
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      trailing: isCurrent
                          ? const Icon(Icons.graphic_eq_rounded, color: AppColors.secondary)
                          : const Icon(Icons.play_arrow_rounded, color: Colors.white24),
                      onTap: () {
                        controller.playbackSource.value = AudioPlaybackSource.all;
                        controller.playSurah(surahIndex);
                        Get.back();
                      },
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showOptionsBottomSheet(BuildContext context, QuranAudioController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              final isFav = controller.isFavorite(controller.currentSurahIndex.value);
              return ListTile(
                leading: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? Colors.red : Colors.white70),
                title: Text(
                  isFav ? "remove_from_favorites".tr : "add_to_favorites".tr,
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: () {
                  controller.toggleFavorite(controller.currentSurahIndex.value);
                  Get.back();
                },
              );
            }),
            const Divider(color: Colors.white12),
            Obx(() {
              final isDownloaded = controller.isSurahDownloaded(controller.currentSurahIndex.value);
              final isDownloading = controller.downloadProgress.containsKey(controller.currentSurahIndex.value);

              return ListTile(
                leading: Icon(
                  isDownloaded ? Icons.check_circle : Icons.download_for_offline_rounded,
                  color: isDownloaded ? AppColors.secondary : Colors.white70,
                ),
                title: Text(
                  isDownloading
                      ? "downloading_status".tr
                      : (isDownloaded ? "downloaded_status".tr : "download_this_surah".tr),
                  style: const TextStyle(color: Colors.white),
                ),
                onTap: isDownloaded || isDownloading
                    ? null
                    : () {
                        controller.downloadSurah(controller.currentSurahIndex.value);
                        Get.back();
                      },
              );
            }),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
