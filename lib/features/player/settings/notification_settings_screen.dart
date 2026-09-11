import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../notifications/providers/notification_settings_provider.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationSettingsProvider>().loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBFBF9),
      appBar: AppBar(
        backgroundColor: const Color(0xffFBFBF9),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'إعدادات الإشعارات',
          style: TextStyle(
            color: Color(0xff1E1446),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Consumer<NotificationSettingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.error != null) {
            return _buildErrorState(provider);
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'تحكم في الإشعارات التي تريد استقبالها',
                style: TextStyle(
                  color: Color(0xff9A9A8F),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 20),

              // =========================
              // الحجوزات
              // =========================

              _buildSection(
                title: 'الحجوزات',
                children: [
                  _buildNotificationTile(
                    icon: Icons.calendar_month_outlined,
                    title: 'تأكيد الحجز',
                    subtitle: 'استقبل إشعارًا عند تأكيد حجزك',
                    value: provider.bookingConfirmed,
                    onChanged: provider.isUpdating
                        ? null
                        : (value) async {
                      await provider.setBookingConfirmed(value);
                    },
                  ),
                  _buildNotificationTile(
                    icon: Icons.event_busy_outlined,
                    title: 'رفض الحجز',
                    subtitle: 'استقبل إشعارًا عند رفض حجزك',
                    value: provider.bookingRejected,
                    onChanged: provider.isUpdating
                        ? null
                        : (value) async {
                      await provider.setBookingRejected(value);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // =========================
              // المدفوعات
              // =========================

              _buildSection(
                title: 'المدفوعات',
                children: [
                  _buildNotificationTile(
                    icon: Icons.payment_outlined,
                    title: 'إشعارات المدفوعات',
                    subtitle: 'تحديثات الدفع والمعاملات المالية',
                    value: provider.payments,
                    onChanged: provider.isUpdating
                        ? null
                        : (value) async {
                      await provider.setPayments(value);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // =========================
              // العروض
              // =========================

              _buildSection(
                title: 'العروض',
                children: [
                  _buildNotificationTile(
                    icon: Icons.local_offer_outlined,
                    title: 'العروض والتخفيضات',
                    subtitle: 'استقبل أحدث العروض المتاحة',
                    value: provider.offers,
                    onChanged: provider.isUpdating
                        ? null
                        : (value) async {
                      await provider.setOffers(value);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // =========================
              // المباريات
              // =========================

              _buildSection(
                title: 'المباريات',
                children: [
                  _buildNotificationTile(
                    icon: Icons.sports_soccer_outlined,
                    title: 'إشعارات المباريات',
                    subtitle: 'تحديثات المباريات والأحداث المهمة',
                    value: provider.matches,
                    onChanged: provider.isUpdating
                        ? null
                        : (value) async {
                      await provider.setMatches(value);
                    },
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // =========================
              // عام
              // =========================

              _buildSection(
                title: 'عام',
                children: [
                  _buildNotificationTile(
                    icon: Icons.notifications_none,
                    title: 'الإشعارات العامة',
                    subtitle: 'التنبيهات والتحديثات العامة المهمة',
                    value: provider.general,
                    onChanged: provider.isUpdating
                        ? null
                        : (value) async {
                      await provider.setGeneral(value);
                    },
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
      NotificationSettingsProvider provider,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'حدث خطأ أثناء تحميل إعدادات الإشعارات',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff1E1446),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: provider.loadSettings,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xff1E1446).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              8,
            ),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xff1E1446),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
      secondary: Container(
        width: 42,
        height: 42,
        decoration: const BoxDecoration(
          color: Color(0xffF1F3EC),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: const Color(0xff5C7A2A),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xff1E1446),
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: Color(0xff9A9A8F),
          fontSize: 12,
          height: 1.4,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xff7CC000),
    );
  }
}