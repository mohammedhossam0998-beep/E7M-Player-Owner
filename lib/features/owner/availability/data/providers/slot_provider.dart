import 'package:flutter/foundation.dart';

import '../models/slot_model.dart';
import '../services/slot_service.dart';

class SlotProvider extends ChangeNotifier {
  final SlotService _service;

  SlotProvider({
    SlotService? service,
  }) : _service = service ?? SlotService();

  // ============================================================
  // STATE
  // ============================================================

  List<SlotModel> _slots = [];

  bool _isLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  bool _isUpdatingStatus = false;

  String? _errorMessage;

  int? _stadiumId;

  // ============================================================
  // GETTERS
  // ============================================================

  List<SlotModel> get slots =>
      List.unmodifiable(_slots);

  bool get isLoading => _isLoading;

  bool get isCreating => _isCreating;

  bool get isUpdating => _isUpdating;

  bool get isDeleting => _isDeleting;

  bool get isUpdatingStatus => _isUpdatingStatus;

  bool get hasError =>
      _errorMessage != null;

  String? get errorMessage =>
      _errorMessage;

  int? get stadiumId =>
      _stadiumId;

  // ============================================================
  // GET STADIUM SLOTS
  // ============================================================

  Future<void> fetchStadiumSlots(
      int stadiumId,
      ) async {
    _stadiumId = stadiumId;

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _slots = await _service.getStadiumSlots(
        stadiumId,
      );

      _sortSlots();
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // CREATE SLOT
  // ============================================================

  Future<SlotModel?> createSlot(
      int stadiumId,
      SlotModel slot,
      ) async {
    _isCreating = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final createdSlot =
      await _service.createSlot(
        stadiumId,
        slot,
      );

      _stadiumId = stadiumId;

      _slots.add(createdSlot);

      _sortSlots();

      return createdSlot;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return null;
    } finally {
      _isCreating = false;

      notifyListeners();
    }
  }

  // ============================================================
  // UPDATE SLOT
  // ============================================================

  Future<SlotModel?> updateSlot(
      int stadiumId,
      int slotId,
      SlotModel slot,
      ) async {
    _isUpdating = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final updatedSlot =
      await _service.updateSlot(
        stadiumId,
        slotId,
        slot,
      );

      final index = _slots.indexWhere(
            (item) => item.id == slotId,
      );

      if (index != -1) {
        _slots[index] = updatedSlot;
      } else {
        _slots.add(updatedSlot);
      }

      _sortSlots();

      return updatedSlot;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return null;
    } finally {
      _isUpdating = false;

      notifyListeners();
    }
  }

  // ============================================================
  // DELETE SLOT
  // ============================================================

  Future<bool> deleteSlot(
      int stadiumId,
      int slotId,
      ) async {
    _isDeleting = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _service.deleteSlot(
        stadiumId,
        slotId,
      );

      _slots.removeWhere(
            (slot) => slot.id == slotId,
      );

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return false;
    } finally {
      _isDeleting = false;

      notifyListeners();
    }
  }

  // ============================================================
  // UPDATE SLOT STATUS
  // ============================================================

  Future<SlotModel?> updateSlotStatus(
      int stadiumId,
      int slotId,
      String status,
      ) async {
    _isUpdatingStatus = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final updatedSlot =
      await _service.updateSlotStatus(
        stadiumId,
        slotId,
        status,
      );

      final index = _slots.indexWhere(
            (slot) => slot.id == slotId,
      );

      if (index != -1) {
        _slots[index] = updatedSlot;
      } else {
        _slots.add(updatedSlot);
      }

      _sortSlots();

      return updatedSlot;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return null;
    } finally {
      _isUpdatingStatus = false;

      notifyListeners();
    }
  }

  // ============================================================
  // CLEAR SLOTS
  // ============================================================

  void clearSlots() {
    _slots = [];
    _stadiumId = null;
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // SORT SLOTS
  // ============================================================

  void _sortSlots() {
    _slots.sort(
          (a, b) {
        final dateCompare =
        a.slotDate.compareTo(
          b.slotDate,
        );

        if (dateCompare != 0) {
          return dateCompare;
        }

        return a.startTime.compareTo(
          b.startTime,
        );
      },
    );
  }

  // ============================================================
  // CLEAN ERROR
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

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