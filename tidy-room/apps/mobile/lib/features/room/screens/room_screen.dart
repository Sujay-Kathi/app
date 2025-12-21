import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/room_provider.dart';
import '../../tasks/providers/task_provider.dart';
import '../../child/providers/child_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../widgets/virtual_room.dart';
import '../widgets/room_stats_card.dart';
import '../widgets/zone_progress_list.dart';

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> with SingleTickerProviderStateMixin {
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
      // Refresh child data first
      await childProvider.fetchChild(childId);
      // Load room data
      await context.read<RoomProvider>().fetchRoom(childId);
      // Load tasks
      await context.read<TaskProvider>().fetchTasks(childId);
      // Load profile
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
          child: Consumer3<ChildProvider, RoomProvider, ProfileProvider>(
            builder: (context, childProvider, roomProvider, profileProvider, _) {
              // Show loading state
              if (roomProvider.isLoading || profileProvider.isLoading) {
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

              // Show error state
              if (roomProvider.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: ${roomProvider.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      floating: true,
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                      title: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppTheme.primary, AppTheme.primaryDark],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.home_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${childProvider.name}'s Room",
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _getCleanlinessMessage(roomProvider.cleanlinessScore),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      actions: [
                        // Points Display
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.star_rounded, color: AppTheme.accent, size: 20),
                              const SizedBox(width: 4),
                              Text(
                                _formatPoints(childProvider.availablePoints),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.amber[800],
                                ),
                              ),
                            ],
                          ),
                        ).animate(onPlay: (c) => c.repeat()).shimmer(
                          duration: 3000.ms,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),

                    // Room Stats Card
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const RoomStatsCard().animate().fadeIn().slideY(begin: 0.2),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // Virtual Room Display
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: const VirtualRoom().animate().fadeIn(delay: 200.ms).scale(
                          begin: const Offset(0.95, 0.95),
                          end: const Offset(1, 1),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // Zone Progress Section
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Zone Progress',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: () => context.go('/tasks'),
                              child: const Text('See Tasks'),
                            ),
                          ],
                        ).animate().fadeIn(delay: 400.ms),
                      ),
                    ),

                    // Zone Progress List
                    SliverToBoxAdapter(
                      child: const ZoneProgressList().animate().fadeIn(delay: 500.ms),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // Pending Tasks Section
                    SliverToBoxAdapter(
                      child: Consumer<TaskProvider>(
                        builder: (context, taskProvider, _) {
                          final pendingTasks = taskProvider.pendingTasks;
                          
                          if (pendingTasks.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppTheme.error.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${pendingTasks.length}',
                                            style: const TextStyle(
                                              color: AppTheme.error,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Tasks To Do',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () => context.go('/tasks'),
                                      child: const Text('View All'),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                // Show first 3 pending tasks
                                ...pendingTasks.take(3).map((task) => 
                                  _buildTaskCard(task)).toList(),
                              ],
                            ),
                          ).animate().fadeIn(delay: 500.ms);
                        },
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 24)),

                    // Quick Actions
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildQuickAction(
                                    icon: Icons.checklist,
                                    label: 'My Tasks',
                                    color: AppTheme.secondary,
                                    onTap: () => context.go('/tasks'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildQuickAction(
                                    icon: Icons.store_rounded,
                                    label: 'Store',
                                    color: AppTheme.primary,
                                    onTap: () => context.go('/store'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildQuickAction(
                                    icon: Icons.emoji_events_rounded,
                                    label: 'Awards',
                                    color: AppTheme.accent,
                                    onTap: () => context.go('/achievements'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ).animate().fadeIn(delay: 600.ms),
                      ),
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

  String _getCleanlinessMessage(int score) {
    if (score >= 90) return 'Sparkling clean! ✨';
    if (score >= 70) return 'Looking good! 🌟';
    if (score >= 40) return 'Needs some tidying 🧹';
    if (score >= 20) return 'Getting messy! 😬';
    return 'Disaster zone! 🆘';
  }

  String _formatPoints(int points) {
    if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}k';
    }
    return points.toString();
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
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
      onTap: () {
        context.go('/tasks/${task['id']}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: zoneColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: zoneColor.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: zoneColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 12),
            // Task Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                        const SizedBox(width: 8),
                        const Icon(Icons.camera_alt, size: 14, color: Colors.grey),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Points
            Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: AppTheme.accent, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$points',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
