import 'package:flutter/foundation.dart';
import 'package:e7m/core/network/api_client.dart';

import 'owner_booking_model.dart';

class OwnerBookingsApi {
  final ApiClient _apiClient;

  OwnerBookingsApi(this._apiClient);

  Future<List<OwnerBookingModel>> getOwnerBookings() async {
    final response = await _apiClient.get('/owner/bookings');

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid response format');
    }

    final bookings = response['bookings'];

    if (bookings is! List) {
      throw Exception('Invalid bookings format');
    }

    return bookings
        .map(
          (item) => OwnerBookingModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  Future<OwnerBookingModel> approveBooking(int bookingId) async {
    debugPrint('🔥 API: approveBooking called with ID = $bookingId');

    final response = await _apiClient.patch(
      '/owner/bookings/$bookingId/approve',
      {},
    );

    debugPrint('🔥 API: approveBooking response = $response');

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid response format');
    }

    final booking = response['booking'];

    if (booking is! Map) {
      throw Exception('Invalid booking response');
    }

    return OwnerBookingModel.fromJson(
      Map<String, dynamic>.from(booking),
    );
  }

  Future<OwnerBookingModel> rejectBooking(int bookingId) async {
    debugPrint('🔥 API: rejectBooking called with ID = $bookingId');

    final response = await _apiClient.patch(
      '/owner/bookings/$bookingId/reject',
      {},
    );

    debugPrint('🔥 API: rejectBooking response = $response');

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid response format');
    }

    final booking = response['booking'];

    if (booking is! Map) {
      throw Exception('Invalid booking response');
    }

    return OwnerBookingModel.fromJson(
      Map<String, dynamic>.from(booking),
    );
  }
}