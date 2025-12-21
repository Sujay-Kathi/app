import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../auth/providers/auth_provider.dart';

class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  List<Map<String, dynamic>> _children = [];
  List<Map<String, dynamic>> _pendingTasks = [];
  List<Map<String, dynamic>> _recentActivity = [];
  bool _isLoading = true;
  int _totalTasksToday = 0;
  int _completedToday = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final profile = authProvider.profile;
      
      if (profile != null && profile['family_id'] != null) {
        final familyId = profile['family_id'];

        // Fetch children with room and streak data
        final childrenResponse = await supabase
            .from('tidy_children')
            .select('*, room:tidy_rooms(*), streak:tidy_streaks(*)')
            .eq('family_id', familyId)
            .order('created_at');

        _children = List<Map<String, dynamic>>.from(childrenResponse);

        // Get all child IDs
        final childIds = _children.map((c) => c['id'] as String).toList();

        if (childIds.isNotEmpty) {
          // Fetch pending approval tasks (completed but not verified)
          final pendingResponse = await supabase
              .from('tidy_tasks')
              .select('*, child:tidy_children(name, avatar_emoji)')
              .inFilter('child_id', childIds)
              .eq('status', 'completed')
              .order('completed_at', ascending: false);

          _pendingTasks = List<Map<String, dynamic>>.from(pendingResponse);

          // Calculate today's stats
          final today = DateTime.now();
          final todayStart = DateTime(today.year, today.month, today.day);
          
          final tasksResponse = await supabase
              .from('tidy_tasks')
              .select()
              .inFilter('child_id', childIds)
              .gte('created_at', todayStart.toIso8601String());

          final todayTasks = List<Map<String, dynamic>>.from(tasksResponse);
          _totalTasksToday = todayTasks.length;
          _completedToday = todayTasks.where((t) => 
            t['status'] == 'completed' || t['status'] == 'verified'
          ).length;

          // Fetch recent activity (recent completed tasks)
          final activityResponse = await supabase
              .from('tidy_tasks')
              .select('*, child:tidy_children(name, avatar_emoji)')
              .inFilter('child_id', childIds)
              .inFilter('status', ['completed', 'verified'])
              .order('completed_at', ascending: false)
              .limit(5);

          _recentActivity = List<Map<String, dynamic>>.from(activityResponse);
        }
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading data: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  void _logout() {
    context.read<AuthProvider>().signOut();
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome back! 👋',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Family Dashboard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () {},
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_outlined),
                      ),
                    ),
                    IconButton(
                      onPressed: _logout,
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.logout),
                      ),
                    ),
                  ],
                ).animate().fadeIn(),

                const SizedBox(height: 24),

                // Quick Stats
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickStat(
                        title: 'Tasks Today',
                        value: '$_totalTasksToday',
                        subtitle: '$_completedToday completed',
                        icon: Icons.check_circle_outline,
                        color: AppTheme.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildQuickStat(
                        title: 'Pending Approval',
                        value: '${_pendingTasks.length}',
                        subtitle: 'Need review',
                        icon: Icons.pending_actions,
                        color: AppTheme.warning,
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),

                // Children Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Children',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => context.push('/parent/children'),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Add Child'),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 12),

                // Children Cards - from real data
                if (_children.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        const Text(
                          'No children yet',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () => context.push('/parent/children'),
                          child: const Text('Add Your First Child'),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms)
                else
                  ...List.generate(_children.length, (index) {
                    final child = _children[index];
                    final room = child['room'];
                    final streak = child['streak'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildChildCard(
                        name: child['name'] ?? 'Child',
                        emoji: child['avatar_emoji'] ?? '👦',
                        age: child['age'] ?? 0,
                        streak: streak?['current_streak'] ?? 0,
                        roomScore: room?['cleanliness_score'] ?? 50,
                        pendingTasks: _getPendingTasksForChild(child['id']),
                        completedToday: _getCompletedTodayForChild(child['id']),
                      ).animate().fadeIn(delay: Duration(milliseconds: 300 + (index * 100))).slideX(begin: 0.1),
                    );
                  }),

                const SizedBox(height: 24),

                // Quick Actions
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.add_task,
                        label: 'Assign Task',
                        color: AppTheme.primary,
                        onTap: () => context.push('/parent/assign-task'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.verified,
                        label: 'Review Tasks',
                        color: AppTheme.secondary,
                        badge: _pendingTasks.isNotEmpty ? _pendingTasks.length : null,
                        onTap: () => _showPendingTasks(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.bar_chart,
                        label: 'Reports',
                        color: AppTheme.accent,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Reports coming soon!')),
                          );
                        },
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 600.ms),

                const SizedBox(height: 24),

                // Recent Activity
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 12),

                if (_recentActivity.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('No recent activity'),
                    ),
                  ).animate().fadeIn(delay: 800.ms)
                else
                  ...List.generate(_recentActivity.length, (index) {
                    final activity = _recentActivity[index];
                    final child = activity['child'];
                    return _buildActivityItem(
                      emoji: '✅',
                      title: '${child?['name'] ?? 'Child'} completed "${activity['title']}"',
                      time: _formatTime(activity['completed_at']),
                      points: activity['points'],
                    ).animate().fadeIn(delay: Duration(milliseconds: 800 + (index * 50)));
                  }),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  int _getPendingTasksForChild(String childId) {
    return _pendingTasks.where((t) => t['child_id'] == childId).length;
  }

  int _getCompletedTodayForChild(String childId) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    
    return _recentActivity.where((t) {
      if (t['child_id'] != childId) return false;
      final completedAt = DateTime.tryParse(t['completed_at'] ?? '');
      return completedAt != null && completedAt.isAfter(todayStart);
    }).length;
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.tryParse(timestamp);
    if (date == null) return '';
    
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    return '${diff.inDays} days ago';
  }

  void _showPendingTasks() {
    if (_pendingTasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No tasks pending approval! 🎉')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Pending Approval',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            // Tasks list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _pendingTasks.length,
                itemBuilder: (context, index) {
                  final task = _pendingTasks[index];
                  final child = task['child'];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              child?['avatar_emoji'] ?? '👦',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    task['title'] ?? 'Task',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'By ${child?['name'] ?? 'Child'} • ${_formatTime(task['completed_at'])}',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '⭐ ${task['points']}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => _rejectTask(task['id'], task['child_id']),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.error,
                                  side: const BorderSide(color: AppTheme.error),
                                ),
                                child: const Text('Reject'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => _approveTask(task['id'], task['child_id'], task['points']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.success,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Approve'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _approveTask(String taskId, String childId, int points) async {
    try {
      final authProvider = context.read<AuthProvider>();
      
      await supabase.from('tidy_tasks').update({
        'status': 'verified',
        'verified_at': DateTime.now().toIso8601String(),
        'verified_by': authProvider.user?.id,
      }).eq('id', taskId);

      // Award points to child
      final childData = await supabase
          .from('tidy_children')
          .select('total_points, available_points')
          .eq('id', childId)
          .single();

      await supabase.from('tidy_children').update({
        'total_points': (childData['total_points'] ?? 0) + points,
        'available_points': (childData['available_points'] ?? 0) + points,
      }).eq('id', childId);

      Navigator.pop(context);
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Task approved! +$points points awarded 🎉'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Future<void> _rejectTask(String taskId, String childId) async {
    try {
      await supabase.from('tidy_tasks').update({
        'status': 'rejected',
        'rejection_reason': 'Not approved by parent',
      }).eq('id', taskId);

      Navigator.pop(context);
      await _loadData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Task rejected. Child can try again.'),
            backgroundColor: AppTheme.warning,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  Widget _buildQuickStat({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildCard({
    required String name,
    required String emoji,
    required int age,
    required int streak,
    required int roomScore,
    required int pendingTasks,
    required int completedToday,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (streak > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 10)),
                            const SizedBox(width: 2),
                            Text(
                              '$streak',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Age $age • Room: $roomScore%',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMiniStat(Icons.pending, '$pendingTasks pending', AppTheme.warning),
                    const SizedBox(width: 12),
                    _buildMiniStat(Icons.check_circle, '$completedToday done', AppTheme.success),
                  ],
                ),
              ],
            ),
          ),

          // Arrow
          Icon(Icons.chevron_right, color: Colors.grey.shade400),
        ],
      ),
    );
  }

  Widget _buildMiniStat(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    int? badge,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
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
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          if (badge != null)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.error,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badge',
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
    );
  }

  Widget _buildActivityItem({
    required String emoji,
    required String title,
    required String time,
    int? points,
    bool isAchievement = false,
    bool isStreak = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          if (points != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '+$points',
                style: const TextStyle(
                  color: AppTheme.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
