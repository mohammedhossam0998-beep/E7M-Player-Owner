class OwnerPaymentAccountModel {
  final int id;
  final int ownerId;

  final String paymentMethod;
  final String? walletProvider;

  final String accountName;
  final String accountIdentifier;

  final bool isActive;

  final DateTime createdAt;
  final DateTime updatedAt;

  const OwnerPaymentAccountModel({
    required this.id,
    required this.ownerId,
    required this.paymentMethod,
    this.walletProvider,
    required this.accountName,
    required this.accountIdentifier,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OwnerPaymentAccountModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return OwnerPaymentAccountModel(
      id: int.parse(json['id'].toString()),
      ownerId: int.parse(json['owner_id'].toString()),

      paymentMethod:
      json['payment_method']?.toString() ?? '',

      walletProvider:
      json['wallet_provider']?.toString(),

      accountName:
      json['account_name']?.toString() ?? '',

      accountIdentifier:
      json['account_identifier']?.toString() ?? '',

      isActive:
      json['is_active'] == true,

      createdAt:
      DateTime.parse(
        json['created_at'].toString(),
      ),

      updatedAt:
      DateTime.parse(
        json['updated_at'].toString(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'payment_method': paymentMethod,
      'wallet_provider': walletProvider,
      'account_name': accountName,
      'account_identifier': accountIdentifier,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}