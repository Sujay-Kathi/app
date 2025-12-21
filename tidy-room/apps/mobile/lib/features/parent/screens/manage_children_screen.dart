import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../auth/providers/auth_provider.dart';

class ManageChildrenScreen extends StatefulWidget {
  const ManageChildrenScreen({super.key});

  @override
  State<ManageChildrenScreen> createState() => _ManageChildrenScreenState();
}

class _ManageChildrenScreenState extends State<ManageChildrenScreen> {
  List<Map<String, dynamic>> _children = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authProvider = context.read<AuthProvider>();
      final profile = authProvider.profile;
      
      if (profile != null && profile['family_id'] != null) {
        final response = await supabase
            .from('tidy_children')
            .select('*, room:tidy_rooms(*), streak:tidy_streaks(*)')
            .eq('family_id', profile['family_id'])
            .order('created_at');

        setState(() {
          _children = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      } else {
        setState(() {
          _children = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _showAddChildDialog() {
    final nameController = TextEditingController();
    final ageController = TextEditingController();
    final pinController = TextEditingController();
    String selectedAvatar = '👦';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Text(
                      'Add New Child 👶',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Avatar Selection
                const Text('Select Avatar', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['👦', '👧', '🧒', '👶', '🧑', '👱', '🐱', '🐶', '🦊', '🐼', '🦁', '🐰']
                        .map((avatar) => GestureDetector(
                              onTap: () => setModalState(() => selectedAvatar = avatar),
                              child: Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: selectedAvatar == avatar
                                      ? AppTheme.primary.withOpacity(0.2)
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: selectedAvatar == avatar
                                      ? Border.all(color: AppTheme.primary, width: 2)
                                      : null,
                                ),
                                child: Center(
                                  child: Text(avatar, style: const TextStyle(fontSize: 26)),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
                const SizedBox(height: 20),

                // Name Input
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Child\'s Name',
                    hintText: 'Enter name',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Age Input
                TextField(
                  controller: ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    hintText: 'Enter age',
                    prefixIcon: const Icon(Icons.cake_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // PIN Input
                TextField(
                  controller: pinController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Login PIN (4 digits)',
                    hintText: 'Enter 4-digit PIN',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Add Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (nameController.text.isEmpty ||
                          ageController.text.isEmpty ||
                          pinController.text.length != 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill all fields correctly'),
                            backgroundColor: AppTheme.error,
                          ),
                        );
                        return;
                      }

                      await _addChild(
                        name: nameController.text,
                        age: int.tryParse(ageController.text) ?? 6,
                        avatar: selectedAvatar,
                        pin: pinController.text,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Child',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addChild({
    required String name,
    required int age,
    required String avatar,
    required String pin,
  }) async {
    try {
      final authProvider = context.read<AuthProvider>();
      final profile = authProvider.profile;
      
      if (profile == null || profile['family_id'] == null) {
        throw Exception('No family found');
      }

      // Create child
      final childResponse = await supabase.from('tidy_children').insert({
        'family_id': profile['family_id'],
        'name': name,
        'age': age,
        'avatar_emoji': avatar,
        'pin_code': pin,
      }).select().single();

      // Create room for child
      await supabase.from('tidy_rooms').insert({
        'child_id': childResponse['id'],
        'cleanliness_score': 50,
        'zone_bed': 50,
        'zone_floor': 50,
        'zone_desk': 50,
        'zone_closet': 50,
        'zone_general': 50,
      });

      // Create streak for child
      await supabase.from('tidy_streaks').insert({
        'child_id': childResponse['id'],
        'current_streak': 0,
        'longest_streak': 0,
      });

      // Refresh list
      await _fetchChildren();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$name added successfully! 🎉'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _deleteChild(String childId, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Child?'),
        content: Text('Are you sure you want to remove $name? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await supabase.from('tidy_children').delete().eq('id', childId);
        await _fetchChildren();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$name removed'),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: AppTheme.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Children'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchChildren,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _children.isEmpty
                  ? _buildEmptyState()
                  : _buildChildrenList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddChildDialog,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Add Child', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('👨‍👩‍👧‍👦', style: TextStyle(fontSize: 80)),
          const SizedBox(height: 24),
          const Text(
            'No Children Yet',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first child to get started!',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _showAddChildDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add Your First Child'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildChildrenList() {
    return RefreshIndicator(
      onRefresh: _fetchChildren,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _children.length,
        itemBuilder: (context, index) {
          final child = _children[index];
          return _buildChildCard(child).animate().fadeIn(
                delay: Duration(milliseconds: 100 * index),
              ).slideX(begin: 0.1);
        },
      ),
    );
  }

  Widget _buildChildCard(Map<String, dynamic> child) {
    final room = child['room'];
    final streak = child['streak'];
    final cleanliness = room?['cleanliness_score'] ?? 50;
    final currentStreak = streak?['current_streak'] ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                child['avatar_emoji'] ?? '👦',
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child['name'] ?? 'Child',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Age ${child['age'] ?? '?'} • Level ${child['current_level'] ?? 1}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // Cleanliness
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.getCleanlinessColor(cleanliness).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Text('🏠', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            '$cleanliness%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.getCleanlinessColor(cleanliness),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Streak
                    if (currentStreak > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 12)),
                            const SizedBox(width: 4),
                            Text(
                              '$currentStreak',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Actions
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 20),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
                onTap: () {
                  // TODO: Edit child
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.pin, size: 20),
                    SizedBox(width: 8),
                    Text('Reset PIN'),
                  ],
                ),
                onTap: () {
                  // TODO: Reset PIN
                },
              ),
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.delete, color: AppTheme.error, size: 20),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: AppTheme.error)),
                  ],
                ),
                onTap: () => _deleteChild(child['id'], child['name'] ?? 'Child'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
