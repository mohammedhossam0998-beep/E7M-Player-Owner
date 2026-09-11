class StadiumSlot {
  final String id;
  final String pitchId;

  final DateTime? slotDate;

  final String startTime;
  final String endTime;

  final double price;
  final String status;

  final DateTime? createdAt;

  const StadiumSlot({
    required this.id,
    required this.pitchId,
    this.slotDate,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.status,
    this.createdAt,
  });

  factory StadiumSlot.fromJson(Map<String, dynamic> json) {
    return StadiumSlot(
      id: json['id']?.toString() ?? '',
      pitchId: json['pitch_id']?.toString() ?? '',
      slotDate: _parseDateTime(json['slot_date']),
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      price: _parseDouble(json['price']) ?? 0.0,
      status: json['status']?.toString() ?? '',
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pitch_id': pitchId,
      'slot_date': slotDate?.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'price': price,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  bool get isAvailable => status.toLowerCase() == 'available';

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}