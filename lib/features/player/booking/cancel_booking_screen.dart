import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/features/player/booking/models/booking_model.dart';
import 'package:e7m/features/player/booking/providers/booking_provider.dart';

class CancelBookingScreen extends StatefulWidget {
  final BookingModel booking;

  const CancelBookingScreen({
    super.key,
    required this.booking,
  });

  @override
  State<CancelBookingScreen> createState() => _CancelBookingScreenState();
}

class _CancelBookingScreenState extends State<CancelBookingScreen> {
  bool _isCancelling = false;

  Future<void> _cancelBooking() async {
    if (_isCancelling) return;

    setState(() {
      _isCancelling = true;
    });

    final provider = context.read<BookingProvider>();

    final success = await provider.cancelBooking(widget.booking.id);

    if (!mounted) return;

    setState(() {
      _isCancelling = false;
    });

    if (success) {
      Navigator.pop(context, true);
      return;
    }

    final errorMessage =
        provider.errorMessage ?? 'Failed to cancel booking';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;
    final booking = widget.booking;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: _isCancelling
              ? null
              : () => Navigator.pop(context),
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
            color: const Color(0xff1E1446),
          ),
        ),
        title: Text(
          t('cancel_booking'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    // =====================================================
                    // WARNING
                    // =====================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 70,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            t('cancel_booking_confirm_question') ??
                                'Cancel This Booking?',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff1E1446),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            t('cancel_booking_warning_desc') ??
                                'Are you sure you want to cancel your reservation?',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =====================================================
                    // BOOKING INFORMATION
                    // =====================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 12,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.receipt_long_rounded,
                                color: Color(0xff1E1446),
                                size: 22,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t('booking_info_destination') ??
                                    'Booking Information',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff1E1446),
                                ),
                              ),
                            ],
                          ),

                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(
                              height: 1,
                              color: Colors.black12,
                            ),
                          ),

                          _buildInfoRow(
                            t('booking_id'),
                            booking.id.toString(),
                            isBoldValue: true,
                          ),

                          const SizedBox(height: 12),

                          _buildInfoRow(
                            t('total'),
                            '${booking.totalPrice.toStringAsFixed(2)} EGP',
                            isBoldValue: true,
                          ),

                          const SizedBox(height: 12),

                          _buildInfoRow(
                            t('deposit'),
                            '${booking.depositAmount.toStringAsFixed(2)} EGP',
                          ),

                          const SizedBox(height: 12),

                          _buildInfoRow(
                            t('remaining'),
                            '${booking.remainingAmount.toStringAsFixed(2)} EGP',
                          ),

                          const SizedBox(height: 12),

                          _buildInfoRow(
                            t('payment_method'),
                            booking.paymentMethod?.isNotEmpty == true
                                ? booking.paymentMethod!
                                : '-',
                          ),

                          const SizedBox(height: 12),

                          _buildInfoRow(
                            t('payment_status'),
                            booking.paymentStatus?.isNotEmpty == true
                                ? booking.paymentStatus!
                                : '-',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // =====================================================
                    // IMPORTANT REFUND NOTICE
                    // =====================================================

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Colors.orange,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Refund details will be determined according to the booking cancellation policy.',
                              style: TextStyle(
                                color: Colors.orange.shade900,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ===========================================================
            // ACTION BUTTONS
            // ===========================================================

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isCancelling
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      side: const BorderSide(
                        color: Colors.black26,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      t('keep_booking') ?? 'Keep Booking',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: _isCancelling ? null : _cancelBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      disabledBackgroundColor:
                      Colors.red.withOpacity(0.5),
                      elevation: 0,
                      minimumSize: const Size(0, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isCancelling
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    )
                        : Text(
                      t('cancel_booking'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String title,
      String value, {
        bool isBoldValue = false,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight:
              isBoldValue ? FontWeight.bold : FontWeight.w600,
              color: const Color(0xff1E1446),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}