class FormationPosition {
  final String id;
  final String title;
  final double x;
  final double y;

  const FormationPosition({
    required this.id,
    required this.title,
    required this.x,
    required this.y,
  });

  FormationPosition copyWith({
    String? id,
    String? title,
    double? x,
    double? y,
  }) {
    return FormationPosition(
      id: id ?? this.id,
      title: title ?? this.title,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }
}