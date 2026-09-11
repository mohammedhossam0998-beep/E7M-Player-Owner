class PaymentModel {
  final int id;
  final int userId;
  final int bookingId;
  final double amount;

  final String paymentMethod;
  final String paymentType;
  final String status;

  final int? ownerPaymentAccountId;
  final String? transactionReference;
  final DateTime? createdAt;

  // Owner payment account data
  final String? paymentAccountMethod;
  final String? paymentAccountName;
  final String? paymentAccountIdentifier;

  const PaymentModel({
    required this.id,
    required this.userId,
    required this.bookingId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentType,
    required this.status,
    this.ownerPaymentAccountId,
    this.transactionReference,
    this.createdAt,
    this.paymentAccountMethod,
    this.paymentAccountName,
    this.paymentAccountIdentifier,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: _toInt(json['id']) ?? 0,
      userId: _toInt(json['user_id']) ?? 0,
      bookingId: _toInt(json['booking_id']) ?? 0,
      amount: _toDouble(json['amount']) ?? 0.0,

      paymentMethod:
      json['payment_method']?.toString() ?? '',

      paymentType:
      json['payment_type']?.toString() ?? '',

      status:
      json['status']?.toString() ?? '',

      ownerPaymentAccountId:
      _toInt(json['owner_payment_account_id']),

      transactionReference:
      json['transaction_reference']?.toString(),

      createdAt:
      _toDateTime(json['created_at']),

      paymentAccountMethod:
      json['payment_account_method']?.toString(),

      paymentAccountName:
      json['payment_account_name']?.toString(),

      paymentAccountIdentifier:
      json['payment_account_identifier']?.toString(),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'booking_id': bookingId,
      'amount': amount,
      'payment_method': paymentMethod,
      'payment_type': paymentType,
      'status': status,
      'owner_payment_account_id': ownerPaymentAccountId,
      'transaction_reference': transactionReference,
      'created_at': createdAt?.toIso8601String(),

      'payment_account_method': paymentAccountMethod,
      'payment_account_name': paymentAccountName,
      'payment_account_identifier': paymentAccountIdentifier,
    };
  }

  // ============================================================
  // STATUS HELPERS
  // ============================================================

  bool get isPending {
    return status.toLowerCase() == 'pending';
  }

  bool get isPaid {
    return status.toLowerCase() == 'paid';
  }

  bool get isFailed {
    return status.toLowerCase() == 'failed';
  }

  // ============================================================
  // PAYMENT TYPE HELPERS
  // ============================================================

  bool get isDeposit {
    return paymentType.toLowerCase() == 'deposit';
  }

  bool get isFullPayment {
    return paymentType.toLowerCase() == 'full_payment';
  }

  // ============================================================
  // PAYMENT METHOD HELPERS
  // ============================================================

  bool get isInstaPay {
    return paymentMethod.toLowerCase() == 'instapay';
  }

  bool get isWallet {
    return paymentMethod.toLowerCase() == 'wallet';
  }

  // ============================================================
  // ACCOUNT DATA
  // ============================================================

  bool get hasPaymentAccount {
    return paymentAccountName != null &&
        paymentAccountIdentifier != null &&
        paymentAccountIdentifier!.isNotEmpty;
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  PaymentModel copyWith({
    int? id,
    int? userId,
    int? bookingId,
    double? amount,
    String? paymentMethod,
    String? paymentType,
    String? status,
    int? ownerPaymentAccountId,
    String? transactionReference,
    DateTime? createdAt,
    String? paymentAccountMethod,
    String? paymentAccountName,
    String? paymentAccountIdentifier,
  }) {
    return PaymentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      bookingId: bookingId ?? this.bookingId,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentType: paymentType ?? this.paymentType,
      status: status ?? this.status,
      ownerPaymentAccountId:
      ownerPaymentAccountId ?? this.ownerPaymentAccountId,
      transactionReference:
      transactionReference ?? this.transactionReference,
      createdAt: createdAt ?? this.createdAt,
      paymentAccountMethod:
      paymentAccountMethod ?? this.paymentAccountMethod,
      paymentAccountName:
      paymentAccountName ?? this.paymentAccountName,
      paymentAccountIdentifier:
      paymentAccountIdentifier ?? this.paymentAccountIdentifier,
    );
  }

  // ============================================================
  // PARSING HELPERS
  // ============================================================

  static int? _toInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }
}