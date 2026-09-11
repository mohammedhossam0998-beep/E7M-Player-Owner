import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import '../../data/settings_repository.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  // ============================================================
  // PASSWORD VISIBILITY
  // ============================================================

  bool currentObscure = true;
  bool newObscure = true;
  bool confirmObscure = true;

  // ============================================================
  // LOADING
  // ============================================================

  bool isLoading = false;

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController currentPasswordController =
  TextEditingController();

  final TextEditingController newPasswordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  // ============================================================
  // REPOSITORY
  // ============================================================

  late final SettingsRepository _repository;

  // ============================================================
  // PASSWORD STRENGTH
  // ============================================================

  double passwordStrength = 0;

  String strengthText = "weak";

  @override
  void initState() {
    super.initState();

    _repository = SettingsRepository();
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // ============================================================
  // PASSWORD STRENGTH
  // ============================================================

  void checkPasswordStrength(String value) {
    double strength = 0;

    if (value.length >= 8) {
      strength += 0.3;
    }

    if (value.contains(RegExp(r'[A-Z]'))) {
      strength += 0.3;
    }

    if (value.contains(RegExp(r'[0-9]'))) {
      strength += 0.2;
    }

    if (value.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    )) {
      strength += 0.2;
    }

    if (!mounted) return;

    setState(() {
      passwordStrength = strength;

      if (strength < 0.4) {
        strengthText = "weak";
      } else if (strength < 0.7) {
        strengthText = "medium";
      } else {
        strengthText = "strong";
      }
    });
  }

  // ============================================================
  // PASSWORD STRENGTH COLOR
  // ============================================================

  Color strengthColor() {
    if (passwordStrength < 0.4) {
      return Colors.red;
    }

    if (passwordStrength < 0.7) {
      return Colors.orange;
    }

    return Colors.green;
  }

  // ============================================================
  // CHANGE PASSWORD
  // ============================================================

  Future<void> _changePassword() async {
    final t = context.read<LanguageProvider>().translate;

    final currentPassword =
    currentPasswordController.text.trim();

    final newPassword =
        newPasswordController.text;

    final confirmPassword =
        confirmPasswordController.text;

    // ==========================================================
    // EMPTY FIELDS
    // ==========================================================

    if (currentPassword.isEmpty ||
        newPassword.isEmpty ||
        confirmPassword.isEmpty) {
      _showError(
        t('fill_all_fields'),
      );

      return;
    }

    // ==========================================================
    // MINIMUM PASSWORD LENGTH
    // Backend requires 8 characters
    // ==========================================================

    if (newPassword.length < 8) {
      _showError(
        t('password_too_short'),
      );

      return;
    }

    // ==========================================================
    // PASSWORD MATCH
    // ==========================================================

    if (newPassword != confirmPassword) {
      _showError(
        t('passwords_not_match'),
      );

      return;
    }

    // ==========================================================
    // START LOADING
    // ==========================================================

    setState(() {
      isLoading = true;
    });

    try {
      // ========================================================
      // REAL API REQUEST
      // ========================================================

      await _repository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (!mounted) return;

      // ========================================================
      // STOP LOADING
      // ========================================================

      setState(() {
        isLoading = false;
      });

      // ========================================================
      // SUCCESS DIALOG
      // ========================================================

      await showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              t('success'),
            ),
            content: Text(
              t('password_updated_successfully'),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xff7CC000,
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  t('done'),
                  style: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      // ========================================================
      // CLEAR FIELDS
      // ========================================================

      currentPasswordController.clear();
      newPasswordController.clear();
      confirmPasswordController.clear();

      setState(() {
        passwordStrength = 0;
        strengthText = "weak";
      });

      // ========================================================
      // RETURN TO SETTINGS
      // ========================================================

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      _showError(
        _extractErrorMessage(e),
      );
    }
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  String _extractErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }

  // ============================================================
  // SHOW ERROR
  // ============================================================

  void _showError(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(message),
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        leading: IconButton(
          onPressed: isLoading
              ? null
              : () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Color(0xff1E1446),
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // TITLE
                // ==================================================

                Text(
                  t('change_password'),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1E1446),
                  ),
                ),

                const SizedBox(height: 10),

                // ==================================================
                // DESCRIPTION
                // ==================================================

                Text(
                  t('change_password_desc'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xff8FA18D),
                  ),
                ),

                const SizedBox(height: 40),

                // ==================================================
                // CURRENT PASSWORD
                // ==================================================

                buildTitle(
                  t('current_password'),
                ),

                const SizedBox(height: 10),

                buildTextField(
                  controller: currentPasswordController,
                  obscure: currentObscure,
                  hint: t('enter_current_password'),
                  onToggle: () {
                    setState(() {
                      currentObscure = !currentObscure;
                    });
                  },
                ),

                const SizedBox(height: 28),

                // ==================================================
                // NEW PASSWORD
                // ==================================================

                buildTitle(
                  t('new_password'),
                ),

                const SizedBox(height: 10),

                buildTextField(
                  controller: newPasswordController,
                  obscure: newObscure,
                  hint: t('enter_new_password'),
                  onChanged: checkPasswordStrength,
                  onToggle: () {
                    setState(() {
                      newObscure = !newObscure;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // ==================================================
                // PASSWORD STRENGTH
                // ==================================================

                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: passwordStrength,
                      minHeight: 8,
                      borderRadius:
                      BorderRadius.circular(10),
                      backgroundColor:
                      Colors.grey.shade300,
                      valueColor:
                      AlwaysStoppedAnimation(
                        strengthColor(),
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      "${t('password_strength')}: "
                          "${t(strengthText)}",
                      style: TextStyle(
                        color: strengthColor(),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ==================================================
                // CONFIRM PASSWORD
                // ==================================================

                buildTitle(
                  t('confirm_password'),
                ),

                const SizedBox(height: 10),

                buildTextField(
                  controller: confirmPasswordController,
                  obscure: confirmObscure,
                  hint: t('confirm_new_password'),
                  onToggle: () {
                    setState(() {
                      confirmObscure =
                      !confirmObscure;
                    });
                  },
                ),

                const SizedBox(height: 40),

                // ==================================================
                // UPDATE BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xff7CC000),
                      disabledBackgroundColor:
                      const Color(0xff7CC000)
                          .withOpacity(0.6),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(18),
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : _changePassword,
                    child: isLoading
                        ? const SizedBox(
                      width: 25,
                      height: 25,
                      child:
                      CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      ),
                    )
                        : Text(
                      t('update_password'),
                      style:
                      const TextStyle(
                        fontSize: 22,
                        fontWeight:
                        FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TITLE
  // ============================================================

  Widget buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xff1E1446),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget buildTextField({
    required TextEditingController controller,
    required bool obscure,
    required VoidCallback onToggle,
    String hint = "",
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      onChanged: onChanged,
      enabled: !isLoading,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xff8FA18D),
        ),
        suffixIcon: IconButton(
          onPressed: isLoading
              ? null
              : onToggle,
          icon: Icon(
            obscure
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            color: const Color(0xff8FA18D),
          ),
        ),
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}