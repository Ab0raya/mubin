import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import '../../../../utils/colors.dart';

class SurahSelectionSheet extends StatefulWidget {
  final Function(int surahNumber) onSurahSelected;
  const SurahSelectionSheet({super.key, required this.onSurahSelected});

  @override
  State<SurahSelectionSheet> createState() => _SurahSelectionSheetState();
}

class _SurahSelectionSheetState extends State<SurahSelectionSheet> {
  final TextEditingController _searchController = TextEditingController();
  List<int> _filteredSurahNumbers = List.generate(114, (i) => i + 1);

  void _filterSurahs(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredSurahNumbers = List.generate(114, (i) => i + 1);
      });
      return;
    }

    final lowercaseQuery = query.toLowerCase();
    setState(() {
      _filteredSurahNumbers = List.generate(114, (i) => i + 1).where((s) {
        final englishName = quran.getSurahName(s).toLowerCase();
        final arabicName = quran.getSurahNameArabic(s);
        final surahNumberStr = s.toString();
        return englishName.contains(lowercaseQuery) ||
            arabicName.contains(lowercaseQuery) ||
            surahNumberStr == lowercaseQuery;
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double sheetHeight = MediaQuery.of(context).size.height * 0.75;

    return Container(
      height: sheetHeight + keyboardHeight,
      padding: EdgeInsets.only(bottom: keyboardHeight),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Select Surah',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSurahs,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search Surah...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                filled: true,
                fillColor: AppColors.card,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gold, width: 1.5),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Surah List
          Expanded(
            child: _filteredSurahNumbers.isEmpty
                ? const Center(
                    child: Text(
                      'No surahs found',
                      style: TextStyle(color: Colors.white38, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredSurahNumbers.length,
                    itemBuilder: (context, index) {
                      final surahNumber = _filteredSurahNumbers[index];
                      final englishName = quran.getSurahName(surahNumber);
                      final arabicName = quran.getSurahNameArabic(surahNumber);
                      final verseCount = quran.getVerseCount(surahNumber);
                      final place = quran.getPlaceOfRevelation(surahNumber);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: AppColors.card.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.04),
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.3),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$surahNumber',
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            englishName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Text(
                            '$place • $verseCount Verses',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                          trailing: Text(
                            arabicName,
                            style: GoogleFonts.amiri(
                              color: AppColors.gold,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Get.back();
                            widget.onSurahSelected(surahNumber);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
