
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/features/owner/support/screens/owner_support_tickets_screen.dart';
import 'package:e7m/features/owner/support/screens/create_owner_support_ticket_screen.dart';

// ============================================================
// HELP & SUPPORT SCREEN
// ============================================================

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  // ============================================================
  // COLORS
  // ============================================================

  static const Color _green = Color(0xFF7CC000);
  static const Color _navy = Color(0xFF1E1446);
  static const Color _background = Color(0xFFF7F8FA);

  // ============================================================
  // SUPPORT CONTACTS
  // ============================================================

  static const String supportEmail =
      'e7gzlyml3b@gmail.com';

  static const String supportPhone =
      '01029149458';

  static const String supportWhatsApp =
      'https://wa.me/201029149458';

  // ============================================================
  // OPTIONAL OFFICIAL LINKS
  // ============================================================

  static const String _ratingUrl =
  String.fromEnvironment(
    'E7M_STORE_RATING_URL',
  );

  static const String _termsUrl =
  String.fromEnvironment(
    'E7M_TERMS_URL',
  );

  // ============================================================
  // LOCALIZED TEXT
  // ============================================================

  String _local(
      bool arabic,
      String arabicText,
      String englishText,
      ) {
    return arabic ? arabicText : englishText;
  }

  // ============================================================
  // SUPPORT TICKETS
  // ============================================================

  void _openTickets(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
        const OwnerSupportTicketsScreen(),
      ),
    );
  }

  // ============================================================
  // CREATE SUPPORT TICKET
  // ============================================================

  void _createTicket(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
        const CreateOwnerSupportTicketScreen(),
      ),
    );
  }

  // ============================================================
  // SHOW NOTICE
  // ============================================================

  Future<void> _showNotice(
      BuildContext context, {
        required String title,
        required String message,
        required bool arabic,
        bool offerTickets = false,
      }) async {
    final openTickets = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                _local(
                  arabic,
                  'إغلاق',
                  'Close',
                ),
              ),
            ),
            if (offerTickets)
              FilledButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    true,
                  );
                },
                child: Text(
                  _local(
                    arabic,
                    'تذاكر الدعم',
                    'Support tickets',
                  ),
                ),
              ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    if (openTickets == true) {
      _openTickets(context);
    }
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

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            _local(
              arabic,
              'تم نسخ بيانات التواصل',
              'Contact copied',
            ),
          ),
          backgroundColor: _green,
        ),
      );
  }

  // ============================================================
  // LAUNCH CONTACT
  // If device does not support email/phone,
  // offer copying the contact instead.
  // ============================================================

  Future<void> _launchContact(
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
        'SUPPORT CONTACT ERROR: $error',
      );
    }

    if (!context.mounted || opened) {
      return;
    }

    final shouldCopy = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            _local(
              arabic,
              'تعذر فتح التطبيق',
              'Unable to open application',
            ),
          ),
          content: Text(
            _local(
              arabic,
              'الجهاز مش قادر يفتح وسيلة التواصل دي. '
                  'تحب تنسخ بيانات التواصل؟',
              'Your device could not open this contact method. '
                  'Would you like to copy the contact?',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: Text(
                _local(
                  arabic,
                  'إلغاء',
                  'Cancel',
                ),
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: Text(
                _local(
                  arabic,
                  'نسخ',
                  'Copy',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!context.mounted) return;

    if (shouldCopy == true) {
      await _copyContact(
        context,
        fallbackValue,
        arabic,
      );
    }
  }

  // ============================================================
  // EMAIL SUPPORT
  // ============================================================

  Future<void> _openEmail(
      BuildContext context,
      bool arabic,
      ) async {
    final uri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {
        'subject': 'E7M Owner Support',
      },
    );

    await _launchContact(
      context,
      uri: uri,
      fallbackValue: supportEmail,
      arabic: arabic,
    );
  }

  // ============================================================
  // PHONE SUPPORT
  // ============================================================

  Future<void> _callSupport(
      BuildContext context,
      bool arabic,
      ) async {
    final uri = Uri(
      scheme: 'tel',
      path: supportPhone,
    );

    await _launchContact(
      context,
      uri: uri,
      fallbackValue: supportPhone,
      arabic: arabic,
    );
  }

  // ============================================================
  // WHATSAPP SUPPORT
  // ============================================================

  Future<void> _openWhatsApp(
      BuildContext context,
      bool arabic,
      ) async {
    final uri = Uri.parse(
      supportWhatsApp,
    );

    await _launchContact(
      context,
      uri: uri,
      fallbackValue: supportPhone,
      arabic: arabic,
    );
  }

  // ============================================================
  // OPEN OPTIONAL OFFICIAL LINK
  // ============================================================

  Future<void> _openOfficialLink(
      BuildContext context, {
        required String url,
        required String title,
        required bool arabic,
        required String missingArabic,
        required String missingEnglish,
      }) async {
    final value = url.trim();
    final uri = Uri.tryParse(value);

    final valid =
        uri != null &&
            (uri.scheme == 'https' ||
                uri.scheme == 'http') &&
            uri.host.isNotEmpty;

    if (!valid) {
      await _showNotice(
        context,
        title: title,
        message: _local(
          arabic,
          missingArabic,
          missingEnglish,
        ),
        arabic: arabic,
      );
      return;
    }

    bool opened = false;

    try {
      opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } catch (error) {
      debugPrint(
        'SUPPORT LINK ERROR: $error',
      );
    }

    if (!context.mounted || opened) {
      return;
    }

    await _showNotice(
      context,
      title: title,
      message: _local(
        arabic,
        'تعذر فتح الرابط. حاول مرة أخرى.',
        'Could not open the link. Please try again.',
      ),
      arabic: arabic,
    );
  }

  // ============================================================
  // SUPPORT CARD
  // ============================================================

  Widget _supportTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Color(0xFFE8EAF0),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding:
        const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 24,
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
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(
            top: 4,
          ),
          child: Text(
            subtitle,
            style: const TextStyle(
              fontSize: 12.5,
            ),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 15,
          color: Color(0xFF999BA4),
        ),
      ),
    );
  }

  // ============================================================
  // CONTACT INFO
  // ============================================================

  Widget _contactInfo(bool arabic) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _green.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: _green,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _local(
                arabic,
                'تقدر تتواصل مع دعم E7M عبر الإيميل '
                    'أو التليفون أو واتساب، وكمان تقدر '
                    'تفتح تذكرة دعم وتتابع الرد عليها.',
                'Contact E7M support by email, '
                    'phone, or WhatsApp. You can also '
                    'create a support ticket and '
                    'track the replies.',
              ),
              style: const TextStyle(
                height: 1.6,
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
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: _navy,
        elevation: 0,
        title: Text(
          language.translate('help_support'),
          style: const TextStyle(
            color: _navy,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // ====================================================
          // HEADER
          // ====================================================

          const SizedBox(height: 12),

          const Icon(
            Icons.support_agent_rounded,
            size: 70,
            color: _green,
          ),

          const SizedBox(height: 16),

          Text(
            language.translate(
              'how_can_we_help',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _navy,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 9),

          Text(
            language.translate(
              'help_support_description',
            ),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 26),

          // ====================================================
          // CONTACT SECTION
          // ====================================================

          Text(
            _local(
              arabic,
              'تواصل معنا',
              'Contact Us',
            ),
            style: const TextStyle(
              color: _navy,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          // ====================================================
          // SUPPORT EMAIL
          // ====================================================

          _supportTile(
            icon: Icons.email_outlined,
            color: Colors.blue,
            title: _local(
              arabic,
              'البريد الإلكتروني',
              'Support Email',
            ),
            subtitle: supportEmail,
            onTap: () {
              _openEmail(context, arabic);
            },
          ),

          // ====================================================
          // SUPPORT PHONE
          // ====================================================

          _supportTile(
            icon: Icons.phone_outlined,
            color: Colors.teal,
            title: _local(
              arabic,
              'اتصل بالدعم',
              'Call Support',
            ),
            subtitle: supportPhone,
            onTap: () {
              _callSupport(context, arabic);
            },
          ),

          // ====================================================
          // WHATSAPP
          // ====================================================

          _supportTile(
            icon: Icons.chat_outlined,
            color: Colors.green,
            title: language.translate(
              'whatsapp_support',
            ),
            subtitle: _local(
              arabic,
              'تواصل معنا على واتساب: $supportPhone',
              'Chat on WhatsApp: $supportPhone',
            ),
            onTap: () {
              _openWhatsApp(context, arabic);
            },
          ),

          const SizedBox(height: 16),

          // ====================================================
          // HELP AND SUPPORT SECTION
          // ====================================================

          Text(
            _local(
              arabic,
              'المساعدة والدعم',
              'Help and Support',
            ),
            style: const TextStyle(
              color: _navy,
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 12),

          // ====================================================
          // FAQ
          // ====================================================

          _supportTile(
            icon: Icons.question_answer_outlined,
            color: Colors.blue,
            title: language.translate(
              'frequently_asked_questions',
            ),
            subtitle: language.translate(
              'find_answers_common_questions',
            ),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) =>
                  const _OwnerFaqScreen(),
                ),
              );
            },
          ),

          // ====================================================
          // SUPPORT TICKETS
          // ====================================================

          _supportTile(
            icon: Icons.support_agent_outlined,
            color: Colors.deepPurple,
            title: language.translate(
              'contact_support',
            ),
            subtitle: _local(
              arabic,
              'متابعة طلبات الدعم والردود',
              'View support tickets and replies',
            ),
            onTap: () {
              _openTickets(context);
            },
          ),

          // ====================================================
          // REPORT A PROBLEM
          // ====================================================

          _supportTile(
            icon: Icons.bug_report_outlined,
            color: Colors.orange,
            title: language.translate(
              'report_problem',
            ),
            subtitle: language.translate(
              'report_bugs_issues',
            ),
            onTap: () {
              _createTicket(context);
            },
          ),

          // ====================================================
          // RATE E7M
          // ====================================================

          _supportTile(
            icon: Icons.star_rate_rounded,
            color: Colors.amber.shade800,
            title: language.translate(
              'rate_e7m',
            ),
            subtitle: language.translate(
              'share_google_play',
            ),
            onTap: () {
              _openOfficialLink(
                context,
                url: _ratingUrl,
                title: language.translate(
                  'rate_e7m',
                ),
                arabic: arabic,
                missingArabic:
                'رابط تقييم تطبيق E7M غير متوفر حاليًا.',
                missingEnglish:
                'The E7M app rating link is not available yet.',
              );
            },
          ),

          // ====================================================
          // TERMS OF SERVICE
          // ====================================================

          _supportTile(
            icon: Icons.description_outlined,
            color: Colors.indigo,
            title: language.translate(
              'terms_of_service',
            ),
            subtitle: language.translate(
              'read_terms_conditions',
            ),
            onTap: () {
              _openOfficialLink(
                context,
                url: _termsUrl,
                title: language.translate(
                  'terms_of_service',
                ),
                arabic: arabic,
                missingArabic:
                'شروط الاستخدام الرسمية لم يتم ربطها بالتطبيق بعد.',
                missingEnglish:
                'The official terms of service have not been linked yet.',
              );
            },
          ),

          const SizedBox(height: 16),

          // ====================================================
          // CONTACT INFORMATION
          // ====================================================

          _contactInfo(arabic),

          const SizedBox(height: 24),

          // ====================================================
          // CONTACT SUPPORT BUTTON
          // ====================================================

          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                _openTickets(context);
              },
              icon: const Icon(
                Icons.support_agent,
              ),
              label: Text(
                language.translate(
                  'contact_support',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),
        ],
      ),
    );
  }
}

