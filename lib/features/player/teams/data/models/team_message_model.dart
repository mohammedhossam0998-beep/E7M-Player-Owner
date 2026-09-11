class TeamMessageModel {
  final int id;
  final int teamId;
  final int senderId;
  final String message;
  final DateTime? createdAt;
  final String? fullName;
  final String? profileImage;

  const TeamMessageModel({
    required this.id,
    required this.teamId,
    required this.senderId,
    required this.message,
    this.createdAt,
    this.fullName,
    this.profileImage,
  });

  factory TeamMessageModel.fromJson(Map<String, dynamic> json) {
    return TeamMessageModel(
      id: int.parse(json['id'].toString()),
      teamId: int.parse(json['team_id'].toString()),
      senderId: int.parse(json['sender_id'].toString()),
      message: json['message']?.toString() ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(
        json['created_at'].toString(),
      )?.toLocal()
          : null,
      fullName: json['full_name']?.toString(),
      profileImage: json['profile_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'team_id': teamId,
      'sender_id': senderId,
      'message': message,
      'created_at': createdAt?.toIso8601String(),
      'full_name': fullName,
      'profile_image': profileImage,
    };
  }
}