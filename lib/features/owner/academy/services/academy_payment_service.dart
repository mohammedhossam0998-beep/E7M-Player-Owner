
import '../../../../core/network/api_client.dart';

class AcademyPaymentService {
  final ApiClient _apiClient;

  AcademyPaymentService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET OWNER ACADEMY PAYMENTS
  // ============================================================

  Future<List<Map<String, dynamic>>> getOwnerPayments() async {
    final response = await _apiClient.get(
      '/payments/academy/owner',
    );

    if (response is! Map ||
        response['success'] != true) {
      throw Exception(
        response is Map
            ? response['message']?.toString() ??
            'Failed to load academy payments'
            : 'Invalid server response',
      );
    }

    final payments = response['payments'];

    if (payments is! List) {
      throw Exception(
        'Invalid academy payments list',
      );
    }

    return payments.map<Map<String, dynamic>>((item) {
      if (item is! Map) {
        throw Exception(
          'Invalid academy payment record',
        );
      }

      return Map<String, dynamic>.from(item);
    }).toList();
  }

  // ============================================================
  // APPROVE ACADEMY PAYMENT
  // ============================================================

  Future<Map<String, dynamic>> approvePayment(
      int paymentId,
      ) async {
    final response = await _apiClient.patch(
      '/payments/academy/$paymentId/approve',
      {},
    );

    if (response is! Map ||
        response['success'] != true) {
      throw Exception(
        response is Map
            ? response['message']?.toString() ??
            'Failed to approve academy payment'
            : 'Invalid server response',
      );
    }

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // REJECT ACADEMY PAYMENT
  // ============================================================

  Future<Map<String, dynamic>> rejectPayment(
      int paymentId,
      ) async {
    final response = await _apiClient.patch(
      '/payments/academy/$paymentId/reject',
      {},
    );

    if (response is! Map ||
        response['success'] != true) {
      throw Exception(
        response is Map
            ? response['message']?.toString() ??
            'Failed to reject academy payment'
            : 'Invalid server response',
      );
    }

    return Map<String, dynamic>.from(response);
  }
}
