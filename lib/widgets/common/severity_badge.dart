// =============================================================================
// BRE4CH - SeverityBadge Widget
// CRIT / HIGH / MED / LOW pill badge for SOCMINT items
// =============================================================================

import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/socmint_item.dart';

class SeverityBadge extends StatelessWidget {
  final SocmintSeverity severity;

  const SeverityBadge({super.key, required this.severity});

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
    switch (severity) {
      case SocmintSeverity.critical:
        return 'CRIT';
      case SocmintSeverity.high:
        return 'HIGH';
      case SocmintSeverity.medium:
        return 'MED';
      case SocmintSeverity.low:
        return 'LOW';
    }
  }

  Color get _color {
    switch (severity) {
      case SocmintSeverity.critical:
        return SeverityColors.critical;
      case SocmintSeverity.high:
        return SeverityColors.high;
      case SocmintSeverity.medium:
        return SeverityColors.medium;
      case SocmintSeverity.low:
        return SeverityColors.low;
    }
  }
}
