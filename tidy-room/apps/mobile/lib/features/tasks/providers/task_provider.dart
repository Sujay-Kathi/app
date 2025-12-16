import 'package:flutter/material.dart';
import '../../../main.dart';

class TaskProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _tasks = [];
  List<Map<String, dynamic>> _taskTemplates = [];
  bool _isLoading = false;
  String? _error;

  List<Map<String, dynamic>> get tasks => _tasks;
  List<Map<String, dynamic>> get taskTemplates => _taskTemplates;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Map<String, dynamic>> get pendingTasks =>
      _tasks.where((t) => t['status'] == 'pending').toList();
  
  List<Map<String, dynamic>> get completedTasks =>
      _tasks.where((t) => t['status'] == 'completed' || t['status'] == 'verified').toList();

  int get pendingCount => pendingTasks.length;
  int get completedCount => completedTasks.length;

  List<Map<String, dynamic>> getTasksByZone(String zone) =>
      _tasks.where((t) => t['zone'] == zone).toList();

  Future<void> fetchTasks(String childId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await supabase
          .from('tidy_tasks')
          .select()
          .eq('child_id', childId)
          .order('created_at', ascending: false);

      _tasks = List<Map<String, dynamic>>.from(response);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTaskTemplates() async {
    try {
      final response = await supabase
          .from('tidy_task_templates')
          .select()
          .order('zone')
          .order('default_points');

      _taskTemplates = List<Map<String, dynamic>>.from(response);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>?> getTask(String taskId) async {
    try {
      final response = await supabase
          .from('tidy_tasks')
          .select()
          .eq('id', taskId)
          .single();

      return response;
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  Future<bool> createTask({
    required String childId,
    required String title,
    required String zone,
    required int points,
    String? description,
    String difficulty = 'medium',
    String frequency = 'one_time',
    String icon = '✨',
    DateTime? dueDate,
    bool requiresVerification = false,
    String? templateId,
    required String createdBy,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      await supabase.from('tidy_tasks').insert({
        'child_id': childId,
        'created_by': createdBy,
        'template_id': templateId,
        'title': title,
        'description': description,
        'zone': zone,
        'points': points,
        'difficulty': difficulty,
        'frequency': frequency,
        'icon': icon,
        'due_date': dueDate?.toIso8601String(),
        'requires_verification': requiresVerification,
      });

      await fetchTasks(childId);
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeTask(String taskId, String childId, {String? photoUrl}) async {
    try {
      await supabase.from('tidy_tasks').update({
        'status': 'completed',
        'completed_at': DateTime.now().toIso8601String(),
        'verification_photo_url': photoUrl,
      }).eq('id', taskId);

      await fetchTasks(childId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyTask(String taskId, String childId, String verifiedBy, bool approve, {String? reason}) async {
    try {
      if (approve) {
        await supabase.from('tidy_tasks').update({
          'status': 'verified',
          'verified_at': DateTime.now().toIso8601String(),
          'verified_by': verifiedBy,
        }).eq('id', taskId);
      } else {
        await supabase.from('tidy_tasks').update({
          'status': 'rejected',
          'rejection_reason': reason,
        }).eq('id', taskId);
      }

      await fetchTasks(childId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(String taskId, String childId) async {
    try {
      await supabase.from('tidy_tasks').delete().eq('id', taskId);
      await fetchTasks(childId);
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
