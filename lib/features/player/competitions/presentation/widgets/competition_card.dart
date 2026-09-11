import 'package:flutter/material.dart';

import 'package:e7m/features/player/competitions/models/competition_model.dart';

class CompetitionCard extends StatelessWidget {
  const CompetitionCard({
    super.key,
    required this.competition,
    this.onTap,
  });

  final CompetitionModel competition;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: theme.dividerColor.withOpacity(0.15),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CompetitionImage(
              imageUrl: competition.imageUrl,
              status: competition.status,
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    competition.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_hasDescription) ...[
                    const SizedBox(height: 8),
                    Text(
                      competition.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(0.65),
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    text: _formatDateRange(),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _InfoRow(
                          icon: Icons.people_outline,
                          text: _participantsText(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      _EntryFee(
                        amount: competition.entryFee,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool get _hasDescription {
    final description = competition.description;

    return description != null &&
        description.trim().isNotEmpty;
  }

  String _participantsText() {
    final current = competition.currentParticipants;
    final max = competition.maxParticipants;

    if (max == null) {
      return '$current participants';
    }

    return '$current / $max participants';
  }

  String _formatDateRange() {
    final start = competition.startDate;
    final end = competition.endDate;

    if (start == null && end == null) {
      return 'Date not available';
    }

    String format(DateTime date) {
      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    }

    if (start == null) {
      return format(end!);
    }

    if (end == null) {
      return format(start);
    }

    final startText = format(start);
    final endText = format(end);

    if (startText == endText) {
      return startText;
    }

    return '$startText - $endText';
  }
}

// ============================================================
// COMPETITION IMAGE
// ============================================================

class _CompetitionImage extends StatelessWidget {
  const _CompetitionImage({
    required this.imageUrl,
    required this.status,
  });

  final String? imageUrl;
  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 190,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _buildImage(theme),
          Positioned(
            top: 14,
            right: 14,
            child: _StatusBadge(
              status: status,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(ThemeData theme) {
    final url = imageUrl?.trim();

    if (url == null || url.isEmpty) {
      return _PlaceholderImage(
        theme: theme,
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (
          context,
          error,
          stackTrace,
          ) {
        return _PlaceholderImage(
          theme: theme,
        );
      },
      loadingBuilder: (
          context,
          child,
          loadingProgress,
          ) {
        if (loadingProgress == null) {
          return child;
        }

        return _PlaceholderImage(
          theme: theme,
          showLoading: true,
        );
      },
    );
  }
}

// ============================================================
// IMAGE PLACEHOLDER
// ============================================================

class _PlaceholderImage extends StatelessWidget {
  const _PlaceholderImage({
    required this.theme,
    this.showLoading = false,
  });

  final ThemeData theme;
  final bool showLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: showLoading
          ? const CircularProgressIndicator()
          : Icon(
        Icons.emoji_events_outlined,
        size: 56,
        color: theme.colorScheme.primary,
      ),
    );
  }
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final label = _statusLabel(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withOpacity(0.92),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _statusLabel(String value) {
    switch (value.toLowerCase()) {
      case 'open':
        return 'Open';

      case 'upcoming':
        return 'Upcoming';

      case 'ongoing':
        return 'Ongoing';

      case 'completed':
        return 'Completed';

      case 'cancelled':
      case 'canceled':
        return 'Cancelled';

      default:
        return value.isEmpty
            ? 'Competition'
            : value;
    }
  }
}

// ============================================================
// INFO ROW
// ============================================================

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ENTRY FEE
// ============================================================

class _EntryFee extends StatelessWidget {
  const _EntryFee({
    required this.amount,
  });

  final double amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        amount <= 0
            ? 'Free'
            : '${amount.toStringAsFixed(0)} EGP',
        style: theme.textTheme.labelLarge?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}