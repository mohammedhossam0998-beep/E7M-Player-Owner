import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';

class TeamEmptyState extends StatelessWidget {
  final String? title;
  final String? message;
  final String? buttonText;
  final VoidCallback? onRetry;
  final IconData icon;

  const TeamEmptyState({
    super.key,
    this.title,
    this.message,
    this.buttonText,
    this.onRetry,
    this.icon = Icons.groups_outlined,
  });

  static const Color primaryGreen =
  Color(0xff7CC000);

  static const Color darkNavy =
  Color(0xff1E1446);

  @override
  Widget build(BuildContext context) {
    final t =
        context.read<LanguageProvider>().translate;

    final resolvedTitle =
        title ?? t('no_teams_found');

    final resolvedMessage =
        message ?? t('try_adjusting_search');

    final resolvedButtonText =
        buttonText ?? t('try_again');

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            // ======================================================
            // ICON
            // ======================================================

            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color:
                primaryGreen.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: primaryGreen,
              ),
            ),

            const SizedBox(height: 20),

            // ======================================================
            // TITLE
            // ======================================================

            Text(
              resolvedTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: darkNavy,
              ),
            ),

            const SizedBox(height: 8),

            // ======================================================
            // MESSAGE
            // ======================================================

            ConstrainedBox(
              constraints:
              const BoxConstraints(
                maxWidth: 340,
              ),
              child: Text(
                resolvedMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color:
                  Colors.grey.shade600,
                ),
              ),
            ),

            // ======================================================
            // RETRY BUTTON
            // ======================================================

            if (onRetry != null) ...[
              const SizedBox(height: 20),

              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 19,
                ),
                label: Text(
                  resolvedButtonText,
                ),
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  primaryGreen,
                  foregroundColor:
                  Colors.white,
                  elevation: 0,
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(13),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}