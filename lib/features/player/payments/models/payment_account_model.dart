class PaymentAccountModel {
  final String paymentMethod;
  final String accountName;
  final String accountIdentifier;

  const PaymentAccountModel({
    required this.paymentMethod,
    required this.accountName,
    required this.accountIdentifier,
  });

  factory PaymentAccountModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return PaymentAccountModel(
      paymentMethod:
      json['payment_method']?.toString() ?? '',

      accountName:
      json['account_name']?.toString() ?? '',

      accountIdentifier:
      json['account_identifier']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'payment_method': paymentMethod,
      'account_name': accountName,
      'account_identifier': accountIdentifier,
    };
  }
}