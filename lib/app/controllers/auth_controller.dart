import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../utils/constants.dart';
import '../routes/app_routes.dart';

class AuthController extends GetxController {
  // Form Keys
  final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> registerFormKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();

  // Observable State
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    nameController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your name';
    }
    return null;
  }

  Future<void> login() async {
    if (loginFormKey.currentState!.validate()) {
      try {
        isLoading.value = true;
        // Simulate network delay
        await Future.delayed(const Duration(seconds: 2));

        // Success
        Get.snackbar(
          'Success',
          'Logged in successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        _onSuccess();
      } catch (e) {
        Get.snackbar(
          'Error',
          'Login failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> register() async {
    if (registerFormKey.currentState!.validate()) {
      try {
        isLoading.value = true;
        // Simulate network delay
        await Future.delayed(const Duration(seconds: 2));

        // Success
        Get.snackbar(
          'Success',
          'Account created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        _onSuccess();
      } catch (e) {
        Get.snackbar(
          'Error',
          'Registration failed: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    }
  }

  Future<void> loginWithGoogle() async {
    isLoading.value = true;
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    Get.snackbar(
      'Google Sign In',
      'Google Sign In simulated successfully',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    isLoading.value = false;
    _onSuccess();
  }

  void _onSuccess() {
    final box = GetStorage();
    box.write(Constants.keyIsLoggedIn, true); // Save login state

    if (box.read(Constants.keyOnboardingComplete) == true) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }

  void navigateToRegister() {
    Get.toNamed(AppRoutes.register);
  }

  void navigateToLogin() {
    Get.back();
  }
}
