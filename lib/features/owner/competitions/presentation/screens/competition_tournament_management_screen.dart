import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/competition_model.dart';
import '../../data/models/competition_seeding_model.dart';
import '../../data/models/competition_match_model.dart';
import '../../data/models/competition_standing_model.dart';
import '../../data/models/competition_bracket_model.dart';
import '../providers/competition_provider.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class CompetitionTournamentManagementScreen extends StatefulWidget {
  final CompetitionModel competition;

  const CompetitionTournamentManagementScreen({
    super.key,
    required this.competition,
  });

  @override
  State<CompetitionTournamentManagementScreen> createState() =>
      _CompetitionTournamentManagementScreenState();
}

class _CompetitionTournamentManagementScreenState
    extends State<CompetitionTournamentManagementScreen> {
  static const Color primaryColor = Color(0xff7CC000);
  static const Color darkColor = Color(0xff1E1446);

  bool _initialLoading = true;

  bool get _isKnockout =>
      widget.competition.format?.toLowerCase() == 'knockout';

  String _t(BuildContext context, String key) {
    return context.read<LanguageProvider>().translate(key);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAll();
    });
  }

  Future<void> _loadAll() async {
    final provider = context.read<CompetitionProvider>();
    setState(() => _initialLoading = true);

    final futures = <Future<void>>[
      provider.loadRegistrations(widget.competition.id),
      provider.loadMatches(widget.competition.id),
      provider.loadStandings(widget.competition.id),
    ];

    if (_isKnockout) {
      futures.add(provider.loadSeeding(widget.competition.id));
      futures.add(provider.loadBracket(widget.competition.id));
    }

    await Future.wait(futures);

    if (mounted) {
      setState(() => _initialLoading = false);
    }
  }

  Future<void> _generateSeeding() async {
    final provider = context.read<CompetitionProvider>();
    final success = await provider.generateSeeding(widget.competition.id);
    if (!mounted) return;
    _showResult(success, success ? 'Seeding generated successfully.' : null);
  }

  Future<void> _confirmSeeding() async {
    final provider = context.read<CompetitionProvider>();
    final success = await provider.confirmSeeding(widget.competition.id);
    if (!mounted) return;
    _showResult(success, success ? 'Seeding confirmed successfully.' : null);
  }

  Future<void> _generateTournament() async {
    final provider = context.read<CompetitionProvider>();
    final success = await provider.generateTournament(widget.competition.id);
    if (!mounted) return;
    _showResult(success, success ? 'Tournament generated successfully.' : null);
    if (success) {
      final futures = <Future<void>>[
        provider.loadMatches(widget.competition.id),
        provider.loadStandings(widget.competition.id),
      ];

      if (_isKnockout) {
        futures.add(provider.loadSeeding(widget.competition.id));
        futures.add(provider.loadBracket(widget.competition.id));
      }

      await Future.wait(futures);
    }
  }

  void _showResult(bool success, String? successMessage) {
    final provider = context.read<CompetitionProvider>();
    final message = success
        ? successMessage ?? 'Operation completed successfully.'
        : provider.errorMessage ?? 'Operation failed.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: success ? primaryColor : Colors.red,
      ),
    );
  }

  String _participantName({
    required int? participantId,
    required String fallback,
    required List<CompetitionSeedingModel> seeding,
  }) {
    for (final item in seeding) {
      if (item.registrationId == participantId) {
        if (item.playerId != null) return 'Player #${item.playerId}';
        if (item.teamId != null) return 'Team #${item.teamId}';
      }
    }
    return fallback;
  }

  Widget _sectionCard({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
  }) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: child,
    );
  }

  Widget _empty(String text, IconData icon) {
    return _sectionCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30),
        child: Column(
          children: [
            Icon(icon, size: 42, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    bool outlined = false,
  }) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildSeeding(CompetitionProvider provider) {
    final seeding = provider.seeding;

    return RefreshIndicator(
      onRefresh: () => provider.loadSeeding(widget.competition.id),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Seeding Management',
                  style: TextStyle(
                    color: darkColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Generate the competition seeding and confirm it before generating the tournament.',
                  style: TextStyle(color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _actionButton(
                      label: 'Generate Seeding',
                      icon: Icons.auto_awesome,
                      onPressed: provider.isLoading ? null : _generateSeeding,
                    ),
                    _actionButton(
                      label: 'Confirm Seeding',
                      icon: Icons.verified_outlined,
                      outlined: true,
                      onPressed: provider.isLoading || seeding.isEmpty
                          ? null
                          : _confirmSeeding,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (seeding.isEmpty)
            _empty('No seeding has been generated yet.', Icons.format_list_numbered)
          else
            _sectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  for (int i = 0; i < seeding.length; i++) ...[
                    ListTile(
                      leading: CircleAvatar(
                        backgroundColor: primaryColor.withValues(alpha: .12),
                        child: Text(
                          '${seeding[i].seed}',
                          style: const TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      title: Text(
                        seeding[i].playerId != null
                            ? 'Player #${seeding[i].playerId}'
                            : seeding[i].teamId != null
                            ? 'Team #${seeding[i].teamId}'
                            : 'Registration #${seeding[i].registrationId}',
                        style: const TextStyle(
                          color: darkColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Registration #${seeding[i].registrationId} • ${seeding[i].status}',
                      ),
                    ),
                    if (i != seeding.length - 1)
                      Divider(height: 1, color: Colors.grey.shade200),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTournament(CompetitionProvider provider) {
    return RefreshIndicator(
      onRefresh: () async {
        await provider.loadMatches(widget.competition.id);
        await provider.loadStandings(widget.competition.id);
        if (_isKnockout) {
          await provider.loadSeeding(widget.competition.id);
          await provider.loadBracket(widget.competition.id);
        }
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tournament Generation',
                  style: TextStyle(
                    color: darkColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Generate the tournament after the seeding is confirmed.',
                  style: TextStyle(color: Colors.grey.shade600, height: 1.4),
                ),
                const SizedBox(height: 16),
                _actionButton(
                  label: 'Generate Tournament',
                  icon: Icons.account_tree_outlined,
                  onPressed: provider.isLoading ? null : _generateTournament,
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _sectionCard(
            child: Column(
              children: [
                _summaryRow(
                  Icons.groups_outlined,
                  'Participants',
                  '${provider.seeding.length}',
                ),
                const SizedBox(height: 12),
                _summaryRow(
                  Icons.sports_soccer_outlined,
                  'Matches',
                  '${provider.matches.length}',
                ),
                const SizedBox(height: 12),
                _summaryRow(
                  Icons.emoji_events_outlined,
                  'Standings Entries',
                  '${provider.standings.length}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: primaryColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: darkColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: darkColor,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildMatches(CompetitionProvider provider) {
    final matches = provider.matches;

    return RefreshIndicator(
      onRefresh: () => provider.loadMatches(widget.competition.id),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (matches.isEmpty)
            _empty('No tournament matches are available yet.', Icons.sports_soccer)
          else
            for (final match in matches) ...[
              _buildMatchCard(match, provider),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }

  Widget _buildMatchCard(
      CompetitionMatchModel match,
      CompetitionProvider provider,
      ) {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  match.round?.isNotEmpty == true
                      ? '${match.round} • Match ${match.matchNumber ?? match.id}'
                      : 'Match ${match.matchNumber ?? match.id}',
                  style: const TextStyle(
                    color: darkColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              _statusBadge(match.status),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Text(
                  _participantFromRegistration(
                    match.homeParticipantId,
                    provider,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  '${match.homeScore ?? '-'}  :  ${match.awayScore ?? '-'}',
                  style: const TextStyle(
                    color: darkColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  _participantFromRegistration(
                    match.awayParticipantId,
                    provider,
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (match.matchDate != null || match.startTime != null) ...[
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.schedule_outlined, size: 17, color: primaryColor),
                const SizedBox(width: 6),
                Text(
                  [
                    if (match.matchDate != null)
                      '${match.matchDate!.day.toString().padLeft(2, '0')}/${match.matchDate!.month.toString().padLeft(2, '0')}/${match.matchDate!.year}',
                    if (match.startTime != null) match.startTime!,
                  ].join(' • '),
                  style: TextStyle(color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _participantFromRegistration(
      int? registrationId,
      CompetitionProvider provider,
      ) {
    if (registrationId == null) return 'TBD';
    for (final registration in provider.registrations) {
      if (registration.id == registrationId) {
        if (registration.playerName?.isNotEmpty == true) {
          return registration.playerName!;
        }
        if (registration.teamName?.isNotEmpty == true) {
          return registration.teamName!;
        }
        return 'Registration #$registrationId';
      }
    }
    return 'Registration #$registrationId';
  }

  Widget _statusBadge(String status) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completed':
        color = Colors.green;
        break;
      case 'cancelled':
        color = Colors.red;
        break;
      case 'ongoing':
        color = Colors.blue;
        break;
      default:
        color = Colors.orange;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildStandings(CompetitionProvider provider) {
    final standings = provider.standings;

    return RefreshIndicator(
      onRefresh: () => provider.loadStandings(widget.competition.id),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (standings.isEmpty)
            _empty('No standings are available yet.', Icons.leaderboard_outlined)
          else
            _sectionCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _standingsHeader(),
                  for (final row in standings) _standingRow(row),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _standingsHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xffF7F8FA),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 34, child: Text('#', textAlign: TextAlign.center)),
          Expanded(child: Text('Participant')),
          SizedBox(width: 34, child: Text('P', textAlign: TextAlign.center)),
          SizedBox(width: 34, child: Text('W', textAlign: TextAlign.center)),
          SizedBox(width: 34, child: Text('D', textAlign: TextAlign.center)),
          SizedBox(width: 34, child: Text('L', textAlign: TextAlign.center)),
          SizedBox(width: 42, child: Text('Pts', textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _standingRow(CompetitionStandingModel row) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text('${row.position}', textAlign: TextAlign.center),
          ),
          Expanded(
            child: Text(
              row.participantName ?? 'Registration #${row.registrationId}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: darkColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(width: 34, child: Text('${row.played}', textAlign: TextAlign.center)),
          SizedBox(width: 34, child: Text('${row.wins}', textAlign: TextAlign.center)),
          SizedBox(width: 34, child: Text('${row.draws}', textAlign: TextAlign.center)),
          SizedBox(width: 34, child: Text('${row.losses}', textAlign: TextAlign.center)),
          SizedBox(
            width: 42,
            child: Text(
              '${row.points}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBracket(CompetitionProvider provider) {
    final bracket = provider.bracket;

    return RefreshIndicator(
      onRefresh: () => provider.loadBracket(widget.competition.id),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (bracket == null || bracket.rounds.isEmpty)
            _empty('No bracket is available yet.', Icons.account_tree_outlined)
          else ...[
            _sectionCard(
              child: Row(
                children: [
                  const Icon(Icons.account_tree_outlined, color: primaryColor, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      bracket.competitionName,
                      style: const TextStyle(
                        color: darkColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            for (final round in bracket.rounds) ...[
              Text(
                round.round,
                style: const TextStyle(
                  color: darkColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              for (final match in round.matches) ...[
                _bracketMatch(match),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }

  Widget _bracketMatch(CompetitionBracketMatchModel match) {
    final home = match.homeParticipant?.name ?? 'TBD';
    final away = match.awayParticipant?.name ?? 'TBD';

    return _sectionCard(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  home,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${match.homeScore ?? '-'}',
                style: const TextStyle(
                  color: darkColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  away,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${match.awayScore ?? '-'}',
                style: const TextStyle(
                  color: darkColor,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Match ${match.matchNumber}'),
              const Spacer(),
              _statusBadge(match.status),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final isArabic = languageProvider.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xffF6F8FB),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: darkColor,
          elevation: 0,
          title: const Text(
            'Tournament Management',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
        ),
        body: _initialLoading
            ? const Center(
          child: CircularProgressIndicator(color: primaryColor),
        )
            : Consumer<CompetitionProvider>(
          builder: (context, provider, _) {
            if (provider.errorMessage != null &&
                provider.matches.isEmpty &&
                provider.standings.isEmpty &&
                (!_isKnockout ||
                    (provider.seeding.isEmpty && provider.bracket == null))) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 12),
                      Text(
                        provider.errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      _actionButton(
                        label: 'Retry',
                        icon: Icons.refresh,
                        onPressed: _loadAll,
                      ),
                    ],
                  ),
                ),
              );
            }

            final tabs = <Tab>[
              if (_isKnockout)
                const Tab(
                  icon: Icon(Icons.format_list_numbered),
                  text: 'Seeding',
                ),
              const Tab(
                icon: Icon(Icons.account_tree_outlined),
                text: 'Tournament',
              ),
              const Tab(
                icon: Icon(Icons.sports_soccer_outlined),
                text: 'Matches',
              ),
              const Tab(
                icon: Icon(Icons.leaderboard_outlined),
                text: 'Standings',
              ),
              if (_isKnockout)
                const Tab(
                  icon: Icon(Icons.account_tree),
                  text: 'Bracket',
                ),
            ];

            final views = <Widget>[
              if (_isKnockout) _buildSeeding(provider),
              _buildTournament(provider),
              _buildMatches(provider),
              _buildStandings(provider),
              if (_isKnockout) _buildBracket(provider),
            ];

            return DefaultTabController(
              length: tabs.length,
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    child: TabBar(
                      isScrollable: true,
                      labelColor: primaryColor,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: primaryColor,
                      tabs: tabs,
                    ),
                  ),
                  Expanded(
                    child: TabBarView(children: views),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
