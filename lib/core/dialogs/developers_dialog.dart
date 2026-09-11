import 'package:flutter/material.dart';
import 'package:e7m/core/theme/app_colors.dart';
import 'package:e7m/core/theme/app_spacing.dart';
import 'package:e7m/core/theme/app_text_styles.dart';

class DevelopersDialog extends StatelessWidget {
  const DevelopersDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.code, size: 50, color: AppColors.primary),
            const SizedBox(height: AppSpacing.sm),
            const Text("فريق التطوير", style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.xl),
            _dev("Mohamed Hossam"),
            _dev("Flutter Developer"),
            _dev("AI Integration"),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إغلاق"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dev(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text),
    );
  }
}
