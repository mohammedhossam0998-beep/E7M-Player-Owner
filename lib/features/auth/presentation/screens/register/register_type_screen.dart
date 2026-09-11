import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/features/auth/presentation/screens/register/signup.dart';
import 'package:e7m/features/auth/presentation/screens/register/owner_registration_screen.dart';

// ✨ إضافة استيراد شاشة تسجيل المالك
class RegisterTypeScreen extends StatefulWidget {
  const RegisterTypeScreen({super.key});

  @override
  State<RegisterTypeScreen> createState() => _RegisterTypeScreenState();
}

class _RegisterTypeScreenState extends State<RegisterTypeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    final List<Map<String, dynamic>> items = [
      {
        "title": t('player'),
        "subtitle": t('player_subtitle'),
        "image": "assets/images/player.png",
      },
      {
        "title": t('stadium_owner'),
        "subtitle": t('stadium_owner_subtitle'),
        "image": "assets/images/stadium_owner.png",
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            children: [
              /// TOP BAR
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Directionality.of(context) == TextDirection.rtl
                          ? Icons.arrow_forward_ios
                          : Icons.arrow_back_ios,
                      size: 20,
                      color: const Color(0xff1E1446),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    t('register'),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E1446),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                t('choose_account_type'),
                style: const TextStyle(fontSize: 18, color: Color(0xff9AAC95)),
              ),
              const SizedBox(height: 30),

              /// CARDS
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    bool isSelected = selectedIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xff7CC000)
                                : Colors.grey.shade300,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isSelected
                                  ? const Color(0xff7CC000).withOpacity(0.2)
                                  : Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Image.asset(
                              items[index]["image"],
                              height: 120,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image,
                                size: 120,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              items[index]["title"],
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff1E1446),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              items[index]["subtitle"],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xffB5C0B2),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              /// BUTTON
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7CC000),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    // ✨ تحديث المنطق للتوجيه للشاشة الصحيحة
                    if (selectedIndex == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SignUpScreen()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const OwnerRegistrationScreen(),
                        ),
                      );
                    }
                  },
                  child: Text(
                    t('continue'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
