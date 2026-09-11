import '../models/schedule_model.dart';
import '../services/schedule_service.dart';

class ScheduleRepositoryImpl {
  final ScheduleService service;

  ScheduleRepositoryImpl({
    required this.service,
  });

  // ============================================================
  // CREATE SCHEDULE
  // ============================================================

  Future<ScheduleModel> createSchedule({
    required int academyId,
    required ScheduleModel schedule,
  }) async {
    return service.createSchedule(
      academyId: academyId,
      schedule: schedule,
    );
  }

  // ============================================================
  // GET ACADEMY SCHEDULE
  // ============================================================

  Future<List<ScheduleModel>> getAcademySchedule({
    required int academyId,
  }) async {
    return service.getAcademySchedule(
      academyId: academyId,
    );
  }

  // ============================================================
  // UPDATE SCHEDULE
  // ============================================================

  Future<ScheduleModel> updateSchedule({
    required int academyId,
    required int scheduleId,
    required ScheduleModel schedule,
  }) async {
    return service.updateSchedule(
      academyId: academyId,
      scheduleId: scheduleId,
      schedule: schedule,
    );
  }

  // ============================================================
  // DELETE SCHEDULE
  // ============================================================

  Future<void> deleteSchedule({
    required int academyId,
    required int scheduleId,
  }) async {
    return service.deleteSchedule(
      academyId: academyId,
      scheduleId: scheduleId,
    );
  }
}