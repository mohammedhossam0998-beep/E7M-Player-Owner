import 'package:flutter/foundation.dart';
import 'package:e7m/core/network/api_client.dart';

import '../data/owner_booking_model.dart';
import '../data/owner_bookings_api.dart';

class OwnerBookingsProvider extends ChangeNotifier {
  final OwnerBookingsApi _api = OwnerBookingsApi(ApiClient());

  // ============================================================
  // STATE
  // ============================================================

  final List<OwnerBookingModel> _bookings = [];

  bool _loading = false;
  bool get loading => _loading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int? _processingBookingId;
  int? get processingBookingId => _processingBookingId;

  bool get actionLoading => _processingBookingId != null;

  // ============================================================
  // GETTERS
  // ============================================================

  List<OwnerBookingModel> get bookings =>
      List.unmodifiable(_bookings);

  int get totalBookings => _bookings.length;

  int get pendingBookings =>
      _bookings.where((booking) => booking.status == 'pending').length;

  int get confirmedBookings =>
      _bookings.where((booking) => booking.status == 'confirmed').length;

  int get rejectedBookings =>
      _bookings.where((booking) => booking.status == 'rejected').length;

  int get cancelledBookings =>
      _bookings.where((booking) => booking.status == 'cancelled').length;

  // ============================================================
  // LOAD OWNER BOOKINGS
  // ============================================================

  Future<void> loadBookings() async {
    if (_loading) return;

    _loading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      debugPrint('=================================');
      debugPrint('OWNER BOOKINGS: Loading...');
      debugPrint('=================================');

      final freshBookings = await _api.getOwnerBookings();

      _bookings
        ..clear()
        ..addAll(freshBookings);

      debugPrint(
        'OWNER BOOKINGS: ${_bookings.length} loaded',
      );
    } catch (e) {
      debugPrint(
        'OWNER BOOKINGS LOAD ERROR: $e',
      );

      _errorMessage = _cleanErrorMessage(e);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshBookings() async {
    if (_loading || actionLoading) return;

    await loadBookings();
  }

  // ============================================================
  // APPROVE BOOKING
  // ============================================================

  Future<bool> approveBooking(int bookingId) async {
    if (actionLoading) return false;

    _processingBookingId = bookingId;
    _errorMessage = null;

    notifyListeners();

    try {
      debugPrint(
        'OWNER BOOKINGS: Approving booking $bookingId',
      );

      final updatedBooking =
      await _api.approveBooking(bookingId);

      _replaceBooking(updatedBooking);

      debugPrint(
        'OWNER BOOKINGS: Booking $bookingId approved',
      );

      return true;
    } catch (e) {
      debugPrint(
        'OWNER BOOKINGS APPROVE ERROR: $e',
      );

      _errorMessage = _cleanErrorMessage(e);

      return false;
    } finally {
      _processingBookingId = null;

      notifyListeners();
    }
  }

  // ============================================================
  // REJECT BOOKING
  // ============================================================

  Future<bool> rejectBooking(int bookingId) async {
    if (actionLoading) return false;

    _processingBookingId = bookingId;
    _errorMessage = null;

    notifyListeners();

    try {
      debugPrint(
        'OWNER BOOKINGS: Rejecting booking $bookingId',
      );

      final updatedBooking =
      await _api.rejectBooking(bookingId);

      _replaceBooking(updatedBooking);

      debugPrint(
        'OWNER BOOKINGS: Booking $bookingId rejected',
      );

      return true;
    } catch (e) {
      debugPrint(
        'OWNER BOOKINGS REJECT ERROR: $e',
      );

      _errorMessage = _cleanErrorMessage(e);

      return false;
    } finally {
      _processingBookingId = null;

      notifyListeners();
    }
  }

  // ============================================================
  // REPLACE UPDATED BOOKING
  // ============================================================

  void _replaceBooking(
      OwnerBookingModel updatedBooking,
      ) {
    final index = _bookings.indexWhere(
          (booking) => booking.id == updatedBooking.id,
    );

    if (index == -1) {
      _bookings.insert(0, updatedBooking);
      return;
    }

    _bookings[index] = updatedBooking;
  }

  // ============================================================
  // CLEAR BOOKINGS
  // ============================================================

  void clearBookings() {
    if (_bookings.isEmpty) return;

    _bookings.clear();
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
  // ERROR MESSAGE
  // ============================================================

  String _cleanErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _bookings.clear();
    super.dispose();
  }
}