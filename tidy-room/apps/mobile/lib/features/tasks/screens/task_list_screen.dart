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
    return Scaffold(
      body: SafeArea(
        child: Consumer2<TaskProvider, ChildProvider>(
          builder: (context, taskProvider, childProvider, _) {
            final pendingTasks = _filterByZone(taskProvider.pendingTasks);
            final completedTasks = _filterByZone(taskProvider.completedTasks);
            final allTasks = taskProvider.tasks;

            // Show loading state
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
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text(
                          'My Tasks',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppTheme.secondary, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${taskProvider.completedCount}/${allTasks.length}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Zone Filter
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildZoneChip('all', 'All', '✨'),
                        _buildZoneChip('bed', 'Bed', '🛏️'),
                        _buildZoneChip('floor', 'Floor', '🧹'),
                        _buildZoneChip('desk', 'Desk', '📚'),
                        _buildZoneChip('closet', 'Closet', '👕'),
                        _buildZoneChip('general', 'General', '🧼'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tab Bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
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
                      tabs: [
                        Tab(text: 'To Do (${pendingTasks.length})'),
                        Tab(text: 'Done (${completedTasks.length})'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Task List
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildTaskList(pendingTasks, false, childProvider.childId),
                        _buildTaskList(completedTasks, true, childProvider.childId),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildZoneChip(String zone, String label, String emoji) {
    final isSelected = _selectedZone == zone;
    return GestureDetector(
      onTap: () => setState(() => _selectedZone = zone),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Map<String, dynamic>> tasks, bool isCompleted, String? childId) {
    if (tasks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isCompleted ? '🎉' : '📋',
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            Text(
              isCompleted 
                  ? 'No completed tasks yet' 
                  : _selectedZone == 'all' 
                      ? 'All tasks done! Great job!' 
                      : 'No tasks in this zone',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            if (!isCompleted && _selectedZone == 'all') ...[
              const SizedBox(height: 24),
              const Text(
                '🌟',
                style: TextStyle(fontSize: 40),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return _buildTaskCard(task, isCompleted, childId).animate().fadeIn(
          delay: Duration(milliseconds: 100 * index),
        ).slideX(begin: 0.1);
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, bool isCompleted, String? childId) {
    final zone = task['zone'] ?? 'general';
    final zoneColor = AppTheme.getZoneColor(zone);
    final difficulty = task['difficulty'] ?? 'medium';
    final icon = task['icon'] ?? '✨';
    final points = task['points'] ?? 10;
    final title = task['title'] ?? 'Task';
    final requiresVerification = task['requires_verification'] ?? false;
    
    return GestureDetector(
      onTap: () {
        // Navigate to task detail
        context.go('/tasks/${task['id']}');
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCompleted ? Colors.grey.shade300 : zoneColor.withOpacity(0.3),
          ),
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
            // Checkbox / Complete Button
            GestureDetector(
              onTap: isCompleted ? null : () => _completeTask(task, childId),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.success.withOpacity(0.1)
                      : zoneColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_circle, color: AppTheme.success, size: 28)
                      : Text(icon, style: const TextStyle(fontSize: 26)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            
            // Task Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            decoration: isCompleted ? TextDecoration.lineThrough : null,
                            color: isCompleted ? Colors.grey : null,
                          ),
                        ),
                      ),
                      if (requiresVerification && !isCompleted) ...[
                        const SizedBox(width: 4),
                        Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.grey.shade500,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: zoneColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          zone.toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: zoneColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.getDifficultyColor(difficulty).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          difficulty.toString().toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.getDifficultyColor(difficulty),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Points
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
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
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeTask(Map<String, dynamic> task, String? childId) async {
    if (childId == null) return;
    
    final taskId = task['id'];
    final points = task['points'] ?? 10;
    final requiresVerification = task['requires_verification'] ?? false;

    if (requiresVerification) {
      // Navigate to photo verification screen
      // TODO: Implement photo capture flow
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📷 Photo verification coming soon!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Complete the task
    final success = await context.read<TaskProvider>().completeTask(taskId, childId);
    
    if (success && mounted) {
      // Update points in child provider
      context.read<ChildProvider>().updatePoints(points);
      
      // Show celebration
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Text('🎉 Task completed! +'),
              Text('$points', style: const TextStyle(fontWeight: FontWeight.bold)),
              const Text(' points'),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
