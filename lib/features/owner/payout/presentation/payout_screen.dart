import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/owner_payment_model.dart';
import '../providers/owner_payment_provider.dart';

class PayoutScreen extends StatefulWidget {
  const PayoutScreen({super.key});

  @override
  State<PayoutScreen> createState() => _PayoutScreenState();
}

class _PayoutScreenState extends State<PayoutScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<OwnerPaymentProvider>().loadPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Owner Payments'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              context.read<OwnerPaymentProvider>().refreshPayments();
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Consumer<OwnerPaymentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.payments.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (provider.errorMessage != null &&
              provider.payments.isEmpty) {
            return _buildErrorState(
              provider.errorMessage!,
              provider,
            );
          }

          if (provider.payments.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: provider.refreshPayments,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSummary(provider),
                const SizedBox(height: 20),

                if (provider.pendingPayments.isNotEmpty) ...[
                  _buildSectionTitle(
                    'Pending Payments',
                    provider.pendingCount,
                  ),
                  const SizedBox(height: 12),

                  ...provider.pendingPayments.map(
                        (payment) => _buildPaymentCard(
                      context,
                      payment,
                      provider,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],

                if (provider.paidPayments.isNotEmpty) ...[
                  _buildSectionTitle(
                    'Paid Payments',
                    provider.paidCount,
                  ),
                  const SizedBox(height: 12),

                  ...provider.paidPayments.map(
                        (payment) => _buildPaymentCard(
                      context,
                      payment,
                      provider,
                    ),
                  ),

                  const SizedBox(height: 24),
                ],

                if (provider.failedPayments.isNotEmpty) ...[
                  _buildSectionTitle(
                    'Rejected Payments',
                    provider.failedCount,
                  ),
                  const SizedBox(height: 12),

                  ...provider.failedPayments.map(
                        (payment) => _buildPaymentCard(
                      context,
                      payment,
                      provider,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(OwnerPaymentProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Pending',
            value: provider.pendingCount.toString(),
            icon: Icons.hourglass_top,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryCard(
            title: 'Paid',
            value: provider.paidCount.toString(),
            icon: Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryCard(
            title: 'Rejected',
            value: provider.failedCount.toString(),
            icon: Icons.cancel_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.color,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
      String title,
      int count,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Theme.of(context)
                .colorScheme
                .primary
                .withOpacity(0.1),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context)
                  .colorScheme
                  .primary,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT CARD
  // ============================================================

  Widget _buildPaymentCard(
      BuildContext context,
      OwnerPaymentModel payment,
      OwnerPaymentProvider provider,
      ) {
    final isPending = payment.status == 'pending';
    final isProcessing =
        provider.processingPaymentId == payment.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ----------------------------------------------------
            // HEADER
            // ----------------------------------------------------

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 23,
                  child: Text(
                    payment.playerName.isNotEmpty
                        ? payment.playerName[0]
                        .toUpperCase()
                        : '?',
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        payment.playerName.isNotEmpty
                            ? payment.playerName
                            : 'Unknown Player',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        payment.playerEmail,
                        style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color,
                        ),
                      ),
                    ],
                  ),
                ),

                _buildStatusBadge(payment.status),
              ],
            ),

            const SizedBox(height: 18),

            // ----------------------------------------------------
            // BOOKING INFO
            // ----------------------------------------------------

            _buildInfoRow(
              Icons.sports_soccer,
              'Pitch',
              payment.pitchName,
            ),

            _buildInfoRow(
              Icons.calendar_today,
              'Date',
              _formatDate(payment.slotDate),
            ),

            _buildInfoRow(
              Icons.access_time,
              'Time',
              '${payment.startTime} - ${payment.endTime}',
            ),

            _buildInfoRow(
              Icons.receipt_long,
              'Booking',
              '#${payment.bookingId}',
            ),

            const Divider(height: 24),

            // ----------------------------------------------------
            // PAYMENT INFO
            // ----------------------------------------------------

            _buildMoneyRow(
              'Total Price',
              payment.totalPrice,
            ),

            _buildMoneyRow(
              'Deposit',
              payment.depositAmount,
            ),

            _buildMoneyRow(
              'Remaining',
              payment.remainingAmount,
            ),

            _buildInfoRow(
              Icons.payment,
              'Method',
              _paymentMethodName(
                payment.paymentMethod,
              ),
            ),

            _buildInfoRow(
              Icons.category,
              'Type',
              payment.paymentType,
            ),

            if (payment.transactionReference !=
                null &&
                payment.transactionReference!
                    .trim()
                    .isNotEmpty)
              _buildInfoRow(
                Icons.tag,
                'Transaction',
                payment.transactionReference!,
              ),

            const SizedBox(height: 12),

            // ----------------------------------------------------
            // ACTIONS
            // ----------------------------------------------------

            if (isPending)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () => _rejectPayment(
                        context,
                        payment,
                        provider,
                      ),
                      icon: const Icon(
                        Icons.close,
                      ),
                      label: const Text(
                        'Reject',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: isProcessing
                          ? null
                          : () => _approvePayment(
                        context,
                        payment,
                        provider,
                      ),
                      icon: isProcessing
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(
                        Icons.check,
                      ),
                      label: Text(
                        isProcessing
                            ? 'Processing...'
                            : 'Approve',
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow(
      IconData icon,
      String title,
      String value,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
          const SizedBox(width: 9),
          Text(
            '$title: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // MONEY ROW
  // ============================================================

  Widget _buildMoneyRow(
      String title,
      double amount,
      ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)} EGP',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATUS
  // ============================================================

  Widget _buildStatusBadge(String status) {
    String text;
    IconData icon;

    switch (status) {
      case 'pending':
        text = 'Pending';
        icon = Icons.hourglass_top;
        break;

      case 'paid':
        text = 'Paid';
        icon = Icons.check_circle;
        break;

      case 'failed':
        text = 'Rejected';
        icon = Icons.cancel;
        break;

      default:
        text = status;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // APPROVE
  // ============================================================

  Future<void> _approvePayment(
      BuildContext context,
      OwnerPaymentModel payment,
      OwnerPaymentProvider provider,
      ) async {
    final confirmed =
    await _showConfirmationDialog(
      context,
      title: 'Approve Payment',
      message:
      'Are you sure you want to approve payment #${payment.id}?',
      confirmText: 'Approve',
    );

    if (!confirmed || !mounted) {
      return;
    }

    final success =
    await provider.approvePayment(payment.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payment approved successfully',
          ),
        ),
      );
    } else {
      _showError(
        provider.errorMessage ??
            'Failed to approve payment',
      );
    }
  }

  // ============================================================
  // REJECT
  // ============================================================

  Future<void> _rejectPayment(
      BuildContext context,
      OwnerPaymentModel payment,
      OwnerPaymentProvider provider,
      ) async {
    final confirmed =
    await _showConfirmationDialog(
      context,
      title: 'Reject Payment',
      message:
      'Are you sure you want to reject payment #${payment.id}?',
      confirmText: 'Reject',
    );

    if (!confirmed || !mounted) {
      return;
    }

    final success =
    await provider.rejectPayment(payment.id);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Payment rejected successfully',
          ),
        ),
      );
    } else {
      _showError(
        provider.errorMessage ??
            'Failed to reject payment',
      );
    }
  }

  // ============================================================
  // CONFIRMATION DIALOG
  // ============================================================

  Future<bool> _showConfirmationDialog(
      BuildContext context, {
        required String title,
        required String message,
        required String confirmText,
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
                Navigator.of(dialogContext)
                    .pop(false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext)
                    .pop(true);
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
  // ERROR
  // ============================================================

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
      String message,
      OwnerPaymentProvider provider,
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
              size: 55,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: provider.loadPayments,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.payments_outlined,
              size: 70,
            ),
            SizedBox(height: 16),
            Text(
              'No payments found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'There are no owner payments to display.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _paymentMethodName(String method) {
    switch (method) {
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
        return method.isEmpty ? 'Not specified' : method;
    }
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    return '${localDate.day.toString().padLeft(2, '0')}/'
        '${localDate.month.toString().padLeft(2, '0')}/'
        '${localDate.year}';
  }
}