import 'package:e7m/features/player/booking/models/booking_model.dart';
import 'package:e7m/features/player/booking/services/booking_service.dart';

class BookingRepository {
  final BookingService _bookingService;

  BookingRepository({BookingService? bookingService})
      : _bookingService = bookingService ?? BookingService();

  // ============================================================
  // GET MY BOOKINGS
  // ============================================================

  Future<List<BookingModel>> getMyBookings() async {
    final response = await _bookingService.getMyBookings();

    return _parseBookingList(response);
  }

  // ============================================================
  // GET BOOKING DETAILS
  // ============================================================

  Future<BookingModel> getBookingDetails(int bookingId) async {
    final response = await _bookingService.getBookingDetails(
      bookingId,
    );

    final data = _extractData(response);

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid booking details response');
    }

    return BookingModel.fromJson(data);
  }

  // ============================================================
  // CREATE BOOKING
  // ============================================================

  Future<BookingModel> createBooking({
    required int pitchSlotId,
    int? coachId,
    String? paymentMethod,
    String? notes,
  }) async {
    final response = await _bookingService.createBooking(
      pitchSlotId: pitchSlotId,
      coachId: coachId,
      paymentMethod: paymentMethod,
      notes: notes,
    );

    final data = _extractData(response);

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid booking creation response');
    }

    return BookingModel.fromJson(data);
  }

  // ============================================================
  // CANCEL BOOKING
  // ============================================================

  Future<BookingModel> cancelBooking(int bookingId) async {
    final response = await _bookingService.cancelBooking(
      bookingId,
    );

    final data = _extractData(response);

    if (data is! Map<String, dynamic>) {
      throw Exception('Invalid booking cancellation response');
    }

    return BookingModel.fromJson(data);
  }

  // ============================================================
  // PARSE BOOKING LIST
  // ============================================================

  List<BookingModel> _parseBookingList(dynamic response) {
    final data = _extractData(response);

    if (data is List) {
      return data
          .whereType<Map>()
          .map(
            (item) => BookingModel.fromJson(
          Map<String, dynamic>.from(item),
        ),
      )
          .toList();
    }

    throw Exception('Invalid bookings list response');
  }

  // ============================================================
  // EXTRACT DATA
  // ============================================================

  dynamic _extractData(dynamic response) {
    if (response is Map<String, dynamic>) {
      if (response.containsKey('data')) {
        return response['data'];
      }

      if (response.containsKey('booking')) {
        return response['booking'];
      }

      if (response.containsKey('bookings')) {
        return response['bookings'];
      }
    }

    return response;
  }
}