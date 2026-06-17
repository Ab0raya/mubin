import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:quran/quran.dart' as quran;
import '../../controllers/quran_audio_controller.dart';
import '../../../utils/colors.dart';
import '../../data/models/reciter.dart';
import 'quran_audio_player_view.dart';

class QuranAudioView extends StatefulWidget {
  const QuranAudioView({super.key});

  @override
  State<QuranAudioView> createState() => _QuranAudioViewState();
}

class _QuranAudioViewState extends State<QuranAudioView>
    with SingleTickerProviderStateMixin {
  final QuranAudioController controller = Get.put(QuranAudioController());
  final RxInt _activeTab = 0.obs; // 0: Quran, 1: Favorites, 2: Downloads
  final RxString _searchQuery = "".obs;
  final RxBool _isSearching = false.obs;
  final TextEditingController _searchController = TextEditingController();

  late AnimationController _visualizerController;

  @override
  void initState() {
    super.initState();
    _visualizerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _visualizerController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<int> _getFilteredSurahs() {
    final query = _searchQuery.value.toLowerCase().trim();
    final List<int> all = List.generate(114, (i) => i + 1);

    if (query.isEmpty) return all;

    return all.where((index) {
      final nameEn = quran.getSurahNameEnglish(index).toLowerCase();
      final nameAr = quran.getSurahNameArabic(index);
      return nameEn.contains(query) ||
          nameAr.contains(query) ||
          index.toString() == query;
    }).toList();
  }

  List<dynamic> _getFilteredFavorites() {
    final query = _searchQuery.value.toLowerCase().trim();
    final List<dynamic> favorites = controller.favoriteTracks;

    if (query.isEmpty) return favorites;

    return favorites.where((track) {
      final surahIndex = track.surahIndex;
      final nameEn = quran.getSurahNameEnglish(surahIndex).toLowerCase();
      final nameAr = quran.getSurahNameArabic(surahIndex);
      final reciterName = track.reciterName.toLowerCase();
      return nameEn.contains(query) ||
          nameAr.contains(query) ||
          reciterName.contains(query) ||
          surahIndex.toString() == query;
    }).toList();
  }

  List<int> _getFilteredDownloads() {
    final query = _searchQuery.value.toLowerCase().trim();
    final List<int> downloads = controller.downloadedSurahs;

    if (query.isEmpty) return downloads;

    return downloads.where((index) {
      final nameEn = quran.getSurahNameEnglish(index).toLowerCase();
      final nameAr = quran.getSurahNameArabic(index);
      return nameEn.contains(query) ||
          nameAr.contains(query) ||
          index.toString() == query;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background subtle gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF041913), Colors.black],
                stops: [0.0, 0.4],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // 1. Custom Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Obx(() {
                    if (_isSearching.value) {
                      return Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              style: const TextStyle(color: Colors.white),
                              onChanged: (val) => _searchQuery.value = val,
                              decoration: InputDecoration(
                                hintText: "search_surah_hint".tr,
                                hintStyle: const TextStyle(
                                  color: Colors.white54,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search,
                                  color: AppColors.secondary,
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.clear,
                                    color: Colors.white54,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchQuery.value = "";
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white.withOpacity(0.08),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 16,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              _isSearching.value = false;
                              _searchQuery.value = "";
                              _searchController.clear();
                            },
                          ),
                        ],
                      );
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.search,
                            color: Colors.white,
                            size: 26,
                          ),
                          onPressed: () => _isSearching.value = true,
                        ),
                        Column(
                          children: [
                            Text(
                              "audio_player_header".tr,
                              style: TextStyle(
                                color: AppColors.secondary.withOpacity(0.6),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "holy_quran".tr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.record_voice_over,
                            color: Colors.white,
                            size: 28,
                          ),
                          onPressed: () => _showReciterSelectionSheet(context),
                        ),
                      ],
                    );
                  }),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      await controller.checkDownloadedSurahs();
                    },
                    color: AppColors.secondary,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 16),

                              // 2. Active Reciter Card Banner
                              Obx(() {
                                final reciter = controller.currentReciter.value;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: GestureDetector(
                                    onTap: () =>
                                        _showReciterSelectionSheet(context),
                                    child: Container(
                                      height: 200,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(28),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.4,
                                            ),
                                            blurRadius: 15,
                                            offset: const Offset(0, 8),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(28),
                                        child: Stack(
                                          children: [
                                            // Reciter photo background
                                            Positioned.fill(
                                              child: Image.asset(
                                                reciter.imagePath,
                                                fit: BoxFit.cover,
                                                alignment: Alignment.topCenter,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) {
                                                      return Container(
                                                        color: AppColors.card,
                                                      );
                                                    },
                                              ),
                                            ),

                                            // Darker bottom/side gradient overlay
                                            Positioned.fill(
                                              child: DecoratedBox(
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: isArabic
                                                        ? Alignment.bottomRight
                                                        : Alignment.bottomLeft,
                                                    end: isArabic
                                                        ? Alignment.topLeft
                                                        : Alignment.topRight,
                                                    colors: [
                                                      Colors.black.withOpacity(
                                                        0.85,
                                                      ),
                                                      Colors.black.withOpacity(
                                                        0.3,
                                                      ),
                                                      Colors.transparent,
                                                    ],
                                                    stops: const [
                                                      0.0,
                                                      0.6,
                                                      1.0,
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),

                                            // Info Text
                                            Positioned(
                                              bottom: 24,
                                              left: isArabic ? null : 24,
                                              right: isArabic ? 24 : null,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    isArabic
                                                        ? reciter.arabicName
                                                        : reciter.name,
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        width: 6,
                                                        height: 6,
                                                        decoration:
                                                            const BoxDecoration(
                                                              color: AppColors
                                                                  .secondary,
                                                              shape: BoxShape
                                                                  .circle,
                                                            ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        "${reciter.narration} • ${isArabic ? '١١٤ سورة' : '114 Surahs'}",
                                                        style: TextStyle(
                                                          color: Colors.white
                                                              .withOpacity(0.6),
                                                          fontSize: 13,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // Floating Green Play button on card
                                            Positioned(
                                              bottom: 24,
                                              right: isArabic ? null : 24,
                                              left: isArabic ? 24 : null,
                                              child: GestureDetector(
                                                onTap: () {
                                                  controller
                                                          .playbackSource
                                                          .value =
                                                      AudioPlaybackSource.all;
                                                  controller.togglePlayPause();
                                                },
                                                child: Container(
                                                  width: 50,
                                                  height: 50,
                                                  decoration: BoxDecoration(
                                                    color: AppColors.secondary,
                                                    shape: BoxShape.circle,
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: AppColors
                                                            .secondary
                                                            .withOpacity(0.4),
                                                        blurRadius: 10,
                                                        offset: const Offset(
                                                          0,
                                                          4,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Center(
                                                    child: Obx(
                                                      () => Icon(
                                                        controller
                                                                .isPlaying
                                                                .value
                                                            ? Icons.pause
                                                            : Icons.play_arrow,
                                                        color: Colors.black,
                                                        size: 28,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),

                              const SizedBox(height: 24),

                              // 3. Tab bar Row (Quran, Favorites, Downloads)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Row(
                                    children: [
                                      _buildTabItem(0, "quran_tab".tr),
                                      _buildTabItem(1, "favorites".tr),
                                      _buildTabItem(2, "downloads_tab".tr),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(height: 24),

                              // 4. List Header ("السور الشائعة" / "Popular Surahs")
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'سور القران الكريم',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Obx(() {
                                      final downloadedCount =
                                          controller.downloadedSurahs.length;
                                      final isDownloading =
                                          controller.isDownloadingAll.value;

                                      if (downloadedCount == 114) {
                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.check_circle_rounded,
                                              color: AppColors.secondary,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              'all_downloaded'.tr,
                                              style: TextStyle(
                                                color: AppColors.secondary
                                                    .withOpacity(0.9),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        );
                                      } else if (isDownloading) {
                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const SizedBox(
                                              width: 12,
                                              height: 12,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppColors.secondary,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              isArabic
                                                  ? "${'downloading_progress'.tr} ($downloadedCount/١١٤)"
                                                  : "${'downloading_progress'.tr} ($downloadedCount/114)",
                                              style: TextStyle(
                                                color: AppColors.secondary
                                                    .withOpacity(0.9),
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            GestureDetector(
                                              onTap: () {
                                                controller
                                                        .isDownloadingAll
                                                        .value =
                                                    false;
                                              },
                                              child: const Icon(
                                                Icons.stop_circle_rounded,
                                                color: Colors.redAccent,
                                                size: 18,
                                              ),
                                            ),
                                          ],
                                        );
                                      } else {
                                        return TextButton.icon(
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.zero,
                                            minimumSize: Size.zero,
                                            tapTargetSize: MaterialTapTargetSize
                                                .shrinkWrap,
                                          ),
                                          onPressed: () =>
                                              controller.downloadAllSurahs(),
                                          icon: const Icon(
                                            Icons.download_for_offline_rounded,
                                            color: AppColors.secondary,
                                            size: 16,
                                          ),
                                          label: Text(
                                            'download_all'.tr,
                                            style: TextStyle(
                                              color: AppColors.secondary
                                                  .withOpacity(0.9),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        );
                                      }
                                    }),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 16),
                            ],
                          ),
                        ),
                        // 5. Scrollable sliver lists under tabs
                        Obx(() {
                          switch (_activeTab.value) {
                            case 1:
                              return _buildFavoritesSliverList(isArabic);
                            case 2:
                              return _buildDownloadsSliverList(isArabic);
                            case 0:
                            default:
                              return _buildQuranSliverList(isArabic);
                          }
                        }),
                        const SliverToBoxAdapter(child: SizedBox(height: 110)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 6. Persistent Bottom Mini Player
          Obx(() {
            final isIdle =
                controller.processingState.value == ProcessingState.idle;
            if (isIdle) return const SizedBox.shrink();

            return Positioned(
              bottom: 16,
              left: 12,
              right: 12,
              child: GestureDetector(
                onTap: () => Get.to(
                  () => const QuranAudioPlayerView(),
                  transition: Transition.downToUp,
                  duration: const Duration(milliseconds: 350),
                ),
                child: Container(
                  height: 72,
                  decoration: BoxDecoration(
                    color: const Color(0xFF151515).withOpacity(
                      0.95,
                    ), // Premium card dark glassmorphic appearance
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      children: [
                        // Progress line at bottom
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Obx(() {
                            final pos = controller.position.value.inMilliseconds
                                .toDouble();
                            final dur = controller.duration.value.inMilliseconds
                                .toDouble();
                            final progress = dur > 0 ? (pos / dur) : 0.0;
                            return LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white10,
                              color: AppColors.secondary,
                              minHeight: 3,
                            );
                          }),
                        ),

                        // Mini Player Controls & Details
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              // Reciter cover thumbnail
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  color: Colors.white12,
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: Image.asset(
                                          controller
                                              .currentReciter
                                              .value
                                              .imagePath,
                                          fit: BoxFit.cover,
                                        ),
                                      ),

                                      // Overlapping equalizer bars animation
                                      Positioned.fill(
                                        child: Container(
                                          color: Colors.black.withOpacity(0.35),
                                          child: Center(
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: List.generate(
                                                3,
                                                (i) => AnimatedBuilder(
                                                  animation:
                                                      _visualizerController,
                                                  builder: (context, child) {
                                                    double scale = 1.0;
                                                    if (controller
                                                        .isPlaying
                                                        .value) {
                                                      scale =
                                                          0.2 +
                                                          0.8 *
                                                              (math
                                                                  .sin(
                                                                    _visualizerController.value *
                                                                            2 *
                                                                            math.pi +
                                                                        (i *
                                                                            0.8),
                                                                  )
                                                                  .abs());
                                                    } else {
                                                      scale =
                                                          0.2 + (i % 2) * 0.2;
                                                    }
                                                    return Container(
                                                      margin:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 1,
                                                          ),
                                                      width: 2.2,
                                                      height: 16 * scale,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            AppColors.secondary,
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              1,
                                                            ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              // Title and Reciter
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      controller.currentSurahNameLocalized,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      controller.currentReciterNameLocalized,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Play / Pause Button
                              GestureDetector(
                                onTap: controller.togglePlayPause,
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: Center(
                                    child: controller.isLoading.value
                                        ? const SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                              color: AppColors.secondary,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Icon(
                                            controller.isPlaying.value
                                                ? Icons.pause_rounded
                                                : Icons.play_arrow_rounded,
                                            color: Colors.white,
                                            size: 22,
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              // Skip Next Button
                              GestureDetector(
                                onTap: () => controller.nextSurah(),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.08),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.skip_next_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          _activeTab.value = index;
          _searchQuery.value = "";
          _searchController.clear();
        },
        child: Obx(() {
          final isSelected = _activeTab.value == index;
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.secondary.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(
                      color: AppColors.secondary.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? AppColors.secondary : Colors.white60,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildQuranSliverList(bool isArabic) {
    final filtered = _getFilteredSurahs();

    if (filtered.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Text(
              "no_surahs_found".tr,
              style: const TextStyle(color: Colors.white30),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final surahIndex = filtered[index];
          return _buildSurahRowItem(surahIndex, isArabic);
        }, childCount: filtered.length),
      ),
    );
  }

  Widget _buildFavoritesSliverList(bool isArabic) {
    final filtered = _getFilteredFavorites();

    if (filtered.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Text(
              "no_favorites_saved".tr,
              style: const TextStyle(color: Colors.white30),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final track = filtered[index];
          final surahIndex = track.surahIndex;
          return _buildSurahRowItem(surahIndex, isArabic);
        }, childCount: filtered.length),
      ),
    );
  }

  Widget _buildDownloadsSliverList(bool isArabic) {
    final filtered = _getFilteredDownloads();

    if (filtered.isEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(36),
            child: Text(
              "no_downloads_yet".tr,
              style: const TextStyle(color: Colors.white30),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final surahIndex = filtered[index];
          return _buildSurahRowItem(surahIndex, isArabic);
        }, childCount: filtered.length),
      ),
    );
  }

  Widget _buildSurahRowItem(int surahIndex, bool isArabic) {
    return Obx(() {
      final isPlaying =
          controller.currentSurahIndex.value == surahIndex &&
          controller.playbackSource.value == AudioPlaybackSource.all &&
          controller.isPlaying.value;
      final isDownloaded = controller.isSurahDownloaded(surahIndex);
      final isDownloading = controller.downloadProgress.containsKey(surahIndex);
      final isFavorite = controller.isFavorite(surahIndex);

      final surahNameAr = quran.getSurahNameArabic(surahIndex);
      final surahNameEn = quran.getSurahNameEnglish(surahIndex);
      final versesCount = quran.getVerseCount(surahIndex);
      final revelationPlace = quran.getPlaceOfRevelation(surahIndex);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.card.withOpacity(0.6),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isPlaying
                ? AppColors.secondary.withOpacity(0.2)
                : Colors.white.withOpacity(0.03),
            width: 1.2,
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isPlaying
                  ? AppColors.secondary.withOpacity(0.1)
                  : Colors.white.withOpacity(0.04),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: isPlaying ? AppColors.secondary : Colors.white70,
              size: 24,
            ),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                surahNameAr,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              isArabic
                  ? "${revelationPlace == 'Madinah' ? 'madinah'.tr : 'makkah'.tr} • $versesCount آية"
                  : "${revelationPlace == 'Madinah' ? 'madinah'.tr : 'makkah'.tr} • $versesCount Verses",
              style: TextStyle(
                color: Colors.white.withOpacity(0.4),
                fontSize: 12,
              ),
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Favorite Toggle icon
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.white24,
                  size: 20,
                ),
                onPressed: () => controller.toggleFavorite(surahIndex),
              ),

              // Download Status Trailing
              if (isDownloading)
                SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    value: controller.downloadProgress[surahIndex],
                    strokeWidth: 2.5,
                    color: AppColors.secondary,
                  ),
                )
              else if (isDownloaded)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.secondary,
                  size: 20,
                )
              else
                IconButton(
                  icon: const Icon(
                    Icons.download_for_offline_rounded,
                    color: Colors.white24,
                    size: 20,
                  ),
                  onPressed: () => controller.downloadSurah(surahIndex),
                ),
            ],
          ),
          onTap: () {
            controller.playbackSource.value = AudioPlaybackSource.all;
            controller.playSurah(surahIndex);
          },
        ),
      );
    });
  }

  void _showReciterSelectionSheet(BuildContext context) {
    final isArabic = Get.locale?.languageCode == 'ar';
    Get.bottomSheet(
      Container(
        height: Get.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "select_reciter".tr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                itemCount: Reciter.reciters.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.white.withOpacity(0.05)),
                itemBuilder: (context, index) {
                  final reciter = Reciter.reciters[index];
                  return Obx(() {
                    final isSelected =
                        controller.currentReciter.value.name == reciter.name;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 40,
                          height: 40,
                          color: Colors.white12,
                          child: Image.asset(
                            reciter.imagePath,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      title: Text(
                        isArabic ? reciter.arabicName : reciter.name,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.secondary
                              : Colors.white,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        reciter.narration,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.secondary.withOpacity(0.6)
                              : Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.secondary,
                            )
                          : null,
                      onTap: () {
                        controller.changeReciter(reciter);
                        Get.back();
                      },
                    );
                  });
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
