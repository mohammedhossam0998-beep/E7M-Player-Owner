class AvailabilitySettingsModel {
  final int pitchId;
  final List<int> weeklyDays;
  final String startTime;
  final String endTime;
  final int slotDuration;
  final double defaultPrice;

  AvailabilitySettingsModel({
    required this.pitchId,
    required this.weeklyDays,
    required this.startTime,
    required this.endTime,
    required this.slotDuration,
    required this.defaultPrice,
  });

  factory AvailabilitySettingsModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AvailabilitySettingsModel(
      pitchId: json['pitch_id'] is int
          ? json['pitch_id']
          : int.parse(json['pitch_id'].toString()),

      weeklyDays: (json['weekly_days'] as List? ?? [])
          .map((day) => int.parse(day.toString()))
          .toList(),

      startTime: json['start_time']?.toString() ?? '12:00:00',

      endTime: json['end_time']?.toString() ?? '00:00:00',

      slotDuration: json['slot_duration'] is int
          ? json['slot_duration']
          : int.parse(
        json['slot_duration'].toString(),
      ),

      defaultPrice: json['default_price'] is num
          ? (json['default_price'] as num).toDouble()
          : double.parse(
        json['default_price'].toString(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weekly_days': weeklyDays,
      'start_time': startTime,
      'end_time': endTime,
      'slot_duration': slotDuration,
      'default_price': defaultPrice,
    };
  }

  AvailabilitySettingsModel copyWith({
    int? pitchId,
    List<int>? weeklyDays,
    String? startTime,
    String? endTime,
    int? slotDuration,
    double? defaultPrice,
  }) {
    return AvailabilitySettingsModel(
      pitchId: pitchId ?? this.pitchId,
      weeklyDays: weeklyDays ?? this.weeklyDays,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      slotDuration: slotDuration ?? this.slotDuration,
      defaultPrice: defaultPrice ?? this.defaultPrice,
    );
  }
}