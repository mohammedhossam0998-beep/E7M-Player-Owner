import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/team_model.dart';
import '../../data/models/team_member_model.dart';
import '../providers/team_provider.dart';
import '../widgets/team_member_tile.dart';
import '../../../../../shared/localization/language_provider.dart';

class TeamDetailsScreen extends StatefulWidget {
  final int teamId;

  const TeamDetailsScreen({
    super.key,
    required this.teamId,
  });

  @override
  State<TeamDetailsScreen> createState() =>
      _TeamDetailsScreenState();
}

class _TeamDetailsScreenState
    extends State<TeamDetailsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<TeamProvider>()
          .loadTeamDetails(widget.teamId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t =
        context.watch<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(t('team_details')),
        centerTitle: true,
      ),
      body: Consumer<TeamProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingDetails) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null &&
              provider.selectedTeam == null) {
            return _ErrorState(
              message: provider.errorMessage!,
              onRetry: () {
                provider.loadTeamDetails(
                  widget.teamId,
                );
              },
            );
          }

          final team = provider.selectedTeam;

          if (team == null) {
            return _ErrorState(
              message: t('team_not_found'),
              onRetry: () {
                provider.loadTeamDetails(
                  widget.teamId,
                );
              },
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              return provider.loadTeamDetails(
                widget.teamId,
              );
            },
            child: _TeamDetailsContent(
              team: team,
              members: provider.teamMembers,
              onJoin: () =>
                  _handleJoin(context, team),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleJoin(
      BuildContext context,
      TeamModel team,
      ) async {
    final t =
        context.read<LanguageProvider>().translate;

    final provider =
    context.read<TeamProvider>();

    if (team.isMember ||
        team.hasPendingRequest) {
      return;
    }

    if (team.availableSlots != null &&
        team.availableSlots! <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('team_is_full'),
          ),
        ),
      );

      return;
    }

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            t('join_team'),
          ),
          content: Text(
            '${t('join_team_question')} ${team.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                t('cancel'),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(
                t('join'),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !context.mounted) {
      return;
    }

    final success =
    await provider.requestToJoinTeam(
      team.id,
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? t('join_request_sent')
              : provider.errorMessage ??
              t('something_went_wrong'),
        ),
      ),
    );

    if (success) {
      await provider.loadTeamDetails(
        team.id,
      );
    }
  }
}

// ============================================================
// TEAM DETAILS CONTENT
// ============================================================

class _TeamDetailsContent
    extends StatelessWidget {
  final TeamModel team;
  final List<TeamMemberModel> members;
  final VoidCallback onJoin;

  const _TeamDetailsContent({
    required this.team,
    required this.members,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final t =
        context.watch<LanguageProvider>().translate;

    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.only(bottom: 32),
      children: [
        _TeamHeader(
          team: team,
        ),

        const SizedBox(height: 16),

        _TeamMainInfo(
          team: team,
        ),

        const SizedBox(height: 16),

        if (team.description != null &&
            team.description!
                .trim()
                .isNotEmpty)
          _SectionCard(
            title: t('about_team'),
            child: Text(
              team.description!,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
                fontSize: 15,
              ),
            ),
          ),

        const SizedBox(height: 16),

        _TeamStats(
          team: team,
        ),

        const SizedBox(height: 16),

        _JoinSection(
          team: team,
          onJoin: onJoin,
        ),

        const SizedBox(height: 12),

        // ======================================================
        // TEAM CHAT BUTTON
        // ======================================================

        Padding(
          padding:
          const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/team-chat',
                  arguments: team.id,
                );
              },
              icon: const Icon(
                Icons.chat_bubble_outline_rounded,
              ),
              label: Text(
                t('team_chat'),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        _MembersSection(
          team: team,
          members: members,
        ),
      ],
    );
  }
}

// ============================================================
// TEAM HEADER
// ============================================================

