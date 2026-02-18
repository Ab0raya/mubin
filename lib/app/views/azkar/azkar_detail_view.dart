import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/azkar_controller.dart';
import '../../../utils/colors.dart';

class AzkarDetailView extends GetView<AzkarController> {
  const AzkarDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Obx(
          () => Text(
            controller.currentCategory.value?.category.tr ?? 'azkar'.tr,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          const Icon(Icons.keyboard_arrow_up, color: Colors.white54),
          Expanded(
            child: Obx(() {
              if (controller.currentCategory.value == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final category = controller.currentCategory.value!;

              return PageView.builder(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                itemCount: category.items.length,
                itemBuilder: (context, index) {
                  final item = category.items[index];
                  // Use a distinct key to ensure state rebuilds correctly if needed
                  return _buildAzkarCard(
                    context,
                    item,
                    index,
                    category.items.length,
                  );
                },
              );
            }),
          ),
          const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          _buildBottomControls(context),
        ],
      ),
    );
  }

  Widget _buildAzkarCard(
    BuildContext context,
    dynamic item,
    int index,
    int total,
  ) {
    return GestureDetector(
      onTap: controller.incrementCount,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Index Chip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                "${index + 1} / $total",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            Expanded(
              child: padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: SingleChildScrollView(
                    child: Obx(
                      () => Text(
                        item.text,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: controller.fontSize.value,
                          height: 1.8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Section
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  // Count Chip
                  Obx(
                    () => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Text(
                        "${controller.currentCount.value} / ${item.count}",
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Obx(
                      () => LinearProgressIndicator(
                        value: item.count > 0
                            ? (controller.currentCount.value / item.count)
                            : 0,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.secondary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Source (Only item left from actions)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Center it
                      children: [
                        Text(
                          "source".tr,
                          style: const TextStyle(
                            color: AppColors.secondary,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
      child: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Text(
              "AA",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () => _showFontSizeDialog(context),
          ),
        ),
      ),
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'font_size'.tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  "A",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Expanded(
                  child: Obx(
                    () => Slider(
                      value: controller.fontSize.value,
                      min: 16,
                      max: 40,
                      activeColor: AppColors.secondary,
                      onChanged: (val) => controller.updateFontSize(val),
                    ),
                  ),
                ),
                const Text(
                  "A",
                  style: TextStyle(color: Colors.white, fontSize: 24),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAutoTransitionDialog(BuildContext context) {
    Get.defaultDialog(
      title: "Auto Transition",
      content: Obx(
        () => SwitchListTile(
          title: const Text("Enable Auto Transition"),
          value: controller.isAutoTransition.value,
          onChanged: (val) {
            controller.toggleAutoTransition();
            Get.back();
          },
        ),
      ),
    );
  }

  Widget padding({required EdgeInsets padding, required Widget child}) {
    return Padding(padding: padding, child: child);
  }
}
