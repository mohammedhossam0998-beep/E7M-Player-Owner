class StadiumImage {
  final String id;
  final String pitchId;
  final String imageUrl;
  final bool isPrimary;
  final DateTime? createdAt;

  const StadiumImage({
    required this.id,
    required this.pitchId,
    required this.imageUrl,
    required this.isPrimary,
    this.createdAt,
  });

  factory StadiumImage.fromJson(Map<String, dynamic> json) {
    return StadiumImage(
      id: json['id']?.toString() ?? '',
      pitchId: json['pitch_id']?.toString() ?? '',
      imageUrl: json['image_url']?.toString() ?? '',
      isPrimary: json['is_primary'] == true,
      createdAt: _parseDateTime(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pitch_id': pitchId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}