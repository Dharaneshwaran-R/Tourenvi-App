import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:io';
import '../models/user_model.dart';

/// Simulated Auth Service
/// Since Firebase requires google-services.json setup on the user's machine,
/// this service uses local file-based persistence for now.
/// When Firebase is configured, simply swap the method implementations.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  UserModel? _currentUser;
  final String _usersFilePath = 'tourenvi_users.json';

  /// Get current logged-in user
  UserModel? get currentUser => _currentUser;

  /// Check if user is logged in
  bool get isLoggedIn => _currentUser != null;

  /// Initialize - check for a persisted session
  Future<UserModel?> tryAutoLogin() async {
    try {
      final sessionFile = File('tourenvi_session.json');
      if (await sessionFile.exists()) {
        final sessionData = jsonDecode(await sessionFile.readAsString());
        final String? uid = sessionData['uid'];
        if (uid != null) {
          final users = await _loadUsers();
          final userData = users[uid];
          if (userData != null) {
            _currentUser = UserModel.fromMap(Map<String, dynamic>.from(userData), uid);
            return _currentUser;
          }
        }
      }
    } catch (e) {
      debugPrint('Auto-login failed: $e');
    }
    return null;
  }

  /// Register a new user
  Future<({bool success, String message, UserModel? user})> register({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.endUser,
  }) async {
    try {
      // Validate inputs
      if (name.trim().isEmpty) {
        return (success: false, message: 'Name is required', user: null);
      }
      if (email.trim().isEmpty || !email.contains('@')) {
        return (success: false, message: 'Valid email is required', user: null);
      }
      if (password.length < 6) {
        return (success: false, message: 'Password must be at least 6 characters', user: null);
      }

      final users = await _loadUsers();

      // Check if email already exists
      for (var entry in users.entries) {
        if (entry.value['email'] == email.trim()) {
          return (success: false, message: 'Email already registered', user: null);
        }
      }

      // Create unique ID
      final uid = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();

      final newUser = UserModel(
        uid: uid,
        name: name.trim(),
        email: email.trim(),
        role: role,
        createdAt: now,
        lastLogin: now,
      );

      // Save to local storage
      users[uid] = {
        ...newUser.toMap(),
        'password': _hashPassword(password),
      };
      await _saveUsers(users);

      // Save session
      _currentUser = newUser;
      await _saveSession(uid);

      return (success: true, message: 'Registration successful', user: newUser);
    } catch (e) {
      debugPrint('Registration error: $e');
      return (success: false, message: 'Registration failed: $e', user: null);
    }
  }

  /// Login with email & password
  Future<({bool success, String message, UserModel? user})> login({
    required String email,
    required String password,
  }) async {
    try {
      if (email.trim().isEmpty || !email.contains('@')) {
        return (success: false, message: 'Valid email is required', user: null);
      }
      if (password.isEmpty) {
        return (success: false, message: 'Password is required', user: null);
      }

      final users = await _loadUsers();
      final hashedPwd = _hashPassword(password);

      for (var entry in users.entries) {
        if (entry.value['email'] == email.trim() &&
            entry.value['password'] == hashedPwd) {
          // Update last login
          entry.value['lastLogin'] = DateTime.now().millisecondsSinceEpoch;
          await _saveUsers(users);

          _currentUser = UserModel.fromMap(
              Map<String, dynamic>.from(entry.value), entry.key);

          // Save session
          await _saveSession(entry.key);

          return (success: true, message: 'Login successful', user: _currentUser);
        }
      }

      return (success: false, message: 'Invalid email or password', user: null);
    } catch (e) {
      debugPrint('Login error: $e');
      return (success: false, message: 'Login failed: $e', user: null);
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _currentUser = null;
    try {
      final sessionFile = File('tourenvi_session.json');
      if (await sessionFile.exists()) {
        await sessionFile.delete();
      }
    } catch (e) {
      debugPrint('Sign out error: $e');
    }
  }

  /// Send password reset (simulated)
  Future<({bool success, String message})> sendPasswordReset(String email) async {
    try {
      final users = await _loadUsers();
      bool found = false;
      for (var entry in users.entries) {
        if (entry.value['email'] == email.trim()) {
          found = true;
          break;
        }
      }

      if (!found) {
        return (success: false, message: 'No account found with this email');
      }

      // In production, this would send an actual email
      return (success: true, message: 'Password reset link sent to $email');
    } catch (e) {
      return (success: false, message: 'Failed to send reset email');
    }
  }

  /// Update user profile
  Future<bool> updateProfile(UserModel updatedUser) async {
    try {
      final users = await _loadUsers();
      if (users.containsKey(updatedUser.uid)) {
        final existingData = Map<String, dynamic>.from(users[updatedUser.uid]!);
        final String? existingPwd = existingData['password'];
        users[updatedUser.uid] = {
          ...updatedUser.toMap(),
          'password': existingPwd,
        };
        await _saveUsers(users);
        _currentUser = updatedUser;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Update profile error: $e');
      return false;
    }
  }

  // ── Private helpers ──

  Future<Map<String, dynamic>> _loadUsers() async {
    try {
      final file = File(_usersFilePath);
      if (await file.exists()) {
        final content = await file.readAsString();
        return Map<String, dynamic>.from(jsonDecode(content));
      }
    } catch (e) {
      debugPrint('Load users error: $e');
    }
    return {};
  }

  Future<void> _saveUsers(Map<String, dynamic> users) async {
    try {
      final file = File(_usersFilePath);
      await file.writeAsString(jsonEncode(users));
    } catch (e) {
      debugPrint('Save users error: $e');
    }
  }

  Future<void> _saveSession(String uid) async {
    try {
      final file = File('tourenvi_session.json');
      await file.writeAsString(jsonEncode({'uid': uid}));
    } catch (e) {
      debugPrint('Save session error: $e');
    }
  }

  String _hashPassword(String password) {
    // Simple hash for local demo — use proper crypto in production
    int hash = 0;
    for (int i = 0; i < password.length; i++) {
      hash = ((hash << 5) - hash) + password.codeUnitAt(i);
      hash = hash & 0x7FFFFFFF;
    }
    return hash.toString();
  }
}
