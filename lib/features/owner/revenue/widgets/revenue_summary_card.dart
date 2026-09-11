import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';

import '../models/transaction_model.dart';
import '../providers/revenue_provider.dart';

class RevenueSummaryCard extends StatelessWidget {
  const RevenueSummaryCard({super.key});

  String _formatAmount(double amount) {
    return '${NumberFormat('#,##0.00').format(amount)} EGP';
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider =
    context.watch<LanguageProvider>();

    final revenueProvider =
    context.watch<RevenueProvider>();

    final transactions =
    revenueProvider.recentTransactions
        .take(3)
        .toList();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            languageProvider.translate(
              'revenue_summary',
            ),
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E1446),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            languageProvider.translate(
              'booking_payments_overview',
            ),
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 28),

          Row(
            children: [
              Expanded(
                child: _RevenueStatCard(
                  title:
                  languageProvider.translate(
                    'total_revenue',
                  ),
                  value: _formatAmount(
                    revenueProvider.totalRevenue,
                  ),
                  icon:
                  Icons.payments_rounded,
                  color:
                  const Color(0xff7CC000),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _RevenueStatCard(
                  title:
                  languageProvider.translate(
                    'completed',
                  ),
                  value:
                  revenueProvider.paidCount
                      .toString(),
                  icon:
                  Icons.check_circle,
                  color: Colors.green,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _RevenueStatCard(
                  title:
                  languageProvider.translate(
                    'pending',
                  ),
                  value:
                  revenueProvider
                      .pendingCount
                      .toString(),
                  icon:
                  Icons.schedule,
                  color:
                  Colors.orange,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: _RevenueStatCard(
                  title:
                  languageProvider.translate(
                    'refunded',
                  ),
                  value:
                  revenueProvider
                      .refundedCount
                      .toString(),
                  icon:
                  Icons.reply,
                  color: Colors.red,
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),

          Text(
            languageProvider.translate(
              'latest_transactions',
            ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E1446),
            ),
          ),

          const SizedBox(height: 18),

          if (transactions.isEmpty)
            Center(
              child: Padding(
                padding:
                const EdgeInsets.symmetric(
                  vertical: 20,
                ),
                child: Text(
                  languageProvider.translate(
                    'no_transactions_yet',
                  ),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight:
                    FontWeight.w600,
                  ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics:
              const NeverScrollableScrollPhysics(),
              itemCount:
              transactions.length,
              separatorBuilder:
                  (_, __) =>
              const Divider(
                height: 26,
              ),
              itemBuilder:
                  (_, index) {
                return _TransactionTile(
                  transaction:
                  transactions[index],
                );
              },
            ),

          const Divider(height: 40),

          Text(
            languageProvider.translate(
              'reports',
            ),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E1446),
            ),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  style:
                  FilledButton.styleFrom(
                    elevation: 0,
                    backgroundColor:
                    const Color(
                      0xff7CC000,
                    ),
                    minimumSize:
                    const Size.fromHeight(
                      56,
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                  onPressed: null,
                  icon: const Icon(
                    Icons.picture_as_pdf,
                  ),
                  label: Text(
                    languageProvider
                        .translate(
                      'export_pdf',
                    ),
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: OutlinedButton.icon(
                  style:
                  OutlinedButton.styleFrom(
                    minimumSize:
                    const Size.fromHeight(
                      56,
                    ),
                    side:
                    const BorderSide(
                      color:
                      Color(0xff7CC000),
                    ),
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                  onPressed: null,
                  icon: const Icon(
                    Icons.table_chart,
                  ),
                  label: Text(
                    languageProvider
                        .translate(
                      'export_excel',
                    ),
                    style:
                    const TextStyle(
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}


// ============================================================
// STAT CARD
// ============================================================

class _RevenueStatCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _RevenueStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color:
        color.withOpacity(.08),
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor:
            color.withOpacity(.12),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight:
              FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color:
              Colors.grey.shade700,
              fontWeight:
              FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// TRANSACTION TILE
// ============================================================

class _TransactionTile
    extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile({
    required this.transaction,
  });

  Color get statusColor {
    switch (
    transaction.status.toLowerCase()) {
      case 'paid':
        return Colors.green;

      case 'pending':
        return Colors.orange;

      case 'failed':
        return Colors.red;

      case 'refunded':
        return Colors.blueGrey;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider =
    context.watch<LanguageProvider>();

    final locale =
        languageProvider
            .currentLocale
            .languageCode;

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor:
          statusColor.withOpacity(.10),
          child: Icon(
            Icons.payments_outlined,
            color: statusColor,
          ),
        ),

        const SizedBox(width: 14),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                transaction.playerName
                    .isEmpty
                    ? transaction.bookingId
                    : transaction
                    .playerName,
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                  fontSize: 16,
                  color:
                  Color(0xff1E1446),
                ),
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
              ),

              const SizedBox(height: 4),

              Text(
                DateFormat(
                  'dd MMM yyyy',
                  locale,
                ).format(
                  transaction.date,
                ),
                style: TextStyle(
                  color:
                  Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 10),

        Column(
          crossAxisAlignment:
          CrossAxisAlignment.end,
          children: [
            Text(
              '${transaction.amount.toStringAsFixed(0)} EGP',
              style:
              const TextStyle(
                fontWeight:
                FontWeight.bold,
                color:
                Color(0xff1E1446),
              ),
            ),

            const SizedBox(height: 6),

            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 4,
              ),
              decoration:
              BoxDecoration(
                color:
                statusColor
                    .withOpacity(.12),
                borderRadius:
                BorderRadius.circular(
                  30,
                ),
              ),
              child: Text(
                languageProvider
                    .translate(
                  transaction.status
                      .toLowerCase(),
                ),
                style: TextStyle(
                  color:
                  statusColor,
                  fontWeight:
                  FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}