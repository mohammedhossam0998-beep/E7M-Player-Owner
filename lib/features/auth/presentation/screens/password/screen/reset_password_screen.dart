import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/core/theme/app_colors.dart';
import 'package:e7m/features/auth/presentation/controllers/auth_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() =>
      _ResetPasswordScreenState();
}

class _ResetPasswordScreenState
    extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final passwordController =
  TextEditingController();

  final confirmPasswordController =
  TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword(
      AuthController authController,
      ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final success =
    await authController.resetPasswordWithOtp(
      email: widget.email,
      otp: widget.otp,
      password: passwordController.text,
      confirmPassword:
      confirmPasswordController.text,
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authController.errorMessage ??
                'Failed to reset password',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Password reset successfully',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).popUntil(
          (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final authController =
    context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: Stack(
          children: [
            // ==============================
            // TOP GREEN
            // ==============================

            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 330,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius:
                  const BorderRadius.only(
                    bottomLeft:
                    Radius.circular(180),
                  ),
                ),
              ),
            ),

            // ==============================
            // BOTTOM BLUE
            // ==============================

            Positioned(
              bottom: -120,
              left: -100,
              child: Container(
                width: 350,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.darkNavy,
                  borderRadius:
                  const BorderRadius.only(
                    topRight:
                    Radius.circular(180),
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 25),

                    // ==============================
                    // BACK
                    // ==============================

                    IconButton(
                      onPressed:
                      authController.isLoading
                          ? null
                          : () {
                        Navigator.pop(
                            context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color:
                        AppColors.darkNavy,
                      ),
                    ),

                    const SizedBox(height: 45),

                    // ==============================
                    // ICON
                    // ==============================

                    Center(
                      child: Container(
                        width: 135,
                        height: 135,
                        decoration: BoxDecoration(
                          color:
                          const Color(
                              0xffDCECB8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                            AppColors.darkNavy,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.lock_reset,
                          size: 72,
                          color:
                          AppColors.darkNavy,
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // ==============================
                    // TITLE
                    // ==============================

                    const Center(
                      child: Text(
                        'Create New Password',
                        textAlign:
                        TextAlign.center,
                        style: TextStyle(
                          fontSize: 29,
                          fontWeight:
                          FontWeight.bold,
                          color:
                          AppColors.darkNavy,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    const Center(
                      child: Text(
                        'Create a strong new password\nfor your E7gzly account.',
                        textAlign:
                        TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 38),

                    // ==============================
                    // PASSWORD
                    // ==============================

                    const Text(
                      'New Password',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        AppColors.darkNavy,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller:
                      passwordController,
                      obscureText:
                      obscurePassword,

                      textInputAction:
                      TextInputAction.next,

                      decoration:
                      InputDecoration(
                        hintText:
                        'Enter new password',
                        filled: true,
                        fillColor:
                        Colors.white,

                        contentPadding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 20,
                          vertical: 19,
                        ),

                        suffixIcon:
                        IconButton(
                          onPressed: () {
                            setState(() {
                              obscurePassword =
                              !obscurePassword;
                            });
                          },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility
                                : Icons
                                .visibility_off,
                            color:
                            Colors.grey,
                          ),
                        ),

                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              14),
                          borderSide:
                          BorderSide(
                            color:
                            Colors.grey
                                .shade300,
                          ),
                        ),

                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              14),
                          borderSide:
                          BorderSide(
                            color:
                            Colors.grey
                                .shade300,
                          ),
                        ),

                        focusedBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              14),
                          borderSide:
                          const BorderSide(
                            color:
                            AppColors.secondary,
                            width: 2,
                          ),
                        ),
                      ),

                      validator: (value) {
                        final password =
                            value?.trim() ?? '';

                        if (password.isEmpty) {
                          return 'Enter your new password';
                        }

                        if (password.length < 8) {
                          return 'Password must be at least 8 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // ==============================
                    // CONFIRM PASSWORD
                    // ==============================

                    const Text(
                      'Confirm Password',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        AppColors.darkNavy,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller:
                      confirmPasswordController,
                      obscureText:
                      obscureConfirmPassword,

                      textInputAction:
                      TextInputAction.done,

                      decoration:
                      InputDecoration(
                        hintText:
                        'Confirm new password',
                        filled: true,
                        fillColor:
                        Colors.white,

                        contentPadding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 20,
                          vertical: 19,
                        ),

                        suffixIcon:
                        IconButton(
                          onPressed: () {
                            setState(() {
                              obscureConfirmPassword =
                              !obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility
                                : Icons
                                .visibility_off,
                            color:
                            Colors.grey,
                          ),
                        ),

                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              14),
                          borderSide:
                          BorderSide(
                            color:
                            Colors.grey
                                .shade300,
                          ),
                        ),

                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              14),
                          borderSide:
                          BorderSide(
                            color:
                            Colors.grey
                                .shade300,
                          ),
                        ),

                        focusedBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                              14),
                          borderSide:
                          const BorderSide(
                            color:
                            AppColors.secondary,
                            width: 2,
                          ),
                        ),
                      ),

                      validator: (value) {
                        final confirm =
                            value?.trim() ?? '';

                        if (confirm.isEmpty) {
                          return 'Confirm your password';
                        }

                        if (confirm !=
                            passwordController
                                .text) {
                          return 'Passwords do not match';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 35),

                    // ==============================
                    // RESET BUTTON
                    // ==============================

                    SizedBox(
                      width: double.infinity,
                      height: 58,
                      child: ElevatedButton(
                        style:
                        ElevatedButton.styleFrom(
                          backgroundColor:
                          AppColors.secondary,
                          disabledBackgroundColor:
                          AppColors.secondary
                              .withOpacity(0.5),
                          elevation: 0,
                          shape:
                          RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(
                                14),
                          ),
                        ),
                        onPressed:
                        authController.isLoading
                            ? null
                            : () =>
                            _resetPassword(
                              authController,
                            ),
                        child:
                        authController.isLoading
                            ? const SizedBox(
                          width: 25,
                          height: 25,
                          child:
                          CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                            AlwaysStoppedAnimation<
                                Color>(
                              Colors.white,
                            ),
                          ),
                        )
                            : const Text(
                          'Reset Password',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                            color:
                            Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 130),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}