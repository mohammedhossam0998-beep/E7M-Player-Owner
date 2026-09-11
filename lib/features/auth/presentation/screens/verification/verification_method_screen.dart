import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/features/auth/presentation/controllers/auth_controller.dart';
import 'verify_account_screen.dart';

class VerificationMethodScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String city;

  const VerificationMethodScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
  });

  @override
  State<VerificationMethodScreen> createState() =>
      _VerificationMethodScreenState();
}

class _VerificationMethodScreenState
    extends State<VerificationMethodScreen> {
  String selectedMethod = 'email';

  // ============================================================
  // CONTINUE
  // ============================================================
  //
  // هنا كان الخطأ: الشاشة كانت بتعمل Navigator.push
  // على VerifyAccountScreen مباشرة من غير ما تنادي
  // authController.register() أبدًا.
  //
  // ده كان السبب في: "Pending registration not found"
  // لأن مفيش صف اتعمل في pending_registrations أصلًا.
  //
  // ✨ إصلاح إضافي (النهاردة):
  // الشاشة دي جزء من مسار الـ Player فقط (جاية من SignUpScreen)
  // فلازم تبعت role: 'player' صراحة لـ register()، لأن role
  // بقت required parameter في AuthController.register().
  // ----------------------------------------------------------

  Future<void> _handleContinue(
      AuthController authController,
      ) async {
    if (selectedMethod != 'email') {
      final t = context.read<LanguageProvider>().translate;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('phone_verification_unavailable'),
          ),
        ),
      );

      return;
    }

    // --------------------------------------------------------
    // CALL REGISTER (creates pending_registration + sends OTP)
    // --------------------------------------------------------

    final success = await authController.register(
      name: widget.fullName,
      email: widget.email,
      phone: widget.phone,
      city: widget.city,

      // ✨ مضافة: هذا التسجيل خاص بـ Player
      role: 'player',

      verificationChannel: 'email',
    );

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyAccountScreen(
            fullName: widget.fullName,
            email: widget.email,
            phone: widget.phone,
            city: widget.city,
          ),
        ),
      );

      return;
    }

    if (authController.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authController.errorMessage!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    final authController = context.watch<AuthController>();

    final isRtl =
        Directionality.of(context) == TextDirection.rtl;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),

      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },

          icon: Icon(
            isRtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
            size: 20,
            color: const Color(0xff1E1446),
          ),
        ),

        title: Text(
          t('verification'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Column(
            children: [
              const SizedBox(height: 20),

              Container(
                width: 110,
                height: 110,

                decoration: const BoxDecoration(
                  color: Color(0xffEEF5E5),
                  shape: BoxShape.circle,
                ),

                child: const Icon(
                  Icons.verified_user_rounded,
                  size: 55,
                  color: Color(0xff7CC000),
                ),
              ),

              const SizedBox(height: 30),

              Text(
                t('choose_verification_method'),
                textAlign: TextAlign.center,

                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xff1E1446),
                ),
              ),

              const SizedBox(height: 10),

              Text(
                t('select_verification_method'),
                textAlign: TextAlign.center,

                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              _buildMethodCard(
                title: t('email_verification'),
                subtitle: widget.email,
                icon: Icons.email_outlined,
                value: 'email',
              ),

              const SizedBox(height: 15),

              _buildMethodCard(
                title: t('phone_verification'),
                subtitle: widget.phone,
                icon: Icons.phone_android,
                value: 'phone',
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton(
                  onPressed: authController.isLoading
                      ? null
                      : () => _handleContinue(authController),

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xff7CC000),

                    disabledBackgroundColor:
                    const Color(0xffB8D98A),

                    elevation: 0,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),

                  child: authController.isLoading
                      ? const SizedBox(
                    width: 25,
                    height: 25,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Text(
                    t('continue'),

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
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

  Widget _buildMethodCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected =
        selectedMethod == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = value;
        });
      },

      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 250),

        padding:
        const EdgeInsets.all(18),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(18),

          border: Border.all(
            color: isSelected
                ? const Color(0xff7CC000)
                : Colors.grey.shade300,

            width: isSelected ? 2 : 1,
          ),

          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? const Color(0xff7CC000)
                  .withOpacity(0.12)
                  : Colors.black
                  .withOpacity(0.04),

              blurRadius: 8,

              offset:
              const Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              width: 55,
              height: 55,

              decoration:
              BoxDecoration(
                color:
                const Color(0xffEEF5E5),

                borderRadius:
                BorderRadius.circular(14),
              ),

              child: Icon(
                icon,
                color:
                const Color(0xff7CC000),
                size: 27,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    title,

                    style:
                    const TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                      color:
                      Color(0xff1E1446),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    subtitle,

                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,

                    style:
                    const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,

              color: isSelected
                  ? const Color(0xff7CC000)
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }
}