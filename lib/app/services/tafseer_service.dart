import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../data/models/tafseer_model.dart';

class TafseerService extends GetxService {
  final List<TafseerModel> _tafseerList = [];

  Future<TafseerService> init() async {
    await loadTafseerData();
    return this;
  }

  Future<void> loadTafseerData() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/data/tafseer.json',
      );
      final List<TafseerModel> parsedList = await Isolate.run(() {
        final List<dynamic> jsonList = json.decode(jsonString);
        return jsonList.map((json) => TafseerModel.fromJson(json)).toList();
      });
      _tafseerList.clear();
      _tafseerList.addAll(parsedList);
    } catch (e) {
      print('Error loading tafseer data: $e');
    }
  }

  String getTafseer(int surahNumber, int ayaNumber) {
    final tafseer = _tafseerList.firstWhere(
      (element) =>
          element.number == surahNumber.toString() &&
          element.aya == ayaNumber.toString(),
      orElse: () => TafseerModel(
        number: '',
        aya: '',
        text: 'Tafseer not found for this verse.',
      ),
    );
    return tafseer.text;
  }

  /// Searches for tafseer by text query or "surah:aya" pattern (e.g., "2:255").
  List<TafseerModel> search(String query) {
    if (query.isEmpty) return [];

    // Check for "surah:aya" pattern
    final RegExp surahAyaRegex = RegExp(r'^(\d+):(\d+)$');
    final match = surahAyaRegex.firstMatch(query.trim());

    if (match != null) {
      final surah = match.group(1);
      final aya = match.group(2);
      return _tafseerList
          .where((t) => t.number == surah && t.aya == aya)
          .toList();
    }

    // Text search
    return _tafseerList.where((t) {
      return t.text.contains(query.trim());
    }).toList();
  }
}
