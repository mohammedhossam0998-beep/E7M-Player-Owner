import 'package:flutter/material.dart';

class CompetitionStatusBadge extends StatelessWidget {
  final String status;

  const CompetitionStatusBadge({
    super.key,
    required this.status,
  });

  static const Color primaryColor = Color(0xff7CC000);

  String _statusText() {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Draft';

      case 'published':
        return 'Published';

      case 'open':
      case 'registration_open':
        return 'Registration Open';

      case 'closed':
        return 'Closed';

      case 'ongoing':
        return 'Ongoing';

      case 'completed':
        return 'Completed';

      case 'cancelled':
        return 'Cancelled';

      default:
        return status;
    }
  }

  Color _statusColor() {
    switch (status.toLowerCase()) {
      case 'open':
      case 'published':
      case 'registration_open':
        return primaryColor;

      case 'ongoing':
        return Colors.blue;

      case 'completed':
        return Colors.green;

      case 'cancelled':
        return Colors.red;

      case 'closed':
        return Colors.orange;

      case 'draft':
        return Colors.grey;

      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _statusText(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}