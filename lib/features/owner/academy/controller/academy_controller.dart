import 'package:flutter/foundation.dart';

import '../models/academy_model.dart';
import '../repository/academy_repository_impl.dart';

class AcademyController extends ChangeNotifier {
  final AcademyRepositoryImpl repository;

  AcademyController({
    required this.repository,
  });

  // ============================================================
  // STATE
  // ============================================================

  List<AcademyModel> _academies = [];

  AcademyModel? _selectedAcademy;

  bool _isLoading = false;

  bool _isCreating = false;

  bool _isUpdating = false;

  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<AcademyModel> get academies =>
      List.unmodifiable(_academies);

  AcademyModel? get selectedAcademy =>
      _selectedAcademy;

  bool get isLoading =>
      _isLoading;

  bool get isCreating =>
      _isCreating;

  bool get isUpdating =>
      _isUpdating;

  String? get errorMessage =>
      _errorMessage;

  bool get hasError =>
      _errorMessage != null;

  bool get hasAcademies =>
      _academies.isNotEmpty;

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // LOAD OWNER ACADEMIES
  // ============================================================

  Future<void> loadAcademies() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await repository.getOwnerAcademies();

      _academies = result;
    } catch (error) {
      _academies = [];

      _errorMessage = _cleanError(error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // LOAD ONE ACADEMY
  // ============================================================

  Future<AcademyModel?> loadAcademyById(
      String academyId,
      ) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final academy =
      await repository.getOwnerAcademyById(
        academyId,
      );

      _selectedAcademy = academy;

      return academy;
    } catch (error) {
      _selectedAcademy = null;

      _errorMessage = _cleanError(error);

      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CREATE ACADEMY
  // ============================================================

  Future<AcademyModel?> createAcademy({
    required String name,
    required String phoneNumber,
    String? description,
    String? address,
    String? cityId,
    String? imageUrl,
    required String pitchId,
  }) async {
    _isCreating = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final academy =
      await repository.createAcademy(
        name: name,
        phoneNumber: phoneNumber,
        description: description,
        address: address,
        cityId: cityId,
        imageUrl: imageUrl,
        pitchId: pitchId,
      );

      _academies = [
        academy,
        ..._academies,
      ];

      _selectedAcademy = academy;

      return academy;
    } catch (error) {
      _errorMessage = _cleanError(error);

      return null;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }

  // ============================================================
  // UPDATE ACADEMY
  // ============================================================

  Future<AcademyModel?> updateAcademy({
    required String academyId,
    String? name,
    String? phoneNumber,
    String? description,
    String? address,
    String? cityId,
    String? imageUrl,
    String? pitchId,
  }) async {
    _isUpdating = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final updatedAcademy =
      await repository.updateAcademy(
        academyId: academyId,
        name: name,
        phoneNumber: phoneNumber,
        description: description,
        address: address,
        cityId: cityId,
        imageUrl: imageUrl,
        pitchId: pitchId,
      );

      _selectedAcademy = updatedAcademy;

      // ----------------------------------------------------------
      // UPDATE ACADEMY IN LIST
      // ----------------------------------------------------------

      final index = _academies.indexWhere(
            (academy) =>
        academy.id == updatedAcademy.id,
      );

      if (index != -1) {
        final updatedList =
        List<AcademyModel>.from(
          _academies,
        );

        updatedList[index] =
            updatedAcademy;

        _academies = updatedList;
      }

      return updatedAcademy;
    } catch (error) {
      _errorMessage = _cleanError(error);

      return null;
    } finally {
      _isUpdating = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CLEAR SELECTED ACADEMY
  // ============================================================

  void clearSelectedAcademy() {
    _selectedAcademy = null;
    notifyListeners();
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshAcademies() async {
    await loadAcademies();
  }

  // ============================================================
  // ERROR CLEANER
  // ============================================================

  String _cleanError(
      Object error,
      ) {
    return error
        .toString()
        .replaceFirst(
      'Exception: ',
      '',
    );
  }
}