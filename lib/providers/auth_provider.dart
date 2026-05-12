import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Authentication state provider
/// Uses ChangeNotifier for easy widget rebuilds on auth state changes
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ──
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _user != null;
  String? get errorMessage => _errorMessage;
  UserRole get userRole => _user?.role ?? UserRole.endUser;

  /// Try restoring saved session on app start
  Future<bool> tryAutoLogin() async {
    _isLoading = true;
    notifyListeners();

    final restoredUser = await _authService.tryAutoLogin();
    _user = restoredUser;

    _isLoading = false;
    notifyListeners();
    return restoredUser != null;
  }

  /// Register a new user
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.endUser,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(
      name: name,
      email: email,
      password: password,
      role: role,
    );

    _isLoading = false;
    if (result.success) {
      _user = result.user;
      _errorMessage = null;
    } else {
      _errorMessage = result.message;
    }
    notifyListeners();
    return result.success;
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(
      email: email,
      password: password,
    );

    _isLoading = false;
    if (result.success) {
      _user = result.user;
      _errorMessage = null;
    } else {
      _errorMessage = result.message;
    }
    notifyListeners();
    return result.success;
  }

  /// Sign out
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Send password reset email
  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.sendPasswordReset(email);

    _isLoading = false;
    if (!result.success) {
      _errorMessage = result.message;
    }
    notifyListeners();
    return result.success;
  }

  /// Clear any error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
