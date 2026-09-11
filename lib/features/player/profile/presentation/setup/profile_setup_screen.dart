import 'package:flutter/material.dart';
import 'package:e7m/shared/localization/language_provider.dart';
import 'package:provider/provider.dart';

import 'primary_position_screen.dart';

class ProfileSetupScreen extends StatelessWidget {
  final String fullName;
  final int age;
  final int height;
  final int weight;
  final String city;
  final String bio;

  const ProfileSetupScreen({
    super.key,
    required this.fullName,
    required this.age,
    required this.height,
    required this.weight,
    required this.city,
    required this.bio,
  });

  static const Color backgroundColor = Color(0xffF7F7F3);
  static const Color primaryGreen = Color(0xff7CC000);
  static const Color darkNavy = Color(0xff1E1446);

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
            color: darkNavy,
          ),
        ),
        title: Text(
          t('player_profile'),
          style: const TextStyle(
            color: darkNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('step_2_of_4'),
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              t('football_info'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              t('tell_us_about_your_game'),
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            _infoCard(
              icon: Icons.person_outline,
              title: t('full_name'),
              value: fullName,
            ),

            _infoCard(
              icon: Icons.cake_outlined,
              title: t('age'),
              value: '$age',
            ),

            _infoCard(
              icon: Icons.height,
              title: t('height'),
              value: '$height cm',
            ),

            _infoCard(
              icon: Icons.monitor_weight_outlined,
              title: t('weight'),
              value: '$weight kg',
            ),

            _infoCard(
              icon: Icons.location_on_outlined,
              title: t('governorate_city'),
              value: city,
            ),

            if (bio.isNotEmpty)
              _infoCard(
                icon: Icons.info_outline,
                title: t('about_me'),
                value: bio,
              ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PrimaryPositionScreen(
                        fullName: fullName,
                        age: age,
                        height: height,
                        weight: weight,
                        city: city,
                        bio: bio,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  t('next'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: primaryGreen,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: darkNavy,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}