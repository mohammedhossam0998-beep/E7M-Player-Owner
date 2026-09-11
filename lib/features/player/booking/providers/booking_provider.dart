import 'package:flutter/foundation.dart';

import 'package:e7m/features/player/booking/models/booking_model.dart';
import 'package:e7m/features/player/booking/repositories/booking_repository.dart';

class BookingProvider extends ChangeNotifier {
  final BookingRepository _repository;

  BookingProvider({
    BookingRepository? repository,
  }) : _repository = repository ?? BookingRepository();

  // ============================================================
  // STATE
  // ============================================================

  List<BookingModel> _bookings = [];

  bool _isLoading = false;
  bool _isLoadingDetails = false;
  bool _isCreating = false;
  bool _isCancelling = false;

  String? _errorMessage;

  BookingModel? _selectedBooking;

  // ============================================================
  // GETTERS
  // ============================================================

  List<BookingModel> get bookings => List.unmodifiable(_bookings);

  bool get isLoading => _isLoading;

  bool get isLoadingDetails => _isLoadingDetails;

  bool get isCreating => _isCreating;

  bool get isCancelling => _isCancelling;

  String? get errorMessage => _errorMessage;

  BookingModel? get selectedBooking => _selectedBooking;

  bool get hasBookings => _bookings.isNotEmpty;

  // ============================================================
  // UPCOMING BOOKINGS
  // ============================================================

  List<BookingModel> get upcomingBookings {
    return _bookings.where((booking) {
      final status = booking.status.toLowerCase();

      return status == 'pending' || status == 'confirmed';
    }).toList();
  }

  // ============================================================
  // COMPLETED BOOKINGS
  // ============================================================

  List<BookingModel> get completedBookings {
    return _bookings.where((booking) {
      return booking.status.toLowerCase() == 'completed';
    }).toList();
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
  // GET MY BOOKINGS
  // ============================================================

  Future<bool> fetchMyBookings() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result = await _repository.getMyBookings();

      _bookings = result;

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // GET BOOKING DETAILS
  // ============================================================

  Future<BookingModel?> fetchBookingDetails(
      int bookingId,
      ) async {
    _isLoadingDetails = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final booking = await _repository.getBookingDetails(
        bookingId,
      );

      _selectedBooking = booking;

      return booking;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return null;
    } finally {
      _isLoadingDetails = false;

      notifyListeners();
    }
  }

  // ============================================================
  // CREATE BOOKING
  // ============================================================

  Future<BookingModel?> createBooking({
    required int pitchSlotId,
    int? coachId,
    String? paymentMethod,
    String? notes,
  }) async {
    _isCreating = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final booking = await _repository.createBooking(
        pitchSlotId: pitchSlotId,
        coachId: coachId,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      _bookings = [
        booking,
        ..._bookings,
      ];

      return booking;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return null;
    } finally {
      _isCreating = false;

      notifyListeners();
    }
  }

  // ============================================================
  // CANCEL BOOKING
  // ============================================================

  Future<bool> cancelBooking(int bookingId) async {
    _isCancelling = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final cancelledBooking =
      await _repository.cancelBooking(bookingId);

      final index = _bookings.indexWhere(
            (booking) => booking.id == bookingId,
      );

      if (index != -1) {
        _bookings[index] = cancelledBooking;
      }

      if (_selectedBooking?.id == bookingId) {
        _selectedBooking = cancelledBooking;
      }

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return false;
    } finally {
      _isCancelling = false;

      notifyListeners();
    }
  }

  // ============================================================
  // REMOVE LOCAL BOOKING
  // ============================================================

  void removeBookingLocally(int bookingId) {
    _bookings.removeWhere(
          (booking) => booking.id == bookingId,
    );

    if (_selectedBooking?.id == bookingId) {
      _selectedBooking = null;
    }

    notifyListeners();
  }

  // ============================================================
  // SET SELECTED BOOKING
  // ============================================================

  void setSelectedBooking(BookingModel? booking) {
    _selectedBooking = booking;

    notifyListeners();
  }

  // ============================================================
  // CLEAR SELECTED BOOKING
  // ============================================================

  void clearSelectedBooking() {
    if (_selectedBooking == null) return;

    _selectedBooking = null;

    notifyListeners();
  }

  // ============================================================
  // REFRESH BOOKINGS
  // ============================================================

  Future<bool> refreshBookings() async {
    return fetchMyBookings();
  }

  // ============================================================
  // CLEAR ALL BOOKINGS
  // ============================================================

  void clearBookings() {
    _bookings = [];
    _selectedBooking = null;
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }
}