import '../../../../core/network/api_client.dart';
import '../models/enrollment_model.dart';

class EnrollmentService {
  final ApiClient _apiClient;

  EnrollmentService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET ACADEMY PLAYERS / ENROLLMENTS
  // GET /api/owner/academies/:academyId/players
  // ============================================================

  Future<List<EnrollmentModel>> getAcademyPlayers({
    required int academyId,
  }) async {
    final response = await _apiClient.get(
      '/owner/academies/$academyId/players',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid academy players response',
      );
    }

    final players = response['players'];

    if (players is! List) {
      return [];
    }

    return players
        .whereType<Map<String, dynamic>>()
        .map(
      EnrollmentModel.fromJson,
    )
        .toList();
  }

  // ============================================================
  // GET ENROLLMENT DETAILS
  // GET /api/owner/enrollments/:id
  // ============================================================

  Future<EnrollmentModel> getEnrollmentById({
    required int enrollmentId,
  }) async {
    final response = await _apiClient.get(
      '/owner/enrollments/$enrollmentId',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid enrollment response',
      );
    }

    final enrollment =
    response['enrollment'];

    if (enrollment is! Map<String, dynamic>) {
      throw Exception(
        'Enrollment data not found in server response',
      );
    }

    return EnrollmentModel.fromJson(
      enrollment,
    );
  }

  // ============================================================
  // APPROVE ENROLLMENT
  // PATCH /api/owner/enrollments/:id/approve
  // ============================================================

  Future<EnrollmentModel> approveEnrollment({
    required int enrollmentId,
  }) async {
    final response = await _apiClient.patch(
      '/owner/enrollments/$enrollmentId/approve',
      {},
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid approve enrollment response',
      );
    }

    final enrollment =
    response['enrollment'];

    if (enrollment is! Map<String, dynamic>) {
      throw Exception(
        'Approved enrollment data not found',
      );
    }

    return EnrollmentModel.fromJson(
      enrollment,
    );
  }

  // ============================================================
  // REJECT ENROLLMENT
  // PATCH /api/owner/enrollments/:id/reject
  // ============================================================

  Future<EnrollmentModel> rejectEnrollment({
    required int enrollmentId,
  }) async {
    final response = await _apiClient.patch(
      '/owner/enrollments/$enrollmentId/reject',
      {},
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid reject enrollment response',
      );
    }

    final enrollment =
    response['enrollment'];

    if (enrollment is! Map<String, dynamic>) {
      throw Exception(
        'Rejected enrollment data not found',
      );
    }

    return EnrollmentModel.fromJson(
      enrollment,
    );
  }
}