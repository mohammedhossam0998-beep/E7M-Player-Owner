import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class Aboute7mScreen extends StatelessWidget {
  const Aboute7mScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        title: Text(
          t('about_e7m'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// APP HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xff1E1446), Color(0xff7CC000)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.sports_soccer,
                      size: 50,
                      color: Color(0xff7CC000),
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    "E7gzly Ml3b",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    t('version'),
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t('about_app_desc'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            buildInfoCard(
              Icons.stadium_outlined,
              t('stadium_booking'),
              t('stadium_booking_desc'),
            ),

            buildInfoCard(
              Icons.groups_outlined,
              t('team_creation'),
              t('team_creation_desc'),
            ),

            buildInfoCard(
              Icons.sports_soccer_outlined,
              t('find_matches'),
              t('find_matches_desc'),
            ),

            buildInfoCard(
              Icons.favorite_outline,
              t('favorites'),
              t('favorites_desc'),
            ),

            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    t('developed_by'),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "E7gzly Ml3b Team",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E1446),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              t('all_rights_reserved'),
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildInfoCard(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xff7CC000).withOpacity(0.15),
            child: Icon(icon, color: const Color(0xff7CC000)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}