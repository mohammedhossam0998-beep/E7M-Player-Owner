class AcademyCoachModel {
  final int assignmentId;
  final int academyId;
  final int coachId;

  final String role;
  final DateTime? assignedAt;

  final int userId;

  final int? experienceYears;
  final double? hourlyRate;

  final String? bio;
  final bool? isPrivate;
  final bool isApproved;

  final String? gender;
  final String? coachType;
  final String? city;
  final String? address;

  final double rating;
  final int reviewsCount;
  final int playersCount;
  final int certificatesCount;

  final bool isBlocked;
  final bool isFeatured;

  final String? coverUrl;

  final String? fullName;
  final String? email;
  final String? phone;
  final String? profileImage;

  const AcademyCoachModel({
    required this.assignmentId,
    required this.academyId,
    required this.coachId,
    required this.role,
    this.assignedAt,
    required this.userId,
    this.experienceYears,
    this.hourlyRate,
    this.bio,
    this.isPrivate,
    required this.isApproved,
    this.gender,
    this.coachType,
    this.city,
    this.address,
    required this.rating,
    required this.reviewsCount,
    required this.playersCount,
    required this.certificatesCount,
    required this.isBlocked,
    required this.isFeatured,
    this.coverUrl,
    this.fullName,
    this.email,
    this.phone,
    this.profileImage,
  });

  // ============================================================
  // FROM JSON
  // ============================================================

  factory AcademyCoachModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return AcademyCoachModel(
      // Owner Academy API
      assignmentId: _toInt(
        json['assignment_id'] ?? json['id'],
      ),

      academyId: _toInt(
        json['academy_id'],
      ),

      coachId: _toInt(
        json['coach_id'],
      ),

      role: json['role']?.toString() ?? '',

      assignedAt: _toDateTime(
        json['assigned_at'],
      ),

      userId: _toInt(
        json['user_id'],
      ),

      experienceYears: _toNullableInt(
        json['experience_years'],
      ),

      hourlyRate: _toDouble(
        json['hourly_rate'],
      ),

      bio: json['bio']?.toString(),

      isPrivate: _toNullableBool(
        json['is_private'],
      ),

      isApproved: _toBool(
        json['is_approved'],
      ),

      gender: json['gender']?.toString(),

      coachType: json['coach_type']?.toString(),

      city: json['city']?.toString(),

      address: json['address']?.toString(),

      rating:
      _toDouble(json['rating']) ?? 0,

      reviewsCount: _toInt(
        json['reviews_count'],
      ),

      playersCount: _toInt(
        json['players_count'],
      ),

      certificatesCount: _toInt(
        json['certificates_count'],
      ),

      isBlocked: _toBool(
        json['is_blocked'],
      ),

      isFeatured: _toBool(
        json['is_featured'],
      ),

      coverUrl: json['cover_url']?.toString(),

      // ========================================================
      // IMPORTANT
      // GET OWNER COACHES RETURNS:
      // coach_name / coach_email / coach_phone
      // ========================================================

      fullName:
      json['full_name']?.toString() ??
          json['coach_name']?.toString(),

      email:
      json['email']?.toString() ??
          json['coach_email']?.toString(),

      phone:
      json['phone']?.toString() ??
          json['coach_phone']?.toString(),

      profileImage:
      json['profile_image']?.toString() ??
          json['photo_url']?.toString() ??
          json['coach_profile_image']?.toString(),
    );
  }

  // ============================================================
  // TO JSON
  // ============================================================

  Map<String, dynamic> toJson() {
    return {
      'assignment_id': assignmentId,
      'id': assignmentId,
      'academy_id': academyId,
      'coach_id': coachId,
      'role': role,
      'assigned_at':
      assignedAt?.toIso8601String(),

      'user_id': userId,

      'experience_years':
      experienceYears,

      'hourly_rate':
      hourlyRate,

      'bio': bio,
      'is_private': isPrivate,
      'is_approved': isApproved,

      'gender': gender,
      'coach_type': coachType,
      'city': city,
      'address': address,

      'rating': rating,
      'reviews_count': reviewsCount,
      'players_count': playersCount,
      'certificates_count':
      certificatesCount,

      'is_blocked': isBlocked,
      'is_featured': isFeatured,

      'cover_url': coverUrl,

      'full_name': fullName,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  AcademyCoachModel copyWith({
    int? assignmentId,
    int? academyId,
    int? coachId,
    String? role,
    DateTime? assignedAt,
    int? userId,
    int? experienceYears,
    double? hourlyRate,
    String? bio,
    bool? isPrivate,
    bool? isApproved,
    String? gender,
    String? coachType,
    String? city,
    String? address,
    double? rating,
    int? reviewsCount,
    int? playersCount,
    int? certificatesCount,
    bool? isBlocked,
    bool? isFeatured,
    String? coverUrl,
    String? fullName,
    String? email,
    String? phone,
    String? profileImage,
  }) {
    return AcademyCoachModel(
      assignmentId:
      assignmentId ??
          this.assignmentId,

      academyId:
      academyId ??
          this.academyId,

      coachId:
      coachId ??
          this.coachId,

      role:
      role ?? this.role,

      assignedAt:
      assignedAt ??
          this.assignedAt,

      userId:
      userId ??
          this.userId,

      experienceYears:
      experienceYears ??
          this.experienceYears,

      hourlyRate:
      hourlyRate ??
          this.hourlyRate,

      bio:
      bio ?? this.bio,

      isPrivate:
      isPrivate ??
          this.isPrivate,

      isApproved:
      isApproved ??
          this.isApproved,

      gender:
      gender ?? this.gender,

      coachType:
      coachType ??
          this.coachType,

      city:
      city ?? this.city,

      address:
      address ?? this.address,

      rating:
      rating ?? this.rating,

      reviewsCount:
      reviewsCount ??
          this.reviewsCount,

      playersCount:
      playersCount ??
          this.playersCount,

      certificatesCount:
      certificatesCount ??
          this.certificatesCount,

      isBlocked:
      isBlocked ??
          this.isBlocked,

      isFeatured:
      isFeatured ??
          this.isFeatured,

      coverUrl:
      coverUrl ??
          this.coverUrl,

      fullName:
      fullName ??
          this.fullName,

      email:
      email ?? this.email,

      phone:
      phone ?? this.phone,

      profileImage:
      profileImage ??
          this.profileImage,
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

  static double? _toDouble(
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

  static bool _toBool(
      dynamic value,
      ) {
    if (value is bool) {
      return value;
    }

    return value
        ?.toString()
        .toLowerCase() ==
        'true';
  }

  static bool? _toNullableBool(
      dynamic value,
      ) {
    if (value == null) {
      return null;
    }

    if (value is bool) {
      return value;
    }

    final normalized =
    value.toString().toLowerCase();

    if (normalized == 'true') {
      return true;
    }

    if (normalized == 'false') {
      return false;
    }

    return null;
  }

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