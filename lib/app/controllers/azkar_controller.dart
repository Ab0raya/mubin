import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mubin/utils/colors.dart';
import '../data/models/adhkar_model.dart';

class AzkarController extends GetxController {
  var categories = <AdhkarCategory>[].obs;
  var isLoading = true.obs;

  // Selection state
  var currentCategory = Rxn<AdhkarCategory>();
  var currentItemIndex = 0.obs;
  var currentCount = 0.obs;

  // UI State
  late PageController pageController;
  var fontSize = 22.0.obs;
  var isAutoTransition = true.obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    loadAdhkar();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  Future<void> loadAdhkar() async {
    try {
      isLoading.value = true;
      final String response = await rootBundle.loadString(
        'assets/data/adhkar.json',
      );
      final Map<String, dynamic> data = json.decode(response);
      categories.value = data.entries
          .map((entry) => AdhkarCategory.fromMap(entry.key, entry.value))
          .toList();
    } catch (e) {
      print("Error loading adhkar: $e");
      Get.snackbar('Error', 'Failed to load Azkar data');
    } finally {
      isLoading.value = false;
    }
  }

  void openCategory(AdhkarCategory category) {
    currentCategory.value = category;
    currentItemIndex.value = 0;
    currentCount.value = 0;
    // Reset page controller if it's attached, otherwise it will be initialized in view
    if (pageController.hasClients) {
      pageController.jumpToPage(0);
    }
    Get.toNamed('/azkar/detail');
  }

  void onPageChanged(int index) {
    currentItemIndex.value = index;
    currentCount.value = 0;
  }

  void incrementCount() {
    if (currentCategory.value == null) return;

    final item = currentCategory.value!.items[currentItemIndex.value];
    if (currentCount.value < item.count) {
      currentCount.value++;
      HapticFeedback.lightImpact(); // Add haptic feedback

      // Check if item is complete
      if (currentCount.value >= item.count) {
        HapticFeedback.mediumImpact();

        if (isAutoTransition.value) {
          if (currentItemIndex.value <
              currentCategory.value!.items.length - 1) {
            Future.delayed(const Duration(milliseconds: 500), () {
              nextItem();
            });
          } else {
            Get.snackbar(
              'Mubin',
              'All Azkar completed for this category!',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: AppColors.card,
              colorText: Colors.white,
            );
          }
        }
      }
    }
  }

  void nextItem() {
    if (currentCategory.value == null) return;
    if (currentItemIndex.value < currentCategory.value!.items.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousItem() {
    if (currentItemIndex.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void updateFontSize(double size) {
    fontSize.value = size;
  }

  void toggleAutoTransition() {
    isAutoTransition.value = !isAutoTransition.value;
  }
}
