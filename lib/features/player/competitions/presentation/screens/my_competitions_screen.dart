import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/competition_model.dart';
import '../../providers/competition_provider.dart';
import 'competition_details_screen.dart';
import 'competition_payment_screen.dart';
import 'package:e7m/shared/localization/app_translations.dart';

class MyCompetitionsScreen extends StatelessWidget {
  const MyCompetitionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompetitionProvider()..loadMyCompetitions(),
      child: const _MyCompetitionsView(),
    );
  }
}

class _MyCompetitionsView extends StatelessWidget {
  const _MyCompetitionsView();

  static const Color primaryGreen = Color(0xff7CC000);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompetitionProvider>();

    final myCompetitions = provider.myCompetitions;

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'My Competitions'.tr,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: _buildBody(
        context,
        provider,
        myCompetitions,
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      CompetitionProvider provider,
      List<CompetitionModel> competitions,
      ) {
    if (provider.isLoading && provider.competitions.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: primaryGreen,
        ),
      );
    }

    if (provider.hasError && provider.competitions.isEmpty) {
      return _ErrorState(
        message: provider.errorMessage ??
            'Something went wrong. Please try again.'.tr,
        onRetry: provider.loadMyCompetitions,
      );
    }

    if (competitions.isEmpty) {
      return RefreshIndicator(
        color: primaryGreen,
        onRefresh: provider.loadMyCompetitions,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 140),
            _EmptyState(),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: primaryGreen,
      onRefresh: provider.loadMyCompetitions,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          30,
        ),
        itemCount: competitions.length,
        separatorBuilder: (_, __) =>
        const SizedBox(height: 14),
        itemBuilder: (context, index) {
          final competition = competitions[index];

          return _MyCompetitionCard(
            competition: competition,
            onTap: () {
              _openCompetitionDetails(
                context,
                competition,
              );
            },
            onPayment: competition.registrationId == null
                ? null
                : () {
              _openPaymentScreen(
                context,
                competition,
              );
            },
          );
        },
      ),
    );
  }

  void _openCompetitionDetails(
      BuildContext context,
      CompetitionModel competition,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompetitionDetailsScreen(
          competition: competition,
        ),
      ),
    );
  }

  void _openPaymentScreen(
      BuildContext context,
      CompetitionModel competition,
      ) {
    final registrationId = competition.registrationId;

    if (registrationId == null) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompetitionPaymentScreen(
          competition: competition,
          registrationId: registrationId,
        ),
      ),
    );
  }
}

// ============================================================
// MY COMPETITION CARD
// ============================================================

class _MyCompetitionCard extends StatelessWidget {
  const _MyCompetitionCard({
    required this.competition,
    required this.onTap,
    this.onPayment,
  });

  final CompetitionModel competition;
  final VoidCallback onTap;
  final VoidCallback? onPayment;

  static const Color primaryGreen = Color(0xff7CC000);

