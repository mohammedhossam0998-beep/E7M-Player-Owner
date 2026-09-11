class OwnerReviewModel {
  final String id;
  final String playerId;
  final String pitchId;
  final String bookingId;
  final int rating;
  final String? comment;
  final DateTime createdAt;
  final bool isHidden;

  final String? playerName;
  final String? playerEmail;
  final String? playerProfileImage;
  final String? pitchName;

  OwnerReviewModel({
    required this.id,
    required this.playerId,
    required this.pitchId,
    required this.bookingId,
    required this.rating,
    this.comment,
    required this.createdAt,
    required this.isHidden,
    this.playerName,
    this.playerEmail,
    this.playerProfileImage,
    this.pitchName,
  });

  factory OwnerReviewModel.fromJson(Map<String, dynamic> json) {
    return OwnerReviewModel(
      id: json['id']?.toString() ?? '',
      playerId: json['player_id']?.toString() ?? '',
      pitchId: json['pitch_id']?.toString() ?? '',
      bookingId: json['booking_id']?.toString() ?? '',
      rating: int.tryParse(json['rating']?.toString() ?? '') ?? 0,
      comment: json['comment']?.toString(),
      createdAt:
      DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      isHidden: json['is_hidden'] == true,
      playerName: json['player_name']?.toString(),
      playerEmail: json['player_email']?.toString(),
      playerProfileImage: json['player_profile_image']?.toString(),
      pitchName: json['pitch_name']?.toString(),
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
      'created_at': createdAt.toIso8601String(),
      'is_hidden': isHidden,
      'player_name': playerName,
      'player_email': playerEmail,
      'player_profile_image': playerProfileImage,
      'pitch_name': pitchName,
    };
  }

  OwnerReviewModel copyWith({
    String? id,
    String? playerId,
    String? pitchId,
    String? bookingId,
    int? rating,
    String? comment,
    DateTime? createdAt,
    bool? isHidden,
    String? playerName,
    String? playerEmail,
    String? playerProfileImage,
    String? pitchName,
  }) {
    return OwnerReviewModel(
      id: id ?? this.id,
      playerId: playerId ?? this.playerId,
      pitchId: pitchId ?? this.pitchId,
      bookingId: bookingId ?? this.bookingId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      isHidden: isHidden ?? this.isHidden,
      playerName: playerName ?? this.playerName,
      playerEmail: playerEmail ?? this.playerEmail,
      playerProfileImage:
      playerProfileImage ?? this.playerProfileImage,
      pitchName: pitchName ?? this.pitchName,
    );
  }
}