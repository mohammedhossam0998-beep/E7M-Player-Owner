import 'package:e7m/core/network/api_client.dart';
class SlotService {
  final ApiClient _apiClient;

  SlotService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // CREATE SLOT
  // ============================================================

  Future<Map<String, dynamic>> createSlot({
    required int pitchId,
    required String slotDate,
    required String startTime,
    required String endTime,
    required double price,
  }) async {
    final response = await _apiClient.post(
      '/owner/pitches/$pitchId/slots',
      {
        'slot_date': slotDate,
        'start_time': startTime,
        'end_time': endTime,
        'price': price,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid create slot response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to create slot',
      );
    }

    final slot = response['slot'];

    if (slot is! Map) {
      throw Exception(
        'Slot data missing from server response',
      );
    }

    return Map<String, dynamic>.from(
      slot,
    );
  }

  // ============================================================
  // GET PITCH SLOTS
  // ============================================================

  Future<List<Map<String, dynamic>>>
  getPitchSlots(
      int pitchId,
      ) async {
    final response = await _apiClient.get(
      '/owner/pitches/$pitchId/slots',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid slots response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to get slots',
      );
    }

    final slots = response['slots'];

    if (slots is! List) {
      return [];
    }

    return slots
        .whereType<Map>()
        .map(
          (slot) =>
      Map<String, dynamic>.from(
        slot,
      ),
    )
        .toList();
  }
}