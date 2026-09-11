import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/features/owner/support/screens/owner_support_tickets_screen.dart';
import 'package:e7m/features/owner/support/screens/create_owner_support_ticket_screen.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

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
          languageProvider.translate('help_support'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.support_agent, size: 70, color: Color(0xff7CC000)),
          const SizedBox(height: 20),
          Center(
            child: Text(
              languageProvider.translate('how_can_we_help'),
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Color(0xff1E1446),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              languageProvider.translate('help_support_description'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, height: 1.5),
            ),
          ),
          const SizedBox(height: 35),
          supportTile(
            icon: Icons.question_answer_outlined,
            color: Colors.blue,
            title: languageProvider.translate('frequently_asked_questions'),
            subtitle: languageProvider.translate(
              'find_answers_common_questions',
            ),
            onTap: () {},
          ),
          supportTile(
            icon: Icons.email_outlined,
            color: Colors.red,
            title: languageProvider.translate('contact_support'),
            subtitle: languageProvider.translate('send_email_support_team'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const OwnerSupportTicketsScreen(),
                ),
              );
            },
          ),
          supportTile(
            icon: Icons.chat,
            color: Colors.green,
            title: languageProvider.translate('whatsapp_support'),
            subtitle: languageProvider.translate('chat_whatsapp'),
            onTap: () {},
          ),
          supportTile(
            icon: Icons.bug_report_outlined,
            color: Colors.orange,
            title: languageProvider.translate('report_problem'),
            subtitle: languageProvider.translate('report_bugs_issues'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateOwnerSupportTicketScreen(),
                ),
              );
            },
          ),
          supportTile(
            icon: Icons.star_rate_rounded,
            color: Colors.amber,
            title: languageProvider.translate('rate_e7m'),
            subtitle: languageProvider.translate('share_google_play'),
            onTap: () {},
          ),
          supportTile(
            icon: Icons.description_outlined,
            color: Colors.indigo,
            title: languageProvider.translate('terms_of_service'),
            subtitle: languageProvider.translate('read_terms_conditions'),
            onTap: () {},
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Color(0xff7CC000)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    languageProvider.translate('support_team_available'),
                    style: const TextStyle(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OwnerSupportTicketsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.support_agent, color: Colors.white),
              label: Text(
                languageProvider.translate('contact_support'),
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
    );
  }

  Widget supportTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: color.withValues(alpha: 0.15),
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