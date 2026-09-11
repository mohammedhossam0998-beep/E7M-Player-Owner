import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        // ✅ إضافة سهم الرجوع الديناميكي المتوافق مع اللغتين وتناسق الألوان
        leading: IconButton(
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
            color: const Color(0xff1E1446),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [Color(0xff1E1446), Color(0xff7CC000)],
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.shield_outlined,
                    color: Colors.white,
                    size: 70,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    t('data_protected'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    t('data_protected_desc'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            buildCard(
              Icons.lock_outline,
              t('password_protection'),
              t('password_protection_desc'),
            ),

            buildCard(
              Icons.verified_user_outlined,
              t('account_security'),
              t('account_security_desc'),
            ),

            buildCard(
              Icons.payment_outlined,
              t('secure_payments'),
              t('secure_payments_desc'),
            ),

            buildCard(
              Icons.privacy_tip_outlined,
              t('privacy_policy'),
              t('privacy_policy_desc'),
            ),

            buildCard(
              Icons.delete_outline,
              t('data_control'),
              t('data_control_desc'),
            ),

            const SizedBox(height: 20),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                t('privacy_note'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(IconData icon, String title, String subtitle) {
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
              // ✅ محاذاة النصوص لتبدأ تلقائياً حسب اتجاه التطبيق (يمين في العربي، يسار في الإنجليزي)
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
