import 'package:e7m/core/network/api_client.dart';

class PaymentService {
  final ApiClient _apiClient;

  PaymentService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // CREATE DEPOSIT PAYMENT
  // ============================================================

  Future<dynamic> createDepositPayment({
    required int bookingId,
    required String paymentMethod,
  }) async {
    return _apiClient.post(
      '/payments/deposit',
      {
        'booking_id': bookingId,
        'payment_method': paymentMethod,
      },
    );
  }

  // ============================================================
  // CREATE FULL PAYMENT
  // ============================================================

  Future<dynamic> createFullPayment({
    required int bookingId,
    required String paymentMethod,
  }) async {
    return _apiClient.post(
      '/payments/full',
      {
        'booking_id': bookingId,
        'payment_method': paymentMethod,
      },
    );
  }

  // ============================================================
  // SUBMIT TRANSACTION REFERENCE
  // ============================================================

  Future<dynamic> submitTransactionReference({
    required int paymentId,
    required String transactionReference,
  }) async {
    return _apiClient.post(
      '/payments/$paymentId/submit',
      {
        'transaction_reference':
        transactionReference,
      },
    );
  }

  // ============================================================
  // GET BOOKING PAYMENTS
  // ============================================================

  Future<dynamic> getBookingPayments({
    required int bookingId,
  }) async {
    return _apiClient.get(
      '/payments/booking/$bookingId',
    );
  }
}