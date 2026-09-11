import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/player_profile_model.dart';
import '../../../../../shared/localization/language_provider.dart';

class AboutMeCard extends StatelessWidget {
  final PlayerProfileModel profile;

  const AboutMeCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().translate;

    final bio = profile.bio?.trim();

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
                Icons.info_outline,
                color: Color(0xff7CC000),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t('about_me'),
                  style: const TextStyle(
                    color: Color(0xff1E1446),
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            bio == null || bio.isEmpty
                ? t('no_bio_available')
                : bio,
            style: TextStyle(
              color: bio == null || bio.isEmpty
                  ? Colors.grey
                  : const Color(0xff1E1446),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}