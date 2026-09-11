import 'dart:io';

import 'package:e7m/core/network/api_client.dart';

class OwnerProfileApi {
  final ApiClient _apiClient;

  OwnerProfileApi(this._apiClient);

  // ============================================================
  // GET OWNER PROFILE
  // ============================================================

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.get(
      '/owner/profile',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid profile response');
    }

    return response;
  }

  // ============================================================
  // UPDATE OWNER PROFILE
  // ============================================================

  Future<Map<String, dynamic>> updateProfile({
    required String fullName,
    required String email,
    String? phone,
    String? profileImage,
    String? businessName,
    String? businessPhone,
    String? businessEmail,
  }) async {
    final body = {
      'full_name': fullName.trim(),
      'email': email.trim(),
      'phone': phone?.trim(),
      'profile_image': profileImage?.trim(),
      'business_name': businessName?.trim(),
      'business_phone': businessPhone?.trim(),
      'business_email': businessEmail?.trim(),
    };

    final response = await _apiClient.put(
      '/owner/profile',
      body,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid update profile response');
    }

    return response;
  }

  // ============================================================
  // UPLOAD OWNER PROFILE IMAGE
  // ============================================================

  Future<Map<String, dynamic>> uploadProfileImage(
      File imageFile,
      ) async {
    if (!await imageFile.exists()) {
      throw Exception('Selected image does not exist');
    }

    final response = await _apiClient.uploadFiles(
      '/owner/profile/image',
      [imageFile],
      fieldName: 'image',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid image upload response');
    }

    return response;
  }
}