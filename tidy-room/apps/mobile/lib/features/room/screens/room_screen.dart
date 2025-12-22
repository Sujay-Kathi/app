import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../child/providers/child_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../tasks/providers/task_provider.dart';
import '../providers/room_provider.dart';
import '../widgets/virtual_room.dart';
import '../widgets/zone_progress_list.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadData();
      _isInitialized = true;
    }
  }

  Future<void> _loadData() async {
    final childProvider = context.read<ChildProvider>();
    final childId = childProvider.childId;
    
    if (childId != null) {
      await childProvider.fetchChild(childId);
      await context.read<RoomProvider>().fetchRoom(childId);
      await context.read<TaskProvider>().fetchTasks(childId);
      await context.read<ProfileProvider>().fetchChildProfile(childId);
    }
  }

  Future<void> _refresh() async {
    final childProvider = context.read<ChildProvider>();
    final childId = childProvider.childId;
    if (childId != null) {
      await childProvider.fetchChild(childId);
      await context.read<RoomProvider>().fetchRoom(childId);
      await context.read<TaskProvider>().fetchTasks(childId);
      await context.read<ProfileProvider>().fetchChildProfile(childId);
    }
  }

  @override
  void dispose() {
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primary.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer4<ChildProvider, RoomProvider, TaskProvider, ProfileProvider>(
            builder: (context, childProvider, roomProvider, taskProvider, profileProvider, _) {
              final name = childProvider.name;
              final avatar = childProvider.avatarEmoji;
              final level = childProvider.level;
              final totalXp = childProvider.totalXp;
              final availablePoints = childProvider.availablePoints;
              final streak = profileProvider.currentStreak;
              final streakMultiplier = profileProvider.streakMultiplier;
              final cleanlinessScore = roomProvider.cleanlinessScore;
              final pendingTasks = taskProvider.pendingTasks;
              final achievements = profileProvider.achievements;

              if (childProvider.isLoading && childProvider.childData == null) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading your room...'),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header with greeting
                    SliverToBoxAdapter(
                      child: _buildHeader(
                        name: name,
                        avatar: avatar,
                        level: level,
                        totalXp: totalXp,
                        availablePoints: availablePoints,
                        streak: streak,
                        streakMultiplier: streakMultiplier,
                        levelProgress: profileProvider.levelProgress,
                      ),
                    ),

                    // Stats Cards Row
                    SliverToBoxAdapter(
                      child: _buildStatsCards(
                        cleanlinessScore: cleanlinessScore,
                        pendingTasksCount: pendingTasks.length,
                        achievementsCount: achievements.length,
                        streak: streak,
                      ),
                    ),

                    // Virtual Room Preview
                    SliverToBoxAdapter(
                      child: _buildRoomPreview(
                        roomProvider: roomProvider,
                        cleanlinessScore: cleanlinessScore,
                      ),
                    ),

                    // Pending Tasks Section
                    if (pendingTasks.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _buildPendingTasksSection(pendingTasks),
                      ),

                    // Zone Progress
                    SliverToBoxAdapter(
                      child: _buildZoneProgressSection(),
                    ),

                    // Quick Actions
                    SliverToBoxAdapter(
                      child: _buildQuickActionsSection(),
                    ),

                    // Recent Achievements
                    if (achievements.isNotEmpty)
                      SliverToBoxAdapter(
                        child: _buildAchievementsSection(achievements),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required String name,
    required String avatar,
    required int level,
    required int totalXp,
    required int availablePoints,
    required int streak,
    required double streakMultiplier,
    required double levelProgress,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Avatar, Name, Points
          Row(
            children: [
              // Avatar with level badge
              Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.secondary],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(avatar, style: const TextStyle(fontSize: 38)),
                    ),
                  ),
                  // Level badge
                  Positioned(
                    bottom: -2,
                    right: -2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Text(
                        'Lv.$level',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              // Name and greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getGreeting(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Points display
              GestureDetector(
                onTap: () => context.go('/store'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.accent,
                        AppTheme.accent.withOpacity(0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accent.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 20),
                      const SizedBox(width: 6),
                      Text(
                        _formatNumber(availablePoints),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ).animate().fadeIn().slideX(begin: -0.1),

          const SizedBox(height: 20),

          // Level Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Text(
                          'Level $level',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Text(
                      '${(levelProgress * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: levelProgress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                    minHeight: 10,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$totalXp XP',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    if (streak > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.orange, Colors.red.shade400],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              '$streak day streak!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (streakMultiplier > 1) ...[
                              const SizedBox(width: 4),
                              Text(
                                '${streakMultiplier}x',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
        ],
      ),
    );
  }

  Widget _buildStatsCards({
    required int cleanlinessScore,
    required int pendingTasksCount,
    required int achievementsCount,
    required int streak,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              emoji: '🏠',
              value: '$cleanlinessScore%',
              label: 'Room Score',
              color: _getScoreColor(cleanlinessScore),
              onTap: () {},
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              emoji: '📋',
              value: '$pendingTasksCount',
              label: 'Tasks',
              color: pendingTasksCount > 0 ? Colors.orange : AppTheme.success,
              onTap: () => context.go('/tasks'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              emoji: '🏆',
              value: '$achievementsCount',
              label: 'Badges',
              color: AppTheme.accent,
              onTap: () => context.go('/achievements'),
            ),
          ),
        ],
      ).animate().fadeIn(delay: 200.ms),
    );
  }

  Widget _buildStatCard({
    required String emoji,
    required String value,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomPreview({
    required RoomProvider roomProvider,
    required int cleanlinessScore,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'My Room',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getScoreColor(cleanlinessScore).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Text(
                      _getCleanlinessEmoji(cleanlinessScore),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getCleanlinessMessage(cleanlinessScore),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getScoreColor(cleanlinessScore),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: const VirtualRoom(),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildPendingTasksSection(List<Map<String, dynamic>> tasks) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        const Text('📋', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          '${tasks.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Tasks To Do',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => context.go('/tasks'),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tasks.take(3).map((task) => _buildTaskCard(task)).toList(),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildTaskCard(Map<String, dynamic> task) {
    final zone = task['zone'] ?? 'general';
    final zoneColor = AppTheme.getZoneColor(zone);
    final icon = task['icon'] ?? '✨';
    final title = task['title'] ?? 'Task';
    final points = task['points'] ?? 0;
    final difficulty = task['difficulty'] ?? 'medium';
    final requiresVerification = task['requires_verification'] ?? false;

    return GestureDetector(
      onTap: () => context.push('/tasks/${task['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: zoneColor.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: zoneColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [zoneColor.withOpacity(0.2), zoneColor.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.getDifficultyColor(difficulty).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          difficulty.toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getDifficultyColor(difficulty),
                          ),
                        ),
                      ),
                      if (requiresVerification) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.camera_alt, size: 10, color: Colors.blue),
                              SizedBox(width: 2),
                              Text(
                                'PHOTO',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.accent, AppTheme.accent.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '+$points',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoneProgressSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Room Zones',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const ZoneProgressList(),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildQuickActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.checklist_rounded,
                  label: 'My Tasks',
                  emoji: '📋',
                  gradient: [AppTheme.secondary, AppTheme.secondary.withOpacity(0.7)],
                  onTap: () => context.go('/tasks'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.store_rounded,
                  label: 'Store',
                  emoji: '🛒',
                  gradient: [AppTheme.primary, AppTheme.primary.withOpacity(0.7)],
                  onTap: () => context.go('/store'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickAction(
                  icon: Icons.emoji_events_rounded,
                  label: 'Awards',
                  emoji: '🏆',
                  gradient: [AppTheme.accent, AppTheme.accent.withOpacity(0.7)],
                  onTap: () => context.go('/achievements'),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms);
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required String emoji,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 28)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsSection(List<Map<String, dynamic>> achievements) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Badges',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => context.go('/achievements'),
                child: const Text('See All'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: achievements.take(5).length,
              itemBuilder: (context, index) {
                final achievement = achievements[index]['achievement'] ?? {};
                return Container(
                  width: 80,
                  margin: const EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.accent.withOpacity(0.2),
                              AppTheme.accent.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
                        ),
                        child: Center(
                          child: Text(
                            achievement['icon'] ?? '🏆',
                            style: const TextStyle(fontSize: 28),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        achievement['name'] ?? 'Badge',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  // Helper methods
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning! ☀️';
    if (hour < 17) return 'Good Afternoon! 🌤️';
    return 'Good Evening! 🌙';
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppTheme.success;
    if (score >= 60) return Colors.lime;
    if (score >= 40) return Colors.orange;
    return AppTheme.error;
  }

  String _getCleanlinessEmoji(int score) {
    if (score >= 90) return '✨';
    if (score >= 70) return '🌟';
    if (score >= 40) return '🧹';
    if (score >= 20) return '😬';
    return '💥';
  }

  String _getCleanlinessMessage(int score) {
    if (score >= 90) return 'Sparkling!';
    if (score >= 70) return 'Great!';
    if (score >= 40) return 'Needs Work';
    if (score >= 20) return 'Messy';
    return 'Disaster!';
  }
}
