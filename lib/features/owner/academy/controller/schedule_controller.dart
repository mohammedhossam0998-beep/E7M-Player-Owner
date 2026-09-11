import 'package:flutter/foundation.dart';

import '../models/schedule_model.dart';
import '../repository/schedule_repository_impl.dart';

class ScheduleController extends ChangeNotifier {
  final ScheduleRepositoryImpl repository;

  ScheduleController({
    required this.repository,
  });

  // ============================================================
  // STATE
  // ============================================================

  List<ScheduleModel> _schedules = [];

  bool _isLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<ScheduleModel> get schedules =>
      List.unmodifiable(_schedules);

  bool get isLoading => _isLoading;

  bool get isCreating => _isCreating;

  bool get isUpdating => _isUpdating;

  bool get isDeleting => _isDeleting;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  bool get hasSchedules => _schedules.isNotEmpty;

  // ============================================================
  // LOAD SCHEDULE
  // ============================================================

  Future<void> loadSchedule({
    required int academyId,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await repository.getAcademySchedule(
        academyId: academyId,
      );

      _schedules = result;
    } catch (error) {
      _schedules = [];
      _errorMessage = _cleanError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CREATE SCHEDULE
  // ============================================================

  Future<ScheduleModel?> createSchedule({
    required int academyId,
    required ScheduleModel schedule,
  }) async {
    _isCreating = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final createdSchedule =
      await repository.createSchedule(
        academyId: academyId,
        schedule: schedule,
      );

      _schedules = [
        ..._schedules,
        createdSchedule,
      ];

      return createdSchedule;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return null;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  // ============================================================
  // UPDATE SCHEDULE
  // ============================================================

  Future<ScheduleModel?> updateSchedule({
    required int academyId,
    required int scheduleId,
    required ScheduleModel schedule,
  }) async {
    _isUpdating = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final updatedSchedule =
      await repository.updateSchedule(
        academyId: academyId,
        scheduleId: scheduleId,
        schedule: schedule,
      );

      final index = _schedules.indexWhere(
            (item) => item.id == scheduleId,
      );

      if (index != -1) {
        final updatedList =
        List<ScheduleModel>.from(
          _schedules,
        );

        updatedList[index] = updatedSchedule;

        _schedules = updatedList;
      }

      return updatedSchedule;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return null;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // ============================================================
  // DELETE SCHEDULE
  // ============================================================

  Future<bool> deleteSchedule({
    required int academyId,
    required int scheduleId,
  }) async {
    _isDeleting = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await repository.deleteSchedule(
        academyId: academyId,
        scheduleId: scheduleId,
      );

      _schedules.removeWhere(
            (item) => item.id == scheduleId,
      );

      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return false;
    } finally {
      _isDeleting = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshSchedule({
    required int academyId,
  }) async {
    await loadSchedule(
      academyId: academyId,
    );
  }

  // ============================================================
  // ERROR CLEANER
  // ============================================================

  String _cleanError(Object error) {
    return error.toString().replaceFirst(
      'Exception: ',
      '',
    );
  }
}