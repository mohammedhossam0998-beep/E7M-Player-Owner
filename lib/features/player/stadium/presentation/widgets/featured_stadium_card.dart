import 'package:flutter/material.dart';

import '../../data/models/stadium.dart';
import 'stadium_favorite_button.dart';

class FeaturedStadiumCard extends StatelessWidget {
  final Stadium stadium;
  final VoidCallback? onTap;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;

  const FeaturedStadiumCard({
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
    return SizedBox(
      width: 285,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImage(),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      14,
                      12,
                      14,
                      14,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Text(
                          stadium.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: darkNavy,
                          ),
                        ),

                        if (_hasLocation) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 15,
                                color: primaryGreen,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _locationText,
                                  maxLines: 1,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight:
                                    FontWeight.w600,
                                    color:
                                    Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],

                        const Spacer(),

                        Row(
                          children: [
                            if (_hasPitchType)
                              Flexible(
                                child: Container(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 8,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: primaryGreen
                                        .withValues(
                                      alpha: 0.10,
                                    ),
                                    borderRadius:
                                    BorderRadius.circular(9),
                                  ),
                                  child: Text(
                                    stadium.pitchType!,
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight:
                                      FontWeight.w800,
                                      color: darkNavy,
                                    ),
                                  ),
                                ),
                              ),

                            const Spacer(),

                            Text(
                              _formatPrice(
                                stadium.basePrice,
                              ),
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: primaryGreen,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    final image = stadium.primaryImage;

    return SizedBox(
      height: 140,
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
                loading: true,
              );
            },
          ),

          Positioned(
            top: 10,
            right: 10,
            child: StadiumFavoriteButton(
              isFavorite: isFavorite,
              onPressed: onFavoritePressed,
              size: 20,
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

    return 'http://172.16.25.24:5000$value';
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
}

class _ImagePlaceholder extends StatelessWidget {
  final bool loading;

  const _ImagePlaceholder({
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: loading
            ? const CircularProgressIndicator(
          strokeWidth: 2,
          color: Color(0xFF7CC000),
        )
            : Icon(
          Icons.stadium_outlined,
          size: 44,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}