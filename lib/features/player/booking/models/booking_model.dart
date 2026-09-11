class BookingModel {
  final int id;
  final int playerId;
  final int pitchSlotId;
  final int? coachId;

  final String status;

  final double totalPrice;
  final double depositAmount;
  final double remainingAmount;

  final String? paymentMethod;
  final String? paymentStatus;

  final String? notes;

  final DateTime? depositPaidAt;
  final DateTime? bookedAt;
  final DateTime? updatedAt;
  final DateTime? cancelledAt;

  // Slot data
  final DateTime? slotDate;
  final String? startTime;
  final String? endTime;
  final double? slotPrice;

  // Pitch data
  final int? pitchId;
  final String? pitchName;
  final String? pitchAddress;

  const BookingModel({
    required this.id,
    required this.playerId,
    required this.pitchSlotId,
    this.coachId,
    required this.status,
    required this.totalPrice,
    required this.depositAmount,
    required this.remainingAmount,
    this.paymentMethod,
    this.paymentStatus,
    this.notes,
    this.depositPaidAt,
    this.bookedAt,
    this.updatedAt,
    this.cancelledAt,
    this.slotDate,
    this.startTime,
    this.endTime,
    this.slotPrice,
    this.pitchId,
    this.pitchName,
    this.pitchAddress,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: _toInt(json['id']) ?? 0,
      playerId: _toInt(json['player_id']) ?? 0,
      pitchSlotId: _toInt(json['pitch_slot_id']) ?? 0,
      coachId: _toInt(json['coach_id']),

      status: json['status']?.toString() ?? 'pending',

      totalPrice: _toDouble(json['total_price']) ?? 0.0,

      depositAmount: _toDouble(json['deposit_amount']) ?? 0.0,

      remainingAmount: _toDouble(json['remaining_amount']) ?? 0.0,

      paymentMethod: json['payment_method']?.toString(),

      paymentStatus: json['payment_status']?.toString(),

      notes: json['notes']?.toString(),

      depositPaidAt: _toDateTime(json['deposit_paid_at']),

      bookedAt: _toDateTime(json['booked_at']),

      updatedAt: _toDateTime(json['updated_at']),

      cancelledAt: _toDateTime(json['cancelled_at']),

      // Slot
      slotDate: _toDateTime(json['slot_date']),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      slotPrice: _toDouble(json['price']),

      // Pitch
      pitchId: _toInt(json['pitch_id']),
      pitchName: json['pitch_name']?.toString(),
      pitchAddress: json['pitch_address']?.toString(),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_id': playerId,
      'pitch_slot_id': pitchSlotId,
      'coach_id': coachId,
      'status': status,
      'total_price': totalPrice,
      'deposit_amount': depositAmount,
      'remaining_amount': remainingAmount,
      'payment_method': paymentMethod,
      'payment_status': paymentStatus,
      'notes': notes,
      'deposit_paid_at': depositPaidAt?.toIso8601String(),
      'booked_at': bookedAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),

      // Slot
      'slot_date': slotDate?.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'price': slotPrice,

      // Pitch
      'pitch_id': pitchId,
      'pitch_name': pitchName,
      'pitch_address': pitchAddress,
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  BookingModel copyWith({
    int? id,
    int? playerId,
    int? pitchSlotId,
    int? coachId,
    String? status,
    double? totalPrice,
    double? depositAmount,
    double? remainingAmount,
    String? paymentMethod,
    String? paymentStatus,
    String? notes,
    DateTime? depositPaidAt,
    DateTime? bookedAt,
    DateTime? updatedAt,
    DateTime? cancelledAt,
    DateTime? slotDate,
    String? startTime,
    String? endTime,
    double? slotPrice,
    int? pitchId,
    String? pitchName,
    String? pitchAddress,
  }) {
    return BookingModel(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      pitchSlotId: pitchSlotId ?? this.pitchSlotId,
      coachId: coachId ?? this.coachId,
      status: status ?? this.status,
      totalPrice: totalPrice ?? this.totalPrice,
      depositAmount: depositAmount ?? this.depositAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      notes: notes ?? this.notes,
      depositPaidAt: depositPaidAt ?? this.depositPaidAt,
      bookedAt: bookedAt ?? this.bookedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      slotDate: slotDate ?? this.slotDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      slotPrice: slotPrice ?? this.slotPrice,
      pitchId: pitchId ?? this.pitchId,
      pitchName: pitchName ?? this.pitchName,
      pitchAddress: pitchAddress ?? this.pitchAddress,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) return value;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    return DateTime.tryParse(value.toString());
  }
}