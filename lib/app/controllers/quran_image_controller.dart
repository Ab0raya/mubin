import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:path_provider/path_provider.dart';

class QuranImageController extends GetxController {
  final _storage = GetStorage();
  final _dio = Dio();
  CancelToken? _cancelToken;

  final RxBool isDownloading = false.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxBool isDownloaded = false.obs; // True if ALL images are downloaded
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

  Future<void> _checkStatus() async {
    if (!_isInitialized) await _initController();

    // Check if the flag is set
    bool flag = _storage.read(_downloadedKey) ?? false;

    if (flag) {
      // Verify files exist (simple check, maybe just count)
      final dir = Directory(_imagesPath);
      if (await dir.exists()) {
        final fileCount = await dir.list().length;
        // We can be lenient or strict. Let's be reasonably strict.
        if (fileCount >= _totalPages) {
          isDownloaded.value = true;
          return;
        }
      }
      // If flag is true but files missing, reset
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
        // Ensure format matches the source. If URL is 001.png, 002.png...
        String url =
            'https://raw.githubusercontent.com/M03een/Quran/main/$pageNumber.png';
        String savePath = '$_imagesPath/$pageNumber.png';

        File file = File(savePath);
        if (await file.exists()) {
          // Skip if already exists (resume capability)
          // Check size? fast check: if > 0 bytes
          if (await file.length() > 0) {
            downloadProgress.value = i / _totalPages;
            continue;
          }
        }

        currentDownloadFile.value = 'Downloading Page $i / $_totalPages';

        try {
          await _dio.download(
            url,
            savePath,
            cancelToken: _cancelToken,
            deleteOnError: true,
          );
        } catch (e) {
          // If cancelled, stop
          if (CancelToken.isCancel(e as dynamic)) {
            break;
          }
          rethrow;
        }

        downloadProgress.value = i / _totalPages;
      }

      if (!_cancelToken!.isCancelled) {
        isDownloaded.value = true;
        _storage.write(_downloadedKey, true);
        // Get.snackbar('Success', 'Quran images downloaded successfully');
      }
    } catch (e) {
      if (!CancelToken.isCancel(e as dynamic)) {
        // Get.snackbar('Error', 'Failed to download images: $e');
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
