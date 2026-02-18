import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:quran/quran.dart' as quran;
import '../../../utils/colors.dart';
import '../../controllers/tafseer_controller.dart';
import '../../data/models/tafseer_model.dart';

class TafseerView extends StatelessWidget {
  const TafseerView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is initialized
    final controller = Get.put(TafseerController());

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Tafseer Search'),
          backgroundColor: AppColors.background,
          foregroundColor: AppColors.gold,
          bottom: const TabBar(
            indicatorColor: AppColors.gold,
            labelColor: AppColors.gold,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(icon: Icon(Icons.search), text: 'Text Search'),
              Tab(icon: Icon(Icons.location_on), text: 'Verse Selection'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Text Search
            _buildTextSearchTab(controller),
            // Tab 2: Location Search
            _buildLocationSearchTab(context, controller),
          ],
        ),
      ),
    );
  }

  // --- Tab 1: Text Search ---

  Widget _buildTextSearchTab(TafseerController controller) {
    return Column(
      children: [
        _buildSearchBar(controller),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }

            // Only show empty state if we are in text search mode (checking if query is set)
            // But since results are shared, we just check results.
            if (controller.searchResults.isEmpty) {
              return _buildEmptyState('Enter text to search tafseer');
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.searchResults.length,
              itemBuilder: (context, index) {
                final TafseerModel item = controller.searchResults[index];
                return _buildResultItem(context, item, controller);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSearchBar(TafseerController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller:
            controller.searchController, // Using same controller for now
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search for words (e.g., Paradise, Patience)...',
          hintStyle: const TextStyle(color: Colors.white54),
          prefixIcon: const Icon(Icons.search, color: AppColors.gold),
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear, color: Colors.white54),
            onPressed: () {
              controller.searchController.clear();
              controller.search('');
            },
          ),
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
    );
  }

  // --- Tab 2: Location Search ---

  Widget _buildLocationSearchTab(
    BuildContext context,
    TafseerController controller,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Surah Dropdown
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: controller.selectedSurah.value,
                      dropdownColor: AppColors.card,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: AppColors.gold,
                      ),
                      isExpanded: true,
                      items: List.generate(114, (index) {
                        int surahNum = index + 1;
                        return DropdownMenuItem(
                          value: surahNum,
                          child: Text(
                            '$surahNum. ${quran.getSurahName(surahNum)} - ${quran.getSurahNameArabic(surahNum)}',
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }),
                      onChanged: (val) {
                        if (val != null) {
                          controller.selectedSurah.value = val;
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Verse Number Input
              TextField(
                controller: controller.verseController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Verse Number',
                  labelStyle: const TextStyle(color: Colors.white54),
                  hintText: 'Enter Verse No.',
                  hintStyle: const TextStyle(color: Colors.white24),
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
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  controller.searchByLocation();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Search',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        // Results Area (Shared list but usually 1 result here)
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              );
            }

            if (controller.searchResults.isEmpty) {
              // Different empty state for this tab potentially, or just generic
              return const SizedBox.shrink();
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: controller.searchResults.length,
              itemBuilder: (context, index) {
                final TafseerModel item = controller.searchResults[index];
                return _buildResultItem(context, item, controller);
              },
            );
          }),
        ),
      ],
    );
  }

  // --- Common Components ---

  Widget _buildResultItem(
    BuildContext context,
    TafseerModel item,
    TafseerController controller,
  ) {
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gold.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () => _showFullTafseer(context, item, controller),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.gold.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      '${controller.getSurahName(item.number)} : ${item.aya}',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                item.text,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(
                  color: Colors.white,
                  fontSize: 18,
                  height: 1.8,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search, size: 60, color: Colors.white24),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showFullTafseer(
    BuildContext context,
    TafseerModel item,
    TafseerController controller,
  ) {
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.7,
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${controller.getSurahName(item.number)} : ${item.aya}',
                  style: const TextStyle(
                    color: AppColors.gold,
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
            const Divider(color: Colors.white12),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  item.text,
                  textAlign: TextAlign.justify,
                  textDirection: TextDirection.rtl,
                  style: GoogleFonts.amiri(
                    color: Colors.white,
                    fontSize: 22,
                    height: 2.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
