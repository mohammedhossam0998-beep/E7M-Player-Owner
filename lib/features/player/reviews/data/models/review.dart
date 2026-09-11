class Review {
  final String id;
  final String playerId;
  final String pitchId;
  final String bookingId;
  final int rating;
  final String? comment;
  final DateTime? createdAt;
  final String playerName;

  const Review({
    required this.id,
    required this.playerId,
    required this.pitchId,
    required this.bookingId,
    required this.rating,
    this.comment,
    this.createdAt,
    required this.playerName,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id']?.toString() ?? '',
      playerId: json['player_id']?.toString() ?? '',
      pitchId: json['pitch_id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      rating: _parseInt(json['rating']),
      comment: json['comment']?.toString(),
      createdAt: _parseDateTime(json['created_at']),
      playerName: json['player_name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_id': playerId,
      'pitch_id': pitchId,
      'booking_id': bookingId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt?.toIso8601String(),
      'player_name': playerName,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;

    return DateTime.tryParse(value.toString());
  }
}