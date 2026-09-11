import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import '../verification/verification_method_screen.dart';

class PlayerRegisterScreen extends StatefulWidget {
  const PlayerRegisterScreen({super.key});

  @override
  State<PlayerRegisterScreen> createState() =>
      _PlayerRegisterScreenState();
}

class _PlayerRegisterScreenState extends State<PlayerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  final TextEditingController _phoneController =
  TextEditingController();

  final TextEditingController _cityController =
  TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();

    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerificationMethodScreen(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          city: _cityController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),

      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
            color: const Color(0xff1E1446),
          ),
        ),

        title: Text(
          t('player_register'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 15),

                // ==================================================
                // PLAYER IMAGE
                // ==================================================

                Hero(
                  tag: 'player_register_image',

                  child: Image.asset(
                    'assets/images/player.png',
                    height: 180,
                    fit: BoxFit.contain,

                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return const Icon(
                        Icons.person,
                        size: 130,
                        color: Color(0xff7CC000),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 25),

                // ==================================================
                // TITLE
                // ==================================================

                Text(
                  t('register_as_player'),
                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1E1446),
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  t('register_player_desc'),
                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // FULL NAME
                // ==================================================

                _buildLabel(
                  t('full_name'),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _nameController,

                  textInputAction:
                  TextInputAction.next,

                  decoration: _inputDecoration(
                    hint: t('enter_full_name'),
                    icon: Icons.person_outline,
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return t('name_required');
                    }

                    if (value.trim().length < 3) {
                      return t('name_too_short');
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // EMAIL
                // ==================================================

                _buildLabel(
                  t('email'),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _emailController,

                  keyboardType:
                  TextInputType.emailAddress,

                  textInputAction:
                  TextInputAction.next,

                  decoration: _inputDecoration(
                    hint: t('enter_email'),
                    icon: Icons.email_outlined,
                  ),

                  validator: (value) {
                    final email =
                        value?.trim() ?? '';

                    if (email.isEmpty) {
                      return t('email_required');
                    }

                    final regex = RegExp(
                      r'^[\w\.\-]+@([\w\-]+\.)+[\w\-]{2,}$',
                    );

                    if (!regex.hasMatch(email)) {
                      return t('invalid_email');
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // PHONE
                // ==================================================

                _buildLabel(
                  t('phone'),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _phoneController,

                  keyboardType:
                  TextInputType.phone,

                  textInputAction:
                  TextInputAction.next,

                  decoration: _inputDecoration(
                    hint: t('enter_phone'),
                    icon: Icons.phone_outlined,
                  ),

                  validator: (value) {
                    final phone =
                        value?.trim() ?? '';

                    if (phone.isEmpty) {
                      return t('phone_required');
                    }

                    if (phone.length < 10) {
                      return t('invalid_phone');
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 18),

                // ==================================================
                // CITY
                // ==================================================

                _buildLabel(
                  t('city'),
                ),

                const SizedBox(height: 8),

                TextFormField(
                  controller: _cityController,

                  textInputAction:
                  TextInputAction.done,

                  decoration: _inputDecoration(
                    hint: t('enter_city'),
                    icon: Icons.location_city_outlined,
                  ),

                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return t('city_required');
                    }

                    return null;
                  },

                  onFieldSubmitted: (_) {
                    _continue();
                  },
                ),

                const SizedBox(height: 30),

                // ==================================================
                // CONTINUE
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 58,

                  child: ElevatedButton(
                    onPressed: _continue,

                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xff7CC000),

                      elevation: 0,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                    ),

                    child: Text(
                      t('continue'),

                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
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
    );
  }

  // ================================================================
  // LABEL
  // ================================================================

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Color(0xff1E1446),
      ),
    );
  }

  // ================================================================
  // INPUT DECORATION
  // ================================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,

      prefixIcon: Icon(
        icon,
        color: const Color(0xff7CC000),
      ),

      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xff7CC000),
          width: 2,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2,
        ),
      ),
    );
  }
}