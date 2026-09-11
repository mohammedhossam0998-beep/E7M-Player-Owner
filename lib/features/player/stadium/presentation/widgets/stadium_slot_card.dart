import 'package:flutter/material.dart';

import '../../data/models/stadium_slot.dart';

class StadiumSlotCard extends StatelessWidget {
  final StadiumSlot slot;
  final VoidCallback? onTap;
  final bool selected;

  const StadiumSlotCard({
    super.key,
    required this.slot,
    this.onTap,
    this.selected = false,
  });

  static const Color primaryGreen = Color(0xFF7CC000);
  static const Color darkNavy = Color(0xFF1E1446);

  @override
  Widget build(BuildContext context) {
    final available = slot.isAvailable;
    final enabled = available && onTap != null;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: selected
                ? primaryGreen.withValues(alpha: 0.12)
                : available
                ? Colors.white
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? primaryGreen
                  : available
                  ? Colors.grey.shade300
                  : Colors.grey.shade200,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              _TimeIcon(
                available: available,
                selected: selected,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatTime(slot.startTime),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: available
                            ? darkNavy
                            : Colors.grey.shade500,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'to ${_formatTime(slot.endTime)}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: available
                            ? Colors.grey.shade600
                            : Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _formatPrice(slot.price),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: available
                          ? darkNavy
                          : Colors.grey.shade500,
                    ),
                  ),

                  const SizedBox(height: 5),

                  _StatusBadge(
                    available: available,
                    selected: selected,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(String time) {
    final parts = time.split(':');

    if (parts.length < 2) {
      return time;
    }

    final hour = int.tryParse(parts[0]);
    final minute = parts[1];

    if (hour == null) {
      return time;
    }

    final suffix = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:$minute $suffix';
  }

  String _formatPrice(double price) {
    final isWhole = price == price.roundToDouble();

    if (isWhole) {
      return '${price.toStringAsFixed(0)} EGP';
    }

    return '${price.toStringAsFixed(2)} EGP';
  }
}

class _TimeIcon extends StatelessWidget {
  final bool available;
  final bool selected;

  const _TimeIcon({
    required this.available,
    required this.selected,
  });

  static const Color primaryGreen = Color(0xFF7CC000);

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? primaryGreen
        : available
        ? primaryGreen
        : Colors.grey.shade400;

    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        available
            ? Icons.access_time_rounded
            : Icons.lock_clock_outlined,
        color: color,
        size: 23,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool available;
  final bool selected;

  const _StatusBadge({
    required this.available,
    required this.selected,
  });

  static const Color primaryGreen = Color(0xFF7CC000);

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? primaryGreen
        : available
        ? primaryGreen
        : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        selected
            ? 'Selected'
            : available
            ? 'Available'
            : 'Booked',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}