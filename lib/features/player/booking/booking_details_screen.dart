import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/features/player/booking/models/booking_model.dart';
import 'package:e7m/features/player/booking/providers/booking_provider.dart';
import 'package:e7m/features/player/booking/qr_ticket_screen.dart';

class BookingDetailsScreen extends StatefulWidget {
  final BookingModel booking;

  const BookingDetailsScreen({
    super.key,
    required this.booking,
  });

  @override
  State<BookingDetailsScreen> createState() =>
      _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  BookingModel? _booking;

  @override
  void initState() {
    super.initState();

    _booking = widget.booking;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<BookingProvider>().fetchBookingDetails(
        widget.booking.id,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;
    final provider = context.watch<BookingProvider>();

    final BookingModel booking =
    provider.selectedBooking?.id == widget.booking.id
        ? provider.selectedBooking!
        : (_booking ?? widget.booking);

    final bool isLoading = provider.isLoadingDetails;

    final String pitchName =
    booking.pitchName?.trim().isNotEmpty == true
        ? booking.pitchName!
        : t('stadium');

    final String address =
    booking.pitchAddress?.trim().isNotEmpty == true
        ? booking.pitchAddress!
        : t('location_details');

    final String formattedDate = booking.slotDate != null
        ? DateFormat(
      'EEEE, d MMMM yyyy',
    ).format(booking.slotDate!)
        : '-';

    final String formattedTime =
        '${booking.startTime ?? '-'} - ${booking.endTime ?? '-'}';

    final String status = booking.status.isNotEmpty
        ? booking.status
        : 'pending';

    final String normalizedStatus =
    status.toLowerCase();

    final bool isConfirmed =
        normalizedStatus == 'confirmed';

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Color(0xff1E1446),
        ),
        title: Text(
          t('booking_details'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: RefreshIndicator(
        color: const Color(0xff7CC000),
        onRefresh: () async {
          await context
              .read<BookingProvider>()
              .fetchBookingDetails(widget.booking.id);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // ========================================================
              // LOADING INDICATOR
              // ========================================================

              if (isLoading)
                const Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: LinearProgressIndicator(
                    color: Color(0xff7CC000),
                    minHeight: 3,
                  ),
                ),

              // ========================================================
              // ERROR
              // ========================================================

              if (provider.errorMessage != null)
                _ErrorBanner(
                  message: provider.errorMessage!,
                  onRetry: () {
                    context
                        .read<BookingProvider>()
                        .fetchBookingDetails(
                      widget.booking.id,
                    );
                  },
                  retryText: t('retry'),
                ),

              // ========================================================
              // MAIN BOOKING CARD
              // ========================================================

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ==================================================
                    // STADIUM IMAGE
                    // ==================================================

                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                      child: Image.asset(
                        'assets/images/stadium.png',
                        height: 220,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) {
                          return Container(
                            height: 220,
                            width: double.infinity,
                            color: const Color(0xffEDEDED),
                            child: const Icon(
                              Icons.stadium,
                              size: 80,
                              color: Color(0xff7CC000),
                            ),
                          );
                        },
                      ),
                    ),

                    // ==================================================
                    // CONTENT
                    // ==================================================

                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // ============================================
                          // NAME + STATUS
                          // ============================================

                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  pitchName,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xff1E1446),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              _StatusBadge(
                                status: status,
                              ),
                            ],
                          ),

                          const SizedBox(height: 18),

                          // ============================================
                          // LOCATION
                          // ============================================

                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  address,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          const Divider(),

                          const SizedBox(height: 20),

                          // ============================================
                          // DATE
                          // ============================================

                          _buildRow(
                            icon: Icons.calendar_today,
                            title: t('date'),
                            value: formattedDate,
                          ),

                          // ============================================
                          // TIME
                          // ============================================

                          _buildRow(
                            icon: Icons.access_time,
                            title: t('time'),
                            value: formattedTime,
                          ),

                          // ============================================
                          // PITCH
                          // ============================================

                          _buildRow(
                            icon: Icons.sports_soccer,
                            title: t('pitch'),
                            value: pitchName,
                          ),

                          // ============================================
                          // BOOKING ID
                          // ============================================

                          _buildRow(
                            icon:
                            Icons.confirmation_number_outlined,
                            title: t('booking_id'),
                            value: booking.id.toString(),
                          ),

                          // ============================================
                          // PRICE
                          // ============================================

                          _buildRow(
                            icon: Icons.currency_exchange,
                            title: t('price'),
                            value:
                            '${booking.totalPrice.toStringAsFixed(2)} EGP',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ========================================================
              // PAYMENT DETAILS
              // ========================================================

              _PaymentDetailsCard(
                booking: booking,
                translate: t,
              ),

              const SizedBox(height: 20),

              // ========================================================
              // BOOKING SUMMARY / NOTES
              // ========================================================

              if ((booking.notes ?? '').trim().isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      Text(
                        t('booking_summary'),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1E1446),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.notes,
                            color: Color(0xff7CC000),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              booking.notes!,
                              style: const TextStyle(
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 25),

              // ========================================================
              // QR TICKET
              // ========================================================

              if (isConfirmed)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xff1E1446),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QRTicketScreen(
                            booking: booking,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.qr_code,
                      color: Colors.white,
                    ),
                    label: Text(
                      t('show_qr_ticket'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // INFO ROW
  // ==============================================================

  static Widget _buildRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 18,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xff7CC000),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xff1E1446),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PAYMENT DETAILS CARD
// ============================================================================

class _PaymentDetailsCard extends StatelessWidget {
  final BookingModel booking;
  final String Function(String) translate;

  const _PaymentDetailsCard({
    required this.booking,
    required this.translate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            translate('payment_details'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E1446),
            ),
          ),

          const SizedBox(height: 18),

          _paymentRow(
            title: translate('total'),
            value:
            '${booking.totalPrice.toStringAsFixed(2)} EGP',
          ),

          _paymentRow(
            title: translate('deposit'),
            value:
            '${booking.depositAmount.toStringAsFixed(2)} EGP',
          ),

          _paymentRow(
            title: translate('remaining'),
            value:
            '${booking.remainingAmount.toStringAsFixed(2)} EGP',
          ),

          const Divider(height: 24),

          _paymentRow(
            title: translate('payment_method'),
            value: booking.paymentMethod ?? '-',
          ),

          _paymentRow(
            title: translate('payment_status'),
            value: booking.paymentStatus ?? '-',
            valueColor:
            _paymentStatusColor(
              booking.paymentStatus,
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentRow({
    required String title,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color:
                valueColor ??
                    const Color(0xff1E1446),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _paymentStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
        return const Color(0xff7CC000);

      case 'unpaid':
        return Colors.orange.shade700;

      case 'failed':
        return Colors.red.shade700;

      default:
        return const Color(0xff1E1446);
    }
  }
}

// ============================================================================
// STATUS BADGE
// ============================================================================

class _StatusBadge extends StatelessWidget {
  final String status;

  const _StatusBadge({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedStatus =
    status.toLowerCase();

    Color backgroundColor;
    Color textColor;

    switch (normalizedStatus) {
      case 'confirmed':
        backgroundColor =
        const Color(0xff7CC000);
        textColor = Colors.white;
        break;

      case 'cancelled':
      case 'canceled':
      case 'rejected':
        backgroundColor =
            Colors.red.shade100;
        textColor =
            Colors.red.shade700;
        break;

      case 'completed':
        backgroundColor =
            Colors.blue.shade100;
        textColor =
            Colors.blue.shade700;
        break;

      case 'pending':
      default:
        backgroundColor =
            Colors.orange.shade100;
        textColor =
            Colors.orange.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// ============================================================================
// ERROR BANNER
// ============================================================================

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryText;

  const _ErrorBanner({
    required this.message,
    required this.onRetry,
    required this.retryText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius:
        BorderRadius.circular(14),
        border: Border.all(
          color: Colors.red.shade100,
        ),
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
              ),
            ),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(
              retryText,
              style: const TextStyle(
                color: Color(0xff7CC000),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}