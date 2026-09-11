import 'package:flutter/foundation.dart';

import 'package:e7m/features/player/payments/models/payment_model.dart';
import 'package:e7m/features/player/payments/models/payment_account_model.dart';
import 'package:e7m/features/player/payments/repositories/payment_repository.dart';

class PaymentProvider extends ChangeNotifier {
  final PaymentRepository _repository;

  PaymentProvider({
    PaymentRepository? repository,
  }) : _repository = repository ?? PaymentRepository();

  // ============================================================
  // CURRENT PAYMENT
  // ============================================================

  PaymentModel? _payment;

  PaymentModel? get payment => _payment;

  // ============================================================
  // PAYMENT ACCOUNT
  // ============================================================

  PaymentAccountModel? _paymentAccount;

  PaymentAccountModel? get paymentAccount => _paymentAccount;

  // ============================================================
  // BOOKING PAYMENTS
  // ============================================================

  List<PaymentModel> _bookingPayments = [];

  List<PaymentModel> get bookingPayments =>
      List.unmodifiable(_bookingPayments);

  // ============================================================
  // LOADING STATES
  // ============================================================

  bool _isCreatingPayment = false;

  bool get isCreatingPayment => _isCreatingPayment;

  bool _isSubmittingReference = false;

  bool get isSubmittingReference => _isSubmittingReference;

  bool _isLoadingPayments = false;

  bool get isLoadingPayments => _isLoadingPayments;

  // ============================================================
  // ERROR
  // ============================================================

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  // ============================================================
  // PAYMENT STATE HELPERS
  // ============================================================

  bool get hasPayment => _payment != null;

  bool get isPending => _payment?.isPending ?? false;

  bool get isPaid => _payment?.isPaid ?? false;

  bool get isFailed => _payment?.isFailed ?? false;

  bool get hasPaymentAccount =>
      _paymentAccount != null;

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================================
  // CREATE DEPOSIT PAYMENT
  // ============================================================

  Future<bool> createDepositPayment({
    required int bookingId,
    required String paymentMethod,
  }) async {
    _isCreatingPayment = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result = await _repository.createDepositPayment(
        bookingId: bookingId,
        paymentMethod: paymentMethod,
      );

      _payment = result.payment;
      _paymentAccount = result.paymentAccount;

      // Keep the newly created payment
      // inside the booking payments list.
      _bookingPayments = [
        result.payment,
        ..._bookingPayments.where(
              (payment) => payment.id != result.payment.id,
        ),
      ];

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      return false;
    } finally {
      _isCreatingPayment = false;
      notifyListeners();
    }
  }

  // ============================================================
  // CREATE FULL PAYMENT
  // ============================================================

  Future<bool> createFullPayment({
    required int bookingId,
    required String paymentMethod,
  }) async {
    _isCreatingPayment = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result = await _repository.createFullPayment(
        bookingId: bookingId,
        paymentMethod: paymentMethod,
      );

      _payment = result.payment;
      _paymentAccount = result.paymentAccount;

      // Keep the newly created payment
      // inside the booking payments list.
      _bookingPayments = [
        result.payment,
        ..._bookingPayments.where(
              (payment) => payment.id != result.payment.id,
        ),
      ];

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      return false;
    } finally {
      _isCreatingPayment = false;
      notifyListeners();
    }
  }

  // ============================================================
  // SUBMIT TRANSACTION REFERENCE
  // ============================================================

  Future<bool> submitTransactionReference({
    required int paymentId,
    required String transactionReference,
  }) async {
    _isSubmittingReference = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final payment =
      await _repository.submitTransactionReference(
        paymentId: paymentId,
        transactionReference: transactionReference.trim(),
      );

      _payment = payment;

      // Update the payment inside the list.
      final index = _bookingPayments.indexWhere(
            (item) => item.id == payment.id,
      );

      if (index != -1) {
        _bookingPayments[index] = payment;
      }

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      return false;
    } finally {
      _isSubmittingReference = false;
      notifyListeners();
    }
  }

  // ============================================================
  // LOAD BOOKING PAYMENTS
  // ============================================================

  Future<bool> loadBookingPayments({
    required int bookingId,
  }) async {
    _isLoadingPayments = true;
    _errorMessage = null;

    // IMPORTANT:
    // Clear previous booking payment data first.
    _payment = null;
    _paymentAccount = null;
    _bookingPayments = [];

    notifyListeners();

    try {
      final payments =
      await _repository.getBookingPayments(
        bookingId: bookingId,
      );

      _bookingPayments = payments;

      // Backend returns newest payment first.
      if (_bookingPayments.isNotEmpty) {
        final currentPayment =
            _bookingPayments.first;

        _payment = currentPayment;

        // ======================================================
        // LOAD OWNER PAYMENT ACCOUNT
        // ======================================================

        if (currentPayment.hasPaymentAccount) {
          _paymentAccount = PaymentAccountModel(
            paymentMethod:
            currentPayment.paymentAccountMethod ??
                currentPayment.paymentMethod,
            accountName:
            currentPayment.paymentAccountName ?? '',
            accountIdentifier:
            currentPayment.paymentAccountIdentifier ?? '',
          );
        }
      }

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);
      return false;
    } finally {
      _isLoadingPayments = false;
      notifyListeners();
    }
  }

  // ============================================================
  // SET PAYMENT
  // ============================================================

  void setPayment(PaymentModel? payment) {
    _payment = payment;

    if (payment == null) {
      _paymentAccount = null;
    } else if (payment.hasPaymentAccount) {
      _paymentAccount = PaymentAccountModel(
        paymentMethod:
        payment.paymentAccountMethod ??
            payment.paymentMethod,
        accountName:
        payment.paymentAccountName ?? '',
        accountIdentifier:
        payment.paymentAccountIdentifier ?? '',
      );
    }

    notifyListeners();
  }

  // ============================================================
  // CLEAR CURRENT PAYMENT
  // ============================================================

  void clearPayment() {
    _payment = null;
    _paymentAccount = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR BOOKING PAYMENTS
  // ============================================================

  void clearBookingPayments() {
    _bookingPayments = [];
    _payment = null;
    _paymentAccount = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAN ERROR
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }

    return message;
  }
}