// =============================================================================
// BRE4CH - PalantirCard Widget
// Dark card with Palantir border styling
// =============================================================================

import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PalantirCard extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const PalantirCard({
    super.key,
    required this.child,
    this.borderColor,
    this.padding,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Palantir.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: borderColor ?? Palantir.border,
          width: 1,
        ),
      ),
      child: child,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}
