import '../models/owner_review_model.dart';
import '../data/owner_review_api.dart';

class OwnerReviewRepository {
  final OwnerReviewApi _api;

  OwnerReviewRepository({OwnerReviewApi? api})
      : _api = api ?? OwnerReviewApi();

  // ============================================================
  // GET OWNER REVIEWS
  // ============================================================

  Future<OwnerReviewsResponse> getOwnerReviews() async {
    final response = await _api.getOwnerReviews();

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to load owner reviews',
      );
    }

    return OwnerReviewsResponse.fromJson(response);
  }

  // ============================================================
  // HIDE REVIEW
  // ============================================================

  Future<OwnerReviewModel> hideReview(String reviewId) async {
    final response = await _api.hideReview(reviewId);

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to hide review',
      );
    }

    return OwnerReviewModel.fromJson(
      Map<String, dynamic>.from(response['review']),
    );
  }

  // ============================================================
  // UNHIDE REVIEW
  // ============================================================

  Future<OwnerReviewModel> unhideReview(String reviewId) async {
    final response = await _api.unhideReview(reviewId);

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to unhide review',
      );
    }

    return OwnerReviewModel.fromJson(
      Map<String, dynamic>.from(response['review']),
    );
  }
}

// ============================================================
// OWNER REVIEWS RESPONSE
// ============================================================

class OwnerReviewsResponse {
  final int count;
  final int visibleCount;
  final int hiddenCount;
  final double averageRating;
  final List<OwnerReviewModel> reviews;

  OwnerReviewsResponse({
    required this.count,
    required this.visibleCount,
    required this.hiddenCount,
    required this.averageRating,
    required this.reviews,
  });

  factory OwnerReviewsResponse.fromJson(
      Map<String, dynamic> json,
      ) {
    final reviewsJson = json['reviews'];

    final reviews = reviewsJson is List
        ? reviewsJson
        .map(
          (item) => OwnerReviewModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList()
        : <OwnerReviewModel>[];

    return OwnerReviewsResponse(
      count: int.tryParse(
        json['count']?.toString() ?? '',
      ) ??
          0,
      visibleCount: int.tryParse(
        json['visible_count']?.toString() ?? '',
      ) ??
          0,
      hiddenCount: int.tryParse(
        json['hidden_count']?.toString() ?? '',
      ) ??
          0,
      averageRating: double.tryParse(
        json['average_rating']?.toString() ?? '',
      ) ??
          0.0,
      reviews: reviews,
    );
  }
}