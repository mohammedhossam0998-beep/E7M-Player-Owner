import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/core/theme/app_colors.dart';
import 'package:e7m/features/auth/presentation/controllers/auth_controller.dart';

import 'screen/reset_password_otp_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController =
  TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future<void> _handleNext(
      AuthController authController,
      ) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = emailController.text.trim();

    FocusScope.of(context).unfocus();

    final success = await authController.forgotPassword(
      email: email,
    );

    if (!mounted) {
      return;
    }

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authController.errorMessage ??
                'فشل إرسال كود التحقق',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ResetPasswordOtpScreen(
          email: email,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t =
        context.watch<LanguageProvider>().translate;

    final authController =
    context.watch<AuthController>();

    final isRtl =
        Directionality.of(context) ==
            TextDirection.rtl;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,

      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
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
                  const SizedBox(height: 20),

                  // ==================================================
                  // BACK + TITLE
                  // ==================================================

                  Row(
                    children: [
                      IconButton(
                        onPressed:
                        authController.isLoading
                            ? null
                            : () {
                          Navigator.pop(
                            context,
                          );
                        },

                        icon: Icon(
                          isRtl
                              ? Icons.arrow_forward_ios
                              : Icons.arrow_back_ios,

                          size: 20,

                          color:
                          AppColors.darkNavy,
                        ),
                      ),

                      Expanded(
                        child: Text(
                          t('forgot_password'),

                          style:
                          const TextStyle(
                            fontSize: 22,
                            fontWeight:
                            FontWeight.bold,
                            color:
                            AppColors.darkNavy,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 60),

                  // ==================================================
                  // ICON
                  // ==================================================

                  Center(
                    child: Container(
                      width: 150,
                      height: 150,

                      decoration:
                      BoxDecoration(
                        color:
                        const Color(
                          0xffDCECB8,
                        ),

                        shape:
                        BoxShape.circle,

                        border:
                        Border.all(
                          color:
                          AppColors
                              .darkNavy,
                          width: 3,
                        ),
                      ),

                      child: const Icon(
                        Icons
                            .lock_outline_rounded,

                        size: 80,

                        color:
                        AppColors
                            .darkNavy,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ==================================================
                  // TITLE
                  // ==================================================

                  Center(
                    child: Text(
                      t('forgot_password'),

                      textAlign:
                      TextAlign.center,

                      style:
                      const TextStyle(
                        fontSize: 32,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        AppColors
                            .darkNavy,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ==================================================
                  // DESCRIPTION
                  // ==================================================

                  Center(
                    child: Text(
                      t(
                        'select_verification_method',
                      ),

                      textAlign:
                      TextAlign.center,

                      style:
                      const TextStyle(
                        fontSize: 16,
                        color:
                        Colors.grey,
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ==================================================
                  // EMAIL LABEL
                  // ==================================================

                  Text(
                    t('email_address'),

                    style:
                    const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                      color:
                      AppColors.darkNavy,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ==================================================
                  // EMAIL FIELD
                  // ==================================================

                  TextFormField(
                    controller:
                    emailController,

                    enabled:
                    !authController.isLoading,

                    keyboardType:
                    TextInputType
                        .emailAddress,

                    textInputAction:
                    TextInputAction.done,

                    validator: (value) {
                      return authController
                          .validateEmail(
                        value ?? '',
                      );
                    },

                    onFieldSubmitted: (_) {
                      if (!authController
                          .isLoading) {
                        _handleNext(
                          authController,
                        );
                      }
                    },

                    decoration:
                    InputDecoration(
                      hintText:
                      t('enter_email'),

                      prefixIcon:
                      const Icon(
                        Icons
                            .email_outlined,
                        color:
                        AppColors
                            .darkNavy,
                      ),

                      filled: true,

                      fillColor:
                      Colors.white,

                      contentPadding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 20,
                        vertical: 20,
                      ),

                      border:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),

                        borderSide:
                        BorderSide(
                          color: Colors
                              .grey
                              .shade300,
                        ),
                      ),

                      enabledBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),

                        borderSide:
                        BorderSide(
                          color: Colors
                              .grey
                              .shade300,
                        ),
                      ),

                      focusedBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),

                        borderSide:
                        const BorderSide(
                          color:
                          AppColors
                              .secondary,
                          width: 2,
                        ),
                      ),

                      errorBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),

                        borderSide:
                        const BorderSide(
                          color:
                          Colors.red,
                        ),
                      ),

                      focusedErrorBorder:
                      OutlineInputBorder(
                        borderRadius:
                        BorderRadius
                            .circular(
                          14,
                        ),

                        borderSide:
                        const BorderSide(
                          color:
                          Colors.red,
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ==================================================
                  // ERROR MESSAGE
                  // ==================================================

                  if (authController
                      .errorMessage !=
                      null)
                    Padding(
                      padding:
                      const EdgeInsets
                          .only(
                        bottom: 15,
                      ),

                      child: Text(
                        authController
                            .errorMessage!,

                        textAlign:
                        TextAlign.center,

                        style:
                        const TextStyle(
                          color:
                          Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ),

                  // ==================================================
                  // NEXT BUTTON
                  // ==================================================

                  SizedBox(
                    width:
                    double.infinity,

                    height: 58,

                    child:
                    ElevatedButton(
                      style:
                      ElevatedButton
                          .styleFrom(
                        backgroundColor:
                        AppColors
                            .secondary,

                        disabledBackgroundColor:
                        AppColors
                            .secondary
                            .withOpacity(
                          0.5,
                        ),

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
                          : () {
                        _handleNext(
                          authController,
                        );
                      },

                      child:
                      authController
                          .isLoading
                          ? const SizedBox(
                        width: 25,
                        height: 25,

                        child:
                        CircularProgressIndicator(
                          strokeWidth:
                          2.5,

                          valueColor:
                          AlwaysStoppedAnimation<
                              Color>(
                            Colors
                                .white,
                          ),
                        ),
                      )
                          : Text(
                        t('next'),

                        style:
                        const TextStyle(
                          fontSize:
                          20,
                          fontWeight:
                          FontWeight
                              .bold,
                          color:
                          Colors
                              .white,
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
    );
  }
}