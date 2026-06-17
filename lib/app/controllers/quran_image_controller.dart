import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

import '../../utils/colors.dart';

class QuranImageController extends GetxController {
  final _storage = GetStorage();
  final _dio = Dio();
  CancelToken? _cancelToken;
  VoidCallback? _onDownloadSuccessCallback;

  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxBool isDownloaded = RxBool(GetStorage().read('quran_images_downloaded') ?? false);
  final RxString currentDownloadFile = ''.obs;

  static const String _downloadedKey = 'quran_images_downloaded';
  static const int _totalPages = 604;
  late String _imagesPath;
  bool _isInitialized = false;

  @override
  void onInit() {
    super.onInit();
    _initController();
  }

  Future<void> _initController() async {
    final directory = await getApplicationDocumentsDirectory();
    _imagesPath = '${directory.path}/quran_images';
    _isInitialized = true;
    _checkStatus();
  }

  Future<bool> _verifyAllImagesExist() async {
    final dir = Directory(_imagesPath);
    if (!await dir.exists()) return false;

    for (int i = 1; i <= _totalPages; i++) {
      String pageStr = i.toString().padLeft(3, '0');
      File file = File('$_imagesPath/$pageStr.png');
      if (!await file.exists() || await file.length() == 0) {
        return false;
      }
    }
    return true;
  }

  Future<void> _checkStatus() async {
    if (!_isInitialized) await _initController();

    bool allExist = await _verifyAllImagesExist();
    if (allExist) {
      isDownloaded.value = true;
      _storage.write(_downloadedKey, true);
    } else {
      isDownloaded.value = false;
      _storage.write(_downloadedKey, false);
    }
  }

  Future<void> downloadQuranImages() async {
    if (!_isInitialized) await _initController();

    try {
      isDownloading.value = true;
      downloadProgress.value = 0.0;
      _cancelToken = CancelToken();

      final directory = Directory(_imagesPath);
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      for (int i = 1; i <= _totalPages; i++) {
        if (_cancelToken!.isCancelled) break;

        String pageNumber = i.toString().padLeft(3, '0');
        String url =
            'https://raw.githubusercontent.com/M03een/Quran/main/$pageNumber.png';
        String savePath = '$_imagesPath/$pageNumber.png';

        File file = File(savePath);
        if (await file.exists()) {
          // Skip if already exists and is non-empty
          if (await file.length() > 0) {
            downloadProgress.value = i / _totalPages;
            continue;
          }
        }

        currentDownloadFile.value = 'Downloading Page $i / $_totalPages';

        int retryCount = 3;
        bool success = false;
        while (retryCount > 0 && !success) {
          if (_cancelToken!.isCancelled) break;
          try {
            await _dio.download(
              url,
              savePath,
              cancelToken: _cancelToken,
              deleteOnError: true,
            );
            success = true;
          } catch (e) {
            if (CancelToken.isCancel(e as dynamic)) {
              break;
            }
            retryCount--;
            if (retryCount == 0) {
              rethrow; // Re-throw the exception to fail the download process if all retries failed
            }
            await Future.delayed(const Duration(seconds: 1)); // Wait 1 second before retrying
          }
        }

        downloadProgress.value = i / _totalPages;
      }

      if (!_cancelToken!.isCancelled) {
        // Double check all files exist strictly before marking as success
        bool finalVerify = await _verifyAllImagesExist();
        if (finalVerify) {
          isDownloaded.value = true;
          _storage.write(_downloadedKey, true);

          // Close download dialog if it's currently open
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }

          Get.snackbar(
            'download_success_title'.tr,
            'download_success_msg'.tr,
            backgroundColor: AppColors.secondary.withValues(alpha: 0.9),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );

          // If a custom callback is provided (e.g. to open a specific page), execute it.
          // Otherwise, fall back to navigating to the images mode surah list.
          if (_onDownloadSuccessCallback != null) {
            _onDownloadSuccessCallback!();
            _onDownloadSuccessCallback = null;
          } else {
            Get.toNamed('/quran/image');
          }
        } else {
          throw Exception("Verification failed: Some images are missing or empty.");
        }
      }
    } catch (e) {
      if (!CancelToken.isCancel(e as dynamic)) {
        Get.snackbar(
          'download_error_title'.tr,
          'download_error_msg'.tr,
          backgroundColor: Colors.red.withValues(alpha: 0.9),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        print('Download Error: $e');
      }
    } finally {
      isDownloading.value = false;
      currentDownloadFile.value = '';
      _cancelToken = null;
    }
  }

  void cancelDownload() {
    _cancelToken?.cancel();
    isDownloading.value = false;
  }

  void showDownloadDialog({VoidCallback? onSuccess}) {
    _onDownloadSuccessCallback = onSuccess;
    Get.dialog(
      PopScope(
        canPop: false, // Prevent dismissal while downloading
        child: Dialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Obx(() {
              bool downloading = isDownloading.value;

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.download_rounded,
                    color: AppColors.gold,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'download_images_title'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    downloading
                        ? 'downloading_file'.tr
                        : 'download_images_desc'.tr,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  if (downloading) ...[
                    LinearProgressIndicator(
                      value: downloadProgress.value,
                      backgroundColor: Colors.white12,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(downloadProgress.value * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () => cancelDownload(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        foregroundColor: Colors.red,
                      ),
                      child: Text('download_cancel'.tr),
                    ),
                  ] else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: Text(
                            'download_not_now'.tr,
                            style: const TextStyle(color: Colors.white54),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => downloadQuranImages(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondary,
                            foregroundColor: AppColors.background,
                          ),
                          child: Text('download_all'.tr),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  File? getPageImageFile(int pageNumber) {
    if (!isDownloaded.value) return null;
    String pageStr = pageNumber.toString().padLeft(3, '0');
    File file = File('$_imagesPath/$pageStr.png');
    return file;
  }

  String getPageImagePath(int pageNumber) {
    String pageStr = pageNumber.toString().padLeft(3, '0');
    return '$_imagesPath/$pageStr.png';
  }
}
