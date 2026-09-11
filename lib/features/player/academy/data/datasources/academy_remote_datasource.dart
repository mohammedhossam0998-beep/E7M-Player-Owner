import 'package:e7m/core/network/api_client.dart';

import '../models/academy_model.dart';
import '../models/academy_program_model.dart';
import '../models/academy_enrollment_model.dart';

class AcademyRemoteDataSource {
  final ApiClient _apiClient;

  AcademyRemoteDataSource({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET ALL APPROVED ACADEMIES
  // GET /api/player/academies
  // ============================================================

  Future<List<AcademyModel>> getAcademies() async {
    final response = await _apiClient.get(
      '/player/academies',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid academies response');
    }

    final data = response['data'];

    if (data is! List) {
      throw Exception('Invalid academies data');
    }

    return data
        .map(
          (item) => AcademyModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }

  // ============================================================
  // GET ACADEMY DETAILS
  // GET /api/player/academies/:academyId
  // ============================================================

  Future<AcademyModel> getAcademyById(
      int academyId,
      ) async {
    final response = await _apiClient.get(
      '/player/academies/$academyId',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid academy response');
    }

    final data = response['data'];

    if (data is! Map) {
      throw Exception('Invalid academy data');
    }

    return AcademyModel.fromJson(
      Map<String, dynamic>.from(data),
    );
  }

  // ============================================================
  // GET ACADEMY PROGRAMS
  // GET /api/player/academies/:academyId/programs
  // ============================================================

  Future<List<AcademyProgramModel>> getAcademyPrograms(
      int academyId,
      ) async {
    final response = await _apiClient.get(
      '/player/academies/$academyId/programs',
    );

    print('🏟️ ACADEMY PROGRAMS RESPONSE: $response');

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid programs response');
    }

    final data = response['data'];

    print('📚 ACADEMY PROGRAMS DATA: $data');
    print('📊 ACADEMY PROGRAMS DATA TYPE: ${data.runtimeType}');

    if (data is! List) {
      throw Exception('Invalid programs data');
    }

    final programs = data
        .map(
          (item) => AcademyProgramModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();

    print('✅ PARSED PROGRAMS COUNT: ${programs.length}');

    return programs;
  }

  // ============================================================
  // ENROLL IN ACADEMY PROGRAM
  // POST /api/player/academies/:academyId/programs/:programId/enroll
  // ============================================================

  Future<Map<String, dynamic>> enrollInProgram({
    required int academyId,
    required int programId,
  }) async {
    final response = await _apiClient.post(
      '/player/academies/$academyId/programs/$programId/enroll',
      {},
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid enrollment response');
    }

    return response;
  }

  // ============================================================
  // GET MY ACADEMY ENROLLMENTS
  // GET /api/player/academies/enrollments
  // ============================================================

  Future<List<AcademyEnrollmentModel>>
  getMyEnrollments() async {
    final response = await _apiClient.get(
      '/player/academies/enrollments',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid enrollments response');
    }

    final data = response['enrollments'];

    if (data is! List) {
      throw Exception('Invalid enrollments data');
    }

    return data
        .map(
          (item) => AcademyEnrollmentModel.fromJson(
        Map<String, dynamic>.from(item),
      ),
    )
        .toList();
  }
}