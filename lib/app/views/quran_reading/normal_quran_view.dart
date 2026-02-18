import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../utils/colors.dart';
import '../../controllers/large_quran_controller.dart';
import 'widgets/custom_quran_page_view.dart';
import 'widgets/verse_action_sheet.dart';

class NormalQuranView extends StatelessWidget {
  final int? initialPage;
  const NormalQuranView({super.key, this.initialPage});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is available
    Get.put(LargeQuranController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomQuranPageView(
          initialPage: initialPage ?? 1,
          showPageNumber: true,
          ayahMenuDarkBackgroundColor: AppColors.background,
          pageNumberDesign: PageNumberDesign.outlined,
          pageNumberBorderColor: Colors.transparent,
          pageNumberBackgroundColor: Colors.transparent,
          selectionSheetBackgroundColor: AppColors.background,
          onAyahTap: (surah, ayah, page) {
            Get.bottomSheet(
              VerseActionSheet(surahNumber: surah, verseNumber: ayah),
              isScrollControlled: true,
            );
          },
          // Customization to match App Theme (Dark/Gold)
          quranTextColor: Colors.white,
          topBarTextColor: AppColors.gold,
          searchSheetIconsColor: AppColors.secondary,
          searchFieldHintTextColor: Colors.grey,
          searchFieldTextColor: Colors.white,
          searchFieldHandleColor: AppColors.secondary,

          searchSheetBackgroundColor: AppColors.background,
          searchSheetDarkBackgroundColor: AppColors.background,

          searchFieldBackgroundColor: AppColors.card,
          searchFieldDarkBackgroundColor: AppColors.card,

          searchSheetHeightMultiplier: 0.6,
          pageNumberColor: AppColors.gold,
          searchResultGroupTitleColor: AppColors.gold,

          themeModeAdaption: false, // We force dark theme styles mostly
          // Ayah Menu Colors (if used, but we override with our bottom sheet)
          ayahMenuBackgroundColor: AppColors.card,
          ayahMenuTextColor: Colors.white,
          ayahMenuIconColor: AppColors.secondary,

          customAyahActions: [], // We use our own bottom sheet on tap
        ),
      ),
    );
  }
}
