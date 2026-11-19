
import 'package:flutter/material.dart';

import '../services/academy_payment_service.dart';
import 'academy_players_screen.dart';

class AcademyPaymentsScreen extends StatefulWidget {
  const AcademyPaymentsScreen({super.key});

  @override
  State<AcademyPaymentsScreen> createState() =>
      _AcademyPaymentsScreenState();
}

class _AcademyPaymentsScreenState
    extends State<AcademyPaymentsScreen> {
  final AcademyPaymentService _service =
  AcademyPaymentService();

  List<Map<String, dynamic>> _payments = [];

  bool _loading = true;
  int? _processingPaymentId;

  String? _error;

  String _search = '';
  String _statusFilter = 'all';
  int _selectedAcademyId = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadPayments();
      }
    });
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _text(dynamic value) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? '-' : text;
  }

  int? _intId(dynamic value) {
    final id = int.tryParse(value?.toString() ?? '');

    if (id == null || id <= 0) {
      return null;
    }

    return id;
  }

  double _number(dynamic value) {
    final number = double.tryParse(
      value?.toString() ?? '',
    );

    if (number == null || !number.isFinite) {
      return 0;
    }

    return number;
  }

  String _money(dynamic value) {
    return '${_number(value).toStringAsFixed(2)} EGP';
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';

    final parsed = DateTime.tryParse(
      value.toString(),
    );

    if (parsed == null) {
      return _text(value);
    }

    final date = parsed.toLocal();

    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final hour =
    date.hour.toString().padLeft(2, '0');

    final minute =
    date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year}  $hour:$minute';
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'paid':
        return Colors.green.shade700;
      case 'pending':
        return Colors.orange.shade800;
      case 'failed':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'paid':
        return 'Approved';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Rejected';
      default:
        return status.toUpperCase();
    }
  }

  // ============================================================
  // LOAD ACADEMY PAYMENTS
  // ============================================================

  Future<void> _loadPayments() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final result = await _service.getOwnerPayments();

      if (!mounted) return;

      final academyIds = result
          .map(
            (payment) => _intId(
          payment['academy_id'],
        ),
      )
          .whereType<int>()
          .toSet();

      setState(() {
        _payments = result;

        if (_selectedAcademyId != 0 &&
            !academyIds.contains(_selectedAcademyId)) {
          _selectedAcademyId = 0;
        }
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _error = error.toString().replaceFirst(
          'Exception: ',
          '',
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  // ============================================================
  // ACADEMY FILTER OPTIONS
  // ============================================================

  Map<int, String> get _academyOptions {
    final academies = <int, String>{};

    for (final payment in _payments) {
      final academyId = _intId(
        payment['academy_id'],
      );

      if (academyId == null) continue;

      final academyName =
      payment['academy_name']?.toString().trim();

      academies[academyId] =
      academyName == null || academyName.isEmpty
          ? 'Academy #$academyId'
          : academyName;
    }

    final sorted = academies.entries.toList()
      ..sort(
            (a, b) => a.value
            .toLowerCase()
            .compareTo(b.value.toLowerCase()),
      );

    return Map<int, String>.fromEntries(sorted);
  }

  // ============================================================
  // FILTER PAYMENTS
  // ============================================================

  List<Map<String, dynamic>> get _filteredPayments {
    final keyword = _search.trim().toLowerCase();

    return _payments.where((payment) {
      final status =
          payment['status']?.toString() ?? '';

      // Filter by academy
      if (_selectedAcademyId != 0) {
        final academyId = _intId(
          payment['academy_id'],
        );

        if (academyId != _selectedAcademyId) {
          return false;
        }
      }

      // Filter by status
      if (_statusFilter != 'all' &&
          status != _statusFilter) {
        return false;
      }

      if (keyword.isEmpty) return true;

      final searchable = [
        payment['id'],
        payment['enrollment_id'],
        payment['academy_name'],
        payment['program_name'],
        payment['player_name'],
        payment['player_email'],
        payment['transaction_reference'],
      ].map(_text).join(' ').toLowerCase();

      return searchable.contains(keyword);
    }).toList();
  }

  // ============================================================
  // SUMMARY COUNTS
  // ============================================================

  List<Map<String, dynamic>> get _academyPayments {
    if (_selectedAcademyId == 0) {
      return _payments;
    }

    return _payments.where((payment) {
      return _intId(payment['academy_id']) ==
          _selectedAcademyId;
    }).toList();
  }

  int get _pendingCount {
    return _academyPayments.where((payment) {
      return payment['status'] == 'pending';
    }).length;
  }

  int get _needsReviewCount {
    return _academyPayments.where((payment) {
      final reference =
          payment['transaction_reference']
              ?.toString()
              .trim() ??
              '';

      return payment['status'] == 'pending' &&
          reference.isNotEmpty;
    }).length;
  }

  int get _awaitingReferenceCount {
    return _academyPayments.where((payment) {
      final reference =
          payment['transaction_reference']
              ?.toString()
              .trim() ??
              '';

      return payment['status'] == 'pending' &&
          reference.isEmpty;
    }).length;
  }

  double get _approvedAmount {
    return _academyPayments
        .where(
          (payment) => payment['status'] == 'paid',
    )
        .fold<double>(
      0,
          (sum, payment) =>
      sum + _number(payment['amount']),
    );
  }

  // ============================================================
  // MESSAGES
  // ============================================================

  void _showMessage(
      String message, {
        bool error = false,
      }) {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();

    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
        error ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  // ============================================================
  // REVIEW ACADEMY PAYMENT
  // ============================================================

  Future<void> _reviewPayment(
      Map<String, dynamic> payment, {
        required bool approve,
      }) async {
    if (_processingPaymentId != null ||
        _loading ||
        _error != null) {
      return;
    }

    final paymentId = _intId(
      payment['id'],
    );

    if (paymentId == null) {
      _showMessage(
        'Invalid payment ID',
        error: true,
      );
      return;
    }

    if (payment['status'] != 'pending') {
      _showMessage(
        'Only pending payments can be reviewed.',
        error: true,
      );
      return;
    }

    final reference =
        payment['transaction_reference']
            ?.toString()
            .trim() ??
            '';

    if (approve && reference.isEmpty) {
      _showMessage(
        'The player has not submitted '
            'a transaction reference.',
        error: true,
      );
      return;
    }

    // Confirm the action with the owner.
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                approve
                    ? Icons.verified_outlined
                    : Icons.cancel_outlined,
                color: approve
                    ? Colors.green
                    : Colors.red,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  approve
                      ? 'Approve Payment'
                      : 'Reject Payment',
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Payment #$paymentId',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _detailRow(
                  'Academy',
                  _text(payment['academy_name']),
                ),
                _detailRow(
                  'Program',
                  _text(payment['program_name']),
                ),
                _detailRow(
                  'Player',
                  _text(payment['player_name']),
                ),
                _detailRow(
                  'Amount',
                  _money(payment['amount']),
                ),
                _detailRow(
                  'Reference',
                  _text(
                    payment['transaction_reference'],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  approve
                      ? 'Only approve after checking '
                      'that the money was actually '
                      'received in the correct account.'
                      : 'Rejecting this payment will '
                      'mark it as failed. It will not '
                      'automatically refund any money.',
                  style: TextStyle(
                    color: approve
                        ? Colors.orange.shade900
                        : Colors.red.shade700,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor:
                approve ? Colors.green : Colors.red,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(
                approve
                    ? 'Confirm Approval'
                    : 'Confirm Rejection',
              ),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    setState(() {
      _processingPaymentId = paymentId;
    });

    try {
      if (approve) {
        await _service.approvePayment(paymentId);
      } else {
        await _service.rejectPayment(paymentId);
      }

      if (!mounted) return;

      await _loadPayments();

      if (!mounted) return;

      if (_error == null) {
        _showMessage(
          approve
              ? 'Academy payment approved successfully.'
              : 'Academy payment rejected successfully.',
        );
      } else {
        _showMessage(
          'Payment action completed, but refresh failed. '
              'Please refresh to check the latest status.',
          error: true,
        );
      }
    } catch (error) {
      if (!mounted) return;

      final message = error.toString().replaceFirst(
        'Exception: ',
        '',
      );

      // Refresh even after an error:
      // the server may have processed the request.
      await _loadPayments();

      if (!mounted) return;

      _showMessage(
        '$message. Check the payment status '
            'before retrying.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _processingPaymentId = null;
        });
      }
    }
  }

  // ============================================================
  // OPEN ACADEMY PLAYERS
  // ============================================================

  Future<void> _openAcademyPlayers(
      Map<String, dynamic> payment,
      ) async {
    final academyId = _intId(
      payment['academy_id'],
    );

    if (academyId == null) {
      _showMessage(
        'Academy ID not found',
        error: true,
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AcademyPlayersScreen(
          academyId: academyId,
        ),
      ),
    );

    if (mounted) {
      await _loadPayments();
    }
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _detailRow(
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 104,
            child: Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
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

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return SizedBox(
      width: 155,
      child: Card(
        elevation: 0,
        color: color.withValues(alpha: 0.08),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 23,
              ),
              const SizedBox(height: 10),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w900,
                  fontSize: 19,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade800,
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
  // SUMMARY SECTION
  // ============================================================

  Widget _buildSummary() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        _summaryCard(
          title: 'Total Payments',
          value: '${_academyPayments.length}',
          icon: Icons.receipt_long_outlined,
          color: Colors.blue.shade700,
        ),
        _summaryCard(
          title: 'Needs Review',
          value: '$_needsReviewCount',
          icon: Icons.fact_check_outlined,
          color: Colors.orange.shade800,
        ),
        _summaryCard(
          title: 'Waiting for Reference',
          value: '$_awaitingReferenceCount',
          icon: Icons.hourglass_empty_outlined,
          color: Colors.deepOrange.shade700,
        ),
        _summaryCard(
          title: 'Approved Amount',
          value: _money(_approvedAmount),
          icon: Icons.payments_outlined,
          color: Colors.green.shade700,
        ),
      ],
    );
  }

  // ============================================================
  // STATUS FILTER
  // ============================================================

  Widget _statusChip(
      String status,
      String title,
      ) {
    return ChoiceChip(
      label: Text(title),
      selected: _statusFilter == status,
      onSelected: (_) {
        setState(() {
          _statusFilter = status;
        });
      },
    );
  }

  // ============================================================
  // FILTER SECTION
  // ============================================================

  Widget _buildFilters() {
    final options = _academyOptions;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText:
            'Search player, program, academy or reference',
            prefixIcon: const Icon(
              Icons.search,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _search = value;
            });
          },
        ),

        const SizedBox(height: 12),

        DropdownButtonFormField<int>(
          value: _selectedAcademyId,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Academy',
            prefixIcon: const Icon(
              Icons.school_outlined,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          items: [
            const DropdownMenuItem<int>(
              value: 0,
              child: Text('All Academies'),
            ),
            ...options.entries.map(
                  (academy) => DropdownMenuItem<int>(
                value: academy.key,
                child: Text(
                  academy.value,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
          onChanged:
          _loading || _processingPaymentId != null
              ? null
              : (value) {
            if (value == null) return;

            setState(() {
              _selectedAcademyId = value;
            });
          },
        ),

        const SizedBox(height: 10),

        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _statusChip('all', 'All'),
              const SizedBox(width: 8),
              _statusChip(
                'pending',
                'Pending ($_pendingCount)',
              ),
              const SizedBox(width: 8),
              _statusChip('paid', 'Approved'),
              const SizedBox(width: 8),
              _statusChip('failed', 'Rejected'),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError() {
    if (_error == null) {
      return const SizedBox.shrink();
    }

    return Card(
      color: Colors.red.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _error!,
                style: const TextStyle(
                  color: Colors.red,
                ),
              ),
            ),
            TextButton(
              onPressed: _loading
                  ? null
                  : _loadPayments,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT CARD
  // ============================================================

  Widget _paymentCard(
      Map<String, dynamic> payment,
      ) {
    final status =
        payment['status']?.toString() ?? '';

    final paymentId = _intId(
      payment['id'],
    );

    final reference =
        payment['transaction_reference']
            ?.toString()
            .trim() ??
            '';

    final isProcessing =
        _processingPaymentId == paymentId;

    final busy =
        _loading ||
            _processingPaymentId != null ||
            _error != null;

    final canApprove =
        !busy &&
            status == 'pending' &&
            reference.isNotEmpty;

    final canReject =
        !busy && status == 'pending';

    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Payment #${_text(payment['id'])}',
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _statusColor(status),
                    ),
                  ),
                  backgroundColor: _statusColor(
                    status,
                  ).withValues(alpha: 0.1),
                ),
              ],
            ),

            const Divider(height: 24),

            _detailRow(
              'Academy',
              _text(payment['academy_name']),
            ),
            _detailRow(
              'Program',
              _text(payment['program_name']),
            ),
            _detailRow(
              'Player',
              _text(payment['player_name']),
            ),
            _detailRow(
              'Email',
              _text(payment['player_email']),
            ),
            _detailRow(
              'Enrollment',
              '#${_text(payment['enrollment_id'])}',
            ),

            const SizedBox(height: 6),

            Text(
              _money(payment['amount']),
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w900,
                color: Theme.of(context)
                    .colorScheme
                    .primary,
              ),
            ),

            const SizedBox(height: 10),

            _detailRow(
              'Method',
              _text(payment['payment_method']),
            ),
            _detailRow(
              'Reference',
              _text(
                payment['transaction_reference'],
              ),
            ),
            _detailRow(
              'Created',
              _formatDate(payment['created_at']),
            ),

            if (status == 'pending' &&
                reference.isEmpty)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Waiting for the player to submit '
                      'the transfer reference.',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            if (isProcessing) ...[
              const SizedBox(height: 14),
              const Center(
                child: CircularProgressIndicator(),
              ),
            ],

            const SizedBox(height: 12),

            if (status == 'pending')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: canReject
                          ? () => _reviewPayment(
                        payment,
                        approve: false,
                      )
                          : null,
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 18,
                      ),
                      label: const Text('Reject'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: canApprove
                          ? () => _reviewPayment(
                        payment,
                        approve: true,
                      )
                          : null,
                      icon: const Icon(
                        Icons.check_rounded,
                        size: 18,
                      ),
                      label: const Text('Approve'),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 8),

            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: busy
                    ? null
                    : () => _openAcademyPlayers(
                  payment,
                ),
                icon: const Icon(
                  Icons.people_outline,
                ),
                label: const Text(
                  'Open Academy Players',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 48,
        horizontal: 20,
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 58,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          const Text(
            'No matching payments',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Try another academy, status or search.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MAIN SCREEN
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final visiblePayments = _filteredPayments;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Academy Payments',
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Refresh payments',
            icon: const Icon(Icons.refresh),
            onPressed: _loading ||
                _processingPaymentId != null
                ? null
                : _loadPayments,
          ),
        ],
      ),

      body: _loading && _payments.isEmpty
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadPayments,
        child: ListView.builder(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            28,
          ),
          itemCount: 1 +
              (visiblePayments.isEmpty
                  ? 1
                  : visiblePayments.length),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildSummary(),

                  const SizedBox(height: 20),

                  _buildFilters(),

                  const SizedBox(height: 12),

                  _buildError(),

                  if (_loading)
                    const LinearProgressIndicator(),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(
                        Icons.list_alt_outlined,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Showing ${visiblePayments.length} payments',
                          style: const TextStyle(
                            fontWeight:
                            FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                ],
              );
            }

            if (visiblePayments.isEmpty) {
              return _buildEmptyState();
            }

            return Padding(
              padding: const EdgeInsets.only(
                bottom: 12,
              ),
              child: _paymentCard(
                visiblePayments[index - 1],
              ),
            );
          },
        ),
      ),
    );
  }
}
