import '../models/program_model.dart';
import '../services/program_service.dart';

class ProgramRepositoryImpl {
  final ProgramService service;

  ProgramRepositoryImpl({
    required this.service,
  });

  // ============================================================
  // CREATE PROGRAM
  // ============================================================

  Future<ProgramModel> createProgram({
    required int academyId,
    required ProgramModel program,
  }) async {
    return service.createProgram(
      academyId: academyId,
      program: program,
    );
  }

  // ============================================================
  // GET PROGRAMS
  // ============================================================

  Future<List<ProgramModel>> getAcademyPrograms({
    required int academyId,
  }) async {
    return service.getAcademyPrograms(
      academyId: academyId,
    );
  }

  // ============================================================
  // UPDATE PROGRAM
  // ============================================================

  Future<ProgramModel> updateProgram({
    required int academyId,
    required int programId,
    required ProgramModel program,
  }) async {
    return service.updateProgram(
      academyId: academyId,
      programId: programId,
      program: program,
    );
  }

  // ============================================================
  // DELETE PROGRAM
  // ============================================================

  Future<void> deleteProgram({
    required int academyId,
    required int programId,
  }) async {
    return service.deleteProgram(
      academyId: academyId,
      programId: programId,
    );
  }
}