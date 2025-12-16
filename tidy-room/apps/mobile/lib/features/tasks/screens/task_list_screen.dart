import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedZone = 'all';

  final List<Map<String, dynamic>> _demoTasks = [
    {
      'id': '1',
      'title': 'Make the Bed',
      'zone': 'bed',
      'points': 15,
      'difficulty': 'easy',
      'icon': '🛏️',
      'status': 'pending',
    },
    {
      'id': '2',
      'title': 'Pick Up Toys',
      'zone': 'floor',
      'points': 20,
      'difficulty': 'easy',
      'icon': '🧸',
      'status': 'pending',
    },
    {
      'id': '3',
      'title': 'Clear Desk Clutter',
      'zone': 'desk',
      'points': 25,
      'difficulty': 'medium',
      'icon': '📚',
      'status': 'pending',
    },
    {
      'id': '4',
      'title': 'Empty Trash Bin',
      'zone': 'general',
      'points': 10,
      'difficulty': 'easy',
      'icon': '🗑️',
      'status': 'completed',
    },
    {
      'id': '5',
      'title': 'Organize Bookshelf',
      'zone': 'desk',
      'points': 35,
      'difficulty': 'medium',
      'icon': '📖',
      'status': 'completed',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _pendingTasks =>
      _demoTasks.where((t) => t['status'] == 'pending').toList();

  List<Map<String, dynamic>> get _completedTasks =>
      _demoTasks.where((t) => t['status'] == 'completed').toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                          '${_completedTasks.length}/${_demoTasks.length}',
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
                  Tab(text: 'To Do (${_pendingTasks.length})'),
                  Tab(text: 'Done (${_completedTasks.length})'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Task List
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTaskList(_pendingTasks, false),
                  _buildTaskList(_completedTasks, true),
                ],
              ),
            ),
          ],
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

  Widget _buildTaskList(List<Map<String, dynamic>> tasks, bool isCompleted) {
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
              isCompleted ? 'No completed tasks yet' : 'All tasks done!',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
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
        return _buildTaskCard(task, isCompleted).animate().fadeIn(
          delay: Duration(milliseconds: 100 * index),
        ).slideX(begin: 0.1);
      },
    );
  }

  Widget _buildTaskCard(Map<String, dynamic> task, bool isCompleted) {
    final zoneColor = AppTheme.getZoneColor(task['zone']);
    
    return Container(
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
            onTap: isCompleted ? null : () => _completeTask(task['id']),
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
                    : Text(task['icon'], style: const TextStyle(fontSize: 26)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Task Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'],
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    color: isCompleted ? Colors.grey : null,
                  ),
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
                        task['zone'].toString().toUpperCase(),
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
                        color: AppTheme.getDifficultyColor(task['difficulty']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        task['difficulty'].toString().toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getDifficultyColor(task['difficulty']),
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
                  '${task['points']}',
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
    );
  }

  void _completeTask(String taskId) {
    // TODO: Implement task completion with provider
    setState(() {
      final index = _demoTasks.indexWhere((t) => t['id'] == taskId);
      if (index != -1) {
        _demoTasks[index]['status'] = 'completed';
      }
    });

    // Show celebration
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Text('🎉 Task completed! +'),
            Text(' points', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
