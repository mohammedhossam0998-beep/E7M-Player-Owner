import 'package:flutter/foundation.dart';

import 'package:e7m/core/network/api_client.dart';

import '../models/transaction_model.dart';

class RevenueProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  String? _error;

  List<TransactionModel> _transactions = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TransactionModel> get transactions =>
      List.unmodifiable(_transactions);

  /// جميع المدفوعات التي رجعها الـ Backend
  List<TransactionModel> get allPayments =>
      List.unmodifiable(_transactions);

  /// المدفوعات الناجحة فقط
  List<TransactionModel> get paidTransactions {
    return _transactions
        .where((transaction) =>
    transaction.status.toLowerCase() == 'paid')
        .toList();
  }

  /// المدفوعات المعلقة
  List<TransactionModel> get pendingTransactions {
    return _transactions
        .where((transaction) =>
    transaction.status.toLowerCase() == 'pending')
        .toList();
  }

  /// المدفوعات الفاشلة
  List<TransactionModel> get failedTransactions {
    return _transactions
        .where((transaction) =>
    transaction.status.toLowerCase() == 'failed')
        .toList();
  }

  /// المدفوعات المستردة
  List<TransactionModel> get refundedTransactions {
    return _transactions
        .where((transaction) =>
    transaction.status.toLowerCase() == 'refunded')
        .toList();
  }

  /// إجمالي الإيرادات المدفوعة
  double get totalRevenue {
    return paidTransactions.fold(
      0,
          (sum, transaction) => sum + transaction.amount,
    );
  }

  /// إجمالي المدفوعات
  double get totalPayments {
    return _transactions.fold(
      0,
          (sum, transaction) => sum + transaction.amount,
    );
  }

  /// عدد المدفوعات الناجحة
  int get paidCount => paidTransactions.length;

  /// عدد المدفوعات المعلقة
  int get pendingCount => pendingTransactions.length;

  /// عدد المدفوعات الفاشلة
  int get failedCount => failedTransactions.length;

  /// عدد المدفوعات المستردة
  int get refundedCount => refundedTransactions.length;

  /// إيرادات الشهر الحالي
  double get currentMonthRevenue {
    final now = DateTime.now();

    return paidTransactions
        .where(
          (transaction) =>
      transaction.date.year == now.year &&
          transaction.date.month == now.month,
    )
        .fold(
      0,
          (sum, transaction) => sum + transaction.amount,
    );
  }

  /// إيرادات الشهر السابق
  double get previousMonthRevenue {
    final now = DateTime.now();

    final previousMonth =
    now.month == 1 ? 12 : now.month - 1;

    final previousYear =
    now.month == 1 ? now.year - 1 : now.year;

    return paidTransactions
        .where(
          (transaction) =>
      transaction.date.year == previousYear &&
          transaction.date.month == previousMonth,
    )
        .fold(
      0,
          (sum, transaction) => sum + transaction.amount,
    );
  }

  /// نسبة النمو بين الشهر الحالي والسابق
  double get revenueGrowthPercentage {
    final previous = previousMonthRevenue;
    final current = currentMonthRevenue;

    if (previous == 0) {
      if (current == 0) return 0;
      return 100;
    }

    return ((current - previous) / previous) * 100;
  }

  /// آخر العمليات
  List<TransactionModel> get recentTransactions {
    final sorted = List<TransactionModel>.from(_transactions);

    sorted.sort(
          (a, b) => b.date.compareTo(a.date),
    );

    return sorted.take(10).toList();
  }

  /// إيرادات آخر 7 أيام
  Map<DateTime, double> get last7DaysRevenue {
    final now = DateTime.now();

    final result = <DateTime, double>{};

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: i));

      result[date] = 0;
    }

    for (final transaction in paidTransactions) {
      final transactionDate = DateTime(
        transaction.date.year,
        transaction.date.month,
        transaction.date.day,
      );

      if (result.containsKey(transactionDate)) {
        result[transactionDate] =
            result[transactionDate]! + transaction.amount;
      }
    }

    return result;
  }

  Future<void> fetchRevenue() async {
    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final response =
      await _apiClient.get('/owner/payments');

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid revenue response',
        );
      }

      final payments = response['payments'];

      if (payments is! List) {
        throw Exception(
          'Invalid payments data',
        );
      }

      _transactions = payments
          .whereType<Map>()
          .map(
            (payment) => TransactionModel.fromMap(
          Map<String, dynamic>.from(payment),
        ),
      )
          .toList();
    } catch (e) {
      _error = e.toString();
      _transactions = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchRevenue();
  }
}