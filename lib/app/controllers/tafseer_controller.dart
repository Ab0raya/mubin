import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/tafseer_service.dart';
import '../data/models/tafseer_model.dart';
import 'package:quran/quran.dart' as quran;

class TafseerController extends GetxController {
  final TafseerService _tafseerService = Get.find<TafseerService>();

  // Use distinct state variables
  final TextEditingController searchController = TextEditingController();
  var searchQuery = ''.obs;
  var searchResults = <TafseerModel>[].obs;
  var isLoading = false.obs;

  // Location Search State
  var selectedSurah = 1.obs; // Default to Al-Fatiha
  final TextEditingController verseController = TextEditingController();

  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    // Listen to search query changes
    searchController.addListener(() {
      if (_debounce?.isActive ?? false) _debounce!.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        if (searchController.text.isNotEmpty) {
          search(searchController.text);
        }
      });
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    verseController.dispose();
    _debounce?.cancel();
    super.onClose();
  }

  void search(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      searchResults.clear();
      return;
    }

    isLoading.value = true;
    try {
      // Run search
      final results = _tafseerService.search(query);
      searchResults.assignAll(results);
    } catch (e) {
      print('Search error: $e');
      searchResults.clear();
    } finally {
      isLoading.value = false;
    }
  }

  void searchByLocation() {
    if (verseController.text.isEmpty) return;

    // Construct query as "surah:verse" to leverage existing service logic
    String query = '${selectedSurah.value}:${verseController.text}';
    search(query);
  }

  String getSurahName(String surahNumberStr) {
    int? num = int.tryParse(surahNumberStr);
    if (num != null) {
      return quran.getSurahName(num);
    }
    return 'Surah $surahNumberStr';
  }
}
