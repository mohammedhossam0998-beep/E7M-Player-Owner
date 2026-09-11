import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/competition_model.dart';
import '../../models/competition_payment_model.dart';
import '../../providers/competition_provider.dart';

class CompetitionPaymentStatusScreen extends StatelessWidget {
  const CompetitionPaymentStatusScreen({
    super.key,
    required this.competition,
    required this.payment,
  });

  final CompetitionModel competition;
  final CompetitionPaymentModel payment;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);
  static const Color e7mDarkNavy = Color(0xFF031B3A);
  static const Color background = Color(0xFFF7F9FC);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompetitionProvider(),
      child: _PaymentStatusView(
        competition: competition,
        payment: payment,
      ),
    );
  }
}

class _PaymentStatusView extends StatelessWidget {
  const _PaymentStatusView({
    required this.competition,
    required this.payment,
  });

  final CompetitionModel competition;
  final CompetitionPaymentModel payment;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);
  static const Color e7mDarkNavy = Color(0xFF031B3A);
  static const Color background = Color(0xFFF7F9FC);

  @override
  Widget build(BuildContext context) {
    final status = payment.status.toLowerCase();
    final config = _paymentStatusConfig(status);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: e7mNavy,
          ),
        ),
        title: const Text(
          'Payment Status',
          style: TextStyle(
            color: e7mNavy,
            fontSize: 19,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          20,
          16,
          30,
        ),
        child: Column(
          children: [
            _StatusHero(
              config: config,
            ),

            const SizedBox(height: 22),

            _CompetitionCard(
              competition: competition,
            ),

            const SizedBox(height: 18),

            _PaymentDetailsCard(
              payment: payment,
            ),

            if (payment.rejectionReason != null &&
                payment.rejectionReason!.trim().isNotEmpty) ...[
              const SizedBox(height: 18),
              _RejectionCard(
                reason: payment.rejectionReason!,
              ),
            ],

            if (status == 'submitted') ...[
              const SizedBox(height: 18),
              const _ReviewNotice(),
            ],

            if (status == 'paid') ...[
              const SizedBox(height: 18),
              const _SuccessNotice(),
            ],

            if (status == 'failed') ...[
              const SizedBox(height: 18),
              const _RetryNotice(),
            ],
          ],
        ),
      ),
      bottomNavigationBar: _BottomAction(
        status: status,
        competition: competition,
        payment: payment,
      ),
    );
  }
}

// ============================================================
// STATUS HERO
// ============================================================

class _StatusHero extends StatelessWidget {
  const _StatusHero({
    required this.config,
  });

