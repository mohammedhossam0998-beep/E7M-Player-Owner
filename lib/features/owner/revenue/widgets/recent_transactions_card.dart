import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import '../models/transaction_model.dart';

class RecentTransactionsCard extends StatelessWidget {
  final List<TransactionModel> transactions;
  final VoidCallback? onViewAll;

  const RecentTransactionsCard({
    super.key,
    required this.transactions,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  languageProvider.translate('recent_transactions'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1E1446),
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  languageProvider.translate('view_all'),
                  style: const TextStyle(
                    color: Color(0xff7CC000),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (transactions.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Text(
                languageProvider.translate('no_transactions_yet'),
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: transactions.length > 5 ? 5 : transactions.length,
              separatorBuilder: (_, __) => const Divider(height: 24),
              itemBuilder: (_, index) {
                return _TransactionTile(transaction: transactions[index]);
              },
            ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionTile({required this.transaction});

  Color get statusColor {
    switch (transaction.status.toLowerCase()) {
      case "paid":
        return Colors.green;
      case "pending":
        return Colors.orange;
      case "failed":
        return Colors.red;
      case "refunded":
        return Colors.blueGrey;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (transaction.status.toLowerCase()) {
      case "paid":
        return Icons.check_circle;
      case "pending":
        return Icons.schedule;
      case "failed":
        return Icons.cancel;
      case "refunded":
        return Icons.reply;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: statusColor.withValues(alpha: .10),
          child: Icon(statusIcon, color: statusColor),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                transaction.playerName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xff1E1446),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat(
                  "dd MMM yyyy",
                  languageProvider.currentLocale.languageCode,
                ).format(transaction.date),
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${transaction.amount.toStringAsFixed(0)} EGP",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xff1E1446),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                languageProvider.translate(transaction.status.toLowerCase()),
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
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