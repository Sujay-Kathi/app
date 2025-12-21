import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../auth/providers/auth_provider.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  String? _error;
  String _selectedPeriod = 'week';
  
  // Data
  List<Map<String, dynamic>> _children = [];
  Map<String, dynamic>? _selectedChild;
  List<Map<String, dynamic>> _completedTasks = [];
  List<Map<String, dynamic>> _pointsHistory = [];
  Map<String, int> _tasksByZone = {};
  int _totalTasks = 0;
  int _totalPoints = 0;
  int _currentStreak = 0;
  int _longestStreak = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadChildren();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadChildren() async {
    try {
      final authProvider = context.read<AuthProvider>();
      final profile = authProvider.profile;
      
      if (profile == null || profile['family_id'] == null) {
        setState(() {
          _error = 'No family found';
          _isLoading = false;
        });
        return;
      }

      final response = await supabase
          .from('tidy_children')
          .select('*, streak:tidy_streaks(*)')
          .eq('family_id', profile['family_id'])
          .order('created_at');

      _children = List<Map<String, dynamic>>.from(response);
      
      if (_children.isNotEmpty) {
        _selectedChild = _children.first;
        await _loadReportData();
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadReportData() async {
    if (_selectedChild == null) return;

    setState(() => _isLoading = true);

    try {
      final childId = _selectedChild!['id'];
      final now = DateTime.now();
      DateTime startDate;
      
      switch (_selectedPeriod) {
        case 'day':
          startDate = DateTime(now.year, now.month, now.day);
          break;
        case 'week':
          startDate = now.subtract(const Duration(days: 7));
          break;
        case 'month':
          startDate = DateTime(now.year, now.month - 1, now.day);
          break;
        case 'all':
          startDate = DateTime(2020);
          break;
        default:
          startDate = now.subtract(const Duration(days: 7));
      }

      // Fetch completed tasks
      final tasksResponse = await supabase
          .from('tidy_tasks')
          .select()
          .eq('child_id', childId)
          .gte('completed_at', startDate.toIso8601String())
          .inFilter('status', ['completed', 'verified'])
          .order('completed_at', ascending: false);

      _completedTasks = List<Map<String, dynamic>>.from(tasksResponse);

      // Calculate stats
      _totalTasks = _completedTasks.length;
      _totalPoints = _completedTasks.fold(0, (sum, task) => sum + (task['points'] as int? ?? 0));
      
      // Tasks by zone
      _tasksByZone = {};
      for (final task in _completedTasks) {
        final zone = task['zone'] as String? ?? 'general';
        _tasksByZone[zone] = (_tasksByZone[zone] ?? 0) + 1;
      }

      // Get streak data
      final streak = _selectedChild!['streak'];
      _currentStreak = streak?['current_streak'] ?? 0;
      _longestStreak = streak?['longest_streak'] ?? 0;

      // Fetch points history
      final pointsResponse = await supabase
          .from('tidy_points_log')
          .select()
          .eq('child_id', childId)
          .gte('created_at', startDate.toIso8601String())
          .order('created_at', ascending: false)
          .limit(20);

      _pointsHistory = List<Map<String, dynamic>>.from(pointsResponse);

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity Reports'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _children.isEmpty
                  ? _buildNoChildrenState()
                  : _buildReportContent(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text(_error ?? 'An error occurred'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadChildren,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoChildrenState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('👶', style: TextStyle(fontSize: 64)),
          SizedBox(height: 16),
          Text('No children yet', style: TextStyle(fontSize: 18)),
          SizedBox(height: 8),
          Text('Add a child to see their activity reports'),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    return Column(
      children: [
        // Child selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _children.map((child) {
                      final isSelected = _selectedChild?['id'] == child['id'];
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedChild = child);
                          _loadReportData();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                            ),
                          ),
                          child: Row(
                            children: [
                              Text(child['avatar_emoji'] ?? '👦', style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(
                                child['name'] ?? 'Child',
                                style: TextStyle(
                                  color: isSelected ? Colors.white : null,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ).animate().fadeIn(),

        const SizedBox(height: 16),

        // Period selector
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['day', 'week', 'month', 'all'].map((period) {
              final isSelected = _selectedPeriod == period;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedPeriod = period);
                    _loadReportData();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.secondary : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        period == 'all' ? 'All Time' : period.capitalize(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : null,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ).animate().fadeIn(delay: 100.ms),

        const SizedBox(height: 16),

        // Tab bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(12),
            ),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey.shade600,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Tasks'),
              Tab(text: 'Points'),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms),

        const SizedBox(height: 16),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOverviewTab(),
              _buildTasksTab(),
              _buildPointsTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Tasks Done',
                  value: '$_totalTasks',
                  icon: Icons.check_circle,
                  color: AppTheme.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Points Earned',
                  value: '$_totalPoints',
                  icon: Icons.star,
                  color: AppTheme.accent,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Current Streak',
                  value: '$_currentStreak',
                  icon: Icons.local_fire_department,
                  color: Colors.orange,
                  suffix: 'days',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: 'Best Streak',
                  value: '$_longestStreak',
                  icon: Icons.emoji_events,
                  color: AppTheme.primary,
                  suffix: 'days',
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // Tasks by Zone
          const Text(
            'Tasks by Zone',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ).animate().fadeIn(delay: 300.ms),
          const SizedBox(height: 12),
          
          ..._buildZoneBreakdown(),

          const SizedBox(height: 24),

          // Child Info
          if (_selectedChild != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Text(
                    _selectedChild!['avatar_emoji'] ?? '👦',
                    style: const TextStyle(fontSize: 48),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedChild!['name'] ?? 'Child',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Level ${_selectedChild!['current_level'] ?? 1}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: AppTheme.accent),
                            const SizedBox(width: 4),
                            Text(
                              '${_selectedChild!['total_points'] ?? 0} total points',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
        ],
      ),
    );
  }

  List<Widget> _buildZoneBreakdown() {
    final zones = ['bed', 'floor', 'desk', 'closet', 'general'];
    final zoneEmojis = {'bed': '🛏️', 'floor': '🧹', 'desk': '📚', 'closet': '👕', 'general': '✨'};
    final zoneNames = {'bed': 'Bed', 'floor': 'Floor', 'desk': 'Desk', 'closet': 'Closet', 'general': 'General'};
    
    final maxTasks = _tasksByZone.values.isEmpty ? 1 : _tasksByZone.values.reduce((a, b) => a > b ? a : b);
    
    return zones.map((zone) {
      final count = _tasksByZone[zone] ?? 0;
      final progress = maxTasks > 0 ? count / maxTasks : 0.0;
      
      return Container(
        margin: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Text(zoneEmojis[zone]!, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(zoneNames[zone]!, style: const TextStyle(fontWeight: FontWeight.w500)),
                      Text('$count tasks'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(AppTheme.getZoneColor(zone)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: Duration(milliseconds: 300 + zones.indexOf(zone) * 50));
    }).toList();
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? suffix,
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
              Icon(icon, color: color, size: 24),
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          if (suffix != null)
            Text(suffix, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTasksTab() {
    if (_completedTasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📋', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('No completed tasks in this period'),
            Text(
              'Try selecting a different time period',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _completedTasks.length,
      itemBuilder: (context, index) {
        final task = _completedTasks[index];
        return _buildTaskItem(task).animate().fadeIn(
          delay: Duration(milliseconds: 50 * index),
        );
      },
    );
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    final completedAt = DateTime.tryParse(task['completed_at'] ?? '');
    final dateStr = completedAt != null 
        ? DateFormat('MMM d, h:mm a').format(completedAt) 
        : '';
        
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(task['icon'] ?? '✨', style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'] ?? 'Task',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  dateStr,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, size: 14, color: AppTheme.accent),
                const SizedBox(width: 4),
                Text(
                  '+${task['points'] ?? 0}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPointsTab() {
    if (_pointsHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⭐', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('No points history in this period'),
            Text(
              'Complete tasks to earn points!',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _pointsHistory.length,
      itemBuilder: (context, index) {
        final entry = _pointsHistory[index];
        return _buildPointsItem(entry).animate().fadeIn(
          delay: Duration(milliseconds: 50 * index),
        );
      },
    );
  }

  Widget _buildPointsItem(Map<String, dynamic> entry) {
    final points = entry['points'] as int? ?? 0;
    final isPositive = points > 0;
    final createdAt = DateTime.tryParse(entry['created_at'] ?? '');
    final dateStr = createdAt != null 
        ? DateFormat('MMM d, h:mm a').format(createdAt) 
        : '';
    
    final typeIcons = {
      'task_complete': '✅',
      'streak_bonus': '🔥',
      'level_up': '⬆️',
      'purchase': '🛒',
      'bonus': '🎁',
      'adjustment': '⚙️',
    };
        
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: (isPositive ? AppTheme.success : AppTheme.error).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                typeIcons[entry['type']] ?? '⭐',
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['description'] ?? 'Points',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  dateStr,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${isPositive ? '+' : ''}$points',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isPositive ? AppTheme.success : AppTheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
  }
}
