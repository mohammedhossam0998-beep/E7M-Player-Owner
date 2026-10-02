import 'package:flutter/material.dart';

import '../../data/models/stadium.dart';
import 'stadium_favorite_button.dart';

class StadiumCard extends StatelessWidget {
  final Stadium stadium;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;

  const StadiumCard({
    super.key,
    required this.stadium,
    this.onTap,
    this.isFavorite = false,
    this.onFavoritePressed,
  });

  static const Color primaryGreen = Color(0xFF7CC000);
  static const Color darkNavy = Color(0xFF1E1446);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(context),

              Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  14,
                  16,
                  16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stadium.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: darkNavy,
                      ),
                    ),

                    if (_hasLocation) ...[
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 18,
                            color: primaryGreen,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              _locationText,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 14),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (_hasPitchType)
                                _InfoChip(
                                  icon: Icons.sports_soccer,
                                  text: stadium.pitchType!,
                                ),

                              if (stadium.capacity != null)
                                _InfoChip(
                                  icon: Icons.people_outline,
                                  text: '${stadium.capacity}',
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.end,
                          children: [
                            Text(
                              _formatPrice(stadium.basePrice),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                                color: primaryGreen,
                              ),
                            ),
                            Text(
                              'per slot',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasPitchType =>
      stadium.pitchType != null &&
          stadium.pitchType!.trim().isNotEmpty;

  bool get _hasLocation =>
      (stadium.cityName != null &&
          stadium.cityName!.trim().isNotEmpty) ||
          (stadium.address != null &&
              stadium.address!.trim().isNotEmpty);

  String get _locationText {
    final city = stadium.cityName?.trim();
    final address = stadium.address?.trim();

    if (city != null &&
        city.isNotEmpty &&
        address != null &&
        address.isNotEmpty) {
      return '$city • $address';
    }

    if (city != null && city.isNotEmpty) {
      return city;
    }

    return address ?? '';
  }

  String _formatPrice(double price) {
    if (price == price.roundToDouble()) {
      return '${price.toStringAsFixed(0)} EGP';
    }

    return '${price.toStringAsFixed(2)} EGP';
  }

  Widget _buildImage(BuildContext context) {
    final image = stadium.primaryImage;

    return SizedBox(
      height: 190,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image == null || image.trim().isEmpty
              ? const _ImagePlaceholder()
              : Image.network(
            _buildImageUrl(image),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) {
              return const _ImagePlaceholder();
            },
            loadingBuilder: (context, child, progress) {
              if (progress == null) {
                return child;
              }

              return const _ImagePlaceholder(
                showLoading: true,
              );
            },
          ),

          Positioned(
            top: 12,
            right: 12,
            child: StadiumFavoriteButton(
              isFavorite: isFavorite,
              onPressed: onFavoritePressed,
            ),
          ),
        ],
      ),
    );
  }

  String _buildImageUrl(String image) {
    final value = image.trim();

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    return '192.168.1.3:5000$value';
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  static const Color primaryGreen = Color(0xFF7CC000);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: primaryGreen.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.circle,
            size: 5,
            color: primaryGreen,
          ),
          const SizedBox(width: 5),
          Icon(
            icon,
            size: 14,
            color: primaryGreen,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  final bool showLoading;

  const _ImagePlaceholder({
    this.showLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: showLoading
            ? const CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF7CC000),
        )
            : Icon(
          Icons.stadium_outlined,
          size: 52,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}