import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/team_model.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class TeamCard extends StatelessWidget {
  final TeamModel team;
  final VoidCallback? onTap;
  final VoidCallback? onJoin;
  final bool showJoinButton;

  const TeamCard({
    super.key,
    required this.team,
    this.onTap,
    this.onJoin,
    this.showJoinButton = true,
  });

  static const Color primaryGreen =
  Color(0xff7CC000);

  static const Color darkNavy =
  Color(0xff1E1446);

  @override
  Widget build(BuildContext context) {
    final t =
        context.read<LanguageProvider>().translate;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 2,
      shadowColor:
      Colors.black.withOpacity(0.10),
      child: InkWell(
        onTap: onTap,
        borderRadius:
        BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              _buildLogo(),

              const SizedBox(width: 14),

              Expanded(
                child: _buildContent(t),
              ),

              if (showJoinButton) ...[
                const SizedBox(width: 8),
                _buildJoinButton(t),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // LOGO
  // ============================================================

  Widget _buildLogo() {
    final hasLogo =
        team.logo != null &&
            team.logo!.trim().isNotEmpty;

    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xffEEF5E5),
        shape: BoxShape.circle,
        border: Border.all(
          color:
          primaryGreen.withOpacity(0.25),
        ),
      ),
      child: ClipOval(
        child: hasLogo
            ? Image.network(
          team.logo!,
          fit: BoxFit.cover,
          errorBuilder:
              (_, __, ___) =>
              _buildLogoPlaceholder(),
        )
            : _buildLogoPlaceholder(),
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return const Icon(
      Icons.groups_rounded,
      color: primaryGreen,
      size: 30,
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _buildContent(
      String Function(String) t,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          team.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: darkNavy,
          ),
        ),

        const SizedBox(height: 6),

        if (_locationText != null)
          _buildInfoRow(
            Icons.location_on_outlined,
            _locationText!,
          ),

        if (team.distanceKm != null) ...[
          const SizedBox(height: 5),
          _buildInfoRow(
            Icons.near_me_outlined,
            '${team.distanceKm!.toStringAsFixed(1)} km',
          ),
        ],

        const SizedBox(height: 8),

        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (team.gameType != null &&
                team.gameType!.isNotEmpty)
              _buildTag(
                team.gameType!,
                Icons.sports_soccer,
              ),

            if (team.skillLevel != null &&
                team.skillLevel!.isNotEmpty)
              _buildTag(
                team.skillLevel!,
                Icons.signal_cellular_alt,
              ),

            _buildSlotsTag(t),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // LOCATION
  // ============================================================

  String? get _locationText {
    if (team.locationName != null &&
        team.locationName!.trim().isNotEmpty) {
      return team.locationName!.trim();
    }

    if (team.city != null &&
        team.city!.trim().isNotEmpty) {
      return team.city!.trim();
    }

    return null;
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(
      IconData icon,
      String text,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TAG
  // ============================================================

  Widget _buildTag(
      String text,
      IconData icon,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color:
        primaryGreen.withOpacity(0.09),
        borderRadius:
        BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: primaryGreen,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: darkNavy,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AVAILABLE SLOTS
  // ============================================================

  Widget _buildSlotsTag(
      String Function(String) t,
      ) {
    final hasSlots =
        team.availableSlots > 0;

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: hasSlots
            ? Colors.orange.withOpacity(0.10)
            : Colors.red.withOpacity(0.10),
        borderRadius:
        BorderRadius.circular(9),
      ),
      child: Text(
        hasSlots
            ? '${team.availableSlots} ${t('slots_left')}'
            : t('full'),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: hasSlots
              ? Colors.deepOrange
              : Colors.red,
        ),
      ),
    );
  }

  // ============================================================
  // JOIN BUTTON
  // ============================================================

  Widget _buildJoinButton(
      String Function(String) t,
      ) {
    final bool isDisabled =
        team.isMember ||
            team.hasPendingRequest ||
            team.availableSlots <= 0;

    final String buttonText;

    if (team.isMember) {
      buttonText = t('joined');
    } else if (team.hasPendingRequest) {
      buttonText = t('pending');
    } else if (team.availableSlots <= 0) {
      buttonText = t('full');
    } else {
      buttonText = t('join');
    }

    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed:
        isDisabled ? null : onJoin,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          disabledBackgroundColor:
          Colors.grey.shade300,
          foregroundColor: Colors.white,
          disabledForegroundColor:
          Colors.grey.shade600,
          elevation: 0,
          padding:
          const EdgeInsets.symmetric(
            horizontal: 13,
          ),
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(12),
          ),
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}