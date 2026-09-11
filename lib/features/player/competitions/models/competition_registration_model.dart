class CompetitionRegistrationModel {
  final int id;
  final int competitionId;
  final int playerId;

  final String status;

  final DateTime? paymentDeadline;
  final DateTime? slotLockedAt;

  final DateTime? registeredAt;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;

  final String? rejectionReason;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CompetitionRegistrationModel({
    required this.id,
    required this.competitionId,
    required this.playerId,
    required this.status,
    this.paymentDeadline,
    this.slotLockedAt,
    this.registeredAt,
    this.approvedAt,
    this.rejectedAt,
    this.rejectionReason,
    this.createdAt,
    this.updatedAt,
  });

  factory CompetitionRegistrationModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionRegistrationModel(
      id: _parseInt(json['id']),
      competitionId: _parseInt(
        json['competition_id'] ?? json['competitionId'],
      ),
      playerId: _parseInt(
        json['player_id'] ?? json['playerId'],
      ),
      status: (json['status'] ?? '').toString(),
      paymentDeadline: _parseDateTime(
        json['payment_deadline'] ?? json['paymentDeadline'],
      ),
      slotLockedAt: _parseDateTime(
        json['slot_locked_at'] ?? json['slotLockedAt'],
      ),
      registeredAt: _parseDateTime(
        json['registered_at'] ?? json['registeredAt'],
      ),
      approvedAt: _parseDateTime(
        json['approved_at'] ?? json['approvedAt'],
      ),
      rejectedAt: _parseDateTime(
        json['rejected_at'] ?? json['rejectedAt'],
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
      'competition_id': competitionId,
      'player_id': playerId,
      'status': status,
      'payment_deadline':
      paymentDeadline?.toIso8601String(),
      'slot_locked_at':
      slotLockedAt?.toIso8601String(),
      'registered_at':
      registeredAt?.toIso8601String(),
      'approved_at':
      approvedAt?.toIso8601String(),
      'rejected_at':
      rejectedAt?.toIso8601String(),
      'rejection_reason': rejectionReason,
      'created_at':
      createdAt?.toIso8601String(),
      'updated_at':
      updatedAt?.toIso8601String(),
    };
  }

  CompetitionRegistrationModel copyWith({
    int? id,
    int? competitionId,
    int? playerId,
    String? status,
    DateTime? paymentDeadline,
    DateTime? slotLockedAt,
    DateTime? registeredAt,
    DateTime? approvedAt,
    DateTime? rejectedAt,
    String? rejectionReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompetitionRegistrationModel(
      id: id ?? this.id,
      competitionId: competitionId ?? this.competitionId,
      playerId: playerId ?? this.playerId,
      status: status ?? this.status,
      paymentDeadline:
      paymentDeadline ?? this.paymentDeadline,
      slotLockedAt:
      slotLockedAt ?? this.slotLockedAt,
      registeredAt:
      registeredAt ?? this.registeredAt,
      approvedAt:
      approvedAt ?? this.approvedAt,
      rejectedAt:
      rejectedAt ?? this.rejectedAt,
      rejectionReason:
      rejectionReason ?? this.rejectionReason,
      createdAt:
      createdAt ?? this.createdAt,
      updatedAt:
      updatedAt ?? this.updatedAt,
    );
  }

  bool get isPending => status == 'pending';

  bool get isApproved => status == 'approved';

  bool get isPaymentPending =>
      status == 'payment_pending';

  bool get isPaid => status == 'paid';

  bool get isRejected => status == 'rejected';

  bool get isWaitlisted => status == 'waitlisted';

  bool get isCancelled => status == 'cancelled';

  bool get isExpired => status == 'expired';

  bool get isCompleted => status == 'completed';

  bool get isDisqualified =>
      status == 'disqualified';

  bool get isSlotLocked =>
      slotLockedAt != null;

  bool get hasPaymentDeadline =>
      paymentDeadline != null;

  bool get paymentDeadlinePassed {
    if (paymentDeadline == null) {
      return false;
    }

    return DateTime.now().isAfter(paymentDeadline!);
  }

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