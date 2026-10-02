import 'package:flutter/material.dart';
import 'package:e7m/shared/localization/app_translations.dart';

class CompetitionRegistrationStatus extends StatelessWidget {
  const CompetitionRegistrationStatus({
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

  _RegistrationStatusStyle _getStyle(
      ThemeData theme,
      ) {
    switch (status.toLowerCase().trim()) {
      case 'pending':
        return _RegistrationStatusStyle(
          label: 'Pending'.tr,
          icon: Icons.hourglass_empty_rounded,
          backgroundColor:
          theme.colorScheme.secondary.withOpacity(0.12),
          foregroundColor:
          theme.colorScheme.secondary,
        );

      case 'approved':
        return _RegistrationStatusStyle(
          label: 'Approved'.tr,
          icon: Icons.check_circle_outline,
          backgroundColor:
          theme.colorScheme.primary.withOpacity(0.12),
          foregroundColor:
          theme.colorScheme.primary,
        );

      case 'payment_pending':
        return _RegistrationStatusStyle(
          label: 'Payment Required'.tr,
          icon: Icons.payments_outlined,
          backgroundColor:
          theme.colorScheme.secondary.withOpacity(0.12),
          foregroundColor:
          theme.colorScheme.secondary,
        );

      case 'paid':
        return _RegistrationStatusStyle(
          label: 'Registered'.tr,
          icon: Icons.verified_outlined,
          backgroundColor:
          theme.colorScheme.primary.withOpacity(0.12),
          foregroundColor:
          theme.colorScheme.primary,
        );

      case 'rejected':
        return _RegistrationStatusStyle(
          label: 'Rejected'.tr,
          icon: Icons.cancel_outlined,
          backgroundColor:
          theme.colorScheme.error.withOpacity(0.12),
          foregroundColor:
          theme.colorScheme.error,
        );

      case 'waitlisted':
        return _RegistrationStatusStyle(
          label: 'Waitlisted'.tr,
          icon: Icons.format_list_numbered_rounded,
          backgroundColor:
          theme.colorScheme.secondary.withOpacity(0.12),
          foregroundColor:
          theme.colorScheme.secondary,
        );

      case 'cancelled':
      case 'canceled':
        return _RegistrationStatusStyle(
          label: 'Cancelled'.tr,
          icon: Icons.block_outlined,
          backgroundColor:
          theme.colorScheme.error.withOpacity(0.12),
          foregroundColor:
          theme.colorScheme.error,
        );

      case 'expired':
        return _RegistrationStatusStyle(
          label: 'Expired'.tr,
          icon: Icons.timer_off_outlined,
          backgroundColor:
          theme.colorScheme.error.withOpacity(0.12),
          foregroundColor:
          theme.colorScheme.error,
        );

      case 'completed':
        return _RegistrationStatusStyle(
          label: 'Completed'.tr,
          icon: Icons.emoji_events_outlined,
          backgroundColor:
          theme.colorScheme.primary.withOpacity(0.12),
          foregroundColor:
          theme.colorScheme.primary,
        );

      case 'disqualified':
        return _RegistrationStatusStyle(
          label: 'Disqualified'.tr,
          icon: Icons.gpp_bad_outlined,
          backgroundColor:
          theme.colorScheme.error.withOpacity(0.12),
          foregroundColor:
          theme.colorScheme.error,
        );

      default:
        return _RegistrationStatusStyle(
          label: status.isEmpty ? 'Unknown'.tr : status,
          icon: Icons.info_outline,
          backgroundColor:
          theme.colorScheme.surfaceContainerHighest,
          foregroundColor:
          theme.colorScheme.onSurfaceVariant,
        );
    }
  }
}

class _RegistrationStatusStyle {
  const _RegistrationStatusStyle({
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