
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'privacy_policy_screen.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const Color _green = Color(0xFF7CC000);
  static const Color _navy = Color(0xFF1E1446);
  static const Color _background = Color(0xFFF7F8FA);

  // ============================================================
  // SUPPORT CONTACTS
  // ============================================================

  static const String _supportEmail =
      'e7gzlyml3b@gmail.com';

  static const String _supportPhone =
      '01029149458';

  static const String _whatsAppUrl =
      'https://wa.me/201029149458';

  // ============================================================
  // OFFICIAL LINKS
  // Supply through --dart-define when available.
  // ============================================================

  static const String _websiteUrl =
  String.fromEnvironment('E7M_WEBSITE_URL');

  static const String _termsUrl =
  String.fromEnvironment('E7M_TERMS_URL');

  static const String _storeUrl =
  String.fromEnvironment('E7M_STORE_RATING_URL');

  static const String _version =
  String.fromEnvironment('E7M_APP_VERSION');

  String _t(
      bool arabic,
      String arabicText,
      String englishText,
      ) {
    return arabic ? arabicText : englishText;
  }

  // ============================================================
  // INFORMATION DIALOG
  // ============================================================

  Future<void> _info(
      BuildContext context,
      String title,
      String body,
      bool arabic,
      ) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: Text(
                _t(arabic, 'إغلاق', 'Close'),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // OPEN EXTERNAL LINK
  // ============================================================

  Future<void> _openUrl(
      BuildContext context,
      String url,
      String title,
      bool arabic,
      ) async {
    final uri = Uri.tryParse(url.trim());

    final valid = uri != null &&
        {
          'https',
          'http',
          'mailto',
          'tel',
        }.contains(uri.scheme) &&
        ((uri.scheme != 'https' &&
            uri.scheme != 'http') ||
            uri.host.isNotEmpty);

    if (!valid) {
      await _info(
        context,
        title,
        _t(
          arabic,
          'الرابط الرسمي غير متوفر حاليًا.',
          'The official link is not available yet.',
        ),
        arabic,
      );
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened && context.mounted) {
        await _info(
          context,
          title,
          _t(
            arabic,
            'تعذر فتح الرابط على الجهاز.',
            'This device could not open the link.',
          ),
          arabic,
        );
      }
    } catch (_) {
      if (!context.mounted) return;

      await _info(
        context,
        title,
        _t(
          arabic,
          'تعذر فتح الرابط على الجهاز.',
          'This device could not open the link.',
        ),
        arabic,
      );
    }
  }

  // ============================================================
  // COPY CONTACT
  // ============================================================

  Future<void> _copy(
      BuildContext context,
      String value,
      bool arabic,
      ) async {
    await Clipboard.setData(
      ClipboardData(text: value),
    );

    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _t(arabic, 'تم النسخ', 'Copied'),
          ),
          backgroundColor: _green,
        ),
      );
  }

  // ============================================================
  // INFORMATION TILE
  // ============================================================

  Widget _tile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    VoidCallback? onCopy,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE9EAF0),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 6,
        ),
        leading: CircleAvatar(
          radius: 23,
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
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: onCopy == null
            ? const Icon(
          Icons.chevron_right_rounded,
        )
            : IconButton(
          tooltip: 'Copy',
          onPressed: onCopy,
          icon: const Icon(
            Icons.copy_outlined,
            size: 19,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _heading(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 12,
        top: 10,
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: _navy,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
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

    final mailUri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: {
        'subject': 'E7M Support',
      },
    );

    final phoneUri = Uri(
      scheme: 'tel',
      path: _supportPhone,
    );

    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        title: Text(
          language.translate('about_e7m'),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 760,
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              20,
              16,
              32,
            ),
            children: [
              // ================================================
              // APP HEADER
              // ================================================

              Container(
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
                  borderRadius:
                  BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                        BorderRadius.circular(22),
                      ),
                      child: const Icon(
                        Icons.sports_soccer_rounded,
                        color: _green,
                        size: 46,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'E7M',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _t(
                        arabic,
                        'احجز ملعبك وأدر نشاطك الرياضي بسهولة',
                        'Book football pitches and manage your sports business',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                    ),

                    if (_version.trim().isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Chip(
                        label: Text(
                          '${_t(arabic, 'الإصدار', 'Version')} $_version',
                        ),
                        backgroundColor:
                        const Color(0xFFEAF7D7),
                        side: BorderSide.none,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // ================================================
              // ABOUT APPLICATION
              // ================================================

              _heading(
                _t(arabic, 'عن E7M', 'About E7M'),
              ),

              Container(
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(16),
                ),
                child: Text(
                  _t(
                    arabic,
                    'E7M منصة رياضية بتساعد اللاعبين يلاقوا الملاعب ويحجزوها، '
                        'وبتساعد أصحاب الملاعب على إدارة المواعيد والحجوزات '
                        'والأسعار والصور والإيرادات من مكان واحد، '
                        'مع أدوات لإدارة الأكاديميات.',
                    'E7M helps players discover and book football pitches. '
                        'It also helps stadium owners manage availability, '
                        'bookings, prices, photos, revenue, and academies '
                        'in one place.',
                  ),
                  style: const TextStyle(
                    height: 1.7,
                  ),
                ),
              ),

              // ================================================
              // DEVELOPER
              // ================================================

              _heading(
                _t(arabic, 'المطور', 'Developer'),
              ),

              _tile(
                icon: Icons.groups_rounded,
                color: Colors.blue,
                title: _t(
                  arabic,
                  'فريق التطوير',
                  'Development team',
                ),
                subtitle: 'E7GZLY Development Team',
                onTap: () {
                  _info(
                    context,
                    _t(
                      arabic,
                      'فريق التطوير',
                      'Development team',
                    ),
                    'E7GZLY Development Team',
                    arabic,
                  );
                },
              ),

              // ================================================
              // SUPPORT CONTACTS
              // ================================================

              _heading(
                _t(
                  arabic,
                  'تواصل مع الدعم',
                  'Contact support',
                ),
              ),

              // EMAIL

              _tile(
                icon: Icons.mail_outline_rounded,
                color: Colors.blue,
                title: _t(
                  arabic,
                  'البريد الإلكتروني',
                  'Support email',
                ),
                subtitle: _supportEmail,
                onTap: () {
                  _openUrl(
                    context,
                    mailUri.toString(),
                    _t(
                      arabic,
                      'البريد الإلكتروني',
                      'Support email',
                    ),
                    arabic,
                  );
                },
                onCopy: () {
                  _copy(
                    context,
                    _supportEmail,
                    arabic,
                  );
                },
              ),

              // PHONE

              _tile(
                icon: Icons.phone_outlined,
                color: Colors.teal,
                title: _t(
                  arabic,
                  'اتصل بالدعم',
                  'Call support',
                ),
                subtitle: _supportPhone,
                onTap: () {
                  _openUrl(
                    context,
                    phoneUri.toString(),
                    _t(
                      arabic,
                      'اتصل بالدعم',
                      'Call support',
                    ),
                    arabic,
                  );
                },
                onCopy: () {
                  _copy(
                    context,
                    _supportPhone,
                    arabic,
                  );
                },
              ),

              // WHATSAPP

              _tile(
                icon: Icons.chat_outlined,
                color: Colors.green,
                title: _t(
                  arabic,
                  'واتساب الدعم',
                  'Support WhatsApp',
                ),
                subtitle: _supportPhone,
                onTap: () {
                  _openUrl(
                    context,
                    _whatsAppUrl,
                    _t(
                      arabic,
                      'واتساب الدعم',
                      'Support WhatsApp',
                    ),
                    arabic,
                  );
                },
              ),

              // OFFICIAL WEBSITE - ONLY IF CONFIGURED

              if (_websiteUrl.trim().isNotEmpty)
                _tile(
                  icon: Icons.language_outlined,
                  color: Colors.green,
                  title: _t(
                    arabic,
                    'الموقع الرسمي',
                    'Official website',
                  ),
                  subtitle: _websiteUrl,
                  onTap: () {
                    _openUrl(
                      context,
                      _websiteUrl,
                      _t(
                        arabic,
                        'الموقع الرسمي',
                        'Official website',
                      ),
                      arabic,
                    );
                  },
                ),

              // ================================================
              // LEGAL INFORMATION
              // ================================================

              _heading(
                _t(
                  arabic,
                  'معلومات قانونية',
                  'Legal information',
                ),
              ),

              // PRIVACY POLICY

              _tile(
                icon: Icons.privacy_tip_outlined,
                color: Colors.orange,
                title: language.translate(
                  'privacy_policy',
                ),
                subtitle: _t(
                  arabic,
                  'اقرأ سياسة الخصوصية',
                  'Read our privacy policy',
                ),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                      const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),

              // TERMS AND CONDITIONS

              _tile(
                icon: Icons.description_outlined,
                color: Colors.indigo,
                title: _t(
                  arabic,
                  'الشروط والأحكام',
                  'Terms & conditions',
                ),
                subtitle: _termsUrl.trim().isEmpty
                    ? _t(
                  arabic,
                  'غير منشورة حاليًا',
                  'Not published yet',
                )
                    : _t(
                  arabic,
                  'قراءة الشروط',
                  'Read the terms',
                ),
                onTap: () {
                  _openUrl(
                    context,
                    _termsUrl,
                    _t(
                      arabic,
                      'الشروط والأحكام',
                      'Terms & conditions',
                    ),
                    arabic,
                  );
                },
              ),

              // OPEN SOURCE LICENSES

              _tile(
                icon: Icons.code_rounded,
                color: Colors.deepPurple,
                title: _t(
                  arabic,
                  'تراخيص المكتبات',
                  'Open-source licenses',
                ),
                subtitle: _t(
                  arabic,
                  'مكتبات Flutter المستخدمة',
                  'Libraries used in the app',
                ),
                onTap: () {
                  showLicensePage(
                    context: context,
                    applicationName: 'E7M',
                  );
                },
              ),

              const SizedBox(height: 14),

              // ================================================
              // CHECK FOR UPDATES
              // ================================================

              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    _openUrl(
                      context,
                      _storeUrl,
                      _t(
                        arabic,
                        'التحقق من التحديثات',
                        'Check for updates',
                      ),
                      arabic,
                    );
                  },
                  icon: const Icon(
                    Icons.system_update_alt_rounded,
                  ),
                  label: Text(
                    _t(
                      arabic,
                      'التحقق من التحديثات',
                      'Check for updates',
                    ),
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // ================================================
              // FOOTER
              // ================================================

              Text(
                _t(
                  arabic,
                  'E7M — جميع الحقوق محفوظة',
                  'E7M — All rights reserved',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
