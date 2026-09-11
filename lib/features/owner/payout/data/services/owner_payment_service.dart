import 'package:e7m/core/network/api_client.dart';

import '../models/owner_payment_model.dart';

class OwnerPaymentService {
  final ApiClient _apiClient;

  OwnerPaymentService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET OWNER PAYMENTS
  // GET /api/owner/payments
  // ============================================================

  Future<List<OwnerPaymentModel>> getOwnerPayments() async {
    try {
      final response = await _apiClient.get(
        '/owner/payments',
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid payments response',
        );
      }

      final success = response['success'] == true;

      if (!success) {
        throw Exception(
          response['message']?.toString() ??
              'Failed to get owner payments',
        );
      }

      final paymentsData = response['payments'];

      if (paymentsData is! List) {
        return [];
      }

      return paymentsData
          .map(
            (payment) => OwnerPaymentModel.fromJson(
          Map<String, dynamic>.from(payment),
        ),
      )
          .toList();
    } catch (e) {
      print(
        '❌ GET OWNER PAYMENTS SERVICE ERROR: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // APPROVE PAYMENT
  // PATCH /api/owner/payments/:id/approve
  // ============================================================

  Future<void> approvePayment(
      int paymentId,
      ) async {
    try {
      final response = await _apiClient.patch(
        '/owner/payments/$paymentId/approve',
        {},
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid approve payment response',
        );
      }

      final success = response['success'] == true;

      if (!success) {
        throw Exception(
          response['message']?.toString() ??
              'Failed to approve payment',
        );
      }

      // The approve endpoint returns a partial payment object.
      // The Provider reloads the complete payment list from
      // GET /owner/payments after a successful approval.
    } catch (e) {
      print(
        '❌ APPROVE PAYMENT SERVICE ERROR: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // REJECT PAYMENT
  // PATCH /api/owner/payments/:id/reject
  // ============================================================

  Future<void> rejectPayment(
      int paymentId,
      ) async {
    try {
      final response = await _apiClient.patch(
        '/owner/payments/$paymentId/reject',
        {},
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid reject payment response',
        );
      }

      final success = response['success'] == true;

      if (!success) {
        throw Exception(
          response['message']?.toString() ??
              'Failed to reject payment',
        );
      }

      // The reject endpoint returns a partial payment object.
      // The Provider reloads the complete payment list from
      // GET /owner/payments after a successful rejection.
    } catch (e) {
      print(
        '❌ REJECT PAYMENT SERVICE ERROR: $e',
      );

      rethrow;
    }
  }
}