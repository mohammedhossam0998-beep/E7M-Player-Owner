import 'package:image_picker/image_picker.dart';

import 'package:e7m/core/network/api_client.dart';

class PlayerProfileApi {
  final ApiClient _apiClient;

  PlayerProfileApi({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET MY PROFILE
  // ============================================================

  Future<Map<String, dynamic>> getMyProfile() async {
    final response = await _apiClient.get('/player/profile');

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid player profile response');
    }

    return response;
  }

  // ============================================================
  // CREATE PROFILE
  // ============================================================

  Future<Map<String, dynamic>> createProfile(
      Map<String, dynamic> data,
      ) async {
    final response = await _apiClient.post(
      '/player/profile',
      data,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid create profile response');
    }

    return response;
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<Map<String, dynamic>> updateProfile(
      Map<String, dynamic> data,
      ) async {
    final response = await _apiClient.put(
      '/player/profile',
      data,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid update profile response');
    }

    return response;
  }

  // ============================================================
  // UPDATE ACCOUNT
  // ============================================================

  Future<Map<String, dynamic>> updateAccount(
      Map<String, dynamic> data,
      ) async {
    final response = await _apiClient.put(
      '/player/account',
      data,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid update account response');
    }

    return response;
  }

  // ============================================================
  // UPLOAD PROFILE IMAGE
  // ============================================================

  Future<Map<String, dynamic>> uploadProfileImage(
      XFile image,
      ) async {
    // XFile + bytes works on Android, iOS and Flutter Web
    // (dart:io File does not work on web).
    final bytes = await image.readAsBytes();

    final filename =
    image.name.contains('.') ? image.name : '${image.name}.jpg';

    final response = await _apiClient.uploadBytes(
      '/player/profile/image',
      bytes: bytes,
      filename: filename,
      fieldName: 'image',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid profile image upload response');
    }

    return response;
  }
}