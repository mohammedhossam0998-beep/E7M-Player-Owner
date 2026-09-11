import 'package:flutter/material.dart';
import 'package:e7m/shared/localization/language_provider.dart';
import 'package:provider/provider.dart';

import 'profile_setup_screen.dart';

class PlayerProfileSetupScreen extends StatefulWidget {
  const PlayerProfileSetupScreen({super.key});

  @override
  State<PlayerProfileSetupScreen> createState() =>
      _PlayerProfileSetupScreenState();
}

class _PlayerProfileSetupScreenState
    extends State<PlayerProfileSetupScreen> {
  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  // ============================================================
  // DATA
  // ============================================================

  String _city = 'Cairo';

  // ============================================================
  // COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xffF7F7F3);
  static const Color primaryGreen = Color(0xff7CC000);
  static const Color darkNavy = Color(0xff1E1446);

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _bioController.dispose();

    super.dispose();
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final t = context.read<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
            color: darkNavy,
          ),
        ),

        title: Text(
          t('player_profile'),
          style: const TextStyle(
            color: darkNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ====================================================
            // STEP
            // ====================================================

            Text(
              t('step_1_of_4'),
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            // ====================================================
            // TITLE
            // ====================================================

            Text(
              t('register_player_desc'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),

            const SizedBox(height: 8),

            // ====================================================
            // DESCRIPTION
            // ====================================================

            Text(
              t('discover_you'),
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 25),

            // ====================================================
            // FULL NAME
            // ====================================================

            _buildField(
              controller: _nameController,
              label: t('full_name'),
              icon: Icons.person_outline,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 15),

            // ====================================================
            // AGE
            // ====================================================

            _buildField(
              controller: _ageController,
              label: t('age'),
              icon: Icons.cake_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 15),

            // ====================================================
            // HEIGHT
            // ====================================================

            _buildField(
              controller: _heightController,
              label: '${t('height')} (cm)',
              icon: Icons.height,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 15),

            // ====================================================
            // WEIGHT
            // ====================================================

            _buildField(
              controller: _weightController,
              label: '${t('weight')} (kg)',
              icon: Icons.monitor_weight_outlined,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
            ),

            const SizedBox(height: 15),

            // ====================================================
            // CITY
            // ====================================================

            DropdownButtonFormField<String>(
              value: _city,

              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: primaryGreen,
                    width: 1.5,
                  ),
                ),
              ),

              items: [
                DropdownMenuItem(
                  value: 'Cairo',
                  child: Text(t('cairo')),
                ),
                DropdownMenuItem(
                  value: 'Alexandria',
                  child: Text(t('alexandria')),
                ),
                DropdownMenuItem(
                  value: 'Giza',
                  child: Text(t('giza')),
                ),
              ],

              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _city = value;
                });
              },
            ),

            const SizedBox(height: 15),

            // ====================================================
            // BIO
            // ====================================================

            TextField(
              controller: _bioController,
              maxLines: 4,
              textInputAction: TextInputAction.newline,

              decoration: InputDecoration(
                labelText: t('about_me'),
                alignLabelWithHint: true,

                filled: true,
                fillColor: Colors.white,

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Colors.grey.shade300,
                  ),
                ),

                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: primaryGreen,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // ====================================================
            // PROFILE PREVIEW
            // ====================================================

            _buildProfilePreview(t),

            const SizedBox(height: 30),

            // ====================================================
            // NEXT BUTTON
            // ====================================================

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _continueToNextStep,

                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,

                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                child: Text(
                  t('next'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // TEXT FIELD
  // ============================================================

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction? textInputAction,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,

      decoration: InputDecoration(
        labelText: label,

        prefixIcon: Icon(icon),

        filled: true,
        fillColor: Colors.white,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: primaryGreen,
            width: 1.5,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE PREVIEW
  // ============================================================

  Widget _buildProfilePreview(
      String Function(String key) t,
      ) {
    final name = _nameController.text.trim();
    final age = _ageController.text.trim();
    final height = _heightController.text.trim();
    final weight = _weightController.text.trim();

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            t('stats'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: darkNavy,
            ),
          ),

          const SizedBox(height: 12),

          _previewRow(
            '${t('full_name')}:',
            name.isEmpty ? '-' : name,
          ),

          _previewRow(
            '${t('age')}:',
            age.isEmpty ? '-' : age,
          ),

          _previewRow(
            '${t('height')}:',
            height.isEmpty ? '-' : '$height cm',
          ),

          _previewRow(
            '${t('weight')}:',
            weight.isEmpty ? '-' : '$weight kg',
          ),

          _previewRow(
            '${t('governorate_city')}:',
            t(_city.toLowerCase()),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PREVIEW ROW
  // ============================================================

  Widget _previewRow(
      String label,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        '$label $value',
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
        ),
      ),
    );
  }

  // ============================================================
  // CONTINUE
  // ============================================================

  void _continueToNextStep() {
    final t = context.read<LanguageProvider>().translate;

    final name = _nameController.text.trim();
    final age = _ageController.text.trim();
    final height = _heightController.text.trim();
    final weight = _weightController.text.trim();
    final bio = _bioController.text.trim();

    // ----------------------------------------------------------
    // NAME VALIDATION
    // ----------------------------------------------------------

    if (name.isEmpty) {
      _showMessage(t('enter_name'));
      return;
    }

    // ----------------------------------------------------------
    // AGE VALIDATION
    // ----------------------------------------------------------

    final parsedAge = int.tryParse(age);

    if (age.isEmpty || parsedAge == null || parsedAge <= 0) {
      _showMessage(t('enter_age'));
      return;
    }

    // ----------------------------------------------------------
    // HEIGHT VALIDATION
    // ----------------------------------------------------------

    final parsedHeight = int.tryParse(height);

    if (height.isEmpty || parsedHeight == null || parsedHeight <= 0) {
      _showMessage(t('enter_height'));
      return;
    }

    // ----------------------------------------------------------
    // WEIGHT VALIDATION
    // ----------------------------------------------------------

    final parsedWeight = int.tryParse(weight);

    if (weight.isEmpty || parsedWeight == null || parsedWeight <= 0) {
      _showMessage(t('enter_weight'));
      return;
    }

    // ----------------------------------------------------------
    // NEXT SCREEN
    // ----------------------------------------------------------

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileSetupScreen(
          fullName: name,
          age: parsedAge,
          height: parsedHeight,
          weight: parsedWeight,
          city: _city,
          bio: bio,
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }
}