import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../child/providers/child_provider.dart';
import '../providers/profile_provider.dart';
import '../../tasks/providers/task_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadProfile();
      _isInitialized = true;
    }
  }

  Future<void> _loadProfile() async {
    final childId = context.read<ChildProvider>().childId;
    if (childId != null) {
      await context.read<ProfileProvider>().fetchChildProfile(childId);
      await context.read<ProfileProvider>().fetchPointsHistory(childId);
    }
  }

  void _logout() {
    context.read<ChildProvider>().clear();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer3<ChildProvider, ProfileProvider, TaskProvider>(
          builder: (context, childProvider, profileProvider, taskProvider, _) {
            final name = childProvider.name;
            final avatar = childProvider.avatarEmoji;
            final level = childProvider.level;
            final totalPoints = childProvider.totalPoints;
            final streak = profileProvider.currentStreak;
            final achievements = profileProvider.achievements;
            final completedTasks = taskProvider.completedCount;

            if (profileProvider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Profile Header
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        // Avatar
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(avatar, style: const TextStyle(fontSize: 50)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Level $level - ${_getLevelTitle(level)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Level Progress Bar
                        Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'XP: ${childProvider.totalXp}',
                                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                                Text(
                                  '${profileProvider.xpToNextLevel} to Level ${level + 1}',
                                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: profileProvider.levelProgress,
                                backgroundColor: Colors.white.withOpacity(0.2),
                                valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                                minHeight: 8,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Stats Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatColumn('🔥', '$streak', 'Streak'),
                            _buildStatColumn('⭐', _formatNumber(totalPoints), 'Points'),
                            _buildStatColumn('🏆', '${achievements.length}', 'Badges'),
                            _buildStatColumn('✅', '$completedTasks', 'Tasks'),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2),

                  const SizedBox(height: 16),

                  // Streak Multiplier Card
                  if (streak > 0)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.withOpacity(0.2),
                            Colors.red.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 40)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '$streak Day${streak > 1 ? 's' : ''} Streak!',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.orange,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${((profileProvider.streakMultiplier - 1) * 100).toInt()}% Bonus',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profileProvider.streakMultiplier > 1 
                                      ? 'You\'re earning ${profileProvider.streakMultiplier}x points!'
                                      : 'Keep it up to earn bonus points!',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),

                  const SizedBox(height: 24),

                  // Achievements Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.go('/achievements'),
                        child: const Text('See All'),
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms),

                  if (achievements.isEmpty)
                    Container(
                      height: 100,
                      alignment: Alignment.center,
                      child: Text(
                        'No achievements yet. Keep cleaning! 🧹',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    )
                  else
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: achievements.length,
                        itemBuilder: (context, index) {
                          final achievement = achievements[index]['achievement'] ?? {};
                          return _buildAchievementBadge(
                            achievement['icon'] ?? '🏆',
                            achievement['name'] ?? 'Achievement',
                            true,
                          );
                        },
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 24),

                  // Menu Items
                  _buildMenuItem(
                    icon: Icons.history,
                    title: 'Points History',
                    subtitle: 'View your earning history',
                    onTap: () {
                      _showPointsHistory(context, profileProvider.pointsHistory);
                    },
                  ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

                  _buildMenuItem(
                    icon: Icons.color_lens,
                    title: 'Change Avatar',
                    subtitle: 'Pick a new emoji avatar',
                    onTap: () {
                      _showAvatarPicker(context, childProvider);
                    },
                  ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.1),

                  _buildMenuItem(
                    icon: Icons.pin,
                    title: 'Change PIN',
                    subtitle: 'Update your secret PIN',
                    onTap: () {
                      _showChangePinDialog(context, profileProvider);
                    },
                  ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1),

                  _buildMenuItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'App preferences',
                    onTap: () {},
                  ).animate().fadeIn(delay: 550.ms).slideX(begin: 0.1),

                  _buildMenuItem(
                    icon: Icons.logout,
                    title: 'Log Out',
                    subtitle: 'Sign out from your account',
                    onTap: _logout,
                    isDestructive: true,
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),

                  const SizedBox(height: 40),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _getLevelTitle(int level) {
    if (level >= 50) return 'Legendary Cleaner';
    if (level >= 30) return 'Expert Cleaner';
    if (level >= 20) return 'Pro Cleaner';
    if (level >= 10) return 'Master Cleaner';
    if (level >= 5) return 'Junior Tidier';
    return 'Newbie Cleaner';
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}k';
    }
    return number.toString();
  }

  void _showPointsHistory(BuildContext context, List<Map<String, dynamic>> history) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Points History',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (history.isEmpty)
              const Center(child: Text('No points earned yet!'))
            else
              ...history.take(5).map((item) => ListTile(
                leading: Text(item['type'] == 'earn' ? '➕' : '➖', style: const TextStyle(fontSize: 24)),
                title: Text(item['description'] ?? 'Points'),
                trailing: Text(
                  '${item['type'] == 'earn' ? '+' : '-'}${item['amount']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item['type'] == 'earn' ? AppTheme.success : AppTheme.error,
                  ),
                ),
              )),
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, ChildProvider childProvider) {
    final avatars = ['👦', '👧', '🧒', '👶', '🧑', '👱', '🧔', '👩', '🐱', '🐶', '🦊', '🐼'];
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pick your avatar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: avatars.map((avatar) => GestureDetector(
                onTap: () async {
                  final childId = childProvider.childId;
                  if (childId != null) {
                    await context.read<ProfileProvider>().updateAvatar(childId, avatar);
                    await childProvider.fetchChild(childId);
                  }
                  Navigator.pop(context);
                },
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(avatar, style: const TextStyle(fontSize: 32)),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showChangePinDialog(BuildContext context, ProfileProvider profileProvider) {
    final pinController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change PIN'),
        content: TextField(
          controller: pinController,
          keyboardType: TextInputType.number,
          maxLength: 4,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'New 4-digit PIN',
            hintText: 'Enter 4 digits',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final childId = context.read<ChildProvider>().childId;
              if (childId != null && pinController.text.length == 4) {
                final success = await profileProvider.updatePin(childId, pinController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'PIN updated! 🔐' : 'Failed to update PIN'),
                    backgroundColor: success ? AppTheme.success : AppTheme.error,
                  ),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String emoji, String value, String label) {
    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(String emoji, String title, bool unlocked) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: unlocked
                  ? AppTheme.accent.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: unlocked ? AppTheme.accent : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: Center(
              child: Opacity(
                opacity: unlocked ? 1 : 0.4,
                child: Text(emoji, style: const TextStyle(fontSize: 28)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: unlocked ? null : Colors.grey,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: isDestructive
                ? AppTheme.error.withOpacity(0.1)
                : AppTheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: isDestructive ? AppTheme.error : AppTheme.primary,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isDestructive ? AppTheme.error : null,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tileColor: Theme.of(context).cardColor,
      ),
    );
  }
}
