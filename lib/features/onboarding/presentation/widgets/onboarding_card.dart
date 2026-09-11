import 'package:flutter/material.dart';
import '../../models/onboarding_model.dart';
import 'package:e7m/core/theme/app_colors.dart';

class OnboardingCard extends StatelessWidget {
  final OnboardingModel item;

  const OnboardingCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // 3 & 4. استخدام الـ Theme لسهولة دعم الـ Dark Mode وتوحيد الخط
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AspectRatio(
            aspectRatio: 1,
            // 2 & 6. إزالة FilterQuality غير الضروري وإضافة semanticLabel
            child: Image.asset(
              item.image,
              fit: BoxFit.contain,
              semanticLabel: item.titleKey,
            ),
          ),
          const SizedBox(height: 25),
          Text(
            item.titleKey, // مفتاح الترجمة
            textAlign: TextAlign.center,
            // 7. استخدام style ديناميكي يتجاوب مع إعدادات النظام
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Text(
              item.descriptionKey, // مفتاح الترجمة
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
