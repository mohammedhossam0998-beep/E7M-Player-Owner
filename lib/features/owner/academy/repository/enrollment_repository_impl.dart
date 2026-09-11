import '../models/enrollment_model.dart';
import '../services/enrollment_service.dart';

class EnrollmentRepositoryImpl {
  final EnrollmentService service;

  EnrollmentRepositoryImpl({
    required this.service,
  });

  // ============================================================
  // GET ACADEMY PLAYERS / ENROLLMENTS
  // ============================================================

  Future<List<EnrollmentModel>> getAcademyPlayers({
    required int academyId,
  }) async {
    return service.getAcademyPlayers(
      academyId: academyId,
    );
  }

  // ============================================================
  // GET ENROLLMENT DETAILS
  // ============================================================

  Future<EnrollmentModel> getEnrollmentById({
    required int enrollmentId,
  }) async {
    return service.getEnrollmentById(
      enrollmentId: enrollmentId,
    );
  }

  // ============================================================
  // APPROVE ENROLLMENT
  // ============================================================

  Future<EnrollmentModel> approveEnrollment({
    required int enrollmentId,
  }) async {
    return service.approveEnrollment(
      enrollmentId: enrollmentId,
    );
  }

  // ============================================================
  // REJECT ENROLLMENT
  // ============================================================

  Future<EnrollmentModel> rejectEnrollment({
    required int enrollmentId,
  }) async {
    return service.rejectEnrollment(
      enrollmentId: enrollmentId,
    );
  }
}