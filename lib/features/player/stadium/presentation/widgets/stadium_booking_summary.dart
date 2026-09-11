import 'package:flutter/material.dart';

class StadiumBookingSummary extends StatelessWidget {
  final String stadiumName;
  final String date;
  final String time;
  final double price;
  final double deposit;
  final double remaining;

  const StadiumBookingSummary({
    super.key,
    required this.stadiumName,
    required this.date,
    required this.time,
    required this.price,
    required this.deposit,
    required this.remaining,
  });

  static const Color primaryGreen =
  Color(0xFF7CC000);

  static const Color darkNavy =
  Color(0xFF1E1446);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            'Booking Summary',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: darkNavy,
            ),
          ),

          const SizedBox(height: 18),

          _Row(
            icon: Icons.stadium_outlined,
            title: 'Stadium',
            value: stadiumName,
          ),

          _Row(
            icon: Icons.calendar_today_outlined,
            title: 'Date',
            value: date,
          ),

          _Row(
            icon: Icons.access_time,
            title: 'Time',
            value: time,
          ),

          const Divider(height: 26),

          _PriceRow(
            title: 'Total price',
            value: price,
          ),

          const SizedBox(height: 8),

          _PriceRow(
            title: 'Deposit',
            value: deposit,
            highlight: true,
          ),

          const SizedBox(height: 8),

          _PriceRow(
            title: 'Remaining',
            value: remaining,
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _Row({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.circle,
            size: 8,
            color: Color(0xFF7CC000),
          ),

          const SizedBox(width: 10),

          Text(
            '$title: ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String title;
  final double value;
  final bool highlight;

  const _PriceRow({
    required this.title,
    required this.value,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        Text(
          '${value.toStringAsFixed(0)} EGP',
          style: TextStyle(
            color: highlight
                ? const Color(0xFF7CC000)
                : const Color(0xFF1E1446),
            fontWeight: FontWeight.w900,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}