import 'package:flutter/material.dart';
import '../../../main.dart';

class ProfileProvider extends ChangeNotifier {
  Map<String, dynamic>? _child;
  Map<String, dynamic>? _streak;
  List<Map<String, dynamic>> _achievements = [];
  List<Map<String, dynamic>> _pointsHistory = [];
  Map<String, dynamic>? _currentLevel;
  Map<String, dynamic>? _nextLevel;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get child => _child;
  Map<String, dynamic>? get streak => _streak;
  List<Map<String, dynamic>> get achievements => _achievements;
  List<Map<String, dynamic>> get pointsHistory => _pointsHistory;
  Map<String, dynamic>? get currentLevel => _currentLevel;
  Map<String, dynamic>? get nextLevel => _nextLevel;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get name => _child?['name'] ?? 'Unknown';
  String get avatarEmoji => _child?['avatar_emoji'] ?? '👦';
  int get totalPoints => _child?['total_points'] ?? 0;
  int get availablePoints => _child?['available_points'] ?? 0;
  int get level => _child?['current_level'] ?? 1;
  int get totalXp => _child?['total_xp'] ?? 0;
  int get currentStreak => _streak?['current_streak'] ?? 0;
  int get longestStreak => _streak?['longest_streak'] ?? 0;
  double get streakMultiplier => (_streak?['streak_multiplier'] ?? 1.0).toDouble();

  int get xpToNextLevel {
    if (_nextLevel == null) return 0;
    final required = _nextLevel!['xp_required'] as int;
    return required - totalXp;
  }

  double get levelProgress {
    if (_currentLevel == null || _nextLevel == null) return 0.0;
    final currentRequired = _currentLevel!['xp_required'] as int;
    final nextRequired = _nextLevel!['xp_required'] as int;
    final range = nextRequired - currentRequired;
    if (range <= 0) return 1.0;
    final progress = (totalXp - currentRequired) / range;
    return progress.clamp(0.0, 1.0);
  }

  Future<void> fetchChildProfile(String childId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Fetch child data
      final childResponse = await supabase
          .from('tidy_children')
          .select()
          .eq('id', childId)
          .single();

      _child = childResponse;

      // Fetch streak
      final streakResponse = await supabase
          .from('tidy_streaks')
          .select()
          .eq('child_id', childId)
          .maybeSingle();

      _streak = streakResponse;

      // Fetch unlocked achievements
      final achievementsResponse = await supabase
          .from('tidy_child_achievements')
          .select('*, achievement:tidy_achievements(*)')
          .eq('child_id', childId);

      _achievements = List<Map<String, dynamic>>.from(achievementsResponse);

      // Fetch current and next level
      await _fetchLevelInfo();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchLevelInfo() async {
    try {
      // Current level
      final currentResponse = await supabase
          .from('tidy_levels')
          .select()
          .eq('level', level)
          .maybeSingle();

      _currentLevel = currentResponse;

      // Next level
      final nextResponse = await supabase
          .from('tidy_levels')
          .select()
          .eq('level', level + 1)
          .maybeSingle();

      _nextLevel = nextResponse;
    } catch (e) {
      // Levels might not exist
    }
  }

  Future<void> fetchPointsHistory(String childId, {int limit = 20}) async {
    try {
      final response = await supabase
          .from('tidy_points_log')
          .select()
          .eq('child_id', childId)
          .order('created_at', ascending: false)
          .limit(limit);

      _pointsHistory = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<bool> updateAvatar(String childId, String emoji) async {
    try {
      await supabase
          .from('tidy_children')
          .update({'avatar_emoji': emoji})
          .eq('id', childId);

      _child?['avatar_emoji'] = emoji;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePin(String childId, String newPin) async {
    try {
      await supabase
          .from('tidy_children')
          .update({'pin_code': newPin})
          .eq('id', childId);

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
