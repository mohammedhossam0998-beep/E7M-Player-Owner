import 'package:flutter/foundation.dart';

import '../data/models/owner_payment_model.dart';
import '../data/services/owner_payment_service.dart';

class OwnerPaymentProvider extends ChangeNotifier {
  final OwnerPaymentService _service;

  OwnerPaymentProvider({
    OwnerPaymentService? service,
  }) : _service = service ?? OwnerPaymentService();

  // ============================================================
  // STATE
  // ============================================================

  List<OwnerPaymentModel> _payments = [];

  bool _isLoading = false;
  bool _isProcessing = false;

  String? _errorMessage;

  int? _processingPaymentId;

  // ============================================================
  // GETTERS
  // ============================================================

  List<OwnerPaymentModel> get payments =>
      List.unmodifiable(_payments);

  bool get isLoading => _isLoading;

  bool get isProcessing => _isProcessing;

  String? get errorMessage => _errorMessage;

  int? get processingPaymentId =>
      _processingPaymentId;

  // ============================================================
  // FILTERS
  // ============================================================

  List<OwnerPaymentModel> get pendingPayments {
    return _payments
        .where(
          (payment) => payment.status == 'pending',
    )
        .toList();
  }

  List<OwnerPaymentModel> get paidPayments {
    return _payments
        .where(
          (payment) => payment.status == 'paid',
    )
        .toList();
  }

  List<OwnerPaymentModel> get failedPayments {
    return _payments
        .where(
          (payment) => payment.status == 'failed',
    )
        .toList();
  }

  int get pendingCount =>
      pendingPayments.length;

  int get paidCount =>
      paidPayments.length;

  int get failedCount =>
      failedPayments.length;

  // ============================================================
  // LOAD OWNER PAYMENTS
  // ============================================================

  Future<void> loadPayments({
    bool refresh = false,
  }) async {
    if (_isLoading && !refresh) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final payments =
      await _service.getOwnerPayments();

      _payments = payments;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> refreshPayments() async {
    await loadPayments(
      refresh: true,
    );
  }

  // ============================================================
  // APPROVE PAYMENT
  // ============================================================

  Future<bool> approvePayment(
      int paymentId,
      ) async {
    if (_isProcessing) {
      return false;
    }

    _isProcessing = true;
    _processingPaymentId = paymentId;
    _errorMessage = null;

    notifyListeners();

    try {
      await _service.approvePayment(
        paymentId,
      );

      // Reload from server so the UI always
      // represents the real backend state.
      await _reloadSilently();

      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);

      return false;
    } finally {
      _isProcessing = false;
      _processingPaymentId = null;

      notifyListeners();
    }
  }

  // ============================================================
  // REJECT PAYMENT
  // ============================================================

  Future<bool> rejectPayment(
      int paymentId,
      ) async {
    if (_isProcessing) {
      return false;
    }

    _isProcessing = true;
    _processingPaymentId = paymentId;
    _errorMessage = null;

    notifyListeners();

    try {
      await _service.rejectPayment(
        paymentId,
      );

      // Reload from server after rejection.
      await _reloadSilently();

      return true;
    } catch (e) {
      _errorMessage = _cleanErrorMessage(e);

      return false;
    } finally {
      _isProcessing = false;
      _processingPaymentId = null;

      notifyListeners();
    }
  }

  // ============================================================
  // FIND PAYMENT
  // ============================================================

  OwnerPaymentModel? getPaymentById(
      int paymentId,
      ) {
    try {
      return _payments.firstWhere(
            (payment) => payment.id == paymentId,
      );
    } catch (_) {
      return null;
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
  // INTERNAL SILENT RELOAD
  // ============================================================

  Future<void> _reloadSilently() async {
    try {
      final payments =
      await _service.getOwnerPayments();

      _payments = payments;
    } catch (e) {
      // Don't replace the successful
      // approve/reject result with a reload error.
      debugPrint(
        'OWNER PAYMENTS RELOAD ERROR: $e',
      );
    }
  }

  // ============================================================
  // ERROR HANDLER
  // ============================================================

  String _cleanErrorMessage(
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