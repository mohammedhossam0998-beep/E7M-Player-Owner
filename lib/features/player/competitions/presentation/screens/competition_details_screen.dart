import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/competition_model.dart';
import '../../models/competition_goal_model.dart';
import '../../models/competition_match_model.dart';
import '../../providers/competition_provider.dart';
import 'competition_payment_screen.dart';
import 'package:e7m/shared/localization/app_translations.dart';

class CompetitionDetailsScreen extends StatelessWidget {
  const CompetitionDetailsScreen({
    super.key,
    required this.competition,
  });

  final CompetitionModel competition;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);
  static const Color e7mDarkNavy = Color(0xFF031B3A);
  static const Color background = Color(0xFFF7F9FC);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompetitionProvider()
        ..loadCompetitionStandings(competition.id)
        ..loadCompetitionMatches(competition.id)
        ..loadCompetitionGoals(competition.id)
        ..loadCompetitionBracket(competition.id),
      child: _CompetitionDetailsView(
        competition: competition,
      ),
    );
  }
}

class _CompetitionDetailsView extends StatelessWidget {
  const _CompetitionDetailsView({
    required this.competition,
  });

  final CompetitionModel competition;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);
  static const Color e7mDarkNavy = Color(0xFF031B3A);
  static const Color background = Color(0xFFF7F9FC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              leading: Padding(
                padding: const EdgeInsets.all(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: e7mNavy.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: e7mNavy,
                    ),
                  ),
                ),
              ),
              title: Text(
                'Competition Details'.tr,
                style: TextStyle(
                  color: e7mNavy,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              centerTitle: false,
            ),
            SliverToBoxAdapter(
              child: _CompetitionHero(
                competition: competition,
              ),
            ),
            SliverToBoxAdapter(
              child: _CompetitionContent(
                competition: competition,
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _RegistrationBottomBar(
        competition: competition,
      ),
    );
  }
}

// ============================================================
// HERO
// ============================================================

class _CompetitionHero extends StatelessWidget {
  const _CompetitionHero({
    required this.competition,
  });

  final CompetitionModel competition;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);
  static const Color e7mDarkNavy = Color(0xFF031B3A);

  @override
  Widget build(BuildContext context) {
    return Consumer<CompetitionProvider>(
      builder: (context, provider, _) {
        // ============================================================
        // The status pill only becomes a "register" action when the
        // competition itself is available AND the player does not
        // already have a registration (pending, paid, waitlisted...).
        // Any other case renders the pill as a plain, non-tappable
        // badge, exactly like before.
        // ============================================================

        final rawRegistrationStatus =
            provider.registration?.status ??
                competition.registrationStatus;

        final registrationStatus =
        rawRegistrationStatus?.trim().toLowerCase();

        final isAvailableToRegister = registrationStatus == null &&
            competition.status.trim().toLowerCase() == 'available';

        return Container(
          margin: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            20,
          ),
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                e7mNavy,
                e7mDarkNavy,
              ],
            ),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: e7mNavy.withValues(alpha: 0.16),
                blurRadius: 22,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      competition.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _StatusBadge(
                    status: competition.status,
                    onTap: isAvailableToRegister
                        ? (provider.isLoading
                        ? null
                        : () => _performRegistration(
                      context,
                      provider,
                      competition,
                    ))
                        : null,
                  ),
                ],
              ),
              if (_hasText(competition.description)) ...[
                const SizedBox(height: 14),
                Text(
                  competition.description!,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    height: 1.55,
                  ),
                ),
              ],
              if (_hasText(competition.location)) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: e7mGreen,
                      size: 19,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        competition.location!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// CONTENT
// ============================================================

class _CompetitionContent extends StatelessWidget {
  const _CompetitionContent({
    required this.competition,
  });

