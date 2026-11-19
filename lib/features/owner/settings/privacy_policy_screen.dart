
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:e7m/shared/localization/language_provider.dart';

// ============================================================
// E7M PRIVACY POLICY SCREEN
// ============================================================

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // ============================================================
  // THEME COLORS
  // ============================================================

  static const Color _green = Color(0xFF7CC000);
  static const Color _navy = Color(0xFF1E1446);
  static const Color _background = Color(0xFFF7F8FA);
  static const Color _border = Color(0xFFE8EAF0);
  static const Color _secondary = Color(0xFF777B86);

  // ============================================================
  // OFFICIAL SUPPORT CONTACTS
  // ============================================================

  static const String supportEmail =
      'e7gzlyml3b@gmail.com';

  static const String supportPhone =
      '01029149458';

  // ============================================================
  // POLICY LAST UPDATED
  //
  // Set the actual approved policy date using:
  // --dart-define=E7M_PRIVACY_LAST_UPDATED=YYYY-MM-DD
  //
  // No invented date is shown if not configured.
  // ============================================================

  static const String _lastUpdated =
  String.fromEnvironment(
    'E7M_PRIVACY_LAST_UPDATED',
  );

  // ============================================================
  // LOCALIZED TEXT HELPER
  // ============================================================

  String _text(
      bool arabic,
      String ar,
      String en,
      ) {
    return arabic ? ar : en;
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _showMessage(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: _navy,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // COPY CONTACT
  // ============================================================

  Future<void> _copyContact(
      BuildContext context,
      String value,
      bool arabic,
      ) async {
    await Clipboard.setData(
      ClipboardData(text: value),
    );

    if (!context.mounted) return;

    _showMessage(
      context,
      _text(
        arabic,
        'تم نسخ بيانات التواصل',
        'Contact information copied',
      ),
    );
  }

  // ============================================================
  // OPEN EMAIL / PHONE
  //
  // If the device cannot open the external app,
  // automatically copy the contact.
  // ============================================================

  Future<void> _openContact(
      BuildContext context, {
        required Uri uri,
        required String fallbackValue,
        required bool arabic,
      }) async {
    bool opened = false;

    try {
      opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      debugPrint(
        'PRIVACY CONTACT ERROR: $error',
      );
    }

    if (!context.mounted) return;

    if (!opened) {
      await _copyContact(
        context,
        fallbackValue,
        arabic,
      );
    }
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================

  Widget _buildHeader(
      bool arabic,
      LanguageProvider language,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            _navy,
            Color(0xFF30205B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
              borderRadius:
              BorderRadius.circular(22),
            ),
            child: const Icon(
              Icons.privacy_tip_rounded,
              color: _green,
              size: 43,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            language.translate('privacy_policy'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            _text(
              arabic,
              'خصوصيتك مهمة لنا في E7M',
              'Your privacy matters at E7M',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),

          if (_lastUpdated.trim().isNotEmpty) ...[
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.12,
                ),
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: Text(
                '${_text(arabic, 'آخر تحديث', 'Last updated')}: $_lastUpdated',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // INTRODUCTION
  // ============================================================

  Widget _buildIntroduction(bool arabic) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: _green,
            size: 25,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              _text(
                arabic,
                'توضح سياسة الخصوصية المعلومات المتعلقة '
                    'بكيفية التعامل مع بيانات المستخدمين '
                    'داخل منصة E7M. يرجى قراءة الأقسام '
                    'التالية بعناية، والتواصل معنا إذا '
                    'كانت لديك أي استفسارات.',
                'This privacy policy provides information '
                    'about how user data is handled within '
                    'E7M. Please review the following '
                    'sections carefully and contact us '
                    'if you have any questions.',
              ),
              style: const TextStyle(
                color: _navy,
                height: 1.7,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PRIVACY SECTION
  // ============================================================

  Widget _privacySection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.025,
            ),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _green.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                  BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: _green,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 13),

          Text(
            content,
            style: const TextStyle(
              color: Color(0xFF484B55),
              fontSize: 13.5,
              height: 1.75,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // CONTACT TILE
  // ============================================================

  Widget _contactTile({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
    required VoidCallback onTap,
    required VoidCallback onCopy,
  }) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      decoration: BoxDecoration(
        color: _background,
        borderRadius:
        BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 5,
        ),
        onTap: onTap,

        leading: CircleAvatar(
          backgroundColor:
          color.withValues(alpha: 0.12),
          child: Icon(
            icon,
            color: color,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            color: _navy,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),

        subtitle: SelectableText(
          value,
          style: const TextStyle(
            fontSize: 13,
          ),
        ),

        trailing: IconButton(
          tooltip: 'Copy',
          onPressed: onCopy,
          icon: const Icon(
            Icons.copy_outlined,
            size: 19,
            color: _secondary,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // CONTACT SECTION
  // ============================================================

  Widget _buildContactSection(
      BuildContext context,
      bool arabic,
      LanguageProvider language,
      ) {
    return Container(
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.support_agent_rounded,
                color: _green,
                size: 27,
              ),

              const SizedBox(width: 11),

              Expanded(
                child: Text(
                  language.translate(
                    'privacy_contact_us',
                  ),
                  style: const TextStyle(
                    color: _navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            _text(
              arabic,
              'لو عندك استفسار عن خصوصية بياناتك '
                  'أو محتاج مساعدة بخصوص حسابك '
                  'في E7M، تقدر تتواصل معانا '
                  'من خلال البيانات التالية.',
              'If you have questions about your '
                  'personal data or need assistance '
                  'with your E7M account, please '
                  'contact us using the details below.',
            ),
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: _secondary,
            ),
          ),

          const SizedBox(height: 16),

          // ==================================================
          // EMAIL
          // ==================================================

          _contactTile(
            icon: Icons.email_outlined,
            color: Colors.blue,
            title: _text(
              arabic,
              'البريد الإلكتروني',
              'Support Email',
            ),
            value: supportEmail,

            onTap: () {
              _openContact(
                context,
                uri: Uri(
                  scheme: 'mailto',
                  path: supportEmail,
                  queryParameters: {
                    'subject':
                    'E7M Privacy Inquiry',
                  },
                ),
                fallbackValue: supportEmail,
                arabic: arabic,
              );
            },

            onCopy: () {
              _copyContact(
                context,
                supportEmail,
                arabic,
              );
            },
          ),

          // ==================================================
          // PHONE
          // ==================================================

          _contactTile(
            icon: Icons.phone_outlined,
            color: Colors.teal,
            title: _text(
              arabic,
              'رقم التواصل',
              'Contact Phone',
            ),
            value: supportPhone,

            onTap: () {
              _openContact(
                context,
                uri: Uri(
                  scheme: 'tel',
                  path: supportPhone,
                ),
                fallbackValue: supportPhone,
                arabic: arabic,
              );
            },

            onCopy: () {
              _copyContact(
                context,
                supportPhone,
                arabic,
              );
            },
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFORMATION NOTICE
  // ============================================================

  Widget _buildNotice(bool arabic) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _green.withValues(
          alpha: 0.08,
        ),
        borderRadius:
        BorderRadius.circular(18),
        border: Border.all(
          color: _green.withValues(
            alpha: 0.25,
          ),
        ),
      ),

      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.verified_user_outlined,
            color: _green,
            size: 26,
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              _text(
                arabic,
                'لو عندك أي سؤال عن استخدام بياناتك '
                    'أو حقوق الخصوصية الخاصة بيك، '
                    'تقدر تتواصل مع فريق دعم E7M.',
                'If you have questions about '
                    'how your data is used or '
                    'your privacy rights, '
                    'you can contact E7M support.',
              ),
              style: const TextStyle(
                color: _navy,
                height: 1.65,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final language =
    context.watch<LanguageProvider>();

    final arabic =
        language.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor: _background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0,
        centerTitle: true,
        title: Text(
          language.translate(
            'privacy_policy',
          ),
          style: const TextStyle(
            color: _navy,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 780,
          ),

          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              16,
              20,
              16,
              36,
            ),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,
              children: [
                // ============================================
                // HEADER
                // ============================================

                _buildHeader(
                  arabic,
                  language,
                ),

                const SizedBox(height: 18),

                // ============================================
                // INTRODUCTION
                // ============================================

                _buildIntroduction(arabic),

                const SizedBox(height: 24),

                // ============================================
                // INFORMATION COLLECTED
                // ============================================

                _privacySection(
                  icon:
                  Icons.person_outline_rounded,

                  title: language.translate(
                    'privacy_information_collect',
                  ),

                  content: language.translate(
                    'privacy_information_collect_desc',
                  ),
                ),

                // ============================================
                // INFORMATION USE
                // ============================================

                _privacySection(
                  icon:
                  Icons.settings_outlined,

                  title: language.translate(
                    'privacy_information_use',
                  ),

                  content: language.translate(
                    'privacy_information_use_desc',
                  ),
                ),

                // ============================================
                // DATA SECURITY
                // ============================================

                _privacySection(
                  icon:
                  Icons.lock_outline_rounded,

                  title: language.translate(
                    'privacy_data_security',
                  ),

                  content: language.translate(
                    'privacy_data_security_desc',
                  ),
                ),

                // ============================================
                // THIRD PARTIES
                // ============================================

                _privacySection(
                  icon:
                  Icons.hub_outlined,

                  title: language.translate(
                    'privacy_third_party',
                  ),

                  content: language.translate(
                    'privacy_third_party_desc',
                  ),
                ),

                // ============================================
                // USER RIGHTS
                // ============================================

                _privacySection(
                  icon:
                  Icons.manage_accounts_outlined,

                  title: language.translate(
                    'privacy_user_rights',
                  ),

                  content: language.translate(
                    'privacy_user_rights_desc',
                  ),
                ),

                // ============================================
                // CONTACT US
                // ============================================

                _buildContactSection(
                  context,
                  arabic,
                  language,
                ),

                const SizedBox(height: 18),

                // ============================================
                // PRIVACY NOTICE
                // ============================================

                _buildNotice(arabic),

                const SizedBox(height: 24),

                // ============================================
                // BACK BUTTON
                // This does not record legal consent.
                // ============================================

                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).maybePop();
                    },

                    icon: const Icon(
                      Icons.arrow_back_rounded,
                    ),

                    label: Text(
                      _text(
                        arabic,
                        'الرجوع',
                        'Back',
                      ),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor:
                      Colors.white,
                      elevation: 0,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'E7M',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _secondary.withValues(
                      alpha: 0.8,
                    ),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
