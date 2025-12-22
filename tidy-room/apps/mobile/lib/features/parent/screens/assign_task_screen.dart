import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../auth/providers/auth_provider.dart';
import '../../tasks/providers/task_provider.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  String? _selectedChild;
  String? _selectedZone;
  Set<String> _selectedTemplates = {}; // Changed to Set for multi-select
  int _points = 20;
  String _difficulty = 'medium';
  bool _requiresVerification = false;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  List<Map<String, dynamic>> _children = [];
  List<Map<String, dynamic>> _taskTemplates = [];

  final List<Map<String, dynamic>> _zones = [
    {'id': 'bed', 'name': 'Bed Zone', 'emoji': '🛏️', 'color': AppTheme.zoneBed},
    {'id': 'floor', 'name': 'Floor Zone', 'emoji': '🧹', 'color': AppTheme.zoneFloor},
    {'id': 'desk', 'name': 'Desk Zone', 'emoji': '📚', 'color': AppTheme.zoneDesk},
    {'id': 'closet', 'name': 'Closet Zone', 'emoji': '👕', 'color': AppTheme.zoneCloset},
    {'id': 'general', 'name': 'General', 'emoji': '✨', 'color': AppTheme.zoneGeneral},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final profile = authProvider.profile;

      if (profile == null || profile['family_id'] == null) {
        setState(() {
          _error = 'No family found. Please try logging out and back in.';
          _isLoading = false;
        });
        return;
      }

      // Fetch children
      final childrenResponse = await supabase
          .from('tidy_children')
          .select()
          .eq('family_id', profile['family_id'])
          .order('created_at');

      // Fetch task templates
      final templatesResponse = await supabase
          .from('tidy_task_templates')
          .select()
          .order('zone')
          .order('default_points');

      setState(() {
        _children = List<Map<String, dynamic>>.from(childrenResponse);
        _taskTemplates = List<Map<String, dynamic>>.from(templatesResponse);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredTemplates {
    if (_selectedZone == null) return _taskTemplates;
    return _taskTemplates.where((t) => t['zone'] == _selectedZone).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Task'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _children.isEmpty
                  ? _buildNoChildrenState()
                  : _buildTaskForm(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoChildrenState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('👶', style: TextStyle(fontSize: 80)),
            const SizedBox(height: 24),
            const Text(
              'No Children Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'You need to add a child before you can assign tasks.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.push('/parent/children');
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Add Your First Child'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ).animate().fadeIn(),
      ),
    );
  }

  Widget _buildTaskForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step 1: Select Child
          _buildSectionTitle('1. Select Child'),
          const SizedBox(height: 12),
          _buildChildSelector(),

          const SizedBox(height: 24),

          // Step 2: Select Zone
          _buildSectionTitle('2. Select Zone'),
          const SizedBox(height: 12),
          _buildZoneSelector(),

          const SizedBox(height: 24),

          // Step 3: Select Task Template
          _buildSectionTitle('3. Choose Task'),
          const SizedBox(height: 12),
          _buildTaskTemplateList(),

          const SizedBox(height: 24),

          // Step 4: Customize
          _buildSectionTitle('4. Customize (Optional)'),
          const SizedBox(height: 12),
          _buildPointsSlider(),
          const SizedBox(height: 12),
          _buildDifficultySelector(),
          const SizedBox(height: 12),
          _buildVerificationToggle(),

          const SizedBox(height: 32),

          // Assign Button
          _buildAssignButton(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildChildSelector() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _children.map((child) {
        final isSelected = _selectedChild == child['id'];
        return GestureDetector(
          onTap: () => setState(() => _selectedChild = child['id']),
          child: Container(
            width: (_children.length <= 2) 
                ? (MediaQuery.of(context).size.width - 44) / 2
                : null,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary.withOpacity(0.1) : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? AppTheme.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(child['avatar_emoji'] ?? '👦', style: const TextStyle(fontSize: 32)),
                const SizedBox(height: 8),
                Text(
                  child['name'] ?? 'Child',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppTheme.primary : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    ).animate().fadeIn().slideX(begin: 0.1);
  }

  Widget _buildZoneSelector() {
    return SizedBox(
      height: 50,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: _zones.map((zone) {
          final isSelected = _selectedZone == zone['id'];
          return GestureDetector(
            onTap: () => setState(() {
              _selectedZone = zone['id'];
              _selectedTemplates.clear(); // Clear multi-select when zone changes
            }),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? zone['color'] : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                children: [
                  Text(zone['emoji'], style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text(
                    zone['name'],
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1);
  }

  Widget _buildTaskTemplateList() {
    final templates = _filteredTemplates;
    
    if (templates.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No task templates found'),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Multi-select info
        if (_selectedTemplates.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppTheme.primary, size: 18),
                const SizedBox(width: 8),
                Text(
                  '${_selectedTemplates.length} task${_selectedTemplates.length > 1 ? 's' : ''} selected',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => setState(() => _selectedTemplates.clear()),
                  child: const Text(
                    'Clear',
                    style: TextStyle(color: AppTheme.primary),
                  ),
                ),
              ],
            ),
          ),
        // Task templates
        ...templates.asMap().entries.map((entry) {
          final index = entry.key;
          final template = entry.value;
          final isSelected = _selectedTemplates.contains(template['id']);
          return GestureDetector(
            onTap: () => setState(() {
              if (isSelected) {
                _selectedTemplates.remove(template['id']);
              } else {
                _selectedTemplates.add(template['id']);
              }
              // Update points/difficulty to last selected template
              if (_selectedTemplates.isNotEmpty) {
                final lastTemplate = _taskTemplates.firstWhere(
                  (t) => t['id'] == _selectedTemplates.last,
                  orElse: () => template,
                );
                _points = lastTemplate['default_points'] ?? lastTemplate['points'] ?? 20;
                _difficulty = lastTemplate['difficulty'] ?? 'medium';
              }
            }),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.primary.withOpacity(0.1) : Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : Theme.of(context).dividerColor,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  // Checkbox
                  Container(
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppTheme.primary : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isSelected ? AppTheme.primary : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      color: AppTheme.getZoneColor(template['zone']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(template['icon'] ?? '✨', style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          template['title'] ?? 'Task',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          (template['zone'] as String? ?? 'general').toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.getZoneColor(template['zone']),
                            fontWeight: FontWeight.w500,
                          ),
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
                          '${template['default_points'] ?? template['points'] ?? 20}',
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
        ).animate().fadeIn(delay: Duration(milliseconds: 200 + index * 50)).slideX(begin: 0.1);
      }),
      ],
    );
  }

  Widget _buildPointsSlider() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Points'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_points pts',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _points.toDouble(),
            min: 5,
            max: 100,
            divisions: 19,
            onChanged: (value) => setState(() => _points = value.round()),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildDifficultySelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Difficulty'),
          const SizedBox(height: 12),
          Row(
            children: ['easy', 'medium', 'hard'].map((diff) {
              final isSelected = _difficulty == diff;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _difficulty = diff),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.getDifficultyColor(diff)
                          : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppTheme.getDifficultyColor(diff),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        diff.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.getDifficultyColor(diff),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 450.ms);
  }

  Widget _buildVerificationToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Require Photo Verification',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Child must submit a photo for approval',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _requiresVerification,
            onChanged: (value) => setState(() => _requiresVerification = value),
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 500.ms);
  }

  Widget _buildAssignButton() {
    final canAssign = _selectedChild != null && _selectedTemplates.isNotEmpty;
    final taskCount = _selectedTemplates.length;
    
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canAssign && !_isSubmitting ? _assignTasks : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                taskCount > 1 ? 'Assign $taskCount Tasks' : 'Assign Task',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Future<void> _assignTasks() async {
    if (_selectedChild == null || _selectedTemplates.isEmpty) return;

    setState(() => _isSubmitting = true);

    try {
      final authProvider = context.read<AuthProvider>();
      final taskProvider = context.read<TaskProvider>();
      
      int successCount = 0;
      int failCount = 0;

      debugPrint('AssignTask: Assigning ${_selectedTemplates.length} tasks to child: $_selectedChild');
      
      // Create a task for each selected template
      for (final templateId in _selectedTemplates) {
        final template = _taskTemplates.firstWhere(
          (t) => t['id'] == templateId,
          orElse: () => {},
        );

        if (template.isEmpty) continue;

        // Use template's default points if creating multiple, otherwise use slider
        final useTemplatePoints = _selectedTemplates.length > 1;
        final taskPoints = useTemplatePoints 
            ? (template['default_points'] ?? template['points'] ?? 20)
            : _points;

        final success = await taskProvider.createTask(
          childId: _selectedChild!,
          title: template['title'] ?? 'Task',
          zone: template['zone'] ?? 'general',
          points: taskPoints,
          description: template['description'],
          difficulty: template['difficulty'] ?? _difficulty,
          icon: template['icon'] ?? '✨',
          requiresVerification: _requiresVerification,
          templateId: template['id'],
          createdBy: authProvider.user!.id,
        );

        if (success) {
          successCount++;
        } else {
          failCount++;
        }
      }

      if (mounted) {
        if (successCount > 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                successCount == 1 
                    ? '✅ Task assigned successfully!'
                    : '✅ $successCount tasks assigned successfully!',
              ),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
          context.pop();
        } else if (failCount > 0) {
          throw Exception('Failed to create tasks');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}
