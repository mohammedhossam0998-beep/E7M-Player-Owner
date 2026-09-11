import 'package:flutter/material.dart';

class StadiumRating extends StatelessWidget {
  final double? rating;
  final int? reviewCount;
  final double size;
  final bool showValue;
  final bool showReviewCount;

  const StadiumRating({
    super.key,
    this.rating,
    this.reviewCount,
    this.size = 18,
    this.showValue = true,
    this.showReviewCount = true,
  });

  static const Color starColor = Color(0xFFFFB800);
  static const Color textColor = Color(0xFF1E1446);

  @override
  Widget build(BuildContext context) {
    final hasRating =
        rating != null && rating! > 0;

    if (!hasRating) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star_border_rounded,
            size: size,
            color: Colors.grey.shade400,
          ),
          const SizedBox(width: 5),
          Text(
            'No ratings yet',
            style: TextStyle(
              fontSize: size * 0.72,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      );
    }

    final normalizedRating =
    rating!.clamp(0.0, 5.0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStars(normalizedRating),

        if (showValue) ...[
          const SizedBox(width: 6),
          Text(
            normalizedRating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.78,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],

        if (showReviewCount &&
            reviewCount != null) ...[
          const SizedBox(width: 4),
          Text(
            '(${reviewCount!})',
            style: TextStyle(
              fontSize: size * 0.68,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStars(double value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
            (index) {
          final starValue = index + 1;

          IconData icon;

          if (value >= starValue) {
            icon = Icons.star_rounded;
          } else if (value >= starValue - 0.5) {
            icon = Icons.star_half_rounded;
          } else {
            icon = Icons.star_border_rounded;
          }

          return Icon(
            icon,
            size: size,
            color: starColor,
          );
        },
      ),
    );
  }
}