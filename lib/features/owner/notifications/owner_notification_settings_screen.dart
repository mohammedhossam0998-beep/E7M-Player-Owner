
import 'package:flutter/material.dart';
import 'package:e7m/core/network/api_client.dart';

class OwnerNotificationSettingsScreen extends StatefulWidget {
  const OwnerNotificationSettingsScreen({
    super.key,
  });

  @override
  State<OwnerNotificationSettingsScreen> createState() =>
      _OwnerNotificationSettingsScreenState();
}

class _OwnerNotificationSettingsScreenState
    extends State<OwnerNotificationSettingsScreen> {
  final ApiClient _api = ApiClient();

  Map<String, bool>? _settings;

  bool _loading = false;
  String? _savingKey;
  String? _error;

  // ============================================================
  // SUPPORTED NOTIFICATION SETTINGS
  // ============================================================

  static const List<String> _keys = [
    'new_booking',
    'booking_confirmed',
    'booking_rejected',
    'payments',
    'offers',
    'matches',
    'general',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadSettings();
      }
    });
  }

  // ============================================================
  // PARSE SETTINGS
  // ============================================================

  Map<String, bool> _parseSettings(dynamic raw) {
    if (raw is! Map) {
      throw Exception(
        'Notification settings are missing',
      );
    }

    final parsed = <String, bool>{};

    for (final key in _keys) {
      final value = raw[key];

      if (value is! bool) {
        throw Exception(
          'Invalid or missing notification setting: $key',
        );
      }

      parsed[key] = value;
    }

    return parsed;
  }

  // ============================================================
  // LOAD SETTINGS
  // GET /api/notifications/settings
  // ============================================================

  Future<void> _loadSettings() async {
    if (_loading || _savingKey != null) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await _api.get(
        '/notifications/settings',
      );

      if (response is! Map ||
          response['success'] != true) {
        throw Exception(
          response is Map
              ? response['message']?.toString() ??
              'Failed to load notification settings'
              : 'Invalid server response',
        );
      }

      final settings = _parseSettings(
        response['settings'],
      );

      if (!mounted) return;

      setState(() {
        _settings = settings;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // UPDATE ONE NOTIFICATION SETTING
  // PATCH /api/notifications/settings
  // ============================================================

  Future<void> _updateSetting(
      String key,
      bool enabled,
      ) async {
    if (_settings == null ||
        _savingKey != null ||
        _loading) {
      return;
    }

    if (_settings![key] == enabled) {
      return;
    }

    setState(() {
      _savingKey = key;
      _error = null;
    });

    try {
      final response = await _api.patch(
        '/notifications/settings',
        {
          key: enabled,
        },
      );

      if (response is! Map ||
          response['success'] != true) {
        throw Exception(
          response is Map
              ? response['message']?.toString() ??
              'Failed to update notification setting'
              : 'Invalid server response',
        );
      }

      final saved = _parseSettings(
        response['settings'],
      );

      if (!mounted) return;

      setState(() {
        _settings = saved;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Notification setting saved successfully',
            ),
          ),
        );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _savingKey = null;
        });
      }
    }
  }

  // ============================================================
  // SETTING TILE
  // ============================================================

  Widget _settingTile({
    required String keyName,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final value = _settings?[keyName] ?? false;

    final saving = _savingKey == keyName;

    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(
          color: Color(0xFFE8EBF0),
        ),
      ),
      child: SwitchListTile.adaptive(
        value: value,

        onChanged: _loading ||
            _savingKey != null ||
            _error != null
            ? null
            : (enabled) {
          _updateSetting(
            keyName,
            enabled,
          );
        },

        secondary: saving
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        )
            : Icon(
          icon,
          color: const Color(0xFF1E1446),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),

        subtitle: Text(subtitle),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),

      appBar: AppBar(
        title: const Text(
          'Notification Settings',
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E1446),
        actions: [
          IconButton(
            tooltip: 'Refresh settings',
            icon: const Icon(
              Icons.refresh,
            ),
            onPressed:
            _loading || _savingKey != null
                ? null
                : _loadSettings,
          ),
        ],
      ),

      body: _settings == null && _loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : _settings == null
          ? Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 45,
              color: Colors.red,
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _error ??
                    'Failed to load notification settings',
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 12),

            FilledButton(
              onPressed: _loadSettings,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadSettings,
        child: ListView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Owner Notification Preferences',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E1446),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Choose which push notifications '
                  'you want to receive.',
              style: TextStyle(
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 20),

            if (_loading)
              const LinearProgressIndicator(),

            if (_error != null) ...[
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(
                          color: Colors.red,
                        ),
                      ),
                      TextButton(
                        onPressed: _loadSettings,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],

            // =================================================
            // NEW BOOKING
            // =================================================

            _settingTile(
              keyName: 'new_booking',
              title: 'New Booking Requests',
              subtitle:
              'Receive alerts when a player '
                  'books your stadium.',
              icon: Icons.event_note_outlined,
            ),

            // =================================================
            // BOOKING CONFIRMED
            // =================================================

            _settingTile(
              keyName: 'booking_confirmed',
              title: 'Booking Confirmations',
              subtitle:
              'Receive booking confirmation alerts.',
              icon: Icons.event_available_outlined,
            ),

            // =================================================
            // BOOKING REJECTED
            // =================================================

            _settingTile(
              keyName: 'booking_rejected',
              title: 'Booking Rejections',
              subtitle:
              'Receive booking rejection alerts.',
              icon: Icons.event_busy_outlined,
            ),

            // =================================================
            // PAYMENTS
            // =================================================

            _settingTile(
              keyName: 'payments',
              title: 'Payments',
              subtitle:
              'Receive stadium and academy '
                  'payment alerts.',
              icon: Icons.payments_outlined,
            ),

            // =================================================
            // OFFERS
            // =================================================

            _settingTile(
              keyName: 'offers',
              title: 'Offers',
              subtitle:
              'Receive promotional offers.',
              icon: Icons.local_offer_outlined,
            ),

            // =================================================
            // MATCHES
            // =================================================

            _settingTile(
              keyName: 'matches',
              title: 'Matches',
              subtitle:
              'Receive match-related notifications.',
              icon: Icons.sports_soccer_outlined,
            ),

            // =================================================
            // GENERAL
            // =================================================

            _settingTile(
              keyName: 'general',
              title: 'General Notifications',
              subtitle:
              'Receive general system notifications.',
              icon:
              Icons.notifications_active_outlined,
            ),

            const SizedBox(height: 20),

            const Text(
              'These settings control push '
                  'notifications. Notifications '
                  'already saved in the app inbox '
                  'will remain available.',
              style: TextStyle(
                color: Colors.black54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
