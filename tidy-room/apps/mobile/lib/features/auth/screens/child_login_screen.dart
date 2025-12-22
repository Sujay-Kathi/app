import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../child/providers/child_provider.dart';
import '../providers/auth_provider.dart';

class ChildLoginScreen extends StatefulWidget {
  const ChildLoginScreen({super.key});

  @override
  State<ChildLoginScreen> createState() => _ChildLoginScreenState();
}

class _ChildLoginScreenState extends State<ChildLoginScreen> {
  String _pin = '';
  bool _isLoading = false;
  List<Map<String, dynamic>> _children = [];
  int _selectedChildIndex = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    setState(() => _isLoading = true);

    try {
      // First, check if there's a cached family_id from a parent login on this device
      final cachedFamilyId = await AuthProvider.getCachedFamilyId();
      debugPrint('Child login: cached family_id = $cachedFamilyId');
      
      List<Map<String, dynamic>> allChildren = [];
      
      // Try RPC function first (works for unauthenticated users)
      try {
        final response = await supabase.rpc('get_children_for_login');
        allChildren = List<Map<String, dynamic>>.from(response ?? []);
      } catch (e) {
        debugPrint('RPC failed: $e, trying direct query...');
        // Fallback to direct query (for authenticated users)
        try {
          final fallbackResponse = await supabase
              .from('tidy_children')
              .select('id, name, avatar_emoji, family_id')
              .order('name');
          allChildren = List<Map<String, dynamic>>.from(fallbackResponse);
        } catch (e2) {
          debugPrint('Direct query also failed: $e2');
        }
      }
      
      // Filter by cached family_id if available
      if (cachedFamilyId != null && allChildren.isNotEmpty) {
        allChildren = allChildren
            .where((child) => child['family_id'] == cachedFamilyId)
            .toList();
        debugPrint('Filtered to ${allChildren.length} children from family');
      }
      
      if (mounted) {
        setState(() {
          _children = allChildren;
          _isLoading = false;
          if (_children.isEmpty) {
            _error = cachedFamilyId != null 
                ? 'No children added yet. Ask a parent to add you!'
                : 'No children found. A parent needs to log in first and add a child.';
          }
        });
      }
    } catch (e) {
      debugPrint('Error fetching children: $e');
      if (mounted) {
        setState(() {
          _error = 'Could not load children. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _onNumberPressed(String number) {
    if (_pin.length < 4) {
      setState(() {
        _pin += number;
      });

      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
      });
    }
  }

  Future<void> _verifyPin() async {
    if (_children.isEmpty) return;
    
    setState(() => _isLoading = true);

    try {
      final selectedChild = _children[_selectedChildIndex];
      final childId = selectedChild['id'];
      
      Map<String, dynamic>? verifiedChild;

      // Try RPC function first (for unauthenticated users)
      try {
        final response = await supabase.rpc('verify_child_pin', params: {
          'p_child_id': childId,
          'p_pin': _pin,
        });
        
        final results = List<Map<String, dynamic>>.from(response ?? []);
        if (results.isNotEmpty) {
          verifiedChild = results.first;
        }
      } catch (rpcError) {
        debugPrint('RPC verification failed: $rpcError, trying direct query...');
        
        // Fallback to direct query (for authenticated users or if RPC not set up)
        try {
          final response = await supabase
              .from('tidy_children')
              .select('id, name, avatar_emoji, family_id, current_level, total_points, available_points')
              .eq('id', childId)
              .eq('pin_code', _pin)
              .maybeSingle();
          
          verifiedChild = response;
        } catch (queryError) {
          debugPrint('Direct query also failed: $queryError');
        }
      }

      if (!mounted) return;

      if (verifiedChild != null) {
        // Set child in provider
        debugPrint('Child login successful! Child ID: $childId');
        debugPrint('Child data: $verifiedChild');
        context.read<ChildProvider>().setChild(childId, verifiedChild);
        
        // Navigate to room
        context.go('/room');
      } else {
        setState(() {
          _pin = '';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wrong PIN! Try again. 🔒'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error verifying PIN: $e');
      if (mounted) {
        setState(() {
          _pin = '';
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFBBF24),
              Color(0xFFF97316),
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
                    IconButton(
                      onPressed: () => context.go('/login'),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'Kid Login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Child Avatars
              if (_isLoading && _children.isEmpty)
                const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              else if (_children.isEmpty)
                Center(
                  child: Column(
                    children: [
                      const Text(
                        '😢',
                        style: TextStyle(fontSize: 60),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No kids found.\nAsk a parent to add you!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    itemCount: _children.length,
                    itemBuilder: (context, index) {
                      final child = _children[index];
                      final isSelected = index == _selectedChildIndex;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedChildIndex = index;
                            _pin = '';
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.accent.withOpacity(0.2)
                                      : Colors.grey.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    child['avatar_emoji'] ?? '👦',
                                    style: const TextStyle(fontSize: 28),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                child['name'] ?? 'Kid',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? AppTheme.primary : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ).animate().fadeIn().slideY(begin: -0.3),

              const SizedBox(height: 40),

              // PIN Display
              if (_children.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Enter your secret PIN',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(4, (index) {
                          final isFilled = index < _pin.length;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: isFilled ? Colors.white : Colors.transparent,
                              border: Border.all(color: Colors.white, width: 2),
                              shape: BoxShape.circle,
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 200.ms).scale(),

              const Spacer(),

              // Number Pad
              if (_children.isNotEmpty)
                if (_isLoading)
                  const CircularProgressIndicator(color: Colors.white)
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: GridView.count(
                      shrinkWrap: true,
                      crossAxisCount: 3,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        ...List.generate(9, (index) {
                          return _buildNumberButton('${index + 1}');
                        }),
                        const SizedBox(), // Empty space
                        _buildNumberButton('0'),
                        _buildBackspaceButton(),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNumberButton(String number) {
    return GestureDetector(
      onTap: () => _onNumberPressed(number),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            number,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceButton() {
    return GestureDetector(
      onTap: _onBackspace,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.backspace_outlined,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }
}
