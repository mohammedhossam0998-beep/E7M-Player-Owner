import 'package:flutter/foundation.dart';

import '../models/academy_coach_model.dart';
import '../repository/academy_coach_repository_impl.dart';

class AcademyCoachController extends ChangeNotifier {
  final AcademyCoachRepositoryImpl repository;

  AcademyCoachController({
    required this.repository,
  });

  // ============================================================
  // STATE
  // ============================================================

  List<AcademyCoachModel> _coaches = [];

  List<AcademyCoachModel> _availableCoaches = [];

  bool _isLoading = false;
  bool _isLoadingAvailable = false;
  bool _isAssigning = false;
  bool _isUpdating = false;
  bool _isRemoving = false;

  String? _errorMessage;
  String? _availableErrorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<AcademyCoachModel> get coaches =>
      List.unmodifiable(_coaches);

  List<AcademyCoachModel> get availableCoaches =>
      List.unmodifiable(_availableCoaches);

  bool get isLoading => _isLoading;

  bool get isLoadingAvailable =>
      _isLoadingAvailable;

  bool get isAssigning => _isAssigning;

  bool get isUpdating => _isUpdating;

  bool get isRemoving => _isRemoving;

  String? get errorMessage => _errorMessage;

  String? get availableErrorMessage =>
      _availableErrorMessage;

  bool get hasError =>
      _errorMessage != null;

  bool get hasAvailableError =>
      _availableErrorMessage != null;

  bool get hasCoaches =>
      _coaches.isNotEmpty;

  bool get hasAvailableCoaches =>
      _availableCoaches.isNotEmpty;

  // ============================================================
  // LOAD ACADEMY COACHES
  // ============================================================

  Future<void> loadCoaches({
    required int academyId,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await repository.getAcademyCoaches(
        academyId: academyId,
      );

      _coaches = result;
    } catch (error) {
      _coaches = [];
      _errorMessage = _cleanError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // LOAD AVAILABLE COACHES
  // ============================================================

  Future<void> loadAvailableCoaches({
    required int academyId,
  }) async {
    _isLoadingAvailable = true;
    _availableErrorMessage = null;

    notifyListeners();

    try {
      final result =
      await repository.getAvailableCoaches(
        academyId: academyId,
      );

      _availableCoaches = result;
    } catch (error) {
      _availableCoaches = [];
      _availableErrorMessage =
          _cleanError(error);
    } finally {
      _isLoadingAvailable = false;
      notifyListeners();
    }
  }

  // ============================================================
  // ASSIGN COACH
  // ============================================================

  Future<AcademyCoachModel?> assignCoach({
    required int academyId,
    required int coachId,
    required String role,
  }) async {
    _isAssigning = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final coach =
      await repository.assignCoach(
        academyId: academyId,
        coachId: coachId,
        role: role,
      );

      _coaches = [
        coach,
        ..._coaches,
      ];

      _availableCoaches.removeWhere(
            (item) => item.coachId == coachId,
      );

      return coach;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return null;
    } finally {
      _isAssigning = false;
      notifyListeners();
    }
  }

  // ============================================================
  // UPDATE COACH ASSIGNMENT
  // ============================================================

  Future<AcademyCoachModel?> updateCoachAssignment({
    required int academyId,
    required int coachId,
    required String role,
  }) async {
    _isUpdating = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final updatedCoach =
      await repository.updateCoachAssignment(
        academyId: academyId,
        coachId: coachId,
        role: role,
      );

      final index = _coaches.indexWhere(
            (coach) => coach.coachId == coachId,
      );

      if (index != -1) {
        final updatedList =
        List<AcademyCoachModel>.from(
          _coaches,
        );

        updatedList[index] = updatedCoach;

        _coaches = updatedList;
      }

      return updatedCoach;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return null;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // ============================================================
  // REMOVE COACH
  // ============================================================

  Future<bool> removeCoach({
    required int academyId,
    required int coachId,
  }) async {
    _isRemoving = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await repository.removeCoach(
        academyId: academyId,
        coachId: coachId,
      );

      _coaches.removeWhere(
            (coach) => coach.coachId == coachId,
      );

      return true;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return false;
    } finally {
      _isRemoving = false;
      notifyListeners();
    }
  }

  // ============================================================
  // REFRESH ACADEMY COACHES
  // ============================================================

  Future<void> refreshCoaches({
    required int academyId,
  }) async {
    await loadCoaches(
      academyId: academyId,
    );
  }

  // ============================================================
  // REFRESH AVAILABLE COACHES
  // ============================================================

  Future<void> refreshAvailableCoaches({
    required int academyId,
  }) async {
    await loadAvailableCoaches(
      academyId: academyId,
    );
  }

  // ============================================================
  // CLEAR ERRORS
  // ============================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearAvailableError() {
    _availableErrorMessage = null;
    notifyListeners();
  }

  void clearAllErrors() {
    _errorMessage = null;
    _availableErrorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // ERROR CLEANER
  // ============================================================

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );
  }
}