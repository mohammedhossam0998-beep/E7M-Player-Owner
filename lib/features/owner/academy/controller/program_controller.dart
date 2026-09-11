import 'package:flutter/foundation.dart';

import '../models/program_model.dart';
import '../repository/program_repository_impl.dart';

class ProgramController extends ChangeNotifier {
  final ProgramRepositoryImpl repository;

  ProgramController({
    required this.repository,
  });

  // ============================================================
  // STATE
  // ============================================================

  List<ProgramModel> _programs = [];

  bool _isLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<ProgramModel> get programs =>
      List.unmodifiable(_programs);

  bool get isLoading => _isLoading;

  bool get isCreating => _isCreating;

  bool get isUpdating => _isUpdating;

  bool get isDeleting => _isDeleting;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  bool get hasPrograms => _programs.isNotEmpty;

  // ============================================================
  // LOAD PROGRAMS
  // ============================================================

  Future<void> loadPrograms({
    required int academyId,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await repository.getAcademyPrograms(
        academyId: academyId,
      );

      _programs = result;
    } catch (error) {
      _programs = [];
      _errorMessage = _cleanError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CREATE PROGRAM
  // ============================================================

  Future<ProgramModel?> createProgram({
    required int academyId,
    required ProgramModel program,
  }) async {
    _isCreating = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final createdProgram =
      await repository.createProgram(
        academyId: academyId,
        program: program,
      );

      _programs = [
        createdProgram,
        ..._programs,
      ];

      return createdProgram;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return null;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  // ============================================================
  // UPDATE PROGRAM
  // ============================================================

  Future<ProgramModel?> updateProgram({
    required int academyId,
    required int programId,
    required ProgramModel program,
  }) async {
    _isUpdating = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final updatedProgram =
      await repository.updateProgram(
        academyId: academyId,
        programId: programId,
        program: program,
      );

      final index = _programs.indexWhere(
            (item) => item.id == programId,
      );

      if (index != -1) {
        final updatedList =
        List<ProgramModel>.from(
          _programs,
        );

        updatedList[index] = updatedProgram;

        _programs = updatedList;
      }

      return updatedProgram;
    } catch (error) {
      _errorMessage = _cleanError(error);
      return null;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // ============================================================
  // DELETE PROGRAM
  // ============================================================

  Future<bool> deleteProgram({
    required int academyId,
    required int programId,
  }) async {
    _isDeleting = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await repository.deleteProgram(
        academyId: academyId,
        programId: programId,
      );

      _programs.removeWhere(
            (item) => item.id == programId,
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

  Future<void> refreshPrograms({
    required int academyId,
  }) async {
    await loadPrograms(
      academyId: academyId,
    );
  }

  // ============================================================
  // ERROR CLEANER
  // ============================================================

  String _cleanError(
      Object error,
      ) {
    return error.toString().replaceFirst(
      'Exception: ',
      '',
    );
  }
}