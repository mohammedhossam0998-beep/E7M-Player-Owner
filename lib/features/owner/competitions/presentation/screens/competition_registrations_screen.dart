import 'package:e7m/shared/localization/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/competition_model.dart';
import '../../data/models/competition_registration_model.dart';
import '../providers/competition_provider.dart';

class CompetitionRegistrationsScreen extends StatefulWidget {
  final CompetitionModel competition;

  const CompetitionRegistrationsScreen({
    super.key,
    required this.competition,
  });

  @override
  State<CompetitionRegistrationsScreen> createState() =>
      _CompetitionRegistrationsScreenState();
}

class _CompetitionRegistrationsScreenState
    extends State<CompetitionRegistrationsScreen> {
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
      ).loadRegistrations(widget.competition.id);
    });
  }

  String _statusText(LanguageProvider lp, String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return lp.translate('status_approved');
      case 'rejected':
        return lp.translate('status_rejected');
      case 'pending':
        return lp.translate('status_pending');
      case 'waitlisted':
      case 'waitlist':
        return lp.translate('status_waitlist');
      case 'cancelled':
        return lp.translate('status_cancelled');
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      case 'waitlisted':
      case 'waitlist':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusBadge(LanguageProvider lp, String status) {
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
        _statusText(lp, status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  String _formatDate(LanguageProvider lp, DateTime? date) {
    if (date == null) return lp.translate('not_available');

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  Widget _buildAvatar(CompetitionRegistrationModel registration) {
    final image = registration.playerProfileImage;

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

  Future<void> _approve(
      LanguageProvider lp,
      CompetitionRegistrationModel registration,
      ) async {
    final provider = Provider.of<CompetitionProvider>(
      context,
      listen: false,
    );

    final result = await provider.approveRegistration(
      widget.competition.id,
      registration.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result != null
              ? lp.translate('registration_approved_success')
              : provider.errorMessage ??
              lp.translate('registration_approve_failed'),
        ),
      ),
    );
  }

  Future<void> _reject(
      LanguageProvider lp,
      CompetitionRegistrationModel registration,
      ) async {
    final provider = Provider.of<CompetitionProvider>(
      context,
      listen: false,
    );

    final result = await provider.rejectRegistration(
      widget.competition.id,
      registration.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result != null
              ? lp.translate('registration_rejected_success')
              : provider.errorMessage ??
              lp.translate('registration_reject_failed'),
        ),
      ),
    );
  }

  Future<void> _moveToWaitlist(
      LanguageProvider lp,
      CompetitionRegistrationModel registration,
      ) async {
    final provider = Provider.of<CompetitionProvider>(
      context,
      listen: false,
    );

    final result = await provider.moveRegistrationToWaitlist(
      widget.competition.id,
      registration.id,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result != null
              ? lp.translate('registration_waitlisted_success')
              : provider.errorMessage ??
              lp.translate('registration_waitlist_failed'),
        ),
      ),
    );
  }

  Widget _buildActions(
      LanguageProvider lp,
      CompetitionRegistrationModel registration,
      bool isLoading,
      ) {
    final status = registration.status.toLowerCase();

    if (status != 'pending') {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLoading ? null : () => _reject(lp, registration),
            icon: const Icon(
              Icons.close,
              size: 18,
            ),
            label: Text(lp.translate('action_reject')),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(
                color: Colors.red,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: isLoading
                ? null
                : () => _moveToWaitlist(lp, registration),
            icon: const Icon(
              Icons.hourglass_empty,
              size: 18,
            ),
            label: Text(lp.translate('action_waitlist')),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(
                color: Colors.blue,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: isLoading ? null : () => _approve(lp, registration),
            icon: const Icon(
              Icons.check,
              size: 18,
            ),
            label: Text(lp.translate('action_approve')),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationCard(
      LanguageProvider lp,
      CompetitionRegistrationModel registration,
      bool isLoading,
      ) {
    final playerName = registration.playerName?.trim();

    final displayName =
    playerName != null && playerName.isNotEmpty
        ? playerName
        : registration.teamName ??
        '${lp.translate('registration_hash')}${registration.id}';

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
              _buildAvatar(registration),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
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
                      registration.playerId != null
                          ? '${lp.translate('player_hash')}${registration.playerId}'
                          : registration.teamId != null
                          ? '${lp.translate('team_hash')}${registration.teamId}'
                          : '${lp.translate('registration_hash')}${registration.id}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(lp, registration.status),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          if (registration.playerEmail != null &&
              registration.playerEmail!.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 17,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      registration.playerEmail!,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (registration.registeredAt != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 17,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${lp.translate('registered_label')}: ${_formatDate(lp, registration.registeredAt)}',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          _buildActions(lp, registration, isLoading),
        ],
      ),
    );
  }

  Widget _buildEmptyState(LanguageProvider lp) {
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
                Icons.people_outline,
                color: primaryColor,
                size: 46,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              lp.translate('no_registrations_title'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              lp.translate('no_registrations_subtitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(LanguageProvider lp, CompetitionProvider provider) {
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
              provider.errorMessage ?? lp.translate('something_went_wrong'),
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
                ).loadRegistrations(widget.competition.id);
              },
              icon: const Icon(Icons.refresh),
              label: Text(lp.translate('retry')),
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

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CompetitionProvider>(context);
    final lp = context.watch<LanguageProvider>();
    final isArabic = lp.currentLocale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: darkColor,
          elevation: 0,
          title: Text(
            lp.translate('registrations_title'),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SafeArea(
          child: Builder(
            builder: (context) {
              if (provider.isLoading &&
                  provider.registrations.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: primaryColor,
                  ),
                );
              }

              if (provider.errorMessage != null &&
                  provider.registrations.isEmpty) {
                return _buildErrorState(lp, provider);
              }

              if (provider.registrations.isEmpty) {
                return _buildEmptyState(lp);
              }

              return RefreshIndicator(
                color: primaryColor,
                onRefresh: () {
                  return provider.loadRegistrations(
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
                  itemCount: provider.registrations.length,
                  itemBuilder: (context, index) {
                    return _buildRegistrationCard(
                      lp,
                      provider.registrations[index],
                      provider.isLoading,
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