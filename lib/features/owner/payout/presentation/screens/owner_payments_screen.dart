import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/owner_payment_provider.dart';
import '../../data/models/owner_payment_model.dart';
import 'package:e7m/shared/localization/app_translations.dart';

class OwnerPaymentsScreen extends StatefulWidget {
  const OwnerPaymentsScreen({super.key});

  @override
  State<OwnerPaymentsScreen> createState() =>
      _OwnerPaymentsScreenState();
}

class _OwnerPaymentsScreenState extends State<OwnerPaymentsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerPaymentProvider>().loadPayments();
    });
  }

  // ============================================================
  // APPROVE PAYMENT
  // ============================================================

  Future<void> _approvePayment(
      OwnerPaymentModel payment,
      ) async {
    // ==========================================================
    // GUARD: transactionReference must exist before approving
    // ==========================================================

    final hasTransactionReference =
        payment.transactionReference != null &&
            payment.transactionReference!.trim().isNotEmpty;

    if (!hasTransactionReference) {
      _showSnackBar(
        'Cannot approve: no transaction reference submitted by the player yet'.tr,
        isError: true,
      );
      return;
    }

    final confirmed = await _showConfirmDialog(
      title: 'Approve Payment'.tr,
      message:
      'Are you sure you want to approve this deposit payment?'.tr,
      confirmText: 'Approve'.tr,
      isDanger: false,
    );

    if (!confirmed || !mounted) return;

    final provider = context.read<OwnerPaymentProvider>();

    final success = await provider.approvePayment(
      payment.id,
    );

    if (!mounted) return;

    if (success) {
      _showSnackBar(
        'Payment approved successfully'.tr,
        isError: false,
      );
    } else {
      _showSnackBar(
        provider.errorMessage ??
            'Failed to approve payment'.tr,
        isError: true,
      );
    }
  }

  // ============================================================
  // REJECT PAYMENT
  // ============================================================

  Future<void> _rejectPayment(
      OwnerPaymentModel payment,
      ) async {
    final confirmed = await _showConfirmDialog(
      title: 'Reject Payment'.tr,
      message:
      'Are you sure you want to reject this deposit payment?'.tr,
      confirmText: 'Reject'.tr,
      isDanger: true,
    );

    if (!confirmed || !mounted) return;

    final provider = context.read<OwnerPaymentProvider>();

    final success = await provider.rejectPayment(
      payment.id,
    );

    if (!mounted) return;

    if (success) {
      _showSnackBar(
        'Payment rejected successfully'.tr,
        isError: false,
      );
    } else {
      _showSnackBar(
        provider.errorMessage ??
            'Failed to reject payment'.tr,
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
              child: Text('Cancel'.tr),
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
        return 'Pending'.tr;

      case 'paid':
        return 'Paid'.tr;

      case 'failed':
        return 'Rejected'.tr;

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

      case 'paid':
        return Colors.green;

      case 'failed':
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  // ============================================================
  // PAYMENT METHOD
  // ============================================================

  String _paymentMethodText(String method) {
    switch (method.toLowerCase()) {
      case 'instapay':
        return 'InstaPay'.tr;

      case 'vodafone_cash':
        return 'Vodafone Cash'.tr;

      case 'orange_cash':
        return 'Orange Cash'.tr;

      case 'etisalat_cash':
        return 'Etisalat Cash'.tr;

      case 'cash':
        return 'Cash'.tr;

      default:
        return method.isEmpty ? 'Unknown'.tr : method;
    }
  }

  // ============================================================
  // DATE
  // ============================================================

  String _formatDate(DateTime date) {
    final day =
    date.day.toString().padLeft(2, '0');

    final month =
    date.month.toString().padLeft(2, '0');

    final year =
    date.year.toString();

    return '$day/$month/$year';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Owner Payments'.tr,
        ),
        actions: [
          Consumer<OwnerPaymentProvider>(
            builder: (
                context,
                provider,
                child,
                ) {
              return IconButton(
                onPressed: provider.isLoading
                    ? null
                    : () {
                  provider.refreshPayments();
                },
                icon: const Icon(
                  Icons.refresh,
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<OwnerPaymentProvider>(
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
      OwnerPaymentProvider provider,
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
      onRefresh: provider.refreshPayments,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummary(provider),

          const SizedBox(height: 20),

          ...provider.payments.map(
                (payment) =>
                _buildPaymentCard(payment, provider),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(
      OwnerPaymentProvider provider,
      ) {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Pending'.tr,
            value: provider.pendingCount
                .toString(),
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildSummaryCard(
            title: 'Paid'.tr,
            value:
            provider.paidCount.toString(),
            icon: Icons.check_circle_outline,
            color: Colors.green,
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _buildSummaryCard(
            title: 'Rejected'.tr,
            value:
            provider.failedCount.toString(),
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
        padding: const EdgeInsets.all(12),
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
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 3),

            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
      OwnerPaymentProvider provider,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color: Colors.red,
            ),

            const SizedBox(height: 16),

            Text(
              provider.errorMessage ??
                  'Something went wrong'.tr,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed:
              provider.loadPayments,
              icon: const Icon(
                Icons.refresh,
              ),
              label: Text(
                'Try Again'.tr,
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
      OwnerPaymentProvider provider,
      ) {
    return RefreshIndicator(
      onRefresh: provider.refreshPayments,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: 180),

          Icon(
            Icons.payments_outlined,
            size: 64,
          ),

          SizedBox(height: 16),

          Center(
            child: Text(
              'No payments found'.tr,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 8),

          Center(
            child: Text(
              'Payments will appear here'.tr,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PAYMENT CARD
  // ============================================================

  Widget _buildPaymentCard(
      OwnerPaymentModel payment,
      OwnerPaymentProvider provider,
      ) {
    final statusColor =
    _statusColor(payment.status);

    final isPending =
        payment.status.toLowerCase() ==
            'pending';

    final isProcessing =
        provider.isProcessing &&
            provider.processingPaymentId ==
                payment.id;

    final hasTransactionReference =
        payment.transactionReference != null &&
            payment.transactionReference!.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                    'Payment #{id}'.trArgs({'id': payment.id}),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
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
            // PLAYER
            // ====================================================

            _infoRow(
              icon: Icons.person_outline,
              label: 'Player'.tr,
              value: payment.playerName,
            ),

            _infoRow(
              icon: Icons.email_outlined,
              label: 'Email'.tr,
              value: payment.playerEmail,
            ),

            // ====================================================
            // BOOKING
            // ====================================================

            _infoRow(
              icon:
              Icons.receipt_long_outlined,
              label: 'Booking'.tr,
              value:
              '#${payment.bookingId}',
            ),

            // ====================================================
            // PITCH
            // ====================================================

            _infoRow(
              icon: Icons.sports_soccer,
              label: 'Pitch'.tr,
              value: payment.pitchName,
            ),

            // ====================================================
            // AMOUNT
            // ====================================================

            _infoRow(
              icon:
              Icons.payments_outlined,
              label: 'Amount'.tr,
              value:
              '{amount} EGP'.trArgs({'amount': payment.amount.toStringAsFixed(2)}),
            ),

            _infoRow(
              icon: Icons
                  .account_balance_wallet_outlined,
              label: 'Deposit'.tr,
              value:
              '{amount} EGP'.trArgs({'amount': payment.depositAmount.toStringAsFixed(2)}),
            ),

            _infoRow(
              icon:
              Icons.pending_actions_outlined,
              label: 'Remaining'.tr,
              value:
              '{amount} EGP'.trArgs({'amount': payment.remainingAmount.toStringAsFixed(2)}),
            ),

            // ====================================================
            // PAYMENT METHOD
            // ====================================================

            _infoRow(
              icon:
              Icons.account_balance_outlined,
              label: 'Method'.tr,
              value:
              _paymentMethodText(
                payment.paymentMethod,
              ),
            ),

            // ====================================================
            // PAYMENT TYPE
            // ====================================================

            _infoRow(
              icon: Icons.category_outlined,
              label: 'Type'.tr,
              value: _paymentTypeLabel(payment.paymentType),
            ),

            // ====================================================
            // TRANSACTION
            // ====================================================

            _infoRow(
              icon: Icons.tag,
              label: 'Transaction'.tr,
              value:
              payment.transactionReference ??
                  'Not submitted'.tr,
            ),

            // ====================================================
            // DATE
            // ====================================================

            _infoRow(
              icon:
              Icons.calendar_today_outlined,
              label: 'Date'.tr,
              value: _formatDate(
                payment.slotDate,
              ),
            ),

            // ====================================================
            // TIME
            // ====================================================

            _infoRow(
              icon:
              Icons.access_time,
              label: 'Time'.tr,
              value:
              '${payment.startTime} - ${payment.endTime}',
            ),

            // ====================================================
            // MISSING TRANSACTION WARNING
            // ====================================================

            if (isPending && !hasTransactionReference) ...[
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.orange.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Waiting for the player to submit a transaction reference before this can be approved'.tr,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // ====================================================
            // ACTIONS
            // ====================================================

            if (isPending) ...[
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
                        icon: const Icon(
                          Icons.close,
                        ),
                        label: Text(
                          'Reject'.tr,
                        ),
                        style:
                        OutlinedButton.styleFrom(
                          foregroundColor:
                          Colors.red,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child:
                      ElevatedButton.icon(
                        onPressed:
                        hasTransactionReference
                            ? () => _approvePayment(
                          payment,
                        )
                            : null,
                        icon: const Icon(
                          Icons.check,
                        ),
                        label: Text(
                          'Approve'.tr,
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
  // INFO ROW
  // ============================================================

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding:
      const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
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

// Translates the raw payment type coming from the API.
String _paymentTypeLabel(String type) {
  switch (type) {
    case 'deposit':
      return 'Deposit'.tr;
    case 'full_payment':
      return 'Full Payment'.tr;
    default:
      return type;
  }
}