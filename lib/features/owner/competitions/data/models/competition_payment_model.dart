class CompetitionPaymentModel {
  final int id;
  final int registrationId;
  final int competitionId;

  final double amount;
  final String currency;
  final String status;

  final String? paymentMethod;
  final String? transactionReference;
  final String? proofImageUrl;

  final DateTime? submittedAt;
  final DateTime? paidAt;
  final DateTime? verifiedAt;
  final int? verifiedBy;
  final DateTime? rejectedAt;
  final String? rejectionReason;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  // ============================================================
  // COMPETITION
  // ============================================================

  final String? competitionName;
  final double? entryFee;
  final DateTime? startDate;
  final DateTime? endDate;

  // ============================================================
  // REGISTRATION
  // ============================================================

  final String? registrationStatus;
  final int? playerId;
  final int? teamId;
  final DateTime? paymentDeadline;
  final DateTime? slotLockedAt;

  // ============================================================
  // PLAYER
  // ============================================================

  final String? playerName;
  final String? playerEmail;

  // ============================================================
  // OWNER PAYMENT ACCOUNT
  // ============================================================

  final String? accountName;
  final String? accountIdentifier;

  const CompetitionPaymentModel({
    required this.id,
    required this.registrationId,
    required this.competitionId,
    required this.amount,
    required this.currency,
    required this.status,
    this.paymentMethod,
    this.transactionReference,
    this.proofImageUrl,
    this.submittedAt,
    this.paidAt,
    this.verifiedAt,
    this.verifiedBy,
    this.rejectedAt,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
    this.competitionName,
    this.entryFee,
    this.startDate,
    this.endDate,
    this.registrationStatus,
    this.playerId,
    this.teamId,
    this.paymentDeadline,
    this.slotLockedAt,
    this.playerName,
    this.playerEmail,
    this.accountName,
    this.accountIdentifier,
  });

  // ============================================================
  // HELPERS
  // ============================================================

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String && value.trim().isNotEmpty) {
      return DateTime.tryParse(value);
    }

    return null;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString()) ?? 0;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is int) {
      return value;
    }

    return int.tryParse(value.toString());
  }

  static String? _parseString(dynamic value) {
    if (value == null) {
      return null;
    }

    final valueString = value.toString().trim();

    if (valueString.isEmpty) {
      return null;
    }

    return valueString;
  }

  // ============================================================
  // FROM JSON
  // ============================================================

  factory CompetitionPaymentModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionPaymentModel(
      id: _parseInt(json['id']) ?? 0,

      registrationId:
      _parseInt(json['registration_id']) ?? 0,

      competitionId:
      _parseInt(json['competition_id']) ?? 0,

      amount: _parseDouble(json['amount']),

      currency:
      json['currency']?.toString() ?? 'EGP',

      status:
      json['status']?.toString() ?? 'pending',

      paymentMethod:
      _parseString(json['payment_method']),

      transactionReference:
      _parseString(json['transaction_reference']),

      proofImageUrl:
      _parseString(json['proof_image_url']),

      submittedAt:
      _parseDate(json['submitted_at']),

      paidAt:
      _parseDate(json['paid_at']),

      verifiedAt:
      _parseDate(json['verified_at']),

      verifiedBy:
      _parseInt(json['verified_by']),

      rejectedAt:
      _parseDate(json['rejected_at']),

      rejectionReason:
      _parseString(json['rejection_reason']),

      createdAt:
      _parseDate(json['created_at']),

      updatedAt:
      _parseDate(json['updated_at']),

      // Competition
      competitionName:
      _parseString(json['competition_name']),

      entryFee:
      json['entry_fee'] == null
          ? null
          : _parseDouble(json['entry_fee']),

      startDate:
      _parseDate(json['start_date']),

      endDate:
      _parseDate(json['end_date']),

      // Registration
      registrationStatus:
      _parseString(json['registration_status']),

      playerId:
      _parseInt(json['player_id']),

      teamId:
      _parseInt(json['team_id']),

      paymentDeadline:
      _parseDate(json['payment_deadline']),

      slotLockedAt:
      _parseDate(json['slot_locked_at']),

      // Player
      playerName:
      _parseString(json['player_name']),

      playerEmail:
      _parseString(json['player_email']),

      // Owner payment account
      accountName:
      _parseString(json['account_name']),

      accountIdentifier:
      _parseString(json['account_identifier']),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'registration_id': registrationId,
      'competition_id': competitionId,
      'amount': amount,
      'currency': currency,
      'status': status,
      'payment_method': paymentMethod,
      'transaction_reference': transactionReference,
      'proof_image_url': proofImageUrl,
      'submitted_at': submittedAt?.toIso8601String(),
      'paid_at': paidAt?.toIso8601String(),
      'verified_at': verifiedAt?.toIso8601String(),
      'verified_by': verifiedBy,
      'rejected_at': rejectedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'competition_name': competitionName,
      'entry_fee': entryFee,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'registration_status': registrationStatus,
      'player_id': playerId,
      'team_id': teamId,
      'payment_deadline': paymentDeadline?.toIso8601String(),
      'slot_locked_at': slotLockedAt?.toIso8601String(),
      'player_name': playerName,
      'player_email': playerEmail,
      'account_name': accountName,
      'account_identifier': accountIdentifier,
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  CompetitionPaymentModel copyWith({
    int? id,
    int? registrationId,
    int? competitionId,
    double? amount,
    String? currency,
    String? status,
    String? paymentMethod,
    String? transactionReference,
    String? proofImageUrl,
    DateTime? submittedAt,
    DateTime? paidAt,
    DateTime? verifiedAt,
    int? verifiedBy,
    DateTime? rejectedAt,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? competitionName,
    double? entryFee,
    DateTime? startDate,
    DateTime? endDate,
    String? registrationStatus,
    int? playerId,
    int? teamId,
    DateTime? paymentDeadline,
    DateTime? slotLockedAt,
    String? playerName,
    String? playerEmail,
    String? accountName,
    String? accountIdentifier,
  }) {
    return CompetitionPaymentModel(
      id: id ?? this.id,
      registrationId:
      registrationId ?? this.registrationId,
      competitionId:
      competitionId ?? this.competitionId,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentMethod:
      paymentMethod ?? this.paymentMethod,
      transactionReference:
      transactionReference ??
          this.transactionReference,
      proofImageUrl:
      proofImageUrl ?? this.proofImageUrl,
      submittedAt:
      submittedAt ?? this.submittedAt,
      paidAt:
      paidAt ?? this.paidAt,
      verifiedAt:
      verifiedAt ?? this.verifiedAt,
      verifiedBy:
      verifiedBy ?? this.verifiedBy,
      rejectedAt:
      rejectedAt ?? this.rejectedAt,
      rejectionReason:
      rejectionReason ?? this.rejectionReason,
      createdAt:
      createdAt ?? this.createdAt,
      updatedAt:
      updatedAt ?? this.updatedAt,
      competitionName:
      competitionName ?? this.competitionName,
      entryFee:
      entryFee ?? this.entryFee,
      startDate:
      startDate ?? this.startDate,
      endDate:
      endDate ?? this.endDate,
      registrationStatus:
      registrationStatus ??
          this.registrationStatus,
      playerId:
      playerId ?? this.playerId,
      teamId:
      teamId ?? this.teamId,
      paymentDeadline:
      paymentDeadline ??
          this.paymentDeadline,
      slotLockedAt:
      slotLockedAt ?? this.slotLockedAt,
      playerName:
      playerName ?? this.playerName,
      playerEmail:
      playerEmail ?? this.playerEmail,
      accountName:
      accountName ?? this.accountName,
      accountIdentifier:
      accountIdentifier ??
          this.accountIdentifier,
    );
  }
}