import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
          languageProvider.translate('privacy_policy'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.privacy_tip, color: Color(0xff7CC000), size: 70),
            const SizedBox(height: 20),
            Text(
              languageProvider.translate('privacy_policy'),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xff1E1446),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              languageProvider.translate('privacy_last_updated'),
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 30),
            privacySection(
              title: languageProvider.translate(
                'privacy_information_collect',
              ),
              content: languageProvider.translate(
                'privacy_information_collect_desc',
              ),
            ),
            privacySection(
              title: languageProvider.translate('privacy_information_use'),
              content: languageProvider.translate(
                'privacy_information_use_desc',
              ),
            ),
            privacySection(
              title: languageProvider.translate('privacy_data_security'),
              content: languageProvider.translate(
                'privacy_data_security_desc',
              ),
            ),
            privacySection(
              title: languageProvider.translate('privacy_third_party'),
              content: languageProvider.translate('privacy_third_party_desc'),
            ),
            privacySection(
              title: languageProvider.translate('privacy_user_rights'),
              content: languageProvider.translate('privacy_user_rights_desc'),
            ),
            privacySection(
              title: languageProvider.translate('privacy_contact_us'),
              content: languageProvider.translate('privacy_contact_us_desc'),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: .08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xff7CC000).withValues(alpha: .3),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.verified_user, color: Color(0xff7CC000)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      languageProvider.translate('privacy_agreement'),
                      style: const TextStyle(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle, color: Colors.white),
                label: Text(
                  languageProvider.translate('i_understand'),
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
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget privacySection({required String title, required String content}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E1446),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(color: Colors.black87, height: 1.6),
          ),
        ],
      ),
    );
  }
}