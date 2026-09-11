import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/team_model.dart';
import '../providers/team_provider.dart';
import '../widgets/team_card.dart';
import '../widgets/team_empty_state.dart';
import 'create_team_screen.dart';
import 'team_details_screen.dart';
import '../../../../../shared/localization/language_provider.dart';

class MyTeamsScreen extends StatefulWidget {
  const MyTeamsScreen({super.key});

  @override
  State<MyTeamsScreen> createState() => _MyTeamsScreenState();
}

class _MyTeamsScreenState extends State<MyTeamsScreen> {
  static const Color primaryGreen = Color(0xff7CC000);
  static const Color darkNavy = Color(0xff1E1446);
  static const Color background = Color(0xffF7F7F3);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<TeamProvider>().loadMyTeams();
    });
  }

  Future<void> _refresh() async {
    await context.read<TeamProvider>().loadMyTeams();
  }

  Future<void> _openCreateTeam() async {
    final TeamModel? createdTeam =
    await Navigator.of(context).push<TeamModel>(
      MaterialPageRoute(
        builder: (_) => const CreateTeamScreen(),
      ),
    );

    if (!mounted || createdTeam == null) return;

    await _refresh();

    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Team created successfully.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _openTeamDetails(TeamModel team) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TeamDetailsScreen(
          teamId: team.id,
        ),
      ),
    );
  }

  Future<void> _openEditTeam(TeamModel team) async {
    final TeamModel? updatedTeam =
    await Navigator.of(context).push<TeamModel>(
      MaterialPageRoute(
        builder: (_) => CreateTeamScreen(
          team: team,
        ),
      ),
    );

    if (!mounted || updatedTeam == null) return;

    await _refresh();

    if (!mounted) return;

    _showMessage('Team updated successfully.');
  }

  Future<void> _leaveTeam(TeamModel team) async {
    final t = context.read<LanguageProvider>().translate;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(t('leave_team')),
          content: Text(
            '${t('leave_team_question')} ${team.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(t('cancel')),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(t('leave')),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<TeamProvider>();

    final success = await provider.leaveTeam(team.id);

    if (!mounted) return;

    if (success) {
      _showMessage(t('left_team'));
    } else {
      _showMessage(
        provider.errorMessage ??
            t('something_went_wrong'),
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final t =
        context.read<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t('my_teams'),
          style: const TextStyle(
            color: darkNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _openCreateTeam,
            tooltip: t('create_team'),
            icon: const Icon(
              Icons.add_circle_outline_rounded,
              color: primaryGreen,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Consumer<TeamProvider>(
          builder: (context, provider, _) {
            if (provider.isLoadingMyTeams &&
                provider.myTeams.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryGreen,
                ),
              );
            }

            if (provider.errorMessage != null &&
                provider.myTeams.isEmpty) {
              return TeamEmptyState(
                icon: Icons.cloud_off_rounded,
                title: t('something_went_wrong'),
                message: provider.errorMessage!,
                buttonText: t('try_again'),
                onRetry: _refresh,
              );
            }

            if (provider.myTeams.isEmpty) {
              return TeamEmptyState(
                icon: Icons.groups_outlined,
                title: t('no_teams_yet'),
                message: t('no_teams_yet_message'),
                buttonText: t('create_team'),
                onRetry: _openCreateTeam,
              );
            }

            return RefreshIndicator(
              color: primaryGreen,
              onRefresh: _refresh,
              child: ListView.separated(
                physics:
                const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  30,
                ),
                itemCount: provider.myTeams.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final team =
                  provider.myTeams[index];

                  return Column(
                    children: [
                      TeamCard(
                        team: team,
                        showJoinButton: false,
                        onTap: () =>
                            _openTeamDetails(team),
                      ),
                      const SizedBox(height: 8),
                      _buildTeamActions(
                        team,
                        t,
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTeamActions(
      TeamModel team,
      String Function(String) t,
      ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _openTeamDetails(team),
            icon: const Icon(
              Icons.visibility_outlined,
            ),
            label: Text(
              t('view_details'),
            ),
          ),
        ),

        // Captain can edit the team.
        if (team.isCaptain) ...[
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _openEditTeam(team),
              icon: const Icon(
                Icons.edit_outlined,
              ),
              label: Text(
                t('edit_team'),
              ),
            ),
          ),
        ],

        // Captain cannot leave the team.
        if (!team.isCaptain) ...[
          const SizedBox(width: 10),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _leaveTeam(team),
              icon: const Icon(
                Icons.logout_rounded,
              ),
              label: Text(
                t('leave'),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ),
        ],
      ],
    );
  }
}