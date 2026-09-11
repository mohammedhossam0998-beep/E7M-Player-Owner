
class AcademyModel {
final int id;
final String name;
final String? description;
final String? address;
final int? cityId;
final String? cityName;
final String? imageUrl;
final int? ownerId;
final int? pitchId;
final String status;
final DateTime createdAt;
final DateTime updatedAt;

const AcademyModel({
required this.id,
required this.name,
this.description,
this.address,
this.cityId,
this.cityName,
this.imageUrl,
this.ownerId,
this.pitchId,
required this.status,
required this.createdAt,
required this.updatedAt,
});

factory AcademyModel.fromJson(Map<String, dynamic> json) {
return AcademyModel(
id: int.parse(json['id'].toString()),
name: json['name']?.toString() ?? '',
description: json['description']?.toString(),
address: json['address']?.toString(),
cityId: json['city_id'] != null
? int.tryParse(json['city_id'].toString())
    : null,
cityName: json['city_name']?.toString(),
imageUrl: json['image_url']?.toString(),
ownerId: json['owner_id'] != null
? int.tryParse(json['owner_id'].toString())
    : null,
pitchId: json['pitch_id'] != null
? int.tryParse(json['pitch_id'].toString())
    : null,
status: json['status']?.toString() ?? '',
createdAt: DateTime.parse(json['created_at'].toString()),
updatedAt: DateTime.parse(json['updated_at'].toString()),
);
}

Map<String, dynamic> toJson() {
return {
'id': id,
'name': name,
'description': description,
'address': address,
'city_id': cityId,
'city_name': cityName,
'image_url': imageUrl,
'owner_id': ownerId,
'pitch_id': pitchId,
'status': status,
'created_at': createdAt.toIso8601String(),
'updated_at': updatedAt.toIso8601String(),
};
}
}
