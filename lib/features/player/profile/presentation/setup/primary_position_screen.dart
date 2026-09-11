import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e7m/shared/localization/language_provider.dart';

import 'player_level_screen.dart';

class PrimaryPositionScreen extends StatefulWidget {
  final String fullName;
  final int age;
  final int height;
  final int weight;
  final String city;
  final String bio;

  const PrimaryPositionScreen({
    super.key,
    required this.fullName,
    required this.age,
    required this.height,
    required this.weight,
    required this.city,
    required this.bio,
  });

  @override
  State<PrimaryPositionScreen> createState() =>
      _PrimaryPositionScreenState();
}

class _PrimaryPositionScreenState extends State<PrimaryPositionScreen> {
  // القيمة التي سيتم إرسالها إلى Backend.
  String selectedPosition = 'forward';

  static const Color backgroundColor = Color(0xffF7F7F3);
  static const Color primaryGreen = Color(0xff7CC000);
  static const Color darkNavy = Color(0xff1E1446);

  // Backend values + localization keys.
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
          t('primary_position'),
          style: const TextStyle(
            color: darkNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
            color: darkNavy,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t('step_3_of_4'),
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t('select_main_position'),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 220,
              child: Stack(
                children: [
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/football_field_hd.png',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  _buildPositionPoint(
                    'goalkeeper',
                    25,
                    95,
                  ),

                  _buildPositionPoint(
                    'defender',
                    110,
                    95,
                  ),

                  _buildPositionPoint(
                    'midfielder',
                    190,
                    95,
                  ),

                  _buildPositionPoint(
                    'forward',
                    285,
                    95,
                  ),
                ],
              ),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.black.withOpacity(0.05),
                ),
              ),
              child: Text(
                '${t('selected_position')}: '
                    '${t(_positionTranslationKeys[selectedPosition] ?? 'fwd')}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: darkNavy,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _continueToNextStep,
                child: Text(
                  t('next'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionPoint(
      String position,
      double left,
      double top,
      ) {
    final isSelected = selectedPosition == position;

    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedPosition = position;
          });
        },
        child: AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: isSelected ? 1.3 : 1.0,
          child: Container(
            width: isSelected ? 34 : 28,
            height: isSelected ? 34 : 28,
            decoration: BoxDecoration(
              color: isSelected ? primaryGreen : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryGreen,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                BoxShadow(
                  color: primaryGreen.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
                  : null,
            ),
            child: Icon(
              Icons.sports_soccer,
              size: isSelected ? 18 : 14,
              color: isSelected ? Colors.white : primaryGreen,
            ),
          ),
        ),
      ),
    );
  }

  void _continueToNextStep() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlayerLevelScreen(
          fullName: widget.fullName,
          age: widget.age,
          height: widget.height,
          weight: widget.weight,
          city: widget.city,
          bio: widget.bio,
          position: selectedPosition,
        ),
      ),
    );
  }
}