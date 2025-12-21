import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../child/providers/child_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  List<Map<String, dynamic>> _allAchievements = [];
  List<Map<String, dynamic>> _unlockedAchievements = [];
  bool _isLoading = true;
  String _selectedCategory = 'all';

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() => _isLoading = true);
    
    final childId = context.read<ChildProvider>().childId;
    
    try {
      // Load all achievements
      final allResponse = await supabase
          .from('tidy_achievements')
          .select()
          .order('category')
          .order('requirement_value');
      
      _allAchievements = List<Map<String, dynamic>>.from(allResponse);
      
      // Load unlocked achievements for this child
      if (childId != null) {
        final unlockedResponse = await supabase
            .from('tidy_child_achievements')
            .select('*, achievement:tidy_achievements(*)')
            .eq('child_id', childId);
        
        _unlockedAchievements = List<Map<String, dynamic>>.from(unlockedResponse);
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      debugPrint('Error loading achievements: $e');
      setState(() => _isLoading = false);
    }
  }

  bool _isUnlocked(String achievementId) {
    return _unlockedAchievements.any((ua) => ua['achievement_id'] == achievementId);
  }

  DateTime? _getUnlockDate(String achievementId) {
    final unlocked = _unlockedAchievements.firstWhere(
      (ua) => ua['achievement_id'] == achievementId,
      orElse: () => {},
    );
    if (unlocked.isNotEmpty && unlocked['unlocked_at'] != null) {
      return DateTime.parse(unlocked['unlocked_at']);
    }
    return null;
  }

  List<Map<String, dynamic>> get _filteredAchievements {
    if (_selectedCategory == 'all') {
      return _allAchievements;
    }
    return _allAchievements.where((a) => a['category'] == _selectedCategory).toList();
  }

  int get _unlockedCount => _unlockedAchievements.length;
  int get _totalCount => _allAchievements.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.accent.withOpacity(0.1),
              Theme.of(context).scaffoldBackgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.accent, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Achievements',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Collect badges and rewards!',
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.military_tech, color: AppTheme.success, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            '$_unlockedCount/$_totalCount',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Progress Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: _totalCount > 0 ? _unlockedCount / _totalCount : 0,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: const AlwaysStoppedAnimation(AppTheme.success),
                        minHeight: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${((_unlockedCount / (_totalCount > 0 ? _totalCount : 1)) * 100).toInt()}% Complete',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 16),

              // Category Filter
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    _buildCategoryChip('all', '🏆 All'),
                    _buildCategoryChip('streak', '🔥 Streak'),
                    _buildCategoryChip('tasks', '✅ Tasks'),
                    _buildCategoryChip('points', '💰 Points'),
                    _buildCategoryChip('level', '⭐ Level'),
                    _buildCategoryChip('special', '✨ Special'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Achievements List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: _loadAchievements,
                        child: _filteredAchievements.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('🏆', style: TextStyle(fontSize: 60)),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No achievements in this category',
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: _filteredAchievements.length,
                                itemBuilder: (context, index) {
                                  final achievement = _filteredAchievements[index];
                                  final isUnlocked = _isUnlocked(achievement['id']);
                                  final unlockDate = _getUnlockDate(achievement['id']);
                                  
                                  return _buildAchievementCard(
                                    achievement: achievement,
                                    isUnlocked: isUnlocked,
                                    unlockDate: unlockDate,
                                  ).animate().fadeIn(
                                    delay: Duration(milliseconds: 50 * index),
                                  ).slideX(begin: 0.1);
                                },
                              ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, String label) {
    final isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _selectedCategory = category),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primary : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey.shade700,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementCard({
    required Map<String, dynamic> achievement,
    required bool isUnlocked,
    DateTime? unlockDate,
  }) {
    final icon = achievement['icon'] ?? '🏆';
    final name = achievement['name'] ?? 'Achievement';
    final description = achievement['description'] ?? '';
    final xpReward = achievement['xp_reward'] ?? 0;
    final pointsReward = achievement['points_reward'] ?? 0;
    final category = achievement['category'] ?? '';
    final requirementValue = achievement['requirement_value'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: isUnlocked
            ? Border.all(color: AppTheme.success.withOpacity(0.5), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: isUnlocked 
                ? AppTheme.success.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: isUnlocked ? 15 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isUnlocked
                    ? _getCategoryColor(category).withOpacity(0.2)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      isUnlocked ? icon : '🔒',
                      style: TextStyle(
                        fontSize: isUnlocked ? 32 : 24,
                      ),
                    ),
                  ),
                  if (isUnlocked)
                    Positioned(
                      bottom: -2,
                      right: -2,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppTheme.success,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 10,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // Text Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isUnlocked ? null : Colors.grey.shade500,
                          ),
                        ),
                      ),
                      if (isUnlocked && unlockDate != null)
                        Text(
                          '${unlockDate.day}/${unlockDate.month}/${unlockDate.year}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isUnlocked ? Colors.grey.shade600 : Colors.grey.shade400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (xpReward > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('✨', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 4),
                              Text(
                                '+$xpReward XP',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked ? Colors.blue : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (pointsReward > 0) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('⭐', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 4),
                              Text(
                                '+$pointsReward',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isUnlocked ? Colors.amber[700] : Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(category).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getCategoryEmoji(category),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'streak':
        return Colors.orange;
      case 'tasks':
        return Colors.green;
      case 'points':
        return Colors.amber;
      case 'level':
        return Colors.purple;
      case 'special':
        return Colors.pink;
      default:
        return AppTheme.primary;
    }
  }

  String _getCategoryEmoji(String category) {
    switch (category) {
      case 'streak':
        return '🔥';
      case 'tasks':
        return '✅';
      case 'points':
        return '💰';
      case 'level':
        return '⭐';
      case 'special':
        return '✨';
      default:
        return '🏆';
    }
  }
}
