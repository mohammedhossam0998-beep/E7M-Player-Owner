import '../models/academy_coach_model.dart';
import '../services/academy_coach_service.dart';

class AcademyCoachRepositoryImpl {
  final AcademyCoachService service;

  AcademyCoachRepositoryImpl({
    required this.service,
  });

  // ============================================================
  // GET AVAILABLE COACHES
  // ============================================================

  Future<List<AcademyCoachModel>> getAvailableCoaches({
    required int academyId,
  }) async {
    return service.getAvailableCoaches(
      academyId: academyId,
    );
  }

  // ============================================================
  // ASSIGN COACH
  // ============================================================

  Future<AcademyCoachModel> assignCoach({
    required int academyId,
    required int coachId,
    required String role,
  }) async {
    return service.assignCoach(
      academyId: academyId,
      coachId: coachId,
      role: role,
    );
  }

  // ============================================================
  // GET ACADEMY COACHES
  // ============================================================

  Future<List<AcademyCoachModel>> getAcademyCoaches({
    required int academyId,
  }) async {
    return service.getAcademyCoaches(
      academyId: academyId,
    );
  }

  // ============================================================
  // UPDATE COACH ASSIGNMENT
  // ============================================================

  Future<AcademyCoachModel> updateCoachAssignment({
    required int academyId,
    required int coachId,
    required String role,
  }) async {
    return service.updateCoachAssignment(
      academyId: academyId,
      coachId: coachId,
      role: role,
    );
  }

  // ============================================================
  // REMOVE COACH
  // ============================================================

  Future<void> removeCoach({
    required int academyId,
    required int coachId,
  }) async {
    return service.removeCoach(
      academyId: academyId,
      coachId: coachId,
    );
  }
}