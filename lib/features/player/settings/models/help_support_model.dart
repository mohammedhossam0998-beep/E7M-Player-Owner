class HelpSupportModel {
  final int id;
  final String email;
  final String phone;
  final String version;
  final List<FaqItem> faq;

  HelpSupportModel({
    required this.id,
    required this.email,
    required this.phone,
    required this.version,
    required this.faq,
  });

  factory HelpSupportModel.fromJson(Map<String, dynamic> json) {
    return HelpSupportModel(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id'].toString()) ?? 0,
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      faq: (json['faq'] as List<dynamic>? ?? [])
          .map((item) => FaqItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({
    required this.question,
    required this.answer,
  });

  factory FaqItem.fromJson(Map<String, dynamic> json) {
    return FaqItem(
      question: json['question']?.toString() ?? '',
      answer: json['answer']?.toString() ?? '',
    );
  }
}