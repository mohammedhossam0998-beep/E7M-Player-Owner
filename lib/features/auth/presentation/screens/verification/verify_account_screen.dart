import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

import 'package:e7m/core/theme/app_colors.dart';
import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/features/auth/presentation/controllers/auth_controller.dart';
import 'package:e7m/features/auth/presentation/screens/password/set_password_screen.dart';

class VerifyAccountScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phone;
  final String city;

  const VerifyAccountScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.city,
  });

  @override
  State<VerifyAccountScreen> createState() =>
      _VerifyAccountScreenState();
}

class _VerifyAccountScreenState
    extends State<VerifyAccountScreen> {
  final TextEditingController otpController =
  TextEditingController();

  Timer? _timer;

  int _secondsRemaining = 59;

  bool _isResending = false;

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    _startTimer();
  }

  // ============================================================
  // TIMER
  // ============================================================

  void _startTimer() {
    _timer?.cancel();

    if (!mounted) {
      return;
    }

    setState(() {
      _secondsRemaining = 59;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_secondsRemaining <= 1) {
          timer.cancel();

          setState(() {
            _secondsRemaining = 0;
          });

          return;
        }

        setState(() {
          _secondsRemaining--;
        });
      },
    );
  }

  String get _timerLabel {
    final minutes =
    (_secondsRemaining ~/ 60)
        .toString()
        .padLeft(2, '0');

    final seconds =
    (_secondsRemaining % 60)
        .toString()
        .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  // ============================================================
  // VERIFY OTP
  // ============================================================

  Future<void> _handleVerify(
      AuthController authController,
      ) async {
    final otp =
    otpController.text.trim();

    if (otp.length != 6) {
      _showMessage(
        'Please enter the 6-digit verification code.',
      );

      return;
    }

    FocusScope.of(context).unfocus();

    final success =
    await authController.verifyOtp(
      email: widget.email,
      otp: otp,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      // ----------------------------------------------------------
      // IMPORTANT:
      // نلغي التايمر فورًا قبل الانتقال، عشان محدش يعمل setState
      // على الشاشة دي وهي بترحل. وبعدين ننتقل لشاشة الباسورد
      // المنفصلة SetPasswordScreen بدل ما نبدّل UI جوه نفس
      // الشاشة، عشان نتجنب كراش:
      // '_dependents.isEmpty': is not true.
      // ----------------------------------------------------------

      _timer?.cancel();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SetPasswordScreen(
              fullName: widget.fullName,
              email: widget.email,
              phone: widget.phone,
              city: widget.city,
            ),
          ),
        );
      });

      return;
    }

    if (authController.errorMessage != null) {
      _showMessage(
        authController.errorMessage!,
      );
    }
  }

  // ============================================================
  // RESEND OTP
  // ============================================================

  Future<void> _handleResend(
      AuthController authController,
      ) async {
    if (_secondsRemaining > 0 ||
        _isResending ||
        authController.isLoading) {
      return;
    }

    setState(() {
      _isResending = true;
    });

    final success =
    await authController.sendOtp(
      email: widget.email,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _isResending = false;
    });

    if (success) {
      otpController.clear();

      _startTimer();

      _showMessage(
        'تم إرسال كود تحقق جديد إلى البريد الإلكتروني',
      );

      return;
    }

    if (authController.errorMessage != null) {
      _showMessage(
        authController.errorMessage!,
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _timer?.cancel();

    otpController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final t =
        context
            .watch<LanguageProvider>()
            .translate;

    final authController =
    context.watch<AuthController>();

    return Scaffold(
      backgroundColor:
      AppColors.background,

      appBar: AppBar(
        elevation: 0,
        backgroundColor:
        Colors.transparent,
        iconTheme:
        const IconThemeData(
          color: AppColors.darkNavy,
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
          const EdgeInsets.all(24),

          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),

              // ==================================================
              // STEP
              // ==================================================

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration:
                BoxDecoration(
                  color: AppColors.secondary
                      .withValues(
                    alpha: .1,
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),
                child: const Text(
                  'Step 2 of 3',
                  style:
                  TextStyle(
                    color:
                    AppColors.secondary,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // ==================================================
              // ICON
              // ==================================================

              const Icon(
                Icons.mark_email_read_rounded,
                size: 90,
                color:
                AppColors.secondary,
              ),

              const SizedBox(
                height: 25,
              ),

              // ==================================================
              // TITLE
              // ==================================================

              const Text(
                'Verify Your Email',
                textAlign:
                TextAlign.center,
                style:
                TextStyle(
                  fontSize: 30,
                  fontWeight:
                  FontWeight.bold,
                  color:
                  AppColors.darkNavy,
                ),
              ),

              const SizedBox(
                height: 12,
              ),

              // ==================================================
              // EMAIL
              // ==================================================

              Text(
                widget.email,
                textAlign:
                TextAlign.center,
                style:
                const TextStyle(
                  fontSize: 16,
                  fontWeight:
                  FontWeight.w600,
                  color:
                  AppColors.secondary,
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              // ==================================================
              // OTP SECTION
              // ==================================================

              const Text(
                'We sent a 6-digit verification code to your email address.',
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  height: 1.5,
                  fontSize: 15,
                ),
              ),

              const SizedBox(
                height: 35,
              ),

              PinCodeTextField(
                appContext: context,
                length: 6,
                controller:
                otpController,
                keyboardType:
                TextInputType.number,
                autoFocus: true,
                animationType:
                AnimationType.fade,
                enableActiveFill: true,
                cursorColor:
                AppColors.secondary,
                textStyle:
                const TextStyle(
                  fontSize: 22,
                  fontWeight:
                  FontWeight.bold,
                ),
                pinTheme:
                PinTheme(
                  shape:
                  PinCodeFieldShape
                      .box,
                  borderRadius:
                  BorderRadius
                      .circular(
                    12,
                  ),
                  fieldHeight: 60,
                  fieldWidth: 50,
                  activeFillColor:
                  Colors.white,
                  selectedFillColor:
                  Colors.white,
                  inactiveFillColor:
                  Colors.white,
                  activeColor:
                  AppColors
                      .secondary,
                  selectedColor:
                  AppColors
                      .secondary,
                  inactiveColor:
                  Colors.grey
                      .shade300,
                ),
                onCompleted:
                    (value) {
                  FocusScope.of(
                    context,
                  ).unfocus();
                },
                onChanged:
                    (value) {},
              ),

              const SizedBox(
                height: 25,
              ),

              TextButton(
                onPressed:
                (_secondsRemaining ==
                    0 &&
                    !_isResending &&
                    !authController
                        .isLoading)
                    ? () =>
                    _handleResend(
                      authController,
                    )
                    : null,
                child:
                _isResending
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child:
                  CircularProgressIndicator(
                    strokeWidth:
                    2,
                    color: AppColors
                        .secondary,
                  ),
                )
                    : Text(
                  _secondsRemaining ==
                      0
                      ? 'Resend Code'
                      : 'Resend Code ($_timerLabel)',
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              SizedBox(
                width:
                double.infinity,
                height: 56,
                child:
                ElevatedButton(
                  style:
                  ElevatedButton
                      .styleFrom(
                    backgroundColor:
                    AppColors
                        .secondary,
                    foregroundColor:
                    Colors.white,
                    elevation: 0,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius
                          .circular(
                        14,
                      ),
                    ),
                  ),
                  onPressed:
                  authController
                      .isLoading
                      ? null
                      : () =>
                      _handleVerify(
                        authController,
                      ),
                  child:
                  authController
                      .isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child:
                    CircularProgressIndicator(
                      strokeWidth:
                      2.5,
                      color: Colors
                          .white,
                    ),
                  )
                      : const Text(
                    'Verify Email',
                    style:
                    TextStyle(
                      fontSize:
                      18,
                      fontWeight:
                      FontWeight
                          .bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(
                height: 25,
              ),

              Text(
                'E7M © 2026',
                style: TextStyle(
                  color:
                  Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}