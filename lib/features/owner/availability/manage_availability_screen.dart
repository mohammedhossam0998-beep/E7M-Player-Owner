import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:e7m/core/theme/app_colors.dart';

import 'data/models/slot_model.dart';
import 'data/models/availability_settings_model.dart';

import 'data/providers/slot_provider.dart';
import 'data/providers/availability_provider.dart';

import 'availability_calendar_screen.dart';

class ManageAvailabilityScreen extends StatefulWidget {
  final int stadiumId;

  const ManageAvailabilityScreen({
    super.key,
    required this.stadiumId,
  });

  @override
  State<ManageAvailabilityScreen> createState() =>
      _ManageAvailabilityScreenState();
}

class _ManageAvailabilityScreenState
    extends State<ManageAvailabilityScreen> {
  final Set<int> _selectedWeekdays = {
    DateTime.saturday,
    DateTime.sunday,
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
  };

  TimeOfDay _startTime =
  const TimeOfDay(hour: 12, minute: 0);

  TimeOfDay _endTime =
  const TimeOfDay(hour: 0, minute: 0);

  int _slotDurationMinutes = 90;
  double _price = 300;

  bool _isSaving = false;
  bool _isLoadingSettings = false;
  bool _settingsLoadFailed = false;

  final List<_PreviewSlot> _previewSlots = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadAvailability();
      }
    });
  }

  // ============================================================
  // LOAD SAVED WORKING HOURS
  // ============================================================

  Future<void> _loadAvailability() async {
    if (_isSaving || _isLoadingSettings) return;

    setState(() {
      _isLoadingSettings = true;
      _settingsLoadFailed = false;
    });

    final provider = context.read<AvailabilityProvider>();

    await provider.fetchAvailability(
      widget.stadiumId,
    );

    if (!mounted) return;

    final settings = provider.pitchId == widget.stadiumId
        ? provider.settings
        : null;

    setState(() {
      _isLoadingSettings = false;

      if (settings == null) {
        _settingsLoadFailed = true;
      } else {
        _selectedWeekdays
          ..clear()
          ..addAll(settings.weeklyDays);

        _startTime = _parseTime(settings.startTime);
        _endTime = _parseTime(settings.endTime);
        _slotDurationMinutes = settings.slotDuration;
        _price = settings.defaultPrice;
      }
    });

    if (settings == null) {
      _showMessage(
        'Could not load saved working hours. Please retry.',
      );
    }

    _refreshPreview();
  }

  // ============================================================
  // TIME HELPERS
  // ============================================================

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');

    if (parts.length < 2) {
      return const TimeOfDay(hour: 0, minute: 0);
    }

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    if (hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return const TimeOfDay(hour: 0, minute: 0);
    }

    return TimeOfDay(hour: hour, minute: minute);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour =
    time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;

    final minute =
    time.minute.toString().padLeft(2, '0');

    final period =
    time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  String _timeText(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _dateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  String _dateKeyFromString(String value) {
    return value.length >= 10
        ? value.substring(0, 10)
        : value;
  }

  String _normalizeTime(String value) {
    final parts = value.split(':');

    if (parts.length < 2) return value;

    return '${parts[0].padLeft(2, '0')}:'
        '${parts[1].padLeft(2, '0')}';
  }

  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.saturday:
        return 'Saturday';
      case DateTime.sunday:
        return 'Sunday';
      case DateTime.monday:
        return 'Monday';
      case DateTime.tuesday:
        return 'Tuesday';
      case DateTime.wednesday:
        return 'Wednesday';
      case DateTime.thursday:
        return 'Thursday';
      case DateTime.friday:
        return 'Friday';
      default:
        return '';
    }
  }

  // ============================================================
  // SELECT WORKING HOURS
  // ============================================================

  Future<void> _pickStartTime() async {
    if (_isSaving || _isLoadingSettings) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (!mounted || picked == null || _isSaving) return;

    setState(() {
      _startTime = picked;
    });

    _refreshPreview();
  }

  Future<void> _pickEndTime() async {
    if (_isSaving || _isLoadingSettings) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (!mounted || picked == null || _isSaving) return;

    setState(() {
      _endTime = picked;
    });

    _refreshPreview();
  }

  // ============================================================
  // EDIT DEFAULT PRICE
  // ============================================================

  Future<void> _editPrice() async {
    if (_isSaving || _isLoadingSettings) return;

    String input = _price.toStringAsFixed(
      _price.truncateToDouble() == _price ? 0 : 2,
    );

    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Slot Price'),
          content: TextFormField(
            initialValue: input,
            autofocus: true,
            keyboardType:
            const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: (newValue) {
              input = newValue;
            },
            decoration: const InputDecoration(
              labelText: 'Price',
              suffixText: 'EGP',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final parsed =
                double.tryParse(input.trim());

                if (parsed == null ||
                    !parsed.isFinite ||
                    parsed < 0) {
                  ScaffoldMessenger.of(dialogContext)
                      .showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Enter a valid non-negative price.',
                      ),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, parsed);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted || value == null || _isSaving) return;

    setState(() {
      _price = value;
    });

    _refreshPreview();
  }

  // ============================================================
  // WEEKDAY SELECTION
  // ============================================================

  void _toggleWeekday(int weekday) {
    if (_isSaving || _isLoadingSettings) return;

    setState(() {
      if (_selectedWeekdays.contains(weekday)) {
        _selectedWeekdays.remove(weekday);
      } else {
        _selectedWeekdays.add(weekday);
      }
    });

    _refreshPreview();
  }

  // ============================================================
  // GENERATE PREVIEW
  // ============================================================

  List<_PreviewSlot> _calculatePreview() {
    final preview = <_PreviewSlot>[];

    if (_selectedWeekdays.isEmpty ||
        !_price.isFinite ||
        _price < 0 ||
        ![60, 90, 120].contains(_slotDurationMinutes)) {
      return preview;
    }

    final start = _timeToMinutes(_startTime);
    var end = _timeToMinutes(_endTime);

    // Same start/end is invalid, not 24 hours.
    if (start == end) return preview;

    // End before start means the shift crosses midnight.
    if (end < start) {
      end += 24 * 60;
    }

    final now = DateTime.now();

    final today = DateTime(
      now.year,
      now.month,
      now.day,
    );

    final windowEnd = DateTime(
      today.year,
      today.month,
      today.day + 7,
    );

    for (int offset = 0; offset < 7; offset++) {
      final workingDay = DateTime(
        today.year,
        today.month,
        today.day + offset,
      );

      if (!_selectedWeekdays.contains(
        workingDay.weekday,
      )) {
        continue;
      }

      for (
      int minute = start;
      minute + _slotDurationMinutes <= end;
      minute += _slotDurationMinutes
      ) {
        // This correctly moves times after midnight
        // to the next calendar day.
        final slotStart = workingDay.add(
          Duration(minutes: minute),
        );

        final slotEnd = workingDay.add(
          Duration(
            minutes: minute + _slotDurationMinutes,
          ),
        );

        // Do not create slots in the past.
        if (!slotStart.isAfter(now)) {
          continue;
        }

        // Limit slot start dates to the next 7 days.
        if (!slotStart.isBefore(windowEnd)) {
          continue;
        }

        preview.add(
          _PreviewSlot(
            startAt: slotStart,
            endAt: slotEnd,
            price: _price,
          ),
        );
      }
    }

    preview.sort(
          (a, b) => a.startAt.compareTo(b.startAt),
    );

    return preview;
  }

  void _refreshPreview() {
    if (!mounted) return;

    final preview = _calculatePreview();

    setState(() {
      _previewSlots
        ..clear()
        ..addAll(preview);
    });
  }

  // ============================================================
  // EXISTING SLOT DATE / TIME
  // ============================================================

  DateTime? _slotStart(SlotModel slot) {
    final date = DateTime.tryParse(
      _dateKeyFromString(slot.slotDate),
    );

    if (date == null) return null;

    final parts =
    _normalizeTime(slot.startTime).split(':');

    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    return DateTime(
      date.year,
      date.month,
      date.day,
      hour,
      minute,
    );
  }

  DateTime? _slotEnd(SlotModel slot) {
    final start = _slotStart(slot);

    if (start == null) return null;

    final parts =
    _normalizeTime(slot.endTime).split(':');

    if (parts.length < 2) return null;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    var end = DateTime(
      start.year,
      start.month,
      start.day,
      hour,
      minute,
    );

    if (end == start) return null;

    if (end.isBefore(start)) {
      end = end.add(
        const Duration(days: 1),
      );
    }

    return end;
  }

  // ============================================================
  // CHECK OVERLAPPING TIME RANGES
  // ============================================================

  bool _overlaps(
      DateTime firstStart,
      DateTime firstEnd,
      DateTime secondStart,
      DateTime secondEnd,
      ) {
    return firstStart.isBefore(secondEnd) &&
        secondStart.isBefore(firstEnd);
  }

  // ============================================================
  // BUILD SLOT FOR API
  // ============================================================

  SlotModel _buildSlot(_PreviewSlot item) {
    return SlotModel(
      id: 0,
      pitchId: widget.stadiumId,
      slotDate: _dateKey(item.startAt),
      startTime: _timeText(item.startAt),
      endTime: _timeText(item.endAt),
      price: item.price,
      status: 'available',
      createdAt: null,
    );
  }

  // ============================================================
  // GENERATE AND SAVE SLOTS SAFELY
  // ============================================================

  Future<void> _generateSlots() async {
    if (_isSaving || _isLoadingSettings) {
      return;
    }

    if (_settingsLoadFailed) {
      _showMessage(
        'Reload working hours before generating slots.',
      );
      return;
    }

    if (_selectedWeekdays.isEmpty) {
      _showMessage(
        'Choose at least one working day.',
      );
      return;
    }

    if (_timeToMinutes(_startTime) ==
        _timeToMinutes(_endTime)) {
      _showMessage(
        'Start time and end time cannot be the same.',
      );
      return;
    }

    if (![60, 90, 120].contains(
      _slotDurationMinutes,
    ) ||
        !_price.isFinite ||
        _price < 0) {
      _showMessage(
        'Choose a valid duration and price.',
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    int createdCount = 0;
    int verifiedCount = 0;
    int existingCount = 0;
    int overlapCount = 0;

    bool settingsSaved = false;

    try {
      final slotProvider =
      context.read<SlotProvider>();

      final availabilityProvider =
      context.read<AvailabilityProvider>();

      // Always recalculate when the button is pressed.
      final preview = _calculatePreview();

      // Load latest slots before checking duplicates.
      await slotProvider.fetchStadiumSlots(
        widget.stadiumId,
      );

      if (!mounted) return;

      if (slotProvider.errorMessage != null ||
          slotProvider.stadiumId != widget.stadiumId) {
        throw Exception(
          'Could not load existing slots. Please retry.',
        );
      }

      // Keep both exact-start keys and time ranges.
      final exactKeys = <String>{};

      final occupied = <
          ({
          DateTime start,
          DateTime end,
          })
      >[];

      for (final existing in slotProvider.slots) {
        final existingStart = _slotStart(existing);
        final existingEnd = _slotEnd(existing);

        if (existingStart == null ||
            existingEnd == null) {
          throw Exception(
            'An existing slot has an invalid date or time.',
          );
        }

        final key =
            '${_dateKeyFromString(existing.slotDate)}|'
            '${_normalizeTime(existing.startTime)}';

        exactKeys.add(key);

        occupied.add(
          (
          start: existingStart,
          end: existingEnd,
          ),
        );
      }

      final toCreate = <SlotModel>[];

      for (final item in preview) {
        final slot = _buildSlot(item);

        final key =
            '${slot.slotDate}|${slot.startTime}';

        if (exactKeys.contains(key)) {
          existingCount++;
          continue;
        }

        final hasOverlap = occupied.any(
              (range) => _overlaps(
            item.startAt,
            item.endAt,
            range.start,
            range.end,
          ),
        );

        if (hasOverlap) {
          overlapCount++;
          continue;
        }

        exactKeys.add(key);

        occupied.add(
          (
          start: item.startAt,
          end: item.endAt,
          ),
        );

        toCreate.add(slot);
      }

      if (!mounted) return;

      // Confirmation before making any changes.
      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              'Review Working Hours & Slots',
            ),
            content: SingleChildScrollView(
              child: Text(
                'Stadium #${widget.stadiumId}\n'
                    'New slots: ${toCreate.length}\n'
                    'Already existing: $existingCount\n'
                    'Skipped overlaps: $overlapCount\n'
                    'Default price: '
                    '${_price.toStringAsFixed(2)} EGP\n\n'
                    'Save weekly settings and generate '
                    'only new slots?\n\n'
                    'Existing slots and bookings will '
                    'not be modified.\n\n'
                    'Slots are created one by one. '
                    'If interrupted, some may already '
                    'have been saved.',
              ),
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
                child: Text(
                  toCreate.isEmpty
                      ? 'Save Hours Only'
                      : 'Save & Generate',
                ),
              ),
            ],
          );
        },
      );

      if (!mounted || confirmed != true) {
        return;
      }

      // Save weekly settings first.
      final settings = AvailabilitySettingsModel(
        pitchId: widget.stadiumId,
        weeklyDays:
        _selectedWeekdays.toList()..sort(),
        startTime:
        '${_startTime.hour.toString().padLeft(2, '0')}:'
            '${_startTime.minute.toString().padLeft(2, '0')}',
        endTime:
        '${_endTime.hour.toString().padLeft(2, '0')}:'
            '${_endTime.minute.toString().padLeft(2, '0')}',
        slotDuration: _slotDurationMinutes,
        defaultPrice: _price,
      );

      final saved =
      await availabilityProvider.saveAvailability(
        widget.stadiumId,
        settings,
      );

      if (!mounted) return;

      if (saved == null) {
        throw Exception(
          availabilityProvider.errorMessage ??
              'Failed to save weekly settings.',
        );
      }

      settingsSaved = true;

      // Create only the slots that passed preflight.
      for (final slot in toCreate) {
        if (!mounted) return;

        final created = await slotProvider.createSlot(
          widget.stadiumId,
          slot,
        );

        if (created != null) {
          createdCount++;
          continue;
        }

        // If a request failed after an insert,
        // check the server before retrying.
        final originalError =
            slotProvider.errorMessage ??
                'Unknown save error';

        await slotProvider.fetchStadiumSlots(
          widget.stadiumId,
        );

        if (!mounted) return;

        if (slotProvider.errorMessage != null ||
            slotProvider.stadiumId != widget.stadiumId) {
          throw Exception(
            'Stopped at ${slot.slotDate} '
                '${slot.startTime}: $originalError. '
                'Could not verify whether it saved.',
          );
        }

        final exists = slotProvider.slots.any(
              (entry) =>
          _dateKeyFromString(entry.slotDate) ==
              slot.slotDate &&
              _normalizeTime(entry.startTime) ==
                  slot.startTime &&
              _normalizeTime(entry.endTime) ==
                  slot.endTime,
        );

        if (exists) {
          verifiedCount++;
          continue;
        }

        throw Exception(
          'Stopped at ${slot.slotDate} '
              '${slot.startTime}: $originalError',
        );
      }

      // Final refresh.
      await slotProvider.fetchStadiumSlots(
        widget.stadiumId,
      );

      if (!mounted) return;

      if (slotProvider.errorMessage != null) {
        _showMessage(
          'Saved $createdCount slots, but the '
              'final refresh failed. Check calendar.',
        );
      } else {
        _showMessage(
          'Schedule saved. '
              'Created: $createdCount. '
              'Verified after errors: $verifiedCount. '
              'Already existed: $existingCount. '
              'Skipped overlaps: $overlapCount.',
          success: true,
        );
      }
    } catch (error) {
      if (!mounted) return;

      final reason = error.toString().replaceFirst(
        'Exception: ',
        '',
      );

      _showMessage(
        '$reason\n'
            'Created: $createdCount. '
            '${settingsSaved ? 'Weekly settings saved. ' : ''}'
            'Check calendar before retrying.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // ============================================================
  // USER MESSAGES
  // ============================================================

  void _showMessage(
      String message, {
        bool success = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 7),
      ),
    );
  }

  // ============================================================
  // SECTION CARD
  // ============================================================

  Widget _sectionCard({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.06),
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 6),
            color: Color(0x10000000),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: AppColors.secondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkNavy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // ============================================================
  // TIME TILE
  // ============================================================

  Widget _timeTile({
    required String title,
    required TimeOfDay value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap:
        (_isSaving || _isLoadingSettings)
            ? null
            : onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xffF7F9FC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.black.withValues(alpha: 0.07),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _formatTimeOfDay(value),
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // WEEKDAY TILE
  // ============================================================

  Widget _weekdayTile(int weekday) {
    final selected =
    _selectedWeekdays.contains(weekday);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _toggleWeekday(weekday),
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 12,
            horizontal: 5,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.secondary
                : const Color(0xffF7F9FC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.secondary
                  : Colors.black.withValues(alpha: 0.07),
            ),
          ),
          child: Column(
            children: [
              Icon(
                selected
                    ? Icons.check_circle
                    : Icons.circle_outlined,
                size: 19,
                color:
                selected ? Colors.white : Colors.grey,
              ),
              const SizedBox(height: 6),
              Text(
                _weekdayName(weekday).substring(0, 3),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? Colors.white
                      : AppColors.darkNavy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DURATION TILE
  // ============================================================

  Widget _durationTile(int minutes) {
    final selected =
        _slotDurationMinutes == minutes;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: (_isSaving || _isLoadingSettings)
            ? null
            : () {
          setState(() {
            _slotDurationMinutes = minutes;
          });
          _refreshPreview();
        },
        child: AnimatedContainer(
          duration: const Duration(
            milliseconds: 180,
          ),
          padding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.secondary
                : const Color(0xffF7F9FC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? AppColors.secondary
                  : Colors.black.withValues(alpha: 0.07),
            ),
          ),
          child: Column(
            children: [
              Text(
                '$minutes',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: selected
                      ? Colors.white
                      : AppColors.darkNavy,
                ),
              ),
              Text(
                'min',
                style: TextStyle(
                  fontSize: 12,
                  color: selected
                      ? Colors.white
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PREVIEW ITEM
  // ============================================================

  Widget _previewItem(_PreviewSlot item) {
    final start = TimeOfDay.fromDateTime(
      item.startAt,
    );

    final end = TimeOfDay.fromDateTime(
      item.endAt,
    );

    final overnight = _dateKey(item.startAt) !=
        _dateKey(item.endAt);

    final nextDayText =
    overnight ? ' (+1 day)' : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: const Color(0xffF7F9FC),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Color(0xff16A34A),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${DateFormat('EEE, d MMM').format(item.startAt)}  •  '
                  '${_formatTimeOfDay(start)} → '
                  '${_formatTimeOfDay(end)}$nextDayText',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            '${item.price.toStringAsFixed(0)} EGP',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.darkNavy,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.darkNavy,
        elevation: 0,
        title: const Text(
          'Manage Availability',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Calendar',
            icon: const Icon(
              Icons.calendar_month_rounded,
            ),
            onPressed:
            (_isSaving || _isLoadingSettings)
                ? null
                : _openCalendar,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            30,
          ),
          child: Column(
            children: [
              if (_settingsLoadFailed)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 12,
                  ),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(
                        Icons.wifi_off_rounded,
                        color: Colors.red,
                      ),
                      title: const Text(
                        'Could not load saved working hours',
                      ),
                      subtitle: const Text(
                        'Retry before generating slots.',
                      ),
                      trailing: TextButton(
                        onPressed: _isLoadingSettings
                            ? null
                            : _loadAvailability,
                        child: const Text('Retry'),
                      ),
                    ),
                  ),
                ),

              // Weekly days
              _sectionCard(
                title: 'Weekly Schedule',
                icon: Icons.date_range_rounded,
                child: Column(
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Choose the days this stadium is available.',
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        _weekdayTile(DateTime.saturday),
                        const SizedBox(width: 6),
                        _weekdayTile(DateTime.sunday),
                        const SizedBox(width: 6),
                        _weekdayTile(DateTime.monday),
                        const SizedBox(width: 6),
                        _weekdayTile(DateTime.tuesday),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _weekdayTile(DateTime.wednesday),
                        const SizedBox(width: 6),
                        _weekdayTile(DateTime.thursday),
                        const SizedBox(width: 6),
                        _weekdayTile(DateTime.friday),
                        const SizedBox(width: 6),
                        const Spacer(),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Working hours
              _sectionCard(
                title: 'Working Hours',
                icon: Icons.access_time_rounded,
                child: Row(
                  children: [
                    _timeTile(
                      title: 'From',
                      value: _startTime,
                      onTap: _pickStartTime,
                    ),
                    const SizedBox(width: 10),
                    _timeTile(
                      title: 'To',
                      value: _endTime,
                      onTap: _pickEndTime,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Slot duration
              _sectionCard(
                title: 'Slot Duration',
                icon: Icons.timer_outlined,
                child: Row(
                  children: [
                    _durationTile(60),
                    const SizedBox(width: 8),
                    _durationTile(90),
                    const SizedBox(width: 8),
                    _durationTile(120),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Default price
              _sectionCard(
                title: 'Default Price',
                icon: Icons.payments_outlined,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap:
                  (_isSaving || _isLoadingSettings)
                      ? null
                      : _editPrice,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xffF7F9FC),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${_price.toStringAsFixed(0)} EGP',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.darkNavy,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.edit_outlined,
                          color: AppColors.secondary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Preview
              _sectionCard(
                title: 'Preview — Next 7 Days',
                icon: Icons.preview_rounded,
                child: Column(
                  children: [
                    if (_previewSlots.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: 20,
                        ),
                        child: Text(
                          'No upcoming slots in the selected schedule.',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      )
                    else
                      ..._previewSlots
                          .take(12)
                          .map(_previewItem),

                    if (_previewSlots.length > 12)
                      Align(
                        alignment: Alignment.center,
                        child: Text(
                          '+ ${_previewSlots.length - 12} more slots',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // Generate button
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isSaving ||
                      _isLoadingSettings ||
                      _settingsLoadFailed
                      ? null
                      : _generateSlots,
                  icon: _isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons.auto_awesome,
                  ),
                  label: Text(
                    _isSaving
                        ? 'Checking & Saving...'
                        : 'Review & Generate Slots',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Calendar button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed:
                  (_isSaving || _isLoadingSettings)
                      ? null
                      : _openCalendar,
                  icon: const Icon(
                    Icons.calendar_month_rounded,
                  ),
                  label: const Text(
                    'Open Calendar & Manual Slots',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCalendar() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AvailabilityCalendarScreen(
          stadiumId: widget.stadiumId,
        ),
      ),
    );
  }
}

class _PreviewSlot {
  final DateTime startAt;
  final DateTime endAt;
  final double price;

  const _PreviewSlot({
    required this.startAt,
    required this.endAt,
    required this.price,
  });
}
