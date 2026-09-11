import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';

import 'models/notification_model.dart';
import 'providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  int selectedFilter = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<NotificationProvider>()
          .loadNotifications();
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final languageProvider =
    context.watch<LanguageProvider>();

    final notificationProvider =
    context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),

      // ========================================================
      // APP BAR
      // ========================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        title: Text(
          languageProvider.translate('notifications'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          TextButton(
            onPressed:
            notificationProvider.unreadCount == 0 ||
                notificationProvider.isUpdating
                ? null
                : _markAllAsRead,
            child: Text(
              languageProvider.translate('read_all'),
              style: TextStyle(
                color:
                notificationProvider.unreadCount == 0
                    ? Colors.grey
                    : const Color(0xff7CC000),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),

      // ========================================================
      // BODY
      // ========================================================

      body: Column(
        children: [
          const SizedBox(height: 15),

          // ====================================================
          // FILTERS
          // ====================================================

          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding:
              const EdgeInsets.symmetric(horizontal: 16),
              children: [
                filterChip(
                  languageProvider.translate('all'),
                  0,
                ),
                const SizedBox(width: 10),
                filterChip(
                  languageProvider.translate('unread'),
                  1,
                ),
                const SizedBox(width: 10),
                filterChip(
                  languageProvider.translate('read'),
                  2,
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // ====================================================
          // NOTIFICATIONS
          // ====================================================

          Expanded(
            child: RefreshIndicator(
              color: const Color(0xff7CC000),

              onRefresh: () async {
                await context
                    .read<NotificationProvider>()
                    .refresh();
              },

              child: _buildNotificationsList(
                context,
                notificationProvider,
                languageProvider,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // NOTIFICATIONS LIST
  // ============================================================

  Widget _buildNotificationsList(
      BuildContext context,
      NotificationProvider provider,
      LanguageProvider languageProvider,
      ) {
    if (provider.isLoading &&
        provider.notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xff7CC000),
        ),
      );
    }

    if (provider.hasError &&
        provider.notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),

          Icon(
            Icons.error_outline,
            size: 60,
            color: Colors.grey.shade400,
          ),

          const SizedBox(height: 15),

          Center(
            child: Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 30),
              child: Text(
                provider.errorMessage ??
                    'Failed to load notifications',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 15,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Center(
            child: ElevatedButton(
              onPressed: () {
                provider.loadNotifications();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xff7CC000),
                elevation: 0,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    final filteredNotifications =
    _getFilteredNotifications(
      provider.notifications,
    );

    if (filteredNotifications.isEmpty) {
      return _buildEmptyState(
        languageProvider,
      );
    }

    return ListView.builder(
      physics:
      const AlwaysScrollableScrollPhysics(),
      padding:
      const EdgeInsets.symmetric(horizontal: 16),
      itemCount: filteredNotifications.length,
      itemBuilder: (context, index) {
        final notification =
        filteredNotifications[index];

        return _buildNotificationItem(
          context,
          notification,
          languageProvider,
        );
      },
    );
  }

  // ============================================================
  // FILTER
  // ============================================================

  List<NotificationModel> _getFilteredNotifications(
      List<NotificationModel> notifications,
      ) {
    switch (selectedFilter) {
      case 1:
        return notifications
            .where(
              (notification) =>
          !notification.isRead,
        )
            .toList();

      case 2:
        return notifications
            .where(
              (notification) =>
          notification.isRead,
        )
            .toList();

      case 0:
      default:
        return notifications;
    }
  }

  // ============================================================
  // NOTIFICATION ITEM
  // ============================================================

  Widget _buildNotificationItem(
      BuildContext context,
      NotificationModel notification,
      LanguageProvider languageProvider,
      ) {
    final icon = _getNotificationIcon(
      notification.type,
    );

    final color = _getNotificationColor(
      notification.type,
    );

    return Dismissible(
      key: ValueKey(notification.id),

      direction:
      DismissDirection.endToStart,

      background: Container(
        margin:
        const EdgeInsets.only(bottom: 15),
        padding:
        const EdgeInsets.only(right: 25),
        alignment:
        Alignment.centerRight,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius:
          BorderRadius.circular(20),
        ),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),

      onDismissed: (_) async {
        final provider =
        context.read<NotificationProvider>();

        final success =
        await provider.deleteNotification(
          notification.id,
        );

        if (!context.mounted) return;

        ScaffoldMessenger.of(context)
            .hideCurrentSnackBar();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? languageProvider.translate(
                'notification_deleted',
              )
                  : 'Failed to delete notification',
            ),
          ),
        );
      },

      child: GestureDetector(
        onTap: () {
          if (!notification.isRead) {
            context
                .read<NotificationProvider>()
                .markAsRead(notification.id);
          }
        },

        child: Container(
          margin:
          const EdgeInsets.only(bottom: 15),
          padding:
          const EdgeInsets.all(18),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withValues(
                  alpha: .05,
                ),
                blurRadius: 12,
              ),
            ],
          ),

          child: Row(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // ==================================================
              // ICON
              // ==================================================

              CircleAvatar(
                radius: 28,
                backgroundColor:
                color.withValues(
                  alpha: .15,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),

              const SizedBox(width: 16),

              // ==================================================
              // CONTENT
              // ==================================================

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
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                        ),

                        // UNREAD INDICATOR
                        if (!notification.isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration:
                            const BoxDecoration(
                              color:
                              Color(0xff7CC000),
                              shape:
                              BoxShape.circle,
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    Text(
                      notification.message,
                      style: TextStyle(
                        color:
                        Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),

                    const SizedBox(height: 10),

                    // ==================================================
                    // DATE / TIME
                    // ==================================================

                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color:
                          Colors.grey.shade500,
                        ),

                        const SizedBox(width: 5),

                        Text(
                          _formatDay(
                            notification.createdAt,
                            languageProvider,
                          ),
                          style: TextStyle(
                            color:
                            Colors.grey.shade600,
                          ),
                        ),

                        const Spacer(),

                        Text(
                          _formatTime(
                            notification.createdAt,
                            languageProvider,
                          ),
                          style: TextStyle(
                            color:
                            Colors.grey.shade600,
                          ),
                        ),
                      ],
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

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState(
      LanguageProvider languageProvider,
      ) {
    String message;

    switch (selectedFilter) {
      case 1:
        message =
            languageProvider.translate(
              'no_unread_notifications',
            );
        break;

      case 2:
        message =
            languageProvider.translate(
              'no_read_notifications',
            );
        break;

      default:
        message =
            languageProvider.translate(
              'no_notifications',
            );
    }

    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),

        Icon(
          Icons.notifications_none,
          size: 70,
          color: Colors.grey.shade400,
        ),

        const SizedBox(height: 15),

        Center(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<void> _markAllAsRead() async {
    final provider =
    context.read<NotificationProvider>();

    final success =
    await provider.markAllAsRead();

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Failed to mark all notifications as read',
          ),
        ),
      );
    }
  }

  // ============================================================
  // FILTER CHIP
  // ============================================================

  Widget filterChip(
      String title,
      int index,
      ) {
    final bool selected =
        selectedFilter == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = index;
        });
      },

      child: AnimatedContainer(
        duration:
        const Duration(milliseconds: 250),

        padding:
        const EdgeInsets.symmetric(
          horizontal: 22,
          vertical: 10,
        ),

        decoration: BoxDecoration(
          color: selected
              ? const Color(0xff7CC000)
              : Colors.white,

          borderRadius:
          BorderRadius.circular(30),

          border: Border.all(
            color: selected
                ? const Color(0xff7CC000)
                : Colors.grey.shade300,
          ),

          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withValues(
                alpha: .04,
              ),
              blurRadius: 8,
            ),
          ],
        ),

        child: Text(
          title,
          style: TextStyle(
            color: selected
                ? Colors.white
                : Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ICON BY TYPE
  // ============================================================

  IconData _getNotificationIcon(
      String? type,
      ) {
    switch (type) {
      case 'new_booking':
        return Icons.calendar_month;

      case 'payment_received':
        return Icons.payments;

      case 'new_review':
        return Icons.star;

      case 'system':
        return Icons.verified;

      default:
        return Icons.notifications;
    }
  }

  // ============================================================
  // COLOR BY TYPE
  // ============================================================

  Color _getNotificationColor(
      String? type,
      ) {
    switch (type) {
      case 'new_booking':
        return Colors.green;

      case 'payment_received':
        return Colors.orange;

      case 'new_review':
        return Colors.amber;

      case 'system':
        return Colors.blue;

      default:
        return const Color(0xff7CC000);
    }
  }

  // ============================================================
  // FORMAT DAY
  // ============================================================

  String _formatDay(
      DateTime date,
      LanguageProvider languageProvider,
      ) {
    final now = DateTime.now();

    final localDate = date.toLocal();

    if (DateUtils.isSameDay(
      localDate,
      now,
    )) {
      return languageProvider.translate(
        'today',
      );
    }

    final yesterday =
    now.subtract(
      const Duration(days: 1),
    );

    if (DateUtils.isSameDay(
      localDate,
      yesterday,
    )) {
      return languageProvider.translate(
        'yesterday',
      );
    }

    final locale =
        languageProvider.locale.languageCode;

    return DateFormat(
      'dd MMM yyyy',
      locale,
    ).format(localDate);
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(
      DateTime date,
      LanguageProvider languageProvider,
      ) {
    final locale =
        languageProvider.locale.languageCode;

    return DateFormat(
      'hh:mm a',
      locale,
    ).format(
      date.toLocal(),
    );
  }
}