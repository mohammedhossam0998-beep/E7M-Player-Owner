import 'package:flutter/material.dart';

import '../../models/competition_model.dart';

class CompetitionInfo extends StatelessWidget {
  const CompetitionInfo({
    super.key,
    required this.competition,
  });

  final CompetitionModel competition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(
          icon: Icons.calendar_today_outlined,
          title: 'Start Date',
          value: _formatOptionalDateTime(competition.startDate),
        ),

        const SizedBox(height: 12),

        _InfoRow(
          icon: Icons.event_available_outlined,
          title: 'End Date',
          value: _formatOptionalDateTime(competition.endDate),
        ),

        const SizedBox(height: 12),

        _InfoRow(
          icon: Icons.people_outline,
          title: 'Participants',
          value: _participantsText(),
        ),

        const SizedBox(height: 12),

        _InfoRow(
          icon: Icons.payments_outlined,
          title: 'Entry Fee',
          value: _entryFeeText(),
        ),

        const SizedBox(height: 12),

        _InfoRow(
          icon: Icons.verified_outlined,
          title: 'Approval',
          value: _approvalModeText(),
        ),

        const SizedBox(height: 12),

        _InfoRow(
          icon: Icons.visibility_outlined,
          title: 'Visibility',
          value: _visibilityText(),
        ),

        if (competition.waitingListEnabled) ...[
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.hourglass_bottom_outlined,
            title: 'Waiting List',
            value: 'Enabled',
          ),
        ],

        if (competition.paymentWindowMinutes != null &&
            competition.paymentWindowMinutes! > 0) ...[
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.timer_outlined,
            title: 'Payment Window',
            value: _paymentWindowText(),
          ),
        ],

        if (competition.refundPolicy.trim().isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.currency_exchange_outlined,
            title: 'Refund Policy',
            value: _refundPolicyText(),
          ),
        ],

        if (competition.description != null &&
            competition.description!.trim().isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            'Description',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            competition.description!.trim(),
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  String _participantsText() {
    final current = competition.currentParticipants;
    final max = competition.maxParticipants;

    if (max == null || max <= 0) {
      return '$current participants';
    }

    return '$current / $max participants';
  }

  String _entryFeeText() {
    if (competition.entryFee <= 0) {
      return 'Free';
    }

    return '${_formatNumber(competition.entryFee)} EGP';
  }

  String _approvalModeText() {
    switch (competition.approvalMode.toLowerCase().trim()) {
      case 'auto':
        return 'Automatic';

      case 'manual':
        return 'Manual';

      default:
        return competition.approvalMode;
    }
  }

  String _visibilityText() {
    switch (competition.visibility.toLowerCase().trim()) {
      case 'public':
        return 'Public';

      case 'private':
        return 'Private';

      default:
        return competition.visibility;
    }
  }

  String _paymentWindowText() {
    final minutes = competition.paymentWindowMinutes!;

    if (minutes < 60) {
      return '$minutes minutes';
    }

    final hours = minutes / 60;

    if (minutes % 60 == 0) {
      final hoursValue = hours.toInt();

      if (hoursValue == 1) {
        return '1 hour';
      }

      return '$hoursValue hours';
    }

    return '$minutes minutes';
  }

  String _refundPolicyText() {
    switch (competition.refundPolicy.toLowerCase().trim()) {
      case 'none':
        return 'No refund';

      case 'full':
        return 'Full refund';

      case 'partial':
        return 'Partial refund';

      default:
        return competition.refundPolicy;
    }
  }

  String _formatNumber(double value) {
    if (value == value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }

  String _formatOptionalDateTime(DateTime? dateTime) {
    if (dateTime == null) {
      return 'Date not available';
    }

    return _formatDateTime(dateTime);
  }

  String _formatDateTime(DateTime dateTime) {
    final local = dateTime.toLocal();

    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();

    final hour = local.hour == 0
        ? 12
        : local.hour > 12
        ? local.hour - 12
        : local.hour;

    final minute = local.minute.toString().padLeft(2, '0');

    final period = local.hour >= 12 ? 'PM' : 'AM';

    return '$day/$month/$year • $hour:$minute $period';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 21,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}