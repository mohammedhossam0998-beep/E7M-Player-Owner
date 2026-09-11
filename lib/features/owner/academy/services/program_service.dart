import '../../../../core/network/api_client.dart';
import '../models/program_model.dart';

class ProgramService {
  final ApiClient _apiClient;

  ProgramService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // CREATE PROGRAM
  // POST /api/owner/academies/:academyId/programs
  // ============================================================

  Future<ProgramModel> createProgram({
    required int academyId,
    required ProgramModel program,
  }) async {
    final response = await _apiClient.post(
      '/owner/academies/$academyId/programs',
      program.toRequestJson(),
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid create program response',
      );
    }

    final programData = response['program'];

    if (programData is! Map<String, dynamic>) {
      throw Exception(
        'Program data not found in server response',
      );
    }

    return ProgramModel.fromJson(
      programData,
    );
  }

  // ============================================================
  // GET ACADEMY PROGRAMS
  // GET /api/owner/academies/:academyId/programs
  // ============================================================

  Future<List<ProgramModel>> getAcademyPrograms({
    required int academyId,
  }) async {
    final response = await _apiClient.get(
      '/owner/academies/$academyId/programs',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid academy programs response',
      );
    }

    final programs = response['programs'];

    if (programs is! List) {
      return [];
    }

    return programs
        .whereType<Map<String, dynamic>>()
        .map(
      ProgramModel.fromJson,
    )
        .toList();
  }

  // ============================================================
  // UPDATE PROGRAM
  // PUT /api/owner/academies/:academyId/programs/:programId
  // ============================================================

  Future<ProgramModel> updateProgram({
    required int academyId,
    required int programId,
    required ProgramModel program,
  }) async {
    final response = await _apiClient.put(
      '/owner/academies/$academyId/programs/$programId',
      program.toRequestJson(),
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid update program response',
      );
    }

    final programData = response['program'];

    if (programData is! Map<String, dynamic>) {
      throw Exception(
        'Updated program data not found',
      );
    }

    return ProgramModel.fromJson(
      programData,
    );
  }

  // ============================================================
  // DELETE PROGRAM
  // DELETE /api/owner/academies/:academyId/programs/:programId
  // ============================================================

  Future<void> deleteProgram({
    required int academyId,
    required int programId,
  }) async {
    final response = await _apiClient.delete(
      '/owner/academies/$academyId/programs/$programId',
    );

    // ------------------------------------------------------------
    // ApiClient may return null for successful DELETE.
    // We don't need to parse a response body here.
    // ------------------------------------------------------------

    return;
  }
}