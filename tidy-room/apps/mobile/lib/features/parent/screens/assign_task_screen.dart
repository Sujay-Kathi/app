import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  String? _selectedChild;
  String? _selectedZone;
  String? _selectedTemplate;
  int _points = 20;
  String _difficulty = 'medium';
  bool _requiresVerification = false;

  final List<Map<String, dynamic>> _children = [
    {'id': '1', 'name': 'Arjun', 'emoji': '👦'},
    {'id': '2', 'name': 'Priya', 'emoji': '👧'},
  ];

  final List<Map<String, dynamic>> _zones = [
    {'id': 'bed', 'name': 'Bed Zone', 'emoji': '🛏️', 'color': AppTheme.zoneBed},
    {'id': 'floor', 'name': 'Floor Zone', 'emoji': '🧹', 'color': AppTheme.zoneFloor},
    {'id': 'desk', 'name': 'Desk Zone', 'emoji': '📚', 'color': AppTheme.zoneDesk},
    {'id': 'closet', 'name': 'Closet Zone', 'emoji': '👕', 'color': AppTheme.zoneCloset},
    {'id': 'general', 'name': 'General', 'emoji': '✨', 'color': AppTheme.zoneGeneral},
  ];

  final List<Map<String, dynamic>> _templates = [
    {'id': '1', 'title': 'Make the Bed', 'zone': 'bed', 'points': 15, 'icon': '🛏️'},
    {'id': '2', 'title': 'Pick Up Toys', 'zone': 'floor', 'points': 20, 'icon': '🧸'},
    {'id': '3', 'title': 'Clear Desk Clutter', 'zone': 'desk', 'points': 25, 'icon': '📚'},
    {'id': '4', 'title': 'Hang Up Clothes', 'zone': 'closet', 'points': 30, 'icon': '👔'},
    {'id': '5', 'title': 'Dust Surfaces', 'zone': 'general', 'points': 30, 'icon': '🪥'},
    {'id': '6', 'title': 'Empty Trash Bin', 'zone': 'general', 'points': 10, 'icon': '🗑️'},
    {'id': '7', 'title': 'Vacuum Floor', 'zone': 'floor', 'points': 50, 'icon': '🧹'},
    {'id': '8', 'title': 'Organize Bookshelf', 'zone': 'desk', 'points': 35, 'icon': '📖'},
  ];

  List<Map<String, dynamic>> get _filteredTemplates {
    if (_selectedZone == null) return _templates;
    return _templates.where((t) => t['zone'] == _selectedZone).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assign Task'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Step 1: Select Child
            _buildSectionTitle('1. Select Child'),
            const SizedBox(height: 12),
            Row(
              children: _children.map((child) {
                final isSelected = _selectedChild == child['id'];
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedChild = child['id']),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primary.withOpacity(0.1) : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(child['emoji'], style: const TextStyle(fontSize: 32)),
                          const SizedBox(height: 8),
                          Text(
                            child['name'],
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isSelected ? AppTheme.primary : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ).animate().fadeIn().slideX(begin: 0.1),

            const SizedBox(height: 24),

            // Step 2: Select Zone
            _buildSectionTitle('2. Select Zone'),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _zones.map((zone) {
                  final isSelected = _selectedZone == zone['id'];
                  return GestureDetector(
                    onTap: () => setState(() {
                      _selectedZone = zone['id'];
                      _selectedTemplate = null;
                    }),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? zone['color'] : Colors.grey.shade100,
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
                              color: isSelected ? Colors.white : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),

            const SizedBox(height: 24),

            // Step 3: Select Task Template
            _buildSectionTitle('3. Choose Task'),
            const SizedBox(height: 12),
            ..._filteredTemplates.asMap().entries.map((entry) {
              final index = entry.key;
              final template = entry.value;
              final isSelected = _selectedTemplate == template['id'];
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedTemplate = template['id'];
                  _points = template['points'];
                  _selectedZone = template['zone'];
                }),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected ? AppTheme.primary.withOpacity(0.1) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          color: AppTheme.getZoneColor(template['zone']).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(template['icon'], style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              template['title'],
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            Text(
                              template['zone'].toString().toUpperCase(),
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
                              '${template['points']}',
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

            const SizedBox(height: 24),

            // Step 4: Customize
            _buildSectionTitle('4. Customize (Optional)'),
            const SizedBox(height: 12),
            
            // Points Slider
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
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
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 12),

            // Difficulty
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
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
                                  : Colors.white,
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
            ).animate().fadeIn(delay: 450.ms),

            const SizedBox(height: 12),

            // Requires Verification
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
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
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 32),

            // Assign Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedChild != null && _selectedTemplate != null
                    ? _assignTask
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Assign Task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
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

  void _assignTask() {
    // TODO: Implement with provider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Task assigned successfully!'),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    context.pop();
  }
}
