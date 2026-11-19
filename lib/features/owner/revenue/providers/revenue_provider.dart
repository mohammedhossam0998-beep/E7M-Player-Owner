import 'package:flutter/foundation.dart';

import 'package:e7m/core/network/api_client.dart';
import 'package:e7m/features/owner/academy/services/academy_payment_service.dart';

import '../models/transaction_model.dart';

class RevenueProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();
  final AcademyPaymentService _academyPayments = AcademyPaymentService();

  int _sessionVersion = 0;
  int _requestVersion = 0;

  bool _isLoading = false;
  String? _error;

  List<TransactionModel> _transactions = [];

  bool get isLoading => _isLoading;
  String? get error => _error;

  List<TransactionModel> get transactions =>
      List.unmodifiable(_transactions);

  /// جميع المدفوعات التي رجعها الـ Backend.
  List<TransactionModel> get allPayments =>
      List.unmodifiable(_transactions);

  /// المدفوعات الناجحة، بما فيها المدفوعات المسترد جزء منها.
  List<TransactionModel> get paidTransactions {
    return _transactions
        .where(
          (transaction) =>
      transaction.status == 'paid' ||
          transaction.status == 'partially_refunded',
    )
        .toList();
  }

  /// المدفوعات المعلقة.
  List<TransactionModel> get pendingTransactions {
    return _transactions
        .where((transaction) => transaction.status == 'pending')
        .toList();
  }

  /// المدفوعات الفاشلة أو المرفوضة.
  List<TransactionModel> get failedTransactions {
    return _transactions
        .where((transaction) => transaction.status == 'failed')
        .toList();
  }

  /// المدفوعات المستردة كليًا أو جزئيًا.
  List<TransactionModel> get refundedTransactions {
    return _transactions
        .where(
          (transaction) =>
      transaction.status == 'refunded' ||
          transaction.status == 'partially_refunded',
    )
        .toList();
  }

  /// الإيراد بعد خصم المبالغ المستردة.
  double get totalRevenue {
    return paidTransactions.fold(
      0,
          (sum, transaction) => sum + transaction.recognizedAmount,
    );
  }

  /// مجموع مبالغ كل سجلات الدفع.
  double get totalPayments {
    return _transactions.fold(
      0,
          (sum, transaction) => sum + transaction.amount,
    );
  }

  int get paidCount => paidTransactions.length;
  int get pendingCount => pendingTransactions.length;
  int get failedCount => failedTransactions.length;
  int get refundedCount => refundedTransactions.length;

  /// إيرادات الشهر الحالي.
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
          (sum, transaction) => sum + transaction.recognizedAmount,
    );
  }

  /// إيرادات الشهر السابق.
  double get previousMonthRevenue {
    final now = DateTime.now();

    final previousMonth = now.month == 1 ? 12 : now.month - 1;
    final previousYear = now.month == 1 ? now.year - 1 : now.year;

    return paidTransactions
        .where(
          (transaction) =>
      transaction.date.year == previousYear &&
          transaction.date.month == previousMonth,
    )
        .fold(
      0,
          (sum, transaction) => sum + transaction.recognizedAmount,
    );
  }

  /// نسبة النمو بين الشهر الحالي والسابق.
  double get revenueGrowthPercentage {
    final previous = previousMonthRevenue;
    final current = currentMonthRevenue;

    if (previous == 0) {
      if (current == 0) return 0;
      return 100;
    }

    return ((current - previous) / previous) * 100;
  }

  /// آخر العمليات.
  List<TransactionModel> get recentTransactions {
    final sorted = List<TransactionModel>.from(_transactions)
      ..sort((a, b) => b.date.compareTo(a.date));

    return sorted.take(10).toList();
  }

  /// إيرادات آخر 7 أيام.
  Map<DateTime, double> get last7DaysRevenue {
    final now = DateTime.now();
    final result = <DateTime, double>{};

    for (int i = 6; i >= 0; i--) {
      final date = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));

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
            result[transactionDate]! + transaction.recognizedAmount;
      }
    }

    return result;
  }

  Future<void> fetchRevenue() async {
    final session = _sessionVersion;
    final request = ++_requestVersion;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // مصادر الإيرادات: حجوزات الملاعب، الأكاديميات، والبطولات.
      final responses = await Future.wait<dynamic>([
        _apiClient.get('/owner/payments'),
        _academyPayments.getOwnerPayments(),
        _apiClient.get('/owner/competition-payments'),
      ]);

      if (session != _sessionVersion || request != _requestVersion) {
        return;
      }

      final bookingRows = _paymentsFrom(responses[0], 'payments');

      final academyRows =
      (responses[1] as List<Map<String, dynamic>>).map((row) => {
        ...row,
        'source_type': 'academy',
        'source_reference_id':
        row['enrollment_id'] ?? row['id'],
        'booking_id': row['enrollment_id'] ?? '',
        'pitch_name':
        row['academy_name'] ?? row['program_name'] ?? 'Academy',
      });

      final competitionRows =
      _paymentsFrom(responses[2], 'payments').map((row) => {
        ...row,
        'source_type': 'competition',
        'source_reference_id':
        row['registration_id'] ?? row['id'],
        'booking_id': row['registration_id'] ?? '',
        'pitch_name': row['competition_name'] ?? 'Competition',
      });

      _transactions = [
        ...bookingRows.map((row) => _transaction(row, 'booking')),
        ...academyRows.map((row) => _transaction(row, 'academy')),
        ...competitionRows.map((row) => _transaction(row, 'competition')),
      ];
    } catch (e) {
      if (session == _sessionVersion && request == _requestVersion) {
        _error = e.toString();
      }
    } finally {
      if (session == _sessionVersion && request == _requestVersion) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  List<Map<String, dynamic>> _paymentsFrom(
      dynamic response,
      String key,
      ) {
    if (response is! Map || response[key] is! List) {
      throw Exception('Invalid $key data');
    }

    return (response[key] as List)
        .whereType<Map>()
        .map((row) => Map<String, dynamic>.from(row))
        .toList();
  }

  TransactionModel _transaction(
      Map<String, dynamic> row,
      String source,
      ) {
    return TransactionModel.fromMap({
      ...row,
      'source_type': source,
      'id': '${source}_${row['id'] ?? ''}',
      'status': row['status'] ?? row['payment_status'] ?? 'pending',
    });
  }

  /// يمنع رجوع بيانات الحساب السابق بعد تسجيل الخروج أو تبديل الحساب.
  void clear() {
    _sessionVersion++;
    _requestVersion++;

    _transactions = [];
    _isLoading = false;
    _error = null;

    notifyListeners();
  }

  Future<void> refresh() async {
    await fetchRevenue();
  }
}