import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../utils/constants.dart';
import '../routes/app_routes.dart';

import 'package:dio/dio.dart';
import '../services/backend_service.dart';

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
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
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

        final backendService = Get.find<BackendService>();
        final response = await backendService.login(
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        final token = response.data['token'];
        final box = GetStorage();
        box.write(Constants.keyAuthToken, token);

        Get.snackbar(
          'Success',
          'Logged in successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        _onSuccess();
      } catch (e) {
        String errorMsg = 'Login failed';
        if (e is DioException) {
          errorMsg = e.response?.data['message'] ?? e.message ?? errorMsg;
        } else {
          errorMsg = e.toString();
        }
        Get.snackbar(
          'Error',
          errorMsg,
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

        final backendService = Get.find<BackendService>();
        // Clean name to make it a valid username (alphanumeric with underscores)
        final username = nameController.text.trim().toLowerCase().replaceAll(RegExp(r'\s+'), '_');

        final response = await backendService.register(
          username: username,
          email: emailController.text.trim(),
          password: passwordController.text,
        );

        final token = response.data['token'];
        final box = GetStorage();
        box.write(Constants.keyAuthToken, token);

        Get.snackbar(
          'Success',
          'Account created successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        _onSuccess();
      } catch (e) {
        String errorMsg = 'Registration failed';
        if (e is DioException) {
          final errorData = e.response?.data;
          if (errorData is Map && errorData.containsKey('errors')) {
            final errors = errorData['errors'] as Map;
            errorMsg = errors.values.map((v) => (v as List).join(', ')).join('\n');
          } else {
            errorMsg = e.response?.data['message'] ?? e.message ?? errorMsg;
          }
        } else {
          errorMsg = e.toString();
        }
        Get.snackbar(
          'Error',
          errorMsg,
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

  Future<bool> requestPasswordOtp(String email) async {
    try {
      isLoading.value = true;
      final backendService = Get.find<BackendService>();
      await backendService.forgotPassword(email.trim());
      Get.snackbar(
        'OTP Sent',
        'Check your email (or laravel.log in local dev) for the 6-digit OTP code.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      String errorMsg = 'Failed to request OTP';
      if (e is DioException) {
        errorMsg = e.response?.data['message'] ?? e.message ?? errorMsg;
      }
      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> resetPasswordWithOtp(String email, String otp, String newPassword) async {
    try {
      isLoading.value = true;
      final backendService = Get.find<BackendService>();
      await backendService.resetPassword(
        email: email.trim(),
        otp: otp.trim(),
        password: newPassword,
      );
      Get.snackbar(
        'Success',
        'Password reset successfully. You can now sign in.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      String errorMsg = 'Failed to reset password';
      if (e is DioException) {
        errorMsg = e.response?.data['message'] ?? e.message ?? errorMsg;
      }
      Get.snackbar(
        'Error',
        errorMsg,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      isLoading.value = true;
      final backendService = Get.find<BackendService>();
      await backendService.logout();
      Get.offAllNamed(AppRoutes.login);
    } catch (e) {
      Get.offAllNamed(AppRoutes.login);
    } finally {
      isLoading.value = false;
    }
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
