import 'package:flutter/foundation.dart';

import '../../models/owner_review_model.dart';
import '../../repositories/owner_review_repository.dart';

class OwnerReviewProvider extends ChangeNotifier {
  final OwnerReviewRepository _repository;

  OwnerReviewProvider({
    OwnerReviewRepository? repository,
  }) : _repository = repository ?? OwnerReviewRepository();

  // ============================================================
  // STATE
  // ============================================================

  List<OwnerReviewModel> _reviews = [];

  int _count = 0;
  int _visibleCount = 0;
  int _hiddenCount = 0;
  double _averageRating = 0.0;

  bool _isLoading = false;
  bool _isActionLoading = false;

  String? _errorMessage;

  String? _actionReviewId;

  // ============================================================
  // GETTERS
  // ============================================================

  List<OwnerReviewModel> get reviews => _reviews;

  int get count => _count;

  int get visibleCount => _visibleCount;

  int get hiddenCount => _hiddenCount;

  double get averageRating => _averageRating;

  bool get isLoading => _isLoading;

  bool get isActionLoading => _isActionLoading;

  String? get errorMessage => _errorMessage;

  String? get actionReviewId => _actionReviewId;

  // ============================================================
  // GET OWNER REVIEWS
  // ============================================================

  Future<void> loadReviews() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final response = await _repository.getOwnerReviews();

      _reviews = response.reviews;

      _count = response.count;
      _visibleCount = response.visibleCount;
      _hiddenCount = response.hiddenCount;
      _averageRating = response.averageRating;
    } catch (error) {
      _errorMessage = _cleanErrorMessage(error);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // HIDE REVIEW
  // ============================================================

  Future<bool> hideReview(String reviewId) async {
    _setActionLoading(reviewId);

    try {
      final updatedReview =
      await _repository.hideReview(reviewId);

      _updateReview(updatedReview);

      _recalculateStatistics();

      return true;
    } catch (error) {
      _errorMessage = _cleanErrorMessage(error);

      return false;
    } finally {
      _clearActionLoading();

      notifyListeners();
    }
  }

  // ============================================================
  // UNHIDE REVIEW
  // ============================================================

  Future<bool> unhideReview(String reviewId) async {
    _setActionLoading(reviewId);

    try {
      final updatedReview =
      await _repository.unhideReview(reviewId);

      _updateReview(updatedReview);

      _recalculateStatistics();

      return true;
    } catch (error) {
      _errorMessage = _cleanErrorMessage(error);

      return false;
    } finally {
      _clearActionLoading();

      notifyListeners();
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshReviews() async {
    await loadReviews();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // UPDATE REVIEW
  // ============================================================

  void _updateReview(OwnerReviewModel updatedReview) {
    final index = _reviews.indexWhere(
          (review) => review.id == updatedReview.id,
    );

    if (index != -1) {
      _reviews[index] = updatedReview;
    }
  }

  // ============================================================
  // RECALCULATE STATISTICS
  // ============================================================

  void _recalculateStatistics() {
    _count = _reviews.length;

    _visibleCount = _reviews
        .where((review) => !review.isHidden)
        .length;

    _hiddenCount = _reviews
        .where((review) => review.isHidden)
        .length;

    if (_reviews.isEmpty) {
      _averageRating = 0.0;
      return;
    }

    final totalRating = _reviews.fold<double>(
      0.0,
          (sum, review) => sum + review.rating,
    );

    _averageRating = totalRating / _reviews.length;
  }

  // ============================================================
  // ACTION LOADING
  // ============================================================

  void _setActionLoading(String reviewId) {
    _isActionLoading = true;
    _actionReviewId = reviewId;
    _errorMessage = null;

    notifyListeners();
  }

  void _clearActionLoading() {
    _isActionLoading = false;
    _actionReviewId = null;
  }

  // ============================================================
  // ERROR MESSAGE
  // ============================================================

  String _cleanErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }
}