class Stadium {
  final String id;
  final String ownerId;
  final String? cityId;
  final String? cityName;

  final String name;
  final String? description;
  final String? address;

  final double? latitude;
  final double? longitude;

  final String? pitchType;
  final int? capacity;

  final double basePrice;
  final double depositAmount;

  final String status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  final String? primaryImage;

  const Stadium({
    required this.id,
    required this.ownerId,
    this.cityId,
    this.cityName,
    required this.name,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    this.pitchType,
    this.capacity,
    required this.basePrice,
    required this.depositAmount,
    required this.status,
    this.createdAt,
    this.updatedAt,
    this.primaryImage,
  });

  factory Stadium.fromJson(Map<String, dynamic> json) {
    return Stadium(
      id: json['id']?.toString() ?? '',
      ownerId: json['owner_id']?.toString() ?? '',
      cityId: json['city_id']?.toString(),
      cityName: json['city_name']?.toString(),

      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      address: json['address']?.toString(),

      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),

      pitchType: json['pitch_type']?.toString(),
      capacity: _parseInt(json['capacity']),

      basePrice: _parseDouble(json['base_price']) ?? 0.0,
      depositAmount: _parseDouble(json['deposit_amount']) ?? 0.0,

      status: json['status']?.toString() ?? '',

      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),

      primaryImage: json['primary_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'city_id': cityId,
      'city_name': cityName,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'pitch_type': pitchType,
      'capacity': capacity,
      'base_price': basePrice,
      'deposit_amount': depositAmount,
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'primary_image': primaryImage,
    };
  }

  Stadium copyWith({
    String? id,
    String? ownerId,
    String? cityId,
    String? cityName,
    String? name,
    String? description,
    String? address,
    double? latitude,
    double? longitude,
    String? pitchType,
    int? capacity,
    double? basePrice,
    double? depositAmount,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? primaryImage,
  }) {
    return Stadium(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      cityId: cityId ?? this.cityId,
      cityName: cityName ?? this.cityName,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pitchType: pitchType ?? this.pitchType,
      capacity: capacity ?? this.capacity,
      basePrice: basePrice ?? this.basePrice,
      depositAmount: depositAmount ?? this.depositAmount,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      primaryImage: primaryImage ?? this.primaryImage,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;

    if (value is int) {
      return value;
    }

    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value.toString());
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}