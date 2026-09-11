import 'package:flutter/material.dart';

import '../../data/models/stadium.dart';

class StadiumInfoCard extends StatelessWidget {
  final Stadium stadium;

  const StadiumInfoCard({
    super.key,
    required this.stadium,
  });

  static const Color primaryGreen = Color(0xFF7CC000);
  static const Color darkNavy = Color(0xFF1E1446);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Stadium Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: darkNavy,
            ),
          ),

          const SizedBox(height: 16),

          _InfoRow(
            icon: Icons.sports_soccer_rounded,
            title: 'Pitch Type',
            value: _displayValue(stadium.pitchType),
          ),

          const SizedBox(height: 14),

          _InfoRow(
            icon: Icons.groups_rounded,
            title: 'Capacity',
            value: stadium.capacity != null
                ? '${stadium.capacity} players'
                : 'Not specified',
          ),

          const SizedBox(height: 14),

          _InfoRow(
            icon: Icons.payments_outlined,
            title: 'Starting Price',
            value: _formatPrice(stadium.basePrice),
          ),

          if (stadium.depositAmount > 0) ...[
            const SizedBox(height: 14),

            _InfoRow(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Deposit',
              value: _formatPrice(stadium.depositAmount),
            ),
          ],

          if (stadium.description != null &&
              stadium.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 18),

            const Divider(
              height: 1,
            ),

            const SizedBox(height: 18),

            const Text(
              'Description',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: darkNavy,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              stadium.description!.trim(),
              style: TextStyle(
                fontSize: 14,
                height: 1.6,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _displayValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Not specified';
    }

    return value.trim();
  }

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return '${price.toStringAsFixed(0)} EGP';
    }

    return '${price.toStringAsFixed(2)} EGP';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  static const Color primaryGreen = Color(0xFF7CC000);
  static const Color darkNavy = Color(0xFF1E1446);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: primaryGreen.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.info_outline_rounded,
            color: primaryGreen,
            size: 22,
          ),
        ),

        const SizedBox(width: 13),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: darkNavy,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}