class _TeamHeader
    extends StatelessWidget {
  final TeamModel team;

  const _TeamHeader({
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: const Color(0xFF7CC000),
        borderRadius:
        const BorderRadius.vertical(
          bottom: Radius.circular(28),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -70,
            right: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white
                    .withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Positioned(
            bottom: -80,
            left: -60,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                color: Colors.white
                    .withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),

          Center(
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                _TeamLogo(
                  logo: team.logo,
                  size: 92,
                ),

                const SizedBox(height: 12),

                Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  child: Text(
                    team.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                if (team.locationName != null &&
                    team.locationName!
                        .trim()
                        .isNotEmpty)
                  Padding(
                    padding:
                    const EdgeInsets.only(
                      top: 6,
                    ),
                    child: Row(
                      mainAxisSize:
                      MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons
                              .location_on_outlined,
                          color:
                          Colors.white70,
                          size: 17,
                        ),

                        const SizedBox(width: 4),

                        Text(
                          team.locationName!,
                          style:
                          const TextStyle(
                            color:
                            Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
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
// TEAM MAIN INFO
// ============================================================

class _TeamMainInfo
    extends StatelessWidget {
  final TeamModel team;

  const _TeamMainInfo({
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    final t =
        context.watch<LanguageProvider>().translate;

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (team.gameType != null)
            _InfoChip(
              icon:
              Icons.sports_soccer,
              label: team.gameType!,
            ),

          if (team.skillLevel != null)
            _InfoChip(
              icon:
              Icons.bar_chart_rounded,
              label: _skillLabel(
                team.skillLevel!,
                t,
              ),
            ),

          if (team.city != null &&
              team.city!
                  .trim()
                  .isNotEmpty)
            _InfoChip(
              icon:
              Icons.location_city_outlined,
              label: team.city!,
            ),

          if (team.distanceKm != null)
            _InfoChip(
              icon:
              Icons.near_me_outlined,
              label:
              '${team.distanceKm!.toStringAsFixed(1)} km',
            ),
        ],
      ),
    );
  }

  String _skillLabel(
      String skill,
      String Function(String) t,
      ) {
    switch (skill.toLowerCase()) {
      case 'beginner':
        return t('beginner');

      case 'intermediate':
        return t('intermediate');

      case 'advanced':
        return t('advanced');

      default:
        return skill;
    }
  }
}

// ============================================================
// TEAM STATS
// ============================================================

class _TeamStats
    extends StatelessWidget {
  final TeamModel team;

  const _TeamStats({
    required this.team,
  });

  @override
  Widget build(BuildContext context) {
    final t =
        context.watch<LanguageProvider>().translate;

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              icon:
              Icons.groups_rounded,
              value:
              '${team.membersCount ?? 0}',
              label: t('players'),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _StatCard(
              icon:
              Icons
                  .person_add_alt_1_rounded,
              value:
              '${team.availableSlots ?? 0}',
              label:
              t('available_slots'),
            ),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: _StatCard(
              icon:
              Icons.people_alt_outlined,
              value:
              '${team.maxPlayers ?? '-'}',
              label:
              t('max_players'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// JOIN SECTION
// ============================================================

class _JoinSection
    extends StatelessWidget {
  final TeamModel team;
  final VoidCallback onJoin;

  const _JoinSection({
    required this.team,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final t =
        context.watch<LanguageProvider>().translate;

    if (team.isCaptain) {
      return Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: SizedBox(
          width: double.infinity,
          height: 52,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/team-requests',
                arguments: {
                  'teamId': team.id,
                  'teamName': team.name,
                },
              );
            },
            icon: const Icon(
              Icons.person_add_alt_1_rounded,
            ),
            label: Text(
              t('join_requests'),
            ),
          ),
        ),
      );
    }

    if (team.isMember) {
      return Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: _StatusContainer(
          icon:
          Icons.check_circle_outline,
          text:
          t('you_are_member'),
        ),
      );
    }

    if (team.hasPendingRequest) {
      return Padding(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: _StatusContainer(
          icon:
          Icons.hourglass_empty_rounded,
          text:
          t('join_request_pending'),
        ),
      );
    }

    final isFull =
        team.availableSlots != null &&
            team.availableSlots! <= 0;

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      child: SizedBox(
        height: 52,
        child: FilledButton.icon(
          onPressed:
          isFull ? null : onJoin,
          icon: Icon(
            isFull
                ? Icons.block_rounded
                : Icons
                .person_add_alt_1_rounded,
          ),
          label: Text(
            isFull
                ? t('team_is_full')
                : t('join_team'),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MEMBERS SECTION
// ============================================================

class _MembersSection
    extends StatelessWidget {
  final TeamModel team;
  final List<TeamMemberModel> members;

  const _MembersSection({
    required this.team,
    required this.members,
  });

  @override
  Widget build(BuildContext context) {
    final t =
        context.watch<LanguageProvider>().translate;

    return _SectionCard(
      title:
      '${t('players')} (${members.length})',
      child: members.isEmpty
          ? Padding(
        padding:
        const EdgeInsets.symmetric(
          vertical: 12,
        ),
        child: Center(
          child: Text(
            t('no_players'),
            style: TextStyle(
              color:
              Colors.grey.shade600,
            ),
          ),
        ),
      )
          : Column(
        children: [
          for (
          int i = 0;
          i < members.length;
          i++
          ) ...[
            TeamMemberTile(
              member: members[i],
              showRemoveButton:
              team.isCaptain &&
                  !members[i]
                      .isCaptain,
              onRemove:
              team.isCaptain &&
                  !members[i]
                      .isCaptain
                  ? () =>
                  _handleRemovePlayer(
                    context,
                    members[i],
                  )
                  : null,
              trailing:
              team.isCaptain &&
                  !members[i]
                      .isCaptain
                  ? _TransferCaptainButton(
                onPressed: () =>
                    _handleTransferCaptaincy(
                      context,
                      members[i],
                    ),
              )
                  : null,
            ),

            if (i != members.length - 1)
              const Divider(
                height: 1,
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleRemovePlayer(
      BuildContext context,
      TeamMemberModel member,
      ) async {
    final t =
        context.read<LanguageProvider>().translate;

    final provider =
    context.read<TeamProvider>();

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            t('remove_player'),
          ),
          content: Text(
            '${t('remove_player_question')} ${member.fullName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                t('cancel'),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(
                t('remove'),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !context.mounted) {
      return;
    }

    final success =
    await provider.removePlayerFromTeam(
      teamId: team.id,
      playerId: member.id,
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? t('player_removed')
              : provider.errorMessage ??
              t('something_went_wrong'),
        ),
      ),
    );

    if (success) {
      await provider.loadTeamDetails(
        team.id,
      );
    }
  }

  Future<void> _handleTransferCaptaincy(
      BuildContext context,
      TeamMemberModel member,
      ) async {
    final t =
        context.read<LanguageProvider>().translate;

    final provider =
    context.read<TeamProvider>();

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            t('transfer_captaincy'),
          ),
          content: Text(
            '${t('transfer_captaincy_question')} ${member.fullName}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                t('cancel'),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(
                t('confirm'),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !context.mounted) {
      return;
    }

    final success =
    await provider.transferCaptaincy(
      teamId: team.id,
      newCaptainId: member.id,
    );

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? t('captaincy_transferred')
              : provider.errorMessage ??
              t('something_went_wrong'),
        ),
      ),
    );

    if (success) {
      await provider.loadTeamDetails(
        team.id,
      );
    }
  }
}

// ============================================================
// TRANSFER CAPTAIN BUTTON
// ============================================================

class _TransferCaptainButton
    extends StatelessWidget {
  final VoidCallback onPressed;

  const _TransferCaptainButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final t =
        context.watch<LanguageProvider>().translate;

    return IconButton(
      onPressed: onPressed,
      tooltip:
      t('transfer_captaincy'),
      icon: const Icon(
        Icons.swap_horiz_rounded,
        color: Color(0xFF7CC000),
      ),
    );
  }
}

// ============================================================
// SECTION CARD
// ============================================================

class _SectionCard
    extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
      const EdgeInsets.symmetric(
        horizontal: 16,
      ),
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.04),
            blurRadius: 12,
            offset:
            const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style:
            const TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          child,
        ],
      ),
    );
  }
}

// ============================================================
// STAT CARD
// ============================================================

class _StatCard
    extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        vertical: 14,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color:
            const Color(0xFF7CC000),
            size: 24,
          ),

          const SizedBox(height: 6),

          Text(
            value,
            style:
            const TextStyle(
              fontSize: 18,
              fontWeight:
              FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            label,
            textAlign:
            TextAlign.center,
            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,
            style: TextStyle(
              color:
              Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INFO CHIP
// ============================================================

class _InfoChip
    extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(30),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 17,
            color:
            const Color(0xFF7CC000),
          ),

          const SizedBox(width: 5),

          Text(
            label,
            style:
            const TextStyle(
              fontSize: 13,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// STATUS CONTAINER
// ============================================================

class _StatusContainer
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _StatusContainer({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF7CC000)
            .withValues(alpha: 0.10),
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color:
            Color(0xFF7CC000),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              text,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// TEAM LOGO
// ============================================================

class _TeamLogo
    extends StatelessWidget {
  final String? logo;
  final double size;

  const _TeamLogo({
    required this.logo,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding:
      const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.15),
            blurRadius: 12,
            offset:
            const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: logo != null &&
            logo!.trim().isNotEmpty
            ? Image.network(
          logo!,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) {
            return const Icon(
              Icons.groups_rounded,
              size: 42,
              color:
              Color(0xFF7CC000),
            );
          },
        )
            : const Icon(
          Icons.groups_rounded,
          size: 42,
          color:
          Color(0xFF7CC000),
        ),
      ),
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

class _ErrorState
    extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final t =
        context.watch<LanguageProvider>().translate;

    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color:
              Colors.grey.shade400,
            ),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh,
              ),
              label: Text(
                t('try_again'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}