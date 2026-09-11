class CompetitionPaymentAccountModel {
  final int id;
  final int ownerId;

  final String paymentMethod;
  final String accountName;
  final String accountIdentifier;

  final bool isActive;

  const CompetitionPaymentAccountModel({
    required this.id,
    required this.ownerId,
    required this.paymentMethod,
    required this.accountName,
    required this.accountIdentifier,
    required this.isActive,
  });

  factory CompetitionPaymentAccountModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionPaymentAccountModel(
      id: _parseInt(json['id']),

      ownerId: _parseInt(
        json['owner_id'] ??
            json['ownerId'],
      ),

      paymentMethod: (
          json['payment_method'] ??
              json['paymentMethod'] ??
              ''
      ).toString(),

      accountName: (
          json['account_name'] ??
              json['accountName'] ??
              ''
      ).toString(),

      accountIdentifier: (
          json['account_identifier'] ??
              json['accountIdentifier'] ??
              ''
      ).toString(),

      isActive: _parseBool(
        json['is_active'] ??
            json['isActive'] ??
            false,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'payment_method': paymentMethod,
      'account_name': accountName,
      'account_identifier': accountIdentifier,
      'is_active': isActive,
    };
  }

  CompetitionPaymentAccountModel copyWith({
    int? id,
    int? ownerId,
    String? paymentMethod,
    String? accountName,
    String? accountIdentifier,
    bool? isActive,
  }) {
    return CompetitionPaymentAccountModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      paymentMethod:
      paymentMethod ?? this.paymentMethod,
      accountName:
      accountName ?? this.accountName,
      accountIdentifier:
      accountIdentifier ??
          this.accountIdentifier,
      isActive:
      isActive ?? this.isActive,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  bool get isWallet =>
      paymentMethod.toLowerCase() == 'wallet';

  bool get isInstaPay =>
      paymentMethod.toLowerCase() == 'instapay';

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static bool _parseBool(dynamic value) {
    if (value is bool) {
      return value;
    }

    if (value is num) {
      return value != 0;
    }

    final normalized =
    value?.toString().toLowerCase().trim();

    return normalized == 'true' ||
        normalized == '1' ||
        normalized == 'yes';
  }
}