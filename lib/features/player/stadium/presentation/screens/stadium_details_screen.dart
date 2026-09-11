import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/stadium.dart';
import '../../data/models/stadium_image.dart';
import '../providers/stadium_provider.dart';
import '../screens/stadium_booking_screen.dart'; // ⚠️ تأكد من المسار الصح
import '../widgets/favorites_service.dart';
import '../widgets/stadium_favorite_button.dart';
import 'stadium_gallery_screen.dart';

import '../../../reviews/presentation/providers/review_provider.dart';
import '../../../reviews/presentation/screens/reviews_screen.dart';
import '../../../reviews/data/models/review.dart';

class StadiumDetailsScreen extends StatefulWidget {
  final String stadiumId;

  const StadiumDetailsScreen({
    super.key,
    required this.stadiumId,
  });

  @override
  State<StadiumDetailsScreen> createState() =>
      _StadiumDetailsScreenState();
}

class _StadiumDetailsScreenState
    extends State<StadiumDetailsScreen> {
  static const Color primaryGreen = Color(0xFF7CC000);

  bool _isFavorite = false;
  bool _isFavoriteLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stadiumProvider = context.read<StadiumProvider>();
      final reviewProvider = context.read<ReviewProvider>();

      stadiumProvider.loadStadiumDetails(widget.stadiumId);
      stadiumProvider.loadStadiumImages(widget.stadiumId);

      reviewProvider.loadPitchReviews(widget.stadiumId);

      _loadFavoriteStatus();
    });
  }

  Future<void> _loadFavoriteStatus() async {
    try {
      final isFavorite = await FavoritesService.isFavorite(
        widget.stadiumId,
      );

      if (!mounted) return;

      setState(() {
        _isFavorite = isFavorite;
      });
    } catch (e) {
      debugPrint('LOAD FAVORITE STATUS ERROR: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isFavoriteLoading) return;

    setState(() {
      _isFavoriteLoading = true;
    });

    try {
      final favoriteIds = await FavoritesService.toggleFavorite(
        widget.stadiumId,
      );

      if (!mounted) return;

      setState(() {
        _isFavorite = favoriteIds.contains(widget.stadiumId);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (!mounted) return;

      setState(() {
        _isFavoriteLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<StadiumProvider>(
        builder: (context, provider, child) {
          if (provider.isLoadingDetails) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
              ),
            );
          }

          if (provider.errorMessage != null &&
              provider.selectedStadium == null) {
            return _ErrorView(
              message: provider.errorMessage!,
              onRetry: () {
                provider.loadStadiumDetails(
                  widget.stadiumId,
                );
              },
            );
          }

          final stadium = provider.selectedStadium;

          if (stadium == null) {
            return const Center(
              child: Text(
                'Stadium not found',
              ),
            );
          }

          return Consumer<ReviewProvider>(
            builder: (context, reviewProvider, child) {
              return _DetailsContent(
                stadium: stadium,
                images: provider.images,
                isLoadingImages: provider.isLoadingImages,
                isFavorite: _isFavorite,
                isFavoriteLoading: _isFavoriteLoading,
                onFavoritePressed: _toggleFavorite,
                reviews: reviewProvider.reviews,
                averageRating: reviewProvider.averageRating,
                totalReviews: reviewProvider.totalReviews,
                isLoadingReviews: reviewProvider.isLoading,
                reviewError: reviewProvider.errorMessage,
              );
            },
          );
        },
      ),
    );
  }
}

class _DetailsContent extends StatelessWidget {
  final Stadium stadium;
  final List<StadiumImage> images;
  final bool isLoadingImages;
  final bool isFavorite;
  final bool isFavoriteLoading;
  final VoidCallback onFavoritePressed;
  final List<Review> reviews;
  final double averageRating;
  final int totalReviews;
  final bool isLoadingReviews;
  final String? reviewError;

  const _DetailsContent({
    required this.stadium,
    required this.images,
    required this.isLoadingImages,
    required this.isFavorite,
    required this.isFavoriteLoading,
    required this.onFavoritePressed,
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
    required this.isLoadingReviews,
    required this.reviewError,
  });

  static const Color primaryGreen = Color(0xFF7CC000);

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(
            stadium.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: GestureDetector(
              onTap: images.isEmpty
                  ? null
                  : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => StadiumGalleryScreen(
                      stadiumName: stadium.name,
                      images: images,
                    ),
                  ),
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _HeroImage(
                    image: stadium.primaryImage,
                  ),

                  Positioned(
                    top: 16,
                    left: 16,
                    child: IgnorePointer(
                      ignoring: isFavoriteLoading,
                      child: StadiumFavoriteButton(
                        isFavorite: isFavorite,
                        onPressed: onFavoritePressed,
                        size: 23,
                      ),
                    ),
                  ),

                  if (images.isNotEmpty)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius:
                          BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.photo_library_outlined,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${images.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
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

        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate(
              [
                Text(
                  stadium.name,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 10),

                if (stadium.cityName != null ||
                    stadium.address != null)
                  Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: primaryGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          stadium.address ??
                              stadium.cityName ??
                              '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 22),

                _MainInfoCard(
                  stadium: stadium,
                ),

                const SizedBox(height: 22),

                _StadiumLocationSection(
                  stadium: stadium,
                ),

                if (stadium.description != null &&
                    stadium.description!.trim().isNotEmpty) ...[
                  const SizedBox(height: 22),
                  const Text(
                    'About this stadium',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    stadium.description!,
                    style: TextStyle(
                      height: 1.6,
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],

                const SizedBox(height: 28),

                _StadiumReviewsPreview(
                  pitchId: stadium.id,
                  pitchName: stadium.name,
                  reviews: reviews,
                  averageRating: averageRating,
                  totalReviews: totalReviews,
                  isLoading: isLoadingReviews,
                  errorMessage: reviewError,
                ),

                const SizedBox(height: 28),

                _StadiumSlotsSection(
                  stadium: stadium,
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  final String? image;

  const _HeroImage({
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    if (image == null || image!.isEmpty) {
      return _placeholder();
    }

    final imageUrl = image!.startsWith('http://') ||
        image!.startsWith('https://')
        ? image!
        : 'http://192.168.1.2:5000$image';

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) {
        return _placeholder();
      },
      loadingBuilder: (
          context,
          child,
          progress,
          ) {
        if (progress == null) {
          return child;
        }

        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF7CC000),
          ),
        );
      },
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade900,
      child: const Center(
        child: Icon(
          Icons.stadium_outlined,
          size: 70,
          color: Colors.white54,
        ),
      ),
    );
  }
}

class _MainInfoCard extends StatelessWidget {
  final Stadium stadium;

  const _MainInfoCard({
    required this.stadium,
  });

  static const Color primaryGreen = Color(0xFF7CC000);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _InfoItem(
              icon: Icons.sports_soccer,
              title: 'Type',
              value: stadium.pitchType ?? '—',
            ),
          ),
          Expanded(
            child: _InfoItem(
              icon: Icons.people_outline,
              title: 'Capacity',
              value: stadium.capacity?.toString() ?? '—',
            ),
          ),
          Expanded(
            child: _InfoItem(
              icon: Icons.payments_outlined,
              title: 'Price',
              value:
              '${stadium.basePrice.toStringAsFixed(0)} EGP',
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  static const Color primaryGreen = Color(0xFF7CC000);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          icon,
          color: primaryGreen,
          size: 24,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _StadiumLocationSection extends StatelessWidget {
  final Stadium stadium;

  const _StadiumLocationSection({
    required this.stadium,
  });

  static const Color primaryGreen = Color(0xFF7CC000);

  bool get _hasCoordinates {
    return stadium.latitude != null &&
        stadium.longitude != null;
  }

  Future<void> _openInMaps() async {
    if (!_hasCoordinates) return;

    final latitude = stadium.latitude!;
    final longitude = stadium.longitude!;

    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude',
    );

    if (!await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    )) {
      throw Exception('Could not open maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 12),

        if (!_hasCoordinates)
          _LocationUnavailable(
            address: stadium.address ?? stadium.cityName,
          )
        else
          _LocationMap(
            latitude: stadium.latitude!,
            longitude: stadium.longitude!,
            onOpenMaps: _openInMaps,
          ),
      ],
    );
  }
}

class _LocationMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final VoidCallback onOpenMaps;

  const _LocationMap({
    required this.latitude,
    required this.longitude,
    required this.onOpenMaps,
  });

  static const Color primaryGreen = Color(0xFF7CC000);

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: point,
                initialZoom: 15,
                interactionOptions: const InteractionOptions(
                  flags: InteractiveFlag.all,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.e7m.app',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: point,
                      width: 50,
                      height: 50,
                      child: Container(
                        decoration: BoxDecoration(
                          color: primaryGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sports_soccer,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Material(
            color: Theme.of(context).cardColor,
            child: InkWell(
              onTap: onOpenMaps,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: primaryGreen,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        'Open location in Google Maps',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    const Icon(
                      Icons.open_in_new,
                      size: 19,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationUnavailable extends StatelessWidget {
  final String? address;

  const _LocationUnavailable({
    required this.address,
  });

  static const Color primaryGreen = Color(0xFF7CC000);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryGreen.withValues(alpha: 0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_off_outlined,
              color: primaryGreen,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Location unavailable',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  address?.trim().isNotEmpty == true
                      ? address!
                      : 'Location coordinates are not available yet.',
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StadiumReviewsPreview extends StatelessWidget {
  final String pitchId;
  final String pitchName;
  final List<Review> reviews;
  final double averageRating;
  final int totalReviews;
  final bool isLoading;
  final String? errorMessage;

  const _StadiumReviewsPreview({
    required this.pitchId,
    required this.pitchName,
    required this.reviews,
    required this.averageRating,
    required this.totalReviews,
    required this.isLoading,
    required this.errorMessage,
  });

  static const Color primaryGreen = Color(0xFF7CC000);
  static const Color darkNavy = Color(0xFF1E1446);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reviews',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 14),
          Center(
            child: CircularProgressIndicator(
              color: primaryGreen,
            ),
          ),
        ],
      );
    }

    if (errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reviews',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            errorMessage!,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Reviews',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            if (totalReviews > 0)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewsScreen(
                        pitchId: pitchId,
                        pitchName: pitchName,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: primaryGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      color: darkNavy,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PreviewStars(
                        rating: averageRating,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$totalReviews '
                            '${totalReviews == 1 ? 'Review' : 'Reviews'}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              if (reviews.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 14),

                ...reviews
                    .take(2)
                    .map(
                      (review) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _PreviewReviewItem(
                      review: review,
                    ),
                  ),
                ),

                if (totalReviews > 2)
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReviewsScreen(
                              pitchId: pitchId,
                              pitchName: pitchName,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'View all reviews',
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ] else ...[
                const SizedBox(height: 14),
                Text(
                  'No reviews yet.',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewReviewItem extends StatelessWidget {
  final Review review;

  const _PreviewReviewItem({
    required this.review,
  });

  static const Color darkNavy = Color(0xFF1E1446);

  @override
  Widget build(BuildContext context) {
    final playerName = review.playerName.trim().isEmpty
        ? 'Player'
        : review.playerName.trim();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF7CC000).withValues(
            alpha: 0.12,
          ),
          child: Text(
            playerName.substring(0, 1).toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF7CC000),
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                playerName,
                style: const TextStyle(
                  color: darkNavy,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              _PreviewStars(
                rating: review.rating.toDouble(),
                size: 15,
              ),

              if (review.comment != null &&
                  review.comment!.trim().isNotEmpty) ...[
                const SizedBox(height: 5),
                Text(
                  review.comment!.trim(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PreviewStars extends StatelessWidget {
  final double rating;
  final double size;

  const _PreviewStars({
    required this.rating,
    this.size = 18,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
            (index) {
          return Icon(
            rating >= index + 1
                ? Icons.star_rounded
                : Icons.star_border_rounded,
            size: size,
            color: const Color(0xFFFFB800),
          );
        },
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StadiumSlotsSection extends StatefulWidget {
  final Stadium stadium;

  const _StadiumSlotsSection({
    required this.stadium,
  });

  @override
  State<_StadiumSlotsSection> createState() =>
      _StadiumSlotsSectionState();
}

class _StadiumSlotsSectionState
    extends State<_StadiumSlotsSection> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<StadiumProvider>()
          .loadStadiumSlots(widget.stadium.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StadiumProvider>(
      builder: (context, provider, child) {
        if (provider.isLoadingSlots) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: CircularProgressIndicator(
                color: Color(0xFF7CC000),
              ),
            ),
          );
        }

        if (provider.errorMessage != null) {
          return Column(
            children: [
              Text(
                provider.errorMessage!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  provider.loadStadiumSlots(
                    widget.stadium.id,
                  );
                },
                child: const Text('Try Again'),
              ),
            ],
          );
        }

        final slots = provider.slots;

        if (slots.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'No available slots at the moment.',
              textAlign: TextAlign.center,
            ),
          );
        }

        final dates = <DateTime>[];

        for (final slot in slots) {
          if (slot.slotDate == null) continue;

          final date = DateTime(
            slot.slotDate!.year,
            slot.slotDate!.month,
            slot.slotDate!.day,
          );

          if (!dates.any(
                (item) => _sameDate(item, date),
          )) {
            dates.add(date);
          }
        }

        dates.sort();

        if (_selectedDate == null && dates.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;

            setState(() {
              _selectedDate ??= dates.first;
            });
          });
        }

        final filteredSlots = _selectedDate == null
            ? slots
            : slots.where((slot) {
          if (slot.slotDate == null) {
            return false;
          }

          return _sameDate(
            slot.slotDate!,
            _selectedDate!,
          );
        }).toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available dates',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 72,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: dates.length,
                separatorBuilder: (_, __) =>
                const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final date = dates[index];

                  final selected =
                      _selectedDate != null &&
                          _sameDate(
                            date,
                            _selectedDate!,
                          );

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDate = date;
                      });
                    },
                    child: AnimatedContainer(
                      duration:
                      const Duration(milliseconds: 180),
                      width: 68,
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color(0xFF7CC000)
                            : Theme.of(context)
                            .cardColor,
                        borderRadius:
                        BorderRadius.circular(16),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFF7CC000)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Text(
                            _weekday(date.weekday),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.black
                                  : Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${date.day}/${date.month}',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: selected
                                  ? Colors.black
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 22),

            Row(
              children: [
                const Text(
                  'Available slots',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                Text(
                  '${filteredSlots.length} slots',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            ...filteredSlots
                .map(
                  (slot) => _SlotCard(
                startTime: slot.startTime,
                endTime: slot.endTime,
                price: slot.price,
                onTap: slot.isAvailable
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StadiumBookingScreen(
                        stadiumId: widget.stadium.id,
                        stadiumName: widget.stadium.name,
                        slotId: slot.id,
                        date: slot.slotDate,
                        startTime: slot.startTime,
                        endTime: slot.endTime,
                        price: slot.price,
                        deposit: widget.stadium.depositAmount,
                      ),
                    ),
                  );
                }
                    : null,
              ),
            )
                .toList(),
          ],
        );
      },
    );
  }

  bool _sameDate(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  String _weekday(int weekday) {
    const names = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return names[weekday - 1];
  }
}

class _SlotCard extends StatelessWidget {
  final String startTime;
  final String endTime;
  final double price;
  final VoidCallback? onTap;

  const _SlotCard({
    required this.startTime,
    required this.endTime,
    required this.price,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final available = onTap != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: available
              ? const Color(0xFF7CC000).withValues(alpha: 0.35)
              : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 5,
        ),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: available
                ? const Color(0xFF7CC000)
                .withValues(alpha: 0.10)
                : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.access_time,
            color: available
                ? const Color(0xFF7CC000)
                : Colors.grey,
          ),
        ),
        title: Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            '${_formatTime(startTime)} - ${_formatTime(endTime)}',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        subtitle: Text(
          available ? 'Available' : 'Unavailable',
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${price.toStringAsFixed(0)} EGP',
              style: const TextStyle(
                color: Color(0xFF7CC000),
                fontWeight: FontWeight.w900,
              ),
            ),
            if (available)
              const Text(
                'Select',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

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
    final displayHour = hour % 12 == 0 ? 12 : hour % 12;

    return '$displayHour:$minute $suffix';
  }
}