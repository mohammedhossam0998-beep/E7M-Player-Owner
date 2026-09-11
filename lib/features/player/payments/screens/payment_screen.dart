import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'package:e7m/features/player/booking/models/booking_model.dart';
import 'package:e7m/features/player/payments/providers/payment_provider.dart';
import 'package:e7m/features/player/payments/widgets/payment_method_card.dart';
import 'package:e7m/features/player/payments/widgets/payment_status_card.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class PaymentScreen extends StatefulWidget {
  final BookingModel booking;

  const PaymentScreen({
    super.key,
    required this.booking,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _paymentType = 'deposit';
  String _paymentMethod = 'instapay';

  final TextEditingController _referenceController =
  TextEditingController();

  @override
  void initState() {
    super.initState();

    // If there is no deposit and there is a remaining amount,
    // default to full payment.
    if (widget.booking.depositAmount <= 0 &&
        widget.booking.remainingAmount > 0) {
      _paymentType = 'full_payment';
    }

    // Load existing payments for this booking.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<PaymentProvider>().loadBookingPayments(
        bookingId: widget.booking.id,
      );
    });
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }

  // ============================================================
  // PAYMENT AMOUNT
  // ============================================================

  double get _amount {
    if (_paymentType == 'deposit') {
      return widget.booking.depositAmount;
    }

    return widget.booking.remainingAmount;
  }

  bool get _canPay => _amount > 0;

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        centerTitle: true,
        title: Text(
          t('payment'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: Consumer<PaymentProvider>(
        builder: (context, provider, _) {
          // ======================================================
          // LOADING EXISTING PAYMENTS
          // ======================================================

          if (provider.isLoadingPayments) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xff7CC000),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBookingSummary(t),

                const SizedBox(height: 20),

                // ==================================================
                // EXISTING PAYMENT
                // ==================================================

                if (provider.payment != null) ...[
                  _buildExistingPaymentSection(
                    context,
                    provider,
                    t,
                  ),
                ]

                // ==================================================
                // NO EXISTING PAYMENT
                // ==================================================

                else ...[
                  _buildPaymentTypeSection(t),

                  const SizedBox(height: 20),

                  _buildPaymentMethodSection(t),

                  const SizedBox(height: 20),

                  _buildCreatePaymentButton(
                    context,
                    provider,
                    t,
                  ),
                ],

                // ==================================================
                // ERROR
                // ==================================================

                if (provider.errorMessage != null) ...[
                  const SizedBox(height: 16),
                  _buildError(provider.errorMessage!),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // BOOKING SUMMARY
  // ============================================================

  Widget _buildBookingSummary(
      String Function(String) t,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.booking.pitchName ?? t('stadium'),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E1446),
            ),
          ),

          const SizedBox(height: 14),

          _summaryRow(
            t('total'),
            '${widget.booking.totalPrice.toStringAsFixed(2)} EGP',
          ),

          const SizedBox(height: 8),

          _summaryRow(
            t('deposit'),
            '${widget.booking.depositAmount.toStringAsFixed(2)} EGP',
          ),

          const SizedBox(height: 8),

          _summaryRow(
            t('remaining'),
            '${widget.booking.remainingAmount.toStringAsFixed(2)} EGP',
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
      String label,
      String value,
      ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT TYPE
  // ============================================================

  Widget _buildPaymentTypeSection(
      String Function(String) t,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('payment_type'),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xff1E1446),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: PaymentMethodCard(
                title: t('deposit'),
                subtitle:
                '${widget.booking.depositAmount.toStringAsFixed(2)} EGP',
                icon: Icons.account_balance_wallet_outlined,
                isSelected: _paymentType == 'deposit',
                onTap: () {
                  if (widget.booking.depositAmount <= 0) {
                    return;
                  }

                  setState(() {
                    _paymentType = 'deposit';
                  });
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: PaymentMethodCard(
                title: t('full_payment'),
                subtitle:
                '${widget.booking.remainingAmount.toStringAsFixed(2)} EGP',
                icon: Icons.payments_outlined,
                isSelected: _paymentType == 'full_payment',
                onTap: () {
                  if (widget.booking.remainingAmount <= 0) {
                    return;
                  }

                  setState(() {
                    _paymentType = 'full_payment';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT METHOD
  // ============================================================

  Widget _buildPaymentMethodSection(
      String Function(String) t,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('choose_payment_method'),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xff1E1446),
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: PaymentMethodCard(
                title: 'InstaPay',
                subtitle: t('instapay'),
                icon: Icons.account_balance,
                isSelected: _paymentMethod == 'instapay',
                onTap: () {
                  setState(() {
                    _paymentMethod = 'instapay';
                  });
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: PaymentMethodCard(
                title: 'Wallet',
                subtitle: t('wallet'),
                icon: Icons.phone_android,
                isSelected: _paymentMethod == 'wallet',
                onTap: () {
                  setState(() {
                    _paymentMethod = 'wallet';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // CREATE PAYMENT
  // ============================================================

  Widget _buildCreatePaymentButton(
      BuildContext context,
      PaymentProvider provider,
      String Function(String) t,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed:
        provider.isCreatingPayment || !_canPay
            ? null
            : () async {
          bool success;

          if (_paymentType == 'deposit') {
            success =
            await provider.createDepositPayment(
              bookingId: widget.booking.id,
              paymentMethod: _paymentMethod,
            );
          } else {
            success =
            await provider.createFullPayment(
              bookingId: widget.booking.id,
              paymentMethod: _paymentMethod,
            );
          }

          if (!context.mounted) {
            return;
          }

          if (success) {
            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(
                  t('payment_created'),
                ),
                backgroundColor:
                const Color(0xff7CC000),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff7CC000),
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: provider.isCreatingPayment
            ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : Text(
          t('continue_payment'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // EXISTING PAYMENT
  // ============================================================

  Widget _buildExistingPaymentSection(
      BuildContext context,
      PaymentProvider provider,
      String Function(String) t,
      ) {
    final payment = provider.payment!;

    // ==========================================================
    // PAID
    // ==========================================================

    if (payment.isPaid) {
      return PaymentStatusCard(
        icon: Icons.check_circle_outline,
        title: t('payment_successful'),
        message: t('payment_success_message'),
        iconColor: const Color(0xff7CC000),
      );
    }

    // ==========================================================
    // FAILED
    // ==========================================================

    if (payment.isFailed) {
      return Column(
        children: [
          PaymentStatusCard(
            icon: Icons.cancel_outlined,
            title: t('payment_failed'),
            message: t('payment_failed'),
            iconColor: Colors.red,
          ),

          const SizedBox(height: 20),

          _buildPaymentTypeSection(t),

          const SizedBox(height: 20),

          _buildPaymentMethodSection(t),

          const SizedBox(height: 20),

          _buildCreatePaymentButton(
            context,
            provider,
            t,
          ),
        ],
      );
    }

    // ==========================================================
    // PENDING
    // ==========================================================

    if (payment.isPending) {
      return Column(
        children: [
          _buildPaymentAccount(
            context,
            provider,
            t,
          ),

          const SizedBox(height: 20),

          _buildReferenceSection(
            context,
            provider,
            t,
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  // ============================================================
  // PAYMENT ACCOUNT
  // ============================================================

  Widget _buildPaymentAccount(
      BuildContext context,
      PaymentProvider provider,
      String Function(String) t,
      ) {
    final account = provider.paymentAccount;

    if (account == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange.shade700,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                t('payment_account_unavailable'),
                style: TextStyle(
                  color: Colors.orange.shade800,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xff7CC000).withOpacity(0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t('transfer_to_this_account'),
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E1446),
            ),
          ),

          const SizedBox(height: 16),

          _accountRow(
            icon: Icons.payment_outlined,
            label: t('payment_method'),
            value: account.paymentMethod,
          ),

          const SizedBox(height: 12),

          _accountRow(
            icon: Icons.person_outline,
            label: t('account_name'),
            value: account.accountName,
          ),

          const SizedBox(height: 12),

          _accountRow(
            icon: Icons.account_balance_wallet_outlined,
            label: t('account_number'),
            value: account.accountIdentifier,
            copyable: true,
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffF7F7F3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xff7CC000),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    '${t('transfer_amount')}: '
                        '${_amount.toStringAsFixed(2)} EGP',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1E1446),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ACCOUNT ROW
  // ============================================================

  Widget _accountRow({
    required IconData icon,
    required String label,
    required String value,
    bool copyable = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xff7CC000),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                style: const TextStyle(
                  color: Color(0xff1E1446),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),

        if (copyable)
          IconButton(
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(text: value),
              );

              if (!mounted) return;

              ScaffoldMessenger.of(context)
                  .showSnackBar(
                SnackBar(
                  content: Text(
                    context
                        .read<LanguageProvider>()
                        .translate('account_copied'),
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.copy,
              color: Color(0xff7CC000),
            ),
          ),
      ],
    );
  }

  // ============================================================
  // TRANSACTION REFERENCE
  // ============================================================

  Widget _buildReferenceSection(
      BuildContext context,
      PaymentProvider provider,
      String Function(String) t,
      ) {
    final payment = provider.payment!;

    if (payment.isPaid) {
      return PaymentStatusCard(
        icon: Icons.check_circle_outline,
        title: t('payment_successful'),
        message: t('payment_success_message'),
        iconColor: const Color(0xff7CC000),
      );
    }

    if (payment.isFailed) {
      return PaymentStatusCard(
        icon: Icons.cancel_outlined,
        title: t('payment_failed'),
        message: t('payment_failed'),
        iconColor: Colors.red,
      );
    }

    if (!payment.isPending) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('reference_number'),
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Color(0xff1E1446),
          ),
        ),

        const SizedBox(height: 10),

        TextField(
          controller: _referenceController,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            hintText: t('reference_number'),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            prefixIcon: const Icon(
              Icons.receipt_long_outlined,
            ),
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed:
            provider.isSubmittingReference
                ? null
                : () async {
              final reference =
              _referenceController.text.trim();

              if (reference.isEmpty) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      t(
                        'enter_transaction_reference',
                      ),
                    ),
                  ),
                );

                return;
              }

              final success =
              await provider
                  .submitTransactionReference(
                paymentId: payment.id,
                transactionReference:
                reference,
              );

              if (!context.mounted) {
                return;
              }

              if (success) {
                _referenceController.clear();

                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  SnackBar(
                    content: Text(
                      t('payment_submitted'),
                    ),
                    backgroundColor:
                    const Color(0xff7CC000),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff1E1446),
              disabledBackgroundColor:
              Colors.grey.shade400,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: provider.isSubmittingReference
                ? const SizedBox(
              height: 22,
              width: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Text(
              t('submit_payment'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(String message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.red.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}