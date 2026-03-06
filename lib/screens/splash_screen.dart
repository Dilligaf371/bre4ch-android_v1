// =============================================================================
// BRE4CH — Splash Screen
// Logo only — 3 seconds then auto-navigate
// =============================================================================

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';


class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();

    // Glow pulse
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    // Navigate after 3 seconds
    Timer(const Duration(milliseconds: 4000), () {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/images/delta_s_logo_white.png',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
      )
          .animate()
          .fadeIn(duration: 600.ms, curve: Curves.easeOut),
    );
  }
}
