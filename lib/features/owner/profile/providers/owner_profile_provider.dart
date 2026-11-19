
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:e7m/core/network/api_client.dart';
import 'package:e7m/features/owner/profile/data/models/owner_profile_model.dart';

class OwnerProfileProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  OwnerProfileModel? _profile;

  bool _isLoading = false;
  bool _isUpdating = false;
  bool _isUploadingImage = false;

  String? _errorMessage;

  int _sessionVersion = 0;

  OwnerProfileModel? get profile => _profile;

  bool get isLoading => _isLoading;

  bool get isUpdating => _isUpdating;

  bool get isUploadingImage => _isUploadingImage;

  String? get errorMessage => _errorMessage;

  bool get hasProfile => _profile != null;

  // Clear account-specific data on logout.
  // Ignore requests started before logout.
  void clearProfile() {
    _sessionVersion++;

    _profile = null;
    _errorMessage = null;

    _isLoading = false;
    _isUpdating = false;
    _isUploadingImage = false;

    notifyListeners();
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<bool> loadProfile() async {
    final sessionVersion = _sessionVersion;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final response = await _apiClient.get(
        '/owner/profile',
      );

      if (response is! Map<String, dynamic>) {
        throw Exception('Invalid profile response');
      }

      if (response['success'] != true) {
        throw Exception(
          response['message']?.toString() ??
              'Failed to load owner profile',
        );
      }

      final ownerData = response['owner'];

      if (ownerData is! Map<String, dynamic>) {
        throw Exception(
          'Owner profile data is missing',
        );
      }

      if (sessionVersion != _sessionVersion) {
        return false;
      }

      _profile = OwnerProfileModel.fromJson(
        ownerData,
      );

      return true;
    } catch (e) {
      if (sessionVersion != _sessionVersion) {
        return false;
      }

      _errorMessage = _cleanError(e);

      return false;
    } finally {
      if (sessionVersion == _sessionVersion) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  // ============================================================
  // UPLOAD PROFILE IMAGE
  // ============================================================

  Future<bool> uploadProfileImage(
      File imageFile,
      ) async {
    final sessionVersion = _sessionVersion;

    _isUploadingImage = true;
    _errorMessage = null;

    notifyListeners();

    try {
      if (!await imageFile.exists()) {
        throw Exception(
          'Selected image does not exist',
        );
      }

      final response = await _apiClient.uploadFiles(
        '/owner/profile/image',
        [imageFile],
        fieldName: 'image',
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid image upload response',
        );
      }

      if (response['success'] != true) {
        throw Exception(
          response['message']?.toString() ??
              'Failed to upload profile image',
        );
      }

      final imageUrl =
      response['profile_image']?.toString();

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception(
          'Profile image URL was not returned by server',
        );
      }

      if (sessionVersion != _sessionVersion) {
        return false;
      }

      final profileResponse =
      await _apiClient.get('/owner/profile');

      if (sessionVersion != _sessionVersion) {
        return false;
      }

      if (profileResponse is Map<String, dynamic> &&
          profileResponse['success'] == true &&
          profileResponse['owner']
          is Map<String, dynamic>) {
        _profile = OwnerProfileModel.fromJson(
          profileResponse['owner'],
        );
      }

      return true;
    } catch (e) {
      if (sessionVersion != _sessionVersion) {
        return false;
      }

      _errorMessage = _cleanError(e);

      return false;
    } finally {
      if (sessionVersion == _sessionVersion) {
        _isUploadingImage = false;
        notifyListeners();
      }
    }
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<bool> updateProfile({
    required String fullName,
    required String email,
    String? phone,
    String? profileImage,
    String? businessName,
    String? businessPhone,
    String? businessEmail,
  }) async {
    final sessionVersion = _sessionVersion;

    _isUpdating = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final body = {
        'full_name': fullName.trim(),
        'email': email.trim(),
        'phone': phone?.trim(),
        'profile_image': profileImage,
        'business_name': businessName?.trim(),
        'business_phone': businessPhone?.trim(),
        'business_email': businessEmail?.trim(),
      };

      final response = await _apiClient.put(
        '/owner/profile',
        body,
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid update response',
        );
      }

      if (response['success'] != true) {
        throw Exception(
          response['message']?.toString() ??
              'Failed to update owner profile',
        );
      }

      final ownerData = response['owner'];

      if (ownerData is! Map<String, dynamic>) {
        throw Exception(
          'Updated owner profile is missing',
        );
      }

      if (sessionVersion != _sessionVersion) {
        return false;
      }

      _profile = OwnerProfileModel.fromJson(
        ownerData,
      );

      return true;
    } catch (e) {
      if (sessionVersion != _sessionVersion) {
        return false;
      }

      _errorMessage = _cleanError(e);

      return false;
    } finally {
      if (sessionVersion == _sessionVersion) {
        _isUpdating = false;
        notifyListeners();
      }
    }
  }

  // ============================================================
  // REFRESH PROFILE
  // ============================================================

  Future<bool> refreshProfile() async {
    return loadProfile();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // ERROR CLEANER
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }
}
