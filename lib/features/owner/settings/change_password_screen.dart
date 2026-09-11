import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'services/change_password_service.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  final currentController =
  TextEditingController();

  final newController =
  TextEditingController();

  final confirmController =
  TextEditingController();

  final ChangePasswordService _service =
  ChangePasswordService();

  bool hideCurrent = true;
  bool hideNew = true;
  bool hideConfirm = true;

  bool loading = false;

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();

    super.dispose();
  }

  // ============================================================
  // UPDATE PASSWORD
  // ============================================================

  Future<void> updatePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
    });

    try {
      await _service.changePassword(
        currentPassword:
        currentController.text.trim(),
        newPassword:
        newController.text,
        confirmPassword:
        confirmController.text,
      );

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      final languageProvider =
      context.read<LanguageProvider>();

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius:
              BorderRadius.circular(20),
            ),
            title: Text(
              languageProvider.translate(
                'success',
              ),
            ),
            content: Text(
              languageProvider.translate(
                'password_updated_successfully',
              ),
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: Text(
                  languageProvider.translate(
                    'ok',
                  ),
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      final languageProvider =
      context.read<LanguageProvider>();

      final errorMessage =
      _cleanErrorMessage(e);

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              _translateError(
                errorMessage,
                languageProvider,
              ),
            ),
            backgroundColor: Colors.red,
            behavior:
            SnackBarBehavior.floating,
          ),
        );
    }
  }

  // ============================================================
  // CLEAN ERROR MESSAGE
  // ============================================================

  String _cleanErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }

  // ============================================================
  // ERROR TRANSLATION
  // ============================================================

  String _translateError(
      String message,
      LanguageProvider languageProvider,
      ) {
    switch (message) {
      case 'Current password is incorrect':
        return languageProvider.translate(
          'current_password_incorrect',
        );

      case 'Password must be at least 8 characters':
        return languageProvider.translate(
          'password_min_length',
        );

      case 'Passwords do not match':
        return languageProvider.translate(
          'passwords_do_not_match',
        );

      case 'New password must be different from current password':
        return languageProvider.translate(
          'new_password_must_be_different',
        );

      case 'Unauthorized':
        return languageProvider.translate(
          'unauthorized',
        );

      case 'User not found':
        return languageProvider.translate(
          'user_not_found',
        );

      case 'Account is inactive':
        return languageProvider.translate(
          'account_inactive',
        );

      default:
        return message;
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider =
    context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor:
      const Color(0xffF7F8FA),

      appBar: AppBar(
        title: Text(
          languageProvider.translate(
            'change_password',
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: ListView(
            padding:
            const EdgeInsets.all(20),

            children: [
              const SizedBox(height: 10),

              // ==================================================
              // CURRENT PASSWORD
              // ==================================================

              Text(
                languageProvider.translate(
                  'current_password',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: currentController,
                obscureText: hideCurrent,
                enabled: !loading,

                decoration:
                InputDecoration(
                  hintText:
                  languageProvider
                      .translate(
                    'enter_current_password',
                  ),

                  prefixIcon:
                  const Icon(
                    Icons.lock_outline,
                  ),

                  suffixIcon:
                  IconButton(
                    icon: Icon(
                      hideCurrent
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: loading
                        ? null
                        : () {
                      setState(() {
                        hideCurrent =
                        !hideCurrent;
                      });
                    },
                  ),

                  filled: true,
                  fillColor:
                  Colors.white,

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                    borderSide:
                    BorderSide.none,
                  ),
                ),

                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return languageProvider
                        .translate(
                      'current_password_required',
                    );
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // NEW PASSWORD
              // ==================================================

              Text(
                languageProvider.translate(
                  'new_password',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller: newController,
                obscureText: hideNew,
                enabled: !loading,

                decoration:
                InputDecoration(
                  hintText:
                  languageProvider
                      .translate(
                    'enter_new_password',
                  ),

                  prefixIcon:
                  const Icon(
                    Icons.lock,
                  ),

                  suffixIcon:
                  IconButton(
                    icon: Icon(
                      hideNew
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: loading
                        ? null
                        : () {
                      setState(() {
                        hideNew =
                        !hideNew;
                      });
                    },
                  ),

                  filled: true,
                  fillColor:
                  Colors.white,

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                    borderSide:
                    BorderSide.none,
                  ),
                ),

                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return languageProvider
                        .translate(
                      'new_password_required',
                    );
                  }

                  if (value.length < 8) {
                    return languageProvider
                        .translate(
                      'password_min_length',
                    );
                  }

                  if (value ==
                      currentController.text) {
                    return languageProvider
                        .translate(
                      'new_password_must_be_different',
                    );
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // ==================================================
              // CONFIRM PASSWORD
              // ==================================================

              Text(
                languageProvider.translate(
                  'confirm_password',
                ),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),

              const SizedBox(height: 8),

              TextFormField(
                controller:
                confirmController,
                obscureText: hideConfirm,
                enabled: !loading,

                decoration:
                InputDecoration(
                  hintText:
                  languageProvider
                      .translate(
                    'confirm_new_password',
                  ),

                  prefixIcon:
                  const Icon(
                    Icons.lock_reset,
                  ),

                  suffixIcon:
                  IconButton(
                    icon: Icon(
                      hideConfirm
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: loading
                        ? null
                        : () {
                      setState(() {
                        hideConfirm =
                        !hideConfirm;
                      });
                    },
                  ),

                  filled: true,
                  fillColor:
                  Colors.white,

                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                    borderSide:
                    BorderSide.none,
                  ),
                ),

                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return languageProvider
                        .translate(
                      'confirm_password_required',
                    );
                  }

                  if (value !=
                      newController.text) {
                    return languageProvider
                        .translate(
                      'passwords_do_not_match',
                    );
                  }

                  return null;
                },
              ),

              const SizedBox(height: 35),

              // ==================================================
              // UPDATE PASSWORD
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton(
                  onPressed:
                  loading
                      ? null
                      : updatePassword,

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(
                      0xff7CC000,
                    ),
                    disabledBackgroundColor:
                    const Color(
                      0xffB8D98A,
                    ),
                    elevation: 0,

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),

                  child: loading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child:
                    CircularProgressIndicator(
                      color:
                      Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .center,
                    children: [
                      const Icon(
                        Icons.security,
                        color:
                        Colors.white,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        languageProvider
                            .translate(
                          'update_password',
                        ),
                        style:
                        const TextStyle(
                          color:
                          Colors.white,
                          fontSize: 17,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // CANCEL
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 55,

                child:
                OutlinedButton(
                  onPressed: loading
                      ? null
                      : () {
                    Navigator.pop(
                      context,
                    );
                  },

                  style:
                  OutlinedButton.styleFrom(
                    side:
                    const BorderSide(
                      color:
                      Color(0xff7CC000),
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        18,
                      ),
                    ),
                  ),

                  child: Text(
                    languageProvider
                        .translate(
                      'cancel',
                    ),
                    style:
                    const TextStyle(
                      color:
                      Color(0xff7CC000),
                      fontWeight:
                      FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // SECURITY TIP
              // ==================================================

              Container(
                padding:
                const EdgeInsets.all(16),

                decoration:
                BoxDecoration(
                  color: Colors.green
                      .withOpacity(.08),
                  borderRadius:
                  BorderRadius.circular(
                    18,
                  ),
                ),

                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,

                  children: [
                    const Icon(
                      Icons.info_outline,
                      color:
                      Color(0xff7CC000),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child: Text(
                        languageProvider
                            .translate(
                          'password_security_tip',
                        ),
                        style:
                        const TextStyle(
                          color:
                          Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}