import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mubin/app/controllers/stats_controller.dart';
import 'package:mubin/utils/colors.dart';
import '../data/models/stats_model.dart';

class StatsView extends GetView<StatsController> {
  const StatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'stats'.tr.toUpperCase(),
          style: const TextStyle(letterSpacing: 2, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: controller.loadStats,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.loadStats,
        color: AppColors.gold,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period Toggle
              Center(
                child: Obx(
                  () => Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildPeriodButton(
                          'weekly'.tr,
                          controller.period.value == 'Weekly',
                        ),
                        _buildPeriodButton(
                          'monthly'.tr,
                          controller.period.value == 'Monthly',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // User Summary Card
              _SectionHeader(title: "my_progress".tr),
              const SizedBox(height: 10),
              Obx(() {
                if (controller.isLoading.value)
                  return const _LoadingShimmer(height: 180);
                if (controller.user.value == null) return const SizedBox();
                return UserSummaryCard(user: controller.user.value!);
              }),

              const SizedBox(height: 30),

              // Stats Grid
              _SectionHeader(title: "overview".tr),
              const SizedBox(height: 10),
              Obx(() {
                if (controller.isLoading.value)
                  return const _LoadingShimmer(height: 200);
                if (controller.stats.value == null) return const SizedBox();
                return StatsGrid(stats: controller.stats.value!);
              }),

              const SizedBox(height: 30),

              // Leaderboard
              _SectionHeader(title: "leaderboard".tr),
              const SizedBox(height: 10),
              Obx(() {
                if (controller.isLoading.value)
                  return const _LoadingShimmer(height: 400);
                return LeaderboardList(items: controller.leaderboard);
              }),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: controller.togglePeriod,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 12,
        letterSpacing: 1.5,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class UserSummaryCard extends StatelessWidget {
  final UserModel user;
  const UserSummaryCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.gold.withOpacity(0.2), AppColors.surface],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.gold.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.gold.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 35,
                backgroundColor: AppColors.gold,
                child: CircleAvatar(
                  radius: 32,
                  backgroundImage: user.avatarUrl.isNotEmpty
                      ? AssetImage(user.avatarUrl) as ImageProvider
                      : null,
                  child: user.avatarUrl.isEmpty
                      ? const Icon(Icons.person, color: Colors.black, size: 30)
                      : null,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "rank".trParams({'rank': user.rank.toString()}),
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "total_points".tr,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                  Text(
                    "${user.totalPoints}",
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "next_level".tr,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  Text(
                    "${(user.nextLevelProgress * 100).toInt()}%",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: user.nextLevelProgress,
                  minHeight: 8,
                  backgroundColor: Colors.white10,
                  valueColor: const AlwaysStoppedAnimation(AppColors.gold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class StatsGrid extends StatelessWidget {
  final UserStats stats;
  const StatsGrid({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildStatItem(
          Icons.local_fire_department,
          "${stats.streak} ${'days_unit'.tr}",
          "current_streak".tr,
          Colors.orange,
        ),
        _buildStatItem(
          Icons.check_circle,
          "${stats.tasksCompleted}",
          "tasks_completed".tr,
          Colors.green,
        ),
        _buildStatItem(
          Icons.calendar_today,
          "${stats.daysActive}",
          "days_active".tr,
          Colors.blue,
        ),
        _buildStatItem(
          Icons.star,
          "${stats.totalPoints}",
          "total_points".tr,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class LeaderboardList extends StatelessWidget {
  final List<LeaderboardItem> items;
  const LeaderboardList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final item = items[index];
        final color = index == 0
            ? const Color(0xFFFFD700)
            : index == 1
            ? const Color(0xFFC0C0C0)
            : index == 2
            ? const Color(0xFFCD7F32)
            : Colors.white;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: item.isCurrentUser
                ? AppColors.gold.withOpacity(0.2)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: item.isCurrentUser
                ? Border.all(color: AppColors.gold.withOpacity(0.5))
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 30,
                child: Text(
                  "#${item.rank}",
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white10,
                child: const Icon(
                  Icons.person,
                  size: 20,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    color: item.isCurrentUser ? AppColors.gold : Colors.white,
                    fontWeight: item.isCurrentUser
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                "${item.points} ${'pts'.tr}",
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _LoadingShimmer extends StatelessWidget {
  final double height;
  const _LoadingShimmer({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.gold),
      ),
    );
  }
}
