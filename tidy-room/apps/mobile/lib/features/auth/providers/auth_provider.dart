import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../main.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  static const String _familyIdKey = 'cached_family_id';
  
  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _errorMessage;
  String? _userRole; // 'parent' or 'child'
  Map<String, dynamic>? _profile;
  bool _isInitialized = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  String? get userRole => _userRole;
  Map<String, dynamic>? get profile => _profile;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isParent => _userRole == 'parent';
  bool get isChild => _userRole == 'child';
  bool get isInitialized => _isInitialized;

  /// Save family_id to local storage for child login on same device
  static Future<void> cacheFamilyId(String? familyId) async {
    final prefs = await SharedPreferences.getInstance();
    if (familyId != null) {
      await prefs.setString(_familyIdKey, familyId);
      debugPrint('Cached family_id: $familyId');
    }
  }

  /// Get cached family_id from local storage
  static Future<String?> getCachedFamilyId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_familyIdKey);
  }

  /// Clear cached family_id
  static Future<void> clearCachedFamilyId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_familyIdKey);
  }

  AuthProvider() {
    _init();
  }

  Future<void> _init() async {
    try {
      // Wait a small moment for Supabase to restore session from storage
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Check current session - this should now have the persisted session
      final session = supabase.auth.currentSession;
      debugPrint('AuthProvider._init: session = ${session != null ? 'exists' : 'null'}');
      
      if (session != null) {
        _user = session.user;
        debugPrint('AuthProvider._init: user id = ${_user?.id}');
        await _fetchProfile();
      } else {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
      }
      
      _isInitialized = true;

      // Listen to auth changes
      supabase.auth.onAuthStateChange.listen((data) async {
        final event = data.event;
        final session = data.session;
        
        debugPrint('AuthProvider: Auth event = $event');

        if (event == AuthChangeEvent.signedIn && session != null) {
          _user = session.user;
          await _fetchProfile();
        } else if (event == AuthChangeEvent.signedOut) {
          _user = null;
          _profile = null;
          _userRole = null;
          _status = AuthStatus.unauthenticated;
          notifyListeners();
        } else if (event == AuthChangeEvent.tokenRefreshed && session != null) {
          // Session was refreshed, update user
          _user = session.user;
          if (_profile == null) {
            await _fetchProfile();
          }
        }
      });
    } catch (e) {
      debugPrint('AuthProvider._init error: $e');
      _status = AuthStatus.unauthenticated;
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _fetchProfile() async {
    if (_user == null) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }
    
    try {
      debugPrint('Fetching profile for user: ${_user!.id}');
      
      final response = await supabase
          .from('tidy_profiles')
          .select()
          .eq('id', _user!.id)
          .maybeSingle();

      if (response == null) {
        debugPrint('No profile found, creating one...');
        // Profile doesn't exist, create it
        await _createProfile();
        return;
      }

      _profile = response;
      _userRole = response['role'] as String? ?? 'parent';
      
      debugPrint('Profile loaded: family_id = ${_profile?['family_id']}');
      
      // Check if family exists, if not create one
      if (_profile!['family_id'] == null) {
        debugPrint('No family found, creating one...');
        await _ensureFamilyExists();
      }
      
      // Cache family_id for child login on same device
      if (_profile?['family_id'] != null) {
        await cacheFamilyId(_profile!['family_id'] as String);
      }
      
      _status = AuthStatus.authenticated;
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      // Still mark as authenticated if we have a user
      _status = AuthStatus.authenticated;
      _userRole = 'parent';
      notifyListeners();
    }
  }

  Future<void> _createProfile() async {
    if (_user == null) return;
    
    try {
      final displayName = _user!.userMetadata?['display_name'] ?? 
                          _user!.email?.split('@').first ?? 
                          'User';
      
      await supabase.from('tidy_profiles').insert({
        'id': _user!.id,
        'email': _user!.email,
        'display_name': displayName,
        'role': 'parent',
        'is_primary_parent': true,
      });
      
      debugPrint('Profile created for user: ${_user!.id}');
      
      // Now fetch the profile again
      await _fetchProfile();
    } catch (e) {
      debugPrint('Error creating profile: $e');
      // Profile might already exist due to trigger
      await _fetchProfile();
    }
  }

  /// Ensure the current user has a family, create one if missing
  Future<bool> _ensureFamilyExists() async {
    if (_user == null) return false;
    
    // Re-read profile to get latest data
    try {
      final profileCheck = await supabase
          .from('tidy_profiles')
          .select('family_id')
          .eq('id', _user!.id)
          .maybeSingle();
      
      if (profileCheck != null && profileCheck['family_id'] != null) {
        // Family already exists, just refresh profile
        await _refreshProfileData();
        return true;
      }
    } catch (e) {
      debugPrint('Error checking profile: $e');
    }
    
    final displayName = _profile?['display_name'] ?? 
                        _user!.userMetadata?['display_name'] ?? 
                        'My';
    
    // Method 1: Try RPC (preferred - handles everything server-side)
    try {
      debugPrint('Trying RPC to create family...');
      final result = await supabase.rpc(
        'create_family_for_user',
        params: {
          'p_family_name': "$displayName's Family",
          'p_user_id': _user!.id,
        },
      );
      
      if (result != null) {
        debugPrint('Family created via RPC: $result');
        await _refreshProfileData();
        return true;
      }
    } catch (rpcError) {
      debugPrint('RPC failed: $rpcError');
    }
    
    // Method 2: Direct insert (fallback)
    try {
      debugPrint('Trying direct insert to create family...');
      
      final familyResponse = await supabase.from('tidy_families').insert({
        'name': "$displayName's Family",
        'created_by': _user!.id,
      }).select().single();
      
      debugPrint('Family created: ${familyResponse['id']}');
      
      // Update profile with family ID
      await supabase.from('tidy_profiles').update({
        'family_id': familyResponse['id'],
      }).eq('id', _user!.id);
      
      debugPrint('Profile updated with family_id');
      
      // Refresh profile
      await _refreshProfileData();
      return true;
    } catch (insertError) {
      debugPrint('Direct insert failed: $insertError');
    }
    
    debugPrint('All family creation methods failed');
    return false;
  }

  /// Refresh profile data from database
  Future<void> _refreshProfileData() async {
    if (_user == null) return;
    
    try {
      final response = await supabase
          .from('tidy_profiles')
          .select()
          .eq('id', _user!.id)
          .maybeSingle();
      
      if (response != null) {
        _profile = response;
        _userRole = response['role'] as String? ?? 'parent';
        debugPrint('Profile refreshed: family_id = ${_profile?['family_id']}');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error refreshing profile: $e');
    }
  }

  /// Public method to refresh profile (can be called from UI)
  Future<bool> refreshProfile() async {
    debugPrint('refreshProfile called');
    
    await _refreshProfileData();
    
    // Also ensure family exists after refresh
    if (_profile != null && _profile!['family_id'] == null) {
      return await _ensureFamilyExists();
    }
    
    return _profile?['family_id'] != null;
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
            
            // Ensure family exists
            if (_profile!['family_id'] == null) {
              await _ensureFamilyExists();
            }
          } else {
            // No profile exists yet - create one
            _userRole = 'parent';
            await _createProfile();
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
