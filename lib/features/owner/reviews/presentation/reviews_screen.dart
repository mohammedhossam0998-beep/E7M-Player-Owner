import 'package:e7m/shared/localization/language_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/owner_review_provider.dart';
import '../models/owner_review_model.dart';

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerReviewProvider>().loadReviews();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<LanguageProvider>();
    final isArabic = lp.currentLocale.languageCode == 'ar';

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            lp.translate('reviews_title'),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
        ),
        body: Consumer<OwnerReviewProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading && provider.reviews.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF7CC000),
                ),
              );
            }

            if (provider.errorMessage != null &&
                provider.reviews.isEmpty) {
              return _ErrorState(
                lp: lp,
                message: provider.errorMessage!,
                onRetry: provider.loadReviews,
              );
            }

            return RefreshIndicator(
              color: const Color(0xFF7CC000),
              onRefresh: provider.refreshReviews,
              child: provider.reviews.isEmpty
                  ? _EmptyState(lp: lp)
                  : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _SummaryCard(
                    lp: lp,
                    provider: provider,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    lp.translate('customer_reviews'),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  ...provider.reviews.map(
                        (review) => Padding(
                      padding:
                      const EdgeInsets.only(bottom: 12),
                      child: _ReviewCard(
                        lp: lp,
                        review: review,
                        provider: provider,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// SUMMARY CARD
// ============================================================

class _SummaryCard extends StatelessWidget {
  final LanguageProvider lp;
  final OwnerReviewProvider provider;

  const _SummaryCard({
    required this.lp,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            lp.translate('overall_rating'),
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                provider.averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.star_rounded,
                size: 34,
                color: Color(0xFFFFB300),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  value: provider.count.toString(),
                  label: lp.translate('total'),
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  value: provider.visibleCount.toString(),
                  label: lp.translate('visible'),
                ),
              ),
              Expanded(
                child: _SummaryItem(
                  value: provider.hiddenCount.toString(),
                  label: lp.translate('hidden'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SUMMARY ITEM
// ============================================================

class _SummaryItem extends StatelessWidget {
  final String value;
  final String label;

  const _SummaryItem({
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// REVIEW CARD
// ============================================================

class _ReviewCard extends StatelessWidget {
  final LanguageProvider lp;
  final OwnerReviewModel review;
  final OwnerReviewProvider provider;

  const _ReviewCard({
    required this.lp,
    required this.review,
    required this.provider,
  });

  @override
  Widget build(BuildContext context) {
    final bool isHidden = review.isHidden;

    final bool isLoading =
        provider.isActionLoading &&
            provider.actionReviewId == review.id;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isHidden
            ? Border.all(
          color: Colors.grey.shade300,
        )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ----------------------------------------------------
          // PLAYER INFO
          // ----------------------------------------------------

          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: const Color(0xFFF0F2F4),
                backgroundImage:
                review.playerProfileImage != null &&
                    review.playerProfileImage!
                        .isNotEmpty
                    ? NetworkImage(
                  review.playerProfileImage!,
                )
                    : null,
                child:
                review.playerProfileImage == null ||
                    review.playerProfileImage!
                        .isEmpty
                    ? const Icon(
                  Icons.person,
                  color: Colors.grey,
                )
                    : null,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.playerName ??
                          lp.translate('default_player_name'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    if (review.playerEmail != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        review.playerEmail!,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              if (isHidden)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    lp.translate('hidden_badge'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 14),

          // ----------------------------------------------------
          // PITCH
          // ----------------------------------------------------

          Row(
            children: [
              const Icon(
                Icons.sports_soccer,
                size: 17,
                color: Color(0xFF7CC000),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  review.pitchName ??
                      lp.translate('default_pitch_name'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ----------------------------------------------------
          // RATING
          // ----------------------------------------------------

          Row(
            children: [
              ...List.generate(
                5,
                    (index) {
                  return Icon(
                    index < review.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    size: 21,
                    color: const Color(0xFFFFB300),
                  );
                },
              ),

              const SizedBox(width: 8),

              Text(
                '${review.rating}/5',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          // ----------------------------------------------------
          // COMMENT
          // ----------------------------------------------------

          if (review.comment != null &&
              review.comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // ----------------------------------------------------
          // DATE + ACTION
          // ----------------------------------------------------

          Row(
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: Colors.grey.shade500,
              ),

              const SizedBox(width: 5),

              Text(
                _formatDate(review.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),

              const Spacer(),

              TextButton.icon(
                onPressed: isLoading
                    ? null
                    : () async {
                  final success = isHidden
                      ? await provider.unhideReview(
                    review.id,
                  )
                      : await provider.hideReview(
                    review.id,
                  );

                  if (!context.mounted) return;

                  if (!success &&
                      provider.errorMessage != null) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      SnackBar(
                        content: Text(
                          provider.errorMessage!,
                        ),
                      ),
                    );
                  }
                },
                icon: isLoading
                    ? const SizedBox(
                  width: 16,
                  height: 16,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF7CC000),
                  ),
                )
                    : Icon(
                  isHidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 18,
                ),
                label: Text(
                  isHidden
                      ? lp.translate('unhide')
                      : lp.translate('hide'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day/$month/$year';
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyState extends StatelessWidget {
  final LanguageProvider lp;

  const _EmptyState({required this.lp});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 180),
        const Icon(
          Icons.rate_review_outlined,
          size: 60,
          color: Colors.grey,
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            lp.translate('no_reviews_title'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            lp.translate('no_reviews_subtitle'),
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

class _ErrorState extends StatelessWidget {
  final LanguageProvider lp;
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.lp,
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.redAccent,
            ),

            const SizedBox(height: 16),

            Text(
              lp.translate('something_went_wrong'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF7CC000),
                foregroundColor: Colors.white,
              ),
              child: Text(lp.translate('retry')),
            ),
          ],
        ),
      ),
    );
  }
}