import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../utils/colors.dart';
import '../../controllers/large_quran_controller.dart';
import 'package:quran/quran.dart' as quran;
import 'normal_quran_view.dart';
import 'surah_detail_view.dart';

class LargeQuranView extends StatefulWidget {
  const LargeQuranView({super.key});

  @override
  State<LargeQuranView> createState() => _LargeQuranViewState();
}

class _LargeQuranViewState extends State<LargeQuranView> {
  final LargeQuranController controller = Get.put(LargeQuranController());
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter Surahs based on search query (English name, Arabic name, or Surah number)
    final filteredSurahs = List.generate(114, (i) => i + 1).where((surahNumber) {
      if (_searchQuery.isEmpty) return true;
      
      final englishName = controller.getSurahNameEnglish(surahNumber).toLowerCase();
      final arabicName = controller.getSurahName(surahNumber);
      final query = _searchQuery.toLowerCase();
      
      return englishName.contains(query) || 
             arabicName.contains(query) || 
             surahNumber.toString() == query;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('mode_large'.tr),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.gold,
      ),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'search_surah_hint'.tr,
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: AppColors.gold),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : const SizedBox.shrink(),
                filled: true,
                fillColor: AppColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.gold),
                ),
              ),
            ),
          ),

          // List Content
          Expanded(
            child: filteredSurahs.isEmpty
                ? Center(
                    child: Text(
                      'no_surahs_found'.tr,
                      style: const TextStyle(color: Colors.white54, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredSurahs.length,
                    itemBuilder: (context, index) {
                      int surahNumber = filteredSurahs[index];
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.secondary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.secondary.withOpacity(0.5),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '$surahNumber',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          controller.getSurahNameEnglish(surahNumber),
                          style: const TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        subtitle: Text(
                          'Verses: ${controller.getVerseCount(surahNumber)}',
                          style: TextStyle(color: Colors.white.withOpacity(0.6)),
                        ),
                        trailing: Text(
                          controller.getSurahName(surahNumber),
                          style: GoogleFonts.amiri(
                            color: AppColors.gold,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () {
                          controller.currentSurahNumber.value = surahNumber;
                          Get.to(() => SurahDetailView(surahNumber: surahNumber));
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
