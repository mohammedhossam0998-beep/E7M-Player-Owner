import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e7m/features/player/teams/data/models/team_member_model.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class TeamMemberTile extends StatelessWidget {
  final TeamMemberModel member;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;
  final bool showRemoveButton;

  // New: allows extra actions such as transfer captaincy.
  final Widget? trailing;

  const TeamMemberTile({
    super.key,
    required this.member,
    this.onTap,
    this.onRemove,
    this.showRemoveButton = false,
    this.trailing,
  });

  static const Color primaryGreen = Color(0xff7CC000);
  static const Color darkNavy = Color(0xff1E1446);

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final t = languageProvider.translate;

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 10,
          ),
          child: Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),

              Expanded(
                child: _buildMemberInfo(t),
              ),

              // Extra action.
              if (trailing != null) trailing!,

              // Existing remove-player action.
              if (showRemoveButton && onRemove != null)
                IconButton(
                  onPressed: onRemove,
                  tooltip: t('remove_player'),
                  icon: const Icon(
                    Icons.person_remove_outlined,
                    color: Colors.redAccent,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // AVATAR
  // ============================================================

  Widget _buildAvatar() {
    final hasImage =
        member.profileImage != null &&
            member.profileImage!.trim().isNotEmpty;

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xffEEF5E5),
        shape: BoxShape.circle,
        border: Border.all(
          color: primaryGreen.withOpacity(0.20),
        ),
      ),
      child: ClipOval(
        child: hasImage
            ? Image.network(
          member.profileImage!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _buildAvatarPlaceholder();
          },
        )
            : _buildAvatarPlaceholder(),
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return const Icon(
      Icons.person_outline_rounded,
      color: primaryGreen,
      size: 27,
    );
  }

  // ============================================================
  // MEMBER INFO
  // ============================================================

  Widget _buildMemberInfo(String Function(String) t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                member.fullName.isEmpty
                    ? t('player')
                    : member.fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: darkNavy,
                ),
              ),
            ),
            if (member.isCaptain) ...[
              const SizedBox(width: 6),
              _buildCaptainBadge(t),
            ],
          ],
        ),
        const SizedBox(height: 5),
        Text(
          member.isCaptain
              ? t('captain')
              : t('player'),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // CAPTAIN BADGE
  // ============================================================

  Widget _buildCaptainBadge(String Function(String) t) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: primaryGreen.withOpacity(0.12),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.star_rounded,
            size: 12,
            color: primaryGreen,
          ),
          const SizedBox(width: 3),
          Text(
            t('captain'),
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: darkNavy,
            ),
          ),
        ],
      ),
    );
  }
}