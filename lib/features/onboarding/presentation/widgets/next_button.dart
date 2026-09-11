import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controller/onboarding_controller.dart';
import 'package:e7m/app/routes/route_names.dart';
import 'package:e7m/core/theme/app_colors.dart';

class NextButton extends StatelessWidget {
  const NextButton({super.key});

  @override
  Widget build(BuildContext context) {
    final isLastPage = context.select(
          (OnboardingController controller) =>
      controller.isLastPage,
    );

    return isLastPage
        ? _buildGetStartedButton(context)
        : _buildNextIconButton(context);
  }

  // ============================================================
  // GET STARTED
  // ============================================================

  Widget _buildGetStartedButton(
      BuildContext context,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 58,
      child: ElevatedButton(
        onPressed: () async {
          // ----------------------------------------------------
          // Mark onboarding as completed
          // ----------------------------------------------------

          await context
              .read<OnboardingController>()
              .markOnboardingAsCompleted();

          if (!context.mounted) return;

          // ----------------------------------------------------
          // Correct flow:
          //
          // Onboarding
          //      ↓
          // Language
          // ----------------------------------------------------

          Navigator.pushReplacementNamed(
            context,
            RouteNames.language,
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text(
          'start_now',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // NEXT
  // ============================================================

  Widget _buildNextIconButton(
      BuildContext context,
      ) {
    return Semantics(
      label: 'Next page',
      button: true,
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              blurRadius: 15,
              color: Colors.black12,
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () {
              context
                  .read<OnboardingController>()
                  .nextPage();
            },
            child: const Icon(
              Icons.arrow_forward,
              color: AppColors.secondary,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}