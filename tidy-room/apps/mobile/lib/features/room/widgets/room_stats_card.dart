import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../child/providers/child_provider.dart';
import '../../profile/providers/profile_provider.dart';
import '../../tasks/providers/task_provider.dart';

class RoomStatsCard extends StatelessWidget {
  const RoomStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<ChildProvider, ProfileProvider, TaskProvider>(
      builder: (context, childProvider, profileProvider, taskProvider, _) {
        final name = childProvider.name;
        final avatar = childProvider.avatarEmoji;
        final level = childProvider.level;
        final totalPoints = childProvider.totalPoints;
        final streak = profileProvider.currentStreak;
        final achievementCount = profileProvider.achievements.length;
        final totalXp = childProvider.totalXp;
        final levelProgress = profileProvider.levelProgress;
        
        // Calculate today's tasks
        final pendingTasks = taskProvider.pendingCount;
        final completedTasks = taskProvider.completedCount;
        final totalTasks = pendingTasks + completedTasks;

        // Calculate XP needed for next level
        final nextLevelXp = profileProvider.nextLevel?['xp_required'] ?? (level + 1) * 500;
        final currentLevelXp = profileProvider.currentLevel?['xp_required'] ?? level * 500;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF7C3AED),
                Color(0xFF8B5CF6),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              // Top Row - Child Info
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: Text(avatar, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $name! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Level $level - ${_getLevelTitle(level)}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Streak Badge
                  if (streak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            '$streak',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Progress Bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Level Progress',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${_formatNumber(totalXp)} / ${_formatNumber(nextLevelXp)} XP',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: levelProgress.clamp(0.0, 1.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.yellow, Colors.orange],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Stats Row
              Row(
                children: [
                  _buildStatItem(
                    icon: Icons.check_circle_outline,
                    value: '$completedTasks/$totalTasks',
                    label: 'Today\'s Tasks',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  _buildStatItem(
                    icon: Icons.star_outline,
                    value: _formatNumber(totalPoints),
                    label: 'Points',
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  _buildStatItem(
                    icon: Icons.emoji_events_outlined,
                    value: '$achievementCount',
                    label: 'Badges',
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _getLevelTitle(int level) {
    if (level >= 50) return 'Legendary Cleaner';
    if (level >= 30) return 'Expert Cleaner';
    if (level >= 20) return 'Pro Cleaner';
    if (level >= 10) return 'Master Tidier';
    if (level >= 5) return 'Junior Tidier';
    return 'Newbie Cleaner';
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
