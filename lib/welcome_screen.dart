import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/features/auth/presentation/screens/login/login_screen.dart';
import 'package:e7m/features/auth/presentation/screens/register/register_type_screen.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: true,
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 430,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    // ==================================================
                    // HERO IMAGE
                    // ==================================================

                    SafeArea(
                      top: true,
                      bottom: false,
                      child: SizedBox(
                        height: size.height * .46,
                        width: double.infinity,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(24),
                            bottomRight: Radius.circular(24),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.asset(
                                'assets/images/stadium.jpg',
                                fit: BoxFit.cover,
                                alignment: const Alignment(
                                  0,
                                  -0.35,
                                ),
                                errorBuilder:
                                    (
                                    context,
                                    error,
                                    stackTrace,
                                    ) {
                                  return Container(
                                    color: const Color(
                                      0xffEEF5E5,
                                    ),
                                    child: const Icon(
                                      Icons.stadium,
                                      size: 100,
                                      color: Color(
                                        0xff7CC000,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // ==================================================
                              // IMAGE GRADIENT
                              // ==================================================

                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 60,
                                  decoration:
                                  const BoxDecoration(
                                    gradient:
                                    LinearGradient(
                                      begin:
                                      Alignment.topCenter,
                                      end:
                                      Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.white,
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    // ==================================================
                    // APP NAME
                    // ==================================================

                    const Text(
                      'E7gzly Ml3b',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: Color(0xff145A32),
                        letterSpacing: .3,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // ==================================================
                    // TAGLINE
                    // ==================================================

                    const Text(
                      'BEYOND THE GAME',
                      style: TextStyle(
                        color: Color(0xff7CC000),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ==================================================
                    // BUTTONS
                    // ==================================================

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                      ),
                      child: Column(
                        children: [
                          // ==================================================
                          // GOOGLE SIGN IN
                          // ==================================================

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton.icon(
                              icon: const Image(
                                image: AssetImage(
                                  'assets/images/google.png',
                                ),
                                width: 22,
                              ),
                              label: Text(
                                t('continue_google'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                  FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              style:
                              OutlinedButton.styleFrom(
                                backgroundColor:
                                Colors.white,
                                side: BorderSide(
                                  color:
                                  Colors.grey.shade300,
                                ),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    16,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                // Google Sign-In
                                // سيتم ربطه بالـ Backend
                                // بعد تجهيز Firebase / Google Auth.
                              },
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ==================================================
                          // SIGN IN
                          // ==================================================

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              style:
                              ElevatedButton.styleFrom(
                                backgroundColor:
                                const Color(
                                  0xff7CC000,
                                ),
                                elevation: 0,
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    16,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const LoginScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                t('sign_in'),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                  FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // ==================================================
                          // CREATE ACCOUNT
                          // ==================================================

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: OutlinedButton(
                              style:
                              OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color:
                                  Color(0xff7CC000),
                                  width: 2,
                                ),
                                shape:
                                RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(
                                    16,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                    const RegisterTypeScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                t('create_account'),
                                style: const TextStyle(
                                  color:
                                  Color(0xff7CC000),
                                  fontSize: 17,
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}