
class EnrollmentModel {
  final int enrollmentId;
  final int academyId;

  final String? academyName;
  final String? academyStatus;

  final int? programId;
  final String? programName;
  final String? programDescription;
  final String? programLevel;
  final double? programPrice;
  final int? programDurationWeeks;

  final int playerId;
  final String? playerName;
  final String? playerEmail;
  final String? playerPhone;
  final String? profileImage;

  final String status;
  final DateTime? enrolledAt;

  const EnrollmentModel({
    required this.enrollmentId,
    required this.academyId,
    this.academyName,
    this.academyStatus,
    this.programId,
    this.programName,
    this.programDescription,
    this.programLevel,
    this.programPrice,
    this.programDurationWeeks,
    required this.playerId,
    this.playerName,
    this.playerEmail,
    this.playerPhone,
    this.profileImage,
    required this.status,
    this.enrolledAt,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory EnrollmentModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return EnrollmentModel(
      enrollmentId: _toInt(
        json['enrollment_id'] ?? json['id'],
      ),

      academyId: _toInt(
        json['academy_id'],
      ),

      academyName: _toStringOrNull(
        json['academy_name'],
      ),

      academyStatus: _toStringOrNull(
        json['academy_status'],
      ),

      programId: _toNullableInt(
        json['program_id'],
      ),

      programName: _toStringOrNull(
        json['program_name'],
      ),

      programDescription: _toStringOrNull(
        json['program_description'],
      ),

      programLevel: _toStringOrNull(
        json['program_level'],
      ),

      programPrice: _toNullableDouble(
        json['program_price'],
      ),

      programDurationWeeks: _toNullableInt(
        json['program_duration_weeks'] ??
            json['duration_weeks'],
      ),

      playerId: _toInt(
        json['player_id'],
      ),

      // The list API returns full_name,
      // while some API responses use player_name.
      playerName: _toStringOrNull(
        json['player_name'] ??
            json['full_name'],
      ),

      playerEmail: _toStringOrNull(
        json['player_email'] ??
            json['email'],
      ),

      playerPhone: _toStringOrNull(
        json['player_phone'] ??
            json['phone'],
      ),

      profileImage: _toStringOrNull(
        json['profile_image'] ??
            json['player_profile_image'],
      ),

      status:
      json['status']?.toString() ?? 'pending',

      enrolledAt: _toDateTime(
        json['enrolled_at'],
      ),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'enrollment_id': enrollmentId,
      'academy_id': academyId,
      'academy_name': academyName,
      'academy_status': academyStatus,

      'program_id': programId,
      'program_name': programName,
      'program_description': programDescription,
      'program_level': programLevel,
      'program_price': programPrice,
      'program_duration_weeks': programDurationWeeks,

      'player_id': playerId,
      'player_name': playerName,
      'player_email': playerEmail,
      'player_phone': playerPhone,
      'profile_image': profileImage,

      'status': status,
      'enrolled_at':
      enrolledAt?.toIso8601String(),
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  EnrollmentModel copyWith({
    int? enrollmentId,
    int? academyId,
    String? academyName,
    String? academyStatus,
    int? programId,
    String? programName,
    String? programDescription,
    String? programLevel,
    double? programPrice,
    int? programDurationWeeks,
    int? playerId,
    String? playerName,
    String? playerEmail,
    String? playerPhone,
    String? profileImage,
    String? status,
    DateTime? enrolledAt,
  }) {
    return EnrollmentModel(
      enrollmentId:
      enrollmentId ?? this.enrollmentId,

      academyId:
      academyId ?? this.academyId,

      academyName:
      academyName ?? this.academyName,

      academyStatus:
      academyStatus ?? this.academyStatus,

      programId:
      programId ?? this.programId,

      programName:
      programName ?? this.programName,

      programDescription:
      programDescription ??
          this.programDescription,

      programLevel:
      programLevel ?? this.programLevel,

      programPrice:
      programPrice ?? this.programPrice,

      programDurationWeeks:
      programDurationWeeks ??
          this.programDurationWeeks,

      playerId:
      playerId ?? this.playerId,

      playerName:
      playerName ?? this.playerName,

      playerEmail:
      playerEmail ?? this.playerEmail,

      playerPhone:
      playerPhone ?? this.playerPhone,

      profileImage:
      profileImage ?? this.profileImage,

      status:
      status ?? this.status,

      enrolledAt:
      enrolledAt ?? this.enrolledAt,
    );
  }

  // ============================================================
  // HELPER: INTEGER
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

  // ============================================================
  // HELPER: NULLABLE INTEGER
  // ============================================================

  static int? _toNullableInt(dynamic value) {
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

  // ============================================================
  // HELPER: DOUBLE
  // ============================================================

  static double? _toNullableDouble(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is double) {
      return value;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    );
  }

  // ============================================================
  // HELPER: STRING
  // ============================================================

  static String? _toStringOrNull(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();

    if (text.isEmpty) {
      return null;
    }

    return text;
  }

  // ============================================================
  // HELPER: DATETIME
  // ============================================================

  static DateTime? _toDateTime(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }
}
