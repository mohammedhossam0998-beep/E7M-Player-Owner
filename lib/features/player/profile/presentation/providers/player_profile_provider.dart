import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/player_profile_repository.dart';
import '../../models/player_profile_model.dart';

class PlayerProfileProvider extends ChangeNotifier {
  final PlayerProfileRepository _repository;

  PlayerProfileProvider({
    PlayerProfileRepository? repository,
  }) : _repository = repository ?? PlayerProfileRepository();

  // ============================================================
  // STATE
  // ============================================================

  PlayerProfileModel? _profile;

  bool _isLoading = false;
  bool _isSaving = false;
  bool _isUploadingImage = false;

  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  PlayerProfileModel? get profile => _profile;

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  bool get isUploadingImage => _isUploadingImage;

  String? get errorMessage => _errorMessage;

  bool get hasProfile => _profile != null;

  bool get hasError =>
      _errorMessage != null && _errorMessage!.isNotEmpty;

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> loadProfile() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _repository.getMyProfile();

      _profile = profile;
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CREATE PROFILE
  // ============================================================

  Future<bool> createProfile(
      Map<String, dynamic> data,
      ) async {
    _setSaving(true);
    _clearError();

    try {
      final profile = await _repository.createProfile(data);

      _profile = profile;

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return false;
    } finally {
      _setSaving(false);
    }
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<bool> updateProfile(
      Map<String, dynamic> data,
      ) async {
    _setSaving(true);
    _clearError();

    try {
      final profile = await _repository.updateProfile(data);

      _profile = profile;

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return false;
    } finally {
      _setSaving(false);
    }
  }

  // ============================================================
  // UPDATE ACCOUNT
  // ============================================================

  Future<bool> updateAccount(
      Map<String, dynamic> data,
      ) async {
    _setSaving(true);
    _clearError();

    try {
      final profile = await _repository.updateAccount(data);

      _profile = profile;

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return false;
    } finally {
      _setSaving(false);
    }
  }

  // ============================================================
  // UPLOAD PROFILE IMAGE
  // ============================================================

  Future<bool> uploadProfileImage(
      XFile image,
      ) async {
    _setUploadingImage(true);
    _clearError();

    try {
      final profile =
      await _repository.uploadProfileImage(image);

      _profile = profile;

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return false;
    } finally {
      _setUploadingImage(false);
    }
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _clearError();
  }

  // ============================================================
  // CLEAR PROFILE
  // ============================================================

  void clearProfile() {
    _profile = null;
    _clearError();
    notifyListeners();
  }

  // ============================================================
  // INTERNAL STATE METHODS
  // ============================================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setSaving(bool value) {
    _isSaving = value;
    notifyListeners();
  }

  void _setUploadingImage(bool value) {
    _isUploadingImage = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // ERROR CLEANUP
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }
}