import 'package:flutter/material.dart';

import '../../data/models/competition_model.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class CompetitionCard extends StatelessWidget {
  final CompetitionModel competition;
  final LanguageProvider languageProvider;
  final VoidCallback? onTap;

  const CompetitionCard({
    super.key,
    required this.competition,
    required this.languageProvider,
    this.onTap,
  });

  static const Color primaryColor = Color(0xff7CC000);
  static const Color darkColor = Color(0xff1E1446);

  String _t(String key) {
    return languageProvider.translate(key);
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return _t('not_set');
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Draft';

      case 'published':
        return 'Published';

      case 'open':
      case 'registration_open':
        return _t('registration_open');

      case 'closed':
        return 'Closed';

      case 'ongoing':
        return 'Ongoing';

      case 'completed':
        return 'Completed';

      case 'cancelled':
        return 'Cancelled';

      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'published':
      case 'registration_open':
        return primaryColor;

      case 'ongoing':
        return Colors.blue;

      case 'completed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      case 'closed':
        return Colors.orange;

      case 'draft':
        return Colors.grey;

      default:
        return Colors.blueGrey;
    }
  }

  Widget _buildStatusBadge() {
    final color = _statusColor(competition.status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusText(competition.status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xffF7F8FA),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(
                        alpha: 0.10,
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.emoji_events_outlined,
                      color: primaryColor,
                      size: 28,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          competition.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: darkColor,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),

                        if (competition.location != null &&
                            competition.location!
                                .trim()
                                .isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  competition.location!,
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: 8),

                  _buildStatusBadge(),
                ],
              ),

              const SizedBox(height: 18),

              const Divider(height: 1),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.calendar_today_outlined,
                      title: _t('competition_starts'),
                      value: _formatDate(
                        competition.startDate,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.event_available_outlined,
                      title: _t('competition_ends'),
                      value: _formatDate(
                        competition.endDate,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.payments_outlined,
                      title: _t('entry_fee'),
                      value:
                      '${competition.entryFee} EGP',
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.groups_outlined,
                      title: _t('maximum_teams'),
                      value:
                      competition.maxParticipants
                          ?.toString() ??
                          _t('not_set'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}