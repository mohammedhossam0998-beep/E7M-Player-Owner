abstract final class AppConstants {
  // 📱 App Info
  static const String appName = "E7M";
  static const String appVersion = "1.0.0";

  // ⏱ Booking
  static const int bookingDurationMinutes = 60;
  static const int maxPlayers = 10;

  // 💰 Pricing
  static const double defaultPrice = 200.0;
  static const double discountPercentage = 0.1;

  // ⏰ Time
  static const int startHour = 8;
  static const int endHour = 23;

  // 📍 Search
  static const double defaultRadius = 5.0;

  // 🤖 AI
  static const int maxChatMessages = 50;

  // 🚀 UX
  static const Duration splashDuration = Duration(seconds: 3);
  static const int otpLength = 6;
}