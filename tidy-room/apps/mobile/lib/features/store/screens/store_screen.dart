import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_theme.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _availablePoints = 1250;

  final List<Map<String, dynamic>> _themes = [
    {'id': '1', 'name': 'Space Adventure', 'price': 500, 'emoji': '🚀', 'owned': false},
    {'id': '2', 'name': 'Ocean Paradise', 'price': 500, 'emoji': '🌊', 'owned': true},
    {'id': '3', 'name': 'Jungle Safari', 'price': 500, 'emoji': '🌴', 'owned': false},
    {'id': '4', 'name': 'Gaming Zone', 'price': 750, 'emoji': '🎮', 'owned': false},
    {'id': '5', 'name': 'Candy Land', 'price': 600, 'emoji': '🍬', 'owned': false},
  ];

  final List<Map<String, dynamic>> _decorations = [
    {'id': '1', 'name': 'Star Poster', 'price': 50, 'emoji': '⭐', 'category': 'wall', 'owned': true},
    {'id': '2', 'name': 'Rainbow Sticker', 'price': 75, 'emoji': '🌈', 'category': 'wall', 'owned': false},
    {'id': '3', 'name': 'Cozy Rug', 'price': 150, 'emoji': '🟫', 'category': 'furniture', 'owned': false},
    {'id': '4', 'name': 'Bean Bag', 'price': 200, 'emoji': '🛋️', 'category': 'furniture', 'owned': false},
    {'id': '5', 'name': 'Desk Lamp', 'price': 100, 'emoji': '💡', 'category': 'furniture', 'owned': true},
    {'id': '6', 'name': 'Sparkle Effect', 'price': 200, 'emoji': '✨', 'category': 'effect', 'owned': false},
    {'id': '7', 'name': 'Lazy Cat', 'price': 300, 'emoji': '😺', 'category': 'pet', 'owned': false},
    {'id': '8', 'name': 'Happy Dog', 'price': 300, 'emoji': '🐕', 'category': 'pet', 'owned': false},
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
                    'Rewards Store',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
                tabs: const [
                  Tab(text: '🎨 Themes'),
                  Tab(text: '🛋️ Decorations'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildThemesGrid(),
                  _buildDecorationsGrid(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemesGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _themes.length,
      itemBuilder: (context, index) {
        final theme = _themes[index];
        return _buildItemCard(
          name: theme['name'],
          emoji: theme['emoji'],
          price: theme['price'],
          owned: theme['owned'],
          onPurchase: () => _purchaseItem(theme, 'theme'),
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).scale(
          begin: const Offset(0.8, 0.8),
        );
      },
    );
  }

  Widget _buildDecorationsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: _decorations.length,
      itemBuilder: (context, index) {
        final decoration = _decorations[index];
        return _buildItemCard(
          name: decoration['name'],
          emoji: decoration['emoji'],
          price: decoration['price'],
          owned: decoration['owned'],
          category: decoration['category'],
          onPurchase: () => _purchaseItem(decoration, 'decoration'),
        ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).scale(
          begin: const Offset(0.8, 0.8),
        );
      },
    );
  }

  Widget _buildItemCard({
    required String name,
    required String emoji,
    required int price,
    required bool owned,
    String? category,
    required VoidCallback onPurchase,
  }) {
    final canAfford = _availablePoints >= price;

    return Container(
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
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Center(
                child: Stack(
                  children: [
                    Text(
                      emoji,
                      style: const TextStyle(fontSize: 60),
                    ),
                    if (owned)
                      Positioned(
                        top: -5,
                        right: -5,
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
                  ],
                ),
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
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                owned
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Owned',
                          style: TextStyle(
                            color: AppTheme.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: canAfford ? onPurchase : null,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '$price',
                                style: TextStyle(
                                  color: canAfford ? Colors.white : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _purchaseItem(Map<String, dynamic> item, String type) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(item['emoji'], style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 8),
            const Expanded(child: Text('Confirm Purchase')),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Buy "${item['name']}" for ${item['price']} points?'),
            const SizedBox(height: 8),
            Text(
              'You have $_availablePoints points',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _completePurchase(item, type);
            },
            child: const Text('Buy'),
          ),
        ],
      ),
    );
  }

  void _completePurchase(Map<String, dynamic> item, String type) {
    setState(() {
      _availablePoints -= item['price'] as int;
      item['owned'] = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(item['emoji'], style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text('${item['name']} purchased!'),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
