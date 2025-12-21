import 'package:flutter/material.dart';
import '../../../main.dart';

class RoomProvider extends ChangeNotifier {
  Map<String, dynamic>? _room;
  Map<String, dynamic>? _theme;
  List<Map<String, dynamic>> _equippedDecorations = [];
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get room => _room;
  Map<String, dynamic>? get theme => _theme;
  List<Map<String, dynamic>> get equippedDecorations => _equippedDecorations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get cleanlinessScore => _room?['cleanliness_score'] ?? 0;
  int get zoneBed => _room?['zone_bed'] ?? 0;
  int get zoneFloor => _room?['zone_floor'] ?? 0;
  int get zoneDesk => _room?['zone_desk'] ?? 0;
  int get zoneCloset => _room?['zone_closet'] ?? 0;
  int get zoneGeneral => _room?['zone_general'] ?? 0;

  String get cleanlinessState {
    final score = cleanlinessScore;
    if (score >= 90) return 'pristine';
    if (score >= 70) return 'clean';
    if (score >= 40) return 'messy';
    if (score >= 20) return 'very_messy';
    return 'disaster';
  }

  Future<void> fetchRoom(String childId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await supabase
          .from('tidy_rooms')
          .select('*, theme:tidy_themes(*)')
          .eq('child_id', childId)
          .maybeSingle();

      if (response != null) {
        _room = response;
        _theme = response['theme'];
      } else {
        // Set default room values if room doesn't exist
        _room = {
          'cleanliness_score': 50,
          'zone_bed': 50,
          'zone_floor': 50,
          'zone_desk': 50,
          'zone_closet': 50,
          'zone_general': 50,
        };
        _theme = null;
        debugPrint('No room found for child $childId, using defaults');
      }

      // Fetch equipped decorations (won't fail if empty)
      final decorations = await supabase
          .from('tidy_inventory')
          .select('*, decoration:tidy_decorations(*)')
          .eq('child_id', childId)
          .eq('item_type', 'decoration')
          .eq('is_equipped', true);

      _equippedDecorations = List<Map<String, dynamic>>.from(decorations);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching room: $e');
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateZone(String childId, String zone, int score) async {
    try {
      final zoneColumn = 'zone_$zone';
      
      await supabase
          .from('tidy_rooms')
          .update({zoneColumn: score})
          .eq('child_id', childId);

      // Refresh room data
      await fetchRoom(childId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> equipDecoration(String childId, String inventoryId, Map<String, dynamic> position) async {
    try {
      await supabase
          .from('tidy_inventory')
          .update({
            'is_equipped': true,
            'position': position,
          })
          .eq('id', inventoryId);

      await fetchRoom(childId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> unequipDecoration(String inventoryId, String childId) async {
    try {
      await supabase
          .from('tidy_inventory')
          .update({'is_equipped': false})
          .eq('id', inventoryId);

      await fetchRoom(childId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> changeTheme(String childId, String themeId) async {
    try {
      await supabase
          .from('tidy_rooms')
          .update({'theme_id': themeId})
          .eq('child_id', childId);

      await fetchRoom(childId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
