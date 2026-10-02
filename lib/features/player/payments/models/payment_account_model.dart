class PaymentAccountModel {
  // ============================================================
  // ACCOUNT ID
  // ============================================================

  final int id;

  // ============================================================
  // PAYMENT METHOD
  // ============================================================

  // instapay
  // wallet
  final String paymentMethod;

  // ============================================================
  // WALLET PROVIDER
  // ============================================================

  // vodafone_cash
  // orange_cash
  // etisalat_cash
  // we_pay
  //
  // null when paymentMethod == instapay
  final String? walletProvider;

  // ============================================================
  // ACCOUNT DATA
  // ============================================================

  final String accountName;
  final String accountIdentifier;

  // ============================================================
  // CONSTRUCTOR
  // ============================================================

  const PaymentAccountModel({
    required this.id,
    required this.paymentMethod,
    this.walletProvider,
    required this.accountName,
    required this.accountIdentifier,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory PaymentAccountModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return PaymentAccountModel(
      id: _toInt(json['id']) ?? 0,

      paymentMethod:
      json['payment_method']?.toString() ?? '',

      walletProvider:
      json['wallet_provider']?.toString(),

      accountName:
      json['account_name']?.toString() ?? '',

      accountIdentifier:
      json['account_identifier']?.toString() ?? '',
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_method': paymentMethod,
      'wallet_provider': walletProvider,
      'account_name': accountName,
      'account_identifier': accountIdentifier,
    };
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
  // WALLET PROVIDER HELPERS
  // ============================================================

  bool get isVodafoneCash {
    return walletProvider?.toLowerCase() ==
        'vodafone_cash';
  }

  bool get isOrangeCash {
    return walletProvider?.toLowerCase() ==
        'orange_cash';
  }

  bool get isEtisalatCash {
    return walletProvider?.toLowerCase() ==
        'etisalat_cash';
  }

  bool get isWePay {
    return walletProvider?.toLowerCase() ==
        'we_pay';
  }

  // ============================================================
  // DISPLAY NAME
  // ============================================================

  String get displayMethod {
    if (isInstaPay) {
      return 'InstaPay';
    }

    switch (walletProvider?.toLowerCase()) {
      case 'vodafone_cash':
        return 'Vodafone Cash';

      case 'orange_cash':
        return 'Orange Cash';

      case 'etisalat_cash':
        return 'Etisalat Cash';

      case 'we_pay':
        return 'WE Pay';

      default:
        return 'Wallet';
    }
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  PaymentAccountModel copyWith({
    int? id,
    String? paymentMethod,
    String? walletProvider,
    String? accountName,
    String? accountIdentifier,
  }) {
    return PaymentAccountModel(
      id: id ?? this.id,

      paymentMethod:
      paymentMethod ?? this.paymentMethod,

      walletProvider:
      walletProvider ?? this.walletProvider,

      accountName:
      accountName ?? this.accountName,

      accountIdentifier:
      accountIdentifier ??
          this.accountIdentifier,
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

    return int.tryParse(
      value.toString(),
    );
  }
}