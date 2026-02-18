import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/home_controller.dart';

class PrayerScheduleWidget extends GetView<HomeController> {
  const PrayerScheduleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF141F1B).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: 10),
              Container(width: 20, height: 1, color: Colors.white24),
              const SizedBox(width: 10),
              Text(
                'prayer_schedule'.tr.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Obx(
            () => Column(
              children: controller.prayers
                  .map((prayer) => _buildPrayerRow(prayer))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerRow(Map<String, dynamic> prayer) {
    bool isNext = prayer['isNext'] == true;
    bool isDone = prayer['done'] == true;
    Color color = isNext
        ? const Color(0xFF00E676)
        : (isDone ? Colors.white54 : Colors.white);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: isNext
          ? BoxDecoration(
              color: const Color(0xFF00E676).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border(
                left: BorderSide(color: const Color(0xFF00E676), width: 3),
              ),
            )
          : null,
      child: Row(
        children: [
          Icon(
            isNext
                ? Icons.radio_button_checked
                : (isDone ? Icons.check : Icons.access_time),
            color: color,
            size: 16,
          ),
          const SizedBox(width: 15),
          Text(
            prayer['name'].toString().tr,
            style: TextStyle(
              color: isNext ? Colors.white : color,
              fontSize: 16,
              fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Text(
            prayer['time'],
            style: TextStyle(
              color: isNext ? const Color(0xFF00E676) : color,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
