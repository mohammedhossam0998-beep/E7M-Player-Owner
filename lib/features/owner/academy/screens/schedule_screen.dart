import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/schedule_controller.dart';
import '../models/schedule_model.dart';
import 'create_schedule_screen.dart';
import 'edit_schedule_screen.dart';
class ScheduleScreen extends StatefulWidget {
  final int academyId;

  const ScheduleScreen({
    super.key,
    required this.academyId,
  });

  @override
  State<ScheduleScreen> createState() =>
      _ScheduleScreenState();
}

class _ScheduleScreenState
    extends State<ScheduleScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ScheduleController>().loadSchedule(
        academyId: widget.academyId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        centerTitle: true,
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateScheduleScreen(
                academyId: widget.academyId,
              ),
            ),
          );

          if (!mounted) return;

          if (result == true) {
            await context
                .read<ScheduleController>()
                .refreshSchedule(
              academyId: widget.academyId,
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Schedule'),
      ),
      body: Consumer<ScheduleController>(
        builder: (
            context,
            controller,
            _,
            ) {
          if (controller.isLoading &&
              controller.schedules.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.hasError &&
              controller.schedules.isEmpty) {
            return _buildError(
              context,
              controller.errorMessage,
            );
          }

          if (controller.schedules.isEmpty) {
            return _buildEmpty(context);
          }

          return RefreshIndicator(
            onRefresh: () {
              return controller.refreshSchedule(
                academyId: widget.academyId,
              );
            },
            child: ListView.separated(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                100,
              ),
              itemCount: controller.schedules.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (
                  context,
                  index,
                  ) {
                final schedule =
                controller.schedules[index];

                return _ScheduleCard(
                  schedule: schedule,
                  isDeleting:
                  controller.isDeleting,
                  onEdit: () async {
                    final result =
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditScheduleScreen(
                              academyId:
                              widget.academyId,
                              schedule: schedule,
                            ),
                      ),
                    );

                    if (!mounted) return;

                    if (result == true) {
                      await controller.refreshSchedule(
                        academyId:
                        widget.academyId,
                      );
                    }
                  },
                  onDelete: () async {
                    await _deleteSchedule(
                      context,
                      controller,
                      schedule,
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

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteSchedule(
      BuildContext context,
      ScheduleController controller,
      ScheduleModel schedule,
      ) async {
    if (controller.isDeleting) {
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Schedule',
          ),
          content: Text(
            'Are you sure you want to delete the schedule for ${schedule.dayOfWeek}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final success =
    await controller.deleteSchedule(
      academyId: widget.academyId,
      scheduleId: schedule.id,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Schedule deleted successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage ??
                'Failed to delete schedule',
          ),
        ),
      );
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
      BuildContext context,
      String? message,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              message ??
                  'Failed to load schedule',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<ScheduleController>()
                    .loadSchedule(
                  academyId:
                  widget.academyId,
                );
              },
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty(
      BuildContext context,
      ) {
    return RefreshIndicator(
      onRefresh: () {
        return context
            .read<ScheduleController>()
            .refreshSchedule(
          academyId: widget.academyId,
        );
      },
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
            MediaQuery.of(context)
                .size
                .height *
                0.65,
            child: Center(
              child: Padding(
                padding:
                const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons
                          .calendar_month_outlined,
                      size: 72,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                      'No schedule found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      'Create the academy training schedule.',
                      textAlign:
                      TextAlign.center,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result =
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                CreateScheduleScreen(
                                  academyId:
                                  widget.academyId,
                                ),
                          ),
                        );

                        if (!context.mounted) {
                          return;
                        }

                        if (result == true) {
                          await context
                              .read<
                              ScheduleController>()
                              .refreshSchedule(
                            academyId:
                            widget
                                .academyId,
                          );
                        }
                      },
                      icon:
                      const Icon(Icons.add),
                      label: const Text(
                        'Add Schedule',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SCHEDULE CARD
// ============================================================================

class _ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDeleting;

  const _ScheduleCard({
    required this.schedule,
    required this.onEdit,
    required this.onDelete,
    required this.isDeleting,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ==========================================================
            // DAY
            // ==========================================================

            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(12),
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest,
                  ),
                  child: const Icon(
                    Icons.calendar_today_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    schedule.dayOfWeek,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ==========================================================
            // TIME
            // ==========================================================

            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon:
                    Icons.access_time_outlined,
                    label: 'Start',
                    value:
                    schedule.startTime,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon:
                    Icons.access_time_filled_outlined,
                    label: 'End',
                    value:
                    schedule.endTime,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ==========================================================
            // LOCATION
            // ==========================================================

            if (schedule.location != null &&
                schedule.location!
                    .trim()
                    .isNotEmpty)
              _InfoItem(
                icon:
                Icons.location_on_outlined,
                label: 'Location',
                value:
                schedule.location!,
              ),

            // ==========================================================
            // PROGRAM
            // ==========================================================

            if (schedule.programName != null &&
                schedule.programName!
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(height: 14),
              _InfoItem(
                icon:
                Icons.menu_book_outlined,
                label: 'Program',
                value:
                schedule.programName!,
              ),
            ],

            const SizedBox(height: 16),

            const Divider(height: 1),

            const SizedBox(height: 8),

            // ==========================================================
            // ACTIONS
            // ==========================================================

            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed:
                  isDeleting ? null : onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                  ),
                  label:
                  const Text('Edit'),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed:
                  isDeleting
                      ? null
                      : onDelete,
                  icon: isDeleting
                      ? const SizedBox(
                    width: 17,
                    height: 17,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.delete_outline,
                    size: 18,
                  ),
                  label:
                  const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// INFO ITEM
// ============================================================================

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color:
                  Colors.grey.shade500,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}