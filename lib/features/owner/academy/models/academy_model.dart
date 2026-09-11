class AcademyModel {
  final String id;
  final String name;
  final String? phoneNumber;
  final String? description;
  final String? address;
  final String? cityId;
  final String? imageUrl;
  final String? createdBy;
  final String? ownerId;
  final String? pitchId;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? pitchName;
  final String? pitchStatus;

  const AcademyModel({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.description,
    this.address,
    this.cityId,
    this.imageUrl,
    this.createdBy,
    this.ownerId,
    this.pitchId,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.pitchName,
    this.pitchStatus,
  });

  factory AcademyModel.fromJson(Map<String, dynamic> json) {
    return AcademyModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phoneNumber: json['phone_number']?.toString(),
      description: json['description']?.toString(),
      address: json['address']?.toString(),
      cityId: json['city_id']?.toString(),
      imageUrl: json['image_url']?.toString(),
      createdBy: json['created_by']?.toString(),
      ownerId: json['owner_id']?.toString(),
      pitchId: json['pitch_id']?.toString(),
      status: json['status']?.toString() ?? '',
      createdAt: _parseDate(json['created_at']),
      updatedAt: _parseDate(json['updated_at']),
      pitchName: json['pitch_name']?.toString(),
      pitchStatus: json['pitch_status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone_number': phoneNumber,
      'description': description,
      'address': address,
      'city_id': cityId,
      'image_url': imageUrl,
      'created_by': createdBy,
      'owner_id': ownerId,
      'pitch_id': pitchId,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'pitch_name': pitchName,
      'pitch_status': pitchStatus,
    };
  }

  AcademyModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? description,
    String? address,
    String? cityId,
    String? imageUrl,
    String? createdBy,
    String? ownerId,
    String? pitchId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? pitchName,
    String? pitchStatus,
  }) {
    return AcademyModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      description: description ?? this.description,
      address: address ?? this.address,
      cityId: cityId ?? this.cityId,
      imageUrl: imageUrl ?? this.imageUrl,
      createdBy: createdBy ?? this.createdBy,
      ownerId: ownerId ?? this.ownerId,
      pitchId: pitchId ?? this.pitchId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      pitchName: pitchName ?? this.pitchName,
      pitchStatus: pitchStatus ?? this.pitchStatus,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;

    final stringValue = value.toString().trim();

    if (stringValue.isEmpty) return null;

    return DateTime.tryParse(stringValue);
  }
}