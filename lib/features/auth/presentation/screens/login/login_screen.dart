import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';

import 'package:e7m/core/theme/app_colors.dart';
import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/features/auth/presentation/controllers/auth_controller.dart';
import 'package:e7m/features/player/home/home_screen.dart';
import 'package:e7m/features/owner/dashboard/owner_dashboard_screen.dart';
import 'package:e7m/features/auth/presentation/screens/player_otp_screen.dart';
import 'package:e7m/features/auth/presentation/screens/password/forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool rememberMe = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<void> _handleLogin(
      AuthController authController,
      Function(String) t,
      ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final success = await authController.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) {
      return;
    }

    // ==========================================================
    // EMAIL VERIFICATION REQUIRED
    // ==========================================================

    if (authController.requiresVerification) {
      final verificationEmail =
          authController.verificationEmail ??
              emailController.text.trim();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PlayerOtpScreen(
            email: verificationEmail,
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // LOGIN SUCCESS
    // ==========================================================

    if (success) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.success(
          message: t("login_success"),
        ),
      );

      final role = authController.role?.toLowerCase();

      if (role == 'player' || role == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const HomeScreen(),
          ),
        );

        return;
      }

      if (role == 'owner') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const OwnerDashboardScreen(),
          ),
        );

        return;
      }

      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.info(
          message: 'Unknown account role',
        ),
      );

      return;
    }

    // ==========================================================
    // LOGIN ERROR
    // ==========================================================

    if (authController.errorMessage != null) {
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: authController.errorMessage!,
        ),
      );
    }
  }

  // ============================================================
  // FORGOT PASSWORD
  // ============================================================

  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ForgotPasswordScreen(),
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,

      hintStyle: const TextStyle(
        color: Color(0xff92929B),
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),

      prefixIcon: Padding(
        padding: const EdgeInsets.only(
          left: 17,
          right: 10,
        ),
        child: Icon(
          icon,
          color: AppColors.darkNavy,
          size: 23,
        ),
      ),

      prefixIconConstraints: const BoxConstraints(
        minWidth: 55,
        minHeight: 55,
      ),

      suffixIcon: suffixIcon,

      filled: true,
      fillColor: Colors.white,

      contentPadding: const EdgeInsets.symmetric(
        horizontal: 17,
        vertical: 18,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xffD8D9DD),
          width: 1,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xffD8D9DD),
          width: 1,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.secondary,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.4,
        ),
      ),

      errorStyle: const TextStyle(
        fontSize: 11.5,
        height: 1.15,
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

    final isRtl =
        Directionality.of(context) ==
            TextDirection.rtl;

    return Scaffold(
      backgroundColor: const Color(0xffF9FBF7),
      resizeToAvoidBottomInset: true,

      body: SafeArea(
        child: Stack(
          children: [
            // ==================================================
            // BACKGROUND
            // ==================================================

            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _LoginBackgroundPainter(),
                ),
              ),
            ),

            // ==================================================
            // MAIN CONTENT
            // ==================================================

            Positioned.fill(
              child: LayoutBuilder(
                builder: (
                    context,
                    constraints,
                    ) {
                  return SingleChildScrollView(
                    physics:
                    const BouncingScrollPhysics(),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),

                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                        constraints.maxHeight,
                      ),

                      child: Form(
                        key: _formKey,

                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,

                          children: [
                            // ==================================================
                            // TOP SPACE
                            // ==================================================

                            const SizedBox(
                              height: 8,
                            ),

                            // ==================================================
                            // BACK BUTTON
                            // ==================================================

                            Align(
                              alignment: isRtl
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,

                              child: SizedBox(
                                width: 42,
                                height: 42,

                                child: IconButton(
                                  padding:
                                  EdgeInsets.zero,

                                  splashRadius: 23,

                                  onPressed:
                                  authController
                                      .isLoading
                                      ? null
                                      : () {
                                    Navigator.pop(
                                      context,
                                    );
                                  },

                                  icon: Icon(
                                    isRtl
                                        ? Icons
                                        .arrow_forward_ios_rounded
                                        : Icons
                                        .arrow_back_ios_rounded,

                                    color:
                                    AppColors.darkNavy,

                                    size: 21,
                                  ),
                                ),
                              ),
                            ),

                            // ==================================================
                            // E7M LOGO
                            // ==================================================

                            const SizedBox(
                              height: 5,
                            ),

                            Center(
                              child: Container(
                                width: 150,
                                height: 112,

                                decoration:
                                BoxDecoration(
                                  color:
                                  Colors.transparent,

                                  borderRadius:
                                  BorderRadius.circular(
                                    20,
                                  ),
                                ),

                                child: Image.asset(
                                  'assets/images/e7m_logo.png',

                                  width: 150,
                                  height: 112,

                                  fit: BoxFit.contain,

                                  filterQuality:
                                  FilterQuality.high,
                                ),
                              ),
                            ),

                            // ==================================================
                            // TITLE
                            // ==================================================

                            const SizedBox(
                              height: 12,
                            ),

                            Text(
                              t("welcome_back"),

                              textAlign:
                              TextAlign.center,

                              style: const TextStyle(
                                color:
                                AppColors.darkNavy,

                                fontSize: 29,

                                fontWeight:
                                FontWeight.w800,

                                letterSpacing: -0.4,

                                height: 1.15,
                              ),
                            ),

                            // ==================================================
                            // SUBTITLE
                            // ==================================================

                            const SizedBox(
                              height: 9,
                            ),

                            Text(
                              t("join_e7gzly"),

                              textAlign:
                              TextAlign.center,

                              style: const TextStyle(
                                color:
                                Color(0xff85858D),

                                fontSize: 14.5,

                                fontWeight:
                                FontWeight.w400,

                                height: 1.4,
                              ),
                            ),

                            // ==================================================
                            // EMAIL LABEL
                            // ==================================================

                            const SizedBox(
                              height: 31,
                            ),

                            Text(
                              t("email_address"),

                              style: const TextStyle(
                                color:
                                AppColors.darkNavy,

                                fontSize: 16,

                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),

                            const SizedBox(
                              height: 9,
                            ),

                            // ==================================================
                            // EMAIL FIELD
                            // ==================================================

                            TextFormField(
                              controller:
                              emailController,

                              keyboardType:
                              TextInputType
                                  .emailAddress,

                              textInputAction:
                              TextInputAction.next,

                              style: const TextStyle(
                                color:
                                AppColors.darkNavy,

                                fontSize: 15,

                                fontWeight:
                                FontWeight.w500,
                              ),

                              validator:
                                  (value) =>
                                  authController
                                      .validateEmail(
                                    value ?? '',
                                  ),

                              decoration:
                              _inputDecoration(
                                hint: t(
                                  "enter_email",
                                ),
                                icon:
                                Icons
                                    .email_outlined,
                              ),
                            ),

                            // ==================================================
                            // PASSWORD LABEL
                            // ==================================================

                            const SizedBox(
                              height: 19,
                            ),

                            Text(
                              t("password"),

                              style: const TextStyle(
                                color:
                                AppColors.darkNavy,

                                fontSize: 16,

                                fontWeight:
                                FontWeight.w700,
                              ),
                            ),

                            const SizedBox(
                              height: 9,
                            ),

                            // ==================================================
                            // PASSWORD FIELD
                            // ==================================================

                            TextFormField(
                              controller:
                              passwordController,

                              obscureText:
                              obscurePassword,

                              textInputAction:
                              TextInputAction.done,

                              style: const TextStyle(
                                color:
                                AppColors.darkNavy,

                                fontSize: 15,

                                fontWeight:
                                FontWeight.w500,
                              ),

                              validator:
                                  (value) =>
                                  authController
                                      .validatePassword(
                                    value ?? '',
                                  ),

                              onFieldSubmitted: (_) {
                                if (!authController
                                    .isLoading) {
                                  _handleLogin(
                                    authController,
                                    t,
                                  );
                                }
                              },

                              decoration:
                              _inputDecoration(
                                hint: t("password"),

                                icon:
                                Icons
                                    .lock_outline_rounded,

                                suffixIcon:
                                IconButton(
                                  splashRadius: 22,

                                  onPressed: () {
                                    setState(() {
                                      obscurePassword =
                                      !obscurePassword;
                                    });
                                  },

                                  icon: Icon(
                                    obscurePassword
                                        ? Icons
                                        .visibility_off_outlined
                                        : Icons
                                        .visibility_outlined,

                                    color:
                                    const Color(
                                      0xff858590,
                                    ),

                                    size: 23,
                                  ),
                                ),
                              ),
                            ),

                            // ==================================================
                            // REMEMBER / FORGOT
                            // ==================================================

                            const SizedBox(
                              height: 8,
                            ),

                            Row(
                              children: [
                                // ==============================================
                                // REMEMBER ME
                                // ==============================================

                                Expanded(
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 26,
                                        height: 26,

                                        child: Checkbox(
                                          value:
                                          rememberMe,

                                          activeColor:
                                          AppColors
                                              .secondary,

                                          checkColor:
                                          Colors.white,

                                          materialTapTargetSize:
                                          MaterialTapTargetSize
                                              .shrinkWrap,

                                          visualDensity:
                                          VisualDensity
                                              .compact,

                                          shape:
                                          RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius
                                                .circular(
                                              5,
                                            ),
                                          ),

                                          side:
                                          const BorderSide(
                                            color:
                                            Color(
                                              0xff62626B,
                                            ),
                                            width: 1.5,
                                          ),

                                          onChanged:
                                              (value) {
                                            setState(() {
                                              rememberMe =
                                                  value ??
                                                      false;
                                            });
                                          },
                                        ),
                                      ),

                                      const SizedBox(
                                        width: 5,
                                      ),

                                      Flexible(
                                        child: Text(
                                          t(
                                            "remember_me",
                                          ),

                                          overflow:
                                          TextOverflow
                                              .ellipsis,

                                          style:
                                          const TextStyle(
                                            color:
                                            AppColors
                                                .darkNavy,

                                            fontSize: 13.5,

                                            fontWeight:
                                            FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // ==============================================
                                // FORGOT PASSWORD
                                // ==============================================

                                GestureDetector(
                                  onTap:
                                  authController
                                      .isLoading
                                      ? null
                                      : _handleForgotPassword,

                                  child: Text(
                                    t(
                                      "forget_password",
                                    ),

                                    style:
                                    const TextStyle(
                                      color:
                                      AppColors
                                          .darkNavy,

                                      fontSize: 13.5,

                                      fontWeight:
                                      FontWeight.w600,

                                      decoration:
                                      TextDecoration
                                          .underline,

                                      decorationThickness:
                                      1.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // ==================================================
                            // LOGIN BUTTON
                            // ==================================================

                            const SizedBox(
                              height: 22,
                            ),

                            SizedBox(
                              height: 55,

                              child:
                              ElevatedButton(
                                onPressed:
                                authController
                                    .isLoading
                                    ? null
                                    : () =>
                                    _handleLogin(
                                      authController,
                                      t,
                                    ),

                                style:
                                ElevatedButton
                                    .styleFrom(
                                  elevation: 0,

                                  backgroundColor:
                                  AppColors
                                      .secondary,

                                  foregroundColor:
                                  Colors.white,

                                  disabledBackgroundColor:
                                  AppColors
                                      .secondary
                                      .withOpacity(
                                    0.55,
                                  ),

                                  disabledForegroundColor:
                                  Colors.white
                                      .withOpacity(
                                    0.8,
                                  ),

                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      14,
                                    ),
                                  ),
                                ),

                                child:
                                authController
                                    .isLoading
                                    ? const SizedBox(
                                  width: 23,
                                  height: 23,
                                  child:
                                  CircularProgressIndicator(
                                    strokeWidth:
                                    2.3,
                                    color:
                                    Colors
                                        .white,
                                  ),
                                )
                                    : Text(
                                  t("login"),

                                  style:
                                  const TextStyle(
                                    color:
                                    Colors
                                        .white,

                                    fontSize: 17,

                                    fontWeight:
                                    FontWeight
                                        .w700,
                                  ),
                                ),
                              ),
                            ),

                            // ==================================================
                            // FOOTER
                            // ==================================================

                            const SizedBox(
                              height: 18,
                            ),

                            Center(
                              child: Text(
                                'E7M © 2026',

                                style:
                                const TextStyle(
                                  color:
                                  Color(
                                    0xff9999A0,
                                  ),

                                  fontSize: 11.5,

                                  fontWeight:
                                  FontWeight.w400,
                                ),
                              ),
                            ),

                            // ==================================================
                            // BOTTOM SPACE
                            // ==================================================

                            const SizedBox(
                              height: 70,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LOGIN BACKGROUND PAINTER
// ============================================================

class _LoginBackgroundPainter
    extends CustomPainter {
  const _LoginBackgroundPainter();

  @override
  void paint(
      Canvas canvas,
      Size size,
      ) {
    // ==========================================================
    // COLORS
    // ==========================================================

    final green =
        AppColors.secondary;

    const lightGreen =
    Color(0xffB9EA6D);

    final navy =
        AppColors.darkNavy;

    // ==========================================================
    // TOP LIGHT GREEN SHAPE
    // ==========================================================

    final topGreenPaint =
    Paint()
      ..color = lightGreen
      ..style = PaintingStyle.fill;

    final topGreenPath =
    Path();

    topGreenPath.moveTo(
      size.width * 0.62,
      0,
    );

    topGreenPath.lineTo(
      size.width,
      0,
    );

    topGreenPath.lineTo(
      size.width,
      size.height * 0.17,
    );

    topGreenPath.cubicTo(
      size.width * 0.94,
      size.height * 0.145,
      size.width * 0.87,
      size.height * 0.11,
      size.width * 0.79,
      size.height * 0.075,
    );

    topGreenPath.cubicTo(
      size.width * 0.72,
      size.height * 0.045,
      size.width * 0.66,
      size.height * 0.018,
      size.width * 0.62,
      0,
    );

    topGreenPath.close();

    canvas.drawPath(
      topGreenPath,
      topGreenPaint,
    );

    // ==========================================================
    // TOP WHITE CUT / CURVE
    // ==========================================================

    final topWhiteLinePaint =
    Paint()
      ..color = const Color(0xffF9FBF7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;

    final topWhiteLinePath =
    Path();

    topWhiteLinePath.moveTo(
      size.width * 0.51,
      0,
    );

    topWhiteLinePath.cubicTo(
      size.width * 0.59,
      size.height * 0.045,
      size.width * 0.67,
      size.height * 0.075,
      size.width * 0.77,
      size.height * 0.11,
    );

    topWhiteLinePath.cubicTo(
      size.width * 0.88,
      size.height * 0.15,
      size.width * 0.95,
      size.height * 0.19,
      size.width,
      size.height * 0.23,
    );

    canvas.drawPath(
      topWhiteLinePath,
      topWhiteLinePaint,
    );

    // ==========================================================
    // TOP GREEN ACCENT LINE
    // ==========================================================

    final topLinePaint =
    Paint()
      ..color = green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;

    final topLinePath =
    Path();

    topLinePath.moveTo(
      size.width * 0.47,
      0,
    );

    topLinePath.cubicTo(
      size.width * 0.56,
      size.height * 0.05,
      size.width * 0.66,
      size.height * 0.085,
      size.width * 0.77,
      size.height * 0.125,
    );

    topLinePath.cubicTo(
      size.width * 0.88,
      size.height * 0.165,
      size.width * 0.96,
      size.height * 0.205,
      size.width,
      size.height * 0.245,
    );

    canvas.drawPath(
      topLinePath,
      topLinePaint,
    );

    // ==========================================================
    // BOTTOM NAVY SHAPE
    // ==========================================================

    final bottomNavyPaint =
    Paint()
      ..color = navy
      ..style = PaintingStyle.fill;

    final bottomNavyPath =
    Path();

    bottomNavyPath.moveTo(
      0,
      size.height * 0.91,
    );

    bottomNavyPath.cubicTo(
      size.width * 0.09,
      size.height * 0.945,
      size.width * 0.20,
      size.height * 0.955,
      size.width * 0.31,
      size.height,
    );

    bottomNavyPath.lineTo(
      0,
      size.height,
    );

    bottomNavyPath.close();

    canvas.drawPath(
      bottomNavyPath,
      bottomNavyPaint,
    );

    // ==========================================================
    // BOTTOM WHITE CURVE
    // ==========================================================

    final bottomWhitePaint =
    Paint()
      ..color = const Color(0xffF9FBF7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;

    final bottomWhitePath =
    Path();

    bottomWhitePath.moveTo(
      0,
      size.height * 0.885,
    );

    bottomWhitePath.cubicTo(
      size.width * 0.10,
      size.height * 0.925,
      size.width * 0.22,
      size.height * 0.945,
      size.width * 0.34,
      size.height,
    );

    canvas.drawPath(
      bottomWhitePath,
      bottomWhitePaint,
    );

    // ==========================================================
    // BOTTOM GREEN ACCENT
    // ==========================================================

    final bottomGreenPaint =
    Paint()
      ..color = green
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;

    final bottomGreenPath =
    Path();

    bottomGreenPath.moveTo(
      0,
      size.height * 0.865,
    );

    bottomGreenPath.cubicTo(
      size.width * 0.11,
      size.height * 0.915,
      size.width * 0.24,
      size.height * 0.935,
      size.width * 0.37,
      size.height,
    );

    canvas.drawPath(
      bottomGreenPath,
      bottomGreenPaint,
    );
  }

  @override
  bool shouldRepaint(
      covariant CustomPainter oldDelegate,
      ) {
    return false;
  }
}