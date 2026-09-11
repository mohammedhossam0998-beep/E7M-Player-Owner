import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        // ✅ إضافة الـ leading لضبط اتجاه السهم عند قلب اللغة
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t('privacy_security'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.security,
                    size: 70,
                    color: Color(0xff7CC000),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t('your_privacy_matters'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E1446),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t('privacy_intro'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey, height: 1.6),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            buildCard(
              Icons.person_outline,
              t('account_information'),
              t('account_information_desc'),
            ),
            buildCard(
              Icons.lock_outline,
              t('password_protection'),
              t('password_protection_desc'),
            ),
            buildCard(
              Icons.shield_outlined,
              t('secure_payments'),
              t('secure_payments_desc'),
            ),
          ],
        ),
      ),
    );
  }

  static Widget buildCard(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xff7CC000)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(subtitle, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
