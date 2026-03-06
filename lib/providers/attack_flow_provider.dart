// ── Attack Flow Provider ─────────────────────────────────────────
// Ports useAttackFlowState — toggle conventional/cyber visibility.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── State class ──────────────────────────────────────────────────

class AttackFlowState {
  final bool showConventional;
  final bool showCyber;

  const AttackFlowState({
    this.showConventional = true,
    this.showCyber = true,
  });

  AttackFlowState copyWith({
    bool? showConventional,
    bool? showCyber,
  }) {
    return AttackFlowState(
      showConventional: showConventional ?? this.showConventional,
      showCyber: showCyber ?? this.showCyber,
    );
  }
}

// ── SharedPreferences keys ───────────────────────────────────────

const String _conventionalKey = 'attack_flow_conventional';
const String _cyberKey = 'attack_flow_cyber';

// ── StateNotifier ────────────────────────────────────────────────

class AttackFlowNotifier extends StateNotifier<AttackFlowState> {
  AttackFlowNotifier() : super(const AttackFlowState()) {
    _loadPersistedState();
  }

  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final conventional = prefs.getBool(_conventionalKey) ?? true;
      final cyber = prefs.getBool(_cyberKey) ?? true;
      if (mounted) {
        state = AttackFlowState(
          showConventional: conventional,
          showCyber: cyber,
        );
      }
    } catch (_) {
      // Use defaults on error
    }
  }

  Future<void> toggleConventional() async {
    final newVal = !state.showConventional;
    state = state.copyWith(showConventional: newVal);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_conventionalKey, newVal);
    } catch (_) {}
  }

  Future<void> toggleCyber() async {
    final newVal = !state.showCyber;
    state = state.copyWith(showCyber: newVal);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_cyberKey, newVal);
    } catch (_) {}
  }
}

// ── Provider ─────────────────────────────────────────────────────

final attackFlowProvider =
    StateNotifierProvider<AttackFlowNotifier, AttackFlowState>((ref) {
  return AttackFlowNotifier();
});
