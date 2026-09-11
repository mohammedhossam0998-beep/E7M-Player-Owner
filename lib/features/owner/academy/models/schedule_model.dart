class ScheduleModel {
  final int id;
  final int academyId;
  final int? programId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String? location;
  final String? createdAt;
  final String? programName;

  const ScheduleModel({
    required this.id,
    required this.academyId,
    this.programId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    this.location,
    this.createdAt,
    this.programName,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory ScheduleModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ScheduleModel(
      id: _toInt(json['id']),
      academyId: _toInt(
        json['academy_id'],
      ),
      programId:
      _toNullableInt(json['program_id']),
      dayOfWeek:
      json['day_of_week']?.toString() ?? '',
      startTime:
      json['start_time']?.toString() ?? '',
      endTime:
      json['end_time']?.toString() ?? '',
      location:
      json['location']?.toString(),
      createdAt:
      json['created_at']?.toString(),
      programName:
      json['program_name']?.toString(),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'academy_id': academyId,
      'program_id': programId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'location': location,
      'created_at': createdAt,
      'program_name': programName,
    };
  }

  // ============================================================
  // CREATE / UPDATE REQUEST
  // ============================================================

  Map<String, dynamic> toRequestJson() {
    return {
      'program_id': programId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'location': location,
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  ScheduleModel copyWith({
    int? id,
    int? academyId,
    int? programId,
    String? dayOfWeek,
    String? startTime,
    String? endTime,
    String? location,
    String? createdAt,
    String? programName,
  }) {
    return ScheduleModel(
      id: id ?? this.id,
      academyId:
      academyId ?? this.academyId,
      programId:
      programId ?? this.programId,
      dayOfWeek:
      dayOfWeek ?? this.dayOfWeek,
      startTime:
      startTime ?? this.startTime,
      endTime:
      endTime ?? this.endTime,
      location:
      location ?? this.location,
      createdAt:
      createdAt ?? this.createdAt,
      programName:
      programName ?? this.programName,
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

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static int? _toNullableInt(
      dynamic value,
      ) {
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
}