import 'package:flutter/material.dart';

enum IssuedStatusTone { neutral, info, success, warning, error }

class IssuedStatusBadge extends StatelessWidget {
  const IssuedStatusBadge({
    super.key,
    required this.label,
    this.tone = IssuedStatusTone.neutral,
    this.icon,
  });

  final String label;
  final IssuedStatusTone tone;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final (background, foreground) = switch (tone) {
      IssuedStatusTone.neutral => (
        const Color(0xFFEEF2F6),
        const Color(0xFF475569),
      ),
      IssuedStatusTone.info => (
        const Color(0xFFDCE8F7),
        const Color(0xFF1E3A5F),
      ),
      IssuedStatusTone.success => (
        const Color(0xFFDCFCE7),
        const Color(0xFF166534),
      ),
      IssuedStatusTone.warning => (
        const Color(0xFFFEF3C7),
        const Color(0xFF92400E),
      ),
      IssuedStatusTone.error => (
        const Color(0xFFFEE2E2),
        const Color(0xFF991B1B),
      ),
    };
    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: foreground),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
