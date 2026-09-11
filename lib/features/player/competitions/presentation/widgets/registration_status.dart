import 'package:flutter/material.dart';

class RegistrationStatus extends StatelessWidget {
  const RegistrationStatus({
    super.key,
    required this.status,
    this.compact = false,
  });

  final String status;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final config = _getStatusConfig(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 12,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            config.icon,
            size: compact ? 14 : 16,
            color: config.foregroundColor,
          ),
          const SizedBox(width: 6),
          Text(
            config.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: config.foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  _RegistrationStatusConfig _getStatusConfig(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (status.toLowerCase().trim()) {
      case 'pending':
        return _RegistrationStatusConfig(
          label: 'Pending',
          icon: Icons.hourglass_empty_outlined,
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
        );

      case 'approved':
        return _RegistrationStatusConfig(
          label: 'Approved',
          icon: Icons.check_circle_outline,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        );

      case 'payment_pending':
        return _RegistrationStatusConfig(
          label: 'Payment Pending',
          icon: Icons.payment_outlined,
          backgroundColor: colorScheme.tertiaryContainer,
          foregroundColor: colorScheme.onTertiaryContainer,
        );

      case 'paid':
        return _RegistrationStatusConfig(
          label: 'Paid',
          icon: Icons.verified_outlined,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        );

      case 'rejected':
        return _RegistrationStatusConfig(
          label: 'Rejected',
          icon: Icons.cancel_outlined,
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
        );

      case 'waitlisted':
        return _RegistrationStatusConfig(
          label: 'Waitlisted',
          icon: Icons.queue_outlined,
          backgroundColor: colorScheme.secondaryContainer,
          foregroundColor: colorScheme.onSecondaryContainer,
        );

      case 'cancelled':
        return _RegistrationStatusConfig(
          label: 'Cancelled',
          icon: Icons.remove_circle_outline,
          backgroundColor: colorScheme.surfaceContainerHighest,
          foregroundColor: colorScheme.onSurfaceVariant,
        );

      case 'expired':
        return _RegistrationStatusConfig(
          label: 'Expired',
          icon: Icons.timer_off_outlined,
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
        );

      case 'completed':
        return _RegistrationStatusConfig(
          label: 'Completed',
          icon: Icons.emoji_events_outlined,
          backgroundColor: colorScheme.primaryContainer,
          foregroundColor: colorScheme.onPrimaryContainer,
        );

      case 'disqualified':
        return _RegistrationStatusConfig(
          label: 'Disqualified',
          icon: Icons.block_outlined,
          backgroundColor: colorScheme.errorContainer,
          foregroundColor: colorScheme.onErrorContainer,
        );

      default:
        return _RegistrationStatusConfig(
          label: _formatUnknownStatus(status),
          icon: Icons.info_outline,
          backgroundColor: colorScheme.surfaceContainerHighest,
          foregroundColor: colorScheme.onSurfaceVariant,
        );
    }
  }

  String _formatUnknownStatus(String value) {
    final normalized = value.trim();

    if (normalized.isEmpty) {
      return 'Unknown';
    }

    return normalized
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
      '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
    )
        .join(' ');
  }
}

class _RegistrationStatusConfig {
  const _RegistrationStatusConfig({
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