import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/onboarding_controller.dart';
import 'package:e7m/app/routes/route_names.dart';
import 'package:e7m/core/theme/app_colors.dart';

class SkipButton extends StatelessWidget {
  const SkipButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
    context.read<OnboardingController>();

    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
      ),
      onPressed: () async {
        // ------------------------------------------------------
        // Save onboarding as completed
        // ------------------------------------------------------

        await controller.skip();

        if (!context.mounted) return;

        // ------------------------------------------------------
        // Correct flow:
        //
        // Onboarding
        //      ↓
        // Language
        // ------------------------------------------------------

        Navigator.pushReplacementNamed(
          context,
          RouteNames.language,
        );
      },
      child: const Text(
        'skip_label',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}