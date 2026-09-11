import 'dart:io';

import 'package:e7m/core/network/api_client.dart';

class PitchService {
  final ApiClient _apiClient;

  PitchService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // CREATE PITCH
  // ============================================================

  Future<Map<String, dynamic>> createPitch({
    required int cityId,
    required String name,
    required String description,
    required String pitchType,
    required int capacity,
    required double basePrice,
  }) async {
    final response = await _apiClient.post(
      '/owner/pitches',
      {
        'city_id': cityId,
        'name': name,
        'description':
        description.trim().isEmpty ? null : description.trim(),
        'pitch_type': pitchType,
        'capacity': capacity,
        'base_price': basePrice,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid create pitch response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to create pitch',
      );
    }

    final pitch = response['pitch'];

    if (pitch is! Map) {
      throw Exception(
        'Pitch data missing from server response',
      );
    }

    return Map<String, dynamic>.from(pitch);
  }

  // ============================================================
  // UPLOAD PITCH IMAGES
  // ============================================================

  Future<List<Map<String, dynamic>>> uploadPitchImages({
    required int pitchId,
    required List<File> images,
  }) async {
    // No images
    if (images.isEmpty) {
      return [];
    }

    // Backend allows maximum 10 images
    if (images.length > 10) {
      throw Exception(
        'You can upload a maximum of 10 images',
      );
    }

    final response = await _apiClient.uploadFiles(
      '/owner/pitches/$pitchId/images',
      images,
      fieldName: 'images',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid upload images response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to upload pitch images',
      );
    }

    final rawImages = response['images'];

    if (rawImages is! List) {
      return [];
    }

    return rawImages
        .whereType<Map>()
        .map(
          (image) => Map<String, dynamic>.from(image),
    )
        .toList();
  }

  // ============================================================
  // GET MY PITCHES
  // ============================================================

  Future<List<Map<String, dynamic>>> getMyPitches() async {
    final response = await _apiClient.get(
      '/owner/pitches',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid pitches response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to get pitches',
      );
    }

    final pitches = response['pitches'];

    if (pitches is! List) {
      return [];
    }

    return pitches
        .whereType<Map>()
        .map(
          (pitch) => Map<String, dynamic>.from(pitch),
    )
        .toList();
  }

  // ============================================================
  // GET ONE PITCH
  // ============================================================

  Future<Map<String, dynamic>> getPitch(
      int pitchId,
      ) async {
    final response = await _apiClient.get(
      '/owner/pitches/$pitchId',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid pitch response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to get pitch',
      );
    }

    final pitch = response['pitch'];

    if (pitch is! Map) {
      throw Exception(
        'Pitch data missing',
      );
    }

    return Map<String, dynamic>.from(pitch);
  }

  // ============================================================
  // UPDATE PITCH
  // ============================================================

  Future<Map<String, dynamic>> updatePitch({
    required int pitchId,
    required int cityId,
    required String name,
    required String description,
    required String pitchType,
    required int capacity,
    required double basePrice,
  }) async {
    final response = await _apiClient.put(
      '/owner/pitches/$pitchId',
      {
        'city_id': cityId,
        'name': name,
        'description':
        description.trim().isEmpty ? null : description.trim(),
        'pitch_type': pitchType,
        'capacity': capacity,
        'base_price': basePrice,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid update pitch response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to update pitch',
      );
    }

    final pitch = response['pitch'];

    if (pitch is! Map) {
      throw Exception(
        'Updated pitch data missing',
      );
    }

    return Map<String, dynamic>.from(pitch);
  }

  // ============================================================
  // DELETE PITCH
  // ============================================================

  Future<void> deletePitch(
      int pitchId,
      ) async {
    final response = await _apiClient.delete(
      '/owner/pitches/$pitchId',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid delete pitch response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to delete pitch',
      );
    }
  }
}