class StadiumModel {
  final int id;
  final int ownerId;
  final int cityId;

  final String name;
  final String? description;
  final String? address;

  final double? latitude;
  final double? longitude;

  final String pitchType;
  final int capacity;
  final double basePrice;
  final double depositAmount;

  final String status;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const StadiumModel({
    required this.id,
    required this.ownerId,
    required this.cityId,
    required this.name,
    this.description,
    this.address,
    this.latitude,
    this.longitude,
    required this.pitchType,
    required this.capacity,
    required this.basePrice,
    required this.depositAmount,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory StadiumModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StadiumModel(
      id: _toInt(json['id']),
      ownerId: _toInt(json['owner_id']),
      cityId: _toInt(json['city_id']),
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      address: json['address']?.toString(),
      latitude: _toDouble(json['latitude']),
      longitude: _toDouble(json['longitude']),
      pitchType:
      json['pitch_type']?.toString() ?? '',
      capacity: _toInt(json['capacity']),
      basePrice:
      _toDouble(json['base_price']) ?? 0,
      depositAmount:
      _toDouble(json['deposit_amount']) ?? 0,
      status:
      json['status']?.toString() ?? '',
      createdAt:
      _toDateTime(json['created_at']),
      updatedAt:
      _toDateTime(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'city_id': cityId,
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
      'created_at':
      createdAt?.toIso8601String(),
      'updated_at':
      updatedAt?.toIso8601String(),
    };
  }

  // ============================================================
  // CREATE / UPDATE PAYLOAD
  // ============================================================

  Map<String, dynamic> toCreateJson() {
    return {
      'city_id': cityId,
      'name': name,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'pitch_type': pitchType,
      'capacity': capacity,
      'base_price': basePrice,
      'deposit_amount': depositAmount,
    };
  }

  StadiumModel copyWith({
    int? id,
    int? ownerId,
    int? cityId,
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
  }) {
    return StadiumModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      cityId: cityId ?? this.cityId,
      name: name ?? this.name,
      description: description ?? this.description,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      pitchType: pitchType ?? this.pitchType,
      capacity: capacity ?? this.capacity,
      basePrice:
      basePrice ?? this.basePrice,
      depositAmount:
      depositAmount ?? this.depositAmount,
      status: status ?? this.status,
      createdAt:
      createdAt ?? this.createdAt,
      updatedAt:
      updatedAt ?? this.updatedAt,
    );
  }

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

  static double? _toDouble(dynamic value) {
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