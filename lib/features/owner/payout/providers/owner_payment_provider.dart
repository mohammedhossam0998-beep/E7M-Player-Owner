import 'package:flutter/foundation.dart';

import '../data/models/owner_payment_model.dart';
import '../data/services/owner_payment_service.dart';

class OwnerPaymentProvider extends ChangeNotifier {
  final OwnerPaymentService _service;

  OwnerPaymentProvider({
    OwnerPaymentService? service,
  }) : _service = service ?? OwnerPaymentService();

  List<OwnerPaymentModel> _payments = [];

  bool _isLoading = false;
  bool _isProcessing = false;

  String? _errorMessage;

  int? _processingPaymentId;
  int _sessionVersion = 0;
  int _requestVersion = 0;

  List<OwnerPaymentModel> get payments =>
      List.unmodifiable(_payments);

  bool get isLoading => _isLoading;
  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  int? get processingPaymentId => _processingPaymentId;

  List<OwnerPaymentModel> get pendingPayments {
    return _payments
        .where(
          (payment) => payment.status.toLowerCase() == 'pending',
    )
        .toList();
  }

  List<OwnerPaymentModel> get paidPayments {
    return _payments
        .where(
          (payment) => payment.status.toLowerCase() == 'paid',
    )
        .toList();
  }

  List<OwnerPaymentModel> get failedPayments {
    return _payments
        .where(
          (payment) =>
      payment.status.toLowerCase() == 'failed' ||
          payment.status.toLowerCase() == 'rejected',
    )
        .toList();
  }

  int get pendingCount => pendingPayments.length;
  int get paidCount => paidPayments.length;
  int get failedCount => failedPayments.length;

  Future<void> loadPayments({
    bool refresh = false,
  }) async {
    if (_isLoading && !refresh) {
      return;
    }

    final session = _sessionVersion;
    final request = ++_requestVersion;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final payments = await _service.getOwnerPayments();

      if (session == _sessionVersion && request == _requestVersion) {
        _payments = payments;
      }
    } catch (e) {
      if (session == _sessionVersion && request == _requestVersion) {
        _errorMessage = _cleanErrorMessage(e);
      }
    } finally {
      if (session == _sessionVersion && request == _requestVersion) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> refreshPayments() async {
    await loadPayments(refresh: true);
  }

  Future<bool> approvePayment(int paymentId) async {
    if (_isProcessing) {
      return false;
    }

    _isProcessing = true;
    _processingPaymentId = paymentId;
    _errorMessage = null;
    notifyListeners();

    final session = _sessionVersion;

    try {
      await _service.approvePayment(paymentId);

      if (session != _sessionVersion) return false;

      await _reloadSilently(session);
      return session == _sessionVersion;
    } catch (e) {
      if (session == _sessionVersion) {
        _errorMessage = _cleanErrorMessage(e);
      }
      return false;
    } finally {
      if (session == _sessionVersion) {
        _isProcessing = false;
        _processingPaymentId = null;
        notifyListeners();
      }
    }
  }

  Future<bool> rejectPayment(int paymentId) async {
    if (_isProcessing) {
      return false;
    }

    _isProcessing = true;
    _processingPaymentId = paymentId;
    _errorMessage = null;
    notifyListeners();

    final session = _sessionVersion;

    try {
      await _service.rejectPayment(paymentId);

      if (session != _sessionVersion) return false;

      await _reloadSilently(session);
      return session == _sessionVersion;
    } catch (e) {
      if (session == _sessionVersion) {
        _errorMessage = _cleanErrorMessage(e);
      }
      return false;
    } finally {
      if (session == _sessionVersion) {
        _isProcessing = false;
        _processingPaymentId = null;
        notifyListeners();
      }
    }
  }

  OwnerPaymentModel? getPaymentById(int paymentId) {
    try {
      return _payments.firstWhere(
            (payment) => payment.id == paymentId,
      );
    } catch (_) {
      return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> _reloadSilently(int session) async {
    try {
      final payments = await _service.getOwnerPayments();

      if (session == _sessionVersion) {
        _payments = payments;
      }
    } catch (e) {
      debugPrint('OWNER PAYMENTS RELOAD ERROR: $e');
    }
  }

  /// يمسح المدفوعات المخزنة عند الخروج أو تبديل الحساب.
  void clearAccountData() {
    _sessionVersion++;
    _requestVersion++;

    _payments = [];
    _isLoading = false;
    _isProcessing = false;
    _processingPaymentId = null;
    _errorMessage = null;

    notifyListeners();
  }

  String _cleanErrorMessage(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring('Exception: '.length);
    }

    return message;
  }
}