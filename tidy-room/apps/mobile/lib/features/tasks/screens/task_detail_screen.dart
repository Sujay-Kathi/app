import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../../core/theme/app_theme.dart';
import '../providers/task_provider.dart';
import '../../child/providers/child_provider.dart';
import 'photo_verification_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> with TickerProviderStateMixin {
  Map<String, dynamic>? _task;
  bool _isLoading = true;
  bool _isCompleting = false;
  bool _showCelebration = false;
  
  late AnimationController _celebrationController;

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _loadTask();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _loadTask() async {
    setState(() => _isLoading = true);
    
    final task = await context.read<TaskProvider>().getTask(widget.taskId);
    
    setState(() {
      _task = task;
      _isLoading = false;
    });
  }

  Future<void> _completeTask() async {
    if (_task == null) return;
    
    final requiresVerification = _task!['requires_verification'] ?? false;
    final childId = context.read<ChildProvider>().childId;
    
    if (childId == null) return;
    
    if (requiresVerification) {
      // Navigate to photo verification screen
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => PhotoVerificationScreen(
            task: _task!,
            childId: childId,
            onComplete: () {
              Navigator.pop(context, true);
            },
          ),
        ),
      );
      
      if (result == true && mounted) {
        // Photo submitted, show celebration
        _showTaskCompletedCelebration();
      }
    } else {
      // Direct completion
      setState(() => _isCompleting = true);
      
      final childId = context.read<ChildProvider>().childId;
      if (childId != null) {
        final success = await context.read<TaskProvider>().completeTask(
          widget.taskId,
          childId,
        );
        
        if (success && mounted) {
          _showTaskCompletedCelebration();
        } else {
          setState(() => _isCompleting = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to complete task'),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        }
      }
    }
  }

  void _showTaskCompletedCelebration() {
    setState(() {
      _showCelebration = true;
      _isCompleting = false;
    });
    _celebrationController.forward();
    
    // Refresh task data
    _loadTask();
    
    // Navigate back after celebration
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/room');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Task Details'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_task == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Task Details'),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('❌', style: TextStyle(fontSize: 60)),
              const SizedBox(height: 16),
              const Text('Task not found'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    final zone = _task!['zone'] ?? 'general';
    final zoneColor = AppTheme.getZoneColor(zone);
    final icon = _task!['icon'] ?? '✨';
    final title = _task!['title'] ?? 'Task';
    final description = _task!['description'] ?? 'Complete this task to earn points!';
    final points = _task!['points'] ?? 0;
    final difficulty = _task!['difficulty'] ?? 'medium';
    final status = _task!['status'] ?? 'pending';
    final requiresVerification = _task!['requires_verification'] ?? false;
    final isCompleted = status != 'pending';

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  zoneColor.withOpacity(0.2),
                  Theme.of(context).scaffoldBackgroundColor,
                ],
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // App Bar
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          _getZoneName(zone),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: zoneColor,
                          ),
                        ),
                      ),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getStatusColor(status).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getStatusText(status),
                          style: TextStyle(
                            color: _getStatusColor(status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Task Icon
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: zoneColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: zoneColor.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(icon, style: const TextStyle(fontSize: 60)),
                          ),
                        ).animate().scale(
                          begin: const Offset(0.8, 0.8),
                          duration: 400.ms,
                          curve: Curves.elasticOut,
                        ),

                        const SizedBox(height: 24),

                        // Title
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn().slideY(begin: 0.2),

                        const SizedBox(height: 12),

                        // Description
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),

                        const SizedBox(height: 32),

                        // Stats Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                '⭐',
                                '$points',
                                'Points',
                                AppTheme.accent,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                _getDifficultyEmoji(difficulty),
                                difficulty.toUpperCase(),
                                'Difficulty',
                                AppTheme.getDifficultyColor(difficulty),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                requiresVerification ? '📸' : '✅',
                                requiresVerification ? 'Yes' : 'No',
                                'Photo Proof',
                                requiresVerification ? Colors.blue : Colors.grey,
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 200.ms),

                        const SizedBox(height: 32),

                        // Streak bonus info
                        Consumer<ChildProvider>(
                          builder: (context, childProvider, _) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.orange.withOpacity(0.2),
                                    Colors.red.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                children: [
                                  const Text('🔥', style: TextStyle(fontSize: 32)),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Streak Bonus Active!',
                                          style: TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          'Complete tasks daily to increase your multiplier!',
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
                            ).animate().fadeIn(delay: 300.ms);
                          },
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Complete Button
                if (!isCompleted)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isCompleting ? null : _completeTask,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: zoneColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: _isCompleting
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    requiresVerification ? Icons.camera_alt : Icons.check_circle,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    requiresVerification ? 'Complete with Photo 📸' : 'Mark as Complete ✓',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                  ),

                if (isCompleted)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.check_circle, color: AppTheme.success),
                          const SizedBox(width: 8),
                          Text(
                            _getStatusText(status),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Celebration overlay
          if (_showCelebration)
            _buildCelebrationOverlay(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebrationOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Stack(
        children: [
          // Confetti
          ...List.generate(30, (index) {
            final random = math.Random(index);
            final startX = random.nextDouble() * MediaQuery.of(context).size.width;
            final delay = random.nextDouble() * 500;
            final size = 10.0 + random.nextDouble() * 20;
            final color = [
              AppTheme.primary,
              AppTheme.secondary,
              AppTheme.accent,
              Colors.pink,
              Colors.green,
              Colors.orange,
            ][random.nextInt(6)];

            return AnimatedBuilder(
              animation: _celebrationController,
              builder: (context, child) {
                final progress = ((_celebrationController.value * 2) - delay / 1000).clamp(0.0, 1.0);
                if (progress <= 0) return const SizedBox();
                
                return Positioned(
                  left: startX + math.sin(progress * math.pi * 4 + index) * 50,
                  top: -50 + progress * (MediaQuery.of(context).size.height + 100),
                  child: Transform.rotate(
                    angle: progress * math.pi * 4,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        color: color.withOpacity(1 - progress * 0.5),
                        borderRadius: BorderRadius.circular(size / 4),
                      ),
                    ),
                  ),
                );
              },
            );
          }),

          // Success message
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 80)),
                const SizedBox(height: 24),
                const Text(
                  'Task Completed!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.accent,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Colors.white, size: 28),
                      const SizedBox(width: 8),
                      Text(
                        '+${_task?['points'] ?? 0} Points!',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().scale(
            begin: const Offset(0.5, 0.5),
            curve: Curves.elasticOut,
            duration: 600.ms,
          ),
        ],
      ),
    );
  }

  String _getZoneName(String zone) {
    final zones = {
      'bed': '🛏️ Bed Zone',
      'floor': '🧹 Floor Zone',
      'desk': '📚 Desk Zone',
      'closet': '👕 Closet Zone',
      'general': '✨ General',
    };
    return zones[zone] ?? '✨ General';
  }

  String _getDifficultyEmoji(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return '🟢';
      case 'medium':
        return '🟡';
      case 'hard':
        return '🔴';
      default:
        return '🟡';
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
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
      case 'pending':
        return 'Pending';
      case 'completed':
        return 'Awaiting Approval';
      case 'verified':
        return 'Completed! ✓';
      case 'rejected':
        return 'Rejected';
      default:
        return 'Unknown';
    }
  }
}
