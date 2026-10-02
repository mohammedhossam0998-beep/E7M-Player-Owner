import 'package:e7m/core/network/api_client.dart';

import '../models/owner_payment_account_model.dart';

class OwnerPaymentAccountService {
  final ApiClient _apiClient;

  OwnerPaymentAccountService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET
  // ============================================================

  Future<List<OwnerPaymentAccountModel>>
  getPaymentAccounts() async {
    final response = await _apiClient.get(
      '/owner/payment-accounts',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid payment accounts response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to get payment accounts',
      );
    }

    final data = response['accounts'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) =>
          OwnerPaymentAccountModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
    )
        .toList();
  }

  // ============================================================
  // ADD
  // ============================================================

  Future<OwnerPaymentAccountModel>
  addPaymentAccount({
    required String paymentMethod,
    String? walletProvider,
    required String accountName,
    required String accountIdentifier,
  }) async {
    final response = await _apiClient.post(
      '/owner/payment-accounts',
      {
        'payment_method': paymentMethod,
        'wallet_provider': walletProvider,
        'account_name': accountName,
        'account_identifier': accountIdentifier,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid add payment account response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to add payment account',
      );
    }

    return OwnerPaymentAccountModel.fromJson(
      Map<String, dynamic>.from(
        response['account'],
      ),
    );
  }

  // ============================================================
  // UPDATE
  // ============================================================

  Future<OwnerPaymentAccountModel>
  updatePaymentAccount({
    required int accountId,
    required String paymentMethod,
    String? walletProvider,
    required String accountName,
    required String accountIdentifier,
  }) async {
    final response = await _apiClient.put(
      '/owner/payment-accounts/$accountId',
      {
        'payment_method': paymentMethod,
        'wallet_provider': walletProvider,
        'account_name': accountName,
        'account_identifier': accountIdentifier,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid update payment account response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to update payment account',
      );
    }

    return OwnerPaymentAccountModel.fromJson(
      Map<String, dynamic>.from(
        response['account'],
      ),
    );
  }

  // ============================================================
  // DEACTIVATE
  // ============================================================

  Future<void> deactivatePaymentAccount(
      int accountId,
      ) async {
    final response = await _apiClient.delete(
      '/owner/payment-accounts/$accountId',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid delete payment account response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to deactivate payment account',
      );
    }
  }
}