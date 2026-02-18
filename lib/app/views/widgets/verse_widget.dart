import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors.dart';
import '../../controllers/home_controller.dart';

class VerseWidget extends GetView<HomeController> {
  const VerseWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Icon(
              Icons.format_quote_rounded,
              size: 60,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
          Obx(() {
            final verse = controller.verseOfTheDay.value;
            if (verse == null) return const SizedBox.shrink();

            final isArabic = Get.locale?.languageCode == 'ar';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'verse_of_the_day'.tr.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.gold,
                    fontSize: 10,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  isArabic ? verse.arabic : verse.translation,
                  style: const TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontSize: 14,
                    height: 1.5,
                    fontFamily:
                        'Amiri', // Ensure you have an arabic font if needed, or default
                  ),
                  textAlign: isArabic ? TextAlign.right : TextAlign.left,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${verse.surahName} ${verse.surahNumber}:${verse.ayahNumber}'
                          .toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Icon(
                        Icons.ios_share,
                        color: Colors.white54,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
