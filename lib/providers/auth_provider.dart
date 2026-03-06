// ── Auth Provider ────────────────────────────────────────────────
// CRIT-01 FIX: Removed hardcoded admin/admin credentials.
// App auto-authenticates on launch (no login screen).
// API authentication handled via API key header in ApiService.

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
  // CRIT-01: Auto-authenticate on construction (no hardcoded credentials)
  AuthNotifier() : super(const AuthState(isAuthenticated: true));

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
