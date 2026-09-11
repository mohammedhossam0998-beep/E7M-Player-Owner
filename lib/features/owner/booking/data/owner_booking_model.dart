class OwnerBookingModel {
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
  final String? depositPaidAt;

  final String? notes;
  final String bookedAt;
  final String updatedAt;
  final String? cancelledAt;

  // Player
  final String? playerName;
  final String? playerEmail;

  // Slot
  final String? slotDate;
  final String? startTime;
  final String? endTime;
  final double? slotPrice;

  // Pitch
  final int? pitchId;
  final String? pitchName;
  final String? pitchAddress;

  OwnerBookingModel({
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
    this.depositPaidAt,
    this.notes,
    required this.bookedAt,
    required this.updatedAt,
    this.cancelledAt,
    this.playerName,
    this.playerEmail,
    this.slotDate,
    this.startTime,
    this.endTime,
    this.slotPrice,
    this.pitchId,
    this.pitchName,
    this.pitchAddress,
  });

  factory OwnerBookingModel.fromJson(Map<String, dynamic> json) {
    return OwnerBookingModel(
      id: _toInt(json['id']) ?? 0,
      playerId: _toInt(json['player_id']) ?? 0,
      pitchSlotId: _toInt(json['pitch_slot_id']) ?? 0,
      coachId: _toInt(json['coach_id']),

      status: json['status']?.toString() ?? '',

      totalPrice: _toDouble(json['total_price']) ?? 0,
      depositAmount: _toDouble(json['deposit_amount']) ?? 0,
      remainingAmount: _toDouble(json['remaining_amount']) ?? 0,

      paymentMethod: json['payment_method']?.toString(),
      paymentStatus: json['payment_status']?.toString(),
      depositPaidAt: json['deposit_paid_at']?.toString(),

      notes: json['notes']?.toString(),

      bookedAt: json['booked_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      cancelledAt: json['cancelled_at']?.toString(),

      // Player
      playerName: json['player_name']?.toString(),
      playerEmail: json['player_email']?.toString(),

      // Slot
      slotDate: json['slot_date']?.toString(),
      startTime: json['start_time']?.toString(),
      endTime: json['end_time']?.toString(),
      slotPrice: _toDouble(json['slot_price']),

      // Pitch
      pitchId: _toInt(json['pitch_id']),
      pitchName: json['pitch_name']?.toString(),
      pitchAddress: json['pitch_address']?.toString(),
    );
  }

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
      'deposit_paid_at': depositPaidAt,
      'notes': notes,
      'booked_at': bookedAt,
      'updated_at': updatedAt,
      'cancelled_at': cancelledAt,

      'player_name': playerName,
      'player_email': playerEmail,

      'slot_date': slotDate,
      'start_time': startTime,
      'end_time': endTime,
      'slot_price': slotPrice,

      'pitch_id': pitchId,
      'pitch_name': pitchName,
      'pitch_address': pitchAddress,
    };
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}