import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          languageProvider.translate('about_e7m'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            const SizedBox(height: 10),

            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.06),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Icon(
                Icons.stadium,
                size: 70,
                color: Color(0xff7CC000),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "E7gzly Ml3b",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xff1E1446),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              languageProvider.translate('soccer_stadium_booking_platform'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xff7CC000),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                '${languageProvider.translate('version')} 1.0.0',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 35),
            aboutTile(
              icon: Icons.person,
              color: Colors.blue,
              title: languageProvider.translate('developer'),
              subtitle: languageProvider.translate('development_team'),
            ),

            aboutTile(
              icon: Icons.email_outlined,
              color: Colors.red,
              title: languageProvider.translate('support_email'),
              subtitle: "support@e7m.com",
            ),

            aboutTile(
              icon: Icons.language,
              color: Colors.green,
              title: languageProvider.translate('website'),
              subtitle: "www.e7m.com",
            ),

            aboutTile(
              icon: Icons.security,
              color: Colors.orange,
              title: languageProvider.translate('privacy_policy'),
              subtitle: languageProvider.translate('read_privacy_policy'),
            ),

            aboutTile(
              icon: Icons.description,
              color: Colors.indigo,
              title: languageProvider.translate('terms_conditions'),
              subtitle: languageProvider.translate('application_usage_terms'),
            ),

            aboutTile(
              icon: Icons.code,
              color: Colors.deepPurple,
              title: languageProvider.translate('open_source_licenses'),
              subtitle: languageProvider.translate('libraries_used'),
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.05),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageProvider.translate('about'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E1446),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    languageProvider.translate('about_e7m_description'),
                    style: const TextStyle(height: 1.6, color: Colors.black87),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xff7CC000).withOpacity(.25),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, color: Color(0xff7CC000)),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Text(
                      languageProvider.translate('thank_you_message'),
                      style: const TextStyle(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xff7CC000),
                      content: Text(
                        languageProvider.translate('latest_version_message'),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.system_update, color: Colors.white),
                label: Text(
                  languageProvider.translate('check_for_updates'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff7CC000),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            Text(
              languageProvider.translate('copyright'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget aboutTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withOpacity(.15),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
      ),
    );
  }
}