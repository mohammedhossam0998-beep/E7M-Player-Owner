class StadiumImageModel {
  final int id;
  final int pitchId;
  final String imageUrl;
  final bool isPrimary;
  final DateTime? createdAt;

  const StadiumImageModel({
    required this.id,
    required this.pitchId,
    required this.imageUrl,
    required this.isPrimary,
    this.createdAt,
  });

  factory StadiumImageModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return StadiumImageModel(
      id: _parseInt(json['id']),
      pitchId: _parseInt(json['pitch_id']),
      imageUrl: json['image_url']?.toString() ?? '',
      isPrimary:
      json['is_primary'] == true,
      createdAt:
      _parseDate(json['created_at']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value is int) {
      return value;
    }

    return int.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    return DateTime.tryParse(
      value.toString(),
    );
  }
}