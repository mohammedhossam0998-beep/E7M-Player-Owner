import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/program_controller.dart';
import '../controller/schedule_controller.dart';
import '../models/schedule_model.dart';

class EditScheduleScreen extends StatefulWidget {
  final int academyId;
  final ScheduleModel schedule;

  const EditScheduleScreen({
    super.key,
    required this.academyId,
    required this.schedule,
  });

  @override
  State<EditScheduleScreen> createState() =>
      _EditScheduleScreenState();
}

class _EditScheduleScreenState
    extends State<EditScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _selectedDay;
  int? _selectedProgramId;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  late final TextEditingController _locationController;

  final List<String> _days = const [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  bool _programsLoaded = false;

  @override
  void initState() {
    super.initState();

    _selectedDay = widget.schedule.dayOfWeek;
    _selectedProgramId = widget.schedule.programId;

    _startTime = _parseTime(
      widget.schedule.startTime,
    );

    _endTime = _parseTime(
      widget.schedule.endTime,
    );

    _locationController =
        TextEditingController(
          text: widget.schedule.location ?? '',
        );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (!_programsLoaded) {
        _programsLoaded = true;

        context
            .read<ProgramController>()
            .loadPrograms(
          academyId: widget.academyId,
        );
      }
    });
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  // ============================================================
  // PARSE TIME
  // ============================================================

  TimeOfDay? _parseTime(String value) {
    final parts = value.split(':');

    if (parts.length < 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);

    if (hour == null || minute == null) {
      return null;
    }

    if (hour < 0 ||
        hour > 23 ||
        minute < 0 ||
        minute > 59) {
      return null;
    }

    return TimeOfDay(
      hour: hour,
      minute: minute,
    );
  }

  // ============================================================
  // PICK START TIME
  // ============================================================

  Future<void> _pickStartTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime:
      _startTime ??
          const TimeOfDay(
            hour: 17,
            minute: 0,
          ),
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _startTime = selected;
    });
  }

  // ============================================================
  // PICK END TIME
  // ============================================================

  Future<void> _pickEndTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime:
      _endTime ??
          const TimeOfDay(
            hour: 18,
            minute: 30,
          ),
    );

    if (!mounted || selected == null) {
      return;
    }

    setState(() {
      _endTime = selected;
    });
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDay.trim().isEmpty) {
      _showMessage(
        'Please select a day',
      );
      return;
    }

    if (_startTime == null) {
      _showMessage(
        'Please select start time',
      );
      return;
    }

    if (_endTime == null) {
      _showMessage(
        'Please select end time',
      );
      return;
    }

    final startMinutes =
        _startTime!.hour * 60 +
            _startTime!.minute;

    final endMinutes =
        _endTime!.hour * 60 +
            _endTime!.minute;

    if (endMinutes <= startMinutes) {
      _showMessage(
        'End time must be after start time',
      );
      return;
    }

    final updatedSchedule =
    widget.schedule.copyWith(
      academyId: widget.academyId,
      programId: _selectedProgramId,
      dayOfWeek: _selectedDay,
      startTime:
      _formatTime(_startTime!),
      endTime:
      _formatTime(_endTime!),
      location:
      _nullable(_locationController.text),
    );

    final controller =
    context.read<ScheduleController>();

    final result =
    await controller.updateSchedule(
      academyId: widget.academyId,
      scheduleId: widget.schedule.id,
      schedule: updatedSchedule,
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Schedule updated successfully',
          ),
        ),
      );

      Navigator.of(context).pop(true);
      return;
    }

    _showMessage(
      controller.errorMessage ??
          'Failed to update schedule',
    );
  }

  // ============================================================
  // FORMAT TIME FOR API
  // ============================================================

  String _formatTime(TimeOfDay time) {
    final hour =
    time.hour.toString().padLeft(2, '0');

    final minute =
    time.minute.toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  // ============================================================
  // FORMAT TIME FOR DISPLAY
  // ============================================================

  String _formatDisplayTime(
      TimeOfDay? time,
      ) {
    if (time == null) {
      return 'Select time';
    }

    final hour =
    time.hourOfPeriod == 0
        ? 12
        : time.hourOfPeriod;

    final minute =
    time.minute
        .toString()
        .padLeft(2, '0');

    final period =
    time.period == DayPeriod.am
        ? 'AM'
        : 'PM';

    return '$hour:$minute $period';
  }

  // ============================================================
  // NULLABLE
  // ============================================================

  String? _nullable(String value) {
    final text = value.trim();

    return text.isEmpty ? null : text;
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Schedule',
        ),
        centerTitle: true,
      ),
      body: Consumer<ScheduleController>(
        builder: (
            context,
            scheduleController,
            _,
            ) {
          return Form(
            key: _formKey,
            child: ListView(
              padding:
              const EdgeInsets.all(16),
              children: [
                // ========================================================
                // DAY
                // ========================================================

                DropdownButtonFormField<String>(
                  initialValue: _days.contains(
                    _selectedDay,
                  )
                      ? _selectedDay
                      : null,
                  isExpanded: true,
                  decoration:
                  const InputDecoration(
                    labelText: 'Day',
                    prefixIcon: Icon(
                      Icons.calendar_today_outlined,
                    ),
                    border:
                    OutlineInputBorder(),
                  ),
                  items: _days.map(
                        (day) {
                      return DropdownMenuItem<
                          String>(
                        value: day,
                        child: Text(day),
                      );
                    },
                  ).toList(),
                  onChanged:
                  scheduleController
                      .isUpdating
                      ? null
                      : (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _selectedDay =
                          value;
                    });
                  },
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'Please select a day';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ========================================================
                // PROGRAM
                // ========================================================

                Consumer<ProgramController>(
                  builder: (
                      context,
                      programController,
                      _,
                      ) {
                    if (programController
                        .isLoading &&
                        programController
                            .programs
                            .isEmpty) {
                      return const InputDecorator(
                        decoration:
                        InputDecoration(
                          labelText: 'Program',
                          prefixIcon:
                          Icon(
                            Icons
                                .menu_book_outlined,
                          ),
                          border:
                          OutlineInputBorder(),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Loading programs...',
                            ),
                          ],
                        ),
                      );
                    }

                    return DropdownButtonFormField<int>(
                      initialValue:
                      _programExists(
                        programController,
                      )
                          ? _selectedProgramId
                          : null,
                      isExpanded: true,
                      decoration:
                      const InputDecoration(
                        labelText: 'Program',
                        prefixIcon:
                        Icon(
                          Icons
                              .menu_book_outlined,
                        ),
                        border:
                        OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<
                            int>(
                          value: null,
                          child:
                          Text(
                            'No specific program',
                          ),
                        ),
                        ...programController
                            .programs
                            .map(
                              (program) {
                            return DropdownMenuItem<
                                int>(
                              value:
                              program.id,
                              child: Text(
                                program.name,
                                overflow:
                                TextOverflow
                                    .ellipsis,
                              ),
                            );
                          },
                        ),
                      ],
                      onChanged:
                      scheduleController
                          .isUpdating
                          ? null
                          : (value) {
                        setState(() {
                          _selectedProgramId =
                              value;
                        });
                      },
                    );
                  },
                ),

                const SizedBox(height: 16),

                // ========================================================
                // START TIME
                // ========================================================

                _TimePickerField(
                  label: 'Start Time',
                  icon: Icons
                      .access_time_outlined,
                  value:
                  _formatDisplayTime(
                    _startTime,
                  ),
                  onTap:
                  scheduleController
                      .isUpdating
                      ? null
                      : _pickStartTime,
                ),

                const SizedBox(height: 16),

                // ========================================================
                // END TIME
                // ========================================================

                _TimePickerField(
                  label: 'End Time',
                  icon: Icons
                      .access_time_filled_outlined,
                  value:
                  _formatDisplayTime(
                    _endTime,
                  ),
                  onTap:
                  scheduleController
                      .isUpdating
                      ? null
                      : _pickEndTime,
                ),

                const SizedBox(height: 16),

                // ========================================================
                // LOCATION
                // ========================================================

                TextFormField(
                  controller:
                  _locationController,
                  enabled:
                  !scheduleController
                      .isUpdating,
                  decoration:
                  const InputDecoration(
                    labelText: 'Location',
                    hintText:
                    'Example: Main Training Field',
                    prefixIcon:
                    Icon(
                      Icons
                          .location_on_outlined,
                    ),
                    border:
                    OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 28),

                // ========================================================
                // SAVE
                // ========================================================

                SizedBox(
                  height: 54,
                  child:
                  ElevatedButton(
                    onPressed:
                    scheduleController
                        .isUpdating
                        ? null
                        : _submit,
                    child:
                    scheduleController
                        .isUpdating
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Save Changes',
                    ),
                  ),
                ),

                if (scheduleController
                    .hasError)
                  Padding(
                    padding:
                    const EdgeInsets.only(
                      top: 14,
                    ),
                    child: Text(
                      scheduleController
                          .errorMessage ??
                          'Something went wrong',
                      textAlign:
                      TextAlign.center,
                      style:
                      const TextStyle(
                        color: Colors.red,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  bool _programExists(
      ProgramController controller,
      ) {
    if (_selectedProgramId == null) {
      return false;
    }

    return controller.programs.any(
          (program) =>
      program.id ==
          _selectedProgramId,
    );
  }
}

// ============================================================================
// TIME PICKER FIELD
// ============================================================================

class _TimePickerField
    extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final VoidCallback? onTap;

  const _TimePickerField({
    required this.label,
    required this.icon,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
      BorderRadius.circular(4),
      child: InputDecorator(
        decoration:
        InputDecoration(
          labelText: label,
          prefixIcon:
          Icon(icon),
          border:
          const OutlineInputBorder(),
        ),
        child: Text(
          value,
          style:
          const TextStyle(
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}