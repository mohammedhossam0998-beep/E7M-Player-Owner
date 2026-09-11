class ProgramModel {
  final int id;
  final int academyId;
  final String name;
  final String? description;
  final String? level;
  final double? price;
  final int? durationWeeks;

  const ProgramModel({
    required this.id,
    required this.academyId,
    required this.name,
    this.description,
    this.level,
    this.price,
    this.durationWeeks,
  });

  factory ProgramModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return ProgramModel(
      id: _toInt(json['id']),
      academyId: _toInt(json['academy_id']),
      name: json['name']?.toString() ?? '',
      description:
      json['description']?.toString(),
      level:
      json['level']?.toString(),
      price:
      _toDouble(json['price']),
      durationWeeks:
      _toNullableInt(
        json['duration_weeks'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'academy_id': academyId,
      'name': name,
      'description': description,
      'level': level,
      'price': price,
      'duration_weeks': durationWeeks,
    };
  }

  // ============================================================
  // CREATE / UPDATE PAYLOAD
  // ============================================================

  Map<String, dynamic> toRequestJson() {
    return {
      'name': name,
      'description': description,
      'level': level,
      'price': price,
      'duration_weeks': durationWeeks,
    };
  }

  ProgramModel copyWith({
    int? id,
    int? academyId,
    String? name,
    String? description,
    String? level,
    double? price,
    int? durationWeeks,
  }) {
    return ProgramModel(
      id: id ?? this.id,
      academyId: academyId ?? this.academyId,
      name: name ?? this.name,
      description:
      description ?? this.description,
      level: level ?? this.level,
      price: price ?? this.price,
      durationWeeks:
      durationWeeks ?? this.durationWeeks,
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
}