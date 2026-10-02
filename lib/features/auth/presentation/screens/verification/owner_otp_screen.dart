import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/core/theme/app_colors.dart';
import 'package:e7m/features/auth/presentation/controllers/auth_controller.dart';
import '../password/set_password_screen.dart'; // ✅ صح// ✨ عدّل المسار ده حسب مكان set_password_screen.dart عندك

class OwnerOtpScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String city;

  const OwnerOtpScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
  });

  @override
  State<OwnerOtpScreen> createState() => _OwnerOtpScreenState();
}

class _OwnerOtpScreenState extends State<OwnerOtpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();

  Timer? _timer;
  int _secondsRemaining = 59;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 59;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining == 0) {
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--;
        });
      }
    });
  }

  String get _timerLabel {
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
 // بعد التحقق من الـ OTP، الـ Owner ينتقل إلى SetPasswordScreen.
 // يتم إنشاء الحساب بعد تعيين كلمة المرور.
 // الـ Owner لا يحصل على JWT في هذه المرحلة؛
 // الحساب يظل Pending إلى أن تتم موافقة الـ Admin.
 // AuthController.verifyOtp() يحتفظ بـ registrationToken
 // لاستخدامه في خطوة Set Password.
  // ============================================================

  Future<void> _handleVerify(AuthController authController) async {
    final success = await authController.verifyOtp(
      email: widget.email,
      otp: otpController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SetPasswordScreen(
            fullName: widget.fullName,
            email: widget.email,
            phone: widget.phone,
            city: widget.city,
            isOwner: true,
          ),
        ),
      );
    } else if (authController.errorMessage != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(authController.errorMessage!)));
    }
  }

  @override
  void dispose() {
    otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;
    final authController = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.darkNavy),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height - 120,
            ),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withValues(alpha: .1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        t('step_2_of_5'),
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Icon(
                      Icons.verified_user_rounded,
                      size: 90,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(height: 25),
                    Text(
                      t('verify_phone_number'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      t('otp_instructions'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.grey, height: 1.4),
                    ),
                    const SizedBox(height: 40),

                    PinCodeTextField(
                      appContext: context,
                      length: 6,
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      autoFocus: true,
                      animationType: AnimationType.fade,
                      enableActiveFill: true,
                      cursorColor: AppColors.secondary,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.box,
                        borderRadius: BorderRadius.circular(12),
                        fieldHeight: 60,
                        fieldWidth: 50,
                        activeFillColor: Colors.white,
                        selectedFillColor: Colors.white,
                        inactiveFillColor: Colors.white,
                        activeColor: AppColors.secondary,
                        selectedColor: AppColors.secondary,
                        inactiveColor: Colors.grey.shade300,
                      ),
                      onCompleted: (value) {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (value) {},
                    ),

                    const SizedBox(height: 25),
                    TextButton(
                      onPressed: _secondsRemaining == 0
                          ? () {
                        authController.sendOtp(
                          email: widget.email,
                        );
                        _startTimer();
                      }
                          : null,
                      child: Text(
                        _secondsRemaining == 0
                            ? t('resend_code')
                            : '${t('resend_code')} ($_timerLabel)',
                      ),
                    ),
                    const Spacer(),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: authController.isLoading
                            ? null
                            : () => _handleVerify(authController),
                        child: authController.isLoading
                            ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                            : Text(
                          t('verify_and_continue'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
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
          ),
        ),
      ),
    );
  }
}