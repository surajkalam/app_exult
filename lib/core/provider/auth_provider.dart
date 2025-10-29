import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Auth State Model
class AuthState {
  final bool isAuthenticated;
  final String? email;
  final bool isLoading;
  final String? error;

  AuthState({
    this.isAuthenticated = false,
    this.email,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    String? email,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      email: email ?? this.email,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState()) {
    _checkAuthStatus();
  }

  static const String _keyIsAuthenticated = 'is_authenticated';
  static const String _keyEmail = 'user_email';
  static const String _keyPassword = 'user_password';

  // Check if user is already logged in
  Future<void> _checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final isAuth = prefs.getBool(_keyIsAuthenticated) ?? false;
      final email = prefs.getString(_keyEmail);

      state = state.copyWith(
        isAuthenticated: isAuth,
        email: email,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to check auth status',
      );
    }
  }

  // Login method
  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate a delay for authentication
      await Future.delayed(const Duration(seconds: 1));

      // Simple validation - you can replace this with actual Firebase Auth
      if (email.isEmpty || password.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Email and password cannot be empty',
        );
        return false;
      }

      if (!email.contains('@')) {
        state = state.copyWith(
          isLoading: false,
          error: 'Please enter a valid email',
        );
        return false;
      }

      if (password.length < 6) {
        state = state.copyWith(
          isLoading: false,
          error: 'Password must be at least 6 characters',
        );
        return false;
      }

      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyIsAuthenticated, true);
      await prefs.setString(_keyEmail, email);
      await prefs.setString(_keyPassword, password);

      state = state.copyWith(
        isAuthenticated: true,
        email: email,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Login failed: ${e.toString()}',
      );
      return false;
    }
  }

  // Signup method
  Future<bool> signup(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // Simulate a delay for authentication
      await Future.delayed(const Duration(seconds: 1));

      // Validation
      if (email.isEmpty || password.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Email and password cannot be empty',
        );
        return false;
      }

      if (!email.contains('@')) {
        state = state.copyWith(
          isLoading: false,
          error: 'Please enter a valid email',
        );
        return false;
      }

      if (password.length < 6) {
        state = state.copyWith(
          isLoading: false,
          error: 'Password must be at least 6 characters',
        );
        return false;
      }

      // Check if user already exists
      final prefs = await SharedPreferences.getInstance();
      final existingEmail = prefs.getString(_keyEmail);
      
      if (existingEmail == email) {
        state = state.copyWith(
          isLoading: false,
          error: 'User already exists. Please login.',
        );
        return false;
      }

      // Save to SharedPreferences
      await prefs.setBool(_keyIsAuthenticated, true);
      await prefs.setString(_keyEmail, email);
      await prefs.setString(_keyPassword, password);

      state = state.copyWith(
        isAuthenticated: true,
        email: email,
        isLoading: false,
      );

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Signup failed: ${e.toString()}',
      );
      return false;
    }
  }

  // Logout method
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyIsAuthenticated);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyPassword);

      state = AuthState(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Logout failed',
      );
    }
  }

  // Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Auth Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

