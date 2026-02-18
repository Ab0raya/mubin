import 'package:get/get.dart';
import '../data/models/stats_model.dart';

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
    isLoading.value = true;

    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock User Data
    user.value = UserModel(
      name: "Ahmed",
      avatarUrl: "", // Use empty to trigger fallback Icon
      rank: 5,
      totalPoints: 1250,
      nextLevelProgress: 0.7,
    );

    // Mock Leaderboard Data
    leaderboard.value = [
      LeaderboardItem(rank: 1, name: "Yusuf", avatarUrl: "", points: 2000),
      LeaderboardItem(rank: 2, name: "Sarah", avatarUrl: "", points: 1950),
      LeaderboardItem(rank: 3, name: "Omar", avatarUrl: "", points: 1800),
      LeaderboardItem(rank: 4, name: "Layla", avatarUrl: "", points: 1500),
      LeaderboardItem(
        rank: 5,
        name: "Ahmed",
        avatarUrl: "",
        points: 1250,
        isCurrentUser: true,
      ),
      LeaderboardItem(rank: 6, name: "Fatima", avatarUrl: "", points: 1100),
      LeaderboardItem(rank: 7, name: "Ali", avatarUrl: "", points: 900),
      LeaderboardItem(rank: 8, name: "Zainab", avatarUrl: "", points: 850),
      LeaderboardItem(rank: 9, name: "Hassan", avatarUrl: "", points: 700),
      LeaderboardItem(rank: 10, name: "Maryam", avatarUrl: "", points: 650),
    ];

    // Mock Personal Stats
    stats.value = UserStats(
      totalPoints: 1250,
      streak: 7,
      tasksCompleted: 45,
      daysActive: 30,
    );

    isLoading.value = false;
  }

  void togglePeriod() {
    period.value = period.value == 'Weekly' ? 'Monthly' : 'Weekly';
    // Ideally, reload data based on period
    loadStats();
  }
}
