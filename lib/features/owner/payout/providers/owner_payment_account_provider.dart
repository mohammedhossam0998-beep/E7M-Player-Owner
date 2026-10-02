import 'package:flutter/foundation.dart';

import '../data/models/owner_payment_account_model.dart';
import '../data/services/owner_payment_account_service.dart';

class OwnerPaymentAccountProvider
    extends ChangeNotifier {
  final OwnerPaymentAccountService _service;

  OwnerPaymentAccountProvider({
    OwnerPaymentAccountService? service,
  }) : _service =
      service ?? OwnerPaymentAccountService();

  List<OwnerPaymentAccountModel> _accounts = [];

  bool _isLoading = false;
  bool _isSaving = false;

  String? _errorMessage;

  List<OwnerPaymentAccountModel> get accounts =>
      List.unmodifiable(_accounts);

  bool get isLoading => _isLoading;

  bool get isSaving => _isSaving;

  String? get errorMessage => _errorMessage;

  Future<void> loadAccounts({
    bool refresh = false,
  }) async {
    if (_isLoading && !refresh) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _accounts =
      await _service.getPaymentAccounts();
    } catch (e) {
      _errorMessage =
          _cleanErrorMessage(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addAccount({
    required String paymentMethod,
    String? walletProvider,
    required String accountName,
    required String accountIdentifier,
  }) async {
    _isSaving = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _service.addPaymentAccount(
        paymentMethod: paymentMethod,
        walletProvider: walletProvider,
        accountName: accountName,
        accountIdentifier: accountIdentifier,
      );

      await _reload();

      return true;
    } catch (e) {
      _errorMessage =
          _cleanErrorMessage(e);

      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> updateAccount({
    required int accountId,
    required String paymentMethod,
    String? walletProvider,
    required String accountName,
    required String accountIdentifier,
  }) async {
    _isSaving = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _service.updatePaymentAccount(
        accountId: accountId,
        paymentMethod: paymentMethod,
        walletProvider: walletProvider,
        accountName: accountName,
        accountIdentifier: accountIdentifier,
      );

      await _reload();

      return true;
    } catch (e) {
      _errorMessage =
          _cleanErrorMessage(e);

      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> deactivateAccount(
      int accountId,
      ) async {
    _isSaving = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _service.deactivatePaymentAccount(
        accountId,
      );

      await _reload();

      return true;
    } catch (e) {
      _errorMessage =
          _cleanErrorMessage(e);

      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<void> _reload() async {
    _accounts =
    await _service.getPaymentAccounts();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _cleanErrorMessage(
      Object error,
      ) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }
}