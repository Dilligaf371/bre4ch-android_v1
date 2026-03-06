// ── Auth Provider ────────────────────────────────────────────────
// Simple auth state with hardcoded credentials: admin / admin

import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isAuthenticated;
  final String? error;

  const AuthState({this.isAuthenticated = false, this.error});

  AuthState copyWith({bool? isAuthenticated, String? error}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(const AuthState());

  static const _validUser = 'admin';
  static const _validPass = 'admin';

  bool login(String username, String password) {
    if (username == _validUser && password == _validPass) {
      state = const AuthState(isAuthenticated: true, error: null);
      return true;
    } else {
      state = const AuthState(
        isAuthenticated: false,
        error: 'ACCESS DENIED \u2014 INVALID CREDENTIALS',
      );
      return false;
    }
  }

  void logout() {
    state = const AuthState(isAuthenticated: false, error: null);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
