import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mubin/utils/colors.dart';
import '../../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    // Force dark mode for onboarding as per design
    return Scaffold(
      backgroundColor: const Color(0xFF050B08),
      body: Stack(
        children: [
          // Background Elements
          _buildBackground(),

          SafeArea(
            child: Column(
              children: [
                // Top Bar (Skip / Back)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Obx(
                        () => controller.currentPage.value > 0
                            ? IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios,
                                  color: Colors.white,
                                ),
                                onPressed: controller.previousPage,
                              )
                            : const SizedBox.shrink(),
                      ),
                      // Skip button (optional, maybe disable for mandatory steps)
                      TextButton(
                        onPressed: () {
                          // Allow skip directly to finish? Or force steps?
                          // For now, force steps.
                        },
                        child: const Text(''),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: controller.pageController,
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable swipe to force button use/validation
                    children: [
                      _buildLanguagePage(),
                      _buildPermissionsPage(),
                      _buildCalculationPage(),
                      _buildFinishPage(),
                    ],
                  ),
                ),

                // Bottom Indicators and Next Button
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      // Indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          4,
                          (index) => Obx(() {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: controller.currentPage.value == index
                                  ? 24
                                  : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: controller.currentPage.value == index
                                    ? AppColors.secondary
                                    : Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            );
                          }),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Next Button
                      Obx(
                        () => SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: controller.isLoading.value
                                ? null
                                : controller.nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.secondary,
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 5,
                              shadowColor: AppColors.secondary.withOpacity(0.4),
                            ),
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.black,
                                  )
                                : Text(
                                    controller.currentPage.value == 3
                                        ? 'get_started'.tr
                                        : 'continue'.tr,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -100,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(0.15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 100,
                  spreadRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Step 1: Language ---
  Widget _buildLanguagePage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.language, size: 80, color: AppColors.gold),
        const SizedBox(height: 32),
        Text(
          'choose_language'.tr,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'select_language_subtitle'.tr,
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 48),

        // Language Buttons
        Obx(
          () => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _languageButton(
                'English',
                'en',
                controller.selectedLanguage.value == 'en',
              ),
              const SizedBox(width: 20),
              _languageButton(
                'العربية',
                'ar',
                controller.selectedLanguage.value == 'ar',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _languageButton(String label, String code, bool isSelected) {
    return GestureDetector(
      onTap: () => controller.setLanguage(code),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondary.withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          border: Border.all(
            color: isSelected ? AppColors.secondary : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.secondary : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  // --- Step 2: Permissions ---
  Widget _buildPermissionsPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.security, size: 80, color: AppColors.gold),
          const SizedBox(height: 32),
          Text(
            'permissions_required'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ).paddingOnly(bottom: 8),
          Text(
            'permissions_desc'.tr,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),

          // Location Permission Tile
          Obx(
            () => _permissionTile(
              icon: Icons.location_on,
              title: 'location_permission'.tr,
              subtitle: 'location_subtitle'.tr,
              isGranted: controller.isLocationGranted.value,
              onTap: controller.requestLocation,
            ),
          ),

          const SizedBox(height: 16),

          // Notification Permission Tile
          Obx(
            () => _permissionTile(
              icon: Icons.notifications_active,
              title: 'notification_permission'.tr,
              subtitle: 'notification_subtitle'.tr,
              isGranted: controller.isNotificationGranted.value,
              onTap: controller.requestNotification,
            ),
          ),

          const SizedBox(height: 16),

          // Camera Permission Tile
          Obx(
            () => _permissionTile(
              icon: Icons.camera_alt,
              title: 'camera_permission'.tr,
              subtitle: 'camera_subtitle'.tr,
              isGranted: controller.isCameraGranted.value,
              onTap: controller.requestCamera,
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isGranted
                ? AppColors.secondary
                : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isGranted
                    ? AppColors.secondary.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isGranted ? AppColors.secondary : Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isGranted)
              const Icon(Icons.check_circle, color: AppColors.secondary)
            else
              const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }

  // --- Step 3: Calculation Method ---
  Widget _buildCalculationPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.access_time_filled, size: 80, color: AppColors.gold),
          const SizedBox(height: 32),
          Text(
            'calculation_method'.tr,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'select_calc_method'.tr,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          Expanded(
            child: ListView(
              children: [
                _methodTile(5, 'calc_egypt'.tr),
                _methodTile(4, 'calc_umm_al_qura'.tr),
                _methodTile(3, 'calc_muslim_league'.tr),
                _methodTile(2, 'calc_isna'.tr),
                _methodTile(1, 'calc_karachi'.tr),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _methodTile(int id, String name) {
    return Obx(() {
      bool isSelected = controller.selectedCalculationMethod.value == id;
      return GestureDetector(
        onTap: () => controller.setCalculationMethod(id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.secondary.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.secondary : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: isSelected ? AppColors.secondary : Colors.grey,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white70,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // --- Step 4: Finish ---
  Widget _buildFinishPage() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondary.withOpacity(0.1),
            border: Border.all(
              color: AppColors.secondary.withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.secondary.withOpacity(0.2),
                blurRadius: 50,
                spreadRadius: 10,
              ),
            ],
          ),
          child: const Icon(Icons.check, size: 80, color: AppColors.secondary),
        ),
        const SizedBox(height: 48),
        Text(
          'all_set'.tr,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 48.0),
          child: Text(
            'preferences_saved'.tr,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
