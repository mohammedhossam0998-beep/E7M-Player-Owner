import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/academy_coach_controller.dart';
import '../models/academy_coach_model.dart';
import 'assign_academy_coach_screen.dart';

class AcademyCoachesScreen extends StatefulWidget {
  final int academyId;

  const AcademyCoachesScreen({
    super.key,
    required this.academyId,
  });

  @override
  State<AcademyCoachesScreen> createState() =>
      _AcademyCoachesScreenState();
}

class _AcademyCoachesScreenState
    extends State<AcademyCoachesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AcademyCoachController>().loadCoaches(
        academyId: widget.academyId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academy Coaches'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AssignAcademyCoachScreen(
                academyId: widget.academyId,
              ),
            ),
          );

          if (!mounted) return;

          if (result == true) {
            await context
                .read<AcademyCoachController>()
                .refreshCoaches(
              academyId: widget.academyId,
            );
          }
        },
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Assign Coach'),
      ),
      body: Consumer<AcademyCoachController>(
        builder: (
            context,
            controller,
            _,
            ) {
          if (controller.isLoading &&
              controller.coaches.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.hasError &&
              controller.coaches.isEmpty) {
            return _buildError(
              context,
              controller.errorMessage,
            );
          }

          if (controller.coaches.isEmpty) {
            return _buildEmpty(context);
          }

          return RefreshIndicator(
            onRefresh: () {
              return controller.refreshCoaches(
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
              itemCount: controller.coaches.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (
                  context,
                  index,
                  ) {
                final coach =
                controller.coaches[index];

                return _CoachCard(
                  coach: coach,
                  isRemoving:
                  controller.isRemoving,
                  onEdit: () {
                    _showEditRoleDialog(
                      context,
                      controller,
                      coach,
                    );
                  },
                  onDelete: () {
                    _deleteCoach(
                      context,
                      controller,
                      coach,
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
  // EDIT ROLE
  // ============================================================

  Future<void> _showEditRoleDialog(
      BuildContext context,
      AcademyCoachController controller,
      AcademyCoachModel coach,
      ) async {
    const roles = [
      'Head Coach',
      'Assistant Coach',
      'Goalkeeper Coach',
      'Fitness Coach',
    ];

    String selectedRole = coach.role;

    final result =
    await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
              context,
              setDialogState,
              ) {
            return AlertDialog(
              title: const Text(
                'Update Coach Role',
              ),
              content: DropdownButtonFormField<String>(
                initialValue:
                roles.contains(selectedRole)
                    ? selectedRole
                    : null,
                isExpanded: true,
                decoration:
                const InputDecoration(
                  labelText: 'Role',
                  border:
                  OutlineInputBorder(),
                ),
                items: roles.map(
                      (role) {
                    return DropdownMenuItem<
                        String>(
                      value: role,
                      child: Text(role),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  if (value == null) return;

                  setDialogState(() {
                    selectedRole = value;
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop();
                  },
                  child: const Text(
                    'Cancel',
                  ),
                ),
                FilledButton(
                  onPressed: () {
                    Navigator.of(
                      dialogContext,
                    ).pop(selectedRole);
                  },
                  child: const Text(
                    'Save',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (!mounted ||
        result == null ||
        result == coach.role) {
      return;
    }

    final updated =
    await controller.updateCoachAssignment(
      academyId: widget.academyId,
      coachId: coach.coachId,
      role: result,
    );

    if (!mounted) return;

    if (updated != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Coach role updated successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage ??
                'Failed to update coach role',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<void> _deleteCoach(
      BuildContext context,
      AcademyCoachController controller,
      AcademyCoachModel coach,
      ) async {
    if (controller.isRemoving) {
      return;
    }

    final coachName =
    coach.fullName?.trim().isNotEmpty == true
        ? coach.fullName!
        : 'this coach';

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Remove Coach',
          ),
          content: Text(
            'Are you sure you want to remove $coachName from this academy?',
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
                'Remove',
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
    await controller.removeCoach(
      academyId: widget.academyId,
      coachId: coach.coachId,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Coach removed successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage ??
                'Failed to remove coach',
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
                  'Failed to load academy coaches',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<AcademyCoachController>()
                    .loadCoaches(
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
            .read<AcademyCoachController>()
            .refreshCoaches(
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
                          .sports_handball_outlined,
                      size: 72,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No coaches assigned',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Assign a coach to your academy.',
                      textAlign:
                      TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result =
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AssignAcademyCoachScreen(
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
                              AcademyCoachController>()
                              .refreshCoaches(
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
                        'Assign Coach',
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
// COACH CARD
// ============================================================================

class _CoachCard extends StatelessWidget {
  final AcademyCoachModel coach;
  final bool isRemoving;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CoachCard({
    required this.coach,
    required this.isRemoving,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final name =
    coach.fullName?.trim().isNotEmpty == true
        ? coach.fullName!
        : 'Coach #${coach.coachId}';

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                _buildAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow:
                        TextOverflow.ellipsis,
                        style:
                        const TextStyle(
                          fontSize: 18,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        coach.role,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight:
                          FontWeight.w600,
                          color: Theme.of(
                            context,
                          )
                              .colorScheme
                              .primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            const Divider(height: 1),

            const SizedBox(height: 14),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (coach.experienceYears != null)
                  _InfoChip(
                    icon:
                    Icons.workspace_premium_outlined,
                    label:
                    '${coach.experienceYears} years',
                  ),
                if (coach.rating >= 0)
                  _InfoChip(
                    icon:
                    Icons.star_outline,
                    label:
                    coach.rating.toStringAsFixed(2),
                  ),
                _InfoChip(
                  icon:
                  Icons.people_outline,
                  label:
                  '${coach.playersCount} players',
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (coach.phone != null &&
                coach.phone!
                    .trim()
                    .isNotEmpty)
              _DetailRow(
                icon:
                Icons.phone_outlined,
                text: coach.phone!,
              ),

            if (coach.email != null &&
                coach.email!
                    .trim()
                    .isNotEmpty)
              Padding(
                padding:
                const EdgeInsets.only(
                  top: 8,
                ),
                child: _DetailRow(
                  icon:
                  Icons.email_outlined,
                  text: coach.email!,
                ),
              ),

            if (coach.bio != null &&
                coach.bio!
                    .trim()
                    .isNotEmpty)
              Padding(
                padding:
                const EdgeInsets.only(
                  top: 10,
                ),
                child: Text(
                  coach.bio!,
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
              ),

            const SizedBox(height: 14),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed:
                  isRemoving
                      ? null
                      : onEdit,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                  ),
                  label:
                  const Text('Edit Role'),
                ),
                const SizedBox(width: 4),
                TextButton.icon(
                  onPressed:
                  isRemoving
                      ? null
                      : onDelete,
                  icon: isRemoving
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
                  const Text('Remove'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (coach.profileImage != null &&
        coach.profileImage!
            .trim()
            .isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage:
        NetworkImage(
          coach.profileImage!,
        ),
      );
    }

    return const CircleAvatar(
      radius: 28,
      child: Icon(
        Icons.person_outline,
        size: 30,
      ),
    );
  }
}

// ============================================================================
// INFO CHIP
// ============================================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(20),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// DETAIL ROW
// ============================================================================

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({
    required this.icon,
    required this.text,
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
          child: Text(
            text,
            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,
            style:
            const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}