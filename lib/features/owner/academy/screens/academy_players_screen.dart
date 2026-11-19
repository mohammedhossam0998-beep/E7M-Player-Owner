
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/enrollment_controller.dart';
import '../models/enrollment_model.dart';
import '../services/academy_payment_service.dart';
import 'academy_payments_screen.dart';

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
  final AcademyPaymentService _paymentService =
  AcademyPaymentService();

  List<Map<String, dynamic>> _payments = [];

  bool _refreshing = false;
  bool _paymentsLoaded = false;
  int? _processingEnrollmentId;

  String? _paymentError;
  String _search = '';
  String _enrollmentFilter = 'all';
  String _paymentFilter = 'all';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _refreshData();
      }
    });
  }

  // ============================================================
  // LOAD ENROLLMENTS AND PAYMENTS
  // ============================================================

  Future<void> _refreshData() async {
    if (!mounted || _refreshing) return;

    setState(() {
      _refreshing = true;
      _paymentsLoaded = false;
      _paymentError = null;
    });

    final controller =
    context.read<EnrollmentController>();

    // Refresh enrollments using the existing controller.
    final enrollmentFuture =
    controller.refreshEnrollments(
      academyId: widget.academyId,
    );

    // Payments are loaded independently.
    // Never show "unpaid" if the request failed.
    try {
      final payments =
      await _paymentService.getOwnerPayments();

      if (mounted) {
        setState(() {
          _payments = payments.where((payment) {
            final academyId = _parseId(
              payment['academy_id'],
            );

            return academyId == widget.academyId;
          }).toList();

          _paymentsLoaded = true;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _payments = [];
          _paymentsLoaded = false;
          _paymentError = _cleanError(error);
        });
      }
    }

    await enrollmentFuture;

    if (mounted) {
      setState(() {
        _refreshing = false;
      });
    }
  }

  // ============================================================
  // HELPERS
  // ============================================================

  int? _parseId(dynamic value) {
    final id = int.tryParse(
      value?.toString() ?? '',
    );

    if (id == null || id <= 0) {
      return null;
    }

    return id;
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst('Exception: ', '');
  }

  String _text(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }

    return value.trim();
  }

  String _playerName(EnrollmentModel enrollment) {
    final name = enrollment.playerName;

    if (name != null && name.trim().isNotEmpty) {
      return name.trim();
    }

    return 'Player #${enrollment.playerId}';
  }

  String _money(double? value) {
    if (value == null || !value.isFinite) {
      return '-';
    }

    return '${value.toStringAsFixed(2)} EGP';
  }

  String _date(DateTime? value) {
    if (value == null) return '-';

    final local = value.toLocal();

    final day =
    local.day.toString().padLeft(2, '0');

    final month =
    local.month.toString().padLeft(2, '0');

    return '$day/$month/${local.year}';
  }

  void _message(
      String value, {
        bool error = false,
      }) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(value),
        backgroundColor:
        error ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // PAYMENT STATUS FOR ONE ENROLLMENT
  // ============================================================

  _EnrollmentPaymentInfo _paymentInfo(
      EnrollmentModel enrollment,
      ) {
    // Free program.
    if (enrollment.programPrice != null &&
        enrollment.programPrice == 0) {
      return const _EnrollmentPaymentInfo(
        status: 'free',
      );
    }

    // Do not interpret an API failure as "unpaid".
    if (!_paymentsLoaded || _paymentError != null) {
      return const _EnrollmentPaymentInfo(
        status: 'unknown',
      );
    }

    final matches = _payments.where((payment) {
      return _parseId(payment['enrollment_id']) ==
          enrollment.enrollmentId;
    }).toList();

    if (matches.isEmpty) {
      return const _EnrollmentPaymentInfo(
        status: 'none',
      );
    }

    // An approved payment takes priority, even if
    // older rejected attempts also exist.
    for (final payment in matches) {
      if (payment['status'] == 'paid') {
        return _EnrollmentPaymentInfo(
          status: 'paid',
          payment: payment,
        );
      }
    }

    // A pending payment with a reference
    // is ready for the owner to review.
    for (final payment in matches) {
      final reference =
          payment['transaction_reference']
              ?.toString()
              .trim() ??
              '';

      if (payment['status'] == 'pending' &&
          reference.isNotEmpty) {
        return _EnrollmentPaymentInfo(
          status: 'review',
          payment: payment,
        );
      }
    }

    // Payment created but no transfer reference yet.
    for (final payment in matches) {
      if (payment['status'] == 'pending') {
        return _EnrollmentPaymentInfo(
          status: 'awaiting',
          payment: payment,
        );
      }
    }

    for (final payment in matches) {
      if (payment['status'] == 'failed') {
        return _EnrollmentPaymentInfo(
          status: 'failed',
          payment: payment,
        );
      }
    }

    return const _EnrollmentPaymentInfo(
      status: 'unknown',
    );
  }

  // ============================================================
  // PAYMENT LABELS
  // ============================================================

  String _paymentLabel(String status) {
    switch (status) {
      case 'free':
        return 'Free Program';
      case 'paid':
        return 'Payment Confirmed';
      case 'review':
        return 'Needs Payment Review';
      case 'awaiting':
        return 'Waiting for Transfer';
      case 'failed':
        return 'Payment Rejected';
      case 'none':
        return 'No Payment Recorded';
      default:
        return 'Payment Status Unknown';
    }
  }

  Color _paymentColor(String status) {
    switch (status) {
      case 'paid':
      case 'free':
        return Colors.green.shade700;
      case 'review':
        return Colors.deepOrange.shade700;
      case 'awaiting':
        return Colors.orange.shade800;
      case 'failed':
        return Colors.red.shade700;
      case 'none':
        return Colors.blueGrey;
      default:
        return Colors.grey.shade700;
    }
  }

  Color _enrollmentColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green.shade700;
      case 'pending':
        return Colors.orange.shade800;
      case 'rejected':
        return Colors.red.shade700;
      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // APPROVAL RULES
  // ============================================================

  bool _canApprove(
      EnrollmentModel enrollment,
      _EnrollmentPaymentInfo payment,
      ) {
    if (enrollment.status.toLowerCase() != 'pending') {
      return false;
    }

    final price = enrollment.programPrice;

    // Unknown price must be checked on the server.
    if (price == null || !price.isFinite || price < 0) {
      return false;
    }

    if (price == 0) {
      return true;
    }

    return payment.status == 'paid';
  }

  bool _canReject(
      EnrollmentModel enrollment,
      _EnrollmentPaymentInfo payment,
      ) {
    if (enrollment.status.toLowerCase() != 'pending') {
      return false;
    }

    // Do not allow rejecting when payment data
    // could not be verified.
    if (payment.status == 'unknown') {
      return false;
    }

    // A pending or paid transfer needs payment
    // review/refund handling first.
    return ![
      'paid',
      'review',
      'awaiting',
    ].contains(payment.status);
  }

  // ============================================================
  // FILTER ENROLLMENTS
  // ============================================================

  List<EnrollmentModel> _filtered(
      List<EnrollmentModel> enrollments,
      ) {
    final query = _search.trim().toLowerCase();

    return enrollments.where((enrollment) {
      final payment = _paymentInfo(enrollment);

      if (_enrollmentFilter != 'all' &&
          enrollment.status.toLowerCase() !=
              _enrollmentFilter) {
        return false;
      }

      if (_paymentFilter != 'all' &&
          payment.status != _paymentFilter) {
        return false;
      }

      if (query.isEmpty) {
        return true;
      }

      final content = [
        _playerName(enrollment),
        enrollment.playerEmail ?? '',
        enrollment.playerPhone ?? '',
        enrollment.programName ?? '',
        enrollment.enrollmentId.toString(),
        enrollment.playerId.toString(),
        payment.payment?['transaction_reference']
            ?.toString() ??
            '',
      ].join(' ').toLowerCase();

      return content.contains(query);
    }).toList();
  }

  // ============================================================
  // OPEN PAYMENT REVIEW
  // ============================================================

  Future<void> _openPayments() async {
    if (_processingEnrollmentId != null) return;

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AcademyPaymentsScreen(),
      ),
    );

    if (mounted) {
      await _refreshData();
    }
  }

  // ============================================================
  // APPROVE / REJECT ENROLLMENT
  // ============================================================

  Future<void> _reviewEnrollment(
      EnrollmentModel enrollment, {
        required bool approve,
      }) async {
    if (_processingEnrollmentId != null ||
        _refreshing) {
      return;
    }

    final payment = _paymentInfo(enrollment);

    if (approve &&
        !_canApprove(enrollment, payment)) {
      _message(
        'A paid program needs a confirmed payment '
            'before enrollment approval.',
        error: true,
      );
      return;
    }

    if (!approve &&
        !_canReject(enrollment, payment)) {
      _message(
        'Review the pending or paid transaction '
            'before rejecting this enrollment.',
        error: true,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            approve
                ? 'Approve Enrollment'
                : 'Reject Enrollment',
          ),
          content: Text(
            '${approve ? 'Approve' : 'Reject'} '
                '${_playerName(enrollment)}?\n\n'
                'Program: ${_text(enrollment.programName)}\n'
                'Price: ${_money(enrollment.programPrice)}\n'
                'Payment: ${_paymentLabel(payment.status)}',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(dialogContext, true),
              child: Text(
                approve ? 'Approve' : 'Reject',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) return;

    setState(() {
      _processingEnrollmentId =
          enrollment.enrollmentId;
    });

    final controller =
    context.read<EnrollmentController>();

    try {
      final result = approve
          ? await controller.approveEnrollment(
        enrollmentId: enrollment.enrollmentId,
      )
          : await controller.rejectEnrollment(
        enrollmentId: enrollment.enrollmentId,
      );

      if (!mounted) return;

      final errorText = controller.errorMessage;

      // Re-fetch the latest server state.
      await _refreshData();

      if (!mounted) return;

      if (result != null) {
        _message(
          approve
              ? 'Enrollment approved successfully.'
              : 'Enrollment rejected successfully.',
        );
      } else {
        _message(
          errorText ??
              'Could not update enrollment.',
          error: true,
        );
      }
    } catch (error) {
      if (!mounted) return;

      _message(
        _cleanError(error),
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingEnrollmentId = null;
        });
      }
    }
  }

  // ============================================================
  // DETAILS
  // ============================================================

  Future<void> _showDetails(
      EnrollmentModel enrollment,
      ) async {
    final controller =
    context.read<EnrollmentController>();

    final details = await controller.loadEnrollmentById(
      enrollmentId: enrollment.enrollmentId,
    );

    if (!mounted) return;

    if (details == null) {
      _message(
        controller.detailsErrorMessage ??
            'Failed to load enrollment details.',
        error: true,
      );
      return;
    }

    // The details endpoint returns a minimal enrollment.
    // Preserve player/program fields from the list.
    final current = enrollment.copyWith(
      status: details.status,
      enrolledAt: details.enrolledAt,
    );

    final payment = _paymentInfo(current);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20, 8, 20, 32,
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Enrollment Details',
                  style: Theme.of(sheetContext)
                      .textTheme
                      .titleLarge,
                ),
                const SizedBox(height: 16),
                _detailRow(
                  'Player',
                  _playerName(current),
                ),
                _detailRow(
                  'Email',
                  _text(current.playerEmail),
                ),
                _detailRow(
                  'Phone',
                  _text(current.playerPhone),
                ),
                _detailRow(
                  'Enrollment ID',
                  '#${current.enrollmentId}',
                ),
                _detailRow(
                  'Enrollment Status',
                  current.status,
                ),
                _detailRow(
                  'Program',
                  _text(current.programName),
                ),
                _detailRow(
                  'Level',
                  _text(current.programLevel),
                ),
                _detailRow(
                  'Price',
                  _money(current.programPrice),
                ),
                _detailRow(
                  'Duration',
                  current.programDurationWeeks == null
                      ? '-'
                      : '${current.programDurationWeeks} weeks',
                ),
                _detailRow(
                  'Payment Status',
                  _paymentLabel(payment.status),
                ),
                _detailRow(
                  'Transaction Reference',
                  payment.payment?[
                  'transaction_reference']
                      ?.toString() ??
                      '-',
                ),
                _detailRow(
                  'Enrollment Date',
                  _date(current.enrolledAt),
                ),
              ],
            ),
          ),
        );
      },
    );

    controller.clearSelectedEnrollment();
  }

  Widget _detailRow(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _summaryCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return SizedBox(
      width: 155,
      child: Card(
        color: color.withValues(alpha: 0.08),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Widget _filters() {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            hintText:
            'Search player, program or enrollment',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _search = value;
            });
          },
        ),
        const SizedBox(height: 10),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _statusFilterChip('all', 'All'),
              const SizedBox(width: 6),
              _statusFilterChip('pending', 'Pending'),
              const SizedBox(width: 6),
              _statusFilterChip('approved', 'Approved'),
              const SizedBox(width: 6),
              _statusFilterChip('rejected', 'Rejected'),
            ],
          ),
        ),

        const SizedBox(height: 8),

        DropdownButtonFormField<String>(
          value: _paymentFilter,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Payment Status',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'all',
              child: Text('All Payment Statuses'),
            ),
            DropdownMenuItem(
              value: 'paid',
              child: Text('Payment Confirmed'),
            ),
            DropdownMenuItem(
              value: 'review',
              child: Text('Needs Payment Review'),
            ),
            DropdownMenuItem(
              value: 'awaiting',
              child: Text('Waiting for Transfer'),
            ),
            DropdownMenuItem(
              value: 'none',
              child: Text('No Payment Recorded'),
            ),
            DropdownMenuItem(
              value: 'failed',
              child: Text('Payment Rejected'),
            ),
            DropdownMenuItem(
              value: 'free',
              child: Text('Free Programs'),
            ),
            DropdownMenuItem(
              value: 'unknown',
              child: Text('Payment Status Unknown'),
            ),
          ],
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _paymentFilter = value;
            });
          },
        ),
      ],
    );
  }

  Widget _statusFilterChip(
      String value,
      String title,
      ) {
    return ChoiceChip(
      label: Text(title),
      selected: _enrollmentFilter == value,
      onSelected: (_) {
        setState(() {
          _enrollmentFilter = value;
        });
      },
    );
  }

  // ============================================================
  // ENROLLMENT CARD
  // ============================================================

  Widget _enrollmentCard(
      EnrollmentModel enrollment,
      ) {
    final payment = _paymentInfo(enrollment);

    final enrollmentStatus =
    enrollment.status.toLowerCase();

    final canApprove =
    _canApprove(enrollment, payment);

    final canReject =
    _canReject(enrollment, payment);

    final busy =
        _refreshing ||
            _processingEnrollmentId != null;

    final processing =
        _processingEnrollmentId ==
            enrollment.enrollmentId;

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
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
                const CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.person_outline),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        _playerName(enrollment),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _text(enrollment.playerEmail),
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enrollment #${enrollment.enrollmentId}',
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const Divider(height: 25),

            Text(
              _text(enrollment.programName),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 5),

            Text(
              'Program Price: '
                  '${_money(enrollment.programPrice)}',
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Chip(
                  label: Text(
                    'Enrollment: $enrollmentStatus',
                  ),
                  backgroundColor: _enrollmentColor(
                    enrollmentStatus,
                  ).withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: _enrollmentColor(
                      enrollmentStatus,
                    ),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Chip(
                  label: Text(
                    _paymentLabel(payment.status),
                  ),
                  backgroundColor: _paymentColor(
                    payment.status,
                  ).withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: _paymentColor(
                      payment.status,
                    ),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            if (processing) ...[
              const SizedBox(height: 10),
              const LinearProgressIndicator(),
            ],

            if (enrollmentStatus == 'pending' &&
                !canApprove &&
                payment.status == 'review')
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Review the submitted payment '
                      'before approving this player.',
                  style: TextStyle(
                    color: Colors.deepOrange,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: busy
                      ? null
                      : () => _showDetails(enrollment),
                  child: const Text('Details'),
                ),

                if (enrollmentStatus == 'pending') ...[
                  OutlinedButton(
                    onPressed: busy || !canReject
                        ? null
                        : () => _reviewEnrollment(
                      enrollment,
                      approve: false,
                    ),
                    child: const Text('Reject'),
                  ),
                  FilledButton(
                    onPressed: busy || !canApprove
                        ? null
                        : () => _reviewEnrollment(
                      enrollment,
                      approve: true,
                    ),
                    child: const Text('Approve'),
                  ),
                ],

                if (payment.status == 'review' ||
                    payment.status == 'awaiting')
                  TextButton.icon(
                    onPressed: busy
                        ? null
                        : _openPayments,
                    icon: const Icon(
                      Icons.payments_outlined,
                    ),
                    label: const Text('View Payments'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academy Players'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Academy Payments',
            icon: const Icon(Icons.payments_outlined),
            onPressed: _openPayments,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _refreshing
                ? null
                : _refreshData,
          ),
        ],
      ),

      body: Consumer<EnrollmentController>(
        builder: (context, controller, _) {
          if (_refreshing &&
              controller.enrollments.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.hasError &&
              controller.enrollments.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      controller.errorMessage ??
                          'Failed to load academy players',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _refreshData,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final enrollments =
          controller.enrollments.where((item) {
            return item.academyId == widget.academyId;
          }).toList();

          final visible = _filtered(enrollments);

          final pending = enrollments.where((item) {
            return item.status.toLowerCase() ==
                'pending';
          }).length;

          final confirmed = enrollments.where((item) {
            return _paymentInfo(item).status == 'paid';
          }).length;

          final needsReview = enrollments.where((item) {
            return _paymentInfo(item).status == 'review';
          }).length;

          return RefreshIndicator(
            onRefresh: _refreshData,
            child: ListView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                16, 16, 16, 32,
              ),
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _summaryCard(
                      'Total Enrollments',
                      '${enrollments.length}',
                      Icons.people_alt_outlined,
                      Colors.blue.shade700,
                    ),
                    _summaryCard(
                      'Pending Enrollments',
                      '$pending',
                      Icons.hourglass_top_outlined,
                      Colors.orange.shade800,
                    ),
                    _summaryCard(
                      'Confirmed Payments',
                      '$confirmed',
                      Icons.verified_outlined,
                      Colors.green.shade700,
                    ),
                    _summaryCard(
                      'Payments to Review',
                      '$needsReview',
                      Icons.receipt_long_outlined,
                      Colors.deepOrange.shade700,
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (_paymentError != null)
                  Card(
                    color: Colors.orange.withValues(
                      alpha: 0.1,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        'Payment data could not be loaded: '
                            '$_paymentError\n'
                            'Payment statuses are unknown. '
                            'Refresh to try again.',
                      ),
                    ),
                  ),

                if (_refreshing)
                  const LinearProgressIndicator(),

                const SizedBox(height: 16),

                _filters(),

                const SizedBox(height: 14),

                Text(
                  'Showing ${visible.length} of '
                      '${enrollments.length} enrollments',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                if (visible.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 45,
                    ),
                    child: Center(
                      child: Text(
                        'No matching academy enrollments.',
                      ),
                    ),
                  )
                else
                  ...visible.map(_enrollmentCard),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EnrollmentPaymentInfo {
  final String status;
  final Map<String, dynamic>? payment;

  const _EnrollmentPaymentInfo({
    required this.status,
    this.payment,
  });
}
