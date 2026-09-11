import 'package:e7m/core/network/api_client.dart';

import '../models/slot_model.dart';

class SlotService {
  final ApiClient _apiClient;

  SlotService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // CREATE SLOT
  // ============================================================

  Future<SlotModel> createSlot(
      int stadiumId,
      SlotModel slot,
      ) async {
    final response = await _apiClient.post(
      '/owner/pitches/$stadiumId/slots',
      slot.toCreateJson(),
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid create slot response');
    }

    final slotData = response['slot'];

    if (slotData is! Map<String, dynamic>) {
      throw Exception('Slot data not found in server response');
    }

    return SlotModel.fromJson(slotData);
  }

  // ============================================================
  // GET STADIUM SLOTS
  // ============================================================

  Future<List<SlotModel>> getStadiumSlots(
      int stadiumId,
      ) async {
    final response = await _apiClient.get(
      '/owner/pitches/$stadiumId/slots',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid stadium slots response');
    }

    final slots = response['slots'];

    if (slots is! List) {
      return [];
    }

    return slots
        .whereType<Map<String, dynamic>>()
        .map(SlotModel.fromJson)
        .toList();
  }

  // ============================================================
  // UPDATE SLOT
  // ============================================================

  Future<SlotModel> updateSlot(
      int stadiumId,
      int slotId,
      SlotModel slot,
      ) async {
    final response = await _apiClient.put(
      '/owner/pitches/$stadiumId/slots/$slotId',
      slot.toCreateJson(),
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid update slot response');
    }

    final slotData = response['slot'];

    if (slotData is! Map<String, dynamic>) {
      throw Exception('Updated slot data not found');
    }

    return SlotModel.fromJson(slotData);
  }

  // ============================================================
  // DELETE SLOT
  // ============================================================

  Future<void> deleteSlot(
      int stadiumId,
      int slotId,
      ) async {
    final response = await _apiClient.delete(
      '/owner/pitches/$stadiumId/slots/$slotId',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid delete slot response');
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to delete slot',
      );
    }
  }

  // ============================================================
  // UPDATE SLOT STATUS
  // ============================================================

  Future<SlotModel> updateSlotStatus(
      int stadiumId,
      int slotId,
      String status,
      ) async {
    final response = await _apiClient.patch(
      '/owner/pitches/$stadiumId/slots/$slotId/status',
      {
        'status': status,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid slot status response');
    }

    final slotData = response['slot'];

    if (slotData is! Map<String, dynamic>) {
      throw Exception('Updated slot data not found');
    }

    return SlotModel.fromJson(slotData);
  }
}