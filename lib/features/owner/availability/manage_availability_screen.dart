import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:e7m/core/theme/app_colors.dart';
import 'data/models/slot_model.dart';
import 'data/providers/slot_provider.dart';
import 'data/models/availability_settings_model.dart';
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

  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 0, minute: 0);
  int _slotDurationMinutes = 90;
  double _price = 300;
  bool _isSaving = false;

  final List<_PreviewSlot> _previewSlots = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _loadAvailability();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadAvailability() async {
    final provider = context.read<AvailabilityProvider>();

    await provider.fetchAvailability(
      widget.stadiumId,
    );

    if (!mounted) return;

    final settings = provider.settings;

    if (settings != null) {
      setState(() {
        _selectedWeekdays
          ..clear()
          ..addAll(settings.weeklyDays);

        _startTime = _parseTime(
          settings.startTime,
        );

        _endTime = _parseTime(
          settings.endTime,
        );

        _slotDurationMinutes =
            settings.slotDuration;

        _price = settings.defaultPrice;

      });
    }

    _refreshPreview();
  }

  TimeOfDay _parseTime(String value) {
    final parts = value.split(':');

    if (parts.length < 2) {
      return const TimeOfDay(
        hour: 0,
        minute: 0,
      );
    }

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return TimeOfDay(
      hour: hour,
      minute: minute,
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  int _timeToMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
  }

  TimeOfDay _minutesToTime(int minutes) {
    final normalized = minutes % (24 * 60);
    return TimeOfDay(
      hour: normalized ~/ 60,
      minute: normalized % 60,
    );
  }

  String _dateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
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

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );

    if (picked == null) return;

    setState(() {
      _startTime = picked;
    });

    _refreshPreview();
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );

    if (picked == null) return;

    setState(() {
      _endTime = picked;
    });

    _refreshPreview();
  }

  Future<void> _editPrice() async {
    String input = _price.toStringAsFixed(
      _price.truncateToDouble() == _price ? 0 : 2,
    );

    // Do NOT use a TextEditingController here.
    // The dialog owns its TextField and Flutter can safely dispose the
    // dialog without us disposing a controller while the route is closing.
    final value = await showDialog<double>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Slot Price'),
          content: TextFormField(
            initialValue: input,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
            onChanged: (value) {
              input = value;
            },
            decoration: const InputDecoration(
              labelText: 'Price',
              suffixText: 'EGP',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final parsed = double.tryParse(input.trim());

                if (parsed == null || parsed < 0) {
                  return;
                }

                Navigator.of(dialogContext).pop(parsed);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (!mounted || value == null) return;

    setState(() {
      _price = value;
    });

    _refreshPreview();
  }

  void _toggleWeekday(int weekday) {
    setState(() {
      if (_selectedWeekdays.contains(weekday)) {
        _selectedWeekdays.remove(weekday);
      } else {
        _selectedWeekdays.add(weekday);
      }
    });

    _refreshPreview();
  }

  List<_PreviewSlot> _calculatePreview() {
    final preview = <_PreviewSlot>[];

    if (_selectedWeekdays.isEmpty) {
      return preview;
    }

    final start = _timeToMinutes(_startTime);
    var end = _timeToMinutes(_endTime);

    // 12:00 PM -> 12:00 AM means midnight of the next day.
    if (end <= start) {
      end += 24 * 60;
    }

    if (end <= start || _slotDurationMinutes <= 0) {
      return preview;
    }

    final today = DateTime.now();

    for (int offset = 0; offset < 7; offset++) {
      final date = DateTime(
        today.year,
        today.month,
        today.day + offset,
      );

      if (!_selectedWeekdays.contains(date.weekday)) {
        continue;
      }

      var cursor = start;

      while (cursor < end) {
        final slotEnd = cursor + _slotDurationMinutes;

        if (slotEnd > end) {
          break;
        }

        preview.add(
          _PreviewSlot(
            date: date,
            startMinutes: cursor,
            endMinutes: slotEnd,
            price: _price,
          ),
        );

        cursor = slotEnd;
      }
    }

    return preview;
  }

  void _refreshPreview() {
    final preview = _calculatePreview();

    if (!mounted) return;

    setState(() {
      _previewSlots
        ..clear()
        ..addAll(preview);
    });
  }

  Future<void> _generateSlots() async {
    if (_isSaving) return;

    if (_selectedWeekdays.isEmpty) {
      _showMessage(
        'Choose at least one working day.',
      );
      return;
    }

    final start = _timeToMinutes(_startTime);
    var end = _timeToMinutes(_endTime);

    if (end <= start) {
      end += 24 * 60;
    }

    if (end <= start) {
      _showMessage(
        'End time must be after start time.',
      );
      return;
    }

    if (_price < 0) {
      _showMessage(
        'Enter a valid price.',
      );
      return;
    }

    final previewSlots = _calculatePreview();

    if (previewSlots.isEmpty) {
      _showMessage(
        'No valid slots can be generated with the selected settings.',
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _previewSlots
        ..clear()
        ..addAll(previewSlots);
      _isSaving = true;
    });

    try {
      final availabilityProvider =
      context.read<AvailabilityProvider>();

      final availabilitySettings =
      AvailabilitySettingsModel(
        pitchId: widget.stadiumId,
        weeklyDays: _selectedWeekdays.toList()..sort(),
        startTime:
        '${_startTime.hour.toString().padLeft(2, '0')}:'
            '${_startTime.minute.toString().padLeft(2, '0')}',
        endTime:
        '${_endTime.hour.toString().padLeft(2, '0')}:'
            '${_endTime.minute.toString().padLeft(2, '0')}',
        slotDuration: _slotDurationMinutes,
        defaultPrice: _price,
      );

      final savedSettings =
      await availabilityProvider.saveAvailability(
        widget.stadiumId,
        availabilitySettings,
      );

      if (savedSettings == null) {
        throw Exception(
          availabilityProvider.errorMessage ??
              'Failed to save availability settings.',
        );
      }

      final provider =
      context.read<SlotProvider>();

      await provider.fetchStadiumSlots(widget.stadiumId);

      // Backend considers a slot duplicate by:
      // SAME DATE + SAME START TIME.
      //
      // Do not include endTime in this key because a server time such as
      // 12:00:00 must still match a generated time such as 12:00.
      final existingKeys = provider.slots
          .map(
            (slot) =>
        '${_dateKeyFromString(slot.slotDate)}|'
            '${_normalizeTime(slot.startTime)}',
      )
          .toSet();

      int createdCount = 0;
      int skippedCount = 0;

      for (final item in previewSlots) {
        final startTime = _minutesToTime(item.startMinutes);
        final endTime = _minutesToTime(item.endMinutes);

        final startText =
            '${startTime.hour.toString().padLeft(2, '0')}:'
            '${startTime.minute.toString().padLeft(2, '0')}';

        final endText =
            '${endTime.hour.toString().padLeft(2, '0')}:'
            '${endTime.minute.toString().padLeft(2, '0')}';

        // Duplicate rule: date + start time only.
        final key =
            '${_dateKey(item.date)}|$startText';

        if (existingKeys.contains(key)) {
          skippedCount++;
          continue;
        }

        final slot = SlotModel(
          id: 0,
          pitchId: widget.stadiumId,
          slotDate: _dateKey(item.date),
          startTime: startText,
          endTime: endText,
          price: item.price,
          status: 'available',
          createdAt: null,
        );

        // Log the exact slot being sent. This makes any backend failure
        // traceable to one date/time instead of a generic error.
        debugPrint(
          'GENERATE SLOT -> '
              'pitch=${widget.stadiumId}, '
              'date=${slot.slotDate}, '
              'start=${slot.startTime}, '
              'end=${slot.endTime}, '
              'price=${slot.price}',
        );

        final created = await provider.createSlot(
          widget.stadiumId,
          slot,
        );

        if (created != null) {
          createdCount++;
          existingKeys.add(key);
        } else {
          /*
           * Some backend errors are returned only as:
           * "Failed to create pitch slot".
           *
           * If the server rejected the request because the slot already
           * exists (or another request created it at the same moment),
           * refresh from the server before treating it as a real failure.
           */
          await provider.fetchStadiumSlots(widget.stadiumId);

          final existsAfterFailure = provider.slots.any(
                (savedSlot) {
              final savedKey =
                  '${_dateKeyFromString(savedSlot.slotDate)}|'
                  '${_normalizeTime(savedSlot.startTime)}';

              return savedKey == key;
            },
          );

          if (existsAfterFailure) {
            skippedCount++;
            existingKeys.add(key);
            continue;
          }

          throw Exception(
            provider.errorMessage ??
                'Failed to create pitch slot '
                    '($key).',
          );
        }
      }

      if (!mounted) return;

      await provider.fetchStadiumSlots(
        widget.stadiumId,
      );

      _showMessage(
        'Created $createdCount slots'
            '${skippedCount > 0 ? ' • Skipped $skippedCount existing slots' : ''}.',
        success: true,
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        e.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String _dateKeyFromString(String value) {
    if (value.length >= 10) {
      return value.substring(0, 10);
    }
    return value;
  }

  String _normalizeTime(String value) {
    final parts = value.split(':');

    if (parts.length >= 2) {
      return '${parts[0].padLeft(2, '0')}:'
          '${parts[1].padLeft(2, '0')}';
    }

    return value;
  }

  void _showMessage(
      String message, {
        bool success = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? Colors.green : Colors.red,
        content: Text(message),
      ),
    );
  }

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

  Widget _timeTile({
    required String title,
    required TimeOfDay value,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
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

  Widget _weekdayTile(int weekday) {
    final selected = _selectedWeekdays.contains(weekday);

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _toggleWeekday(weekday),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
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
                color: selected
                    ? Colors.white
                    : Colors.grey,
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

  Widget _durationTile(int minutes) {
    final selected = _slotDurationMinutes == minutes;

    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          setState(() {
            _slotDurationMinutes = minutes;
          });
          _refreshPreview();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16),
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
                  color: selected
                      ? Colors.white
                      : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _previewItem(_PreviewSlot item) {
    final start = _minutesToTime(item.startMinutes);
    final end = _minutesToTime(item.endMinutes);

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
              '${DateFormat('EEE, d MMM').format(item.date)}  •  '
                  '${_formatTimeOfDay(start)} → '
                  '${_formatTimeOfDay(end)}',
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
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      AvailabilityCalendarScreen(
                        stadiumId: widget.stadiumId,
                      ),
                ),
              );
            },
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
              _sectionCard(
                title: 'Default Price',
                icon: Icons.payments_outlined,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: _editPrice,
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
                          'Set your schedule to preview the slots.',
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
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed:
                  _isSaving ? null : _generateSlots,
                  icon: _isSaving
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : const Icon(
                    Icons.auto_awesome,
                  ),
                  label: Text(
                    _isSaving
                        ? 'Creating Slots...'
                        : 'Generate & Save Slots',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            AvailabilityCalendarScreen(
                              stadiumId: widget.stadiumId,
                            ),
                      ),
                    );
                  },
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
}

class _PreviewSlot {
  final DateTime date;
  final int startMinutes;
  final int endMinutes;
  final double price;

  const _PreviewSlot({
    required this.date,
    required this.startMinutes,
    required this.endMinutes,
    required this.price,
  });
}