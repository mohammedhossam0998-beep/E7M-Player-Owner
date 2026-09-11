import '../../../../core/network/api_client.dart';
import '../models/schedule_model.dart';

class ScheduleService {
  final ApiClient _apiClient;

  ScheduleService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // CREATE SCHEDULE
  // POST /api/owner/academies/:academyId/schedule
  // ============================================================

  Future<ScheduleModel> createSchedule({
    required int academyId,
    required ScheduleModel schedule,
  }) async {
    final response = await _apiClient.post(
      '/owner/academies/$academyId/schedule',
      schedule.toRequestJson(),
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid create schedule response',
      );
    }

    final scheduleData = response['schedule'];

    if (scheduleData is! Map<String, dynamic>) {
      throw Exception(
        'Schedule data not found in server response',
      );
    }

    return ScheduleModel.fromJson(
      scheduleData,
    );
  }

  // ============================================================
  // GET ACADEMY SCHEDULE
  // GET /api/owner/academies/:academyId/schedule
  // ============================================================

  Future<List<ScheduleModel>> getAcademySchedule({
    required int academyId,
  }) async {
    final response = await _apiClient.get(
      '/owner/academies/$academyId/schedule',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid academy schedule response',
      );
    }

    final schedules = response['schedule'];

    if (schedules is! List) {
      return [];
    }

    return schedules
        .whereType<Map<String, dynamic>>()
        .map(
      ScheduleModel.fromJson,
    )
        .toList();
  }

  // ============================================================
  // UPDATE SCHEDULE
  // PUT /api/owner/academies/:academyId/schedule/:scheduleId
  // ============================================================

  Future<ScheduleModel> updateSchedule({
    required int academyId,
    required int scheduleId,
    required ScheduleModel schedule,
  }) async {
    final response = await _apiClient.put(
      '/owner/academies/$academyId/schedule/$scheduleId',
      schedule.toRequestJson(),
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid update schedule response',
      );
    }

    final scheduleData = response['schedule'];

    if (scheduleData is! Map<String, dynamic>) {
      throw Exception(
        'Updated schedule data not found',
      );
    }

    return ScheduleModel.fromJson(
      scheduleData,
    );
  }

  // ============================================================
  // DELETE SCHEDULE
  // DELETE /api/owner/academies/:academyId/schedule/:scheduleId
  // ============================================================

  Future<void> deleteSchedule({
    required int academyId,
    required int scheduleId,
  }) async {
    await _apiClient.delete(
      '/owner/academies/$academyId/schedule/$scheduleId',
    );
  }
}