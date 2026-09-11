import 'package:flutter/material.dart';

import '../../data/models/competition_model.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class CompetitionStatsCard extends StatelessWidget {
  final CompetitionModel competition;
  final LanguageProvider languageProvider;

  const CompetitionStatsCard({
    super.key,
    required this.competition,
    required this.languageProvider,
  });

  static const Color primaryColor = Color(0xff7CC000);
  static const Color darkColor = Color(0xff1E1446);

  String _t(String key) {
    return languageProvider.translate(key);
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xffF7F8FA),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: primaryColor,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: darkColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _t('competition_information'),
              style: const TextStyle(
                color: darkColor,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                _buildStatItem(
                  icon: Icons.payments_outlined,
                  title: _t('entry_fee'),
                  value: '${competition.entryFee} EGP',
                ),
                const SizedBox(width: 10),
                _buildStatItem(
                  icon: Icons.groups_outlined,
                  title: _t('maximum_teams'),
                  value:
                  competition.maxParticipants?.toString() ??
                      _t('not_set'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                _buildStatItem(
                  icon: Icons.person_outline,
                  title: 'Min Players',
                  value:
                  competition.minPlayersPerTeam?.toString() ??
                      _t('not_set'),
                ),
                const SizedBox(width: 10),
                _buildStatItem(
                  icon: Icons.groups_2_outlined,
                  title: 'Max Players',
                  value:
                  competition.maxPlayersPerTeam?.toString() ??
                      _t('not_set'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}