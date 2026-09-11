class CompetitionPaymentModel {
  final int id;
  final int registrationId;
  final int competitionId;
  final int? playerId;
  final int? captainId;

  final double amount;
  final String paymentMethod;
  final String transactionReference;

  final int? ownerPaymentAccountId;

  final String? proofImageUrl;

  final String status;

  final DateTime? submittedAt;
  final DateTime? paidAt;
  final DateTime? verifiedAt;
  final DateTime? rejectedAt;

  final int? verifiedBy;
  final String? rejectionReason;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompetitionPaymentModel({
    required this.id,
    required this.registrationId,
    required this.competitionId,
    this.playerId,
    this.captainId,
    required this.amount,
    required this.paymentMethod,
    required this.transactionReference,
    this.ownerPaymentAccountId,
    this.proofImageUrl,
    required this.status,
    this.submittedAt,
    this.paidAt,
    this.verifiedAt,
    this.rejectedAt,
    this.verifiedBy,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  factory CompetitionPaymentModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionPaymentModel(
      id: _parseInt(json['id']),
      registrationId: _parseInt(
        json['registration_id'] ??
            json['registrationId'],
      ),
      competitionId: _parseInt(
        json['competition_id'] ??
            json['competitionId'],
      ),
      playerId: _parseNullableInt(
        json['player_id'] ?? json['playerId'],
      ),
      captainId: _parseNullableInt(
        json['captain_id'] ?? json['captainId'],
      ),
      amount: _parseDouble(json['amount']),
      paymentMethod: (
          json['payment_method'] ??
              json['paymentMethod'] ??
              ''
      ).toString(),
      transactionReference: (
          json['transaction_reference'] ??
              json['transactionReference'] ??
              ''
      ).toString(),
      ownerPaymentAccountId: _parseNullableInt(
        json['owner_payment_account_id'] ??
            json['ownerPaymentAccountId'],
      ),
      proofImageUrl:
      json['proof_image_url']?.toString() ??
          json['proofImageUrl']?.toString(),
      status: (
          json['status'] ?? ''
      ).toString(),
      submittedAt: _parseDateTime(
        json['submitted_at'] ?? json['submittedAt'],
      ),
      paidAt: _parseDateTime(
        json['paid_at'] ?? json['paidAt'],
      ),
      verifiedAt: _parseDateTime(
        json['verified_at'] ?? json['verifiedAt'],
      ),
      rejectedAt: _parseDateTime(
        json['rejected_at'] ?? json['rejectedAt'],
      ),
      verifiedBy: _parseNullableInt(
        json['verified_by'] ?? json['verifiedBy'],
      ),
      rejectionReason:
      json['rejection_reason']?.toString() ??
          json['rejectionReason']?.toString(),
      createdAt: _parseDateTime(
        json['created_at'] ?? json['createdAt'],
      ),
      updatedAt: _parseDateTime(
        json['updated_at'] ?? json['updatedAt'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registration_id': registrationId,
      'competition_id': competitionId,
      'player_id': playerId,
      'captain_id': captainId,
      'amount': amount,
      'payment_method': paymentMethod,
      'transaction_reference': transactionReference,
      'owner_payment_account_id': ownerPaymentAccountId,
      'proof_image_url': proofImageUrl,
      'status': status,
      'submitted_at':
      submittedAt?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'verified_at':
      verifiedAt?.toIso8601String(),
      'rejected_at':
      rejectedAt?.toIso8601String(),
      'verified_by': verifiedBy,
      'rejection_reason': rejectionReason,
      'created_at':
      createdAt?.toIso8601String(),
      'updated_at':
      updatedAt?.toIso8601String(),
    };
  }

  CompetitionPaymentModel copyWith({
    int? id,
    int? registrationId,
    int? competitionId,
    int? playerId,
    int? captainId,
    double? amount,
    String? paymentMethod,
    String? transactionReference,
    int? ownerPaymentAccountId,
    String? proofImageUrl,
    String? status,
    DateTime? submittedAt,
    DateTime? paidAt,
    DateTime? verifiedAt,
    DateTime? rejectedAt,
    int? verifiedBy,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompetitionPaymentModel(
      id: id ?? this.id,
      registrationId:
      registrationId ?? this.registrationId,
      competitionId:
      competitionId ?? this.competitionId,
      playerId: playerId ?? this.playerId,
      captainId: captainId ?? this.captainId,
      amount: amount ?? this.amount,
      paymentMethod:
      paymentMethod ?? this.paymentMethod,
      transactionReference:
      transactionReference ??
          this.transactionReference,
      ownerPaymentAccountId:
      ownerPaymentAccountId ??
          this.ownerPaymentAccountId,
      proofImageUrl:
      proofImageUrl ?? this.proofImageUrl,
      status: status ?? this.status,
      submittedAt:
      submittedAt ?? this.submittedAt,
      paidAt: paidAt ?? this.paidAt,
      verifiedAt:
      verifiedAt ?? this.verifiedAt,
      rejectedAt:
      rejectedAt ?? this.rejectedAt,
      verifiedBy:
      verifiedBy ?? this.verifiedBy,
      rejectionReason:
      rejectionReason ?? this.rejectionReason,
      createdAt:
      createdAt ?? this.createdAt,
      updatedAt:
      updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == 'pending';

  bool get isSubmitted => status == 'submitted';

  bool get isPaid => status == 'paid';

  bool get isFailed => status == 'failed';

  bool get isExpired => status == 'expired';

  bool get isRefunded => status == 'refunded';

  bool get isPartiallyRefunded =>
      status == 'partially_refunded';

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

  static int? _parseNullableInt(dynamic value) {
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

  static double _parseDouble(dynamic value) {
    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0.0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }
}