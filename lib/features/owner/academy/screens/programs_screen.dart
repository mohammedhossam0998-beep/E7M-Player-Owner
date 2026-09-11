import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/program_controller.dart';
import '../models/program_model.dart';
import 'create_program_screen.dart';
import 'edit_program_screen.dart';

class ProgramsScreen extends StatefulWidget {
  final int academyId;

  const ProgramsScreen({
    super.key,
    required this.academyId,
  });

  @override
  State<ProgramsScreen> createState() =>
      _ProgramsScreenState();
}

class _ProgramsScreenState
    extends State<ProgramsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<ProgramController>().loadPrograms(
        academyId: widget.academyId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Programs'),
        centerTitle: true,
      ),

      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateProgramScreen(
                academyId: widget.academyId,
              ),
            ),
          );

          if (!mounted) return;

          if (result == true) {
            await context
                .read<ProgramController>()
                .refreshPrograms(
              academyId: widget.academyId,
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Program'),
      ),

      body: Consumer<ProgramController>(
        builder: (
            context,
            controller,
            child,
            ) {
          if (controller.isLoading &&
              controller.programs.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.hasError &&
              controller.programs.isEmpty) {
            return _buildError(
              context,
              controller.errorMessage,
            );
          }

          if (controller.programs.isEmpty) {
            return _buildEmpty(context);
          }

          return RefreshIndicator(
            onRefresh: () {
              return controller.refreshPrograms(
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
              itemCount: controller.programs.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (
                  context,
                  index,
                  ) {
                final program =
                controller.programs[index];

                return _ProgramCard(
                  program: program,
                  isDeleting:
                  controller.isDeleting,
                  onEdit: () async {
                    final result =
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditProgramScreen(
                              academyId:
                              widget.academyId,
                              program: program,
                            ),
                      ),
                    );

                    if (!mounted) return;

                    if (result == true) {
                      await controller
                          .refreshPrograms(
                        academyId:
                        widget.academyId,
                      );
                    }
                  },
                  onDelete: () async {
                    await _deleteProgram(
                      context,
                      controller,
                      program,
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
  // DELETE CONFIRMATION
  // ============================================================

  Future<void> _deleteProgram(
      BuildContext context,
      ProgramController controller,
      ProgramModel program,
      ) async {
    if (controller.isDeleting) {
      return;
    }

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Program',
          ),
          content: Text(
            'Are you sure you want to delete "${program.name}"?',
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
    await controller.deleteProgram(
      academyId: widget.academyId,
      programId: program.id,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Program deleted successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage ??
                'Failed to delete program',
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
        padding:
        const EdgeInsets.all(24),
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
                  'Failed to load programs',
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<ProgramController>()
                    .loadPrograms(
                  academyId:
                  widget.academyId,
                );
              },
              icon:
              const Icon(Icons.refresh),
              label:
              const Text('Retry'),
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
            .read<ProgramController>()
            .refreshPrograms(
          academyId:
          widget.academyId,
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
                          .menu_book_outlined,
                      size: 72,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                      'No programs found',
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
                      'Create your first training program.',
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
                                CreateProgramScreen(
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
                              ProgramController>()
                              .refreshPrograms(
                            academyId:
                            widget
                                .academyId,
                          );
                        }
                      },
                      icon:
                      const Icon(Icons.add),
                      label:
                      const Text(
                        'Add Program',
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
// PROGRAM CARD
// ============================================================================

class _ProgramCard extends StatelessWidget {
  final ProgramModel program;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final bool isDeleting;

  const _ProgramCard({
    required this.program,
    required this.onEdit,
    required this.onDelete,
    required this.isDeleting,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ==========================================================
            // HEADER
            // ==========================================================

            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    program.name,
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                if (program.level !=
                    null &&
                    program.level!
                        .trim()
                        .isNotEmpty)
                  Container(
                    padding:
                    const EdgeInsets
                        .symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration:
                    BoxDecoration(
                      borderRadius:
                      BorderRadius
                          .circular(
                        20,
                      ),
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .surfaceContainerHighest,
                    ),
                    child: Text(
                      program.level!,
                      style:
                      const TextStyle(
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            // ==========================================================
            // DESCRIPTION
            // ==========================================================

            if (program.description !=
                null &&
                program.description!
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                program.description!,
                maxLines: 3,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  color:
                  Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ==========================================================
            // INFO
            // ==========================================================

            Row(
              children: [
                if (program.price != null)
                  Expanded(
                    child: _InfoItem(
                      icon: Icons
                          .payments_outlined,
                      label: 'Price',
                      value:
                      '${_formatPrice(program.price!)} EGP',
                    ),
                  ),

                if (program.durationWeeks !=
                    null)
                  Expanded(
                    child: _InfoItem(
                      icon: Icons
                          .calendar_today_outlined,
                      label: 'Duration',
                      value:
                      '${program.durationWeeks} weeks',
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(height: 1),

            const SizedBox(height: 10),

            // ==========================================================
            // ACTIONS
            // ==========================================================

            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed:
                  isDeleting
                      ? null
                      : onEdit,
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
                    Icons
                        .delete_outline,
                    size: 18,
                  ),
                  label: const Text(
                    'Delete',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatPrice(
      double value,
      ) {
    if (value ==
        value.roundToDouble()) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(2);
  }
}

// ============================================================================
// INFO ITEM
// ============================================================================

class _InfoItem
    extends StatelessWidget {
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
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  fontSize: 13,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}