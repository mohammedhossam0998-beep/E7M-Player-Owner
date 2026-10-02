import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/stadium_provider.dart';
import '../widgets/stadium_booking_summary.dart';

import 'package:e7m/features/player/payments/screens/payment_screen.dart';

class StadiumBookingScreen extends StatefulWidget {
  final String stadiumId;
  final String stadiumName;
  final String slotId;
  final DateTime? date;
  final String startTime;
  final String endTime;
  final double price;
  final double deposit;

  const StadiumBookingScreen({
    super.key,
    required this.stadiumId,
    required this.stadiumName,
    required this.slotId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.deposit,
  });

  @override
  State<StadiumBookingScreen> createState() =>
      _StadiumBookingScreenState();
}

class _StadiumBookingScreenState
    extends State<StadiumBookingScreen> {
  // ============================================================
  // PAYMENT METHOD
  // ============================================================
  //
  // Payment is always online (InstaPay / Wallet), chosen later
  // in the payment screen. The booking is always created with
  // 'online'.
  // ============================================================

  static const String _paymentMethod = 'online';

  final TextEditingController _notesController =
  TextEditingController();

  static const Color primaryGreen = Color(0xFF7CC000);
  static const Color darkNavy = Color(0xFF1E1446);

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================

  String _formatDate(DateTime? date) {
    if (date == null) {
      return '—';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // ============================================================
  // FORMAT TIME
  // ============================================================

  String _formatTime(String time) {
    final parts = time.split(':');

    if (parts.length < 2) {
      return time;
    }

    final hour = int.tryParse(parts[0]);

    if (hour == null) {
      return time;
    }

    final minute = parts[1];

    final suffix = hour >= 12 ? 'PM' : 'AM';

    final displayHour =
    hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:$minute $suffix';
  }

  // ============================================================
  // CONFIRM BOOKING
  // ============================================================

  Future<void> _confirmBooking() async {
    final provider = context.read<StadiumProvider>();

    final booking = await provider.createBooking(
      pitchSlotId: widget.slotId,
      paymentMethod: _paymentMethod,
      notes: _notesController.text.trim(),
    );

    if (!mounted) return;

    // ==========================================================
    // BOOKING FAILED
    // ==========================================================

    if (booking == null) {
      final message =
          provider.errorMessage ??
              'Booking could not be created';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      );

      return;
    }

    // ==========================================================
    // BOOKING CREATED DIALOG
    // ==========================================================

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: primaryGreen,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Booking Created',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Your booking has been created successfully. You can continue to payment now.',
            style: TextStyle(
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'Continue',
                style: TextStyle(
                  color: primaryGreen,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    // ==========================================================
    // GO TO PAYMENT
    // ==========================================================

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PaymentScreen(
          booking: booking,
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final remaining =
        widget.price - widget.deposit;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F3),

      // ==========================================================
      // APP BAR
      // ==========================================================

      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F3),
        elevation: 0,
        foregroundColor: darkNavy,
        title: const Text(
          'Confirm Booking',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // ==========================================================
      // BODY
      // ==========================================================

      body: Consumer<StadiumProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                // ==================================================
                // BOOKING SUMMARY
                // ==================================================

                StadiumBookingSummary(
                  stadiumName:
                  widget.stadiumName,
                  date:
                  _formatDate(widget.date),
                  time:
                  '${_formatTime(widget.startTime)} - '
                      '${_formatTime(widget.endTime)}',
                  price: widget.price,
                  deposit: widget.deposit,
                  remaining: remaining,
                ),

                const SizedBox(height: 24),

                // ==================================================
                // PAYMENT METHOD (ONLINE ONLY)
                // ==================================================

                const Text(
                  'Payment Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: darkNavy,
                  ),
                ),

                const SizedBox(height: 12),

                const _PaymentOption(
                  title: 'Online',
                  icon: Icons.language,
                ),

                const SizedBox(height: 24),

                // ==================================================
                // NOTES
                // ==================================================

                const Text(
                  'Notes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: darkNavy,
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller: _notesController,
                  maxLines: 4,
                  textInputAction:
                  TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText:
                    'Add a note (optional)',
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding:
                    const EdgeInsets.all(16),
                    border: OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                      borderSide:
                      BorderSide.none,
                    ),
                    enabledBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                      borderSide:
                      BorderSide.none,
                    ),
                    focusedBorder:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(18),
                      borderSide:
                      const BorderSide(
                        color: primaryGreen,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // ==================================================
                // CONFIRM BUTTON
                // ==================================================

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                    provider.isCreatingBooking
                        ? null
                        : _confirmBooking,
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      primaryGreen,
                      foregroundColor:
                      Colors.black,
                      disabledBackgroundColor:
                      Colors.grey.shade300,
                      elevation: 0,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(17),
                      ),
                    ),
                    child:
                    provider.isCreatingBooking
                        ? const SizedBox(
                      width: 23,
                      height: 23,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color:
                        Colors.black,
                      ),
                    )
                        : const Text(
                      'Confirm Booking',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================================
// PAYMENT OPTION (single, always selected)
// ============================================================================

class _PaymentOption extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PaymentOption({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF7CC000),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFF7CC000),
            size: 25,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF7CC000),
                width: 2,
              ),
            ),
            child: Center(
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF7CC000),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}