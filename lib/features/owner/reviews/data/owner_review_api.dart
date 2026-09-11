import 'package:e7m/core/network/api_client.dart';

class OwnerReviewApi {
  final ApiClient _apiClient;

  OwnerReviewApi({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET OWNER REVIEWS
  // GET /api/owner/reviews
  // ============================================================

  Future<Map<String, dynamic>> getOwnerReviews() async {
    final response = await _apiClient.get(
      '/owner/reviews',
    );

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // HIDE REVIEW
  // PATCH /api/owner/reviews/:reviewId/hide
  // ============================================================

  Future<Map<String, dynamic>> hideReview(
      String reviewId,
      ) async {
    final response = await _apiClient.patch(
      '/owner/reviews/$reviewId/hide',
      {},
    );

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // UNHIDE REVIEW
  // PATCH /api/owner/reviews/:reviewId/unhide
  // ============================================================

  Future<Map<String, dynamic>> unhideReview(
      String reviewId,
      ) async {
    final response = await _apiClient.patch(
      '/owner/reviews/$reviewId/unhide',
      {},
    );

    return Map<String, dynamic>.from(response);
  }
}