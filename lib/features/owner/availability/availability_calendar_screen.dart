import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:e7m/core/theme/app_colors.dart';
import 'package:e7m/shared/localization/language_provider.dart';

import 'data/models/slot_model.dart';
import 'data/providers/slot_provider.dart';

class AvailabilityCalendarScreen extends StatefulWidget {
  final int stadiumId;

  const AvailabilityCalendarScreen({
    super.key,
    required this.stadiumId,
  });

  @override
  State<AvailabilityCalendarScreen> createState() =>
      _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState
    extends State<AvailabilityCalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<SlotProvider>().fetchStadiumSlots(
        widget.stadiumId,
      );
    });
  }

  // ============================================================
  // DATE HELPERS
  // ============================================================

  DateTime _normalizeDate(DateTime date) {
    return DateTime(
      date.year,
      date.month,
      date.day,
    );
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  DateTime? _parseSlotDate(String value) {
    final raw = value.trim();

    if (raw.isEmpty || raw.length < 10) {
      return null;
    }

    final datePart = raw.substring(0, 10);
    final parts = datePart.split('-');

    if (parts.length != 3) {
      return null;
    }

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);

    if (year == null || month == null || day == null) {
      return null;
    }

    try {
      final parsed = DateTime(
        year,
        month,
        day,
      );

      if (parsed.year != year ||
          parsed.month != month ||
          parsed.day != day) {
        return null;
      }

      return parsed;
    } catch (_) {
      return null;
    }
  }

  bool _isSameCalendarDate(
      DateTime first,
      DateTime second,
      ) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  bool _isSlotOnSelectedDay(SlotModel slot) {
    final slotDate = _parseSlotDate(slot.slotDate);
    final selectedDay = _selectedDay;

    if (slotDate == null || selectedDay == null) {
      return false;
    }

    return _isSameCalendarDate(
      slotDate,
      selectedDay,
    );
  }

  List<SlotModel> _getSelectedDaySlots(
      List<SlotModel> slots,
      ) {
    final selectedSlots = slots
        .where(_isSlotOnSelectedDay)
        .toList();

    selectedSlots.sort(
          (a, b) => a.startTime.compareTo(
        b.startTime,
      ),
    );

    return selectedSlots;
  }

  // ============================================================
  // CALENDAR EVENTS
  // ============================================================

  List<SlotModel> _getDaySlots(
      DateTime day,
      List<SlotModel> slots,
      ) {
    return slots.where((slot) {
      final slotDate = _parseSlotDate(
        slot.slotDate,
      );

      if (slotDate == null) {
        return false;
      }

      return _isSameCalendarDate(
        slotDate,
        day,
      );
    }).toList();
  }

  bool _dayHasSlots(
      DateTime day,
      List<SlotModel> slots,
      ) {
    return _getDaySlots(
      day,
      slots,
    ).isNotEmpty;
  }

  // ============================================================
  // TIME HELPERS
  // ============================================================

  String _formatTime(String value) {
    if (value.isEmpty) {
      return '--';
    }

    final parts = value.split(':');

    if (parts.length < 2) {
      return value;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return value;
    }

    final date = DateTime(
      2000,
      1,
      1,
      hour,
      minute,
    );

    return DateFormat(
      'hh:mm a',
    ).format(date);
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour =
    time.hourOfPeriod == 0
        ? 12
        : time.hourOfPeriod;

    final minute = time.minute
        .toString()
        .padLeft(2, '0');

    final period =
    time.period == DayPeriod.am
        ? 'AM'
        : 'PM';

    return '$hour:$minute $period';
  }

  String? _normalizeTimeText(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return null;
    }

    try {
      final parsed = DateFormat(
        'hh:mm a',
      ).parseStrict(
        trimmed.toUpperCase(),
      );

      return '${parsed.hour.toString().padLeft(2, '0')}:'
          '${parsed.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      // Continue with 24-hour format.
    }

    final parts = trimmed.split(':');

    if (parts.length == 2) {
      final hour = int.tryParse(parts[0]);
      final minute = int.tryParse(parts[1]);

      if (hour != null &&
          minute != null &&
          hour >= 0 &&
          hour <= 23 &&
          minute >= 0 &&
          minute <= 59) {
        return '${hour.toString().padLeft(2, '0')}:'
            '${minute.toString().padLeft(2, '0')}';
      }
    }

    return null;
  }

  int _timeToMinutes(String time) {
    final parts = time.split(':');

    if (parts.length < 2) {
      return 0;
    }

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return hour * 60 + minute;
  }

  TimeOfDay _timeOfDayFromString(String value) {
    final normalized = value.trim();
    final parts = normalized.split(':');

    if (parts.length < 2) {
      return TimeOfDay.now();
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return TimeOfDay.now();
    }

    return TimeOfDay(
      hour: hour,
      minute: minute,
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  bool _isAvailableStatus(String status) {
    final normalized =
    status.trim().toLowerCase();

    return normalized == 'available' ||
        normalized == 'open' ||
        normalized == 'active';
  }

  // ============================================================
  // CREATE SLOT
  // ============================================================

  Future<void> _showCreateSlotDialog() async {
    if (!mounted) return;

    final languageProvider = context.read<LanguageProvider>();
    final slotProvider = context.read<SlotProvider>();
    final selectedDate = _normalizeDate(
      _selectedDay ?? DateTime.now(),
    );

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _CreateSlotDialog(
          stadiumId: widget.stadiumId,
          selectedDate: selectedDate,
          slotProvider: slotProvider,
          languageProvider: languageProvider,
        );
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.secondary,
          content: Text(
            languageProvider.translate(
              'slot_saved_successfully',
            ),
          ),
        ),
      );
    }
  }

  // ============================================================
  // EDIT SLOT
  // ============================================================

  Future<void> _showEditSlotDialog(
      SlotModel slot,
      ) async {
    if (!mounted) return;

    final languageProvider = context.read<LanguageProvider>();
    final slotProvider = context.read<SlotProvider>();

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return _EditSlotDialog(
          stadiumId: widget.stadiumId,
          slot: slot,
          slotProvider: slotProvider,
          languageProvider: languageProvider,
        );
      },
    );

    if (result == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.secondary,
          content: Text(
            languageProvider.translate(
              'slot_updated_successfully',
            ),
          ),
        ),
      );
    }
  }

  // ============================================================
  // DELETE SLOT
  // ============================================================

  Future<void> _confirmDeleteSlot(
      SlotModel slot,
      ) async {
    if (!mounted) return;

    final languageProvider =
    context.read<LanguageProvider>();

    final screenContext = context;

    final confirmed =
    await showDialog<bool>(
      context: screenContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            languageProvider.translate(
              'delete_slot',
            ),
          ),
          content: Text(
            languageProvider.translate(
              'delete_slot_confirmation',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: Text(
                languageProvider.translate(
                  'cancel',
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: Text(
                languageProvider.translate(
                  'delete',
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !screenContext.mounted) {
      return;
    }

    final provider =
    screenContext.read<SlotProvider>();

    final success =
    await provider.deleteSlot(
      widget.stadiumId,
      slot.id,
    );

    if (!screenContext.mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(
        screenContext,
      ).showSnackBar(
        SnackBar(
          backgroundColor:
          AppColors.secondary,
          content: Text(
            languageProvider.translate(
              'slot_deleted_successfully',
            ),
          ),
        ),
      );
    }
  }

  // ============================================================
  // CHANGE SLOT STATUS
  // ============================================================

  Future<void> _changeSlotStatus(SlotModel slot) async {
    if (!mounted) return;

    final languageProvider = context.read<LanguageProvider>();
    final screenContext = context;

    // Backend accepts ONLY:
    // available / blocked
    final currentStatus = slot.status.trim().toLowerCase();

    final newStatus =
    currentStatus == 'available' ||
        currentStatus == 'open' ||
        currentStatus == 'active'
        ? 'blocked'
        : 'available';

    final isBlocking = newStatus == 'blocked';

    final confirmed = await showDialog<bool>(
      context: screenContext,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            languageProvider.translate('slot_status'),
          ),
          content: Text(
            isBlocking
                ? 'Are you sure you want to block this slot?'
                : 'Are you sure you want to make this slot available?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                languageProvider.translate('cancel'),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                isBlocking ? Colors.red : AppColors.secondary,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(
                isBlocking ? 'Block' : 'Make Available',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !screenContext.mounted) {
      return;
    }

    final provider = screenContext.read<SlotProvider>();

    final updatedSlot = await provider.updateSlotStatus(
      widget.stadiumId,
      slot.id,
      newStatus,
    );

    if (!screenContext.mounted) return;

    if (updatedSlot != null) {
      ScaffoldMessenger.of(screenContext).showSnackBar(
        SnackBar(
          backgroundColor: isBlocking
              ? Colors.red
              : AppColors.secondary,
          content: Text(
            isBlocking
                ? 'Slot blocked successfully'
                : 'Slot is available now',
          ),
        ),
      );
    }
  }

  // ============================================================
  // SLOT ACTIONS
  // ============================================================

  Future<void> _showSlotActions(
      SlotModel slot,
      ) async {
    if (!mounted) return;

    final languageProvider =
    context.read<LanguageProvider>();

    final screenContext = context;

    await showModalBottomSheet<void>(
      context: screenContext,
      showDragHandle: true,
      shape:
      const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding:
            const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              24,
            ),
            child: Column(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                ListTile(
                  leading:
                  const CircleAvatar(
                    child: Icon(
                      Icons.access_time,
                    ),
                  ),
                  title: Text(
                    '${_formatTime(slot.startTime)} - '
                        '${_formatTime(slot.endTime)}',
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${slot.price.toStringAsFixed(2)} '
                        '${languageProvider.translate('egp')}',
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.edit_outlined,
                  ),
                  title: Text(
                    languageProvider
                        .translate(
                      'edit_slot',
                    ),
                  ),
                  onTap: () {
                    Navigator.of(
                      sheetContext,
                    ).pop();

                    _showEditSlotDialog(
                      slot,
                    );
                  },
                ),
                ListTile(
                  leading: Icon(
                    _isAvailableStatus(slot.status)
                        ? Icons.block_outlined
                        : Icons.check_circle_outline,
                    color: _isAvailableStatus(slot.status)
                        ? Colors.red
                        : AppColors.secondary,
                  ),
                  title: Text(
                    languageProvider.translate('slot_status'),
                  ),
                  subtitle: Text(
                    _isAvailableStatus(slot.status)
                        ? 'Block slot'
                        : 'Make available',
                  ),
                  onTap: () async {
                    Navigator.of(sheetContext).pop();
                    await _changeSlotStatus(slot);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  title: Text(
                    languageProvider
                        .translate(
                      'delete_slot',
                    ),
                    style:
                    const TextStyle(
                      color: Colors.red,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(
                      sheetContext,
                    ).pop();

                    _confirmDeleteSlot(
                      slot,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final languageProvider =
    context.watch<LanguageProvider>();

    final slotProvider =
    context.watch<SlotProvider>();

    final allSlots =
        slotProvider.slots;

    final selectedDaySlots =
    _getSelectedDaySlots(
      allSlots,
    );

    final availableCount =
        selectedDaySlots
            .where(
              (slot) =>
              _isAvailableStatus(
                slot.status,
              ),
        )
            .length;

    final locale = 'en';

    final selectedDate =
        _selectedDay ?? DateTime.now();

    final formattedDate =
    DateFormat(
      'EEEE, d MMMM yyyy',
      locale,
    ).format(selectedDate);

    final today =
    _normalizeDate(
      DateTime.now(),
    );

    return Scaffold(
      backgroundColor:
      AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          languageProvider.translate(
            'availability_calendar',
          ),
          style: const TextStyle(
            color: AppColors.darkNavy,
            fontWeight:
            FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip:
            languageProvider.translate(
              'refresh',
            ),
            icon:
            const Icon(Icons.refresh),
            onPressed:
            slotProvider.isLoading
                ? null
                : () {
              context
                  .read<
                  SlotProvider>()
                  .fetchStadiumSlots(
                widget.stadiumId,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child:
        slotProvider.isLoading &&
            allSlots.isEmpty
            ? const Center(
          child:
          CircularProgressIndicator(),
        )
            : RefreshIndicator(
          onRefresh: () {
            return context
                .read<
                SlotProvider>()
                .fetchStadiumSlots(
              widget.stadiumId,
            );
          },
          child:
          SingleChildScrollView(
            physics:
            const AlwaysScrollableScrollPhysics(),
            padding:
            const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              100,
            ),
            child: Column(
              children: [
                if (slotProvider
                    .hasError)
                  Container(
                    width:
                    double.infinity,
                    margin:
                    const EdgeInsets.only(
                      bottom: 16,
                    ),
                    padding:
                    const EdgeInsets.all(
                      14,
                    ),
                    decoration:
                    BoxDecoration(
                      color: Colors.red
                          .withValues(
                        alpha: 0.08,
                      ),
                      borderRadius:
                      BorderRadius
                          .circular(
                        14,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons
                              .error_outline,
                          color:
                          Colors.red,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            slotProvider
                                .errorMessage ??
                                languageProvider
                                    .translate(
                                  'something_went_wrong',
                                ),
                            style:
                            const TextStyle(
                              color:
                              Colors.red,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                          slotProvider
                              .clearError,
                          icon:
                          const Icon(
                            Icons.close,
                            color:
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),

                Container(
                  width:
                  double.infinity,
                  padding:
                  const EdgeInsets.all(
                    16,
                  ),
                  decoration:
                  BoxDecoration(
                    color: AppColors
                        .secondary
                        .withValues(
                      alpha: 0.08,
                    ),
                    borderRadius:
                    BorderRadius
                        .circular(
                      18,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor:
                        AppColors
                            .secondary,
                        child:
                        const Icon(
                          Icons
                              .event_available,
                          color:
                          Colors.white,
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            Text(
                              languageProvider
                                  .translate(
                                'today_availability',
                              ),
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              '$formattedDate\n'
                                  '$availableCount '
                                  '${languageProvider.translate('available')}',
                              style:
                              const TextStyle(
                                color:
                                Colors.grey,
                                height:
                                1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Card(
                  margin:
                  const EdgeInsets
                      .symmetric(
                    vertical: 16,
                  ),
                  elevation: 3,
                  shadowColor:
                  Colors.black12,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      20,
                    ),
                  ),
                  child:
                  TableCalendar<
                      SlotModel>(
                    locale:
                    locale,
                    firstDay:
                    DateTime(
                      2024,
                    ),
                    lastDay:
                    DateTime(
                      2035,
                    ),
                    focusedDay:
                    _focusedDay,
                    rowHeight: 44,
                    daysOfWeekHeight:
                    30,
                    availableGestures:
                    AvailableGestures
                        .horizontalSwipe,
                    enabledDayPredicate:
                        (day) {
                      return !day
                          .isBefore(
                        today,
                      );
                    },
                    selectedDayPredicate:
                        (day) {
                      return isSameDay(
                        _selectedDay,
                        day,
                      );
                    },
                    eventLoader:
                        (day) {
                      return _getDaySlots(
                        day,
                        allSlots,
                      );
                    },
                    onDaySelected:
                        (
                        selected,
                        focused,
                        ) {
                      setState(() {
                        _selectedDay =
                            _normalizeDate(
                              selected,
                            );
                        _focusedDay =
                            _normalizeDate(
                              focused,
                            );
                      });
                    },
                    onPageChanged:
                        (focused) {
                      setState(() {
                        _focusedDay =
                            _normalizeDate(
                              focused,
                            );
                      });
                    },
                    headerStyle:
                    const HeaderStyle(
                      titleCentered:
                      true,
                      formatButtonVisible:
                      false,
                      leftChevronIcon:
                      Icon(
                        Icons
                            .chevron_left,
                        color:
                        AppColors
                            .darkNavy,
                      ),
                      rightChevronIcon:
                      Icon(
                        Icons
                            .chevron_right,
                        color:
                        AppColors
                            .darkNavy,
                      ),
                      titleTextStyle:
                      TextStyle(
                        fontWeight:
                        FontWeight.bold,
                        color:
                        AppColors
                            .darkNavy,
                        fontSize: 16,
                      ),
                    ),
                    calendarStyle:
                    CalendarStyle(
                      todayDecoration:
                      const BoxDecoration(
                        color:
                        AppColors
                            .secondary,
                        shape:
                        BoxShape
                            .circle,
                      ),
                      selectedDecoration:
                      BoxDecoration(
                        color:
                        AppColors
                            .darkNavy,
                        shape:
                        BoxShape
                            .circle,
                      ),
                      markerDecoration:
                      const BoxDecoration(
                        color:
                        AppColors
                            .secondary,
                        shape:
                        BoxShape
                            .circle,
                      ),
                      markerSize: 6,
                      markersMaxCount:
                      1,
                      outsideDaysVisible:
                      false,
                      weekendTextStyle:
                      const TextStyle(
                        color:
                        Colors.black87,
                      ),
                    ),
                    calendarBuilders:
                    CalendarBuilders(
                      markerBuilder:
                          (
                          context,
                          day,
                          events,
                          ) {
                        if (events
                            .isEmpty) {
                          return null;
                        }

                        final slots =
                        events
                            .whereType<
                            SlotModel>()
                            .toList();

                        if (slots
                            .isEmpty) {
                          return null;
                        }

                        final hasAvailable =
                        slots.any(
                              (slot) =>
                              _isAvailableStatus(
                                slot.status,
                              ),
                        );

                        return Positioned(
                          bottom: 4,
                          child:
                          Container(
                            width: 7,
                            height: 7,
                            decoration:
                            BoxDecoration(
                              color:
                              hasAvailable
                                  ? AppColors
                                  .secondary
                                  : Colors
                                  .red,
                              shape:
                              BoxShape
                                  .circle,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment
                      .center,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration:
                      const BoxDecoration(
                        color: AppColors
                            .secondary,
                        shape:
                        BoxShape
                            .circle,
                      ),
                    ),
                    const SizedBox(
                      width: 7,
                    ),
                    Text(
                      languageProvider
                          .translate(
                        'tap_day_to_see_details',
                      ),
                      style:
                      const TextStyle(
                        color:
                        Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 16,
                ),

                SizedBox(
                  width:
                  double.infinity,
                  child:
                  FilledButton.icon(
                    onPressed:
                    slotProvider
                        .isCreating
                        ? null
                        : _showCreateSlotDialog,
                    icon:
                    const Icon(
                      Icons.add,
                    ),
                    label: Text(
                      slotProvider
                          .isCreating
                          ? languageProvider
                          .translate(
                        'creating',
                      )
                          : languageProvider
                          .translate(
                        'add_slot',
                      ),
                    ),
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        languageProvider
                            .translate(
                          'time_slots',
                        ),
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration:
                      BoxDecoration(
                        color: AppColors
                            .secondary
                            .withValues(
                          alpha: 0.1,
                        ),
                        borderRadius:
                        BorderRadius
                            .circular(
                          20,
                        ),
                      ),
                      child: Text(
                        '${selectedDaySlots.length}',
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                          color:
                          AppColors
                              .secondary,
                        ),
                      ),
                    ),
                    if (slotProvider
                        .isLoading)
                      const Padding(
                        padding:
                        EdgeInsets.only(
                          left: 10,
                        ),
                        child:
                        SizedBox(
                          width: 20,
                          height: 20,
                          child:
                          CircularProgressIndicator(
                            strokeWidth:
                            2,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(
                  height: 10,
                ),

                Container(
                  width:
                  double.infinity,
                  padding:
                  const EdgeInsets.all(
                    14,
                  ),
                  decoration:
                  BoxDecoration(
                    color:
                    Colors.white,
                    borderRadius:
                    BorderRadius
                        .circular(
                      14,
                    ),
                    border:
                    Border.all(
                      color: Colors
                          .grey
                          .withValues(
                        alpha: 0.15,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons
                            .calendar_month,
                        color:
                        AppColors
                            .secondary,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          formattedDate,
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                if (selectedDaySlots
                    .isEmpty)
                  Padding(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      vertical: 40,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding:
                          const EdgeInsets
                              .all(
                            18,
                          ),
                          decoration:
                          BoxDecoration(
                            color: Colors
                                .grey
                                .withValues(
                              alpha: 0.08,
                            ),
                            shape:
                            BoxShape
                                .circle,
                          ),
                          child:
                          const Icon(
                            Icons
                                .event_busy,
                            size: 42,
                            color:
                            Colors.grey,
                          ),
                        ),
                        const SizedBox(
                          height: 14,
                        ),
                        Text(
                          languageProvider
                              .translate(
                            'no_slots_for_day',
                          ),
                          style:
                          const TextStyle(
                            color:
                            Colors.grey,
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                        const SizedBox(
                          height: 6,
                        ),
                        Text(
                          languageProvider
                              .translate(
                            'tap_day_to_see_details',
                          ),
                          style:
                          const TextStyle(
                            color:
                            Colors.grey,
                            fontSize: 12,
                          ),
                          textAlign:
                          TextAlign
                              .center,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        OutlinedButton
                            .icon(
                          onPressed:
                          slotProvider
                              .isCreating
                              ? null
                              : _showCreateSlotDialog,
                          icon:
                          const Icon(
                            Icons.add,
                          ),
                          label: Text(
                            languageProvider
                                .translate(
                              'add_first_slot',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (selectedDaySlots
                    .isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics:
                    const NeverScrollableScrollPhysics(),
                    itemCount:
                    selectedDaySlots
                        .length,
                    separatorBuilder:
                        (
                        context,
                        index,
                        ) =>
                    const SizedBox(
                      height: 10,
                    ),
                    itemBuilder:
                        (
                        context,
                        index,
                        ) {
                      final slot =
                      selectedDaySlots[
                      index];

                      final isAvailable =
                      _isAvailableStatus(
                        slot.status,
                      );

                      return Card(
                        elevation: 2,
                        shadowColor:
                        Colors.black12,
                        margin:
                        EdgeInsets.zero,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            16,
                          ),
                        ),
                        child:
                        InkWell(
                          borderRadius:
                          BorderRadius
                              .circular(
                            16,
                          ),
                          onTap: () {
                            _showSlotActions(
                              slot,
                            );
                          },
                          child:
                          Padding(
                            padding:
                            const EdgeInsets
                                .all(
                              15,
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration:
                                  BoxDecoration(
                                    color:
                                    isAvailable
                                        ? AppColors
                                        .secondary
                                        .withValues(
                                      alpha:
                                      0.10,
                                    )
                                        : Colors
                                        .red
                                        .withValues(
                                      alpha:
                                      0.10,
                                    ),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      14,
                                    ),
                                  ),
                                  child:
                                  Icon(
                                    isAvailable
                                        ? Icons
                                        .access_time
                                        : Icons
                                        .lock_outline,
                                    color:
                                    isAvailable
                                        ? AppColors
                                        .secondary
                                        : Colors
                                        .red,
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  child:
                                  Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,
                                    children: [
                                      Text(
                                        '${_formatTime(slot.startTime)} - '
                                            '${_formatTime(slot.endTime)}',
                                        style:
                                        const TextStyle(
                                          fontWeight:
                                          FontWeight.bold,
                                          fontSize:
                                          16,
                                        ),
                                      ),
                                      const SizedBox(
                                        height:
                                        6,
                                      ),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons
                                                .payments_outlined,
                                            size:
                                            16,
                                            color:
                                            Colors.grey,
                                          ),
                                          const SizedBox(
                                            width:
                                            5,
                                          ),
                                          Text(
                                            '${slot.price.toStringAsFixed(2)} '
                                                '${languageProvider.translate('egp')}',
                                            style:
                                            const TextStyle(
                                              color:
                                              Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height:
                                        6,
                                      ),
                                      Text(
                                        isAvailable
                                            ? languageProvider
                                            .translate(
                                          'available',
                                        )
                                            : slot.status,
                                        style:
                                        TextStyle(
                                          color:
                                          isAvailable
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight:
                                          FontWeight.w600,
                                          fontSize:
                                          12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal:
                                    9,
                                    vertical:
                                    6,
                                  ),
                                  decoration:
                                  BoxDecoration(
                                    color:
                                    isAvailable
                                        ? Colors
                                        .green
                                        .withValues(
                                      alpha:
                                      0.10,
                                    )
                                        : Colors
                                        .red
                                        .withValues(
                                      alpha:
                                      0.10,
                                    ),
                                    borderRadius:
                                    BorderRadius
                                        .circular(
                                      10,
                                    ),
                                  ),
                                  child:
                                  Text(
                                    isAvailable
                                        ? '🟢 ${languageProvider.translate('available')}'
                                        : '🔒 ${slot.status}',
                                    style:
                                    TextStyle(
                                      color:
                                      isAvailable
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight:
                                      FontWeight.bold,
                                      fontSize:
                                      11,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 4,
                                ),
                                IconButton(
                                  tooltip:
                                  languageProvider
                                      .translate(
                                    'actions',
                                  ),
                                  icon:
                                  const Icon(
                                    Icons
                                        .more_vert,
                                  ),
                                  onPressed:
                                      () {
                                    _showSlotActions(
                                      slot,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// ============================================================================
// CREATE SLOT DIALOG
// ============================================================================

class _CreateSlotDialog extends StatefulWidget {
  final int stadiumId;
  final DateTime selectedDate;
  final SlotProvider slotProvider;
  final LanguageProvider languageProvider;

  const _CreateSlotDialog({
    required this.stadiumId,
    required this.selectedDate,
    required this.slotProvider,
    required this.languageProvider,
  });

  @override
  State<_CreateSlotDialog> createState() => _CreateSlotDialogState();
}

class _CreateSlotDialogState extends State<_CreateSlotDialog> {
  late final TextEditingController dateController;
  late final TextEditingController startTimeController;
  late final TextEditingController endTimeController;
  late final TextEditingController priceController;

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    dateController = TextEditingController(
      text: _dateKey(widget.selectedDate),
    );
    startTimeController = TextEditingController();
    endTimeController = TextEditingController();
    priceController = TextEditingController();
  }

  @override
  void dispose() {
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    priceController.dispose();
    super.dispose();
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  String? _normalizeTimeText(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return null;

    final parts = raw.split(':');
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

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  int _timeToMinutes(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return 0;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return hour * 60 + minute;
  }

  DateTime? _parseSlotDate(String value) {
    final raw = value.trim();
    if (raw.length < 10) return null;

    final parts = raw.substring(0, 10).split('-');
    if (parts.length != 3) return null;

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);

    if (year == null || month == null || day == null) {
      return null;
    }

    final date = DateTime(year, month, day);

    if (date.year != year ||
        date.month != month ||
        date.day != day) {
      return null;
    }

    return date;
  }

  /// Handles normal + overnight slots on the same calendar day.
  bool _timesOverlap(
      int start1,
      int end1,
      int start2,
      int end2,
      ) {
    List<List<int>> segments(int s, int e) {
      if (e > s) {
        return [
          [s, e]
        ];
      }
      // Overnight: [start → 24:00) + [00:00 → end)
      return [
        [s, 1440],
        [0, e],
      ];
    }

    final segs1 = segments(start1, end1);
    final segs2 = segments(start2, end2);

    for (final a in segs1) {
      for (final b in segs2) {
        if (a[0] < b[1] && b[0] < a[1]) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null || !mounted) return;

    setState(() {
      startTimeController.text = _formatTimeOfDay(picked);
    });
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked == null || !mounted) return;

    setState(() {
      endTimeController.text = _formatTimeOfDay(picked);
    });
  }

  void _showValidation(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submit() async {
    if (isSubmitting || !mounted) return;

    final slotDate = dateController.text.trim();
    final start = _normalizeTimeText(
      startTimeController.text,
    );
    final end = _normalizeTimeText(
      endTimeController.text,
    );

    final priceText = priceController.text
        .trim()
        .replaceAll(',', '.');

    if (slotDate.isEmpty ||
        start == null ||
        end == null ||
        priceText.isEmpty) {
      _showValidation(
        widget.languageProvider.translate(
          'complete_required_fields',
        ),
      );
      return;
    }

    final price = double.tryParse(priceText);

    if (price == null || price < 0) {
      _showValidation(
        widget.languageProvider.translate(
          'enter_valid_price',
        ),
      );
      return;
    }

    final startMinutes = _timeToMinutes(start);
    final endMinutes = _timeToMinutes(end);

    // Only block identical times. Overnight (end < start) is allowed.
    if (startMinutes == endMinutes) {
      _showValidation(
        'Start time and end time cannot be the same',
      );
      return;
    }

    final hasOverlap = widget.slotProvider.slots.any(
          (existingSlot) {
        final existingDate = _parseSlotDate(
          existingSlot.slotDate,
        );

        if (existingDate == null) return false;

        // Strict same calendar day only
        if (_dateKey(existingDate) != slotDate) {
          return false;
        }

        final existingStart = _timeToMinutes(
          existingSlot.startTime,
        );
        final existingEnd = _timeToMinutes(
          existingSlot.endTime,
        );

        return _timesOverlap(
          startMinutes,
          endMinutes,
          existingStart,
          existingEnd,
        );
      },
    );

    if (hasOverlap) {
      _showValidation(
        widget.languageProvider.translate(
          'slot_time_already_exists',
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      final slot = SlotModel(
        id: 0,
        pitchId: widget.stadiumId,
        slotDate: slotDate,
        startTime: start,
        endTime: end,
        price: price,
        status: 'available',
        createdAt: null,
      );

      final created = await widget.slotProvider.createSlot(
        widget.stadiumId,
        slot,
      );

      if (!mounted) return;

      if (created != null) {
        Navigator.of(context).pop(true);
        return;
      }

      setState(() {
        isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = widget.languageProvider;

    return AlertDialog(
      title: Text(
        languageProvider.translate('add_time_slot'),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: languageProvider.translate('date'),
                prefixIcon: const Icon(
                  Icons.calendar_today,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: startTimeController,
              readOnly: true,
              onTap: _selectStartTime,
              decoration: InputDecoration(
                labelText:
                languageProvider.translate('start_time'),
                prefixIcon: const Icon(
                  Icons.access_time,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endTimeController,
              readOnly: true,
              onTap: _selectEndTime,
              decoration: InputDecoration(
                labelText:
                languageProvider.translate('end_time'),
                prefixIcon: const Icon(
                  Icons.access_time,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText:
                languageProvider.translate('price_egp'),
                prefixIcon: const Icon(
                  Icons.payments_outlined,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text(
            languageProvider.translate('cancel'),
          ),
        ),
        FilledButton(
          onPressed: isSubmitting ? null : _submit,
          child: isSubmitting
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text(
            languageProvider.translate('create'),
          ),
        ),
      ],
    );
  }
}


// ============================================================================
// EDIT SLOT DIALOG
// ============================================================================

class _EditSlotDialog extends StatefulWidget {
  final int stadiumId;
  final SlotModel slot;
  final SlotProvider slotProvider;
  final LanguageProvider languageProvider;

  const _EditSlotDialog({
    required this.stadiumId,
    required this.slot,
    required this.slotProvider,
    required this.languageProvider,
  });

  @override
  State<_EditSlotDialog> createState() => _EditSlotDialogState();
}

class _EditSlotDialogState extends State<_EditSlotDialog> {
  late final TextEditingController dateController;
  late final TextEditingController startTimeController;
  late final TextEditingController endTimeController;
  late final TextEditingController priceController;

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();

    dateController = TextEditingController(
      text: widget.slot.slotDate,
    );
    startTimeController = TextEditingController(
      text: _formatTime(widget.slot.startTime),
    );
    endTimeController = TextEditingController(
      text: _formatTime(widget.slot.endTime),
    );
    priceController = TextEditingController(
      text: widget.slot.price.toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    dateController.dispose();
    startTimeController.dispose();
    endTimeController.dispose();
    priceController.dispose();
    super.dispose();
  }

  String _formatTime(String value) {
    final normalized = value.trim();
    final parts = normalized.split(':');

    if (parts.length < 2) return normalized;

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return normalized;
    }

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:'
        '${time.minute.toString().padLeft(2, '0')}';
  }

  TimeOfDay _timeOfDayFromString(String value) {
    final parts = value.trim().split(':');

    if (parts.length < 2) {
      return TimeOfDay.now();
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null ||
        minute == null ||
        hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return TimeOfDay.now();
    }

    return TimeOfDay(
      hour: hour,
      minute: minute,
    );
  }

  String? _normalizeTimeText(String value) {
    final raw = value.trim();
    if (raw.isEmpty) return null;

    final parts = raw.split(':');
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

    return '${hour.toString().padLeft(2, '0')}:'
        '${minute.toString().padLeft(2, '0')}';
  }

  int _timeToMinutes(String value) {
    final parts = value.split(':');
    if (parts.length < 2) return 0;

    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;

    return hour * 60 + minute;
  }

  DateTime? _parseSlotDate(String value) {
    final raw = value.trim();
    if (raw.length < 10) return null;

    final parts = raw.substring(0, 10).split('-');
    if (parts.length != 3) return null;

    final year = int.tryParse(parts[0]);
    final month = int.tryParse(parts[1]);
    final day = int.tryParse(parts[2]);

    if (year == null || month == null || day == null) {
      return null;
    }

    final date = DateTime(year, month, day);

    if (date.year != year ||
        date.month != month ||
        date.day != day) {
      return null;
    }

    return date;
  }

  String _dateKey(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Handles normal + overnight slots on the same calendar day.
  bool _timesOverlap(
      int start1,
      int end1,
      int start2,
      int end2,
      ) {
    List<List<int>> segments(int s, int e) {
      if (e > s) {
        return [
          [s, e]
        ];
      }
      // Overnight: [start → 24:00) + [00:00 → end)
      return [
        [s, 1440],
        [0, e],
      ];
    }

    final segs1 = segments(start1, end1);
    final segs2 = segments(start2, end2);

    for (final a in segs1) {
      for (final b in segs2) {
        if (a[0] < b[1] && b[0] < a[1]) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> _selectStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDayFromString(
        widget.slot.startTime,
      ),
    );

    if (picked == null || !mounted) return;

    setState(() {
      startTimeController.text = _formatTimeOfDay(picked);
    });
  }

  Future<void> _selectEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _timeOfDayFromString(
        widget.slot.endTime,
      ),
    );

    if (picked == null || !mounted) return;

    setState(() {
      endTimeController.text = _formatTimeOfDay(picked);
    });
  }

  void _showValidation(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _submit() async {
    if (isSubmitting || !mounted) return;

    final start = _normalizeTimeText(
      startTimeController.text,
    );
    final end = _normalizeTimeText(
      endTimeController.text,
    );

    final priceText = priceController.text
        .trim()
        .replaceAll(',', '.');

    final price = double.tryParse(priceText);

    if (start == null || end == null) {
      _showValidation(
        widget.languageProvider.translate(
          'invalid_time_format',
        ),
      );
      return;
    }

    if (price == null || price < 0) {
      _showValidation(
        widget.languageProvider.translate(
          'enter_valid_price',
        ),
      );
      return;
    }

    final startMinutes = _timeToMinutes(start);
    final endMinutes = _timeToMinutes(end);

    // Only block identical times. Overnight (end < start) is allowed.
    if (startMinutes == endMinutes) {
      _showValidation(
        'Start time and end time cannot be the same',
      );
      return;
    }

    final hasOverlap = widget.slotProvider.slots.any(
          (existingSlot) {
        if (existingSlot.id == widget.slot.id) {
          return false;
        }

        final existingDate = _parseSlotDate(
          existingSlot.slotDate,
        );

        if (existingDate == null) return false;

        // Strict same calendar day only (never moves overnight to next day)
        if (_dateKey(existingDate) !=
            widget.slot.slotDate) {
          return false;
        }

        final existingStart = _timeToMinutes(
          existingSlot.startTime,
        );
        final existingEnd = _timeToMinutes(
          existingSlot.endTime,
        );

        return _timesOverlap(
          startMinutes,
          endMinutes,
          existingStart,
          existingEnd,
        );
      },
    );

    if (hasOverlap) {
      _showValidation(
        widget.languageProvider.translate(
          'slot_time_already_exists',
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      // Date is never changed – stays on original slotDate
      final updatedSlot = widget.slot.copyWith(
        startTime: start,
        endTime: end,
        price: price,
      );

      final result = await widget.slotProvider.updateSlot(
        widget.stadiumId,
        widget.slot.id,
        updatedSlot,
      );

      if (!mounted) return;

      if (result != null) {
        Navigator.of(context).pop(true);
        return;
      }

      setState(() {
        isSubmitting = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = widget.languageProvider;

    return AlertDialog(
      title: Text(
        languageProvider.translate('edit_slot'),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: languageProvider.translate('date'),
                prefixIcon: const Icon(
                  Icons.calendar_today,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: startTimeController,
              readOnly: true,
              onTap: _selectStartTime,
              decoration: InputDecoration(
                labelText:
                languageProvider.translate('start_time'),
                prefixIcon: const Icon(
                  Icons.access_time,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: endTimeController,
              readOnly: true,
              onTap: _selectEndTime,
              decoration: InputDecoration(
                labelText:
                languageProvider.translate('end_time'),
                prefixIcon: const Icon(
                  Icons.access_time,
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType:
              const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText:
                languageProvider.translate('price_egp'),
                prefixIcon: const Icon(
                  Icons.payments_outlined,
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSubmitting
              ? null
              : () => Navigator.of(context).pop(false),
          child: Text(
            languageProvider.translate('cancel'),
          ),
        ),
        FilledButton(
          onPressed: isSubmitting ? null : _submit,
          child: isSubmitting
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.white,
            ),
          )
              : Text(
            languageProvider.translate('save'),
          ),
        ),
      ],
    );
  }
}