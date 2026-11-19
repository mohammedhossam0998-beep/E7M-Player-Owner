
import 'package:flutter/foundation.dart';

import '../models/slot_model.dart';
import '../services/slot_service.dart';

class SlotProvider extends ChangeNotifier {
  final SlotService _service;

  SlotProvider({
    SlotService? service,
  }) : _service = service ?? SlotService();

  List<SlotModel> _slots = [];

  int? _stadiumId;
  String? _errorMessage;

  bool _isLoading = false;
  bool _isCreating = false;
  bool _isUpdating = false;
  bool _isDeleting = false;
  bool _isUpdatingStatus = false;
  bool _disposed = false;

  int _sessionVersion = 0;
  int _requestVersion = 0;

  // ============================================================
  // GETTERS
  // ============================================================

  List<SlotModel> get slots => List.unmodifiable(_slots);

  int? get stadiumId => _stadiumId;

  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  bool get isLoading => _isLoading;

  bool get isCreating => _isCreating;

  bool get isUpdating => _isUpdating;

  bool get isDeleting => _isDeleting;

  bool get isUpdatingStatus => _isUpdatingStatus;

  bool get isBusy =>
      _isCreating ||
          _isUpdating ||
          _isDeleting ||
          _isUpdatingStatus;

  // ============================================================
  // SAFE NOTIFICATION
  // ============================================================

  void _notify() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  // ============================================================
  // SWITCH STADIUM SAFELY
  // ============================================================

  void _activateStadium(int id) {
    if (_stadiumId == id) return;

    _stadiumId = id;

    ++_sessionVersion;
    ++_requestVersion;

    _slots = [];

    _isLoading = false;
    _isCreating = false;
    _isUpdating = false;
    _isDeleting = false;
    _isUpdatingStatus = false;

    _errorMessage = null;
  }

  void _invalidateLoading() {
    ++_requestVersion;
    _isLoading = false;
  }

  // ============================================================
  // FETCH STADIUM SLOTS
  // ============================================================

  Future<void> fetchStadiumSlots(int stadiumId) async {
    if (_disposed) return;

    _activateStadium(stadiumId);

    if (isBusy) {
      _errorMessage =
      'Finish the current action before refreshing.';
      _notify();
      return;
    }

    final session = _sessionVersion;
    final request = ++_requestVersion;

    _isLoading = true;
    _errorMessage = null;

    _notify();

    try {
      final items =
      await _service.getStadiumSlots(stadiumId);

      if (_disposed ||
          session != _sessionVersion ||
          request != _requestVersion) {
        return;
      }

      _slots = items;

      _sortSlots();
    } catch (error) {
      if (_disposed ||
          session != _sessionVersion ||
          request != _requestVersion) {
        return;
      }

      _errorMessage = _cleanError(error);
    } finally {
      if (!_disposed &&
          session == _sessionVersion &&
          request == _requestVersion) {
        _isLoading = false;
        _notify();
      }
    }
  }

  // ============================================================
  // CREATE SLOT
  // ============================================================

  Future<SlotModel?> createSlot(
      int stadiumId,
      SlotModel slot,
      ) async {
    if (_disposed) return null;

    _activateStadium(stadiumId);

    if (isBusy) return null;

    final session = _sessionVersion;

    _invalidateLoading();

    _isCreating = true;
    _errorMessage = null;

    _notify();

    try {
      final created =
      await _service.createSlot(stadiumId, slot);

      if (_disposed || session != _sessionVersion) {
        return null;
      }

      _upsert(created);

      return created;
    } catch (error) {
      if (!_disposed && session == _sessionVersion) {
        _errorMessage = _cleanError(error);
      }

      return null;
    } finally {
      if (!_disposed && session == _sessionVersion) {
        _isCreating = false;
        _notify();
      }
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
    if (_disposed) return null;

    _activateStadium(stadiumId);

    if (isBusy) return null;

    final session = _sessionVersion;

    _invalidateLoading();

    _isUpdating = true;
    _errorMessage = null;

    _notify();

    try {
      final updated = await _service.updateSlot(
        stadiumId,
        slotId,
        slot,
      );

      if (_disposed || session != _sessionVersion) {
        return null;
      }

      _upsert(updated);

      return updated;
    } catch (error) {
      if (!_disposed && session == _sessionVersion) {
        _errorMessage = _cleanError(error);
      }

      return null;
    } finally {
      if (!_disposed && session == _sessionVersion) {
        _isUpdating = false;
        _notify();
      }
    }
  }

  // ============================================================
  // DELETE SLOT
  // ============================================================

  Future<bool> deleteSlot(
      int stadiumId,
      int slotId,
      ) async {
    if (_disposed) return false;

    _activateStadium(stadiumId);

    if (isBusy) return false;

    final session = _sessionVersion;

    _invalidateLoading();

    _isDeleting = true;
    _errorMessage = null;

    _notify();

    try {
      await _service.deleteSlot(stadiumId, slotId);

      if (_disposed || session != _sessionVersion) {
        return false;
      }

      _slots.removeWhere(
            (slot) => slot.id == slotId,
      );

      return true;
    } catch (error) {
      if (!_disposed && session == _sessionVersion) {
        _errorMessage = _cleanError(error);
      }

      return false;
    } finally {
      if (!_disposed && session == _sessionVersion) {
        _isDeleting = false;
        _notify();
      }
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
    if (_disposed) return null;

    _activateStadium(stadiumId);

    if (isBusy) return null;

    final session = _sessionVersion;

    _invalidateLoading();

    _isUpdatingStatus = true;
    _errorMessage = null;

    _notify();

    try {
      final updated =
      await _service.updateSlotStatus(
        stadiumId,
        slotId,
        status,
      );

      if (_disposed || session != _sessionVersion) {
        return null;
      }

      _upsert(updated);

      return updated;
    } catch (error) {
      if (!_disposed && session == _sessionVersion) {
        _errorMessage = _cleanError(error);
      }

      return null;
    } finally {
      if (!_disposed && session == _sessionVersion) {
        _isUpdatingStatus = false;
        _notify();
      }
    }
  }

  // ============================================================
  // INSERT OR UPDATE SLOT LOCALLY
  // ============================================================

  void _upsert(SlotModel slot) {
    if (slot.pitchId != _stadiumId) return;

    final index = _slots.indexWhere(
          (item) => item.id == slot.id,
    );

    if (index >= 0) {
      _slots[index] = slot;
    } else {
      _slots.add(slot);
    }

    _sortSlots();
    _notify();
  }

  // ============================================================
  // SORT SLOTS
  // ============================================================

  void _sortSlots() {
    _slots.sort((a, b) {
      final dateOrder =
      a.slotDate.compareTo(b.slotDate);

      return dateOrder != 0
          ? dateOrder
          : a.startTime.compareTo(b.startTime);
    });
  }

  // ============================================================
  // CLEAR STADIUM SLOTS
  // ============================================================

  void clearSlots() {
    if (_disposed) return;

    ++_sessionVersion;
    ++_requestVersion;

    _stadiumId = null;
    _slots = [];

    _isLoading = false;
    _isCreating = false;
    _isUpdating = false;
    _isDeleting = false;
    _isUpdatingStatus = false;

    _errorMessage = null;

    _notify();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    if (_disposed) return;

    _errorMessage = null;
    _notify();
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    return message.startsWith('Exception: ')
        ? message.substring('Exception: '.length)
        : message;
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _disposed = true;

    ++_sessionVersion;
    ++_requestVersion;

    super.dispose();
  }
}
