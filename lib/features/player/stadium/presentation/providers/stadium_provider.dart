import 'package:flutter/foundation.dart';

import '../../data/models/stadium.dart';
import '../../data/models/stadium_image.dart';
import '../../data/models/stadium_slot.dart';
import '../../data/repositories/stadium_repository.dart';

import 'package:e7m/features/player/booking/models/booking_model.dart';

class StadiumProvider extends ChangeNotifier {
  final StadiumRepository _repository;

  StadiumProvider({
    StadiumRepository? repository,
  }) : _repository = repository ?? StadiumRepository();

  // ============================================================
  // STATE
  // ============================================================

  List<Stadium> _stadiums = [];

  Stadium? _selectedStadium;

  List<StadiumImage> _images = [];

  List<StadiumSlot> _slots = [];

  bool _isLoading = false;
  bool _isLoadingDetails = false;
  bool _isLoadingImages = false;
  bool _isLoadingSlots = false;

  bool _isCreatingBooking = false;

  BookingModel? _createdBooking;

  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<Stadium> get stadiums =>
      List.unmodifiable(_stadiums);

  Stadium? get selectedStadium =>
      _selectedStadium;

  List<StadiumImage> get images =>
      List.unmodifiable(_images);

  List<StadiumSlot> get slots =>
      List.unmodifiable(_slots);

  bool get isLoading =>
      _isLoading;

  bool get isLoadingDetails =>
      _isLoadingDetails;

  bool get isLoadingImages =>
      _isLoadingImages;

  bool get isLoadingSlots =>
      _isLoadingSlots;

  bool get isCreatingBooking =>
      _isCreatingBooking;

  BookingModel? get createdBooking =>
      _createdBooking;

  String? get errorMessage =>
      _errorMessage;

  bool get hasStadiums =>
      _stadiums.isNotEmpty;

  bool get hasImages =>
      _images.isNotEmpty;

  bool get hasSlots =>
      _slots.isNotEmpty;

  // ============================================================
  // GET ALL STADIUMS
  // ============================================================

  Future<void> loadStadiums() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await _repository.getStadiums();

      _stadiums = result;
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // GET STADIUM DETAILS
  // ============================================================

  Future<void> loadStadiumDetails(
      String stadiumId,
      ) async {
    _isLoadingDetails = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await _repository.getStadiumById(
        stadiumId,
      );

      _selectedStadium = result;
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isLoadingDetails = false;

      notifyListeners();
    }
  }

  // ============================================================
  // GET STADIUM IMAGES
  // ============================================================

  Future<void> loadStadiumImages(
      String stadiumId,
      ) async {
    _isLoadingImages = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await _repository.getStadiumImages(
        stadiumId,
      );

      _images = result;
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isLoadingImages = false;

      notifyListeners();
    }
  }

  // ============================================================
  // GET STADIUM SLOTS
  // ============================================================

  Future<void> loadStadiumSlots(
      String stadiumId,
      ) async {
    _isLoadingSlots = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await _repository.getStadiumSlots(
        stadiumId,
      );

      _slots = result;
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isLoadingSlots = false;

      notifyListeners();
    }
  }

  // ============================================================
  // CREATE BOOKING
  // POST /api/bookings
  // ============================================================

  Future<BookingModel?> createBooking({
    required String pitchSlotId,
    String? coachId,
    String? paymentMethod,
    String? notes,
  }) async {
    _isCreatingBooking = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await _repository.createBooking(
        pitchSlotId: pitchSlotId,
        coachId: coachId,
        paymentMethod: paymentMethod,
        notes: notes,
      );

      // StadiumRepository.createBooking()
      // بيرجع بيانات الحجز نفسها مباشرة.
      if (result.isEmpty) {
        throw Exception(
          'Booking was created but response is empty',
        );
      }

      final booking =
      BookingModel.fromJson(result);

      _createdBooking = booking;

      return booking;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return null;
    } finally {
      _isCreatingBooking = false;

      notifyListeners();
    }
  }

  // ============================================================
  // CLEAR CREATED BOOKING
  // ============================================================

  void clearCreatedBooking() {
    _createdBooking = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR SELECTED STADIUM
  // ============================================================

  void clearSelectedStadium() {
    _selectedStadium = null;

    _images = [];

    _slots = [];

    _createdBooking = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }
}