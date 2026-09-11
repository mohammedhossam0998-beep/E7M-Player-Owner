import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/features/player/booking/models/booking_model.dart';

class QRTicketScreen extends StatelessWidget {
  final BookingModel booking;

  const QRTicketScreen({
    super.key,
    required this.booking,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    final bookingId = booking.id.toString();

    final stadiumName =
    booking.pitchName?.trim().isNotEmpty == true
        ? booking.pitchName!
        : t('stadium');

    final date = booking.slotDate != null
        ? '${booking.slotDate!.day.toString().padLeft(2, '0')}/'
        '${booking.slotDate!.month.toString().padLeft(2, '0')}/'
        '${booking.slotDate!.year}'
        : '-';

    final time =
        '${booking.startTime ?? '-'} - ${booking.endTime ?? '-'}';

    final status = booking.status.toLowerCase();

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        centerTitle: true,
        title: Text(
          t('booking_ticket'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Directionality.of(context) == TextDirection.rtl
                ? Icons.arrow_forward_ios
                : Icons.arrow_back_ios,
            color: const Color(0xff1E1446),
            size: 20,
          ),
        ),
      ),

      body: Center(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.sports_soccer,
                  size: 40,
                  color: Color(0xff7CC000),
                ),

                const SizedBox(height: 8),

                Text(
                  t('e7gzly_ticket'),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 20),

                const Divider(
                  color: Colors.black12,
                  thickness: 1,
                ),

                const SizedBox(height: 20),

                // =====================================================
                // QR CODE
                // =====================================================

                QrImageView(
                  data: bookingId,
                  size: 200,
                  version: QrVersions.auto,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xff1E1446),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xff1E1446),
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  stadiumName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff1E1446),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  '${t('booking_id')}: #$bookingId',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 14),

                // =====================================================
                // STATUS
                // =====================================================

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: status == 'confirmed'
                        ? const Color(0xff7CC000)
                        : Colors.orange,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    booking.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Divider(
                  color: Colors.black12,
                  thickness: 1,
                ),

                const SizedBox(height: 20),

                // =====================================================
                // DATE + TIME
                // =====================================================

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,
                              size: 18,
                              color: Color(0xff7CC000),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              t('date'),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          date,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1E1446),
                          ),
                        ),
                      ],
                    ),

                    Container(
                      height: 40,
                      width: 1,
                      color: Colors.black12,
                    ),

                    Column(
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_filled,
                              size: 18,
                              color: Color(0xff7CC000),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              t('time'),
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          time,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff1E1446),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // =====================================================
                // QR NOTE
                // =====================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xffEEF5E5),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xff7CC000)
                          .withOpacity(0.2),
                    ),
                  ),
                  child: Text(
                    t('show_qr_note'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xff1E1446),
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 5),
              ],
            ),
          ),
        ),
      ),
    );
  }
}