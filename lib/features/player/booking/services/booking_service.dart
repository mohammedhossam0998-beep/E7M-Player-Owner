import 'package:e7m/core/network/api_client.dart';

class BookingService {
  final ApiClient _apiClient;

  BookingService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET MY BOOKINGS
  // ============================================================

  Future<dynamic> getMyBookings() async {
    return await _apiClient.get('/bookings/my');
  }

  // ============================================================
  // GET BOOKING DETAILS
  // ============================================================

  Future<dynamic> getBookingDetails(int bookingId) async {
    return await _apiClient.get('/bookings/$bookingId');
  }

  // ============================================================
  // CREATE BOOKING
  // ============================================================

  Future<dynamic> createBooking({
    required int pitchSlotId,
    int? coachId,
    String? paymentMethod,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'pitch_slot_id': pitchSlotId,
    };

    if (coachId != null) {
      body['coach_id'] = coachId;
    }

    if (paymentMethod != null && paymentMethod.trim().isNotEmpty) {
      body['payment_method'] = paymentMethod.trim();
    }

    if (notes != null && notes.trim().isNotEmpty) {
      body['notes'] = notes.trim();
    }

    return await _apiClient.post(
      '/bookings',
      body,
    );
  }

  // ============================================================
  // CANCEL BOOKING
  // ============================================================

  Future<dynamic> cancelBooking(int bookingId) async {
    return await _apiClient.patch(
      '/bookings/$bookingId/cancel',
      {},
    );
  }
}