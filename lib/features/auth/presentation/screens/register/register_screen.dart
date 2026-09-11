import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/features/auth/presentation/controllers/auth_controller.dart';
import 'package:e7m/features/auth/presentation/screens/verification/verify_account_screen.dart';
import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/core/theme/app_colors.dart';

import 'owner_registration_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final cityController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    cityController.dispose();

    super.dispose();
  }

  // ============================================================
  // REGISTER PLAYER
  // ============================================================

  Future<void> _handleRegister(
      AuthController authController,
      ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final fullName = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final city = cityController.text.trim();

    // ==========================================================
    // PLAYER REGISTRATION
    // ==========================================================

    final success = await authController.register(
      name: fullName,
      email: email,
      phone: phone,
      city: city,

      // مهم جدًا:
      // المستخدم موجود حاليًا في Player Registration
      // لذلك نرسل Player للـBackend.
      role: 'player',

      verificationChannel: 'email',
    );

    if (!mounted) {
      return;
    }

    // ==========================================================
    // SUCCESS
    // ==========================================================

    if (success) {
      final registrationId =
          authController.registrationId;

      if (registrationId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'حدث خطأ: لم يتم إنشاء رقم التسجيل',
            ),
          ),
        );

        return;
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyAccountScreen(
            fullName: fullName,
            email: email,
            phone: phone,
            city: city,
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // ERROR
    // ==========================================================

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

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration buildInputDecoration(
      String hint,
      ) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.secondary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final t = context
        .watch<LanguageProvider>()
        .translate;

    final authController =
    context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,

      body: Stack(
        children: [
          // ======================================================
          // BACKGROUND
          // ======================================================

          Positioned.fill(
            child: Image.asset(
              'assets/images/e7m_logo.png',
              fit: BoxFit.cover,
            ),
          ),

          Positioned.fill(
            child: Container(
              color: Colors.white.withValues(
                alpha: 0.88,
              ),
            ),
          ),

          // ======================================================
          // CONTENT
          // ======================================================

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),

                        // ==================================================
                        // LOGO
                        // ==================================================

                        Image.asset(
                          'assets/images/e7m_logo.png',
                          width: 90,
                        ),

                        const SizedBox(height: 20),

                        // ==================================================
                        // TITLE
                        // ==================================================

                        Text(
                          t('create_account'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkNavy,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          t('join_e7gzly'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ==================================================
                        // PLAYER / OWNER
                        // ==================================================

                        Row(
                          children: [
                            // =================================================
                            // PLAYER
                            // =================================================

                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton
                                    .styleFrom(
                                  backgroundColor:
                                  AppColors.darkNavy,
                                  elevation: 0,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                ),

                                // Player is already selected
                                onPressed: () {},

                                child: Text(
                                  t('player'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // =================================================
                            // OWNER
                            // =================================================

                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton
                                    .styleFrom(
                                  backgroundColor:
                                  Colors.white,
                                  side: const BorderSide(
                                    color:
                                    AppColors.darkNavy,
                                  ),
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                      12,
                                    ),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const OwnerRegistrationScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  t('owner'),
                                  style: const TextStyle(
                                    color:
                                    AppColors.darkNavy,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 25),

                        // ==================================================
                        // FULL NAME
                        // ==================================================

                        TextFormField(
                          controller:
                          nameController,
                          textInputAction:
                          TextInputAction.next,
                          validator: (value) =>
                              authController
                                  .validateName(
                                value ?? '',
                              ),
                          decoration:
                          buildInputDecoration(
                            t('full_name'),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // ==================================================
                        // EMAIL
                        // ==================================================

                        TextFormField(
                          controller:
                          emailController,
                          keyboardType:
                          TextInputType.emailAddress,
                          textInputAction:
                          TextInputAction.next,
                          validator: (value) =>
                              authController
                                  .validateEmail(
                                value ?? '',
                              ),
                          decoration:
                          buildInputDecoration(
                            t('email_address'),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // ==================================================
                        // PHONE
                        // ==================================================

                        TextFormField(
                          controller:
                          phoneController,
                          keyboardType:
                          TextInputType.phone,
                          textInputAction:
                          TextInputAction.next,
                          validator: (value) =>
                              authController
                                  .validatePhone(
                                value ?? '',
                              ),
                          decoration:
                          buildInputDecoration(
                            t('phone_number'),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // ==================================================
                        // CITY
                        // ==================================================

                        TextFormField(
                          controller:
                          cityController,
                          textInputAction:
                          TextInputAction.done,
                          validator: (value) =>
                              authController
                                  .validateCity(
                                value ?? '',
                              ),
                          decoration:
                          buildInputDecoration(
                            t('city'),
                          ),
                        ),

                        const SizedBox(height: 25),

                        // ==================================================
                        // CONTINUE
                        // ==================================================

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton
                                .styleFrom(
                              backgroundColor:
                              AppColors.secondary,
                              disabledBackgroundColor:
                              Colors.grey.shade400,
                              elevation: 0,
                              shape:
                              RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(
                                  12,
                                ),
                              ),
                            ),
                            onPressed:
                            authController.isLoading
                                ? null
                                : () =>
                                _handleRegister(
                                  authController,
                                ),
                            child:
                            authController.isLoading
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color:
                                Colors.white,
                              ),
                            )
                                : Text(
                              t('continue'),
                              style:
                              const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.bold,
                                color:
                                Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // ==================================================
                        // ALREADY HAVE ACCOUNT
                        // ==================================================

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            t(
                              'already_have_account',
                            ),
                            style:
                            const TextStyle(
                              color:
                              AppColors.darkNavy,
                              fontWeight:
                              FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}