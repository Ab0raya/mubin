import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/counter_controller.dart';
import '../../utils/colors.dart';

class CounterView extends GetView<CounterController> {
  const CounterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.background],
            stops: [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'counter'.tr.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      onPressed: () {
                        controller.reset();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () => _showEditDhikrDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(
                              () => Text(
                                controller.dhikrText.value,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 24, // Increased size for visibility
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'TheYearofHandicrafts',
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.edit,
                              color: Colors.white54,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 50),
                    GestureDetector(
                      onTap: () => controller.increment(),
                      child: Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.background,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.2),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.05),
                              blurRadius: 0,
                              spreadRadius: 2,
                            ),
                          ],
                          border: Border.all(
                            color: AppColors.gold.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Obx(
                            () => Text(
                              controller.count.value.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Text(
                      'tap_to_count'.tr,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Horizontal Templates List
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: controller.dhikrTemplates.length,
                        itemBuilder: (context, index) {
                          final template = controller.dhikrTemplates[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Obx(
                              () => ActionChip(
                                label: Text(
                                  template,
                                  style: TextStyle(
                                    color:
                                        controller.dhikrText.value == template
                                        ? AppColors.background
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'TheYearofHandicrafts',
                                  ),
                                ),
                                backgroundColor:
                                    controller.dhikrText.value == template
                                    ? AppColors.gold
                                    : Colors.white.withValues(alpha: 0.1),
                                onPressed: () {
                                  controller.updateDhikr(template);
                                  controller.count.value =
                                      0; // Reset count or keep it? Usually reset for new dhikr.
                                },
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDhikrDialog(BuildContext context) {
    final TextEditingController textController = TextEditingController(
      text: controller.dhikrText.value,
    );

    Get.dialog(
      Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'edit_dhikr'.tr,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: textController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'enter_dhikr'.tr,
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.gold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'cancel'.tr,
                      style: const TextStyle(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.background,
                    ),
                    onPressed: () {
                      controller.updateDhikr(textController.text);
                      Get.back();
                    },
                    child: Text('save'.tr),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
