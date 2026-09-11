import '../../../../core/network/api_client.dart';
import '../models/academy_coach_model.dart';

class AcademyCoachService {
  final ApiClient _apiClient;

  AcademyCoachService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET AVAILABLE COACHES
  // GET /api/owner/academies/:academyId/coaches/available
  // ============================================================

  Future<List<AcademyCoachModel>> getAvailableCoaches({
    required int academyId,
  }) async {
    final response = await _apiClient.get(
      '/owner/academies/$academyId/coaches/available',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid available coaches response',
      );
    }

    final coaches = response['coaches'];

    if (coaches is! List) {
      return [];
    }

    return coaches
        .whereType<Map<String, dynamic>>()
        .map(
          (coach) => AcademyCoachModel.fromJson(
        coach,
      ),
    )
        .toList();
  }

  // ============================================================
  // ASSIGN COACH
  // POST /api/owner/academies/:academyId/coaches
  // ============================================================

  Future<AcademyCoachModel> assignCoach({
    required int academyId,
    required int coachId,
    required String role,
  }) async {
    final response = await _apiClient.post(
      '/owner/academies/$academyId/coaches',
      {
        'coach_id': coachId,
        'role': role,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid assign coach response',
      );
    }

    final assignment = response['academy_coach'];

    if (assignment is! Map<String, dynamic>) {
      throw Exception(
        'Coach assignment data not found',
      );
    }

    return AcademyCoachModel.fromJson(
      assignment,
    );
  }

  // ============================================================
  // GET ACADEMY COACHES
  // GET /api/owner/academies/:academyId/coaches
  // ============================================================

  Future<List<AcademyCoachModel>>
  getAcademyCoaches({
    required int academyId,
  }) async {
    final response = await _apiClient.get(
      '/owner/academies/$academyId/coaches',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid academy coaches response',
      );
    }

    final coaches = response['coaches'];

    if (coaches is! List) {
      return [];
    }

    return coaches
        .whereType<Map<String, dynamic>>()
        .map(
      AcademyCoachModel.fromJson,
    )
        .toList();
  }

  // ============================================================
  // UPDATE COACH ASSIGNMENT
  // PUT /api/owner/academies/:academyId/coaches/:coachId
  // ============================================================

  Future<AcademyCoachModel>
  updateCoachAssignment({
    required int academyId,
    required int coachId,
    required String role,
  }) async {
    final response = await _apiClient.put(
      '/owner/academies/$academyId/coaches/$coachId',
      {
        'role': role,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid update coach assignment response',
      );
    }

    final assignment =
    response['academy_coach'];

    if (assignment is! Map<String, dynamic>) {
      throw Exception(
        'Updated coach assignment not found',
      );
    }

    return AcademyCoachModel.fromJson(
      assignment,
    );
  }

  // ============================================================
  // REMOVE COACH
  // DELETE /api/owner/academies/:academyId/coaches/:coachId
  // ============================================================

  Future<void> removeCoach({
    required int academyId,
    required int coachId,
  }) async {
    await _apiClient.delete(
      '/owner/academies/$academyId/coaches/$coachId',
    );
  }
}