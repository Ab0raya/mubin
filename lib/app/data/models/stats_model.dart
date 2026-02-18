class UserModel {
  final String name;
  final String avatarUrl;
  final int rank;
  final int totalPoints;
  final double nextLevelProgress; // 0.0 to 1.0

  UserModel({
    required this.name,
    required this.avatarUrl,
    required this.rank,
    required this.totalPoints,
    required this.nextLevelProgress,
  });
}

class LeaderboardItem {
  final int rank;
  final String name;
  final String avatarUrl;
  final int points;
  final bool isCurrentUser;

  LeaderboardItem({
    required this.rank,
    required this.name,
    required this.avatarUrl,
    required this.points,
    this.isCurrentUser = false,
  });
}

class UserStats {
  final int totalPoints;
  final int streak;
  final int tasksCompleted;
  final int daysActive;

  UserStats({
    required this.totalPoints,
    required this.streak,
    required this.tasksCompleted,
    required this.daysActive,
  });
}
