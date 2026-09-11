// lib/shared/utils/image_url_helper.dart
//
// دالة موحدة لبناء رابط الصورة في كل الشاشات، عشان نتجنب مشكلة
// السلاش المزدوج (//) وتضارب المنطق بين الشاشات المختلفة.

class ImageUrlHelper {
  // غيّر الـ base URL هنا لو الـ IP اتغير، وهيتغير في كل الشاشات مرة واحدة
  static const String baseUrl = 'http://192.168.1.2:5000';

  /// يبني رابط صورة كامل وصحيح من أي path راجع من السيرفر،
  /// سواء كان فيه سلاش زيادة أو ناقص أو كان رابط كامل من الأساس.
  static String build(String? path) {
    if (path == null || path.trim().isEmpty) {
      return '';
    }

    final trimmed = path.trim();

    // لو الرابط كامل بالفعل (http/https) رجّعه زي ما هو
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    // شيل أي عدد سلاشات في الأول، وحط سلاش واحد بس بدالهم
    final cleanPath = '/${trimmed.replaceFirst(RegExp(r'^/+'), '')}';

    return '$baseUrl$cleanPath';
  }
}