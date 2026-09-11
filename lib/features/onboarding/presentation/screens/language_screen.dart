import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✨ تم إضافة حزمة حفظ البيانات المحلية
import 'package:e7m/shared/localization/language_provider.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(),

              /// 🖼️ اللوجو الخاص بالتطبيق
              Image.asset('assets/images/logo.png', width: 120, height: 120),

              const SizedBox(height: 30),

              const Text(
                'Choose Your Language',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1E1446),
                ),
              ),

              const SizedBox(height: 10),

              /// النص الوصفي
              const Text(
                'Book football fields easily',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),

              const SizedBox(height: 40),

              /// كروت اللغات
              buildLanguageCard(title: 'English', value: 'en'),

              const SizedBox(height: 15),

              buildLanguageCard(title: 'العربية', value: 'ar'),

              const Spacer(),

              /// 🎯 زر Continue المعدل لحفظ لغة المستخدم وحالة الدخول الأول للتطبيق
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    // 🔄 تهيئة الـ SharedPreferences وحفظ خيارات المستخدمlocal
                    final prefs = await SharedPreferences.getInstance();

                    await prefs.setBool('first_launch_done', true);

                    await prefs.setString(
                      'selected_language',
                      selectedLanguage,
                    );

                    context.read<LanguageProvider>().changeLanguage(
                      selectedLanguage,
                    );

                    // التأكد من أن الـ Widget ما زالت موجودة في الشجرة قبل عمل Navigation
                    if (!mounted) return;

                    Navigator.pushReplacementNamed(context, "/welcome");
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildLanguageCard({required String title, required String value}) {
    final isSelected = selectedLanguage == value;

    return InkWell(
      onTap: () {
        setState(() {
          selectedLanguage = value;
        });
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2E7D32).withOpacity(0.02)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? const Color(0xFF2E7D32)
                      : const Color(0xff1E1446),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF2E7D32),
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
