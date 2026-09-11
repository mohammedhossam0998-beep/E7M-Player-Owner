import 'package:flutter/material.dart';
import 'package:e7m/core/theme/app_colors.dart';
import 'package:e7m/core/theme/app_spacing.dart';
import 'package:e7m/core/theme/app_text_styles.dart';

class ReceiptDialog extends StatelessWidget {
  final String stadiumName;
  final String date;
  final String time;
  final double price;

  const ReceiptDialog({
    super.key,
    required this.stadiumName,
    required this.date,
    required this.time,
    required this.price,
  });

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
            const Icon(Icons.receipt_long, size: 50, color: AppColors.primary),
            const SizedBox(height: AppSpacing.sm),
            const Text("تفاصيل الحجز", style: AppTextStyles.titleLarge),
            const SizedBox(height: AppSpacing.xl),
            _buildRow("الملعب", stadiumName),
            _buildRow("التاريخ", date),
            _buildRow("الوقت", time),
            _buildRow("السعر", "${price.toStringAsFixed(0)} جنيه"),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("تمام"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}