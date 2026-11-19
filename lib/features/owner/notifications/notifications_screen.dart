
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';

import 'models/notification_model.dart';
import 'providers/notification_provider.dart';
import 'owner_notification_settings_screen.dart';
import '../booking/presentation/screens/owner_bookings_screen.dart';

// ============================================================
// OWNER NOTIFICATIONS SCREEN
// ============================================================

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  static const Color _green = Color(0xFF7CC000);
  static const Color _ink = Color(0xFF1E1446);

  int _selectedFilter = 0;
  int? _openingNotificationId;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context
            .read<NotificationProvider>()
            .loadNotifications();
      }
    });
  }

  // ============================================================
  // SHOW MESSAGE
  // ============================================================

  void _message(
      String text, {
        bool error = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor:
          error ? Colors.red : _green,
        ),
      );
  }

  // ============================================================
  // MARK ALL AS READ
  // ============================================================

  Future<void> _markAllRead() async {
    final provider =
    context.read<NotificationProvider>();

    if (provider.isUpdating ||
        _openingNotificationId != null) {
      return;
    }

    final success =
    await provider.markAllAsRead();

    if (!mounted) return;

    if (!success) {
      _message(
        provider.errorMessage ??
            'Could not update notifications',
        error: true,
      );
    }
  }

  // ============================================================
  // BOOKING NOTIFICATION TYPES
  // ============================================================

  bool _isBookingNotification(String? type) {
    return type == 'new_booking' ||
        type == 'booking_cancelled';
  }

  // ============================================================
  // OPEN NOTIFICATION
  // ============================================================
  //
  // 1. Mark notification as read.
  // 2. Check notification type.
  // 3. Open the linked booking using bookingId.
  // 4. Old notifications without bookingId open all bookings.
  //
  // ============================================================

  Future<void> _openNotification(
      NotificationModel notification,
      ) async {
    if (_openingNotificationId != null) {
      return;
    }

    final provider =
    context.read<NotificationProvider>();

    if (provider.isUpdating) {
      return;
    }

    setState(() {
      _openingNotificationId = notification.id;
    });

    try {
      // ========================================================
      // MARK AS READ
      // ========================================================

      if (!notification.isRead) {
        final success = await provider.markAsRead(
          notification.id,
        );

        if (!mounted) return;

        if (!success) {
          _message(
            provider.errorMessage ??
                'Could not mark notification as read',
            error: true,
          );
        }
      }

      if (!mounted) return;

      // ========================================================
      // OPEN OWNER BOOKING
      // ========================================================

      if (_isBookingNotification(notification.type)) {
        await Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            builder: (_) => OwnerBookingsScreen(
              bookingId: notification.bookingId,
            ),
          ),
        );
      }
    } catch (error) {
      if (!mounted) return;

      _message(
        error
            .toString()
            .replaceFirst('Exception: ', ''),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _openingNotificationId = null;
        });
      }
    }
  }

  // ============================================================
  // DELETE NOTIFICATION
  // ============================================================

  Future<bool> _deleteNotification(
      NotificationModel notification,
      ) async {
    final provider =
    context.read<NotificationProvider>();

    if (provider.isUpdating ||
        _openingNotificationId != null) {
      return false;
    }

    final confirmed = await showDialog<bool>(
      context: context,

      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete notification?',
          ),

          content: const Text(
            'This notification will be removed from your inbox.',
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),

            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return false;
    }

    final success =
    await provider.deleteNotification(
      notification.id,
    );

    if (!mounted) return false;

    _message(
      success
          ? 'Notification deleted'
          : provider.errorMessage ??
          'Could not delete notification',
      error: !success,
    );

    // Provider removes the item after server success.
    // Returning false prevents double removal.
    return false;
  }

  // ============================================================
  // NOTIFICATION ICON
  // ============================================================

  IconData _iconFor(String? type) {
    switch (type) {
      case 'new_booking':
        return Icons.event_note_outlined;

      case 'booking_cancelled':
        return Icons.event_busy_outlined;

      case 'booking_confirmed':
        return Icons.event_available_outlined;

      case 'booking_rejected':
        return Icons.event_busy_outlined;

      case 'payments':
      case 'payment_received':
        return Icons.payments_outlined;

      case 'new_review':
        return Icons.star_outline;

      case 'matches':
        return Icons.sports_soccer_outlined;

      case 'offers':
        return Icons.local_offer_outlined;

      default:
        return Icons.notifications_none_outlined;
    }
  }

  // ============================================================
  // NOTIFICATION COLOR
  // ============================================================

  Color _colorFor(String? type) {
    switch (type) {
      case 'booking_rejected':
      case 'booking_cancelled':
        return Colors.red;

      case 'payments':
      case 'payment_received':
        return Colors.orange.shade800;

      case 'new_review':
        return Colors.amber.shade800;

      case 'new_booking':
      case 'booking_confirmed':
        return _green;

      default:
        return const Color(0xFF3B82F6);
    }
  }

  // ============================================================
  // FILTER NOTIFICATIONS
  // ============================================================

  List<NotificationModel> _filtered(
      List<NotificationModel> all,
      ) {
    switch (_selectedFilter) {
      case 1:
        return all.where((notification) {
          return !notification.isRead;
        }).toList();

      case 2:
        return all.where((notification) {
          return notification.isRead;
        }).toList();

      case 3:
        return all.where((notification) {
          return _isBookingNotification(
            notification.type,
          );
        }).toList();

      default:
        return all;
    }
  }

  // ============================================================
  // NOTIFICATION CARD
  // ============================================================

  Widget _notificationCard(
      NotificationModel notification,
      ) {
    final color = _colorFor(
      notification.type,
    );

    final formatted = DateFormat(
      'dd/MM/yyyy  hh:mm a',
    ).format(
      notification.createdAt.toLocal(),
    );

    final isBooking = _isBookingNotification(
      notification.type,
    );

    return Dismissible(
      key: ValueKey(notification.id),

      direction: DismissDirection.endToStart,

      confirmDismiss: (_) {
        return _deleteNotification(notification);
      },

      background: Container(
        margin: const EdgeInsets.only(
          bottom: 12,
        ),

        alignment: Alignment.centerRight,

        padding: const EdgeInsets.only(
          right: 24,
        ),

        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius:
          BorderRadius.circular(18),
        ),

        child: const Icon(
          Icons.delete_outline,
          color: Colors.white,
        ),
      ),

      child: Card(
        margin: const EdgeInsets.only(
          bottom: 12,
        ),

        color: Colors.white,
        elevation: 0,

        shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(18),

          side: BorderSide(
            color: notification.isRead
                ? const Color(0xFFEBEDF0)
                : _green.withValues(
              alpha: 0.35,
            ),
          ),
        ),

        child: InkWell(
          borderRadius:
          BorderRadius.circular(18),

          onTap: _openingNotificationId != null
              ? null
              : () {
            _openNotification(
              notification,
            );
          },

          child: Padding(
            padding: const EdgeInsets.all(16),

            child: Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                CircleAvatar(
                  backgroundColor:
                  color.withValues(
                    alpha: 0.12,
                  ),

                  child: Icon(
                    _iconFor(notification.type),
                    color: color,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,

                    children: [
                      // =========================================
                      // TITLE + UNREAD INDICATOR
                      // =========================================

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,

                              style: TextStyle(
                                fontWeight:
                                notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w800,

                                fontSize: 15,
                                color: _ink,
                              ),
                            ),
                          ),

                          if (!notification.isRead)
                            const CircleAvatar(
                              radius: 4,
                              backgroundColor:
                              _green,
                            ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      // =========================================
                      // MESSAGE
                      // =========================================

                      Text(
                        notification.message,
                      ),

                      const SizedBox(height: 9),

                      // =========================================
                      // BOOKING NAVIGATION
                      // =========================================

                      if (isBooking) ...[
                        Row(
                          mainAxisSize:
                          MainAxisSize.min,

                          children: [
                            Icon(
                              Icons.open_in_new_rounded,
                              size: 14,
                              color: color,
                            ),

                            const SizedBox(width: 5),

                            Flexible(
                              child: Text(
                                notification.bookingId == null
                                    ? 'Open Owner Bookings'
                                    : 'Open Booking #${notification.bookingId}',

                                style: TextStyle(
                                  color: color,
                                  fontSize: 12,
                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 9),
                      ],

                      // =========================================
                      // DATE
                      // =========================================

                      Text(
                        formatted,

                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTER CHIP
  // ============================================================

  Widget _choice(
      String title,
      int index,
      ) {
    return ChoiceChip(
      label: Text(title),

      selected:
      _selectedFilter == index,

      onSelected: (_) {
        setState(() {
          _selectedFilter = index;
        });
      },
    );
  }

  // ============================================================
  // CONTENT
  // ============================================================

  Widget _content(
      NotificationProvider provider,
      LanguageProvider language,
      ) {
    if (provider.isLoading &&
        provider.notifications.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: _green,
        ),
      );
    }

    final items = _filtered(
      provider.notifications,
    );

    return RefreshIndicator(
      onRefresh: provider.refresh,

      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),

        padding: const EdgeInsets.fromLTRB(
          16,
          10,
          16,
          24,
        ),

        children: [
          // =====================================================
          // ERROR BANNER
          // =====================================================

          if (provider.hasError) ...[
            Card(
              color: Colors.red.shade50,

              child: Padding(
                padding: const EdgeInsets.all(12),

                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        provider.errorMessage ??
                            'Load failed',
                      ),
                    ),

                    TextButton(
                      onPressed:
                      provider.loadNotifications,

                      child: const Text(
                        'Retry',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],

          // =====================================================
          // EMPTY STATE
          // =====================================================

          if (items.isEmpty)
            Padding(
              padding: const EdgeInsets.only(
                top: 95,
              ),

              child: Column(
                children: [
                  const Icon(
                    Icons.notifications_none,
                    size: 62,
                    color: Colors.grey,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _selectedFilter == 1
                        ? language.translate(
                      'no_unread_notifications',
                    )
                        : _selectedFilter == 2
                        ? language.translate(
                      'no_read_notifications',
                    )
                        : _selectedFilter == 3
                        ? 'No booking notifications'
                        : language.translate(
                      'no_notifications',
                    ),
                  ),
                ],
              ),
            )
          else
            ...items.map(
              _notificationCard,
            ),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final language =
    context.watch<LanguageProvider>();

    final provider =
    context.watch<NotificationProvider>();

    return Scaffold(
      backgroundColor:
      const Color(0xFFF6F8FB),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: _ink,
        centerTitle: true,

        title: Text(
          language.translate(
            'notifications',
          ),

          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          // =====================================================
          // SETTINGS
          // =====================================================

          IconButton(
            tooltip:
            'Notification settings',

            icon: const Icon(
              Icons.tune_outlined,
            ),

            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                  const OwnerNotificationSettingsScreen(),
                ),
              );
            },
          ),

          // =====================================================
          // MARK ALL READ
          // =====================================================

          TextButton(
            onPressed:
            provider.unreadCount == 0 ||
                provider.isUpdating ||
                _openingNotificationId != null
                ? null
                : _markAllRead,

            child: Text(
              language.translate(
                'read_all',
              ),

              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: _green,
              ),
            ),
          ),
        ],
      ),

      body: Column(
        children: [
          const SizedBox(height: 12),

          // =====================================================
          // FILTERS
          // =====================================================

          SingleChildScrollView(
            scrollDirection:
            Axis.horizontal,

            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),

            child: Row(
              children: [
                _choice(
                  language.translate('all'),
                  0,
                ),

                const SizedBox(width: 8),

                _choice(
                  language.translate('unread'),
                  1,
                ),

                const SizedBox(width: 8),

                _choice(
                  language.translate('read'),
                  2,
                ),

                const SizedBox(width: 8),

                _choice(
                  'Bookings',
                  3,
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: _content(
              provider,
              language,
            ),
          ),
        ],
      ),
    );
  }
}
