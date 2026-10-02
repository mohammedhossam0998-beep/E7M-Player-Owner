import 'package:image_picker/image_picker.dart';

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
    await _api.createProfile(data);

    // POST /player/profile returns only the football fields (no name,
    // email, phone or image), so reload the full profile.
    return getMyProfile();
  }

  // ============================================================
  // UPDATE PROFILE
  // ============================================================

  Future<PlayerProfileModel> updateProfile(
      Map<String, dynamic> data,
      ) async {
    await _api.updateProfile(data);

    // PUT /player/profile returns only the football fields (no name,
    // email, phone or image). Reload the full profile so the shared
    // provider never ends up with missing account data.
    return getMyProfile();
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
      XFile image,
      ) async {
    await _api.uploadProfileImage(image);

    // بعد رفع الصورة نعيد تحميل الـ Profile
    // لضمان وجود الصورة مع باقي بيانات اللاعب.
    return getMyProfile();
  }
}