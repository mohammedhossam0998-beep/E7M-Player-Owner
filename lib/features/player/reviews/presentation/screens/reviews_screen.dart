import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/review_provider.dart';

class ReviewsScreen extends StatefulWidget {
  final String pitchId;
  final String? pitchName;

  const ReviewsScreen({
    super.key,
    required this.pitchId,
    this.pitchName,
  });

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  static const Color primaryGreen = Color(0xFF7CC000);
  static const Color darkNavy = Color(0xFF1E1446);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ReviewProvider>().loadPitchReviews(widget.pitchId);
    });
  }

  Future<void> _retry() async {
    await context.read<ReviewProvider>().loadPitchReviews(widget.pitchId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: darkNavy,
        centerTitle: true,
        title: Text(
          widget.pitchName?.trim().isNotEmpty == true
              ? 'Reviews'
              : 'Reviews',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: darkNavy,
          ),
        ),
      ),
      body: Consumer<ReviewProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && !provider.hasReviews) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
              ),
            );
          }

          if (provider.errorMessage != null && !provider.hasReviews) {
            return _ErrorState(
              message: provider.errorMessage!,
              onRetry: _retry,
            );
          }

          return RefreshIndicator(
            color: primaryGreen,
            onRefresh: _retry,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _RatingSummary(
                    averageRating: provider.averageRating,
                    totalReviews: provider.totalReviews,
                  ),
                ),

                if (!provider.hasReviews)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyReviewsState(),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      24,
                    ),
                    sliver: SliverList.separated(
                      itemCount: provider.reviews.length,
                      separatorBuilder: (_, __) {
                        return const SizedBox(height: 12);
                      },
                      itemBuilder: (context, index) {
                        final review = provider.reviews[index];

                        return _ReviewCard(
                          playerName: review.playerName,
                          rating: review.rating,
                          comment: review.comment,
                          createdAt: review.createdAt,
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// RATING SUMMARY
// ============================================================

class _RatingSummary extends StatelessWidget {
  final double averageRating;
  final int totalReviews;

  const _RatingSummary({
    required this.averageRating,
    required this.totalReviews,
  });

  static const Color primaryGreen = Color(0xFF7CC000);
  static const Color darkNavy = Color(0xFF1E1446);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            blurRadius: 18,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.06),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Overall Rating',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkNavy,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            averageRating.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: darkNavy,
            ),
          ),

          const SizedBox(height: 6),

          _StarRating(
            rating: averageRating,
            size: 25,
          ),

          const SizedBox(height: 8),

          Text(
            '$totalReviews ${totalReviews == 1 ? 'Review' : 'Reviews'}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            height: 4,
            width: 80,
            decoration: BoxDecoration(
              color: primaryGreen,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REVIEW CARD
// ============================================================

class _ReviewCard extends StatelessWidget {
  final String playerName;
  final int rating;
  final String? comment;
  final DateTime? createdAt;

  const _ReviewCard({
    required this.playerName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  static const Color darkNavy = Color(0xFF1E1446);
  static const Color primaryGreen = Color(0xFF7CC000);

  @override
  Widget build(BuildContext context) {
    final name = playerName.trim().isEmpty
        ? 'Player'
        : playerName.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: primaryGreen,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: darkNavy,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 5),

                    _StarRating(
                      rating: rating.toDouble(),
                      size: 17,
                    ),
                  ],
                ),
              ),

              if (createdAt != null)
                Text(
                  _formatDate(createdAt!),
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),

          if (comment != null && comment!.trim().isNotEmpty) ...[
            const SizedBox(height: 14),

            Text(
              comment!.trim(),
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }
}

// ============================================================
// STAR RATING
// ============================================================

class _StarRating extends StatelessWidget {
  final double rating;
  final double size;

  const _StarRating({
    required this.rating,
    this.size = 20,
  });

  static const Color starColor = Color(0xFFFFB800);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final starNumber = index + 1;

        IconData icon;

        if (rating >= starNumber) {
          icon = Icons.star_rounded;
        } else if (rating >= starNumber - 0.5) {
          icon = Icons.star_half_rounded;
        } else {
          icon = Icons.star_border_rounded;
        }

        return Icon(
          icon,
          size: size,
          color: starColor,
        );
      }),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyReviewsState extends StatelessWidget {
  const _EmptyReviewsState();

  static const Color darkNavy = Color(0xFF1E1446);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.rate_review_outlined,
              size: 58,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No reviews yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkNavy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first player to review this stadium.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  static const Color darkNavy = Color(0xFF1E1446);
  static const Color primaryGreen = Color(0xFF7CC000);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Colors.grey.shade500,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: darkNavy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}