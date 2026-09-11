import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/features/player/home/home_screen.dart';

class PasswordUpdatedScreen extends StatelessWidget {
  const PasswordUpdatedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 🟢 استدعاء المترجم الديناميكي من الـ Provider
    final t = context.watch<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: const Color(0xffEEF5E5),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// ICON
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    // 🟢 تغيير اللون الأزرق القديم للون الأخضر المميز لهوية e7gzly
                    color: const Color(0xff7CC000),
                    width: 5,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.check,
                    // 🟢 تغيير لون الأيقونة الداخلي ليتوافق مع الهوية الجديدة
                    color: Color(0xff7CC000),
                    size: 70,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// TITLE
              Text(
                // 🟢 استبدال النص الثابت بالترجمة
                t('password_updated'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1E1446),
                ),
              ),

              const SizedBox(height: 20),

              /// DESCRIPTION
              Text(
                // 🟢 استبدال نص الوصف الثابت بالترجمة الديناميكية
                t('password_updated_desc'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.5,
                  color: Color(0xff8FA18D),
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 50),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7CC000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                      (route) => false,
                    );
                  },
                  child: Text(
                    // 🟢 استبدال نص الزر بالترجمة الديناميكية
                    t('continue'),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
