import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/team_join_request_model.dart';
import '../providers/team_provider.dart';
import '../../../../../shared/localization/language_provider.dart';

class TeamRequestsScreen extends StatefulWidget {
  final int teamId;
  final String? teamName;

  const TeamRequestsScreen({
    super.key,
    required this.teamId,
    this.teamName,
  });

  @override
  State<TeamRequestsScreen> createState() =>
      _TeamRequestsScreenState();
}

class _TeamRequestsScreenState extends State<TeamRequestsScreen> {
  static const Color primaryGreen = Color(0xff7CC000);
  static const Color darkNavy = Color(0xff1E1446);
  static const Color background = Color(0xffF7F7F3);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<TeamProvider>().loadJoinRequests(
        widget.teamId,
      );
    });
  }

  Future<void> _refresh() async {
    await context.read<TeamProvider>().loadJoinRequests(
      widget.teamId,
    );
  }

  Future<void> _approve(
      TeamJoinRequestModel request,
      ) async {
    final t = context.read<LanguageProvider>().translate;

    final confirmed = await _showConfirmDialog(
      title: t('approve_request'),
      message:
      '${t('approve_request_question')} ${request.fullName ?? t('player')}?',
      confirmText: t('approve'),
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<TeamProvider>();

    final success =
    await provider.approveJoinRequest(
      teamId: widget.teamId,
      requestId: request.id,
    );

    if (!mounted) return;

    _showMessage(
      success
          ? t('request_approved')
          : provider.errorMessage ??
          t('something_went_wrong'),
    );
  }

  Future<void> _reject(
      TeamJoinRequestModel request,
      ) async {
    final t = context.read<LanguageProvider>().translate;

    final confirmed = await _showConfirmDialog(
      title: t('reject_request'),
      message:
      '${t('reject_request_question')} ${request.fullName ?? t('player')}?',
      confirmText: t('reject'),
      isDestructive: true,
    );

    if (confirmed != true || !mounted) return;

    final provider = context.read<TeamProvider>();

    final success =
    await provider.rejectJoinRequest(
      teamId: widget.teamId,
      requestId: request.id,
    );

    if (!mounted) return;

    _showMessage(
      success
          ? t('request_rejected')
          : provider.errorMessage ??
          t('something_went_wrong'),
    );
  }

  Future<bool?> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: darkNavy,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                context.read<LanguageProvider>().translate('cancel'),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: isDestructive
                    ? Colors.red.shade600
                    : primaryGreen,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
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

  TeamJoinRequestModel _mapRequest(
      Map<String, dynamic> json,
      ) {
    return TeamJoinRequestModel.fromJson(json);
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
          widget.teamName == null ||
              widget.teamName!.trim().isEmpty
              ? t('team_requests')
              : widget.teamName!,
          style: const TextStyle(
            color: darkNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<TeamProvider>(
          builder: (
              context,
              provider,
              _,
              ) {
            final requests = provider.joinRequests
                .map(_mapRequest)
                .toList();

            if (provider.isLoadingRequests &&
                requests.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryGreen,
                ),
              );
            }

            if (provider.errorMessage != null &&
                requests.isEmpty) {
              return _ErrorState(
                message: provider.errorMessage!,
                onRetry: _refresh,
              );
            }

            if (requests.isEmpty) {
              return _EmptyRequests(
                onRefresh: _refresh,
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
                itemCount: requests.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final request = requests[index];

                  return _RequestCard(
                    request: request,
                    onApprove: request.isPending
                        ? () => _approve(request)
                        : null,
                    onReject: request.isPending
                        ? () => _reject(request)
                        : null,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  final TeamJoinRequestModel request;
  final VoidCallback? onApprove;
  final VoidCallback? onReject;

  const _RequestCard({
    required this.request,
    this.onApprove,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _ProfileImage(
                imageUrl: request.profileImage,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.fullName ??
                          t('player'),
                      maxLines: 2,
                      overflow:
                      TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xff1E1446),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    _StatusBadge(
                      status: request.status,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (request.position != null &&
                  request.position!
                      .trim()
                      .isNotEmpty)
                _InfoChip(
                  icon: Icons.sports_soccer,
                  text: request.position!,
                ),
              if (request.skillLevel != null &&
                  request.skillLevel!
                      .trim()
                      .isNotEmpty)
                _InfoChip(
                  icon: Icons.bar_chart_rounded,
                  text: _skillLabel(
                    request.skillLevel!,
                    t,
                  ),
                ),
              if (request.city != null &&
                  request.city!
                      .trim()
                      .isNotEmpty)
                _InfoChip(
                  icon: Icons.location_city_outlined,
                  text: request.city!,
                ),
            ],
          ),

          if (request.experience != null &&
              request.experience!
                  .trim()
                  .isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '${t('experience')}: ${request.experience}',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
              ),
            ),
          ],

          if (request.isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onReject,
                    icon: const Icon(
                      Icons.close_rounded,
                    ),
                    label: Text(
                      t('reject'),
                    ),
                    style:
                    OutlinedButton.styleFrom(
                      foregroundColor:
                      Colors.red.shade700,
                      side: BorderSide(
                        color: Colors.red.shade300,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(
                      Icons.check_rounded,
                    ),
                    label: Text(
                      t('approve'),
                    ),
                    style:
                    FilledButton.styleFrom(
                      backgroundColor:
                      const Color(0xff7CC000),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _skillLabel(
      String value,
      String Function(String) t,
      ) {
    switch (value.toLowerCase()) {
      case 'beginner':
        return t('beginner');
      case 'intermediate':
        return t('intermediate');
      case 'advanced':
        return t('advanced');
      default:
        return value;
    }
  }
}

class _ProfileImage extends StatelessWidget {
  final String? imageUrl;

  const _ProfileImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xff7CC000)
            .withValues(alpha: 0.10),
      ),
      child: ClipOval(
        child: imageUrl != null &&
            imageUrl!.trim().isNotEmpty
            ? Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return const Icon(
              Icons.person_rounded,
              color: Color(0xff7CC000),
              size: 30,
            );
          },
        )
            : const Icon(
          Icons.person_rounded,
          color: Color(0xff7CC000),
          size: 30,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final normalized =
    status.toLowerCase();

    final isApproved =
        normalized == 'approved';
    final isRejected =
        normalized == 'rejected';

    final Color background;
    final Color foreground;
    final String label;

    if (isApproved) {
      background =
          Colors.green.withValues(alpha: 0.10);
      foreground = Colors.green.shade700;
      label = context.read<LanguageProvider>().translate(
        'approved',
      );
    } else if (isRejected) {
      background =
          Colors.red.withValues(alpha: 0.10);
      foreground = Colors.red.shade700;
      label = context.read<LanguageProvider>().translate(
        'rejected',
      );
    } else {
      background =
          const Color(0xff7CC000)
              .withValues(alpha: 0.10);
      foreground = const Color(0xff5D9200);
      label = context.read<LanguageProvider>().translate(
        'pending',
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: const Color(0xff7CC000),
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyRequests extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyRequests({
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mark_email_read_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              t('no_join_requests'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xff1E1446),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t('no_join_requests_message'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(
                Icons.refresh_rounded,
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

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
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