class OwnerProfileModel {
  final int userId;
  final String? fullName;
  final String? email;
  final String? phone;
  final String? profileImage;
  final String? role;
  final bool? isActive;
  final bool? isVerified;
  final String? approvalStatus;

  final int ownerId;
  final String? businessName;
  final String? businessPhone;
  final String? businessEmail;
  final String? ownerCreatedAt;

  const OwnerProfileModel({
    required this.userId,
    this.fullName,
    this.email,
    this.phone,
    this.profileImage,
    this.role,
    this.isActive,
    this.isVerified,
    this.approvalStatus,
    required this.ownerId,
    this.businessName,
    this.businessPhone,
    this.businessEmail,
    this.ownerCreatedAt,
  });

  factory OwnerProfileModel.fromJson(Map<String, dynamic> json) {
    return OwnerProfileModel(
      userId: _toInt(json['user_id']),
      fullName: json['full_name']?.toString(),
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      profileImage: json['profile_image']?.toString(),
      role: json['role']?.toString(),
      isActive: _toBool(json['is_active']),
      isVerified: _toBool(json['is_verified']),
      approvalStatus: json['approval_status']?.toString(),

      ownerId: _toInt(json['owner_id']),
      businessName: json['business_name']?.toString(),
      businessPhone: json['business_phone']?.toString(),
      businessEmail: json['business_email']?.toString(),
      ownerCreatedAt: json['owner_created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'profile_image': profileImage,
      'role': role,
      'is_active': isActive,
      'is_verified': isVerified,
      'approval_status': approvalStatus,
      'owner_id': ownerId,
      'business_name': businessName,
      'business_phone': businessPhone,
      'business_email': businessEmail,
      'owner_created_at': ownerCreatedAt,
    };
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool? _toBool(dynamic value) {
    if (value is bool) return value;

    if (value is String) {
      if (value.toLowerCase() == 'true') return true;
      if (value.toLowerCase() == 'false') return false;
    }

    return null;
  }
}