import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/competition_invitation_model.dart';
import '../../data/models/competition_model.dart';
import '../providers/competition_provider.dart';

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
      if (!mounted) return;

      Provider.of<CompetitionProvider>(
        context,
        listen: false,
      ).loadInvitations(widget.competition.id);
    });
  }

  String _formatDateTime(DateTime? date) {
    if (date == null) return 'Not set';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year}  $hour:$minute';
  }

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending';
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
      case 'approved':
        return Colors.green;
      case 'rejected':
      case 'expired':
      case 'cancelled':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
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

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 17,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
          Text(
            '$title: ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
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

  Widget _buildAvatar(CompetitionInvitationModel invitation) {
    final image = invitation.playerProfileImage;

    if (image != null && image.trim().isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: NetworkImage(image),
      );
    }

    return const CircleAvatar(
      radius: 28,
      backgroundColor: Color(0xffEFF8E3),
      child: Icon(
        Icons.person_outline,
        color: primaryColor,
        size: 30,
      ),
    );
  }

  Widget _buildInvitationCard(
      CompetitionInvitationModel invitation,
      ) {
    final isPlayer = invitation.playerId != null;

    final name = isPlayer
        ? (invitation.playerName?.trim().isNotEmpty == true
        ? invitation.playerName!.trim()
        : 'Player #${invitation.playerId}')
        : (invitation.teamName?.trim().isNotEmpty == true
        ? invitation.teamName!.trim()
        : 'Team #${invitation.teamId}');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(invitation),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      isPlayer
                          ? 'Player #${invitation.playerId}'
                          : 'Team #${invitation.teamId}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(invitation.status),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          if (isPlayer &&
              invitation.playerEmail != null &&
              invitation.playerEmail!.trim().isNotEmpty)
            _buildInfoRow(
              icon: Icons.email_outlined,
              title: 'Email',
              value: invitation.playerEmail!,
            ),
          if (!isPlayer && invitation.teamCaptainId != null)
            _buildInfoRow(
              icon: Icons.person_outline,
              title: 'Captain',
              value: '#${invitation.teamCaptainId}',
            ),
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            title: 'Created',
            value: _formatDateTime(invitation.createdAt),
          ),
          if (invitation.expiresAt != null)
            _buildInfoRow(
              icon: Icons.timer_outlined,
              title: 'Expires',
              value: _formatDateTime(invitation.expiresAt),
            ),
          if (invitation.respondedAt != null)
            _buildInfoRow(
              icon: Icons.reply_outlined,
              title: 'Responded',
              value: _formatDateTime(invitation.respondedAt),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mail_outline,
                color: primaryColor,
                size: 46,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No invitations yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no invitations for this competition.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _showSendInvitationDialog,
              icon: const Icon(Icons.add),
              label: const Text('Send Invitation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(CompetitionProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 58,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              provider.errorMessage ?? 'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<CompetitionProvider>(
                  context,
                  listen: false,
                ).loadInvitations(widget.competition.id);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showSendInvitationDialog() async {
    final idController = TextEditingController();
    final expiryController = TextEditingController();

    String recipientType = 'player';

    DateTime? selectedExpiry;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Future<void> pickExpiry() async {
              final now = DateTime.now();

              final picked = await showDatePicker(
                context: context,
                firstDate: now,
                lastDate: DateTime(now.year + 5),
                initialDate: now.add(const Duration(days: 7)),
              );

              if (picked == null) return;

              final expiry = DateTime(
                picked.year,
                picked.month,
                picked.day,
                23,
                59,
                59,
              );

              if (!expiry.isAfter(DateTime.now())) return;

              setDialogState(() {
                selectedExpiry = expiry;
                expiryController.text =
                '${expiry.day.toString().padLeft(2, '0')}/'
                    '${expiry.month.toString().padLeft(2, '0')}/'
                    '${expiry.year}';
              });
            }

            return AlertDialog(
              title: const Text(
                'Send Invitation',
                style: TextStyle(
                  color: darkColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: recipientType,
                      decoration: InputDecoration(
                        labelText: 'Recipient Type',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'player',
                          child: Text('Player'),
                        ),
                        DropdownMenuItem(
                          value: 'team',
                          child: Text('Team'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          recipientType = value;
                          idController.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: idController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: recipientType == 'player'
                            ? 'Player ID'
                            : 'Team ID',
                        hintText: 'Enter ID',
                        prefixIcon: const Icon(Icons.tag),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: expiryController,
                      readOnly: true,
                      onTap: pickExpiry,
                      decoration: InputDecoration(
                        labelText: 'Expiration (Optional)',
                        hintText: 'Choose expiration date',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final id = int.tryParse(idController.text.trim());

                    if (id == null || id <= 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a valid recipient ID',
                          ),
                        ),
                      );
                      return;
                    }

                    Navigator.pop(dialogContext, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Send'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true || !mounted) {
      idController.dispose();
      expiryController.dispose();
      return;
    }

    final id = int.tryParse(idController.text.trim());

    if (id == null || id <= 0) {
      idController.dispose();
      expiryController.dispose();
      return;
    }

    final data = <String, dynamic>{
      if (recipientType == 'player') 'player_id': id,
      if (recipientType == 'team') 'team_id': id,
      if (selectedExpiry != null)
        'expires_at': selectedExpiry!.toIso8601String(),
    };

    final provider = Provider.of<CompetitionProvider>(
      context,
      listen: false,
    );

    final invitation = await provider.sendInvitation(
      widget.competition.id,
      data,
    );

    if (!mounted) {
      idController.dispose();
      expiryController.dispose();
      return;
    }

    if (invitation != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invitation sent successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ?? 'Failed to send invitation',
          ),
        ),
      );
    }

    idController.dispose();
    expiryController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CompetitionProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: darkColor,
        elevation: 0,
        title: const Text(
          'Invitations',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Send Invitation',
            onPressed: provider.isLoading
                ? null
                : _showSendInvitationDialog,
            icon: const Icon(Icons.add),
          ),
        ],
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
              return _buildErrorState(provider);
            }

            if (provider.invitations.isEmpty) {
              return _buildEmptyState();
            }

            return RefreshIndicator(
              color: primaryColor,
              onRefresh: () {
                return provider.loadInvitations(
                  widget.competition.id,
                );
              },
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  30,
                ),
                itemCount: provider.invitations.length,
                itemBuilder: (context, index) {
                  return _buildInvitationCard(
                    provider.invitations[index],
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: provider.invitations.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: provider.isLoading
            ? null
            : _showSendInvitationDialog,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.mail_outline),
        label: const Text('Invite'),
      )
          : null,
    );
  }
}
