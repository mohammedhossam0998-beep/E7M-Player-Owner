
class AcademyProgramModel {
final int id;
final int academyId;
final String name;
final String? description;
final String? level;
final double? price;
final int? durationWeeks;

const AcademyProgramModel({
required this.id,
required this.academyId,
required this.name,
this.description,
this.level,
this.price,
this.durationWeeks,
});

factory AcademyProgramModel.fromJson(Map<String, dynamic> json) {
return AcademyProgramModel(
id: int.parse(json['id'].toString()),
academyId: int.parse(json['academy_id'].toString()),
name: json['name']?.toString() ?? '',
description: json['description']?.toString(),
level: json['level']?.toString(),
price: json['price'] != null
? double.tryParse(json['price'].toString())
    : null,
durationWeeks: json['duration_weeks'] != null
? int.tryParse(json['duration_weeks'].toString())
    : null,
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
}
