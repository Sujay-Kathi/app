import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
                      child: const Center(
                        child: Text('👦', style: TextStyle(fontSize: 50)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Arjun',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Level 10 - Master Cleaner',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn('🔥', '7', 'Streak'),
                        _buildStatColumn('⭐', '1,250', 'Points'),
                        _buildStatColumn('🏆', '12', 'Badges'),
                        _buildStatColumn('✅', '156', 'Tasks'),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 24),

              // Achievements Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Achievements',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('See All'),
                  ),
                ],
              ).animate().fadeIn(delay: 200.ms),

              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildAchievementBadge('🔥', 'Week Warrior', true),
                    _buildAchievementBadge('✅', 'Task Tackler', true),
                    _buildAchievementBadge('🌟', 'Level 10', true),
                    _buildAchievementBadge('💪', '14 Day Streak', false),
                  ],
                ),
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 24),

              // Menu Items
              _buildMenuItem(
                icon: Icons.history,
                title: 'Points History',
                subtitle: 'View your earning history',
                onTap: () {},
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.1),

              _buildMenuItem(
                icon: Icons.color_lens,
                title: 'Change Avatar',
                subtitle: 'Pick a new emoji avatar',
                onTap: () {},
              ).animate().fadeIn(delay: 450.ms).slideX(begin: 0.1),

              _buildMenuItem(
                icon: Icons.pin,
                title: 'Change PIN',
                subtitle: 'Update your secret PIN',
                onTap: () {},
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
                onTap: () {
                  context.go('/login');
                },
                isDestructive: true,
              ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),

              const SizedBox(height: 40),
            ],
          ),
        ),
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
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.grey.shade400,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tileColor: Colors.grey.shade50,
      ),
    );
  }
}
