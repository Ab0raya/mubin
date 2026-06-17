import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/praying_tracker_controller.dart';
import '../../../utils/colors.dart';
import '../../data/models/analysis_report.dart';

class PrayerReportView extends GetView<PrayingTrackerController> {
  const PrayerReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Session Report"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Alhamdulillah, session completed.",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            // Score Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.surface,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    "Movement Accuracy",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Obx(
                    () => Text(
                      "${controller.movementScore.value}%",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Details Row
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      Icons.timer,
                      "Duration",
                      controller.prayerDuration.value,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildStatCard(
                      Icons.directions_walk,
                      "Rakats",
                      "${controller.rakatsCount.value}",
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Session Timeline",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),

            // Scrollable Timeline
            Expanded(
              child: Obx(() {
                final report = controller.lastReport.value;
                if (report.steps.isEmpty) {
                  return const Center(
                    child: Text(
                      "No steps recorded in this session.",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: report.steps.length,
                  itemBuilder: (context, index) {
                    final step = report.steps[index];
                    final durationString = "${(step.timestamp.inSeconds ~/ 60).toString().padLeft(2, '0')}:${(step.timestamp.inSeconds % 60).toString().padLeft(2, '0')}";
                    final confPercent = "${(step.confidence * 100).toStringAsFixed(1)}%";

                    // Let's check if there's any mistake at this timestamp
                    final mistakes = report.mistakes.where(
                      (m) => (m.timestamp.inMilliseconds - step.timestamp.inMilliseconds).abs() < 1000
                    );
                    final isMistake = mistakes.isNotEmpty;
                    final mistakeDesc = isMistake ? mistakes.first.description : "";

                    final poseName = "${step.pose.name[0].toUpperCase()}${step.pose.name.substring(1)}";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isMistake ? Colors.red.withOpacity(0.1) : AppColors.surface,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: isMistake ? Colors.red.withOpacity(0.3) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Time tag
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: isMistake ? Colors.red.withOpacity(0.2) : AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              durationString,
                              style: TextStyle(
                                color: isMistake ? Colors.red : AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Posture Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  poseName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  isMistake ? mistakeDesc : "Confidence: $confPercent",
                                  style: TextStyle(
                                    color: isMistake ? Colors.red[300] : Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Icon Indicator
                          Icon(
                            isMistake ? Icons.warning_amber_rounded : Icons.check_circle_outline_rounded,
                            color: isMistake ? Colors.red : Colors.green,
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),

            const SizedBox(height: 20),

            // Done Button
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Get.back(); // Close report
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppColors.primary, size: 30),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
