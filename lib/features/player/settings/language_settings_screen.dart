import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class LanguageSettingsScreen extends StatelessWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        centerTitle: true,
        // ✅ دعم السهم الـ RTL بشكل كامل وديناميكي عند تغيير الاتجاهات
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
            color: const Color(0xff1E1446),
          ),
        ),
        title: Text(
          provider.translate('language'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ إضافة وصف أعلى الشاشة ممتد حسب اتجاه اللغة
            Text(
              provider.translate('choose_language'),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 🟢 اللغة الإنجليزية
                  RadioListTile<String>(
                    value: 'en',
                    groupValue: provider
                        .locale
                        .languageCode, // ✅ تعديل إلي locale ليتوافق مع الـ Provider
                    activeColor: const Color(0xff7CC000),
                    // ✅ إضافة أيقونة توضيحية جانبية
                    secondary: const Icon(
                      Icons.language,
                      color: Color(0xff1E1446),
                    ),
                    title: Text(
                      provider.translate('english'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xff1E1446),
                      ),
                    ),
                    // ✅ تمرير النص 'en' مباشرة بدلاً من كائن Locale ليتوافق مع دالتك
                    onChanged: (_) {
                      context.read<LanguageProvider>().changeLanguage('en');

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.read<LanguageProvider>().translate(
                              'language_changed',
                            ),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),

                  // 🟢 اللغة العربية
                  RadioListTile<String>(
                    value: 'ar',
                    groupValue: provider
                        .locale
                        .languageCode, // ✅ تعديل إلي locale ليتوافق مع الـ Provider
                    activeColor: const Color(0xff7CC000),
                    // ✅ إضافة أيقونة توضيحية جانبية للترجمة
                    secondary: const Icon(
                      Icons.translate,
                      color: Color(0xff1E1446),
                    ),
                    title: Text(
                      provider.translate('arabic'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xff1E1446),
                      ),
                    ),
                    // ✅ تمرير النص 'ar' مباشرة بدلاً من كائن Locale ليتوافق مع دالتك
                    onChanged: (_) {
                      context.read<LanguageProvider>().changeLanguage('ar');

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            context.read<LanguageProvider>().translate(
                              'language_changed',
                            ),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
