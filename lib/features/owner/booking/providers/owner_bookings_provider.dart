
import 'package:flutter/foundation.dart';
import 'package:e7m/core/network/api_client.dart';

import '../data/owner_booking_model.dart';
import '../data/owner_bookings_api.dart';

class OwnerBookingsProvider extends ChangeNotifier {
  OwnerBookingsProvider({OwnerBookingsApi? api})
      : _api = api ?? OwnerBookingsApi(ApiClient());

  final OwnerBookingsApi _api;
  final List<OwnerBookingModel> _bookings = [];

  bool _loading = false;
  bool _disposed = false;
  String? _errorMessage;
  int? _processingBookingId;
  int _requestVersion = 0;
  int _accountVersion = 0;

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  int? get processingBookingId => _processingBookingId;
  bool get actionLoading => _processingBookingId != null;

  List<OwnerBookingModel> get bookings =>
      List.unmodifiable(_bookings);

  int get totalBookings => _bookings.length;
  int get pendingBookings => _countStatus('pending');
  int get confirmedBookings => _countStatus('confirmed');
  int get rejectedBookings => _countStatus('rejected');
  int get cancelledBookings => _countStatus('cancelled');

  int _countStatus(String status) => _bookings
      .where((b) => b.status.toLowerCase() == status)
      .length;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  // ============================================================
  // LOAD BOOKINGS
  // ============================================================

  Future<void> loadBookings() async {
    if (_disposed || _loading) return;

    final request = ++_requestVersion;
    final account = _accountVersion;

    _loading = true;
    _errorMessage = null;
    _notify();

    try {
      final fresh = await _api.getOwnerBookings();

      if (_disposed ||
          request != _requestVersion ||
          account != _accountVersion) {
        return;
      }

      _bookings
        ..clear()
        ..addAll(fresh);
    } catch (error) {
      if (_disposed ||
          request != _requestVersion ||
          account != _accountVersion) {
        return;
      }

      _errorMessage = _cleanErrorMessage(error);
    } finally {
      if (!_disposed &&
          request == _requestVersion &&
          account == _accountVersion) {
        _loading = false;
        _notify();
      }
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshBookings() async {
    if (_disposed || actionLoading) return;

    await loadBookings();
  }

  // ============================================================
  // APPROVE / REJECT
  // ============================================================

  Future<bool> approveBooking(int bookingId) =>
      _changeStatus(bookingId, approve: true);

  Future<bool> rejectBooking(int bookingId) =>
      _changeStatus(bookingId, approve: false);

  Future<bool> _changeStatus(
      int bookingId, {
        required bool approve,
      }) async {
    if (_disposed || actionLoading) return false;

    final index = _bookings.indexWhere(
          (b) => b.id == bookingId,
    );

    if (index < 0 ||
        _bookings[index].status.toLowerCase() != 'pending') {
      _errorMessage =
      'Booking is no longer pending. Refresh the list.';
      _notify();
      return false;
    }

    final account = _accountVersion;

    // Ignore list responses started before this action.
    ++_requestVersion;
    _loading = false;
    _processingBookingId = bookingId;
    _errorMessage = null;
    _notify();

    try {
      final updated = approve
          ? await _api.approveBooking(bookingId)
          : await _api.rejectBooking(bookingId);

      if (_disposed || account != _accountVersion) {
        return false;
      }

      _replaceBookingPreservingDetails(updated);
      return true;
    } catch (error) {
      if (_disposed || account != _accountVersion) {
        return false;
      }

      final reason = _cleanErrorMessage(error);

      // The server might have updated the booking even if
      // an error was returned afterwards.
      await loadBookings();

      if (_disposed || account != _accountVersion) {
        return false;
      }

      final now = _bookings.where(
            (b) => b.id == bookingId,
      );

      final expected = approve ? 'confirmed' : 'rejected';

      if (now.isNotEmpty &&
          now.first.status.toLowerCase() == expected) {
        _errorMessage = null;
        return true;
      }

      _errorMessage = reason;
      return false;
    } finally {
      if (!_disposed && account == _accountVersion) {
        _processingBookingId = null;
        _notify();
      }
    }
  }

  // ============================================================
  // PRESERVE FULL BOOKING DETAILS
  // ============================================================

  void _replaceBookingPreservingDetails(
      OwnerBookingModel updated,
      ) {
    final index = _bookings.indexWhere(
          (b) => b.id == updated.id,
    );

    if (index == -1) {
      // Do not insert an incomplete response.
      return;
    }

    final current = _bookings[index];

    _bookings[index] = OwnerBookingModel.fromJson({
      ...current.toJson(),
      'status': updated.status,
      'updated_at': updated.updatedAt,
      'payment_status': updated.paymentStatus,
      'payment_method': updated.paymentMethod,
      'deposit_paid_at': updated.depositPaidAt,
      'total_price': updated.totalPrice,
      'deposit_amount': updated.depositAmount,
      'remaining_amount': updated.remainingAmount,
      'cancelled_at': updated.cancelledAt,
    });
  }

  // ============================================================
  // CLEAR ACCOUNT DATA
  // ============================================================

  void clearBookings() {
    if (_disposed) return;

    ++_accountVersion;
    ++_requestVersion;

    _bookings.clear();
    _loading = false;
    _processingBookingId = null;
    _errorMessage = null;

    _notify();
  }

  void clearError() {
    if (_disposed || _errorMessage == null) return;

    _errorMessage = null;
    _notify();
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString();

    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }

  @override
  void dispose() {
    _disposed = true;
    ++_accountVersion;
    ++_requestVersion;

    _bookings.clear();
    super.dispose();
  }
}
