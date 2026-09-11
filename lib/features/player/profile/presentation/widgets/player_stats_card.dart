import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../shared/localization/language_provider.dart';

class PlayerStatsCard extends StatelessWidget {
  final int? bookings;
  final int? favorites;
  final int? teams;

  const PlayerStatsCard({
    super.key,
    this.bookings,
    this.favorites,
    this.teams,
  });

  static const Color primaryGreen = Color(0xff7CC000);
  static const Color darkNavy = Color(0xff1E1446);

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().translate;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 18,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.calendar_month_outlined,
              title: t('bookings'),
              value: bookings,
            ),
          ),

          _divider(),

          Expanded(
            child: _StatItem(
              icon: Icons.favorite_border,
              title: t('favorites'),
              value: favorites,
            ),
          ),

          _divider(),

          Expanded(
            child: _StatItem(
              icon: Icons.groups_outlined,
              title: t('teams'),
              value: teams,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 45,
      color: Colors.grey.shade200,
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int? value;

  const _StatItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xff7CC000),
          size: 23,
        ),

        const SizedBox(height: 7),

        Text(
          value?.toString() ?? '—',
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}