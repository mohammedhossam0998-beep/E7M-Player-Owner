import 'package:e7m/core/network/api_client.dart';

import '../models/stadium.dart';
import '../models/stadium_image.dart';
import '../models/stadium_slot.dart';

class StadiumRepository {
  final ApiClient _apiClient;

  StadiumRepository({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET ALL STADIUMS
  // ============================================================

  Future<List<Stadium>> getStadiums() async {
    final response = await _apiClient.get('/pitches');

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid stadium response');
    }

    final pitches = response['pitches'];

    if (pitches is! List) {
      return [];
    }

    return pitches
        .whereType<Map>()
        .map(
          (json) => Stadium.fromJson(
        Map<String, dynamic>.from(json),
      ),
    )
        .toList();
  }

  // ============================================================
  // GET STADIUM DETAILS
  // ============================================================

  Future<Stadium> getStadiumById(
      String stadiumId,
      ) async {
    final response = await _apiClient.get(
      '/pitches/$stadiumId',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid stadium response');
    }

    final pitch = response['pitch'];

    if (pitch is! Map) {
      throw Exception('Stadium not found');
    }

    return Stadium.fromJson(
      Map<String, dynamic>.from(pitch),
    );
  }

  // ============================================================
  // GET STADIUM IMAGES
  // GET /api/pitches/:id/images
  // ============================================================

  Future<List<StadiumImage>> getStadiumImages(
      String stadiumId,
      ) async {
    final response = await _apiClient.get(
      '/pitches/$stadiumId/images',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid stadium images response');
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to get stadium images',
      );
    }

    final images = response['images'];

    if (images is! List) {
      return [];
    }

    return images
        .whereType<Map>()
        .map(
          (json) => StadiumImage.fromJson(
        Map<String, dynamic>.from(json),
      ),
    )
        .toList();
  }

  // ============================================================
  // GET STADIUM SLOTS
  // ============================================================

  Future<List<StadiumSlot>> getStadiumSlots(
      String stadiumId,
      ) async {
    final response = await _apiClient.get(
      '/pitches/$stadiumId/slots',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid slots response');
    }

    final slots = response['slots'];

    if (slots is! List) {
      return [];
    }

    return slots
        .whereType<Map>()
        .map(
          (json) => StadiumSlot.fromJson(
        Map<String, dynamic>.from(json),
      ),
    )
        .toList();
  }

  // ============================================================
  // CREATE BOOKING
  // POST /api/bookings
  // ============================================================

  Future<Map<String, dynamic>> createBooking({
    required String pitchSlotId,
    String? coachId,
    String? paymentMethod,
    String? notes,
  }) async {
    final body = <String, dynamic>{
      'pitch_slot_id': pitchSlotId,
    };

    if (coachId != null && coachId.isNotEmpty) {
      body['coach_id'] = coachId;
    }

    if (paymentMethod != null &&
        paymentMethod.isNotEmpty) {
      body['payment_method'] = paymentMethod;
    }

    if (notes != null &&
        notes.trim().isNotEmpty) {
      body['notes'] = notes.trim();
    }

    final response = await _apiClient.post(
      '/bookings',
      body,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid booking response');
    }

    if (response['success'] != true) {
      throw Exception(
        response['message'] ??
            'Booking could not be created',
      );
    }

    final booking = response['booking'];

    if (booking is! Map) {
      throw Exception(
        'Booking was created but response is invalid',
      );
    }

    return Map<String, dynamic>.from(booking);
  }
}