
import '../datasources/academy_remote_datasource.dart';
import '../models/academy_enrollment_model.dart';
import '../models/academy_model.dart';
import '../models/academy_program_model.dart';

class AcademyRepository {
final AcademyRemoteDataSource _remoteDataSource;

AcademyRepository({
AcademyRemoteDataSource? remoteDataSource,
}) : _remoteDataSource =
remoteDataSource ?? AcademyRemoteDataSource();

// ============================================================
// GET ALL APPROVED ACADEMIES
// ============================================================

Future<List<AcademyModel>> getAcademies() async {
return _remoteDataSource.getAcademies();
}

// ============================================================
// GET ACADEMY DETAILS
// ============================================================

Future<AcademyModel> getAcademyById(
int academyId,
) async {
return _remoteDataSource.getAcademyById(
academyId,
);
}

// ============================================================
// GET ACADEMY PROGRAMS
// ============================================================

Future<List<AcademyProgramModel>> getAcademyPrograms(
int academyId,
) async {
return _remoteDataSource.getAcademyPrograms(
academyId,
);
}

// ============================================================
// ENROLL IN ACADEMY PROGRAM
// ============================================================

Future<Map<String, dynamic>> enrollInProgram({
required int academyId,
required int programId,
}) async {
return _remoteDataSource.enrollInProgram(
academyId: academyId,
programId: programId,
);
}

// ============================================================
// GET MY ACADEMY ENROLLMENTS
// ============================================================

Future<List<AcademyEnrollmentModel>> getMyEnrollments() async {
return _remoteDataSource.getMyEnrollments();
}
}
