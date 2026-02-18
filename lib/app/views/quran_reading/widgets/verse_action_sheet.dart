import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../utils/colors.dart';
import '../../../controllers/large_quran_controller.dart';

class VerseActionSheet extends GetView<LargeQuranController> {
  final int surahNumber;
  final int verseNumber;

  const VerseActionSheet({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: const BoxDecoration(
        color: AppColors.background, // Match app background or slightly lighter
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Verse Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Header (Copy Icon | Surah Name & No)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.copy_rounded,
                        color: AppColors.gold,
                      ),
                      onPressed: () {
                        controller.copyVerse(surahNumber, verseNumber);
                        Get.back();
                      },
                    ),
                    Row(
                      children: [
                        Text(
                          controller.getSurahName(surahNumber),
                          style: GoogleFonts.amiri(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Color(0xFFD4AF37), // Goldish circle bg
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$verseNumber',
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Verse Text
                Text(
                  controller.getVerse(surahNumber, verseNumber),
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    fontSize: 24,
                    color: Colors.white,
                    height: 1.8,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildActionItem(
                icon: Icons.share_rounded,
                label: 'Share',
                onTap: () {
                  controller.shareVerseAsImage(surahNumber, verseNumber);
                  Get.back();
                },
              ),
              _buildActionItem(
                icon: Icons
                    .search_rounded, // Using search icon for Tafseer as per common UI or maybe menu_book
                label: 'Tafseer',
                onTap: () {
                  Get.back();
                  _showTafseerDialog(context);
                },
              ),
              Obx(() {
                final isPlaying =
                    controller.currentPlayingVerse.value == verseNumber &&
                    controller.isPlaying.value;
                return _buildActionItem(
                  icon: isPlaying
                      ? Icons.pause_rounded
                      : Icons.volume_up_rounded,
                  label: isPlaying ? 'Stop' : 'Play',
                  onTap: () {
                    controller.playAudio(surahNumber, verseNumber);
                    Get.back();
                  },
                );
              }),
              Obx(() {
                final isBookmarked = controller.isBookmarked(
                  surahNumber,
                  verseNumber,
                );
                return _buildActionItem(
                  icon: isBookmarked
                      ? Icons.bookmark_added
                      : Icons.bookmark_border_rounded,
                  label: 'Bookmark',
                  onTap: () {
                    controller.toggleBookmark(surahNumber, verseNumber);
                    // Don't close sheet immediately to show state change? Or close?
                    // User might want to toggle and see. Let's keep it open for a sec or just close.
                    // Usually actions close the sheet.
                    Get.back();
                  },
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.gold, size: 28),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(color: AppColors.secondary, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showTafseerDialog(BuildContext context) {
    final tafseerText = controller.getTafseer(surahNumber, verseNumber);
    Get.defaultDialog(
      title: 'Tafseer',
      titleStyle: const TextStyle(
        color: AppColors.gold,
        fontWeight: FontWeight.bold,
      ),
      content: Container(
        height: 300,
        child: SingleChildScrollView(
          child: Text(
            tafseerText,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
          ),
        ),
      ),
      backgroundColor: AppColors.card,
      confirmTextColor: Colors.white,
      textConfirm: 'Close',
      onConfirm: () => Get.back(),
    );
  }
} // End class
