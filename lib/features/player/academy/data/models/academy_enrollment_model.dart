class AcademyEnrollmentModel {
  final int id;
  final int academyId;
  final int programId;
  final int playerId;
  final String status;
  final DateTime enrolledAt;
  final DateTime updatedAt;

  final String? academyName;
  final String? programName;
  final String? programLevel;
  final double? programPrice;
  final int? programDurationWeeks;

  const AcademyEnrollmentModel({
    required this.id,
    required this.academyId,
    required this.programId,
    required this.playerId,
    required this.status,
    required this.enrolledAt,
    required this.updatedAt,
    this.academyName,
    this.programName,
    this.programLevel,
    this.programPrice,
    this.programDurationWeeks,
  });

  factory AcademyEnrollmentModel.fromJson(
      Map<String, dynamic> json,
      ) {
    final enrolledAtValue = json['enrolled_at'];

    final enrolledAt = enrolledAtValue != null
        ? DateTime.parse(enrolledAtValue.toString())
        : DateTime.now();

    final updatedAtValue = json['updated_at'];

    final updatedAt = updatedAtValue != null
        ? DateTime.parse(updatedAtValue.toString())
        : enrolledAt;

    return AcademyEnrollmentModel(
      id: int.tryParse(
        json['id']?.toString() ?? '',
      ) ??
          0,

      academyId: int.tryParse(
        json['academy_id']?.toString() ?? '',
      ) ??
          0,

      programId: int.tryParse(
        json['program_id']?.toString() ?? '',
      ) ??
          0,

      playerId: int.tryParse(
        json['player_id']?.toString() ?? '',
      ) ??
          0,

      status: json['status']?.toString() ?? 'pending',

      enrolledAt: enrolledAt,

      updatedAt: updatedAt,

      academyName: json['academy_name']?.toString(),

      programName: json['program_name']?.toString(),

      programLevel: json['program_level']?.toString(),

      programPrice: json['program_price'] != null
          ? double.tryParse(
        json['program_price'].toString(),
      )
          : null,

      programDurationWeeks:
      json['program_duration_weeks'] != null
          ? int.tryParse(
        json['program_duration_weeks'].toString(),
      )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'academy_id': academyId,
      'program_id': programId,
      'player_id': playerId,
      'status': status,
      'enrolled_at': enrolledAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'academy_name': academyName,
      'program_name': programName,
      'program_level': programLevel,
      'program_price': programPrice,
      'program_duration_weeks': programDurationWeeks,
    };
  }
}