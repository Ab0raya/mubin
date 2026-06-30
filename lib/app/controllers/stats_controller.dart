import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import '../data/models/stats_model.dart';
import '../services/backend_service.dart';

class StatsController extends GetxController {
  final isLoading = true.obs;
  final user = Rxn<UserModel>();
  final leaderboard = <LeaderboardItem>[].obs;
  final stats = Rxn<UserStats>();
  final period = 'Weekly'.obs; // 'Weekly' or 'Monthly'

  @override
  void onInit() {
    super.onInit();
    loadStats();
  }

  Future<void> loadStats() async {
    try {
      isLoading.value = true;
      final backendService = Get.find<BackendService>();
      final box = GetStorage();

      // 1. Fetch current user profile
      final meResponse = await backendService.getMe();
      final userData = meResponse.data;
      final String username = userData['username'] ?? 'User';
      final String userId = userData['id'] ?? '';
      final int points = userData['points'] ?? 0;
      final int streak = userData['current_streak'] ?? 0;

      // 2. Fetch leaderboard based on selected period
      final String periodParam = period.value == 'Weekly' ? 'week' : 'month';
      final lbResponse = await backendService.getLeaderboard(periodParam);
      final List lbData = lbResponse.data;

      final List<LeaderboardItem> items = [];
      for (int i = 0; i < lbData.length; i++) {
        final item = lbData[i];
        final name = item['username'] ?? 'User';
        final int lbPoints = item['points'] is int ? item['points'] : int.parse(item['points'].toString());
        final bool isCurrentUser = item['id'] == userId;

        items.add(
          LeaderboardItem(
            rank: i + 1,
            name: name,
            avatarUrl: '',
            points: lbPoints,
            isCurrentUser: isCurrentUser,
          ),
        );
      }
      leaderboard.value = items;

      // Find current user's rank on the leaderboard (fallback if not in top 10)
      int userRank = 11;
      final int currentIdx = items.indexWhere((it) => it.isCurrentUser);
      if (currentIdx != -1) {
        userRank = currentIdx + 1;
      }

      // 3. Update Observable Stats & User Models
      user.value = UserModel(
        name: username,
        avatarUrl: "",
        rank: userRank,
        totalPoints: points,
        nextLevelProgress: (points % 100) / 100.0,
      );

      final int tasks = box.read('tasks_completed') ?? 45;
      final int activeDays = box.read('days_active') ?? 30;

      stats.value = UserStats(
        totalPoints: points,
        streak: streak,
        tasksCompleted: tasks,
        daysActive: activeDays,
      );

    } catch (e) {
      debugPrint("Error loading stats from backend: $e");
      // Keep existing data or load local dummy values if API fails
    } finally {
      isLoading.value = false;
    }
  }

  void togglePeriod() {
    period.value = period.value == 'Weekly' ? 'Monthly' : 'Weekly';
    loadStats();
  }
}
