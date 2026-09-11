class SlotModel {
  final int id;
  final int pitchId;
  final String slotDate;
  final String startTime;
  final String endTime;
  final double price;
  final String status;
  final DateTime? createdAt;

  const SlotModel({
    required this.id,
    required this.pitchId,
    required this.slotDate,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.status,
    this.createdAt,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: _toInt(json['id']),
      pitchId: _toInt(json['pitch_id']),
      slotDate: json['slot_date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      price: _toDouble(json['price']),
      status: json['status']?.toString() ?? '',
      createdAt: _toDateTime(json['created_at']),
    );
  }

  // ============================================================
  // CREATE JSON
  // ============================================================

  Map<String, dynamic> toCreateJson() {
    return {
      'slot_date': slotDate,
      'start_time': startTime,
      'end_time': endTime,
      'price': price,
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  SlotModel copyWith({
    int? id,
    int? pitchId,
    String? slotDate,
    String? startTime,
    String? endTime,
    double? price,
    String? status,
    DateTime? createdAt,
  }) {
    return SlotModel(
      id: id ?? this.id,
      pitchId: pitchId ?? this.pitchId,
      slotDate: slotDate ?? this.slotDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      price: price ?? this.price,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  static int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
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

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }

  // ============================================================
  // TO STRING
  // ============================================================

  @override
  String toString() {
    return 'SlotModel('
        'id: $id, '
        'pitchId: $pitchId, '
        'slotDate: $slotDate, '
        'startTime: $startTime, '
        'endTime: $endTime, '
        'price: $price, '
        'status: $status, '
        'createdAt: $createdAt'
        ')';
  }
}