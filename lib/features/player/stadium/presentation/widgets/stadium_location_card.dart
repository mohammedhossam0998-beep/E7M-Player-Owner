import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/stadium.dart';

class StadiumLocationCard extends StatelessWidget {
  final Stadium stadium;

  const StadiumLocationCard({
    super.key,
    required this.stadium,
  });

  static const Color primaryGreen = Color(0xFF7CC000);
  static const Color darkNavy = Color(0xFF1E1446);

  bool get _hasCoordinates =>
      stadium.latitude != null &&
          stadium.longitude != null;

  bool get _hasAddress =>
      stadium.address != null &&
          stadium.address!.trim().isNotEmpty;

  bool get _hasCity =>
      stadium.cityName != null &&
          stadium.cityName!.trim().isNotEmpty;

  Future<void> _openLocation() async {
    if (!_hasCoordinates) {
      return;
    }

    final latitude = stadium.latitude!;
    final longitude = stadium.longitude!;

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1'
          '&query=$latitude,$longitude',
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasAddress && !_hasCity && !_hasCoordinates) {
      return const SizedBox.shrink();
    }

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
            'Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: darkNavy,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: primaryGreen.withValues(
                    alpha: 0.10,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  color: primaryGreen,
                  size: 24,
                ),
              ),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    if (_hasAddress)
                      Text(
                        stadium.address!.trim(),
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                          color: darkNavy,
                        ),
                      ),

                    if (_hasCity) ...[
                      if (_hasAddress)
                        const SizedBox(height: 5),
                      Text(
                        stadium.cityName!.trim(),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          if (_hasCoordinates) ...[
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _openLocation,
                icon: const Icon(
                  Icons.directions_outlined,
                  size: 21,
                ),
                label: const Text(
                  'Open in Google Maps',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryGreen,
                  foregroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}