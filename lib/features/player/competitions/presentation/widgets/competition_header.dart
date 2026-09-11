import 'package:flutter/material.dart';

class CompetitionHeader extends StatelessWidget {
  const CompetitionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.onViewAll,
    this.viewAllText = 'View All',
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onViewAll;
  final String viewAllText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (subtitle != null &&
                  subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.textTheme.bodyMedium?.color
                        ?.withOpacity(0.65),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (onViewAll != null) ...[
          const SizedBox(width: 12),
          TextButton(
            onPressed: onViewAll,
            child: Text(
              viewAllText,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ],
    );
  }
}