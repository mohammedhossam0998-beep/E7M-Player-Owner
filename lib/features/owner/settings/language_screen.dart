import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String selectedLanguage;

  @override
  void initState() {
    super.initState();
    selectedLanguage = context.read<LanguageProvider>().locale.languageCode;
  }

  Future<void> saveLanguage(String value) async {
    final languageProvider = context.read<LanguageProvider>();
    await languageProvider.changeLanguage(value);

    setState(() {
      selectedLanguage = value;
    });

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(languageProvider.translate('language_updated')),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          languageProvider.translate("language"),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          Text(
            languageProvider.translate('choose_app_language'),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            languageProvider.translate('language_description'),
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),
          const SizedBox(height: 30),

          // English Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                radius: 24,
                child: Text("🇬🇧", style: TextStyle(fontSize: 24)),
              ),
              title: Text(
                languageProvider.translate('english'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              subtitle: Text(languageProvider.translate('english_us')),
              trailing: Radio<String>(
                value: "en",
                groupValue: selectedLanguage,
                activeColor: const Color(0xff7CC000),
                onChanged: (value) {
                  if (value != null) saveLanguage(value);
                },
              ),
              onTap: () => saveLanguage("en"),
            ),
          ),
          const SizedBox(height: 16),

          // Arabic Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const CircleAvatar(
                radius: 24,
                child: Text("🇪🇬", style: TextStyle(fontSize: 24)),
              ),
              title: Text(
                languageProvider.translate('arabic'),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              subtitle: Text(languageProvider.translate('arabic_language')),
              trailing: Radio<String>(
                value: "ar",
                groupValue: selectedLanguage,
                activeColor: const Color(0xff7CC000),
                onChanged: (value) {
                  if (value != null) saveLanguage(value);
                },
              ),
              onTap: () => saveLanguage("ar"),
            ),
          ),
          const SizedBox(height: 30),

          // Info Box
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline, color: Color(0xff7CC000)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    languageProvider.translate('language_change_info'),
                    style: const TextStyle(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 35),

          // Apply Button
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, selectedLanguage);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7CC000),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.language, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    languageProvider.translate('apply_language'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            height: 55,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xff7CC000)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                languageProvider.translate('cancel'),
                style: const TextStyle(
                  color: Color(0xff7CC000),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}