  @override
  Widget build(BuildContext context) {
    final status =
    (competition.registrationStatus ?? '')
        .toLowerCase()
        .trim();

    final bool paymentPending =
        status == 'payment_pending';

    final bool paid =
        status == 'paid';

    final bool approved =
        status == 'approved' ||
            status == 'registered';

    final bool expired =
        status == 'expired';

    final bool rejected =
        status == 'rejected';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xffE7E9ED),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.04,
                ),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        competition.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff15171A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _StatusBadge(
                      status: status,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                if (competition.location != null &&
                    competition.location!
                        .trim()
                        .isNotEmpty)
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    text: competition.location!,
                  ),

                const SizedBox(height: 8),

                _InfoRow(
                  icon: Icons.calendar_month_outlined,
                  text: _formatDateRange(
                    competition.startDate,
                    competition.endDate,
                  ),
                ),

                const SizedBox(height: 8),

                _InfoRow(
                  icon: Icons.groups_outlined,
                  text:
                  competition.maxParticipants != null
                      ? '{current} / {max} participants'.trArgs({
                    'current': competition.currentParticipants,
                    'max': competition.maxParticipants,
                  })
                      : '{count} participants'.trArgs({
                    'count': competition.currentParticipants,
                  }),
                ),

                const SizedBox(height: 8),

                _InfoRow(
                  icon: Icons.payments_outlined,
                  text: competition.entryFee > 0
                      ? '{amount} EGP'.trArgs({'amount': competition.entryFee.toStringAsFixed(2)})
                      : 'Free'.tr,
                ),

                if (paymentPending &&
                    competition.paymentDeadline != null) ...[
                  const SizedBox(height: 12),
                  _PaymentDeadline(
                    deadline:
                    competition.paymentDeadline!,
                  ),
                ],

                if (paymentPending &&
                    onPayment != null) ...[
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onPayment,
                      icon: const Icon(
                        Icons.payment_outlined,
                        size: 19,
                      ),
                      label: Text(
                        'Complete Payment'.tr,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize:
                        const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],

                if (paid || approved) ...[
                  const SizedBox(height: 12),
                  _ParticipationMessage(
                    icon: Icons.check_circle_outline,
                    text: 'You are registered in this competition.'.tr,
                  ),
                ],

                if (expired) ...[
                  const SizedBox(height: 12),
                  _ParticipationMessage(
                    icon: Icons.timer_off_outlined,
                    text: 'This registration has expired.'.tr,
                  ),
                ],

                if (rejected) ...[
                  const SizedBox(height: 12),
                  _ParticipationMessage(
                    icon: Icons.cancel_outlined,
                    text: 'This registration was rejected.'.tr,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDateRange(
      DateTime? start,
      DateTime? end,
      ) {
    if (start == null && end == null) {
      return 'Date not available'.tr;
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

    return '${format(start)} - ${format(end)}';
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
    final config = _statusConfig(status);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          color: config.textColor,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  _StatusConfig _statusConfig(String status) {
    switch (status) {
      case 'payment_pending':
        return _StatusConfig(
          label: 'PAYMENT PENDING'.tr,
          backgroundColor: Color(0xfffff4d6),
          textColor: Color(0xff9A6B00),
        );

      case 'paid':
        return _StatusConfig(
          label: 'PAID'.tr,
          backgroundColor: Color(0xffe5f7d2),
          textColor: Color(0xff3E7800),
        );

      case 'approved':
        return _StatusConfig(
          label: 'APPROVED'.tr,
          backgroundColor: Color(0xffe5f7d2),
          textColor: Color(0xff3E7800),
        );

      case 'registered':
        return _StatusConfig(
          label: 'REGISTERED'.tr,
          backgroundColor: Color(0xffe5f7d2),
          textColor: Color(0xff3E7800),
        );

      case 'expired':
        return _StatusConfig(
          label: 'EXPIRED'.tr,
          backgroundColor: Color(0xffeeeeee),
          textColor: Color(0xff666666),
        );

      case 'rejected':
        return _StatusConfig(
          label: 'REJECTED'.tr,
          backgroundColor: Color(0xffffe4e4),
          textColor: Color(0xffB42318),
        );

      case 'cancelled':
        return _StatusConfig(
          label: 'CANCELLED'.tr,
          backgroundColor: Color(0xffffe4e4),
          textColor: Color(0xffB42318),
        );

      case 'waitlisted':
        return _StatusConfig(
          label: 'WAITLISTED'.tr,
          backgroundColor: Color(0xffe9e7ff),
          textColor: Color(0xff5146A5),
        );

      case 'pending':
        return _StatusConfig(
          label: 'PENDING'.tr,
          backgroundColor: Color(0xfffff4d6),
          textColor: Color(0xff9A6B00),
        );

      default:
        return _StatusConfig(
          label: status.isEmpty
              ? 'UNKNOWN'.tr
              : status.replaceAll('_', ' ').toUpperCase(),
          backgroundColor:
          const Color(0xffeeeeee),
          textColor: const Color(0xff555555),
        );
    }
  }
}

class _StatusConfig {
  const _StatusConfig({
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  final String label;
  final Color backgroundColor;
  final Color textColor;
}

// ============================================================
// PAYMENT DEADLINE
// ============================================================

class _PaymentDeadline extends StatelessWidget {
  const _PaymentDeadline({
    required this.deadline,
  });

  final DateTime deadline;

  @override
  Widget build(BuildContext context) {
    final formatted =
        '${deadline.day.toString().padLeft(2, '0')}/'
        '${deadline.month.toString().padLeft(2, '0')}/'
        '${deadline.year} '
        '${deadline.hour.toString().padLeft(2, '0')}:'
        '${deadline.minute.toString().padLeft(2, '0')}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xfffff8e8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xffffe2a8),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 20,
            color: Color(0xff9A6B00),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Payment deadline: {deadline}'.trArgs({'deadline': formatted}),
              style: const TextStyle(
                color: Color(0xff765400),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PARTICIPATION MESSAGE
// ============================================================

class _ParticipationMessage
    extends StatelessWidget {
  const _ParticipationMessage({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xffF1F8E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const SizedBox(width: 1),
          Icon(
            icon,
            size: 19,
            color: const Color(0xff4E8A00),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xff426F08),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
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
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xff7CC000),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xff5E636B),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 30,
      ),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              color: const Color(0xffEAF6DC),
              borderRadius: BorderRadius.circular(28),
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              size: 48,
              color: Color(0xff7CC000),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            'No Competitions Yet'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xff17191C),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'You are not registered in any competition yet.'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xff747A82),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<bool> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load competitions'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff70757D),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xff7CC000),
                foregroundColor: Colors.white,
                elevation: 0,
                minimumSize:
                const Size(150, 46),
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Try Again'.tr,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}