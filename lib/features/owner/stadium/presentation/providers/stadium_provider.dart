import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../data/models/stadium_model.dart';
import '../../data/models/stadium_image_model.dart';
import '../../data/models/city_model.dart';

import '../../data/services/stadium_service.dart';
import '../../data/services/city_service.dart';

class StadiumProvider extends ChangeNotifier {
  final StadiumService _service;
  final CityService _cityService;

  StadiumProvider({
    StadiumService? service,
    CityService? cityService,
  })  : _service =
      service ?? StadiumService(),
        _cityService =
            cityService ?? CityService();

  // ============================================================
  // STADIUM STATE
  // ============================================================

  List<StadiumModel> _stadiums = [];

  StadiumModel? _selectedStadium;

  bool _isLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;

  String? _errorMessage;

  // ============================================================
  // STADIUM IMAGES STATE
  // ============================================================

  List<StadiumImageModel> _stadiumImages = [];

  bool _isLoadingImages = false;
  bool _isUploadingImages = false;
  bool _isDeletingImage = false;
  bool _isSettingPrimaryImage = false;

  String? _imagesErrorMessage;

  // ============================================================
  // CITY STATE
  // ============================================================

  List<CityModel> _cities = [];

  bool _isLoadingCities = false;

  String? _citiesErrorMessage;

  // ============================================================
  // STADIUM GETTERS
  // ============================================================

  List<StadiumModel> get stadiums =>
      List.unmodifiable(_stadiums);

  StadiumModel? get selectedStadium =>
      _selectedStadium;

  bool get isLoading =>
      _isLoading;

  bool get isCreating =>
      _isCreating;

  bool get isUpdating =>
      _isUpdating;

  bool get isDeleting =>
      _isDeleting;

  bool get hasError =>
      _errorMessage != null;

  String? get errorMessage =>
      _errorMessage;

  // ============================================================
  // STADIUM IMAGES GETTERS
  // ============================================================

  List<StadiumImageModel>
  get stadiumImages =>
      List.unmodifiable(
        _stadiumImages,
      );

  bool get isLoadingImages =>
      _isLoadingImages;

  bool get isUploadingImages =>
      _isUploadingImages;

  bool get isDeletingImage =>
      _isDeletingImage;

  bool get isSettingPrimaryImage =>
      _isSettingPrimaryImage;

  bool get hasImagesError =>
      _imagesErrorMessage != null;

  String? get imagesErrorMessage =>
      _imagesErrorMessage;

  // ============================================================
  // CITY GETTERS
  // ============================================================

  List<CityModel> get cities =>
      List.unmodifiable(_cities);

  bool get isLoadingCities =>
      _isLoadingCities;

  bool get hasCitiesError =>
      _citiesErrorMessage != null;

  String? get citiesErrorMessage =>
      _citiesErrorMessage;

  // ============================================================
  // GET OWNER STADIUMS
  // ============================================================

