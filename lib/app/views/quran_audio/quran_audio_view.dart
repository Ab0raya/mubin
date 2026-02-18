import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:quran/quran.dart' as quran;
import '../../controllers/quran_audio_controller.dart';
import '../../../utils/colors.dart';
import '../../data/models/reciter.dart';
import 'surah_selection_sheet.dart';

class QuranAudioView extends StatelessWidget {
  const QuranAudioView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    final QuranAudioController controller = Get.put(QuranAudioController());

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              "now_playing".tr,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "holy_quran".tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _showReciterSelection(context, controller),
            icon: const Icon(Icons.queue_music, color: AppColors.primary),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Album Art
            Obx(
              () => Text(
                controller.currentReciterNameLocalized,
                style: const TextStyle(color: AppColors.primary, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),

            AspectRatio(
              aspectRatio: 1,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: -5,
                    ),
                  ],
                  image: const DecorationImage(
                    image: AssetImage(
                      'assets/images/quran_cover.png',
                    ), // Placeholder, need asset or network image
                    fit: BoxFit.cover,
                  ),
                ),
                // Fallback if image not found
                child: Container(),
              ),
            ),

            // Text Info
            Column(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.bottomSheet(
                      SurahSelectionSheet(controller: controller),
                      isScrollControlled: true,
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Obx(
                        () => IconButton(
                          onPressed: () => controller.toggleFavorite(
                            controller.currentSurahIndex.value,
                          ),
                          icon: Icon(
                            controller.isFavorite(
                                  controller.currentSurahIndex.value,
                                )
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color:
                                controller.isFavorite(
                                  controller.currentSurahIndex.value,
                                )
                                ? Colors.red
                                : Colors.grey,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      Obx(
                        () => Text(
                          controller.currentSurahNameLocalized,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Add a dropdown icon to indicate interactivity
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Progress Bar
            Obx(() {
              final position = controller.position.value;
              final duration = controller.duration.value;
              return Column(
                children: [
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 6,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 12,
                      ),
                      activeTrackColor: AppColors.primary,
                      inactiveTrackColor: Colors.white12,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: position.inSeconds.toDouble().clamp(
                        0,
                        duration.inSeconds.toDouble(),
                      ),
                      min: 0,
                      max: duration.inSeconds.toDouble() > 0
                          ? duration.inSeconds.toDouble()
                          : 1,
                      onChanged: (value) {
                        controller.seek(Duration(seconds: value.toInt()));
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(position),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDuration(duration),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(
                  () => IconButton(
                    onPressed: controller.toggleShuffle,
                    icon: Icon(
                      Icons.shuffle,
                      color: controller.isShuffle.value
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                  ),
                ),
                // Previous Button
                Transform.scale(
                  scaleX: Get.locale?.languageCode == 'ar' ? -1 : 1,
                  child: IconButton(
                    onPressed: controller.prevSurah,
                    icon: const Icon(
                      Icons.skip_previous_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Obx(
                    () => IconButton(
                      onPressed: controller.togglePlayPause,
                      icon: Icon(
                        controller.isPlaying.value
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.black,
                        size: 36,
                      ),
                    ),
                  ),
                ),
                // Next Button
                Transform.scale(
                  scaleX: Get.locale?.languageCode == 'ar' ? -1 : 1,
                  child: IconButton(
                    onPressed: controller.nextSurah,
                    icon: const Icon(
                      Icons.skip_next_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                Obx(() {
                  IconData icon;
                  Color color;
                  switch (controller.loopState.value) {
                    case LoopState.off:
                      icon = Icons.repeat;
                      color = Colors.grey;
                      break;
                    case LoopState.all:
                      icon = Icons.repeat;
                      color = AppColors.primary;
                      break;
                    case LoopState.one:
                      icon = Icons.repeat_one;
                      color = AppColors.primary;
                      break;
                  }
                  return IconButton(
                    onPressed: controller.toggleLoop,
                    icon: Icon(icon, color: color),
                  );
                }),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  void _showReciterSelection(
    BuildContext context,
    QuranAudioController controller,
  ) {
    Get.bottomSheet(
      Container(
        height: 400,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "select_reciter".tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: Reciter.reciters.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.white.withOpacity(0.1)),
                itemBuilder: (context, index) {
                  final reciter = Reciter.reciters[index];
                  return Obx(() {
                    final isSelected =
                        controller.currentReciter.value.name == reciter.name;
                    return ListTile(
                      title: Text(
                        Get.locale?.languageCode == 'ar'
                            ? reciter.arabicName
                            : reciter.name,
                        style: TextStyle(
                          color: isSelected ? AppColors.primary : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () {
                        controller.changeReciter(reciter);
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
}
