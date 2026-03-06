// =============================================================================
// BRE4CH - PulsingDot Widget
// Animated glow indicator for live status
// =============================================================================

import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PulsingDot extends StatefulWidget {
  final Color color;
  final double size;

  const PulsingDot({
    super.key,
    this.color = Palantir.success,
    this.size = 6.0,
  });

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _opacityAnimation,
      builder: (context, child) {
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: _opacityAnimation.value),
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(
                  alpha: 0.4 * _opacityAnimation.value,
                ),
                blurRadius: widget.size,
                spreadRadius: widget.size * 0.3,
              ),
            ],
          ),
        );
      },
    );
  }
}