// ============================================================
// FAQ MODEL
// ============================================================

class _FaqEntry {
  final String questionAr;
  final String answerAr;
  final String questionEn;
  final String answerEn;

  const _FaqEntry({
    required this.questionAr,
    required this.answerAr,
    required this.questionEn,
    required this.answerEn,
  });
}

// ============================================================
// OWNER FAQ SCREEN
// ============================================================

class _OwnerFaqScreen extends StatelessWidget {
  const _OwnerFaqScreen();

  static const List<_FaqEntry> _entries = [
    _FaqEntry(
      questionAr: 'إزاي أضيف ملعب جديد؟',
      answerAr:
      'افتح قسم الملاعب من حساب الأونر، واضغط إضافة ملعب. '
          'اكتب البيانات والسعر والعربون والموقع، وبعد الحفظ '
          'تقدر تضيف صور الملعب.',
      questionEn: 'How do I add a new stadium?',
      answerEn:
      'Open Stadiums from your Owner account, '
          'select Add Stadium, enter the details, price, '
          'deposit, and location, then add images after saving.',
    ),

    _FaqEntry(
      questionAr: 'إزاي أحدد موقع الملعب؟',
      answerAr:
      'افتح إضافة أو تعديل الملعب، واضغط اختيار الموقع '
          'من الخريطة. اضغط على الموقع الصحيح، ثم أكد '
          'المكان واحفظ بيانات الملعب.',
      questionEn:
      'How do I select my stadium location?',
      answerEn:
      'Open Add or Edit Stadium, choose the map '
          'option, tap the correct location, confirm it, '
          'and save your stadium.',
    ),

    _FaqEntry(
      questionAr: 'إزاي أرفع صور الملعب؟',
      answerAr:
      'افتح إدارة صور الملعب، واختار الصور من جهازك، '
          'وراجع المعاينة قبل الرفع. تقدر كمان تغير الصورة '
          'الرئيسية أو تحذف أي صورة.',
      questionEn:
      'How do I upload stadium images?',
      answerEn:
      'Open Stadium Images, select photos, preview '
          'them, and upload. You can also set a primary '
          'image or delete an existing one.',
    ),

    _FaqEntry(
      questionAr: 'فين أراجع طلبات الحجز؟',
      answerAr:
      'افتح حجوزات الأونر أو اضغط على إشعار حجز جديد. '
          'تقدر تراجع الحجز وتوافق أو ترفض الطلبات المعلقة.',
      questionEn:
      'Where can I review booking requests?',
      answerEn:
      'Open Owner Bookings or tap a new booking '
          'notification. You can approve or reject '
          'pending requests.',
    ),

    _FaqEntry(
      questionAr: 'إزاي أبلغ عن مشكلة؟',
      answerAr:
      'افتح المساعدة والدعم، واضغط الإبلاغ عن مشكلة. '
          'اكتب تفاصيل المشكلة وأرسل التذكرة، وبعدها '
          'تابع الرد من صفحة تذاكر الدعم.',
      questionEn:
      'How do I report a problem?',
      answerEn:
      'Open Help & Support, choose Report a Problem, '
          'describe the issue, and submit a ticket. '
          'You can follow replies in Support Tickets.',
    ),

    _FaqEntry(
      questionAr: 'إزاي أتواصل مع الدعم؟',
      answerAr:
      'تقدر تتواصل عن طريق البريد الإلكتروني '
          'e7gzlyml3b@gmail.com أو الرقم 01029149458، '
          'أو واتساب على نفس الرقم. وتقدر كمان تفتح تذكرة دعم.',
      questionEn:
      'How can I contact support?',
      answerEn:
      'You can email e7gzlyml3b@gmail.com, '
          'call 01029149458, or chat on WhatsApp '
          'using the same number. You can also '
          'create a support ticket.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final language =
    context.watch<LanguageProvider>();

    final arabic =
        language.locale.languageCode == 'ar';

    return Scaffold(
      backgroundColor:
      const Color(0xFFF7F8FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor:
        const Color(0xFF1E1446),
        centerTitle: true,
        title: Text(
          arabic
              ? 'الأسئلة الشائعة'
              : 'Frequently Asked Questions',
        ),
      ),

      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _entries.length,

        separatorBuilder: (_, __) =>
        const SizedBox(height: 10),

        itemBuilder: (context, index) {
          final entry = _entries[index];

          return Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(16),
            ),

            child: ExpansionTile(
              title: Text(
                arabic
                    ? entry.questionAr
                    : entry.questionEn,

                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),

              childrenPadding:
              const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                18,
              ),

              children: [
                Align(
                  alignment:
                  AlignmentDirectional.centerStart,

                  child: Text(
                    arabic
                        ? entry.answerAr
                        : entry.answerEn,

                    style: const TextStyle(
                      height: 1.6,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
