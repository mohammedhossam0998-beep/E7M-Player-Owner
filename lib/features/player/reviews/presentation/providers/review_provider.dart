import 'package:flutter/foundation.dart';

import '../../data/models/review.dart';
import '../../data/repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  final ReviewRepository _repository;

  ReviewProvider({
    ReviewRepository? repository,
  }) : _repository = repository ?? ReviewRepository();

  // ============================================================
  // STATE
  // ============================================================

  List<Review> _reviews = [];

  double _averageRating = 0.0;

  int _totalReviews = 0;

  bool _isLoading = false;

  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<Review> get reviews => List.unmodifiable(_reviews);

  double get averageRating => _averageRating;

  int get totalReviews => _totalReviews;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get hasReviews => _reviews.isNotEmpty;

  // ============================================================
  // CREATE REVIEW STATE
  // ============================================================

  bool _isCreating = false;

  bool get isCreating => _isCreating;

  // ============================================================
  // CREATE REVIEW
  // ============================================================

  Future<Review?> createReview({
    required String bookingId,
    required String pitchId,
    required int rating,
    String? comment,
  }) async {
    if (bookingId.trim().isEmpty) {
      _errorMessage = 'Invalid booking ID';
      notifyListeners();
      return null;
    }

    if (pitchId.trim().isEmpty) {
      _errorMessage = 'Invalid pitch ID';
      notifyListeners();
      return null;
    }

    if (rating < 1 || rating > 5) {
      _errorMessage = 'Rating must be between 1 and 5';
      notifyListeners();
      return null;
    }

    _isCreating = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final review = await _repository.createReview(
        bookingId: bookingId,
        pitchId: pitchId,
        rating: rating,
        comment: comment,
      );

      return review;
    } catch (e) {
      _errorMessage = _cleanError(e);
      return null;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  // ============================================================
  // LOAD PITCH REVIEWS
  // ============================================================

  Future<void> loadPitchReviews(String pitchId) async {
    if (pitchId.trim().isEmpty) {
      _errorMessage = 'Invalid pitch ID';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result = await _repository.getPitchReviews(pitchId);

      _reviews = result.reviews;
      _averageRating = result.averageRating;
      _totalReviews = result.totalReviews;
    } catch (e) {
      _errorMessage = _cleanError(e);

      _reviews = [];
      _averageRating = 0.0;
      _totalReviews = 0;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // CLEAR REVIEWS
  // ============================================================

  void clearReviews() {
    _reviews = [];
    _averageRating = 0.0;
    _totalReviews = 0;
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    if (_errorMessage == null) return;

    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // ERROR CLEANUP
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }
}