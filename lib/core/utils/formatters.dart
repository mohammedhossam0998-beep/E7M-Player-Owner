import 'package:intl/intl.dart';

abstract final class Formatters {
  // 📅 Date
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy', 'ar').format(date);
  }

  // ⏰ Time
  static String formatTime(DateTime time) {
    return DateFormat('hh:mm a', 'ar').format(time);
  }

  // 💰 Price
  static String formatPrice(double price) {
    return '${price.toStringAsFixed(0)} جنيه';
  }

  // 💵 Currency
  static String formatCurrency(
      double price, {
        String currencySymbol = 'جنيه',
      }) {
    return '${price.toStringAsFixed(0)} $currencySymbol';
  }
}