import 'package:flutter/material.dart';

class CompetitionStatusBadge extends StatelessWidget {
  const CompetitionStatusBadge({
    super.key,
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = _getStyle(theme);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            style.icon,
            size: 15,
            color: style.foregroundColor,
          ),
          const SizedBox(width: 6),
          Text(
            style.label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: style.foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _StatusStyle _getStyle(ThemeData theme) {
    switch (status.toLowerCase().trim()) {
      case 'open':
        return _StatusStyle(
          label: 'Open',
          icon: Icons.check_circle_outline,
          backgroundColor:
          theme.colorScheme.primary.withOpacity(0.12),
          foregroundColor: theme.colorScheme.primary,
        );

      case 'upcoming':
        return _StatusStyle(
          label: 'Upcoming',
          icon: Icons.schedule_outlined,
          backgroundColor:
          theme.colorScheme.secondary.withOpacity(0.12),
          foregroundColor: theme.colorScheme.secondary,
        );

      case 'ongoing':
        return _StatusStyle(
          label: 'Ongoing',
          icon: Icons.play_circle_outline,
          backgroundColor:
          theme.colorScheme.primary.withOpacity(0.12),
          foregroundColor: theme.colorScheme.primary,
        );

      case 'completed':
        return _StatusStyle(
          label: 'Completed',
          icon: Icons.emoji_events_outlined,
          backgroundColor:
          theme.colorScheme.surfaceContainerHighest,
          foregroundColor:
          theme.colorScheme.onSurfaceVariant,
        );

      case 'cancelled':
      case 'canceled':
        return _StatusStyle(
          label: 'Cancelled',
          icon: Icons.cancel_outlined,
          backgroundColor:
          theme.colorScheme.error.withOpacity(0.12),
          foregroundColor: theme.colorScheme.error,
        );

      default:
        return _StatusStyle(
          label: status.isEmpty ? 'Competition' : status,
          icon: Icons.info_outline,
          backgroundColor:
          theme.colorScheme.surfaceContainerHighest,
          foregroundColor:
          theme.colorScheme.onSurfaceVariant,
        );
    }
  }
}

class _StatusStyle {
  const _StatusStyle({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;
}