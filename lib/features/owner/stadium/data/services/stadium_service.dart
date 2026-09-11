import 'dart:io';

import 'package:e7m/core/network/api_client.dart';

import '../models/stadium_model.dart';
import '../models/stadium_image_model.dart';

class StadiumService {
  final ApiClient _apiClient;

  StadiumService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // CREATE STADIUM
  // ============================================================

  Future<StadiumModel> createStadium(
      StadiumModel stadium,
      ) async {
    final response = await _apiClient.post(
      '/owner/pitches',
      stadium.toCreateJson(),
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid create stadium response',
      );
    }

    final pitchData =
    response['pitch'];

    if (pitchData is! Map<String, dynamic>) {
      throw Exception(
        'Stadium data not found in server response',
      );
    }

    return StadiumModel.fromJson(
      pitchData,
    );
  }

  // ============================================================
  // GET OWNER STADIUMS
  // ============================================================

  Future<List<StadiumModel>>
  getOwnerStadiums() async {
    final response =
    await _apiClient.get(
      '/owner/pitches',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid owner stadiums response',
      );
    }

    final pitches =
    response['pitches'];

    if (pitches is! List) {
      return [];
    }

    return pitches
        .whereType<
        Map<String, dynamic>>()
        .map(
      StadiumModel.fromJson,
    )
        .toList();
  }

  // ============================================================
  // GET ONE STADIUM
  // ============================================================

  Future<StadiumModel>
  getStadiumById(
      int stadiumId,
      ) async {
    final response =
    await _apiClient.get(
      '/owner/pitches/$stadiumId',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid stadium response',
      );
    }

    final pitchData =
    response['pitch'];

    if (pitchData is! Map<String, dynamic>) {
      throw Exception(
        'Stadium data not found in server response',
      );
    }

    return StadiumModel.fromJson(
      pitchData,
    );
  }

  // ============================================================
  // UPDATE STADIUM
  // ============================================================

  Future<StadiumModel> updateStadium(
      int stadiumId,
      StadiumModel stadium,
      ) async {
    final response =
    await _apiClient.put(
      '/owner/pitches/$stadiumId',
      stadium.toCreateJson(),
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid update stadium response',
      );
    }

    final pitchData =
    response['pitch'];

    if (pitchData is! Map<String, dynamic>) {
      throw Exception(
        'Updated stadium data not found',
      );
    }

    return StadiumModel.fromJson(
      pitchData,
    );
  }

  // ============================================================
  // DELETE STADIUM
  // ============================================================

  Future<void> deleteStadium(
      int stadiumId,
      ) async {
    await _apiClient.delete(
      '/owner/pitches/$stadiumId',
    );
  }

  // ============================================================
  // GET STADIUM IMAGES
  // ============================================================

  Future<List<StadiumImageModel>>
  getStadiumImages(
      int stadiumId,
      ) async {
    final response =
    await _apiClient.get(
      '/owner/pitches/$stadiumId/images',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid stadium images response',
      );
    }

    final images =
    response['images'];

    if (images is! List) {
      return [];
    }

    return images
        .whereType<
        Map<String, dynamic>>()
        .map(
      StadiumImageModel.fromJson,
    )
        .toList();
  }

  // ============================================================
  // UPLOAD STADIUM IMAGES
  // ============================================================

  Future<List<StadiumImageModel>>
  uploadStadiumImages(
      int stadiumId,
      List<File> files,
      ) async {
    if (files.isEmpty) {
      throw Exception(
        'At least one image is required',
      );
    }

    final response =
    await _apiClient.uploadFiles(
      '/owner/pitches/$stadiumId/images',
      files,
      fieldName: 'images',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid upload stadium images response',
      );
    }

    final images =
    response['images'];

    if (images is! List) {
      return [];
    }

    return images
        .whereType<
        Map<String, dynamic>>()
        .map(
      StadiumImageModel.fromJson,
    )
        .toList();
  }

  // ============================================================
  // DELETE STADIUM IMAGE
  // ============================================================

  Future<void> deleteStadiumImage(
      int stadiumId,
      int imageId,
      ) async {
    await _apiClient.delete(
      '/owner/pitches/$stadiumId/images/$imageId',
    );
  }

  // ============================================================
  // SET PRIMARY STADIUM IMAGE
  // ============================================================

  Future<StadiumImageModel>
  setPrimaryStadiumImage(
      int stadiumId,
      int imageId,
      ) async {
    final response =
    await _apiClient.put(
      '/owner/pitches/$stadiumId/images/$imageId/primary',
      {},
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid primary image response',
      );
    }

    final image =
    response['image'];

    if (image is! Map<String, dynamic>) {
      throw Exception(
        'Primary image data not found',
      );
    }

    return StadiumImageModel.fromJson(
      image,
    );
  }
}