import 'competition_registrations_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/competition_model.dart';
import 'competition_prizes_screen.dart';
import 'competition_invitations_screen.dart';
import 'competition_tournament_management_screen.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class CompetitionDetailsScreen extends StatelessWidget {
  final CompetitionModel competition;

  const CompetitionDetailsScreen({
    super.key,
    required this.competition,
  });

  static const Color primaryColor = Color(0xff7CC000);
  static const Color darkColor = Color(0xff1E1446);

  String _t(
      BuildContext context,
      String key,
      ) {
    return context
        .read<LanguageProvider>()
        .translate(key);
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) {
      return _t(context, 'not_set');
    }

    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _formatDateTime(BuildContext context, DateTime? date) {
    if (date == null) {
      return _t(context, 'not_set');
    }

    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final hour =
    date.hour.toString().padLeft(2, '0');

    final minute =
    date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year}  $hour:$minute';
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

  String _statusText(BuildContext context, String status) {
    switch (status.toLowerCase()) {
      case 'open':
      case 'registration_open':
        return _t(
          context,
          'registration_open',
        );

      default:
        return status;
    }
  }

  Widget _buildStatusBadge(BuildContext context) {
    final color =
    _statusColor(competition.status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        _statusText(context, competition.status),
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: darkColor,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xffF7F8FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primaryColor.withValues(
                alpha: 0.10,
              ),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: primaryColor,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: darkColor,
                    fontSize: 14,
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

  Widget _buildManagementCard(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: primaryColor.withValues(
                  alpha: 0.10,
                ),
                borderRadius:
                BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: primaryColor,
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: darkColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider =
    context.watch<LanguageProvider>();

    final isArabic =
        languageProvider.locale.languageCode ==
            'ar';

    return Directionality(
      textDirection: isArabic
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor:
        const Color(0xffF6F8FB),

        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: darkColor,
          elevation: 0,
          title: Text(
            competition.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
// ==================================================
// HEADER
// ==================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 62,
                          height: 62,
                          decoration: BoxDecoration(
                            color:
                            primaryColor.withValues(
                              alpha: 0.10,
                            ),
                            borderRadius:
                            BorderRadius.circular(
                              17,
                            ),
                          ),
                          child: const Icon(
                            Icons
                                .emoji_events_outlined,
                            color: primaryColor,
                            size: 34,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment
                                .start,
                            children: [
                              Text(
                                competition.name,
                                style:
                                const TextStyle(
                                  color: darkColor,
                                  fontSize: 21,
                                  fontWeight:
                                  FontWeight.w900,
                                ),
                              ),

                              const SizedBox(height: 8),

                              _buildStatusBadge(
                                context,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    if (competition.description !=
                        null &&
                        competition.description!
                            .trim()
                            .isNotEmpty) ...[
                      const SizedBox(height: 20),

                      Text(
                        competition.description!,
                        style: TextStyle(
                          color:
                          Colors.grey.shade700,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

// ==================================================
// BASIC INFORMATION
// ==================================================

              _buildSectionTitle(
                'Competition Information',
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    if (competition.location !=
                        null &&
                        competition.location!
                            .trim()
                            .isNotEmpty)
                      _buildInfoRow(
                        icon: Icons
                            .location_on_outlined,
                        title: 'Location',
                        value:
                        competition.location!,
                      ),

                    _buildInfoRow(
                      icon: Icons
                          .sports_soccer_outlined,
                      title: 'Competition Type',
                      value:
                      competition.competitionType,
                    ),

                    _buildInfoRow(
                      icon: Icons
                          .payments_outlined,
                      title: _t(
                        context,
                        'entry_fee',
                      ),
                      value:
                      '${competition.entryFee} EGP',
                    ),

                    _buildInfoRow(
                      icon: Icons.visibility_outlined,
                      title: 'Visibility',
                      value:
                      competition.visibility,
                    ),

                    _buildInfoRow(
                      icon: Icons
                          .verified_user_outlined,
                      title: 'Approval Mode',
                      value:
                      competition.approvalMode,
                    ),

                    _buildInfoRow(
                      icon: Icons
                          .money_off_csred_outlined,
                      title: 'Refund Policy',
                      value:
                      competition.refundPolicy,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

// ==================================================
// DATES
// ==================================================

              _buildSectionTitle(
                'Dates',
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon:
                      Icons.play_circle_outline,
                      title: _t(
                        context,
                        'competition_starts',
                      ),
                      value: _formatDateTime(
                        context,
                        competition.startDate,
                      ),
                    ),

                    _buildInfoRow(
                      icon:
                      Icons.stop_circle_outlined,
                      title: _t(
                        context,
                        'competition_ends',
                      ),
                      value: _formatDateTime(
                        context,
                        competition.endDate,
                      ),
                    ),

                    _buildInfoRow(
                      icon:
                      Icons.how_to_reg_outlined,
                      title:
                      'Registration Start',
                      value: _formatDateTime(
                        context,
                        competition
                            .registrationStartDate,
                      ),
                    ),

                    _buildInfoRow(
                      icon:
                      Icons.event_busy_outlined,
                      title:
                      'Registration Deadline',
                      value: _formatDateTime(
                        context,
                        competition
                            .registrationDeadline,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

// ==================================================
// PARTICIPATION
// ==================================================

              _buildSectionTitle(
                'Participation',
              ),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      icon: Icons.groups_outlined,
                      title:
                      _t(
                        context,
                        'maximum_teams',
                      ),
                      value:
                      competition.maxParticipants
                          ?.toString() ??
                          _t(
                            context,
                            'not_set',
                          ),
                    ),

                    _buildInfoRow(
                      icon:
                      Icons.person_add_alt_1_outlined,
                      title:
                      'Minimum Players Per Team',
                      value:
                      competition
                          .minPlayersPerTeam
                          ?.toString() ??
                          _t(
                            context,
                            'not_set',
                          ),
                    ),

                    _buildInfoRow(
                      icon: Icons.group_outlined,
                      title:
                      'Maximum Players Per Team',
                      value:
                      competition
                          .maxPlayersPerTeam
                          ?.toString() ??
                          _t(
                            context,
                            'not_set',
                          ),
                    ),

                    _buildInfoRow(
                      icon:
                      Icons.hourglass_empty_outlined,
                      title:
                      'Waiting List',
                      value: competition
                          .waitingListEnabled
                          ? 'Enabled'
                          : 'Disabled',
                    ),

                    _buildInfoRow(
                      icon:
                      Icons.person_remove_outlined,
                      title:
                      'Allow Withdrawal',
                      value: competition
                          .allowWithdrawal
                          ? 'Allowed'
                          : 'Not Allowed',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

// ==================================================
// MANAGEMENT
// ==================================================

              _buildSectionTitle(
                'Competition Management',
              ),

              _buildManagementCard(
                context,
                icon:
                Icons.how_to_reg_outlined,
                title:
                'Registrations',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          CompetitionRegistrationsScreen(
                            competition: competition,
                          ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              _buildManagementCard(
                context,
                icon:
                Icons.emoji_events_outlined,
                title:
                'Prizes',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CompetitionPrizesScreen(
                        competition: competition,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              _buildManagementCard(
                context,
                icon:
                Icons.mail_outline,
                title:
                'Invitations',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          CompetitionInvitationsScreen(
                            competition: competition,
                          ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 10),

              _buildManagementCard(
                context,
                icon: Icons.account_tree_outlined,
                title: 'Tournament Management',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CompetitionTournamentManagementScreen(
                        competition: competition,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}