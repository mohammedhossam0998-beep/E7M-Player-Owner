import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/player_profile_model.dart';
import '../../../../../shared/localization/language_provider.dart';
import 'profile_info_row.dart';

class FootballInfoCard extends StatelessWidget {
  final PlayerProfileModel profile;

  const FootballInfoCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().translate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.sports_soccer_outlined,
                color: Color(0xff7CC000),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t('football_information'),
                  style: const TextStyle(
                    color: Color(0xff1E1446),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          if (_hasValue(profile.position))
            ProfileInfoRow(
              icon: Icons.sports_soccer,
              title: t('primary_position'),
              value: profile.position!,
            ),

          if (_hasValue(profile.skillLevel))
            ProfileInfoRow(
              icon: Icons.star_outline,
              title: t('skill_level'),
              value: profile.skillLevel!,
            ),

          if (_hasValue(profile.playingStyle))
            ProfileInfoRow(
              icon: Icons.flash_on_outlined,
              title: t('playing_style'),
              value: profile.playingStyle!,
            ),

          if (_hasValue(profile.preferredFoot))
            ProfileInfoRow(
              icon: Icons.directions_run_outlined,
              title: t('preferred_foot'),
              value: profile.preferredFoot!,
            ),

          if (profile.experience != null)
            ProfileInfoRow(
              icon: Icons.workspace_premium_outlined,
              title: t('experience'),
              value: '${profile.experience!}',
            ),

          if (!_hasAnyData)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                t('no_information_available'),
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool get _hasAnyData {
    return _hasValue(profile.position) ||
        _hasValue(profile.skillLevel) ||
        _hasValue(profile.playingStyle) ||
        _hasValue(profile.preferredFoot) ||
        profile.experience != null;
  }

  bool _hasValue(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}