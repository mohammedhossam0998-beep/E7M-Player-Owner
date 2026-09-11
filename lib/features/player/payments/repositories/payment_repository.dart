import 'package:e7m/features/player/payments/models/payment_model.dart';
import 'package:e7m/features/player/payments/models/payment_account_model.dart';
import 'package:e7m/features/player/payments/services/payment_service.dart';

class PaymentRepository {
  final PaymentService _paymentService;

  PaymentRepository({
    PaymentService? paymentService,
  }) : _paymentService =
      paymentService ?? PaymentService();

  // ============================================================
  // CREATE DEPOSIT PAYMENT
  // ============================================================

  Future<PaymentResult> createDepositPayment({
    required int bookingId,
    required String paymentMethod,
  }) async {
    final response =
    await _paymentService.createDepositPayment(
      bookingId: bookingId,
      paymentMethod: paymentMethod,
    );

    return _parsePaymentResult(response);
  }

  // ============================================================
  // CREATE FULL PAYMENT
  // ============================================================

  Future<PaymentResult> createFullPayment({
    required int bookingId,
    required String paymentMethod,
  }) async {
    final response =
    await _paymentService.createFullPayment(
      bookingId: bookingId,
      paymentMethod: paymentMethod,
    );

    return _parsePaymentResult(response);
  }

  // ============================================================
  // SUBMIT TRANSACTION REFERENCE
  // ============================================================

  Future<PaymentModel> submitTransactionReference({
    required int paymentId,
    required String transactionReference,
  }) async {
    final response =
    await _paymentService.submitTransactionReference(
      paymentId: paymentId,
      transactionReference: transactionReference,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid payment submission response',
      );
    }

    final payment = response['payment'];

    if (payment is! Map) {
      throw Exception(
        'Invalid payment data',
      );
    }

    return PaymentModel.fromJson(
      Map<String, dynamic>.from(payment),
    );
  }

  // ============================================================
  // GET BOOKING PAYMENTS
  // ============================================================

  Future<List<PaymentModel>> getBookingPayments({
    required int bookingId,
  }) async {
    final response = await _paymentService.getBookingPayments(
      bookingId: bookingId,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid booking payments response');
    }

    final payments = response['payments'];

    if (payments is! List) {
      throw Exception('Invalid payments data');
    }

    return payments
        .whereType<Map>()
        .map(
          (payment) => PaymentModel.fromJson(
        Map<String, dynamic>.from(payment),
      ),
    )
        .toList();
  }

  // ============================================================
  // PARSE CREATE PAYMENT RESPONSE
  // ============================================================

  PaymentResult _parsePaymentResult(
      dynamic response,
      ) {
    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid payment response',
      );
    }

    final payment = response['payment'];

    if (payment is! Map) {
      throw Exception(
        'Invalid payment data',
      );
    }

    final paymentAccount =
    response['payment_account'];

    PaymentAccountModel? account;

    if (paymentAccount is Map) {
      account = PaymentAccountModel.fromJson(
        Map<String, dynamic>.from(
          paymentAccount,
        ),
      );
    }

    return PaymentResult(
      payment: PaymentModel.fromJson(
        Map<String, dynamic>.from(payment),
      ),
      paymentAccount: account,
    );
  }
}

// ============================================================
// PAYMENT RESULT
// ============================================================

class PaymentResult {
  final PaymentModel payment;
  final PaymentAccountModel? paymentAccount;

  const PaymentResult({
    required this.payment,
    this.paymentAccount,
  });
}