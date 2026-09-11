import 'package:flutter/foundation.dart';

import '../../data/models/academy_model.dart';
import '../../data/models/academy_program_model.dart';
import '../../data/models/academy_enrollment_model.dart';
import '../../data/repositories/academy_repository.dart';

class AcademyProvider extends ChangeNotifier {
  final AcademyRepository _repository;

  AcademyProvider({
    AcademyRepository? repository,
  }) : _repository = repository ?? AcademyRepository();

  // ============================================================
  // ACADEMIES
  // ============================================================

  List<AcademyModel> _academies = [];

  List<AcademyModel> get academies => List.unmodifiable(_academies);

  // ============================================================
  // SELECTED ACADEMY
  // ============================================================

  AcademyModel? _selectedAcademy;

  AcademyModel? get selectedAcademy => _selectedAcademy;

  // ============================================================
  // PROGRAMS
  // ============================================================

  List<AcademyProgramModel> _programs = [];

  List<AcademyProgramModel> get programs =>
      List.unmodifiable(_programs);

  // ============================================================
  // MY ENROLLMENTS
  // ============================================================

  List<AcademyEnrollmentModel> _myEnrollments = [];

  List<AcademyEnrollmentModel> get myEnrollments =>
      List.unmodifiable(_myEnrollments);

  // ============================================================
  // LOADING STATES
  // ============================================================

  bool _isLoadingAcademies = false;
  bool _isLoadingDetails = false;
  bool _isLoadingPrograms = false;
  bool _isLoadingEnrollments = false;
  bool _isEnrolling = false;

  bool get isLoadingAcademies => _isLoadingAcademies;
  bool get isLoadingDetails => _isLoadingDetails;
  bool get isLoadingPrograms => _isLoadingPrograms;
  bool get isLoadingEnrollments => _isLoadingEnrollments;
  bool get isEnrolling => _isEnrolling;

  // ============================================================
  // GENERAL LOADING
  // ============================================================

  bool get isLoading =>
      _isLoadingAcademies ||
          _isLoadingDetails ||
          _isLoadingPrograms ||
          _isLoadingEnrollments ||
          _isEnrolling;

  // ============================================================
  // ERROR
  // ============================================================

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // LOAD ACADEMIES
  // ============================================================

  Future<void> loadAcademies() async {
    _isLoadingAcademies = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _academies = await _repository.getAcademies();
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
    } finally {
      _isLoadingAcademies = false;
      notifyListeners();
    }
  }

  // ============================================================
  // LOAD ACADEMY DETAILS
  // ============================================================

  Future<void> loadAcademyDetails(
      int academyId,
      ) async {
    _isLoadingDetails = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedAcademy =
      await _repository.getAcademyById(academyId);
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  // ============================================================
  // LOAD ACADEMY PROGRAMS
  // ============================================================

  Future<void> loadAcademyPrograms(
      int academyId,
      ) async {
    _isLoadingPrograms = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _programs =
      await _repository.getAcademyPrograms(academyId);
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
    } finally {
      _isLoadingPrograms = false;
      notifyListeners();
    }
  }

  // ============================================================
  // LOAD DETAILS + PROGRAMS
  // ============================================================

  Future<void> loadAcademyData(
      int academyId,
      ) async {
    _errorMessage = null;
    notifyListeners();

    await Future.wait([
      loadAcademyDetails(academyId),
      loadAcademyPrograms(academyId),
    ]);
  }

  // ============================================================
  // ENROLL IN PROGRAM
  // ============================================================

  Future<bool> enrollInProgram({
    required int academyId,
    required int programId,
  }) async {
    _isEnrolling = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _repository.enrollInProgram(
        academyId: academyId,
        programId: programId,
      );

      // Refresh player's enrollments after successful enrollment.
      await loadMyEnrollments();

      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
      return false;
    } finally {
      _isEnrolling = false;
      notifyListeners();
    }
  }

  // ============================================================
  // LOAD MY ENROLLMENTS
  // ============================================================

  Future<void> loadMyEnrollments() async {
    _isLoadingEnrollments = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myEnrollments =
      await _repository.getMyEnrollments();
    } catch (e) {
      _errorMessage = _extractErrorMessage(e);
    } finally {
      _isLoadingEnrollments = false;
      notifyListeners();
    }
  }

  // ============================================================
  // RESET SELECTED ACADEMY DATA
  // ============================================================

  void clearSelectedAcademy() {
    _selectedAcademy = null;
    _programs = [];
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // ERROR HANDLER
  // ============================================================

  String _extractErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }
}