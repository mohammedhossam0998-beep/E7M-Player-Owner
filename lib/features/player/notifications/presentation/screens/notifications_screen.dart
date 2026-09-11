import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/features/player/notifications/data/models/notification_model.dart';
import 'package:e7m/features/player/notifications/providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        centerTitle: true,
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, provider, _) {
              if (!provider.hasUnreadNotifications) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'قراءة الكل',
                onPressed: provider.isMarkingAllAsRead
                    ? null
                    : () async {
                  await provider.markAllNotificationsAsRead();
                },
                icon: provider.isMarkingAllAsRead
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.done_all),
              );
            },
          ),
        ],
      ),

      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {

          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null &&
              !provider.hasNotifications) {
            return _buildErrorState(provider);
          }

          if (!provider.hasNotifications) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: provider.refresh,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              itemCount: provider.notifications.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final notification =
                provider.notifications[index];

                return _NotificationCard(
                  notification: notification,
                  onTap: () async {
                    if (!notification.isRead) {
                      await provider.markNotificationAsRead(
                        notification.id,
                      );
                    }
                  },
                  onDelete: () async {
                    await provider.deleteNotification(
                      notification.id,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return RefreshIndicator(
      onRefresh: () {
        return context
            .read<NotificationProvider>()
            .refresh();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 160),
          Icon(
            Icons.notifications_none_rounded,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              'لا توجد إشعارات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: Text(
              'ستظهر إشعاراتك هنا',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      NotificationProvider provider,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'حدث خطأ أثناء تحميل الإشعارات',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: provider.loadNotifications,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final bool unread = !notification.isRead;

    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        return true;
      },
      onDismissed: (_) {
        onDelete();
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: unread
                ? const Color(0xffF1F8E9)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: unread
                  ? const Color(0xff7CC000)
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: unread
                      ? const Color(0xff7CC000)
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getNotificationIcon(
                    notification.type,
                  ),
                  color: unread
                      ? Colors.white
                      : Colors.grey,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: unread
                                  ? FontWeight.bold
                                  : FontWeight.w600,
                            ),
                          ),
                        ),

                        if (unread)
                          Container(
                            width: 9,
                            height: 9,
                            decoration: const BoxDecoration(
                              color: Color(0xff7CC000),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      _formatDate(
                        notification.createdAt,
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'booking_confirmed':
        return Icons.check_circle_outline;

      case 'booking_rejected':
        return Icons.cancel_outlined;

      case 'payment_success':
        return Icons.payment_outlined;

      case 'booking':
        return Icons.calendar_month_outlined;

      case 'payment':
        return Icons.account_balance_wallet_outlined;

      default:
        return Icons.notifications_none_rounded;
    }
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    final day =
    localDate.day.toString().padLeft(2, '0');

    final month =
    localDate.month.toString().padLeft(2, '0');

    final year =
    localDate.year.toString();

    final hour =
    localDate.hour.toString().padLeft(2, '0');

    final minute =
    localDate.minute.toString().padLeft(2, '0');

    return '$day/$month/$year - $hour:$minute';
  }
}