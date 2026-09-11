import 'dart:io';

import '../models/player_profile_model.dart';
import 'player_profile_api.dart';

class PlayerProfileRepository {
  final PlayerProfileApi _api;

  PlayerProfileRepository({
    PlayerProfileApi? api,
  }) : _api = api ?? PlayerProfileApi();

  // ============================================================
  // GET MY PROFILE
  // ============================================================

  Future<PlayerProfileModel> getMyProfile() async {
    final response = await _api.getMyProfile();

    final profile = response['profile'];

    if (profile is! Map<String, dynamic>) {
      throw Exception('Invalid player profile data');
    }

    return PlayerProfileModel.fromJson(profile);
  }

  // ============================================================
  // CREATE PROFILE
  // ============================================================

  Future<PlayerProfileModel> createProfile(
      Map<String, dynamic> data,
      ) async {
    final response = await _api.createProfile(data);

    final profile = response['profile'];

    if (profile is! Map<String, dynamic>) {
      throw Exception('Invalid created player profile data');
    }

    return PlayerProfileModel.fromJson(profile);
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<PlayerProfileModel> updateProfile(
      Map<String, dynamic> data,
      ) async {
    final response = await _api.updateProfile(data);

    final profile = response['profile'];

    if (profile is! Map<String, dynamic>) {
      throw Exception('Invalid updated player profile data');
    }

    return PlayerProfileModel.fromJson(profile);
  }

  // ============================================================
  // UPDATE ACCOUNT
  // ============================================================

  Future<PlayerProfileModel> updateAccount(
      Map<String, dynamic> data,
      ) async {
    await _api.updateAccount(data);

    // بعد تحديث بيانات الحساب نعيد تحميل الـ Profile
    // لضمان رجوع بيانات الحساب + بيانات player_profiles كاملة.
    return getMyProfile();
  }

  // ============================================================
  // UPLOAD PROFILE IMAGE
  // ============================================================

  Future<PlayerProfileModel> uploadProfileImage(
      File image,
      ) async {
    await _api.uploadProfileImage(image);

    // بعد رفع الصورة نعيد تحميل الـ Profile
    // لضمان وجود الصورة مع باقي بيانات اللاعب.
    return getMyProfile();
  }
}