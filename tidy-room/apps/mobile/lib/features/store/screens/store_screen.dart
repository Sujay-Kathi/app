import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../child/providers/child_provider.dart';
import '../../room/providers/room_provider.dart';
import '../providers/store_provider.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  int _availablePoints = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    final childId = context.read<ChildProvider>().childId;
    if (childId == null) return;

    setState(() => _isLoading = true);

    try {
      await context.read<StoreProvider>().loadStoreData(childId);
      
      // Get available points
      final childData = await supabase
          .from('tidy_children')
          .select('available_points')
          .eq('id', childId)
          .single();
      
      setState(() {
        _availablePoints = childData['available_points'] ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading store: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.primary.withOpacity(0.1),
            Theme.of(context).scaffoldBackgroundColor,
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.primary, AppTheme.primaryDark],
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.store_rounded, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rewards Store',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Spend your points!',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppTheme.accent, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accent.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '$_availablePoints',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ).animate(onPlay: (c) => c.repeat()).shimmer(
                    duration: 3000.ms,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ],
              ),
            ),

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
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                tabs: const [
                  Tab(text: '🎨 Themes'),
                  Tab(text: '🛋️ Decor'),
                  Tab(text: '🐾 Pets'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Consumer<StoreProvider>(
                      builder: (context, storeProvider, _) {
                        return TabBarView(
                          controller: _tabController,
                          children: [
                            _buildThemesGrid(storeProvider),
                            _buildDecorationsGrid(storeProvider),
                            _buildPetsGrid(storeProvider),
                          ],
                        );
                      },
                    ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemesGrid(StoreProvider storeProvider) {
    final themes = storeProvider.themes;
    
    if (themes.isEmpty) {
      return _buildEmptyState('🎨', 'No themes available');
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: themes.length,
        itemBuilder: (context, index) {
          final theme = themes[index];
          final owned = storeProvider.ownsItem(theme['id'], 'theme') || 
                        (theme['is_default'] == true);
          return _buildItemCard(
            id: theme['id'],
            name: theme['name'] ?? 'Theme',
            emoji: _getThemeEmoji(theme['name'] ?? ''),
            price: theme['price'] ?? 0,
            owned: owned,
            type: 'theme',
            description: theme['description'],
          ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).scale(
            begin: const Offset(0.8, 0.8),
          );
        },
      ),
    );
  }

  Widget _buildDecorationsGrid(StoreProvider storeProvider) {
    final decorations = storeProvider.decorations
        .where((d) => d['category'] != 'pet')
        .toList();
    
    if (decorations.isEmpty) {
      return _buildEmptyState('🛋️', 'No decorations available');
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: decorations.length,
        itemBuilder: (context, index) {
          final decoration = decorations[index];
          final owned = storeProvider.ownsItem(decoration['id'], 'decoration');
          return _buildItemCard(
            id: decoration['id'],
            name: decoration['name'] ?? 'Decoration',
            emoji: decoration['icon'] ?? '🎨',
            price: decoration['price'] ?? 0,
            owned: owned,
            type: 'decoration',
            description: decoration['description'],
            category: decoration['category'],
          ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).scale(
            begin: const Offset(0.8, 0.8),
          );
        },
      ),
    );
  }

  Widget _buildPetsGrid(StoreProvider storeProvider) {
    final pets = storeProvider.decorations
        .where((d) => d['category'] == 'pet')
        .toList();
    
    if (pets.isEmpty) {
      return _buildEmptyState('🐾', 'No pets available yet');
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: pets.length,
        itemBuilder: (context, index) {
          final pet = pets[index];
          final owned = storeProvider.ownsItem(pet['id'], 'decoration');
          return _buildItemCard(
            id: pet['id'],
            name: pet['name'] ?? 'Pet',
            emoji: pet['icon'] ?? '🐾',
            price: pet['price'] ?? 0,
            owned: owned,
            type: 'decoration',
            description: pet['description'],
            isPet: true,
          ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).scale(
            begin: const Offset(0.8, 0.8),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(String emoji, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  String _getThemeEmoji(String themeName) {
    final emojiMap = {
      'Default': '🏠',
      'Space Adventure': '🚀',
      'Ocean Paradise': '🌊',
      'Jungle Safari': '🌴',
      'Gaming Zone': '🎮',
      'Candy Land': '🍬',
      'Arctic Ice': '❄️',
    };
    return emojiMap[themeName] ?? '🎨';
  }

  Widget _buildItemCard({
    required String id,
    required String name,
    required String emoji,
    required int price,
    required bool owned,
    required String type,
    String? description,
    String? category,
    bool isPet = false,
  }) {
    final canAfford = _availablePoints >= price;

    return GestureDetector(
      onTap: () => _showItemDetail(
        id: id,
        name: name,
        emoji: emoji,
        price: price,
        owned: owned,
        type: type,
        description: description,
        canAfford: canAfford,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: owned ? AppTheme.success.withOpacity(0.5) : Colors.grey.shade200,
            width: owned ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Emoji Display
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      (isPet ? Colors.pink : AppTheme.primary).withOpacity(0.1),
                      (isPet ? Colors.purple : AppTheme.secondary).withOpacity(0.05),
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        emoji,
                        style: const TextStyle(fontSize: 55),
                      ).animate(onPlay: isPet ? (c) => c.repeat(reverse: true) : null)
                        .scale(
                          begin: const Offset(1, 1),
                          end: isPet ? const Offset(1.1, 1.1) : const Offset(1, 1),
                          duration: 1500.ms,
                        ),
                    ),
                    if (owned)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppTheme.success,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    if (category != null && !isPet)
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getCategoryLabel(category),
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  owned
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            '✓ Owned',
                            style: TextStyle(
                              color: AppTheme.success,
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        )
                      : Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: canAfford ? AppTheme.primary : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star,
                                color: canAfford ? Colors.white : Colors.grey,
                                size: 12,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$price',
                                style: TextStyle(
                                  color: canAfford ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
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

  String _getCategoryLabel(String category) {
    final labels = {
      'wall': '🖼️ Wall',
      'furniture': '🪑 Furniture',
      'effect': '✨ Effect',
      'accessory': '🎀 Accessory',
    };
    return labels[category] ?? category;
  }

  void _showItemDetail({
    required String id,
    required String name,
    required String emoji,
    required int price,
    required bool owned,
    required String type,
    String? description,
    required bool canAfford,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Item preview
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 60)),
              ),
            ),
            const SizedBox(height: 16),
            
            Text(
              name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            
            if (owned)
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, color: AppTheme.success),
                        SizedBox(width: 8),
                        Text(
                          'You own this!',
                          style: TextStyle(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (type == 'theme') ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _applyTheme(id, name),
                        icon: const Icon(Icons.color_lens, color: Colors.white),
                        label: const Text(
                          'Apply Theme',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              )
            else ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.star, color: AppTheme.accent, size: 24),
                  const SizedBox(width: 8),
                  Text(
                    '$price points',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'You have $_availablePoints points',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: canAfford ? () => _purchaseItem(id, name, emoji, price, type) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: canAfford ? AppTheme.primary : Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    canAfford ? 'Buy Now! 🛒' : 'Not Enough Points 😢',
                    style: TextStyle(
                      color: canAfford ? Colors.white : Colors.grey.shade600,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _purchaseItem(String id, String name, String emoji, int price, String type) async {
    Navigator.pop(context);
    
    final childId = context.read<ChildProvider>().childId;
    if (childId == null) return;

    final success = await context.read<StoreProvider>().purchaseItem(
      childId: childId,
      itemId: id,
      itemType: type,
      price: price,
    );

    if (success) {
      setState(() {
        _availablePoints -= price;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text('$name purchased! 🎉'),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<StoreProvider>().error ?? 'Purchase failed'),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _applyTheme(String themeId, String themeName) async {
    Navigator.pop(context);
    
    final childId = context.read<ChildProvider>().childId;
    if (childId == null) return;

    try {
      // Import RoomProvider
      final roomProvider = context.read<RoomProvider>();
      final success = await roomProvider.changeTheme(childId, themeId);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Text('🎨', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Text('$themeName applied to your room! ✨'),
              ],
            ),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to apply theme: $e'),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