  final CompetitionModel competition;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            icon: Icons.info_outline_rounded,
            title: 'Competition Information'.tr,
          ),
          const SizedBox(height: 12),
          _InfoGrid(
            competition: competition,
          ),
          const SizedBox(height: 26),
          _SectionTitle(
            icon: Icons.calendar_month_outlined,
            title: 'Schedule'.tr,
          ),
          const SizedBox(height: 12),
          _ScheduleCard(
            competition: competition,
          ),
          const SizedBox(height: 26),
          _SectionTitle(
            icon: Icons.people_outline_rounded,
            title: 'Participants'.tr,
          ),
          const SizedBox(height: 12),
          _ParticipantsCard(
            competition: competition,
          ),
          const SizedBox(height: 26),
          _SectionTitle(
            icon: Icons.leaderboard_outlined,
            title: 'Standings'.tr,
          ),
          const SizedBox(height: 12),
          const _StandingsCard(),
          const SizedBox(height: 26),
          _SectionTitle(
            icon: Icons.sports_soccer_rounded,
            title: 'Goals'.tr,
          ),
          const SizedBox(height: 12),
          const _GoalsCard(),
          const SizedBox(height: 26),
          _SectionTitle(
            icon: Icons.sports_soccer_outlined,
            title: 'Matches'.tr,
          ),
          const SizedBox(height: 12),
          const _MatchesCard(),
          const SizedBox(height: 16),
          const _BracketCard(),
          const SizedBox(height: 26),
          _SectionTitle(
            icon: Icons.payments_outlined,
            title: 'Payment'.tr,
          ),
          const SizedBox(height: 12),
          _PaymentCard(
            competition: competition,
          ),
          if (_hasText(competition.refundPolicy)) ...[
            const SizedBox(height: 26),
            _SectionTitle(
              icon: Icons.assignment_return_outlined,
              title: 'Refund Policy'.tr,
            ),
            const SizedBox(height: 12),
            _SimpleCard(
              child: Text(
                competition.refundPolicy,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// INFO GRID
// ============================================================

class _InfoGrid extends StatelessWidget {
  const _InfoGrid({
    required this.competition,
  });

  final CompetitionModel competition;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        return GridView.count(
          crossAxisCount: width >= 600 ? 4 : 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: width >= 600 ? 1.8 : 1.45,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _InfoTile(
              icon: Icons.sports_soccer_rounded,
              title: 'Type'.tr,
              value: _competitionType(
                competition.competitionType,
              ),
            ),
            _InfoTile(
              icon: Icons.verified_outlined,
              title: 'Approval'.tr,
              value: _approvalMode(
                competition.approvalMode,
              ),
            ),
            _InfoTile(
              icon: Icons.visibility_outlined,
              title: 'Visibility'.tr,
              value: _visibility(
                competition.visibility,
              ),
            ),
            _InfoTile(
              icon: Icons.event_available_outlined,
              title: 'Registration'.tr,
              value: competition.allowWithdrawal
                  ? 'Withdrawal allowed'.tr
                  : 'No withdrawal'.tr,
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// SCHEDULE
// ============================================================

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({
    required this.competition,
  });

  final CompetitionModel competition;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return _SimpleCard(
      child: Column(
        children: [
          _DateRow(
            icon: Icons.play_circle_outline_rounded,
            title: 'Starts'.tr,
            date: competition.startDate,
          ),
          const Padding(
            padding: EdgeInsets.only(
              left: 21,
              top: 10,
              bottom: 10,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: SizedBox(
                height: 18,
                child: VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: Color(0xFFE3E7ED),
                ),
              ),
            ),
          ),
          _DateRow(
            icon: Icons.flag_outlined,
            title: 'Ends'.tr,
            date: competition.endDate,
          ),
          if (competition.registrationDeadline != null) ...[
            const Divider(height: 28),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: e7mGreen.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.timer_outlined,
                    color: e7mGreen,
                    size: 21,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Registration deadline'.tr,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _formatDateTime(
                          competition.registrationDeadline!,
                        ),
                        style: const TextStyle(
                          color: e7mNavy,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// PARTICIPANTS
// ============================================================

class _StandingsCard extends StatelessWidget {
  const _StandingsCard();

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Consumer<CompetitionProvider>(
      builder: (context, provider, _) {
        final standings = provider.standings?['standings'];

        // Loading
        if (provider.isLoading && standings == null) {
          return const _SimpleCard(
            child: SizedBox(
              height: 72,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: e7mGreen,
                  ),
                ),
              ),
            ),
          );
        }

        // Error
        if (provider.errorMessage != null && standings == null) {
          return _SimpleCard(
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent.shade200,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // No standings
        if (standings is! List || standings.isEmpty) {
          return _SimpleCard(
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: e7mGreen.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.leaderboard_outlined,
                    color: e7mGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No standings available yet.'.tr,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return _SimpleCard(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: e7mNavy.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(
                        '#',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: e7mNavy,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Participant'.tr,
                        style: TextStyle(
                          color: e7mNavy,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        'P',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: e7mNavy,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        'W',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: e7mNavy,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        'D',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: e7mNavy,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 32,
                      child: Text(
                        'L',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: e7mNavy,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 38,
                      child: Text(
                        'Pts'.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: e7mGreen,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              for (var i = 0; i < standings.length; i++) ...[
                _StandingRow(
                  standing: standings[i],
                ),
                if (i != standings.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(height: 1),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _StandingRow extends StatelessWidget {
  const _StandingRow({
    required this.standing,
  });

  final dynamic standing;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    final data = Map<String, dynamic>.from(standing as Map);

    final position = data['position'];
    final participant = data['participant'];

    final participantData = participant is Map
        ? Map<String, dynamic>.from(participant)
        : <String, dynamic>{};

    final name =
    participantData['name']?.toString().trim().isNotEmpty == true
        ? participantData['name'].toString().trim()
        : 'Participant'.tr;

    final played = data['played'] ?? 0;
    final wins = data['wins'] ?? 0;
    final draws = data['draws'] ?? 0;
    final losses = data['losses'] ?? 0;
    final points = data['points'] ?? 0;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 4,
        vertical: 4,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                color: position == 1
                    ? e7mGreen.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$position',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: position == 1
                      ? e7mGreen
                      : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: e7mNavy,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),

          _StandingNumber(value: played),
          _StandingNumber(value: wins),
          _StandingNumber(value: draws),
          _StandingNumber(value: losses),

          SizedBox(
            width: 38,
            child: Text(
              '$points',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: e7mGreen,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingNumber extends StatelessWidget {
  const _StandingNumber({
    required this.value,
  });

  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      child: Text(
        '$value',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.grey.shade700,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GoalsCard extends StatelessWidget {
  const _GoalsCard();

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Consumer<CompetitionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.goals.isEmpty) {
          return const _SimpleCard(
            child: SizedBox(
              height: 72,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: e7mGreen,
                  ),
                ),
              ),
            ),
          );
        }

        if (provider.errorMessage != null && provider.goals.isEmpty) {
          return _SimpleCard(
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent.shade200,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.goals.isEmpty) {
          return _SimpleCard(
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: e7mGreen.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.sports_soccer_outlined,
                    color: e7mGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No goals recorded yet.'.tr,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return _SimpleCard(
          child: Column(
            children: [
              for (var i = 0; i < provider.goals.length; i++) ...[
                _GoalRow(goal: provider.goals[i]),
                if (i != provider.goals.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.goal,
  });

  final CompetitionGoalModel goal;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    final name = goal.playerName?.trim().isNotEmpty == true
        ? goal.playerName!.trim()
        : 'Player {id}'.trArgs({'id': goal.playerId});

    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: e7mGreen.withValues(alpha: 0.10),
          backgroundImage: _hasText(goal.playerImage)
              ? NetworkImage(goal.playerImage!)
              : null,
          child: _hasText(goal.playerImage)
              ? null
              : const Icon(
            Icons.person_outline_rounded,
            color: e7mGreen,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: e7mNavy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                goal.isOwnGoal ? 'Own goal'.tr : 'Goal'.tr,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        if (goal.minute != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: e7mGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '${goal.minute}',
              style: const TextStyle(
                color: e7mGreen,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
      ],
    );
  }
}

class _MatchesCard extends StatelessWidget {
  const _MatchesCard();

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Consumer<CompetitionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.matches.isEmpty) {
          return const _SimpleCard(
            child: SizedBox(
              height: 72,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: e7mGreen,
                  ),
                ),
              ),
            ),
          );
        }

        if (provider.errorMessage != null && provider.matches.isEmpty) {
          return _SimpleCard(
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent.shade200,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (provider.matches.isEmpty) {
          return _SimpleCard(
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: e7mGreen.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.event_note_outlined,
                    color: e7mGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No matches available yet.'.tr,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return _SimpleCard(
          child: Column(
            children: [
              for (var i = 0; i < provider.matches.length; i++) ...[
                _MatchRow(match: provider.matches[i]),
                if (i != provider.matches.length - 1)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Divider(height: 1),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _MatchRow extends StatelessWidget {
  const _MatchRow({
    required this.match,
  });

  final CompetitionMatchModel match;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    final homeName = _participantName(
      playerId: match.homePlayerId,
      teamId: match.homeTeamId,
    );

    final awayName = _participantName(
      playerId: match.awayPlayerId,
      teamId: match.awayTeamId,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                homeName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: e7mNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _ScoreBadge(match: match),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                awayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: e7mNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            if (_hasText(match.round))
              _MatchMeta(
                icon: Icons.account_tree_outlined,
                text: match.round!,
              ),
            if (_hasText(match.round) && match.matchNumber != null)
              const SizedBox(width: 12),
            if (match.matchNumber != null)
              _MatchMeta(
                icon: Icons.tag_rounded,
                text: 'Match {number}'.trArgs({'number': match.matchNumber}),
              ),
            const Spacer(),
            if (match.matchDate != null)
              _MatchMeta(
                icon: Icons.calendar_today_outlined,
                text: _formatDateTime(match.matchDate!),
              ),
          ],
        ),
      ],
    );
  }

  static String _participantName({
    int? playerId,
    int? teamId,
  }) {
    if (playerId != null) return 'Player {id}'.trArgs({'id': playerId});
    if (teamId != null) return 'Team {id}'.trArgs({'id': teamId});
    return 'TBD'.tr;
  }
}

class _ScoreBadge extends StatelessWidget {
  const _ScoreBadge({
    required this.match,
  });

  final CompetitionMatchModel match;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    final hasScore = match.hasResult;

    return Container(
      constraints: const BoxConstraints(minWidth: 58),
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: hasScore
            ? e7mNavy.withValues(alpha: 0.08)
            : e7mGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        hasScore
            ? '${match.homeScore} - ${match.awayScore}'
            : 'VS'.tr,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: e7mNavy,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _MatchMeta extends StatelessWidget {
  const _MatchMeta({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 13,
            color: Colors.grey.shade500,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantsCard extends StatelessWidget {
  const _ParticipantsCard({
    required this.competition,
  });

  final CompetitionModel competition;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    final max = competition.maxParticipants;
    final current = competition.currentParticipants;

    double progress = 0;

    if (max != null && max > 0) {
      progress = (current / max).clamp(0.0, 1.0);
    }

    return _SimpleCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: e7mGreen.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.groups_outlined,
                  color: e7mGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Registered players'.tr,
                      style: TextStyle(
                        color: e7mNavy,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      max == null
                          ? '{count} participants'.trArgs({'count': current})
                          : '{current} / {max} participants'.trArgs({'current': current, 'max': max}),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (max != null)
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(
                    color: e7mGreen,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
            ],
          ),
          if (max != null) ...[
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                color: e7mGreen,
              ),
            ),
          ],
          if (competition.waitingListEnabled) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(
                  Icons.hourglass_bottom_rounded,
                  color: e7mGreen,
                  size: 17,
                ),
                const SizedBox(width: 7),
                Text(
                  'Waiting list is enabled'.tr,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// PAYMENT
// ============================================================

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({
    required this.competition,
  });

  final CompetitionModel competition;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    final isFree = competition.entryFee <= 0;

    return _SimpleCard(
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isFree
                  ? e7mGreen.withValues(alpha: 0.10)
                  : e7mNavy.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              isFree
                  ? Icons.card_giftcard_outlined
                  : Icons.payments_rounded,
              color: isFree ? e7mGreen : e7mNavy,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isFree ? 'Free Entry'.tr : 'Entry Fee'.tr,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  isFree
                      ? 'No payment required'.tr
                      : '{amount} EGP'.trArgs({'amount': _formatMoney(competition.entryFee)}),
                  style: const TextStyle(
                    color: e7mNavy,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          if (!isFree &&
              competition.paymentWindowMinutes != null)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '{n} min'.trArgs({'n': competition.paymentWindowMinutes}),
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// BOTTOM REGISTRATION BAR
// ============================================================

class _RegistrationBottomBar extends StatelessWidget {
  const _RegistrationBottomBar({
    required this.competition,
  });

  final CompetitionModel competition;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          16,
          12,
          16,
          12,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 18,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Consumer<CompetitionProvider>(
          builder: (context, provider, _) {
            final rawRegistrationStatus =
                provider.registration?.status ??
                    competition.registrationStatus;

            final registrationStatus =
            rawRegistrationStatus?.trim().toLowerCase();

            final registrationId =
                provider.registration?.id ??
                    competition.registrationId;

            final isLoading = provider.isLoading;

            // ========================================================
            // PLAYER ALREADY HAS A REAL REGISTRATION
            // ========================================================
            //
            // Competition statuses such as "available" or "open"
            // are NOT player registration statuses.
            // Only the statuses below mean that this player already
            // has a registration. Everything else must go through
            // the Register Now action.
            // ========================================================

            final hasRegistration = registrationStatus != null &&
                {
                  'pending',
                  'approved',
                  'payment_pending',
                  'paid',
                  'rejected',
                  'cancelled',
                  'expired',
                  'waitlisted',
                }.contains(registrationStatus);

            if (hasRegistration) {
              // ------------------------------------------------------
              // PAYMENT PENDING
              // ------------------------------------------------------
              //
              // This covers both:
              // 1. First payment attempt
              // 2. Retry after rejected payment
              //
              // We use competition.registrationId as a fallback
              // because provider.registration may be null when the
              // details screen was opened directly.
              // ------------------------------------------------------

              if (registrationStatus == 'payment_pending' &&
                  registrationId != null) {
                final hasPreviousPayment =
                    competition.registrationStatus == 'payment_pending';

                return SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      _openPaymentScreen(
                        context,
                        registrationId,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: e7mGreen,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      e7mGreen.withValues(alpha: 0.45),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.payment_rounded,
                          size: 21,
                        ),
                        const SizedBox(width: 9),
                        Text(
                          hasPreviousPayment
                              ? 'Retry Payment'.tr
                              : 'Complete Payment'.tr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // ------------------------------------------------------
              // ANY OTHER REGISTRATION STATUS
              // ------------------------------------------------------

              return _RegisteredButton(
                status: registrationStatus!,
              );
            }

            // ========================================================
            // PLAYER IS NOT REGISTERED
            // ========================================================

            final isFull =
                competition.maxParticipants != null &&
                    competition.currentParticipants >=
                        competition.maxParticipants!;

            if (isFull && !competition.waitingListEnabled) {
              return _DisabledButton(
                text: 'Competition Full'.tr,
                icon: Icons.block_rounded,
              );
            }

            return SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                  _performRegistration(
                    context,
                    provider,
                    competition,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: e7mGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                  e7mGreen.withValues(alpha: 0.45),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                  width: 23,
                  height: 23,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : Row(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      isFull
                          ? Icons.hourglass_bottom_rounded
                          : Icons.how_to_reg_rounded,
                      size: 21,
                    ),
                    const SizedBox(width: 9),
                    Text(
                      isFull
                          ? 'Join Waiting List'.tr
                          : 'Register Now'.tr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _openPaymentScreen(
      BuildContext context,
      int registrationId,
      ) {
    Navigator.of(context).push(
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
// REGISTRATION ACTION (shared by the bottom bar AND the
// tappable "AVAILABLE" status badge in the hero)
// ============================================================

Future<void> _performRegistration(
    BuildContext context,
    CompetitionProvider provider,
    CompetitionModel competition,
    ) async {
  const e7mGreen = Color(0xFF7CC000);

  final success = await provider.registerForCompetition(
    competition.id,
  );

  if (!context.mounted) return;

  if (success) {
    final registration = provider.registration;

    if (registration?.status == 'payment_pending') {
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CompetitionPaymentScreen(
            competition: competition,
            registrationId: registration!.id,
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: e7mGreen,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          registration?.status == 'waitlisted'
              ? 'You have been added to the waiting list.'.tr
              : 'Registration completed successfully.'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        content: Text(
          provider.errorMessage ??
              'Failed to register for competition.'.tr,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REGISTERED BUTTON
// ============================================================

class _RegisteredButton extends StatelessWidget {
  const _RegisteredButton({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    final config = _registrationStatusConfig(status);

    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: config.backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: config.foregroundColor.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            config.icon,
            color: config.foregroundColor,
            size: 21,
          ),
          const SizedBox(width: 9),
          Text(
            config.label,
            style: TextStyle(
              color: config.foregroundColor,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DISABLED BUTTON
// ============================================================

class _DisabledButton extends StatelessWidget {
  const _DisabledButton({
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.grey.shade600,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: e7mGreen.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: e7mGreen,
            size: 19,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: e7mNavy,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// INFO TILE
// ============================================================

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE9EDF2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: e7mGreen,
            size: 21,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: e7mNavy,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DATE ROW
// ============================================================

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.icon,
    required this.title,
    required this.date,
  });

  final IconData icon;
  final String title;
  final DateTime? date;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: e7mGreen.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: e7mGreen,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                date == null ? 'Date not available'.tr : _formatDateTime(date!),
                style: const TextStyle(
                  color: e7mNavy,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// SIMPLE CARD
// ============================================================

class _SimpleCard extends StatelessWidget {
  const _SimpleCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE9EDF2),
        ),
      ),
      child: child,
    );
  }
}

// ============================================================
// STATUS BADGE
// ============================================================

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    this.onTap,
  });

  final String status;

  // When non-null, the badge becomes tappable (used for the
  // "AVAILABLE" pill so it can trigger registration directly).
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final config = _statusConfig(status);

    final badge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: config.foregroundColor.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: config.foregroundColor.withValues(
            alpha: onTap != null ? 0.4 : 0.18,
          ),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            config.label,
            style: TextStyle(
              color: config.foregroundColor,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.how_to_reg_rounded,
              color: config.foregroundColor,
              size: 12,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return badge;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: badge,
      ),
    );
  }
}

// ============================================================
// STATUS CONFIG
// ============================================================

class _StatusConfig {
  const _StatusConfig({
    required this.label,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final String label;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;
}

_StatusConfig _statusConfig(String status) {
  switch (status.toLowerCase()) {
    case 'open':
      return _StatusConfig(
        label: 'OPEN'.tr,
        icon: Icons.lock_open_rounded,
        foregroundColor: Color(0xFF4F8F00),
        backgroundColor: Color(0xFFEFF8E5),
      );

    case 'upcoming':
      return _StatusConfig(
        label: 'UPCOMING'.tr,
        icon: Icons.schedule_rounded,
        foregroundColor: Color(0xFF082B5C),
        backgroundColor: Color(0xFFEAF0F8),
      );

    case 'ongoing':
      return _StatusConfig(
        label: 'LIVE'.tr,
        icon: Icons.play_circle_rounded,
        foregroundColor: Color(0xFF16823A),
        backgroundColor: Color(0xFFE8F7ED),
      );

    case 'completed':
      return _StatusConfig(
        label: 'COMPLETED'.tr,
        icon: Icons.check_circle_outline_rounded,
        foregroundColor: Color(0xFF607080),
        backgroundColor: Color(0xFFF0F2F4),
      );

    case 'cancelled':
      return _StatusConfig(
        label: 'CANCELLED'.tr,
        icon: Icons.cancel_outlined,
        foregroundColor: Color(0xFFC62828),
        backgroundColor: Color(0xFFFFEEEE),
      );

    default:
      return _StatusConfig(
        label: 'AVAILABLE'.tr,
        icon: Icons.emoji_events_outlined,
        foregroundColor: Color(0xFF7CC000),
        backgroundColor: Color(0xFFF1F9E7),
      );
  }
}

// ============================================================
// REGISTRATION STATUS CONFIG
// ============================================================
//
// IMPORTANT: this is a DIFFERENT status space than
// _statusConfig() above.
//
//   _statusConfig()             -> COMPETITION status
//                                   (open / upcoming / ongoing /
//                                   completed / cancelled)
//
//   _registrationStatusConfig() -> PLAYER REGISTRATION status
//                                   (pending / approved /
//                                   payment_pending / paid /
//                                   rejected / cancelled /
//                                   expired / waitlisted)
//
// _RegisteredButton only ever renders once the player already
// has a real registration, so it must always read this config,
// never _statusConfig(). Otherwise an unmapped value like
// "paid" silently falls through to _statusConfig()'s default
// case and renders as "AVAILABLE" on a plain, non-tappable
// Container - which looks like a dead button.
// ============================================================

_StatusConfig _registrationStatusConfig(String status) {
  switch (status.toLowerCase()) {
    case 'pending':
      return _StatusConfig(
        label: 'PENDING APPROVAL'.tr,
        icon: Icons.hourglass_top_rounded,
        foregroundColor: Color(0xFF082B5C),
        backgroundColor: Color(0xFFEAF0F8),
      );

    case 'approved':
      return _StatusConfig(
        label: 'APPROVED'.tr,
        icon: Icons.check_circle_outline_rounded,
        foregroundColor: Color(0xFF16823A),
        backgroundColor: Color(0xFFE8F7ED),
      );

    case 'paid':
      return _StatusConfig(
        label: 'REGISTERED'.tr,
        icon: Icons.check_circle_rounded,
        foregroundColor: Color(0xFF4F8F00),
        backgroundColor: Color(0xFFEFF8E5),
      );

    case 'waitlisted':
      return _StatusConfig(
        label: 'ON WAITING LIST'.tr,
        icon: Icons.hourglass_bottom_rounded,
        foregroundColor: Color(0xFFB26A00),
        backgroundColor: Color(0xFFFFF3E0),
      );

    case 'rejected':
      return _StatusConfig(
        label: 'PAYMENT REJECTED'.tr,
        icon: Icons.error_outline_rounded,
        foregroundColor: Color(0xFFC62828),
        backgroundColor: Color(0xFFFFEEEE),
      );

    case 'expired':
      return _StatusConfig(
        label: 'REGISTRATION EXPIRED'.tr,
        icon: Icons.timer_off_outlined,
        foregroundColor: Color(0xFF607080),
        backgroundColor: Color(0xFFF0F2F4),
      );

    case 'cancelled':
      return _StatusConfig(
        label: 'CANCELLED'.tr,
        icon: Icons.cancel_outlined,
        foregroundColor: Color(0xFF607080),
        backgroundColor: Color(0xFFF0F2F4),
      );

    default:
    // Unknown/unmapped registration status from the API.
    // Still shown distinctly from the competition's own
    // "AVAILABLE" state so it never reads as a dead button.
      return _StatusConfig(
        label: status.toUpperCase(),
        icon: Icons.info_outline_rounded,
        foregroundColor: const Color(0xFF082B5C),
        backgroundColor: const Color(0xFFEAF0F8),
      );
  }
}

// ============================================================
// HELPERS
// ============================================================

bool _hasText(String? value) {
  return value != null && value.trim().isNotEmpty;
}

String _competitionType(String value) {
  switch (value.toLowerCase()) {
    case 'individual':
      return 'Individual'.tr;

    case 'team':
      return 'Team'.tr;

    default:
      return value;
  }
}

String _approvalMode(String value) {
  switch (value.toLowerCase()) {
    case 'auto':
      return 'Automatic'.tr;

    case 'manual':
      return 'Manual'.tr;

    default:
      return value;
  }
}

String _visibility(String value) {
  switch (value.toLowerCase()) {
    case 'public':
      return 'Public'.tr;

    case 'private':
      return 'Private'.tr;

    default:
      return value;
  }
}

String _formatMoney(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(2);
}

String _formatDateTime(DateTime date) {
  final local = date.toLocal();

  final day = local.day.toString().padLeft(2, '0');
  final month = local.month.toString().padLeft(2, '0');
  final year = local.year.toString();

  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');

  return '$day/$month/$year • $hour:$minute';
}
class _BracketCard extends StatelessWidget {
  const _BracketCard();

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Consumer<CompetitionProvider>(
      builder: (context, provider, _) {
        final bracket = provider.bracket;

        if (provider.isLoading && bracket == null) {
          return const _SimpleCard(
            child: SizedBox(
              height: 72,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: e7mGreen,
                  ),
                ),
              ),
            ),
          );
        }

        if (provider.errorMessage != null && bracket == null) {
          return _SimpleCard(
            child: Row(
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  color: Colors.redAccent.shade200,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    provider.errorMessage!,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (bracket == null) {
          return const SizedBox.shrink();
        }

        final generated = bracket['generated'] == true;

        final rounds = bracket['rounds'];

        if (!generated ||
            rounds is! List ||
            rounds.isEmpty) {
          return _SimpleCard(
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: e7mGreen.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: const Icon(
                    Icons.account_tree_outlined,
                    color: e7mGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bracket is not generated yet.'.tr,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return _SimpleCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.account_tree_outlined,
                    color: e7mGreen,
                    size: 21,
                  ),
                  SizedBox(width: 9),
                  Text(
                    'Bracket'.tr,
                    style: TextStyle(
                      color: e7mNavy,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < rounds.length; i++) ...[
                _BracketRound(
                  round: rounds[i],
                ),
                if (i != rounds.length - 1)
                  const SizedBox(height: 16),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _BracketRound extends StatelessWidget {
  const _BracketRound({
    required this.round,
  });

  final dynamic round;

  @override
  Widget build(BuildContext context) {
    final data = Map<String, dynamic>.from(
      round as Map,
    );

    final roundName =
        data['round']?.toString() ?? 'unknown';

    final matches = data['matches'];

    if (matches is! List || matches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _formatRoundName(roundName),
          style: const TextStyle(
            color: Color(0xFF082B5C),
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        for (var i = 0; i < matches.length; i++) ...[
          _BracketMatch(
            match: matches[i],
          ),
          if (i != matches.length - 1)
            const SizedBox(height: 8),
        ],
      ],
    );
  }

  String _formatRoundName(String value) {
    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}${word.substring(1)}',
    )
        .join(' ');
  }
}

class _BracketMatch extends StatelessWidget {
  const _BracketMatch({
    required this.match,
  });

  final dynamic match;

  @override
  Widget build(BuildContext context) {
    final data = Map<String, dynamic>.from(
      match as Map,
    );

    final matchNumber = data['match_number'];

    final home = data['home_participant'];
    final away = data['away_participant'];

    final homeData = home is Map
        ? Map<String, dynamic>.from(home)
        : null;

    final awayData = away is Map
        ? Map<String, dynamic>.from(away)
        : null;

    final homeName =
        homeData?['name']?.toString() ?? 'TBD'.tr;

    final awayName =
        awayData?['name']?.toString() ?? 'TBD'.tr;

    final homeScore = data['home_score'];
    final awayScore = data['away_score'];

    final status =
        data['status']?.toString() ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  homeName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF082B5C),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _BracketScore(
                score: homeScore,
              ),
            ],
          ),
          const SizedBox(height: 7),
          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text(
                  awayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF082B5C),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _BracketScore(
                score: awayScore,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (matchNumber != null)
                Text(
                  'Match {number}'.trArgs({'number': matchNumber}),
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const Spacer(),
              Text(
                status,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BracketScore extends StatelessWidget {
  const _BracketScore({
    required this.score,
  });

  final dynamic score;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: score == null
            ? Colors.grey.shade100
            : const Color(0xFF7CC000)
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        score?.toString() ?? '-',
        style: const TextStyle(
          color: Color(0xFF082B5C),
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}