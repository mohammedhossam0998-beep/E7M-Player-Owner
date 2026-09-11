import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/core/theme/app_colors.dart';
import 'package:e7m/features/auth/presentation/controllers/auth_controller.dart';

import 'reset_password_screen.dart';

class ResetPasswordOtpScreen extends StatefulWidget {
  final String email;

  const ResetPasswordOtpScreen({
    super.key,
    required this.email,
  });

  @override
  State<ResetPasswordOtpScreen> createState() =>
      _ResetPasswordOtpScreenState();
}

class _ResetPasswordOtpScreenState
    extends State<ResetPasswordOtpScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController otpController =
  TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  Future<void> _verifyOtp(
      AuthController authController,
      ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final success =
    await authController.verifyResetOtp(
      email: widget.email,
      otp: otpController.text.trim(),
    );

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authController.errorMessage ??
                'Invalid or expired verification code',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(
          email: widget.email,
          otp: otpController.text.trim(),
        ),
      ),
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
            // TOP GREEN DECORATION
            // ==============================

            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 330,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(180),
                  ),
                ),
              ),
            ),

            // ==============================
            // BOTTOM BLUE DECORATION
            // ==============================

            Positioned(
              bottom: -120,
              left: -100,
              child: Container(
                width: 350,
                height: 250,
                decoration: BoxDecoration(
                  color: AppColors.darkNavy,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(180),
                  ),
                ),
              ),
            ),

            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
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
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios_new,
                        color: AppColors.darkNavy,
                      ),
                    ),

                    const SizedBox(height: 45),

                    // ==============================
                    // LOCK ICON
                    // ==============================

                    Center(
                      child: Container(
                        width: 135,
                        height: 135,
                        decoration: BoxDecoration(
                          color: const Color(0xffDCECB8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.darkNavy,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.verified_user_outlined,
                          size: 70,
                          color: AppColors.darkNavy,
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // ==============================
                    // TITLE
                    // ==============================

                    const Center(
                      child: Text(
                        'Verification Code',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkNavy,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Center(
                      child: Text(
                        'Enter the 6-digit code sent to\n${widget.email}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Colors.grey,
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // ==============================
                    // OTP FIELD
                    // ==============================

                    const Text(
                      'Verification Code',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkNavy,
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: otpController,
                      keyboardType:
                      TextInputType.number,
                      textInputAction:
                      TextInputAction.done,
                      maxLength: 6,
                      textAlign: TextAlign.center,

                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 9,
                        color: AppColors.darkNavy,
                      ),

                      decoration: InputDecoration(
                        hintText: '000000',
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,

                        contentPadding:
                        const EdgeInsets.symmetric(
                          vertical: 20,
                        ),

                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                          borderSide:
                          BorderSide(
                            color:
                            Colors.grey.shade300,
                          ),
                        ),

                        enabledBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                          borderSide:
                          BorderSide(
                            color:
                            Colors.grey.shade300,
                          ),
                        ),

                        focusedBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                          borderSide:
                          const BorderSide(
                            color:
                            AppColors.secondary,
                            width: 2,
                          ),
                        ),

                        errorBorder:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                          borderSide:
                          const BorderSide(
                            color: Colors.red,
                          ),
                        ),
                      ),

                      validator: (value) {
                        final otp =
                            value?.trim() ?? '';

                        if (otp.isEmpty) {
                          return 'Enter the verification code';
                        }

                        if (!RegExp(
                          r'^\d{6}$',
                        ).hasMatch(otp)) {
                          return 'OTP must be 6 digits';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 35),

                    // ==============================
                    // VERIFY BUTTON
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
                            BorderRadius.circular(14),
                          ),
                        ),
                        onPressed:
                        authController.isLoading
                            ? null
                            : () => _verifyOtp(
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
                          'Verify Code',
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