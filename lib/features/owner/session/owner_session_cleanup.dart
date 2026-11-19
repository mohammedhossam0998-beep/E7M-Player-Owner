import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../booking/providers/owner_bookings_provider.dart';
import '../competitions/presentation/providers/competition_provider.dart';
import '../notifications/providers/notification_provider.dart';
import '../payout/providers/owner_payment_provider.dart';
import '../profile/providers/owner_profile_provider.dart';
import '../revenue/providers/revenue_provider.dart';

/// يمسح بيانات الأونر المخزنة عند تسجيل الخروج أو تبديل الحساب.
class OwnerSessionCleanup {
  OwnerSessionCleanup._();

  static void clear(BuildContext context) {
    try {
      context.read<OwnerProfileProvider>().clearProfile();
    } catch (_) {}

    try {
      context.read<NotificationProvider>().clearNotifications();
    } catch (_) {}

    try {
      context.read<OwnerBookingsProvider>().clearBookings();
    } catch (_) {}

    try {
      context.read<CompetitionProvider>().reset();
    } catch (_) {}

    try {
      context.read<OwnerPaymentProvider>().clearAccountData();
    } catch (_) {}

    try {
      context.read<RevenueProvider>().clear();
    } catch (_) {}
  }
}