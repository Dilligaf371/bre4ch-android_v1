// ── Login Screen ─────────────────────────────────────────────────
// Palantir-styled auth gate — admin / admin

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _userFocus = FocusNode();
  final _passFocus = FocusNode();
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _userFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (_loading) return;
    final user = _userCtrl.text.trim();
    final pass = _passCtrl.text.trim();
    if (user.isEmpty || pass.isEmpty) return;

    setState(() => _loading = true);
    ref.read(authProvider.notifier).clearError();

    // Simulate brief auth delay for UX
    Timer(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      final success = ref.read(authProvider.notifier).login(user, pass);
      if (!success) {
        setState(() => _loading = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Palantir.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── Logo + Title ──
                _buildLogo().animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
                const SizedBox(height: 12),
                Text(
                  'BRE4CH',
                  style: AppTextStyles.mono(
                    size: 28,
                    weight: FontWeight.w800,
                    color: Palantir.accent,
                    letterSpacing: 6,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 100.ms),
                const SizedBox(height: 4),
                Text(
                  'OPERATIONAL FUSION SECURITY',
                  style: AppTextStyles.mono(
                    size: 9,
                    weight: FontWeight.w500,
                    color: Palantir.textMuted,
                    letterSpacing: 3,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 200.ms),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    border: Border.all(color: Palantir.danger.withValues(alpha: 0.4)),
                    borderRadius: BorderRadius.circular(4),
                    color: Palantir.danger.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    'OPERATIONAL SECURITY',
                    style: AppTextStyles.mono(
                      size: 8,
                      weight: FontWeight.w700,
                      color: Palantir.danger,
                      letterSpacing: 2,
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 300.ms),

                SizedBox(height: size.height * 0.06),

                // ── Login Card ──
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Palantir.surface,
                    border: Border.all(color: Palantir.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header
                      Row(
                        children: [
                          Icon(Icons.lock_outline, size: 14, color: Palantir.accent),
                          const SizedBox(width: 8),
                          Text(
                            'AUTHENTICATE',
                            style: AppTextStyles.mono(
                              size: 11,
                              weight: FontWeight.w700,
                              color: Palantir.accent,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'CLASSIFIED SYSTEM ACCESS',
                        style: AppTextStyles.mono(
                          size: 8,
                          color: Palantir.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── Username ──
                      Text(
                        'OPERATOR ID',
                        style: AppTextStyles.mono(
                          size: 9,
                          weight: FontWeight.w600,
                          color: Palantir.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _userCtrl,
                        focusNode: _userFocus,
                        hint: 'Enter operator ID',
                        icon: Icons.person_outline,
                        onSubmitted: (_) => _passFocus.requestFocus(),
                      ),
                      const SizedBox(height: 16),

                      // ── Password ──
                      Text(
                        'ACCESS CODE',
                        style: AppTextStyles.mono(
                          size: 9,
                          weight: FontWeight.w600,
                          color: Palantir.textMuted,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildTextField(
                        controller: _passCtrl,
                        focusNode: _passFocus,
                        hint: 'Enter access code',
                        icon: Icons.key,
                        obscure: _obscure,
                        suffix: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility,
                            size: 16,
                            color: Palantir.textMuted,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                        onSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: 20),

                      // ── Error message ──
                      if (auth.error != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Palantir.danger.withValues(alpha: 0.1),
                            border: Border.all(color: Palantir.danger.withValues(alpha: 0.3)),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error_outline, size: 14, color: Palantir.danger),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  auth.error!,
                                  style: AppTextStyles.mono(
                                    size: 9,
                                    weight: FontWeight.w600,
                                    color: Palantir.danger,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().shakeX(hz: 4, amount: 4, duration: 400.ms),

                      // ── Submit button ──
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Palantir.accent,
                            foregroundColor: Palantir.bg,
                            disabledBackgroundColor: Palantir.accent.withValues(alpha: 0.5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 0,
                          ),
                          child: _loading
                              ? SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Palantir.bg,
                                  ),
                                )
                              : Text(
                                  'INITIATE SESSION',
                                  style: AppTextStyles.mono(
                                    size: 11,
                                    weight: FontWeight.w700,
                                    color: Palantir.bg,
                                    letterSpacing: 2,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 400.ms).slideY(begin: 0.1),

                const SizedBox(height: 24),

                // ── Footer ──
                Text(
                  'v1.6 \u2022 BRE4CH',
                  style: AppTextStyles.mono(
                    size: 8,
                    color: Palantir.textMuted,
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 600.ms),
                const SizedBox(height: 4),
                Text(
                  '\u00a9 2026 COALITION OFSEC \u2014 ALL RIGHTS RESERVED',
                  style: AppTextStyles.mono(
                    size: 7,
                    color: Palantir.textMuted.withValues(alpha: 0.5),
                    letterSpacing: 1,
                  ),
                ).animate().fadeIn(duration: 600.ms, delay: 700.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Palantir.accent.withValues(alpha: 0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Palantir.accent.withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Icon(Icons.security, size: 28, color: Palantir.accent),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      obscureText: obscure,
      onSubmitted: onSubmitted,
      style: AppTextStyles.mono(size: 13, color: Palantir.text),
      cursorColor: Palantir.accent,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.mono(size: 12, color: Palantir.textMuted.withValues(alpha: 0.5)),
        prefixIcon: Icon(icon, size: 16, color: Palantir.textMuted),
        suffixIcon: suffix,
        filled: true,
        fillColor: Palantir.bg,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Palantir.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Palantir.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Palantir.accent, width: 1.5),
        ),
      ),
    );
  }
}
