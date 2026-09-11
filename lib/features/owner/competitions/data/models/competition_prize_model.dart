class CompetitionPrizeModel {
  final int id;
  final int competitionId;

  final String name;
  final String? description;

  final String prizeType;

  final double? amount;
  final String? currency;

  final int? position;

  const CompetitionPrizeModel({
    required this.id,
    required this.competitionId,
    required this.name,
    this.description,
    required this.prizeType,
    this.amount,
    this.currency,
    this.position,
  });

  factory CompetitionPrizeModel.fromJson(
      Map<String, dynamic> json,
      ) {
    return CompetitionPrizeModel(
      id: _parseInt(json['id']),
      competitionId: _parseInt(json['competition_id']),
      name: json['name'] as String,
      description: json['description'] as String?,
      prizeType: json['prize_type'] as String,
      amount: _parseNullableDouble(json['amount']),
      currency: json['currency'] as String?,
      position: _parseNullableInt(json['position']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'competition_id': competitionId,
      'name': name,
      'description': description,
      'prize_type': prizeType,
      'amount': amount,
      'currency': currency,
      'position': position,
    };
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.parse(value.toString());
  }

  static int? _parseNullableInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.parse(value.toString());
  }

  static double? _parseNullableDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.parse(value.toString());
  }
}