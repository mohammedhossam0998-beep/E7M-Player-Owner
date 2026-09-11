import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/competition_model.dart';
import '../providers/competition_provider.dart';
import 'package:e7m/shared/localization/language_provider.dart';
class CompetitionInvitationsScreen extends StatefulWidget {
  final CompetitionModel competition;

  const CompetitionInvitationsScreen({
    super.key,
    required this.competition,
  });

  @override
  State<CompetitionInvitationsScreen> createState() =>
      _CompetitionInvitationsScreenState();
}

class _CompetitionInvitationsScreenState
    extends State<CompetitionInvitationsScreen> {
  static const Color primaryColor = Color(0xff7CC000);
  static const Color darkColor = Color(0xff1E1446);
  static const Color backgroundColor = Color(0xffF6F8FB);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompetitionProvider>().loadInvitations(
        widget.competition.id,
      );
    });
  }

  String _t(BuildContext context, String key) {
    return context
        .read<LanguageProvider>()
        .translate(key);
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'expired':
        return 'Expired';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      case 'expired':
        return Colors.grey;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blueGrey;
    }
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) {
      return _t(context, 'not_set');
    }

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} $hour:$minute';
  }

  Widget _buildStatusBadge(String status) {
    final color = _statusColor(status);

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
        _statusText(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildInvitationCard(
      BuildContext context,
      dynamic invitation,
      ) {
    final hasPlayer = invitation.playerName != null &&
        invitation.playerName!.trim().isNotEmpty;

    final hasTeam = invitation.teamName != null &&
        invitation.teamName!.trim().isNotEmpty;

    final displayName = hasPlayer
        ? invitation.playerName!
        : hasTeam
        ? invitation.teamName!
        : 'Unknown';

    final subtitle = hasPlayer
        ? invitation.playerEmail ?? ''
        : hasTeam
        ? 'Team'
        : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor:
                primaryColor.withValues(alpha: 0.10),
                backgroundImage:
                invitation.playerProfileImage != null
                    ? NetworkImage(
                  invitation.playerProfileImage!,
                )
                    : null,
                child:
                invitation.playerProfileImage == null
                    ? Icon(
                  hasPlayer
                      ? Icons.person_outline
                      : Icons.groups_outlined,
                  color: primaryColor,
                )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              _buildStatusBadge(
                invitation.status,
              ),
            ],
          ),

          const SizedBox(height: 15),

          Divider(
            height: 1,
            color: Colors.grey.shade200,
          ),

          const SizedBox(height: 12),

          if (invitation.playerId != null)
            _buildInfoRow(
              Icons.person_outline,
              'Player ID',
              invitation.playerId.toString(),
            ),

          if (invitation.teamId != null)
            _buildInfoRow(
              Icons.groups_outlined,
              'Team ID',
              invitation.teamId.toString(),
            ),

          _buildInfoRow(
            Icons.send_outlined,
            'Sent At',
            _formatDate(context, invitation.createdAt),
          ),

          _buildInfoRow(
            Icons.timer_outlined,
            'Expires At',
            _formatDate(context, invitation.expiresAt),
          ),

          if (invitation.respondedAt != null)
            _buildInfoRow(
              Icons.reply_outlined,
              'Responded At',
              _formatDate(context, invitation.respondedAt),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
      IconData icon,
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(
            icon,
            size: 17,
            color: primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: darkColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primaryColor.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mail_outline,
                color: primaryColor,
                size: 40,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No Competition Invitations',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkColor,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
      CompetitionProvider provider,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 55,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 15),
            Text(
              provider.errorMessage ??
                  'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<CompetitionProvider>()
                    .loadInvitations(
                  widget.competition.id,
                );
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<CompetitionProvider>();

    final languageProvider =
    context.watch<LanguageProvider>();

    final isArabic =
        languageProvider.locale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: darkColor,
          elevation: 0,
          title: const Text(
            'Competition Invitations',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SafeArea(
          child: Builder(
            builder: (context) {
              if (provider.isLoading &&
                  provider.invitations.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                );
              }

              if (provider.errorMessage != null &&
                  provider.invitations.isEmpty) {
                return _buildError(provider);
              }

              if (provider.invitations.isEmpty) {
                return RefreshIndicator(
                  color: primaryColor,
                  onRefresh: () {
                    return provider.loadInvitations(
                      widget.competition.id,
                    );
                  },
                  child: ListView(
                    physics:
                    const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height:
                        MediaQuery.of(context).size.height *
                            0.35,
                      ),
                      _buildEmptyState(),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: primaryColor,
                onRefresh: () {
                  return provider.loadInvitations(
                    widget.competition.id,
                  );
                },
                child: ListView.builder(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount:
                  provider.invitations.length,
                  itemBuilder: (context, index) {
                    return _buildInvitationCard(
                      context,
                      provider.invitations[index],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}