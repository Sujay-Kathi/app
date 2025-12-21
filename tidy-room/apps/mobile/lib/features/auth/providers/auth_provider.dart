import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../main.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  String? _userRole; // 'parent' or 'child'
  Map<String, dynamic>? _profile;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get userRole => _userRole;
  Map<String, dynamic>? get profile => _profile;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isParent => _userRole == 'parent';
  bool get isChild => _userRole == 'child';

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    // Check current session
    final session = supabase.auth.currentSession;
    if (session != null) {
      _user = session.user;
      await _fetchProfile();
    } else {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
    }

    // Listen to auth changes
    supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;

      if (event == AuthChangeEvent.signedIn && session != null) {
        _user = session.user;
        await _fetchProfile();
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        _profile = null;
        _userRole = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
    });
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await supabase
          .from('tidy_profiles')
          .select()
          .eq('id', _user!.id)
          .single();

      _profile = response;
      _userRole = response['role'] as String?;
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      // Profile might not exist yet - that's okay for new users
      _status = AuthStatus.authenticated;
      notifyListeners();
    }
  }

  Future<bool> signUp({
  required String email,
  required String password,
  required String displayName,
}) async {
  try {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    // Step 1: Create the auth user
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {'display_name': displayName},
    );

    if (response.user == null) {
      _errorMessage = 'Failed to create user account';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    // Step 2: Wait for the database trigger to create the profile
    await Future.delayed(const Duration(milliseconds: 800));

    // Step 3: Create family using the SECURITY DEFINER function (bypasses RLS)
    try {
      final familyResponse = await supabase.rpc(
        'create_family_for_user',
        params: {
          'p_family_name': "$displayName's Family",
          'p_user_id': response.user!.id,
        },
      );

      if (familyResponse != null) {
        debugPrint('Family created successfully: $familyResponse');
      }
    } catch (rpcError) {
      debugPrint('RPC family creation failed: $rpcError');
      
      // Fallback: Try direct insert (in case RPC function doesn't exist yet)
      try {
        final familyResponse = await supabase.from('tidy_families').insert({
          'name': "$displayName's Family",
          'created_by': response.user!.id,
        }).select().single();

        // Update profile with family ID
        await supabase.from('tidy_profiles').update({
          'family_id': familyResponse['id'],
          'display_name': displayName,
        }).eq('id', response.user!.id);
        
        debugPrint('Family created via fallback: $familyResponse');
      } catch (insertError) {
        debugPrint('Fallback family creation also failed: $insertError');
        // Don't fail signup - user can create family later
        // Just log the error and continue
        _errorMessage = 'Account created but family setup failed. Please try logging in.';
        _status = AuthStatus.authenticated;
        _user = response.user;
        _userRole = 'parent';
        notifyListeners();
        return true; // Still return success since auth account was created
      }
    }

    // Step 4: Load the user profile
    _user = response.user;
    _userRole = 'parent';
    _status = AuthStatus.authenticated;
    notifyListeners();

    return true;
  } on AuthException catch (e) {
    debugPrint('AuthException during signup: ${e.message}');
    _errorMessage = e.message;
    _status = AuthStatus.error;
    notifyListeners();
    return false;
  } catch (e) {
    debugPrint('Unexpected error during signup: $e');
    _errorMessage = 'Registration failed: ${e.toString()}';
    _status = AuthStatus.error;
    notifyListeners();
    return false;
  }
}

  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _user = response.user;
        
        // Fetch user profile to get role
        try {
          final profileResponse = await supabase
              .from('tidy_profiles')
              .select()
              .eq('id', response.user!.id)
              .maybeSingle();

          if (profileResponse != null) {
            _profile = profileResponse;
            _userRole = profileResponse['role'] as String? ?? 'parent';
          } else {
            // No profile exists yet - assume parent role
            _userRole = 'parent';
          }
        } catch (e) {
          debugPrint('Error fetching profile during login: $e');
          _userRole = 'parent'; // Default to parent
        }
        
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Login failed';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } on AuthException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithPin({
    required String childId,
    required String pin,
  }) async {
    try {
      _status = AuthStatus.loading;
      _errorMessage = null;
      notifyListeners();

      // Verify PIN
      final response = await supabase
          .from('tidy_children')
          .select('*, profile:tidy_profiles(*)')
          .eq('id', childId)
          .eq('pin_code', pin)
          .single();

      if (response != null) {
        _userRole = 'child';
        _profile = response['profile'];
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }

      _errorMessage = 'Invalid PIN';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Invalid PIN or child not found';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    _user = null;
    _profile = null;
    _userRole = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }
}
