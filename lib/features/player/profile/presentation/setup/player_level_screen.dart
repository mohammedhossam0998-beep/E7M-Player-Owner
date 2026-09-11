import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e7m/shared/localization/language_provider.dart';

import '../../presentation/providers/player_profile_provider.dart';
import '../screens/player_profile_screen.dart';

class PlayerLevelScreen extends StatefulWidget {
  final String fullName;
  final int age;
  final int height;
  final int weight;
  final String city;
  final String bio;
  final String position;

  const PlayerLevelScreen({
    super.key,
    required this.fullName,
    required this.age,
    required this.height,
    required this.weight,
    required this.city,
    required this.bio,
    required this.position,
  });

  @override
  State<PlayerLevelScreen> createState() => _PlayerLevelScreenState();
}

class _PlayerLevelScreenState extends State<PlayerLevelScreen> {
  String selectedLevel = 'intermediate';
  bool _isSubmitting = false;

  static const Color backgroundColor = Color(0xffF7F7F3);
  static const Color primaryGreen = Color(0xff7CC000);
  static const Color darkNavy = Color(0xff1E1446);

  static const Map<String, String> _positionTranslationKeys = {
    'goalkeeper': 'gk',
    'defender': 'def',
    'midfielder': 'mid',
    'forward': 'fwd',
  };

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t('player_level'),
          style: const TextStyle(
            color: darkNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
            color: darkNavy,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('step_4_of_4'),
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              t('select_player_level'),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t('choose_level_desc'),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 25),

            _buildLevelOption(
              value: 'beginner',
              title: t('beginner'),
              icon: Icons.directions_run,
            ),

            const SizedBox(height: 14),

            _buildLevelOption(
              value: 'intermediate',
              title: t('intermediate'),
              icon: Icons.sports_soccer,
            ),

            const SizedBox(height: 14),

            _buildLevelOption(
              value: 'pro_player',
              title: t('pro_player'),
              icon: Icons.emoji_events_outlined,
            ),

            const SizedBox(height: 30),

            _buildSummary(t),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _finishSetup,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  disabledBackgroundColor:
                  primaryGreen.withOpacity(0.55),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  t('finish'),
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

  Widget _buildLevelOption({
    required String value,
    required String title,
    required IconData icon,
  }) {
    final bool isSelected = selectedLevel == value;

    return GestureDetector(
      onTap: _isSubmitting
          ? null
          : () {
        setState(() {
          selectedLevel = value;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? primaryGreen
                : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: primaryGreen.withOpacity(0.12),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryGreen
                    : primaryGreen.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : primaryGreen,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: darkNavy,
                  fontSize: 17,
                  fontWeight: isSelected
                      ? FontWeight.bold
                      : FontWeight.w600,
                ),
              ),
            ),

            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? primaryGreen
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Center(
                child: Icon(
                  Icons.check,
                  size: 16,
                  color: primaryGreen,
                ),
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(
      String Function(String key) t,
      ) {
    final positionTranslationKey =
    _positionTranslationKeys[widget.position];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.black.withOpacity(0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('profile_summary'),
            style: const TextStyle(
              color: darkNavy,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          _summaryRow(
            t('full_name'),
            widget.fullName,
          ),

          _summaryRow(
            t('age'),
            '${widget.age}',
          ),

          _summaryRow(
            t('height'),
            '${widget.height} cm',
          ),

          _summaryRow(
            t('weight'),
            '${widget.weight} kg',
          ),

          _summaryRow(
            t('governorate_city'),
            widget.city,
          ),

          _summaryRow(
            t('primary_position'),
            positionTranslationKey != null
                ? t(positionTranslationKey)
                : widget.position,
          ),

          _summaryRow(
            t('player_level'),
            t(selectedLevel),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: darkNavy,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishSetup() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    final provider = PlayerProfileProvider();

    try {
      final profileData = <String, dynamic>{
        'position': widget.position,
        'skill_level': selectedLevel,
        'date_of_birth': null,
        'preferred_foot': null,
        'bio': widget.bio.trim().isEmpty
            ? null
            : widget.bio.trim(),
        'height': widget.height,
        'weight': widget.weight,
        'city': widget.city.trim().isEmpty
            ? null
            : widget.city.trim(),
        'experience': null,
        'playing_style': null,
      };

      final success = await provider.createProfile(profileData);

      if (!mounted) {
        provider.dispose();
        return;
      }

      if (success) {
        provider.dispose();

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => const PlayerProfileScreen(),
          ),
              (route) => false,
        );

        return;
      }

      final errorMessage =
          provider.errorMessage ??
              'Failed to create player profile';

      provider.dispose();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) {
        provider.dispose();
        return;
      }

      provider.dispose();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}