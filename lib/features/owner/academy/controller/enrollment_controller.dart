import 'package:flutter/foundation.dart';

import '../models/enrollment_model.dart';
import '../repository/enrollment_repository_impl.dart';

class EnrollmentController extends ChangeNotifier {
  final EnrollmentRepositoryImpl repository;

  EnrollmentController({
    required this.repository,
  });

  // ============================================================
  // STATE
  // ============================================================

  List<EnrollmentModel> _enrollments = [];

  EnrollmentModel? _selectedEnrollment;

  bool _isLoading = false;
  bool _isLoadingDetails = false;
  bool _isApproving = false;
  bool _isRejecting = false;

  String? _errorMessage;
  String? _detailsErrorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<EnrollmentModel> get enrollments =>
      List.unmodifiable(_enrollments);

  EnrollmentModel? get selectedEnrollment =>
      _selectedEnrollment;

  bool get isLoading => _isLoading;

  bool get isLoadingDetails =>
      _isLoadingDetails;

  bool get isApproving => _isApproving;

  bool get isRejecting => _isRejecting;

  String? get errorMessage =>
      _errorMessage;

  String? get detailsErrorMessage =>
      _detailsErrorMessage;

  bool get hasError =>
      _errorMessage != null;

  bool get hasDetailsError =>
      _detailsErrorMessage != null;

  bool get hasEnrollments =>
      _enrollments.isNotEmpty;

  // ============================================================
  // LOAD ACADEMY PLAYERS
  // ============================================================

  Future<void> loadEnrollments({
    required int academyId,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await repository.getAcademyPlayers(
        academyId: academyId,
      );

      _enrollments = result;
    } catch (error) {
      _enrollments = [];
      _errorMessage =
          _cleanError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // LOAD ENROLLMENT DETAILS
  // ============================================================

  Future<EnrollmentModel?> loadEnrollmentById({
    required int enrollmentId,
  }) async {
    _isLoadingDetails = true;
    _detailsErrorMessage = null;

    notifyListeners();

    try {
      final enrollment =
      await repository.getEnrollmentById(
        enrollmentId: enrollmentId,
      );

      _selectedEnrollment =
          enrollment;

      return enrollment;
    } catch (error) {
      _selectedEnrollment = null;

      _detailsErrorMessage =
          _cleanError(error);

      return null;
    } finally {
      _isLoadingDetails = false;
      notifyListeners();
    }
  }

  // ============================================================
  // APPROVE
  // ============================================================

  Future<EnrollmentModel?> approveEnrollment({
    required int enrollmentId,
  }) async {
    _isApproving = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final updatedEnrollment =
      await repository.approveEnrollment(
        enrollmentId: enrollmentId,
      );

      _updateEnrollmentInList(
        updatedEnrollment,
      );

      if (_selectedEnrollment?.enrollmentId ==
          enrollmentId) {
        _selectedEnrollment =
            updatedEnrollment;
      }

      return updatedEnrollment;
    } catch (error) {
      _errorMessage =
          _cleanError(error);

      return null;
    } finally {
      _isApproving = false;
      notifyListeners();
    }
  }

  // ============================================================
  // REJECT
  // ============================================================

  Future<EnrollmentModel?> rejectEnrollment({
    required int enrollmentId,
  }) async {
    _isRejecting = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final updatedEnrollment =
      await repository.rejectEnrollment(
        enrollmentId: enrollmentId,
      );

      _updateEnrollmentInList(
        updatedEnrollment,
      );

      if (_selectedEnrollment?.enrollmentId ==
          enrollmentId) {
        _selectedEnrollment =
            updatedEnrollment;
      }

      return updatedEnrollment;
    } catch (error) {
      _errorMessage =
          _cleanError(error);

      return null;
    } finally {
      _isRejecting = false;
      notifyListeners();
    }
  }

  // ============================================================
  // UPDATE ITEM IN LIST
  // ============================================================

  void _updateEnrollmentInList(
      EnrollmentModel updatedEnrollment,
      ) {
    final index =
    _enrollments.indexWhere(
          (item) =>
      item.enrollmentId ==
          updatedEnrollment.enrollmentId,
    );

    if (index == -1) {
      return;
    }

    final updatedList =
    List<EnrollmentModel>.from(
      _enrollments,
    );

    updatedList[index] =
        updatedEnrollment;

    _enrollments = updatedList;
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshEnrollments({
    required int academyId,
  }) async {
    await loadEnrollments(
      academyId: academyId,
    );
  }

  // ============================================================
  // CLEAR SELECTED
  // ============================================================

  void clearSelectedEnrollment() {
    _selectedEnrollment = null;
    _detailsErrorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearDetailsError() {
    _detailsErrorMessage = null;
    notifyListeners();
  }

  void clearAllErrors() {
    _errorMessage = null;
    _detailsErrorMessage = null;

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