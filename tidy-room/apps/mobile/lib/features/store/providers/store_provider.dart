import 'package:flutter/material.dart';
import '../../../main.dart';

class StoreProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _themes = [];
  List<Map<String, dynamic>> _decorations = [];
  List<Map<String, dynamic>> _ownedItems = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get themes => _themes;
  List<Map<String, dynamic>> get decorations => _decorations;
  List<Map<String, dynamic>> get ownedItems => _ownedItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load themes from database
  Future<void> fetchThemes() async {
    try {
      final response = await supabase
          .from('tidy_themes')
          .select()
          .order('price');
      
      _themes = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching themes: $e');
    }
  }

  /// Load decorations from database
  Future<void> fetchDecorations() async {
    try {
      final response = await supabase
          .from('tidy_decorations')
          .select()
          .order('price');
      
      _decorations = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching decorations: $e');
    }
  }

  /// Load owned items for a child
  Future<void> fetchOwnedItems(String childId) async {
    try {
      final response = await supabase
          .from('tidy_inventory')
          .select('*, theme:tidy_themes(*), decoration:tidy_decorations(*)')
          .eq('child_id', childId);
      
      _ownedItems = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching inventory: $e');
    }
  }

  /// Check if child owns a specific item
  bool ownsItem(String itemId, String itemType) {
    return _ownedItems.any((item) => 
        item['item_id'] == itemId && item['item_type'] == itemType);
  }

  /// Purchase an item
  Future<bool> purchaseItem({
    required String childId,
    required String itemId,
    required String itemType,
    required int price,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Get current child points
      final childResponse = await supabase
          .from('tidy_children')
          .select('available_points')
          .eq('id', childId)
          .single();
      
      final availablePoints = childResponse['available_points'] as int? ?? 0;
      
      if (availablePoints < price) {
        _error = 'Not enough points!';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Deduct points
      await supabase.from('tidy_children').update({
        'available_points': availablePoints - price,
      }).eq('id', childId);

      // Add to inventory
      await supabase.from('tidy_inventory').insert({
        'child_id': childId,
        'item_id': itemId,
        'item_type': itemType,
      });

      // Log the purchase
      await supabase.from('tidy_points_log').insert({
        'child_id': childId,
        'points': -price,
        'balance_after': availablePoints - price,
        'type': 'purchase',
        'description': 'Purchased $itemType',
      });

      // Refresh owned items
      await fetchOwnedItems(childId);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error purchasing item: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Equip/unequip an item
  Future<void> equipItem(String childId, String itemId, String itemType, bool equip) async {
    try {
      await supabase.from('tidy_inventory').update({
        'is_equipped': equip,
      }).eq('child_id', childId)
        .eq('item_id', itemId)
        .eq('item_type', itemType);
      
      await fetchOwnedItems(childId);
    } catch (e) {
      debugPrint('Error equipping item: $e');
    }
  }

  /// Load all store data
  Future<void> loadStoreData(String childId) async {
    _isLoading = true;
    notifyListeners();

    await Future.wait([
      fetchThemes(),
      fetchDecorations(),
      fetchOwnedItems(childId),
    ]);

    _isLoading = false;
    notifyListeners();
  }
}
