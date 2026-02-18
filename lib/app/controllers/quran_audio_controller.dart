import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart'; // just_audio
import 'package:just_audio_background/just_audio_background.dart'; // just_audio_background
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:quran/quran.dart' as quran;
import 'package:get_storage/get_storage.dart';
import 'dart:math';

import 'package:uuid/uuid.dart';
import '../data/models/reciter.dart';
import '../data/models/favorite_track.dart';
import '../data/models/playlist.dart';

enum LoopState { off, all, one }

enum AudioPlaybackSource { all, favorites, downloaded, playlist }

class QuranAudioController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer(); // just_audio player
  final Dio _dio = Dio();

  // State
  var isPlaying = false.obs;
  var currentReciter = Reciter.reciters[7].obs; // Default to Mishary
  var currentSurahIndex = 1.obs; // 1-indexed (Al-Fatiha)
  var duration = Duration.zero.obs;
  var position = Duration.zero.obs;
  var isLoading = false.obs;

  // Download State
  // Map<surahIndex, progress (0.0 to 1.0)>
  // -1 means error or not started (handled by null check)
  var downloadProgress = <int, double>{}.obs;
  var downloadedSurahs = <int>[].obs; // Track downloaded for current reciter

  // Playback Modes
  var isShuffle = false.obs;
  var loopState = LoopState.off.obs;
  var playbackSource = AudioPlaybackSource.all.obs;

  // Playlists
  var playlists = <Playlist>[].obs;
  var currentPlaylist = Rx<Playlist?>(null);

  // Favorites (Legacy support + part of playlists now)
  final GetStorage _storage = GetStorage();
  var favoriteTracks =
      <FavoriteTrack>[].obs; // Kept for quick access/compatibility

  @override
  void onInit() {
    super.onInit();
    _loadPlaylists();
    _loadFavorites(); // Legacy/Quick favorites
    _checkDownloadedSurahs();
    _setupAudioListeners();
  }

  void _setupAudioListeners() {
    audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _onTrackFinished();
      }
    });

    audioPlayer.durationStream.listen((newDuration) {
      if (newDuration != null) {
        duration.value = newDuration;
      }
    });

    audioPlayer.positionStream.listen((newPosition) {
      position.value = newPosition;
    });
  }

  void _loadFavorites() {
    List<dynamic>? stored = _storage.read<List<dynamic>>('favorite_tracks');
    if (stored != null) {
      favoriteTracks.value = stored
          .map((e) => FavoriteTrack.fromJson(e as Map<String, dynamic>))
          .toList();
    }
  }

  void toggleFavorite(int surahIndex) {
    final track = FavoriteTrack(
      reciterName: currentReciter.value.name,
      reciterUrl: currentReciter.value.serverUrl,
      surahIndex: surahIndex,
    );

    // Check if exists (custom equality in FavoriteTrack handles this)
    if (favoriteTracks.contains(track)) {
      favoriteTracks.remove(track);
    } else {
      favoriteTracks.add(track);
    }

    _saveFavorites();
  }

  void removeFavoriteTrack(FavoriteTrack track) {
    favoriteTracks.remove(track);
    _saveFavorites();
  }

  void reorderFavorites(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final track = favoriteTracks.removeAt(oldIndex);
    favoriteTracks.insert(newIndex, track);
    _saveFavorites();
  }

  void _saveFavorites() {
    _storage.write(
      'favorite_tracks',
      favoriteTracks.map((e) => e.toJson()).toList(),
    );
    // Also sync to "Favorites" playlist if it exists
    final favPlaylistIndex = playlists.indexWhere(
      (p) => p.isDefault && p.name == 'Favorites',
    );
    if (favPlaylistIndex != -1) {
      playlists[favPlaylistIndex].tracks.clear();
      playlists[favPlaylistIndex].tracks.addAll(favoriteTracks);
      _savePlaylists();
    }
  }

  // --- Playlist Logic ---

  void _loadPlaylists() {
    List<dynamic>? stored = _storage.read<List<dynamic>>('playlists');
    if (stored != null) {
      playlists.value = stored
          .map((e) => Playlist.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    // Ensure default "Favorites" playlist exists
    if (!playlists.any((p) => p.isDefault && p.name == 'Favorites')) {
      playlists.add(
        Playlist(
          id: const Uuid().v4(),
          name: 'Favorites',
          isDefault: true,
          tracks: [],
        ),
      );
    }
    playlists.refresh();
  }

  void _savePlaylists() {
    _storage.write('playlists', playlists.map((e) => e.toJson()).toList());
    playlists.refresh();
  }

  void createPlaylist(String name) {
    playlists.add(
      Playlist(id: const Uuid().v4(), name: name, isDefault: false),
    );
    _savePlaylists();
  }

  void deletePlaylist(String id) {
    playlists.removeWhere((p) => p.id == id && !p.isDefault);
    if (currentPlaylist.value?.id == id) {
      currentPlaylist.value = null; // Reset if current deleted
    }
    _savePlaylists();
  }

  void addToPlaylist(Playlist playlist, FavoriteTrack track) {
    if (!playlist.tracks.contains(track)) {
      playlist.tracks.add(track);
      _savePlaylists();

      // Sync legacy favorites if it's the default playlist
      if (playlist.isDefault && playlist.name == 'Favorites') {
        if (!favoriteTracks.contains(track)) {
          favoriteTracks.add(track);
          _storage.write(
            'favorite_tracks',
            favoriteTracks.map((e) => e.toJson()).toList(),
          );
        }
      }
    }
  }

  void removeFromPlaylist(Playlist playlist, FavoriteTrack track) {
    playlist.tracks.remove(track);
    _savePlaylists();

    // Sync legacy favorites
    if (playlist.isDefault && playlist.name == 'Favorites') {
      favoriteTracks.remove(track);
      _storage.write(
        'favorite_tracks',
        favoriteTracks.map((e) => e.toJson()).toList(),
      );
    }
  }

  void selectPlaylist(Playlist? playlist) {
    currentPlaylist.value = playlist;
  }

  bool isFavorite(int surahIndex) {
    // Check if current reciter + surah is in favorites
    final track = FavoriteTrack(
      reciterName: currentReciter.value.name,
      reciterUrl: currentReciter.value.serverUrl,
      surahIndex: surahIndex,
    );
    return favoriteTracks.contains(track);
  }

  void _onTrackFinished() {
    if (loopState.value == LoopState.one) {
      // Repeat current
      playSurah(currentSurahIndex.value);
    } else {
      nextSurah(autoPlay: true);
    }
  }

  // --- Download Logic ---

  Future<void> _checkDownloadedSurahs() async {
    downloadedSurahs.clear();
    final dir = await getApplicationDocumentsDirectory();
    final reciterDir = Directory("${dir.path}/${currentReciter.value.name}");

    if (await reciterDir.exists()) {
      for (int i = 1; i <= 114; i++) {
        final formattedIndex = i.toString().padLeft(3, '0');
        final file = File("${reciterDir.path}/$formattedIndex.mp3");
        if (await file.exists()) {
          downloadedSurahs.add(i);
        }
      }
    }
  }

  bool isSurahDownloaded(int surahIndex) {
    return downloadedSurahs.contains(surahIndex);
  }

  Future<String> _getLocalFilePath(int surahIndex) async {
    final dir = await getApplicationDocumentsDirectory();
    final formattedIndex = surahIndex.toString().padLeft(3, '0');
    return "${dir.path}/${currentReciter.value.name}/$formattedIndex.mp3";
  }

  Future<void> downloadSurah(int surahIndex) async {
    if (downloadProgress.containsKey(surahIndex)) return; // Already downloading

    try {
      downloadProgress[surahIndex] = 0.0;

      final dir = await getApplicationDocumentsDirectory();
      final reciterPath = "${dir.path}/${currentReciter.value.name}";
      await Directory(reciterPath).create(recursive: true);

      final formattedIndex = surahIndex.toString().padLeft(3, '0');
      final savePath = "$reciterPath/$formattedIndex.mp3";
      final url = _getSurahUrl(surahIndex);

      final surahName = quran.getSurahNameEnglish(surahIndex);

      // Notification ID: strict unique ID logic (e.g. surahIndex + hash of reciter)
      // For simplicity using surahIndex (assuming one download at a time mostly or unique enough)
      final notificationId = surahIndex;

      await _dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            downloadProgress[surahIndex] = progress;

            // Create notification (throttle this if needed)
            if ((progress * 100).toInt() % 10 == 0) {
              AwesomeNotifications().createNotification(
                content: NotificationContent(
                  id: notificationId,
                  channelKey: 'download_channel',
                  title: 'Downloading $surahName',
                  body: '${(progress * 100).toInt()}%',
                  notificationLayout: NotificationLayout.ProgressBar,
                  progress: (progress * 100),
                  locked: true,
                ),
              );
            }
          }
        },
      );

      downloadProgress.remove(surahIndex);
      downloadedSurahs.add(surahIndex);

      // Completion Notification
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: 'download_channel',
          title: 'Download Complete',
          body: '$surahName downloaded successfully',
          notificationLayout: NotificationLayout.Default,
          locked: false,
        ),
      );
    } catch (e) {
      downloadProgress.remove(surahIndex);
      Get.snackbar("Download Failed", "Error downloading Surah: $e");
    }
  }

  void cancelDownload(int surahIndex) {
    // Implementing cancellation requires CancelToken with Dio.
    // For MVP complexity, we might skip rigorous cancellation or revisit.
    // Assuming simple download for now.
    // But could remove from progress map to stop UI.
    downloadProgress.remove(surahIndex);
  }

  // --- Playback Logic Update ---

  Future<void> playSurah(int surahIndex) async {
    currentSurahIndex.value = surahIndex;

    // Check local first
    String playUrl;
    final localPath = await _getLocalFilePath(surahIndex);
    final isDownloaded = await File(localPath).exists();

    if (isDownloaded) {
      playUrl = localPath;
    } else {
      // Not downloaded, check internet
      if (!await _hasInternetConnection()) {
        Get.snackbar(
          "No Internet Connection",
          "Please connect to the internet to listen to this Surah.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.redAccent,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
        return;
      }
      playUrl = _getSurahUrl(surahIndex);
    }

    try {
      isLoading.value = true;

      Uri audioUri;
      if (isDownloaded) {
        audioUri = Uri.file(localPath);
      } else {
        audioUri = Uri.parse(playUrl);
      }

      await audioPlayer.setAudioSource(
        AudioSource.uri(
          audioUri,
          tag: MediaItem(
            id: surahIndex.toString(),
            album: "Holy Quran",
            title: quran.getSurahName(surahIndex), // Arabic Surah Name
            artist: currentReciter.value.arabicName, // Arabic Reciter Name
            artUri: Uri.parse('asset:///assets/images/quran_cover.png'),
          ),
        ),
      );

      await audioPlayer.play();
      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar("Error", "Failed to play audio: $e");
    }
  }

  Future<bool> _hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  String _getSurahUrl(int index) {
    // Format index to 3 digits (e.g., 001, 012, 114)
    String formattedIndex = index.toString().padLeft(3, '0');
    return "${currentReciter.value.serverUrl}$formattedIndex.mp3";
  }

  void togglePlayPause() {
    if (isPlaying.value) {
      audioPlayer.pause();
    } else {
      if (audioPlayer.processingState == ProcessingState.idle) {
        playSurah(currentSurahIndex.value);
      } else {
        audioPlayer.play();
      }
    }
  }

  void toggleShuffle() {
    isShuffle.value = !isShuffle.value;
    if (isShuffle.value) {
      audioPlayer.setShuffleModeEnabled(true);
      // If Repeat One is active, switch to Repeat All (compatible with shuffle)
      if (loopState.value == LoopState.one) {
        loopState.value = LoopState.all;
        audioPlayer.setLoopMode(LoopMode.off);
      }
    } else {
      audioPlayer.setShuffleModeEnabled(false);
    }
  }

  void toggleLoop() {
    switch (loopState.value) {
      case LoopState.off:
        loopState.value = LoopState.all;
        // Keep just_audio loop mode OFF for manual playlist handling
        audioPlayer.setLoopMode(LoopMode.off);
        break;
      case LoopState.all:
        loopState.value = LoopState.one;
        audioPlayer.setLoopMode(LoopMode.one);
        // Disable shuffle when entering Repeat One
        if (isShuffle.value) {
          isShuffle.value = false;
          audioPlayer.setShuffleModeEnabled(false);
        }
        break;
      case LoopState.one:
        loopState.value = LoopState.off;
        audioPlayer.setLoopMode(LoopMode.off);
        break;
    }
  }

  void nextSurah({bool autoPlay = false}) {
    // Helper to get next index with loop/shuffle logic
    void playNextInList(
      List<dynamic> list,
      dynamic currentItem,
      Function(dynamic) playFunc,
    ) {
      if (isShuffle.value) {
        final random = Random();
        final randomItem = list[random.nextInt(list.length)];
        playFunc(randomItem);
      } else {
        final currentIndex = list.indexOf(currentItem);
        if (currentIndex != -1 && currentIndex < list.length - 1) {
          playFunc(list[currentIndex + 1]);
        } else if (loopState.value == LoopState.all && autoPlay) {
          playFunc(list.first);
        } else if (currentIndex == -1 && list.isNotEmpty) {
          playFunc(list.first);
        }
      }
    }

    switch (playbackSource.value) {
      case AudioPlaybackSource.favorites:
        if (favoriteTracks.isNotEmpty) {
          final currentTrack = FavoriteTrack(
            reciterName: currentReciter.value.name,
            reciterUrl: currentReciter.value.serverUrl,
            surahIndex: currentSurahIndex.value,
          );
          playNextInList(
            favoriteTracks,
            currentTrack,
            (item) => playFavoriteTrack(item as FavoriteTrack),
          );
        }
        break;
      case AudioPlaybackSource.downloaded:
        if (downloadedSurahs.isNotEmpty) {
          // Sort downloaded surahs to ensure logical order
          downloadedSurahs.sort();
          playNextInList(
            downloadedSurahs,
            currentSurahIndex.value,
            (item) => playSurah(item as int),
          );
        }
        break;
      case AudioPlaybackSource.playlist:
        if (currentPlaylist.value != null &&
            currentPlaylist.value!.tracks.isNotEmpty) {
          final currentTrack = FavoriteTrack(
            reciterName: currentReciter.value.name,
            reciterUrl: currentReciter.value.serverUrl,
            surahIndex: currentSurahIndex.value,
          );
          playNextInList(
            currentPlaylist.value!.tracks,
            currentTrack,
            (item) => playFavoriteTrack(item as FavoriteTrack),
          );
        }
        break;
      case AudioPlaybackSource.all:
      default:
        if (isShuffle.value) {
          final random = Random();
          final nextIndex = random.nextInt(114) + 1;
          playSurah(nextIndex);
        } else {
          if (currentSurahIndex.value < 114) {
            playSurah(currentSurahIndex.value + 1);
          } else if (loopState.value == LoopState.all && autoPlay) {
            playSurah(1);
          }
        }
        break;
    }
  }

  void playFavoriteTrack(FavoriteTrack track) {
    // Ensure source is favorites if not playlist
    if (playbackSource.value != AudioPlaybackSource.playlist) {
      playbackSource.value = AudioPlaybackSource.favorites;
    }

    // Find reciter object
    final reciter = Reciter.reciters.firstWhere(
      (r) => r.name == track.reciterName,
      orElse: () => currentReciter.value, // Fallback
    );

    if (currentReciter.value.name != reciter.name) {
      currentReciter.value = reciter;
      // When reciter changes, we should update downloadedSurahs for the new reciter
      _checkDownloadedSurahs();
    }
    playSurah(track.surahIndex);
  }

  void prevSurah() {
    if (position.value.inSeconds > 5) {
      audioPlayer.seek(Duration.zero);
      return;
    }

    void playPrevInList(
      List<dynamic> list,
      dynamic currentItem,
      Function(dynamic) playFunc,
    ) {
      final currentIndex = list.indexOf(currentItem);
      if (currentIndex > 0) {
        playFunc(list[currentIndex - 1]);
      } else if (loopState.value == LoopState.all) {
        playFunc(list.last);
      } else if (currentIndex == -1 && list.isNotEmpty) {
        playFunc(list.last);
      }
    }

    switch (playbackSource.value) {
      case AudioPlaybackSource.favorites:
        if (favoriteTracks.isNotEmpty) {
          final currentTrack = FavoriteTrack(
            reciterName: currentReciter.value.name,
            reciterUrl: currentReciter.value.serverUrl,
            surahIndex: currentSurahIndex.value,
          );
          playPrevInList(
            favoriteTracks,
            currentTrack,
            (item) => playFavoriteTrack(item as FavoriteTrack),
          );
        }
        break;
      case AudioPlaybackSource.downloaded:
        if (downloadedSurahs.isNotEmpty) {
          downloadedSurahs.sort();
          playPrevInList(
            downloadedSurahs,
            currentSurahIndex.value,
            (item) => playSurah(item as int),
          );
        }
        break;
      case AudioPlaybackSource.playlist:
        if (currentPlaylist.value != null &&
            currentPlaylist.value!.tracks.isNotEmpty) {
          final currentTrack = FavoriteTrack(
            reciterName: currentReciter.value.name,
            reciterUrl: currentReciter.value.serverUrl,
            surahIndex: currentSurahIndex.value,
          );
          playPrevInList(
            currentPlaylist.value!.tracks,
            currentTrack,
            (item) => playFavoriteTrack(item as FavoriteTrack),
          );
        }
        break;
      case AudioPlaybackSource.all:
      default:
        if (currentSurahIndex.value > 1) {
          playSurah(currentSurahIndex.value - 1);
        } else if (loopState.value == LoopState.all) {
          playSurah(114);
        }
        break;
    }
  }

  void seek(Duration pos) {
    audioPlayer.seek(pos);
  }

  void changeReciter(Reciter reciter) {
    if (currentReciter.value != reciter) {
      currentReciter.value = reciter;
      _checkDownloadedSurahs(); // Check downloads for new reciter
      // Restart current surah with new reciter
      playSurah(currentSurahIndex.value);
    }
  }

  String get currentSurahName => quran.getSurahName(currentSurahIndex.value);
  String get currentSurahEnglishName =>
      quran.getSurahNameEnglish(currentSurahIndex.value);

  String get currentSurahNameLocalized {
    if (Get.locale?.languageCode == 'ar') {
      return quran.getSurahNameArabic(currentSurahIndex.value);
    }
    return "Surah ${quran.getSurahName(currentSurahIndex.value)}";
  }

  String get currentReciterNameLocalized {
    if (Get.locale?.languageCode == 'ar') {
      return currentReciter.value.arabicName;
    }
    return currentReciter.value.name;
  }

  void playDownloadedTrack(int surahIndex) {
    if (isSurahDownloaded(surahIndex)) {
      playbackSource.value = AudioPlaybackSource.downloaded;
      playSurah(surahIndex);
    } else {
      Get.snackbar("Error", "Surah not downloaded");
    }
  }

  // --- Media Notification Logic ---

  // Manual media notification methods removed as just_audio_background handles it.

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
