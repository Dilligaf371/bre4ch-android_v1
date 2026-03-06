// =============================================================================
// BRE4CH - StatusBadge Widget
// INTERCEPTED / IMPACT / ONGOING / NEUTRALIZED for attack events
// =============================================================================

import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/attack_event.dart';

class StatusBadge extends StatelessWidget {
  final EventStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _color.withValues(alpha: 0.5), width: 0.5),
      ),
      child: Text(
        _label,
        style: AppTextStyles.mono(
          size: 7,
          weight: FontWeight.w700,
          color: _color,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  String get _label {
    switch (status) {
      case EventStatus.intercepted:
        return 'INTERCEPTED';
      case EventStatus.impact:
        return 'IMPACT';
      case EventStatus.ongoing:
        return 'ONGOING';
      case EventStatus.neutralized:
        return 'NEUTRALIZED';
    }
  }

  Color get _color {
    switch (status) {
      case EventStatus.intercepted:
        return StatusColors.intercepted;
      case EventStatus.impact:
        return StatusColors.impact;
      case EventStatus.ongoing:
        return StatusColors.ongoing;
      case EventStatus.neutralized:
        return StatusColors.neutralized;
    }
  }
}
