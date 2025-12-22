import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../providers/task_provider.dart';
import '../../child/providers/child_provider.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedZone = 'all';
  bool _isInitialized = false;

  final List<Map<String, dynamic>> _zones = [
    {'id': 'all', 'name': 'All', 'emoji': '📋'},
    {'id': 'bed', 'name': 'Bed', 'emoji': '🛏️'},
    {'id': 'floor', 'name': 'Floor', 'emoji': '🧹'},
    {'id': 'desk', 'name': 'Desk', 'emoji': '📚'},
    {'id': 'closet', 'name': 'Closet', 'emoji': '👕'},
    {'id': 'general', 'name': 'General', 'emoji': '✨'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _loadTasks();
      _isInitialized = true;
    }
  }

  Future<void> _loadTasks() async {
    final childId = context.read<ChildProvider>().childId;
    if (childId != null) {
      await context.read<TaskProvider>().fetchTasks(childId);
    }
  }

  Future<void> _refresh() async {
    await _loadTasks();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filterByZone(List<Map<String, dynamic>> tasks) {
    if (_selectedZone == 'all') return tasks;
    return tasks.where((t) => t['zone'] == _selectedZone).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.secondary.withOpacity(0.1),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Consumer2<TaskProvider, ChildProvider>(
            builder: (context, taskProvider, childProvider, _) {
              final pendingTasks = _filterByZone(taskProvider.pendingTasks);
              final completedTasks = _filterByZone(taskProvider.completedTasks);
              final allTasks = taskProvider.tasks;

              if (taskProvider.isLoading && allTasks.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading tasks...'),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: _refresh,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: _buildHeader(
                        pendingCount: taskProvider.pendingTasks.length,
                        completedCount: taskProvider.completedTasks.length,
                      ),
                    ),

                    // Zone Filter
                    SliverToBoxAdapter(
                      child: _buildZoneFilter(),
                    ),

                    // Tab Bar
                    SliverToBoxAdapter(
                      child: _buildTabBar(
                        pendingCount: pendingTasks.length,
                        completedCount: completedTasks.length,
                      ),
                    ),

                    // Tab Content
                    SliverFillRemaining(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTaskList(pendingTasks, isPending: true),
                          _buildTaskList(completedTasks, isPending: false),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({required int pendingCount, required int completedCount}) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Icon with gradient
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.secondary, AppTheme.primary],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.secondary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('📋', style: TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My Tasks',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  pendingCount > 0 
                      ? '$pendingCount tasks waiting for you!'
                      : 'All done! 🎉',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Stats badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.success.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.success, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$completedCount',
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
    ).animate().fadeIn().slideY(begin: -0.1);
  }

  Widget _buildZoneFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 45,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _zones.length,
          itemBuilder: (context, index) {
            final zone = _zones[index];
            final isSelected = _selectedZone == zone['id'];
            return GestureDetector(
              onTap: () => setState(() => _selectedZone = zone['id']),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? LinearGradient(
                          colors: [
                            _getZoneColor(zone['id']),
                            _getZoneColor(zone['id']).withOpacity(0.7),
                          ],
                        )
                      : null,
                  color: isSelected ? null : Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: _getZoneColor(zone['id']).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    Text(zone['emoji'], style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      zone['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: isSelected ? Colors.white : null,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ).animate().fadeIn(delay: 100.ms);
  }

  Widget _buildTabBar({required int pendingCount, required int completedCount}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppTheme.primary, AppTheme.secondary],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          dividerColor: Colors.transparent,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('To Do'),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$pendingCount',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Done'),
                  if (completedCount > 0) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.success,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$completedCount',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildTaskList(List<Map<String, dynamic>> tasks, {required bool isPending}) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isPending ? '🎉' : '📋',
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            Text(
              isPending ? 'No pending tasks!' : 'No completed tasks yet',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isPending
                  ? 'Great job keeping your room tidy!'
                  : 'Complete tasks to see them here',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task, isPending: isPending)
            .animate()
            .fadeIn(delay: Duration(milliseconds: 100 * index))
            .slideX(begin: 0.05);
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, {required bool isPending}) {
    final zone = task['zone'] ?? 'general';
    final zoneColor = AppTheme.getZoneColor(zone);
    final icon = task['icon'] ?? '✨';
    final title = task['title'] ?? 'Task';
    final points = task['points'] ?? 0;
    final difficulty = task['difficulty'] ?? 'medium';
    final status = task['status'] ?? 'pending';
    final requiresVerification = task['requires_verification'] ?? false;

    return GestureDetector(
      onTap: () => context.push('/tasks/${task['id']}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isPending ? zoneColor.withOpacity(0.2) : AppTheme.success.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: (isPending ? zoneColor : AppTheme.success).withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isPending
                      ? [zoneColor.withOpacity(0.2), zoneColor.withOpacity(0.1)]
                      : [AppTheme.success.withOpacity(0.2), AppTheme.success.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
                  if (!isPending)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: AppTheme.success,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.check, size: 12, color: Colors.white),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            // Task Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: !isPending ? TextDecoration.lineThrough : null,
                      color: !isPending ? Colors.grey : null,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _buildBadge(
                        difficulty.toUpperCase(),
                        AppTheme.getDifficultyColor(difficulty),
                      ),
                      const SizedBox(width: 6),
                      _buildBadge(
                        zone.toUpperCase(),
                        zoneColor,
                      ),
                      if (requiresVerification) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.camera_alt, size: 10, color: Colors.blue),
                              SizedBox(width: 2),
                              Text(
                                '📸',
                                style: TextStyle(fontSize: 10),
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
            // Points / Status
            isPending
                ? Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.accent, AppTheme.accent.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '+$points',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _getStatusColor(status),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getZoneColor(String zone) {
    switch (zone) {
      case 'bed':
        return AppTheme.zoneBed;
      case 'floor':
        return AppTheme.zoneFloor;
      case 'desk':
        return AppTheme.zoneDesk;
      case 'closet':
        return AppTheme.zoneCloset;
      default:
        return AppTheme.primary;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.blue;
      case 'verified':
        return AppTheme.success;
      case 'rejected':
        return AppTheme.error;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Pending Approval';
      case 'verified':
        return 'Verified ✓';
      case 'rejected':
        return 'Rejected';
      default:
        return status;
    }
  }
}
