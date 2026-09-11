abstract final class Validators {
  // 📱 Phone Regex (يُستخدم في أكتر من مكان زي AcademyValidators)
  static final RegExp phoneRegex = RegExp(r'^01[0125][0-9]{8}$');

  // 📧 Email
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'من فضلك أدخل البريد الإلكتروني';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'بريد إلكتروني غير صالح';
    }
    return null;
  }

  // 🔒 Password
  static String? password(String? value) {
    if (value == null || value.trim().length < 6) {
      return 'كلمة المرور يجب أن تتكون من 6 أحرف على الأقل';
    }
    return null;
  }

  // 📱 Phone
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'من فضلك أدخل رقم الهاتف';
    }
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'رقم هاتف مصري غير صالح';
    }
    return null;
  }

  // 📝 Required
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'هذا الحقل مطلوب';
    }
    return null;
  }
}