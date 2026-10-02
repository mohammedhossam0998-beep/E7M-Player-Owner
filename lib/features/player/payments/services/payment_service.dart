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
    required int ownerPaymentAccountId,
  }) async {
    return _apiClient.post(
      '/payments/deposit',
      {
        'booking_id': bookingId,
        'owner_payment_account_id': ownerPaymentAccountId,
      },
    );
  }

  // ============================================================
  // CREATE FULL PAYMENT
  // ============================================================

  Future<dynamic> createFullPayment({
    required int bookingId,
    required int ownerPaymentAccountId,
  }) async {
    return _apiClient.post(
      '/payments/full',
      {
        'booking_id': bookingId,
        'owner_payment_account_id': ownerPaymentAccountId,
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
        'transaction_reference': transactionReference,
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

  // ============================================================
  // GET AVAILABLE PAYMENT ACCOUNTS FOR BOOKING
  // ============================================================
  //
  // يرجع حسابات الدفع النشطة الخاصة بمالك الملعب
  // المرتبط بالحجز.
  //
  // مثال:
  // InstaPay
  // Vodafone Cash
  // Orange Cash
  // Etisalat Cash
  // WE Pay
  //
  // ============================================================

  Future<dynamic> getBookingPaymentAccounts({
    required int bookingId,
  }) async {
    return _apiClient.get(
      '/payments/booking/$bookingId/accounts',
    );
  }
}