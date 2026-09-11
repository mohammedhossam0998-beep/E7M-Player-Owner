import 'package:flutter/foundation.dart';

import 'package:e7m/core/network/api_client.dart';

class OwnerDashboardProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic>? _profile;
  List<Map<String, dynamic>> _pitches = [];
  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _payments = [];

  // ============================================================
  // GETTERS
  // ============================================================

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  Map<String, dynamic>? get profile => _profile;

  List<Map<String, dynamic>> get pitches => _pitches;

  List<Map<String, dynamic>> get bookings => _bookings;

  List<Map<String, dynamic>> get payments => _payments;

  bool get hasData =>
      _profile != null ||
          _pitches.isNotEmpty ||
          _bookings.isNotEmpty ||
          _payments.isNotEmpty;

  // ============================================================
  // PROFILE
  // ============================================================

  String get ownerName {
    final name = _profile?['full_name']?.toString().trim();

    if (name == null || name.isEmpty) {
      return 'Owner';
    }

    return name;
  }

  String? get profileImage {
    final image = _profile?['profile_image']?.toString().trim();

    if (image == null || image.isEmpty) {
      return null;
    }

    return image;
  }

  // ============================================================
  // PITCHES
  // ============================================================

  int get totalPitches => _pitches.length;

  String? get firstPitchName {
    if (_pitches.isEmpty) {
      return null;
    }

    return _pitches.first['name']?.toString();
  }

  // ============================================================
  // BOOKINGS
  // ============================================================

  int get totalBookings => _bookings.length;

  int get todayBookings {
    final now = DateTime.now();

    return _bookings.where((booking) {
      final date = _extractBookingDate(booking);

      if (date == null) {
        return false;
      }

      return date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;
    }).length;
  }

  // ============================================================
  // PAYMENTS / REVENUE
  // ============================================================

  double get totalRevenue {
    double total = 0;

    for (final payment in _payments) {
      final status = payment['status']
          ?.toString()
          .toLowerCase();

      // Only count successful/completed payments.
      if (status != 'completed' &&
          status != 'success' &&
          status != 'paid') {
        continue;
      }

      total += _toDouble(
        payment['amount'] ?? payment['total_price'],
      );
    }

    return total;
  }

  double get currentMonthRevenue {
    final now = DateTime.now();
    double total = 0;

    for (final payment in _payments) {
      final status = payment['status']
          ?.toString()
          .toLowerCase();

      if (status != 'completed' &&
          status != 'success' &&
          status != 'paid') {
        continue;
      }

      final date = _extractPaymentDate(payment);

      if (date == null) {
        continue;
      }

      if (date.year == now.year &&
          date.month == now.month) {
        total += _toDouble(
          payment['amount'] ?? payment['total_price'],
        );
      }
    }

    return total;
  }

  // ============================================================
  // LOAD DASHBOARD
  // ============================================================

  Future<bool> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await Future.wait([
        _loadProfile(),
        _loadPitches(),
        _loadBookings(),
        _loadPayments(),
      ]);

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // LOAD PROFILE
  // ============================================================

  Future<void> _loadProfile() async {
    final response = await _apiClient.get(
      '/owner/profile',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid owner profile response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to load owner profile',
      );
    }

    final owner = response['owner'];

    if (owner is! Map<String, dynamic>) {
      throw Exception(
        'Owner profile data is missing',
      );
    }

    _profile = Map<String, dynamic>.from(owner);
  }

  // ============================================================
  // LOAD PITCHES
  // ============================================================

  Future<void> _loadPitches() async {
    final response = await _apiClient.get(
      '/owner/pitches',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid pitches response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to load pitches',
      );
    }

    final pitches = response['pitches'];

    if (pitches is List) {
      _pitches = pitches
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
      )
          .toList();
    } else {
      _pitches = [];
    }
  }

  // ============================================================
  // LOAD BOOKINGS
  // ============================================================

  Future<void> _loadBookings() async {
    final response = await _apiClient.get(
      '/owner/bookings',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid bookings response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to load bookings',
      );
    }

    final bookings = response['bookings'];

    if (bookings is List) {
      _bookings = bookings
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
      )
          .toList();
    } else {
      _bookings = [];
    }
  }

  // ============================================================
  // LOAD PAYMENTS
  // ============================================================

  Future<void> _loadPayments() async {
    final response = await _apiClient.get(
      '/owner/payments',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid payments response',
      );
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to load payments',
      );
    }

    final payments = response['payments'];

    if (payments is List) {
      _payments = payments
          .whereType<Map>()
          .map(
            (item) => Map<String, dynamic>.from(item),
      )
          .toList();
    } else {
      _payments = [];
    }
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<bool> refreshDashboard() async {
    return loadDashboard();
  }

  // ============================================================
  // DATE HELPERS
  // ============================================================

  DateTime? _extractBookingDate(
      Map<String, dynamic> booking,
      ) {
    final value =
        booking['slot_date'] ??
            booking['booking_date'] ??
            booking['created_at'];

    return _parseDate(value);
  }

  DateTime? _extractPaymentDate(
      Map<String, dynamic> payment,
      ) {
    final value =
        payment['created_at'] ??
            payment['payment_date'] ??
            payment['slot_date'];

    return _parseDate(value);
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  // ============================================================
  // NUMBER HELPERS
  // ============================================================

  double _toDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    ) ??
        0;
  }

  // ============================================================
  // ERROR
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}