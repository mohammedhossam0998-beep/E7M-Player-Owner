import 'dart:ui' show Color;
import 'package:equatable/equatable.dart';

class OnboardingModel extends Equatable {
  final String titleKey;
  final String descriptionKey;
  final String image;
  // أزلنا primaryColor ليعتمد على الـ Theme كما اقترحت

  const OnboardingModel({
    required this.titleKey,
    required this.descriptionKey,
    required this.image,
  });

  // إضافة Equality للمقارنات الدقيقة
  @override
  List<Object?> get props => [titleKey, descriptionKey, image];

  factory OnboardingModel.fromMap(Map<String, dynamic> map) {
    return OnboardingModel(
      titleKey: map['titleKey'] as String? ?? '',
      descriptionKey: map['descriptionKey'] as String? ?? '',
      image: map['image'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'titleKey': titleKey,
      'descriptionKey': descriptionKey,
      'image': image,
    };
  }
}
