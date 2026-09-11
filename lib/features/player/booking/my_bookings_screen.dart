import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/features/player/booking/models/booking_model.dart';
import 'package:e7m/features/player/booking/providers/booking_provider.dart';

import 'cancel_booking_screen.dart';
import 'booking_details_screen.dart';
import 'qr_ticket_screen.dart';
import 'package:e7m/features/player/reviews/presentation/screens/create_review_screen.dart';
import 'package:e7m/features/player/payments/screens/payment_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  const MyBookingsScreen({super.key});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  int selectedTab = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<BookingProvider>().fetchMyBookings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;
    final bookingProvider = context.watch<BookingProvider>();

    final List<BookingModel> filteredBookings =
    selectedTab == 0
        ? bookingProvider.upcomingBookings
        : bookingProvider.completedBookings;

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          t('my_bookings'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: RefreshIndicator(
        color: const Color(0xff7CC000),
        onRefresh: () async {
          await context.read<BookingProvider>().refreshBookings();
        },
        child: Column(
          children: [
            const SizedBox(height: 10),

            // ========================================================
            // COUNT
            // ========================================================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${filteredBookings.length} ${t('bookings')}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1E1446),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ========================================================
            // TABS
            // ========================================================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: tabButton(
                      title: t('upcoming'),
                      index: 0,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: tabButton(
                      title: t('completed'),
                      index: 1,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ========================================================
            // LOADING
            // ========================================================

            if (bookingProvider.isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xff7CC000),
                  ),
                ),
              )

            // ========================================================
            // ERROR
            // ========================================================

            else if (bookingProvider.errorMessage != null &&
                bookingProvider.bookings.isEmpty)
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 70,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          bookingProvider.errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<BookingProvider>()
                                .fetchMyBookings();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff7CC000),
                          ),
                          child: Text(
                            t('retry'),
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )

            // ========================================================
            // EMPTY
            // ========================================================

            else if (filteredBookings.isEmpty)
                Expanded(
                  child: Center(
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.18,
                        ),
                        Column(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 110,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              selectedTab == 0
                                  ? t('no_upcoming_bookings')
                                  : t('no_completed_bookings'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff1E1446),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                              ),
                              child: Text(
                                selectedTab == 0
                                    ? t('upcoming_bookings_msg')
                                    : t('completed_bookings_msg'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                )

              // ========================================================
              // BOOKINGS
              // ========================================================

              else
                Expanded(
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];

                      return bookingCard(
                        booking,
                        t,
                      );
                    },
                  ),
                ),
          ],
        ),
      ),
    );
  }

  // ==============================================================
  // TAB BUTTON
  // ==============================================================

  Widget tabButton({
    required String title,
    required int index,
  }) {
    final bool isSelected = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedTab = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        height: 50,
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xff7CC000)
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? const Color(0xff7CC000)
                : Colors.grey.shade200,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected
                  ? Colors.white
                  : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  // ==============================================================
  // BOOKING CARD
  // ==============================================================

  Widget bookingCard(
      BookingModel booking,
      String Function(String) t,
      ) {
    final String status = booking.status.toLowerCase();

    final bool isConfirmed = status == 'confirmed';
    final bool isPending = status == 'pending';
    final bool isCompleted = status == 'completed';

    final String pitchName =
    booking.pitchName?.trim().isNotEmpty == true
        ? booking.pitchName!
        : t('stadium');

    final String location =
    booking.pitchAddress?.trim().isNotEmpty == true
        ? booking.pitchAddress!
        : t('location_details');

    final String date = booking.slotDate != null
        ? DateFormat(
      'EEEE, d MMMM yyyy',
    ).format(booking.slotDate!)
        : '-';

    final String time =
        '${booking.startTime ?? '-'} - ${booking.endTime ?? '-'}';

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========================================================
          // IMAGE
          // ========================================================

          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.asset(
              'assets/images/stadium_book.jpg',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 160,
                  width: double.infinity,
                  color: const Color(0xffEDEDED),
                  child: const Icon(
                    Icons.stadium,
                    size: 70,
                    color: Color(0xff7CC000),
                  ),
                );
              },
            ),
          ),

          // ========================================================
          // CONTENT
          // ========================================================

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================================================
                // NAME + STATUS
                // ==================================================

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        pitchName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff1E1446),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _statusBadge(
                      status: status,
                      originalStatus: booking.status,
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Text(
                  location,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 12),

                const Divider(),

                const SizedBox(height: 10),

                // ==================================================
                // DATE + TIME
                // ==================================================

                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        date,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // ==================================================
                // PITCH + DETAILS
                // ==================================================

                Row(
                  children: [
                    const Icon(
                      Icons.sports_soccer,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        booking.pitchId != null
                            ? '${t('pitch')} ${booking.pitchId}'
                            : t('pitch'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BookingDetailsScreen(
                              booking: booking,
                            ),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Text(
                            t('view_details'),
                            style: const TextStyle(
                              color: Color(0xff7CC000),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                            color: Color(0xff7CC000),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ==================================================
                // PAYMENT SUMMARY
                // ==================================================

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xffF7F7F3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _priceInfo(
                          label: t('total'),
                          value:
                          '${booking.totalPrice.toStringAsFixed(2)} EGP',
                        ),
                      ),
                      Expanded(
                        child: _priceInfo(
                          label: t('payment_status'),
                          value: booking.paymentStatus ?? '-',
                        ),
                      ),
                    ],
                  ),
                ),

                // ==================================================
                // PAYMENT BUTTON
                // ==================================================

                if (booking.paymentStatus?.toLowerCase() != 'paid' &&
                    (booking.depositAmount > 0 ||
                        booking.remainingAmount > 0)) ...[
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff7CC000),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(
                              booking: booking,
                            ),
                          ),
                        );

                        if (!context.mounted) return;

                        await context
                            .read<BookingProvider>()
                            .refreshBookings();
                      },
                      icon: const Icon(
                        Icons.payment_outlined,
                        color: Colors.white,
                      ),
                      label: Text(
                        t('pay_now'),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // ==================================================
                // BUTTONS
                // ==================================================

                Row(
                  children: [
                    // ==================================================
                    // QR
                    // ==================================================

                    if (isConfirmed)
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xff1E1446),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
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
                              size: 20,
                            ),
                            label: Text(
                              t('qr_ticket'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      const Spacer(),

                    const SizedBox(width: 12),

                    // ==================================================
                    // CANCEL / BOOK AGAIN
                    // ==================================================

                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: isConfirmed || isPending
                            ? OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(
                              color: Colors.red,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            final cancelled = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CancelBookingScreen(
                                  booking: booking,
                                ),
                              ),
                            );

                            if (!context.mounted) return;

                            if (cancelled == true) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    t('booking_cancelled'),
                                  ),
                                  backgroundColor: Colors.redAccent,
                                ),
                              );
                            }
                          },
                          child: Text(
                            t('cancel_booking'),
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                            : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            const Color(0xff7CC000),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: isCompleted &&
                              booking.pitchId != null
                              ? () async {
                            final result =
                            await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    CreateReviewScreen(
                                      bookingId:
                                      booking.id.toString(),
                                      pitchId: booking
                                          .pitchId!
                                          .toString(),
                                      pitchName: pitchName,
                                    ),
                              ),
                            );

                            if (!context.mounted) return;

                            if (result == true) {
                              await context
                                  .read<BookingProvider>()
                                  .refreshBookings();
                            }
                          }
                              : null,
                          child: const Text(
                            'Write Review',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==============================================================
  // STATUS BADGE
  // ==============================================================

  Widget _statusBadge({
    required String status,
    required String originalStatus,
  }) {
    Color backgroundColor;

    switch (status) {
      case 'confirmed':
        backgroundColor = const Color(0xff7CC000);
        break;

      case 'pending':
        backgroundColor = Colors.orange.shade600;
        break;

      case 'completed':
        backgroundColor = const Color(0xff1E1446);
        break;

      case 'cancelled':
        backgroundColor = Colors.red.shade600;
        break;

      case 'rejected':
        backgroundColor = Colors.red.shade600;
        break;

      default:
        backgroundColor = Colors.grey.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        originalStatus,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ==============================================================
  // PRICE INFO
  // ==============================================================

  Widget _priceInfo({
    required String label,
    required String value,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}