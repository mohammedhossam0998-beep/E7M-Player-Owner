import 'package:e7m/core/network/api_client.dart';

import '../models/review.dart';

class ReviewRepository {
  final ApiClient _apiClient;

  ReviewRepository({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET PITCH REVIEWS
  // ============================================================

  Future<ReviewResult> getPitchReviews(String pitchId) async {
    if (pitchId.trim().isEmpty) {
      throw Exception('Invalid pitch ID');
    }

    final response = await _apiClient.get(
      '/reviews/pitch/$pitchId',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid reviews response');
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to get pitch reviews',
      );
    }

    final reviews = response['reviews'];

    final reviewList = <Review>[];

    if (reviews is List) {
      for (final review in reviews) {
        if (review is Map) {
          reviewList.add(
            Review.fromJson(
              Map<String, dynamic>.from(review),
            ),
          );
        }
      }
    }

    return ReviewResult(
      averageRating: _parseDouble(
        response['average_rating'],
      ),
      totalReviews: _parseInt(
        response['total_reviews'],
      ),
      reviews: reviewList,
    );
  }

  // ============================================================
  // CREATE REVIEW
  // ============================================================

  Future<Review> createReview({
    required String bookingId,
    required String pitchId,
    required int rating,
    String? comment,
  }) async {
    if (bookingId.trim().isEmpty) {
      throw Exception('Invalid booking ID');
    }

    if (pitchId.trim().isEmpty) {
      throw Exception('Invalid pitch ID');
    }

    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5');
    }

    final body = <String, dynamic>{
      'booking_id': bookingId,
      'pitch_id': pitchId,
      'rating': rating,
    };

    if (comment != null && comment.trim().isNotEmpty) {
      body['comment'] = comment.trim();
    }

    final response = await _apiClient.post(
      '/reviews',
      body,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid create review response');
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to create review',
      );
    }

    // Backend response shape has not been confirmed
    // with a successful POST yet.
    final reviewData = response['review'];

    if (reviewData is! Map) {
      throw Exception('Invalid created review data');
    }

    return Review.fromJson(
      Map<String, dynamic>.from(reviewData),
    );
  }

  // ============================================================
  // PARSERS
  // ============================================================

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;

    if (value is double) return value;

    if (value is int) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    ) ??
        0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    return int.tryParse(
      value.toString(),
    ) ??
        0;
  }
}

// ============================================================
// REVIEW RESULT
// ============================================================

class ReviewResult {
  final double averageRating;
  final int totalReviews;
  final List<Review> reviews;

  const ReviewResult({
    required this.averageRating,
    required this.totalReviews,
    required this.reviews,
  });
}