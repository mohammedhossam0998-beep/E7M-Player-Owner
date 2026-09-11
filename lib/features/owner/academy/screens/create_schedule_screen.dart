import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/program_controller.dart';
import '../controller/schedule_controller.dart';
import '../models/schedule_model.dart';

class CreateScheduleScreen extends StatefulWidget {
  final int academyId;

  const CreateScheduleScreen({
    super.key,
    required this.academyId,
  });

  @override
  State<CreateScheduleScreen> createState() =>
      _CreateScheduleScreenState();
}

class _CreateScheduleScreenState
    extends State<CreateScheduleScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedDay;
  int? _selectedProgramId;

  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  final _locationController =
  TextEditingController();

  final List<String> _days = const [
    'Saturday',
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
  ];

  bool _programsRequested = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final programController =
      context.read<ProgramController>();

      if (!_programsRequested) {
        _programsRequested = true;

        programController.loadPrograms(
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
  // PICK START TIME
  // ============================================================

  Future<void> _pickStartTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime:
      _startTime ?? const TimeOfDay(
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
      _endTime ?? const TimeOfDay(
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

    if (_selectedDay == null) {
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

    final schedule = ScheduleModel(
      id: 0,
      academyId: widget.academyId,
      programId: _selectedProgramId,
      dayOfWeek: _selectedDay!,
      startTime: _formatTime(_startTime!),
      endTime: _formatTime(_endTime!),
      location: _nullable(
        _locationController.text,
      ),
    );

    final controller =
    context.read<ScheduleController>();

    final created =
    await controller.createSchedule(
      academyId: widget.academyId,
      schedule: schedule,
    );

    if (!mounted) {
      return;
    }

    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Schedule created successfully',
          ),
        ),
      );

      Navigator.of(context).pop(true);
      return;
    }

    _showMessage(
      controller.errorMessage ??
          'Failed to create schedule',
    );
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(TimeOfDay time) {
    final hour =
    time.hour.toString().padLeft(2, '0');

    final minute =
    time.minute.toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  // ============================================================
  // FORMAT DISPLAY TIME
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
    time.minute.toString().padLeft(2, '0');

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
          'Create Schedule',
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
                  initialValue:
                  _selectedDay,
                  isExpanded: true,
                  decoration:
                  const InputDecoration(
                    labelText: 'Day',
                    hintText:
                    'Select training day',
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
                      .isCreating
                      ? null
                      : (value) {
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

                    if (programController
                        .hasError) {
                      return Container(
                        padding:
                        const EdgeInsets.all(
                          12,
                        ),
                        decoration:
                        BoxDecoration(
                          border: Border.all(
                            color:
                            Colors.red.shade200,
                          ),
                          borderRadius:
                          BorderRadius
                              .circular(
                            8,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                          children: [
                            const Icon(
                              Icons
                                  .error_outline,
                              color:
                              Colors.red,
                            ),
                            const SizedBox(
                              width: 8,
                            ),
                            Expanded(
                              child: Text(
                                programController
                                    .errorMessage ??
                                    'Failed to load programs',
                              ),
                            ),
                            TextButton(
                              onPressed:
                              programController
                                  .isLoading
                                  ? null
                                  : () {
                                context
                                    .read<
                                    ProgramController>()
                                    .loadPrograms(
                                  academyId:
                                  widget.academyId,
                                );
                              },
                              child:
                              const Text(
                                'Retry',
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return DropdownButtonFormField<int>(
                      initialValue:
                      _selectedProgramId,
                      isExpanded: true,
                      decoration:
                      const InputDecoration(
                        labelText:
                        'Program',
                        hintText:
                        'Select program (optional)',
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
                          child: Text(
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
                          .isCreating
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
                      .isCreating
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
                      .isCreating
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
                      .isCreating,
                  textInputAction:
                  TextInputAction.done,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Location',
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
                // CREATE
                // ========================================================

                SizedBox(
                  height: 54,
                  child:
                  ElevatedButton(
                    onPressed:
                    scheduleController
                        .isCreating
                        ? null
                        : _submit,
                    child:
                    scheduleController
                        .isCreating
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,
                      ),
                    )
                        : const Text(
                      'Create Schedule',
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