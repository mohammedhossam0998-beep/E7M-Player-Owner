import 'package:flutter/material.dart';

class CompetitionPaymentStatus extends StatelessWidget {
  const CompetitionPaymentStatus({
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
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            style.icon,
            size: 17,
            color: style.foregroundColor,
          ),
          const SizedBox(width: 7),
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

  _PaymentStatusStyle _getStyle(ThemeData theme) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return _PaymentStatusStyle(
          label: 'Payment Pending',
          icon: Icons.hourglass_empty_rounded,
          backgroundColor:
          theme.colorScheme.secondary.withOpacity(0.12),
          foregroundColor: theme.colorScheme.secondary,
        );

      case 'submitted':
        return _PaymentStatusStyle(
          label: 'Under Review',
          icon: Icons.rate_review_outlined,
          backgroundColor:
          theme.colorScheme.primary.withOpacity(0.12),
          foregroundColor: theme.colorScheme.primary,
        );

      case 'paid':
        return _PaymentStatusStyle(
          label: 'Paid',
          icon: Icons.check_circle_outline,
          backgroundColor:
          theme.colorScheme.primary.withOpacity(0.12),
          foregroundColor: theme.colorScheme.primary,
        );

      case 'failed':
        return _PaymentStatusStyle(
          label: 'Payment Failed',
          icon: Icons.error_outline,
          backgroundColor:
          theme.colorScheme.error.withOpacity(0.12),
          foregroundColor: theme.colorScheme.error,
        );

      case 'expired':
        return _PaymentStatusStyle(
          label: 'Expired',
          icon: Icons.timer_off_outlined,
          backgroundColor:
          theme.colorScheme.error.withOpacity(0.12),
          foregroundColor: theme.colorScheme.error,
        );

      case 'refunded':
        return _PaymentStatusStyle(
          label: 'Refunded',
          icon: Icons.currency_exchange_rounded,
          backgroundColor:
          theme.colorScheme.secondary.withOpacity(0.12),
          foregroundColor: theme.colorScheme.secondary,
        );

      case 'partially_refunded':
        return _PaymentStatusStyle(
          label: 'Partially Refunded',
          icon: Icons.currency_exchange_rounded,
          backgroundColor:
          theme.colorScheme.secondary.withOpacity(0.12),
          foregroundColor: theme.colorScheme.secondary,
        );

      default:
        return _PaymentStatusStyle(
          label: status.isEmpty ? 'Unknown' : status,
          icon: Icons.info_outline,
          backgroundColor:
          theme.colorScheme.surfaceContainerHighest,
          foregroundColor:
          theme.colorScheme.onSurfaceVariant,
        );
    }
  }
}

class _PaymentStatusStyle {
  const _PaymentStatusStyle({
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