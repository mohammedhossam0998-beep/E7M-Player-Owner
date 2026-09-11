import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/competition_payment_model.dart';
import '../providers/competition_provider.dart';

class CompetitionPaymentsScreen extends StatefulWidget {
  const CompetitionPaymentsScreen({super.key});

  @override
  State<CompetitionPaymentsScreen> createState() =>
      _CompetitionPaymentsScreenState();
}

class _CompetitionPaymentsScreenState
    extends State<CompetitionPaymentsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompetitionProvider>().loadPayments();
    });
  }

  // ============================================================
  // REFRESH
  // ============================================================

  Future<void> _refresh() async {
    await context.read<CompetitionProvider>().loadPayments();
  }

  // ============================================================
  // APPROVE PAYMENT
  // ============================================================

  Future<void> _approvePayment(
      CompetitionPaymentModel payment,
      ) async {
    final confirmed = await _showConfirmDialog(
      title: 'Approve Competition Payment',
      message:
      'Are you sure you want to approve this competition payment?',
      confirmText: 'Approve',
      isDanger: false,
    );

    if (!confirmed || !mounted) return;

    final provider = context.read<CompetitionProvider>();

    final result = await provider.approveCompetitionPayment(
      payment.id,
    );

    if (!mounted) return;

    if (result != null) {
      _showSnackBar(
        'Competition payment approved successfully',
        isError: false,
      );
    } else {
      _showSnackBar(
        provider.errorMessage ??
            'Failed to approve competition payment',
        isError: true,
      );
    }
  }

  // ============================================================
  // REJECT PAYMENT
  // ============================================================

  Future<void> _rejectPayment(
      CompetitionPaymentModel payment,
      ) async {
    final controller = TextEditingController();

    final reason = await showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reject Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter the reason for rejecting this payment.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Rejection reason',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(null);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  controller.text.trim(),
                );
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (reason == null || !mounted) return;

    final provider = context.read<CompetitionProvider>();

    final result = await provider.rejectCompetitionPayment(
      payment.id,
      rejectionReason: reason.isEmpty ? null : reason,
    );

    if (!mounted) return;

    if (result != null) {
      _showSnackBar(
        'Competition payment rejected successfully',
        isError: false,
      );
    } else {
      _showSnackBar(
        provider.errorMessage ??
            'Failed to reject competition payment',
        isError: true,
      );
    }
  }

  // ============================================================
  // CONFIRM DIALOG
  // ============================================================

  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required bool isDanger,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isDanger ? Colors.red : null,
                foregroundColor:
                isDanger ? Colors.white : null,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  // ============================================================
  // SNACKBAR
  // ============================================================

  void _showSnackBar(
      String message, {
        required bool isError,
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
          isError ? Colors.red : Colors.green,
        ),
      );
  }

  // ============================================================
  // STATUS TEXT
  // ============================================================

  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';

      case 'submitted':
        return 'Submitted';

      case 'paid':
        return 'Paid';

      case 'failed':
        return 'Rejected';

      case 'expired':
        return 'Expired';

      case 'refunded':
        return 'Refunded';

      case 'partially_refunded':
        return 'Partially Refunded';

      default:
        return status;
    }
  }

  // ============================================================
  // STATUS COLOR
  // ============================================================

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;

      case 'submitted':
        return Colors.blue;

      case 'paid':
        return Colors.green;

      case 'failed':
        return Colors.red;

      case 'expired':
        return Colors.grey;

      case 'refunded':
        return Colors.purple;

      case 'partially_refunded':
        return Colors.deepPurple;

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // PAYMENT METHOD
  // ============================================================

  String _paymentMethodText(String? method) {
    switch (method?.toLowerCase()) {
      case 'instapay':
        return 'InstaPay';

      case 'vodafone_cash':
        return 'Vodafone Cash';

      case 'orange_cash':
        return 'Orange Cash';

      case 'etisalat_cash':
        return 'Etisalat Cash';

      case 'cash':
        return 'Cash';

      default:
        return method == null || method.trim().isEmpty
            ? 'Unknown'
            : method;
    }
  }

  // ============================================================
  // PROOF IMAGE URL
  // ============================================================

  String _buildProofImageUrl(String url) {
    final trimmedUrl = url.trim();

    if (trimmedUrl.startsWith('http://') ||
        trimmedUrl.startsWith('https://')) {
      return trimmedUrl;
    }

    if (trimmedUrl.startsWith('/')) {
      return 'http://192.168.1.2:5000$trimmedUrl';
    }

    return 'http://192.168.1.2:5000/$trimmedUrl';
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }

    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final year =
    date.year.toString();

    return '$day/$month/$year';
  }

  // ============================================================
  // DATE + TIME
  // ============================================================

  String _formatDateTime(DateTime? date) {
    if (date == null) {
      return 'N/A';
    }

    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final year =
    date.year.toString();

    final hour =
    date.hour.toString().padLeft(2, '0');

    final minute =
    date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year  $hour:$minute';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Competition Payments',
        ),
        actions: [
          Consumer<CompetitionProvider>(
            builder: (
                context,
                provider,
                child,
                ) {
              return IconButton(
                onPressed:
                provider.isLoading
                    ? null
                    : _refresh,
                icon: const Icon(
                  Icons.refresh,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<CompetitionProvider>(
        builder: (
            context,
            provider,
            child,
            ) {
          return _buildBody(provider);
        },
      ),
    );
  }

  // ============================================================
  // BODY
  // ============================================================

  Widget _buildBody(
      CompetitionProvider provider,
      ) {
    if (provider.isLoading &&
        provider.payments.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null &&
        provider.payments.isEmpty) {
      return _buildErrorState(provider);
    }

    if (provider.payments.isEmpty) {
      return _buildEmptyState(provider);
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummary(provider),

          const SizedBox(height: 20),

          ...provider.payments.map(
                (payment) =>
                _buildPaymentCard(
                  payment,
                  provider,
                ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(
      CompetitionProvider provider,
      ) {
    final pendingCount = provider.payments
        .where(
          (payment) =>
      payment.status.toLowerCase() ==
          'pending' ||
          payment.status.toLowerCase() ==
              'submitted',
    )
        .length;

    final paidCount = provider.payments
        .where(
          (payment) =>
      payment.status.toLowerCase() ==
          'paid',
    )
        .length;

    final rejectedCount = provider.payments
        .where(
          (payment) =>
      payment.status.toLowerCase() ==
          'failed',
    )
        .length;

    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Pending',
            value: pendingCount.toString(),
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildSummaryCard(
            title: 'Paid',
            value: paidCount.toString(),
            icon:
            Icons.check_circle_outline,
            color: Colors.green,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildSummaryCard(
            title: 'Rejected',
            value:
            rejectedCount.toString(),
            icon: Icons.cancel_outlined,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // SUMMARY CARD
  // ============================================================

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding:
        const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 26,
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight:
                FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              title,
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PAYMENT CARD
  // ============================================================

  Widget _buildPaymentCard(
      CompetitionPaymentModel payment,
      CompetitionProvider provider,
      ) {
    final statusColor =
    _statusColor(payment.status);

    final status =
    payment.status.toLowerCase();

    final isActionable =
        status == 'submitted' ||
            status == 'pending';

    final isProcessing =
        provider.isLoading;

    return Card(
      margin:
      const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ====================================================
            // HEADER
            // ====================================================

            Row(
              children: [
                Expanded(
                  child: Text(
                    'Payment #${payment.id}',
                    style:
                    const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
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
                    color: statusColor
                        .withOpacity(0.12),
                    borderRadius:
                    BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Text(
                    _statusText(
                      payment.status,
                    ),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight:
                      FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ====================================================
            // COMPETITION
            // ====================================================

            _infoRow(
              icon:
              Icons.emoji_events_outlined,
              label: 'Competition',
              value:
              payment.competitionName ??
                  'Unknown',
            ),

            // ====================================================
            // PLAYER
            // ====================================================

            _infoRow(
              icon:
              Icons.person_outline,
              label: 'Player',
              value:
              payment.playerName ??
                  'Unknown',
            ),

            // ====================================================
            // EMAIL
            // ====================================================

            _infoRow(
              icon:
              Icons.email_outlined,
              label: 'Email',
              value:
              payment.playerEmail ??
                  'N/A',
            ),

            // ====================================================
            // AMOUNT
            // ====================================================

            _infoRow(
              icon:
              Icons.payments_outlined,
              label: 'Amount',
              value:
              '${payment.amount.toStringAsFixed(2)} ${payment.currency}',
            ),

            // ====================================================
            // PAYMENT METHOD
            // ====================================================

            _infoRow(
              icon: Icons
                  .account_balance_wallet_outlined,
              label: 'Method',
              value:
              _paymentMethodText(
                payment.paymentMethod,
              ),
            ),

            // ====================================================
            // TRANSACTION
            // ====================================================

            _infoRow(
              icon: Icons.tag,
              label: 'Transaction',
              value:
              payment.transactionReference ??
                  'Not submitted',
            ),

            // ====================================================
            // OWNER ACCOUNT
            // ====================================================

            if (payment.accountName != null &&
                payment.accountName!
                    .trim()
                    .isNotEmpty)
              _infoRow(
                icon:
                Icons.account_balance_outlined,
                label: 'Account',
                value:
                payment.accountName!,
              ),

            if (payment.accountIdentifier !=
                null &&
                payment.accountIdentifier!
                    .trim()
                    .isNotEmpty)
              _infoRow(
                icon: Icons.numbers,
                label: 'Account ID',
                value:
                payment.accountIdentifier!,
              ),

            // ====================================================
            // SUBMITTED DATE
            // ====================================================

            if (payment.submittedAt != null)
              _infoRow(
                icon:
                Icons.upload_outlined,
                label: 'Submitted',
                value:
                _formatDateTime(
                  payment.submittedAt,
                ),
              ),

            // ====================================================
            // PAYMENT DEADLINE
            // ====================================================

            if (payment.paymentDeadline !=
                null)
              _infoRow(
                icon:
                Icons.timer_outlined,
                label: 'Deadline',
                value:
                _formatDateTime(
                  payment.paymentDeadline,
                ),
              ),

            // ====================================================
            // REJECTION REASON
            // ====================================================

            if (payment.rejectionReason !=
                null &&
                payment.rejectionReason!
                    .trim()
                    .isNotEmpty)
              Container(
                width: double.infinity,
                margin:
                const EdgeInsets.only(
                  top: 8,
                ),
                padding:
                const EdgeInsets.all(12),
                decoration:
                BoxDecoration(
                  color: Colors.red
                      .withOpacity(0.08),
                  borderRadius:
                  BorderRadius.circular(
                    10,
                  ),
                  border: Border.all(
                    color: Colors.red
                        .withOpacity(0.25),
                  ),
                ),
                child: Row(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.red,
                      size: 20,
                    ),

                    const SizedBox(
                      width: 8,
                    ),

                    Expanded(
                      child: Text(
                        'Rejection reason: ${payment.rejectionReason}',
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
              ),

            // ====================================================
            // PAYMENT PROOF
            // ====================================================

            if (payment.proofImageUrl !=
                null &&
                payment.proofImageUrl!
                    .trim()
                    .isNotEmpty) ...[
              const SizedBox(height: 14),

              const Text(
                'Payment Proof',
                style:
                TextStyle(
                  fontSize: 15,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              GestureDetector(
                onTap: () {
                  _showProofImage(
                    payment.proofImageUrl!,
                  );
                },
                child: Container(
                  height: 180,
                  width: double.infinity,
                  decoration:
                  BoxDecoration(
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                    border: Border.all(
                      color:
                      Colors.grey.shade300,
                    ),
                  ),
                  clipBehavior:
                  Clip.antiAlias,
                  child: Image.network(
                    _buildProofImageUrl(
                      payment.proofImageUrl!,
                    ),
                    fit: BoxFit.cover,
                    errorBuilder:
                        (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return Container(
                        alignment:
                        Alignment.center,
                        color:
                        Colors.grey.shade100,
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                          children: const [
                            Icon(
                              Icons
                                  .broken_image_outlined,
                              size: 40,
                            ),
                            SizedBox(
                              height: 8,
                            ),
                            Text(
                              'Unable to load proof image',
                            ),
                          ],
                        ),
                      );
                    },
                    loadingBuilder:
                        (
                        context,
                        child,
                        loadingProgress,
                        ) {
                      if (loadingProgress ==
                          null) {
                        return child;
                      }

                      return const Center(
                        child:
                        CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ),
            ],

            // ====================================================
            // ACTIONS
            // ====================================================

            if (isActionable) ...[
              const SizedBox(height: 16),

              if (isProcessing)
                const Center(
                  child:
                  CircularProgressIndicator(),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child:
                      OutlinedButton.icon(
                        onPressed: () =>
                            _rejectPayment(
                              payment,
                            ),
                        icon:
                        const Icon(
                          Icons.close,
                        ),
                        label:
                        const Text(
                          'Reject',
                        ),
                        style:
                        OutlinedButton
                            .styleFrom(
                          foregroundColor:
                          Colors.red,
                        ),
                      ),
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Expanded(
                      child:
                      ElevatedButton
                          .icon(
                        onPressed: () =>
                            _approvePayment(
                              payment,
                            ),
                        icon:
                        const Icon(
                          Icons.check,
                        ),
                        label:
                        const Text(
                          'Approve',
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PROOF IMAGE
  // ============================================================

  void _showProofImage(
      String imageUrl,
      ) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: InteractiveViewer(
            child: Image.network(
              _buildProofImageUrl(
                imageUrl,
              ),
              fit: BoxFit.contain,
              errorBuilder:
                  (
                  context,
                  error,
                  stackTrace,
                  ) {
                return const SizedBox(
                  height: 300,
                  child: Center(
                    child: Text(
                      'Unable to load proof image',
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
      CompetitionProvider provider,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color: Colors.red,
            ),

            const SizedBox(
              height: 16,
            ),

            Text(
              provider.errorMessage ??
                  'Something went wrong',
              textAlign:
              TextAlign.center,
            ),

            const SizedBox(
              height: 20,
            ),

            ElevatedButton.icon(
              onPressed:
              provider.loadPayments,
              icon:
              const Icon(
                Icons.refresh,
              ),
              label:
              const Text(
                'Try Again',
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

  Widget _buildEmptyState(
      CompetitionProvider provider,
      ) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),

          Icon(
            Icons.payments_outlined,
            size: 64,
          ),

          SizedBox(height: 16),

          Center(
            child: Text(
              'No competition payments found',
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 8),

          Center(
            child: Text(
              'Competition payment requests will appear here',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(
        bottom: 10,
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
          ),

          const SizedBox(
            width: 10,
          ),

          SizedBox(
            width: 95,
            child: Text(
              label,
              style:
              const TextStyle(
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: Text(
              value,
              maxLines: 3,
              overflow:
              TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}