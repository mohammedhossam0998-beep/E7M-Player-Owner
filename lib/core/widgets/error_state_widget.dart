import 'package:flutter/material.dart';
import 'package:e7m/core/theme/app_colors.dart';
import 'package:e7m/core/theme/app_spacing.dart';
import 'package:e7m/core/theme/app_text_styles.dart';
import 'package:e7m/core/widgets/custom_button.dart';

class ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorStateWidget({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 60),
            const SizedBox(height: AppSpacing.lg),
            Flexible(
              child: Text(
                message,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (onRetry != null)
              CustomButton(
                text: "إعادة المحاولة",
                onPressed: onRetry!,
              ),
          ],
        ),
      ),
    );
  }
}