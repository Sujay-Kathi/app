import 'package:flutter/material.dart';
import '../../../main.dart';

/// Manages the currently logged-in child's data
/// This is the central source of truth for the child's ID and basic info
class ChildProvider extends ChangeNotifier {
  String? _childId;
  Map<String, dynamic>? _childData;
  Map<String, dynamic>? _familyData;
  List<Map<String, dynamic>> _children = []; // All children in family
  bool _isLoading = false;
  String? _error;

  String? get childId => _childId;
  Map<String, dynamic>? get childData => _childData;
  Map<String, dynamic>? get familyData => _familyData;
  List<Map<String, dynamic>> get children => _children;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Convenience getters
  String get name => _childData?['name'] ?? 'Unknown';
  String get avatarEmoji => _childData?['avatar_emoji'] ?? '👦';
  int get totalPoints => _childData?['total_points'] ?? 0;
  int get availablePoints => _childData?['available_points'] ?? 0;
  int get level => _childData?['current_level'] ?? 1;
  int get totalXp => _childData?['total_xp'] ?? 0;

  /// Set the current child (called after login)
  void setChild(String childId, Map<String, dynamic> childData) {
    _childId = childId;
    _childData = childData;
    notifyListeners();
  }

  /// Fetch child data by ID
  Future<void> fetchChild(String childId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await supabase
          .from('tidy_children')
          .select('*, family:tidy_families(*)')
          .eq('id', childId)
          .single();

      _childId = childId;
      _childData = response;
      _familyData = response['family'];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch all children for a family (for parent view)
  Future<void> fetchFamilyChildren(String familyId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await supabase
          .from('tidy_children')
          .select('*, streak:tidy_streaks(*), room:tidy_rooms(*)')
          .eq('family_id', familyId)
          .order('created_at');

      _children = List<Map<String, dynamic>>.from(response);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Create a new child in the family
  Future<String?> createChild({
    required String familyId,
    required String name,
    required int age,
    required String avatarEmoji,
    required String pinCode,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await supabase.from('tidy_children').insert({
        'family_id': familyId,
        'name': name,
        'age': age,
        'avatar_emoji': avatarEmoji,
        'pin_code': pinCode,
      }).select().single();

      // Refresh children list
      await fetchFamilyChildren(familyId);

      return response['id'];
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Update child's points after completing a task
  void updatePoints(int pointsEarned) {
    if (_childData != null) {
      _childData!['total_points'] = totalPoints + pointsEarned;
      _childData!['available_points'] = availablePoints + pointsEarned;
      notifyListeners();
    }
  }

  /// Clear the current child session
  void clear() {
    _childId = null;
    _childData = null;
    _familyData = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
