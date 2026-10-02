import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/competition_invitation_model.dart';
import '../../providers/competition_provider.dart';
import 'package:e7m/shared/localization/app_translations.dart';

class CompetitionInvitationsScreen extends StatelessWidget {
  const CompetitionInvitationsScreen({super.key});

  static const green = Color(0xFF7CC000);
  static const navy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompetitionProvider()..loadInvitations(),
      child: const _InvitationsView(),
    );
  }
}

class _InvitationsView extends StatelessWidget {
  const _InvitationsView();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CompetitionProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(
          'Invitations'.tr,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.white,
        foregroundColor: CompetitionInvitationsScreen.navy,
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: CompetitionInvitationsScreen.green,
        onRefresh: () async {
          await provider.loadInvitations();
        },
        child: _buildBody(context, provider),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      CompetitionProvider provider,
      ) {
    if (provider.isLoading && provider.invitations.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 220),
          Center(
            child: CircularProgressIndicator(
              color: CompetitionInvitationsScreen.green,
            ),
          ),
        ],
      );
    }

    if (provider.hasError && provider.invitations.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: 170),
          Center(
            child: Text('Failed to load invitations'.tr),
          ),
        ],
      );
    }

    if (provider.invitations.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: 160),
          Center(
            child: Icon(
              Icons.mail_outline_rounded,
              size: 64,
              color: Colors.black26,
            ),
          ),
          SizedBox(height: 14),
          Center(
            child: Text(
              'No invitations yet'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.invitations.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, index) {
        return _InvitationCard(
          invitation: provider.invitations[index],
        );
      },
    );
  }
}

class _InvitationCard extends StatelessWidget {
  const _InvitationCard({
    required this.invitation,
  });

  final CompetitionInvitationModel invitation;

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CompetitionProvider>();

    final pending = invitation.isPending;

    final name = invitation.competitionName ??
        'Competition #{id}'.trArgs({'id': invitation.competitionId});

    final fee = invitation.entryFee == null
        ? null
        : (invitation.entryFee == 0
        ? 'Free'.tr
        : '{amount} EGP'.trArgs({'amount': invitation.entryFee!.toStringAsFixed(2)}));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE7E9ED),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.mail_rounded,
                color: CompetitionInvitationsScreen.green,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _Status(
                status: invitation.status,
              ),
            ],
          ),

          const SizedBox(height: 12),

          if (invitation.competitionType != null)
            Text(
              'Type: {value}'.trArgs({'value': invitation.competitionType}),
            ),

          if (fee != null)
            Text(
              'Entry fee: {value}'.trArgs({'value': fee}),
            ),

          if (invitation.teamName != null)
            Text(
              'Team: {value}'.trArgs({'value': invitation.teamName}),
            ),

          if (invitation.competitionStartDate != null)
            Text(
              'Date: {value}'.trArgs({'value': _date(invitation.competitionStartDate!)}),
            ),

          if (pending) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final ok = await provider.rejectInvitation(
                        invitation.id,
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'Invitation rejected'.tr
                                : provider.errorMessage ??
                                'Failed'.tr,
                          ),
                        ),
                      );

                      if (ok) {
                        await provider.loadInvitations();
                      }
                    },
                    child: Text('Reject'.tr),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await provider.acceptInvitation(
                        invitation.id,
                      );

                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'Invitation accepted'.tr
                                : provider.errorMessage ??
                                'Failed'.tr,
                          ),
                        ),
                      );

                      if (ok) {
                        await provider.loadInvitations();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      CompetitionInvitationsScreen.green,
                      foregroundColor: Colors.white,
                      elevation: 0,
                    ),
                    child: Text('Accept'.tr),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  static String _date(DateTime value) {
    final local = value.toLocal();

    return '${local.year}-'
        '${local.month.toString().padLeft(2, '0')}-'
        '${local.day.toString().padLeft(2, '0')}';
  }
}

class _Status extends StatelessWidget {
  const _Status({
    required this.status,
  });

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF082B5C).withValues(alpha: .08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}