  final _PaymentStatusConfig config;

  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        22,
        28,
        22,
        28,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF082B5C),
            Color(0xFF031B3A),
          ],
        ),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: e7mNavy.withValues(alpha: 0.15),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.13),
              shape: BoxShape.circle,
              border: Border.all(
                color: config.color.withValues(alpha: 0.22),
                width: 1,
              ),
            ),
            child: Icon(
              config.icon,
              color: config.color,
              size: 42,
            ),
          ),

          const SizedBox(height: 18),

          Text(
            config.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w900,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            config.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: config.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: config.color.withValues(alpha: 0.20),
              ),
            ),
            child: Text(
              config.label,
              style: TextStyle(
                color: config.color,
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// COMPETITION CARD
// ============================================================

class _CompetitionCard extends StatelessWidget {
  const _CompetitionCard({
    required this.competition,
  });

  final CompetitionModel competition;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: e7mGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: e7mGreen,
              size: 27,
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Competition',
                  style: TextStyle(
                    color: Color(0xFF7A8594),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  competition.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: e7mNavy,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PAYMENT DETAILS
// ============================================================

class _PaymentDetailsCard extends StatelessWidget {
  const _PaymentDetailsCard({
    required this.payment,
  });

  final CompetitionPaymentModel payment;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _CardTitle(
            icon: Icons.receipt_long_outlined,
            title: 'Payment Details',
          ),

          const SizedBox(height: 16),

          _DetailRow(
            icon: Icons.payments_outlined,
            title: 'Amount',
            value: '${_formatMoney(payment.amount)} EGP',
            valueColor: e7mGreen,
          ),

          const _Divider(),

          _DetailRow(
            icon: Icons.account_balance_wallet_outlined,
            title: 'Payment Method',
            value: _paymentMethodLabel(
              payment.paymentMethod,
            ),
          ),

          if (payment.transactionReference != null &&
              payment.transactionReference!.trim().isNotEmpty) ...[
            const _Divider(),

            _DetailRow(
              icon: Icons.tag_rounded,
              title: 'Transaction Reference',
              value: payment.transactionReference!,
            ),
          ],

          if (payment.ownerPaymentAccountId != null) ...[
            const _Divider(),

            _DetailRow(
              icon: Icons.account_balance_outlined,
              title: 'Payment Account',
              value: '#${payment.ownerPaymentAccountId}',
            ),
          ],

          if (payment.submittedAt != null) ...[
            const _Divider(),

            _DetailRow(
              icon: Icons.upload_rounded,
              title: 'Submitted',
              value: _formatDateTime(
                payment.submittedAt!,
              ),
            ),
          ],

          if (payment.verifiedAt != null) ...[
            const _Divider(),

            _DetailRow(
              icon: Icons.verified_outlined,
              title: 'Verified',
              value: _formatDateTime(
                payment.verifiedAt!,
              ),
            ),
          ],

          if (payment.paidAt != null) ...[
            const _Divider(),

            _DetailRow(
              icon: Icons.check_circle_outline_rounded,
              title: 'Paid',
              value: _formatDateTime(
                payment.paidAt!,
              ),
            ),
          ],

          if (payment.rejectedAt != null) ...[
            const _Divider(),

            _DetailRow(
              icon: Icons.cancel_outlined,
              title: 'Rejected',
              value: _formatDateTime(
                payment.rejectedAt!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// REJECTION CARD
// ============================================================

class _RejectionCard extends StatelessWidget {
  const _RejectionCard({
    required this.reason,
  });

  final String reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.info_outline_rounded,
              color: Colors.redAccent,
              size: 20,
            ),
          ),

          const SizedBox(width: 11),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rejection Reason',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  reason,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REVIEW NOTICE
// ============================================================

class _ReviewNotice extends StatelessWidget {
  const _ReviewNotice();

  static const Color e7mGreen = Color(0xFF7CC000);

  @override
  Widget build(BuildContext context) {
    return _NoticeCard(
      icon: Icons.hourglass_top_rounded,
      title: 'Under Review',
      message:
      'Your payment proof has been submitted and is waiting for the competition owner to review it.',
      color: e7mGreen,
    );
  }
}

// ============================================================
// SUCCESS NOTICE
// ============================================================

class _SuccessNotice extends StatelessWidget {
  const _SuccessNotice();

  static const Color e7mGreen = Color(0xFF7CC000);

  @override
  Widget build(BuildContext context) {
    return _NoticeCard(
      icon: Icons.check_circle_outline_rounded,
      title: 'Payment Confirmed',
      message:
      'Your payment has been verified successfully. Your place in the competition is confirmed.',
      color: e7mGreen,
    );
  }
}

// ============================================================
// RETRY NOTICE
// ============================================================

class _RetryNotice extends StatelessWidget {
  const _RetryNotice();

  @override
  Widget build(BuildContext context) {
    return _NoticeCard(
      icon: Icons.refresh_rounded,
      title: 'Payment Rejected',
      message:
      'Your previous payment was rejected. You can submit a new payment if the registration is still valid.',
      color: Colors.redAccent,
    );
  }
}

// ============================================================
// NOTICE CARD
// ============================================================

class _NoticeCard extends StatelessWidget {
  const _NoticeCard({
    required this.icon,
    required this.title,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: color,
            size: 23,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  message,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BOTTOM ACTION
// ============================================================

class _BottomAction extends StatelessWidget {
  const _BottomAction({
    required this.status,
    required this.competition,
    required this.payment,
  });

  final String status;
  final CompetitionModel competition;
  final CompetitionPaymentModel payment;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    if (status == 'paid') {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            12,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                  ..pop()
                  ..pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: e7mGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (status == 'submitted') {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            12,
          ),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius:
              BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.hourglass_top_rounded,
                  color: Colors.grey.shade600,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Waiting for Review',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (status == 'failed') {
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            12,
          ),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(
                Icons.refresh_rounded,
                size: 20,
              ),
              label: const Text(
                'Retry Payment',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: e7mGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// ============================================================
// SECTION CARD
// ============================================================

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: const Color(0xFFE6EAF0),
        ),
      ),
      child: child,
    );
  }
}

// ============================================================
// CARD TITLE
// ============================================================

class _CardTitle extends StatelessWidget {
  const _CardTitle({
    required this.icon,
    required this.title,
  });

  final IconData icon;
  final String title;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: e7mGreen.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: e7mGreen,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            color: e7mNavy,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DETAIL ROW
// ============================================================

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.title,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color? valueColor;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: e7mGreen,
          size: 19,
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              color: valueColor ?? e7mNavy,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DIVIDER
// ============================================================

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 13,
      ),
      child: Divider(
        height: 1,
        color: Colors.grey.shade200,
      ),
    );
  }
}

// ============================================================
// PAYMENT STATUS CONFIG
// ============================================================

class _PaymentStatusConfig {
  const _PaymentStatusConfig({
    required this.label,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String label;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
}

_PaymentStatusConfig _paymentStatusConfig(
    String status,
    ) {
  switch (status) {
    case 'pending':
      return const _PaymentStatusConfig(
        label: 'PENDING',
        title: 'Payment Pending',
        description:
        'Your payment has not been completed yet.',
        icon: Icons.pending_actions_rounded,
        color: Colors.orange,
      );

    case 'submitted':
      return const _PaymentStatusConfig(
        label: 'UNDER REVIEW',
        title: 'Payment Submitted',
        description:
        'Your payment proof has been received and is waiting for verification.',
        icon: Icons.hourglass_top_rounded,
        color: Color(0xFF7CC000),
      );

    case 'paid':
      return const _PaymentStatusConfig(
        label: 'PAID',
        title: 'Payment Confirmed',
        description:
        'Your payment has been verified successfully.',
        icon: Icons.check_circle_rounded,
        color: Color(0xFF7CC000),
      );

    case 'failed':
      return const _PaymentStatusConfig(
        label: 'REJECTED',
        title: 'Payment Rejected',
        description:
        'Your payment could not be verified.',
        icon: Icons.cancel_rounded,
        color: Colors.redAccent,
      );

    case 'expired':
      return const _PaymentStatusConfig(
        label: 'EXPIRED',
        title: 'Payment Expired',
        description:
        'The payment period for this transaction has expired.',
        icon: Icons.timer_off_rounded,
        color: Colors.redAccent,
      );

    case 'refunded':
      return const _PaymentStatusConfig(
        label: 'REFUNDED',
        title: 'Payment Refunded',
        description:
        'This payment has been refunded.',
        icon: Icons.undo_rounded,
        color: Color(0xFF082B5C),
      );

    case 'partially_refunded':
      return const _PaymentStatusConfig(
        label: 'PARTIALLY REFUNDED',
        title: 'Partially Refunded',
        description:
        'Part of this payment has been refunded.',
        icon: Icons.currency_exchange_rounded,
        color: Color(0xFF082B5C),
      );

    default:
      return const _PaymentStatusConfig(
        label: 'UNKNOWN',
        title: 'Payment Status',
        description:
        'The current payment status could not be determined.',
        icon: Icons.help_outline_rounded,
        color: Color(0xFF607080),
      );
  }
}

// ============================================================
// HELPERS
// ============================================================

String _paymentMethodLabel(String value) {
  switch (value.toLowerCase()) {
    case 'wallet':
      return 'Wallet';

    case 'instapay':
      return 'InstaPay';

    default:
      return value;
  }
}

String _formatMoney(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }

  return value.toStringAsFixed(2);
}

String _formatDateTime(DateTime date) {
  final local = date.toLocal();

  final day =
  local.day.toString().padLeft(2, '0');
  final month =
  local.month.toString().padLeft(2, '0');
  final year = local.year.toString();

  final hour =
  local.hour.toString().padLeft(2, '0');
  final minute =
  local.minute.toString().padLeft(2, '0');

  return '$day/$month/$year • $hour:$minute';
}