  Future<void>
  fetchOwnerStadiums() async {
    _setLoading(true);
    _clearError();

    try {
      _stadiums =
      await _service
          .getOwnerStadiums();
    } catch (e) {
      _errorMessage =
          _cleanError(e);
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // GET STADIUM BY ID
  // ============================================================

  Future<StadiumModel?>
  fetchStadiumById(
      int stadiumId,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      final stadium =
      await _service
          .getStadiumById(
        stadiumId,
      );

      _selectedStadium =
          stadium;

      return stadium;
    } catch (e) {
      _errorMessage =
          _cleanError(e);

      return null;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================================
  // CREATE STADIUM
  // ============================================================

  Future<StadiumModel?>
  createStadium(
      StadiumModel stadium,
      ) async {
    _isCreating = true;
    _clearError();

    notifyListeners();

    try {
      final createdStadium =
      await _service
          .createStadium(
        stadium,
      );

      _stadiums.insert(
        0,
        createdStadium,
      );

      _selectedStadium =
          createdStadium;

      return createdStadium;
    } catch (e) {
      _errorMessage =
          _cleanError(e);

      return null;
    } finally {
      _isCreating = false;

      notifyListeners();
    }
  }

  // ============================================================
  // UPDATE STADIUM
  // ============================================================

  Future<StadiumModel?>
  updateStadium(
      int stadiumId,
      StadiumModel stadium,
      ) async {
    _isUpdating = true;
    _clearError();

    notifyListeners();

    try {
      final updatedStadium =
      await _service
          .updateStadium(
        stadiumId,
        stadium,
      );

      final index =
      _stadiums.indexWhere(
            (item) =>
        item.id == stadiumId,
      );

      if (index != -1) {
        _stadiums[index] =
            updatedStadium;
      }

      if (_selectedStadium?.id ==
          stadiumId) {
        _selectedStadium =
            updatedStadium;
      }

      return updatedStadium;
    } catch (e) {
      _errorMessage =
          _cleanError(e);

      return null;
    } finally {
      _isUpdating = false;

      notifyListeners();
    }
  }

  // ============================================================
  // DELETE STADIUM
  // ============================================================

  Future<bool> deleteStadium(
      int stadiumId,
      ) async {
    _isDeleting = true;
    _clearError();

    notifyListeners();

    try {
      await _service
          .deleteStadium(
        stadiumId,
      );

      _stadiums.removeWhere(
            (item) =>
        item.id == stadiumId,
      );

      if (_selectedStadium?.id ==
          stadiumId) {
        _selectedStadium = null;
      }

      return true;
    } catch (e) {
      _errorMessage =
          _cleanError(e);

      return false;
    } finally {
      _isDeleting = false;

      notifyListeners();
    }
  }

  // ============================================================
  // GET STADIUM IMAGES
  // ============================================================

  Future<void>
  fetchStadiumImages(
      int stadiumId,
      ) async {
    _isLoadingImages = true;
    _imagesErrorMessage = null;

    notifyListeners();

    try {
      _stadiumImages =
      await _service
          .getStadiumImages(
        stadiumId,
      );
    } catch (e) {
      _imagesErrorMessage =
          _cleanError(e);
    } finally {
      _isLoadingImages = false;

      notifyListeners();
    }
  }

  // ============================================================
  // UPLOAD STADIUM IMAGES
  // ============================================================

  Future<bool>
  uploadStadiumImages(
      int stadiumId,
      List<File> files,
      ) async {
    if (files.isEmpty) {
      _imagesErrorMessage =
      'At least one image is required';

      notifyListeners();

      return false;
    }

    _isUploadingImages = true;
    _imagesErrorMessage = null;

    notifyListeners();

    try {
      final uploadedImages =
      await _service
          .uploadStadiumImages(
        stadiumId,
        files,
      );

      _stadiumImages.addAll(
        uploadedImages,
      );

      return true;
    } catch (e) {
      _imagesErrorMessage =
          _cleanError(e);

      return false;
    } finally {
      _isUploadingImages =
      false;

      notifyListeners();
    }
  }

  // ============================================================
  // DELETE STADIUM IMAGE
  // ============================================================

  Future<bool>
  deleteStadiumImage(
      int stadiumId,
      int imageId,
      ) async {
    _isDeletingImage = true;
    _imagesErrorMessage = null;

    notifyListeners();

    try {
      await _service
          .deleteStadiumImage(
        stadiumId,
        imageId,
      );

      _stadiumImages.removeWhere(
            (image) =>
        image.id == imageId,
      );

      return true;
    } catch (e) {
      _imagesErrorMessage =
          _cleanError(e);

      return false;
    } finally {
      _isDeletingImage = false;

      notifyListeners();
    }
  }

  // ============================================================
  // SET PRIMARY STADIUM IMAGE
  // ============================================================

  Future<bool>
  setPrimaryStadiumImage(
      int stadiumId,
      int imageId,
      ) async {
    _isSettingPrimaryImage =
    true;
    _imagesErrorMessage = null;

    notifyListeners();

    try {
      await _service
          .setPrimaryStadiumImage(
        stadiumId,
        imageId,
      );

      _stadiumImages =
          _stadiumImages
              .map(
                (image) =>
                StadiumImageModel(
                  id: image.id,
                  pitchId:
                  image.pitchId,
                  imageUrl:
                  image.imageUrl,
                  isPrimary:
                  image.id ==
                      imageId,
                  createdAt:
                  image.createdAt,
                ),
          )
              .toList();

      return true;
    } catch (e) {
      _imagesErrorMessage =
          _cleanError(e);

      return false;
    } finally {
      _isSettingPrimaryImage =
      false;

      notifyListeners();
    }
  }

  // ============================================================
  // CLEAR STADIUM IMAGES
  // ============================================================

  void clearStadiumImages() {
    _stadiumImages = [];
    _imagesErrorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // SELECT STADIUM
  // ============================================================

  void selectStadium(
      StadiumModel? stadium,
      ) {
    _selectedStadium =
        stadium;

    _clearError();

    notifyListeners();
  }

  // ============================================================
  // CLEAR SELECTED STADIUM
  // ============================================================

  void clearSelectedStadium() {
    _selectedStadium = null;

    notifyListeners();
  }

  // ============================================================
  // GET CITIES
  // ============================================================

  Future<void> fetchCities() async {
    _isLoadingCities = true;
    _citiesErrorMessage = null;

    notifyListeners();

    try {
      _cities =
      await _cityService
          .getCities();
    } catch (e) {
      _citiesErrorMessage =
          _cleanError(e);
    } finally {
      _isLoadingCities = false;

      notifyListeners();
    }
  }

  // ============================================================
  // GET CITY BY ID
  // ============================================================

  Future<CityModel?>
  fetchCityById(
      int cityId,
      ) async {
    _citiesErrorMessage = null;

    try {
      return await _cityService
          .getCityById(
        cityId,
      );
    } catch (e) {
      _citiesErrorMessage =
          _cleanError(e);

      notifyListeners();

      return null;
    }
  }

  // ============================================================
  // CLEAR STADIUM ERROR
  // ============================================================

  void clearError() {
    _clearError();

    notifyListeners();
  }

  // ============================================================
  // CLEAR CITY ERROR
  // ============================================================

  void clearCitiesError() {
    _citiesErrorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR IMAGE ERROR
  // ============================================================

  void clearImagesError() {
    _imagesErrorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // INTERNAL STATE HELPERS
  // ============================================================

  void _setLoading(
      bool value,
      ) {
    _isLoading = value;

    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  String _cleanError(
      Object error,
      ) {
    final message =
    error.toString();

    if (message.startsWith(
      'Exception: ',
    )) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }
}