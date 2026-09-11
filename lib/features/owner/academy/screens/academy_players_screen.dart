import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/enrollment_controller.dart';
import '../models/enrollment_model.dart';

class AcademyPlayersScreen extends StatefulWidget {
  final int academyId;

  const AcademyPlayersScreen({
    super.key,
    required this.academyId,
  });

  @override
  State<AcademyPlayersScreen> createState() =>
      _AcademyPlayersScreenState();
}

class _AcademyPlayersScreenState
    extends State<AcademyPlayersScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<EnrollmentController>().loadEnrollments(
        academyId: widget.academyId,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academy Players'),
        centerTitle: true,
      ),
      body: Consumer<EnrollmentController>(
        builder: (
            context,
            controller,
            _,
            ) {
          if (controller.isLoading &&
              controller.enrollments.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.hasError &&
              controller.enrollments.isEmpty) {
            return _buildError(
              context,
              controller.errorMessage,
            );
          }

          if (controller.enrollments.isEmpty) {
            return _buildEmpty(context);
          }

          return RefreshIndicator(
            onRefresh: () {
              return controller.refreshEnrollments(
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
                32,
              ),
              itemCount:
              controller.enrollments.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 12),
              itemBuilder: (
                  context,
                  index,
                  ) {
                final enrollment =
                controller.enrollments[index];

                return _EnrollmentCard(
                  enrollment: enrollment,
                  isApproving:
                  controller.isApproving,
                  isRejecting:
                  controller.isRejecting,
                  onApprove: () {
                    _approveEnrollment(
                      context,
                      controller,
                      enrollment,
                    );
                  },
                  onReject: () {
                    _rejectEnrollment(
                      context,
                      controller,
                      enrollment,
                    );
                  },
                  onDetails: () {
                    _showEnrollmentDetails(
                      context,
                      controller,
                      enrollment,
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
  // APPROVE
  // ============================================================

  Future<void> _approveEnrollment(
      BuildContext context,
      EnrollmentController controller,
      EnrollmentModel enrollment,
      ) async {
    if (enrollment.status.toLowerCase() !=
        'pending') {
      return;
    }

    final playerName =
    enrollment.playerName
        ?.trim()
        .isNotEmpty ==
        true
        ? enrollment.playerName!
        : 'this player';

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Approve Enrollment',
          ),
          content: Text(
            'Approve $playerName enrollment?',
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
                'Approve',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final result =
    await controller.approveEnrollment(
      enrollmentId:
      enrollment.enrollmentId,
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enrollment approved successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage ??
                'Failed to approve enrollment',
          ),
        ),
      );
    }
  }

  // ============================================================
  // REJECT
  // ============================================================

  Future<void> _rejectEnrollment(
      BuildContext context,
      EnrollmentController controller,
      EnrollmentModel enrollment,
      ) async {
    if (enrollment.status.toLowerCase() !=
        'pending') {
      return;
    }

    final playerName =
    enrollment.playerName
        ?.trim()
        .isNotEmpty ==
        true
        ? enrollment.playerName!
        : 'this player';

    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Reject Enrollment',
          ),
          content: Text(
            'Reject $playerName enrollment?',
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
                'Reject',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    final result =
    await controller.rejectEnrollment(
      enrollmentId:
      enrollment.enrollmentId,
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Enrollment rejected successfully',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.errorMessage ??
                'Failed to reject enrollment',
          ),
        ),
      );
    }
  }

  // ============================================================
  // DETAILS
  // ============================================================

  Future<void> _showEnrollmentDetails(
      BuildContext context,
      EnrollmentController controller,
      EnrollmentModel enrollment,
      ) async {
    final details =
    await controller.loadEnrollmentById(
      enrollmentId:
      enrollment.enrollmentId,
    );

    if (!mounted) return;

    if (details == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            controller.detailsErrorMessage ??
                'Failed to load enrollment details',
          ),
        ),
      );
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return _EnrollmentDetailsSheet(
          enrollment: details,
        );
      },
    );

    controller.clearSelectedEnrollment();
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
                  'Failed to load academy players',
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<EnrollmentController>()
                    .loadEnrollments(
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
            .read<EnrollmentController>()
            .refreshEnrollments(
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
            child: const Center(
              child: Padding(
                padding:
                EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons
                          .people_outline,
                      size: 72,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No players yet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'No enrollment requests have been received for this academy.',
                      textAlign:
                      TextAlign.center,
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
// ENROLLMENT CARD
// ============================================================================

class _EnrollmentCard
    extends StatelessWidget {
  final EnrollmentModel enrollment;
  final bool isApproving;
  final bool isRejecting;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onDetails;

  const _EnrollmentCard({
    required this.enrollment,
    required this.isApproving,
    required this.isRejecting,
    required this.onApprove,
    required this.onReject,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final playerName =
    enrollment.playerName
        ?.trim()
        .isNotEmpty ==
        true
        ? enrollment.playerName!
        : 'Player #${enrollment.playerId}';

    final status =
    enrollment.status.toLowerCase();

    final isPending =
        status == 'pending';

    return Card(
      elevation: 2,
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 27,
                  backgroundImage:
                  enrollment.profileImage !=
                      null &&
                      enrollment.profileImage!
                          .trim()
                          .isNotEmpty
                      ? NetworkImage(
                    enrollment.profileImage!,
                  )
                      : null,
                  child:
                  enrollment.profileImage ==
                      null ||
                      enrollment.profileImage!
                          .trim()
                          .isEmpty
                      ? const Icon(
                    Icons
                        .person_outline,
                    size: 28,
                  )
                      : null,
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        playerName,
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
                      const SizedBox(
                        height: 5,
                      ),
                      _StatusBadge(
                        status: status,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (enrollment.playerEmail != null &&
                enrollment.playerEmail!
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(height: 14),
              _DetailRow(
                icon:
                Icons.email_outlined,
                text:
                enrollment.playerEmail!,
              ),
            ],

            if (enrollment.playerPhone != null &&
                enrollment.playerPhone!
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(height: 8),
              _DetailRow(
                icon:
                Icons.phone_outlined,
                text:
                enrollment.playerPhone!,
              ),
            ],

            const SizedBox(height: 12),

            _DetailRow(
              icon:
              Icons.menu_book_outlined,
              text:
              enrollment.programName ??
                  'No specific program',
            ),

            const SizedBox(height: 8),

            if (enrollment.enrolledAt != null)
              _DetailRow(
                icon:
                Icons.calendar_today_outlined,
                text:
                _formatDate(
                  enrollment.enrolledAt!,
                ),
              ),

            const SizedBox(height: 14),

            const Divider(height: 1),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDetails,
                  child:
                  const Text('Details'),
                ),

                if (isPending) ...[
                  TextButton(
                    onPressed:
                    isRejecting ||
                        isApproving
                        ? null
                        : onReject,
                    child:
                    isRejecting
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,
                      ),
                    )
                        : const Text(
                      'Reject',
                    ),
                  ),

                  const SizedBox(width: 4),

                  FilledButton(
                    onPressed:
                    isApproving ||
                        isRejecting
                        ? null
                        : onApprove,
                    child:
                    isApproving
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child:
                      CircularProgressIndicator(
                        strokeWidth:
                        2,
                      ),
                    )
                        : const Text(
                      'Approve',
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(
      DateTime date,
      ) {
    final year =
    date.year.toString();

    final month =
    date.month.toString().padLeft(
      2,
      '0',
    );

    final day =
    date.day.toString().padLeft(
      2,
      '0',
    );

    final hour =
    date.hour.toString().padLeft(
      2,
      '0',
    );

    final minute =
    date.minute.toString().padLeft(
      2,
      '0',
    );

    return '$year-$month-$day  $hour:$minute';
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge
    extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius:
        BorderRadius.circular(20),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
      ),
      child: Text(
        _capitalize(status),
        style: const TextStyle(
          fontSize: 12,
          fontWeight:
          FontWeight.w700,
        ),
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) {
      return value;
    }

    return value[0].toUpperCase() +
        value.substring(1);
  }
}

// ============================================================================
// DETAIL ROW
// ============================================================================

class _DetailRow
    extends StatelessWidget {
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

// ============================================================================
// DETAILS SHEET
// ============================================================================

class _EnrollmentDetailsSheet
    extends StatelessWidget {
  final EnrollmentModel enrollment;

  const _EnrollmentDetailsSheet({
    required this.enrollment,
  });

  @override
  Widget build(BuildContext context) {
    final playerName =
    enrollment.playerName
        ?.trim()
        .isNotEmpty ==
        true
        ? enrollment.playerName!
        : 'Player #${enrollment.playerId}';

    return SafeArea(
      child: SingleChildScrollView(
        padding:
        const EdgeInsets.fromLTRB(
          20,
          8,
          20,
          32,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Text(
              'Enrollment Details',
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(
                fontWeight:
                FontWeight.w700,
              ),
            ),

            const SizedBox(height: 20),

            _SheetInfo(
              label: 'Player',
              value: playerName,
            ),

            _SheetInfo(
              label: 'Status',
              value: enrollment.status,
            ),

            if (enrollment.playerEmail != null)
              _SheetInfo(
                label: 'Email',
                value:
                enrollment.playerEmail!,
              ),

            if (enrollment.playerPhone != null)
              _SheetInfo(
                label: 'Phone',
                value:
                enrollment.playerPhone!,
              ),

            _SheetInfo(
              label: 'Program',
              value:
              enrollment.programName ??
                  'No specific program',
            ),

            if (enrollment.programLevel != null)
              _SheetInfo(
                label: 'Level',
                value:
                enrollment.programLevel!,
              ),

            if (enrollment.programPrice != null)
              _SheetInfo(
                label: 'Program Price',
                value:
                '${enrollment.programPrice} EGP',
              ),

            if (enrollment
                .programDurationWeeks !=
                null)
              _SheetInfo(
                label: 'Duration',
                value:
                '${enrollment.programDurationWeeks} weeks',
              ),

            if (enrollment.academyName != null)
              _SheetInfo(
                label: 'Academy',
                value:
                enrollment.academyName!,
              ),

            if (enrollment.enrolledAt != null)
              _SheetInfo(
                label: 'Enrolled At',
                value:
                enrollment.enrolledAt!
                    .toLocal()
                    .toString(),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// SHEET INFO
// ============================================================================

class _SheetInfo extends StatelessWidget {
  final String label;
  final String value;

  const _SheetInfo({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 16,
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color:
              Colors.grey.shade600,
              fontWeight:
              FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style:
            const TextStyle(
              fontSize: 15,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}