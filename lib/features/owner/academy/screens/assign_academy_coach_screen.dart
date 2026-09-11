import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/academy_coach_controller.dart';
import '../models/academy_coach_model.dart';

class AssignAcademyCoachScreen extends StatefulWidget {
  final int academyId;

  const AssignAcademyCoachScreen({
    super.key,
    required this.academyId,
  });

  @override
  State<AssignAcademyCoachScreen> createState() =>
      _AssignAcademyCoachScreenState();
}

class _AssignAcademyCoachScreenState
    extends State<AssignAcademyCoachScreen> {
  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  int? _selectedCoachId;
  String? _selectedRole;

  final List<String> _roles = const [
    'Head Coach',
    'Assistant Coach',
    'Goalkeeper Coach',
    'Fitness Coach',
  ];

  bool _requestedCoaches = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_requestedCoaches) return;

      _requestedCoaches = true;

      context
          .read<AcademyCoachController>()
          .loadAvailableCoaches(
        academyId: widget.academyId,
      );
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

    if (_selectedCoachId == null) {
      _showMessage(
        'Please select a coach',
      );
      return;
    }

    if (_selectedRole == null ||
        _selectedRole!.trim().isEmpty) {
      _showMessage(
        'Please select a role',
      );
      return;
    }

    final controller =
    context.read<AcademyCoachController>();

    final result =
    await controller.assignCoach(
      academyId: widget.academyId,
      coachId: _selectedCoachId!,
      role: _selectedRole!,
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Coach assigned successfully',
          ),
        ),
      );

      Navigator.of(context).pop(true);
      return;
    }

    _showMessage(
      controller.errorMessage ??
          'Failed to assign coach',
    );
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
          'Assign Coach',
        ),
        centerTitle: true,
      ),
      body: Consumer<AcademyCoachController>(
        builder: (
            context,
            controller,
            _,
            ) {
          if (controller.isLoadingAvailable &&
              controller.availableCoaches.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.hasAvailableError &&
              controller.availableCoaches.isEmpty) {
            return _buildError(
              context,
              controller.availableErrorMessage,
            );
          }

          if (controller.availableCoaches.isEmpty) {
            return _buildEmpty(
              context,
            );
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ========================================================
                // COACH
                // ========================================================

                DropdownButtonFormField<int>(
                  initialValue: _selectedCoachId,
                  isExpanded: true,
                  decoration:
                  const InputDecoration(
                    labelText: 'Coach',
                    hintText:
                    'Select a coach',
                    prefixIcon: Icon(
                      Icons.person_outline,
                    ),
                    border:
                    OutlineInputBorder(),
                  ),
                  items: controller
                      .availableCoaches
                      .map(
                        (
                        AcademyCoachModel coach,
                        ) {
                      final name =
                      coach.fullName
                          ?.trim()
                          .isNotEmpty ==
                          true
                          ? coach.fullName!
                          : 'Coach #${coach.coachId}';

                      return DropdownMenuItem<
                          int>(
                        value:
                        coach.coachId,
                        child: Text(
                          name,
                          overflow:
                          TextOverflow
                              .ellipsis,
                        ),
                      );
                    },
                  )
                      .toList(),
                  onChanged:
                  controller.isAssigning
                      ? null
                      : (value) {
                    setState(() {
                      _selectedCoachId =
                          value;
                    });
                  },
                  validator: (value) {
                    if (value == null) {
                      return
                        'Please select a coach';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ========================================================
                // ROLE
                // ========================================================

                DropdownButtonFormField<String>(
                  initialValue:
                  _selectedRole,
                  isExpanded: true,
                  decoration:
                  const InputDecoration(
                    labelText: 'Role',
                    hintText:
                    'Select coach role',
                    prefixIcon: Icon(
                      Icons
                          .badge_outlined,
                    ),
                    border:
                    OutlineInputBorder(),
                  ),
                  items: _roles.map(
                        (role) {
                      return DropdownMenuItem<
                          String>(
                        value: role,
                        child: Text(role),
                      );
                    },
                  ).toList(),
                  onChanged:
                  controller.isAssigning
                      ? null
                      : (value) {
                    setState(() {
                      _selectedRole =
                          value;
                    });
                  },
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return
                        'Please select a role';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                // ========================================================
                // SELECTED COACH INFO
                // ========================================================

                if (_selectedCoachId != null)
                  _buildSelectedCoach(
                    controller,
                  ),

                const SizedBox(height: 28),

                // ========================================================
                // ASSIGN BUTTON
                // ========================================================

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                    controller.isAssigning
                        ? null
                        : _submit,
                    child:
                    controller.isAssigning
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
                      'Assign Coach',
                    ),
                  ),
                ),

                // ========================================================
                // ERROR
                // ========================================================

                if (controller.hasError)
                  Padding(
                    padding:
                    const EdgeInsets.only(
                      top: 14,
                    ),
                    child: Text(
                      controller.errorMessage ??
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

  // ============================================================
  // SELECTED COACH
  // ============================================================

  Widget _buildSelectedCoach(
      AcademyCoachController controller,
      ) {
    AcademyCoachModel? coach;

    for (final item
    in controller.availableCoaches) {
      if (item.coachId ==
          _selectedCoachId) {
        coach = item;
        break;
      }
    }

    if (coach == null) {
      return const SizedBox.shrink();
    }

    final name =
    coach.fullName?.trim().isNotEmpty ==
        true
        ? coach.fullName!
        : 'Coach #${coach.coachId}';

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 24,
              child: Icon(
                Icons.person_outline,
              ),
            ),
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
                      fontWeight:
                      FontWeight.w700,
                    ),
                  ),
                  if (coach.email != null &&
                      coach.email!
                          .trim()
                          .isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      coach.email!,
                      maxLines: 1,
                      overflow:
                      TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color:
                        Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
                  'Failed to load available coaches',
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<
                    AcademyCoachController>()
                    .loadAvailableCoaches(
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
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 72,
            ),
            const SizedBox(height: 16),
            const Text(
              'No available coaches',
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'There are no coaches available to assign to this academy.',
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                context
                    .read<
                    AcademyCoachController>()
                    .loadAvailableCoaches(
                  academyId:
                  widget.academyId,
                );
              },
              icon:
              const Icon(Icons.refresh),
              label:
              const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }
}