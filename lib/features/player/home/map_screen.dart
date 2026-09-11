
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:e7m/core/network/api_client.dart';
import 'package:e7m/features/player/stadium/data/models/stadium.dart';
import 'package:e7m/features/player/stadium/presentation/providers/stadium_provider.dart';
import 'package:e7m/features/player/stadium/presentation/screens/stadium_details_screen.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const Color primaryGreen = Color(0xff7CC000);
  static const Color darkNavy = Color(0xff1E1446);
  static const Color background = Color(0xffF7F7F3);

  static const LatLng cairo = LatLng(30.0444, 31.2357);

  final MapController mapController = MapController();
  final TextEditingController searchController = TextEditingController();

  String _searchQuery = '';
  List<Stadium> _filteredStadiums = [];
  List<String> favoriteStadiumIds = [];
  int selectedIndex = -1;
  bool _isFollowingUser = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final provider = context.read<StadiumProvider>();

      if (!provider.hasStadiums && !provider.isLoading) {
        provider.loadStadiums();
      }

      _syncFilteredStadiums(provider.stadiums);
      _loadFavorites();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      favoriteStadiumIds =
          prefs.getStringList('favorite_stadiums') ?? <String>[];
    });
  }

  Future<void> _toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    final updated = List<String>.from(favoriteStadiumIds);

    if (updated.contains(id)) {
      updated.remove(id);
    } else {
      updated.add(id);
    }

    setState(() {
      favoriteStadiumIds = updated;
    });

    await prefs.setStringList('favorite_stadiums', updated);
  }

  void _syncFilteredStadiums(List<Stadium> stadiums) {
    final query = _searchQuery.trim().toLowerCase();

    final result = stadiums.where((stadium) {
      if (!_hasCoordinates(stadium)) return false;

      if (query.isEmpty) return true;

      return stadium.name.toLowerCase().contains(query) ||
          (stadium.cityName?.toLowerCase().contains(query) ?? false) ||
          (stadium.address?.toLowerCase().contains(query) ?? false) ||
          (stadium.pitchType?.toLowerCase().contains(query) ?? false);
    }).toList();

    final selectedId = selectedIndex >= 0 &&
        selectedIndex < _filteredStadiums.length
        ? _filteredStadiums[selectedIndex].id
        : null;

    setState(() {
      _filteredStadiums = result;

      if (selectedId != null) {
        final newIndex =
        result.indexWhere((stadium) => stadium.id == selectedId);
        selectedIndex = newIndex;
      } else {
        selectedIndex = result.isNotEmpty ? 0 : -1;
      }
    });
  }

  bool _hasCoordinates(Stadium stadium) {
    return stadium.latitude != null &&
        stadium.longitude != null &&
        stadium.latitude! >= -90 &&
        stadium.latitude! <= 90 &&
        stadium.longitude! >= -180 &&
        stadium.longitude! <= 180;
  }

  void _filterStadiums(String value) {
    _searchQuery = value;
    _syncFilteredStadiums(context.read<StadiumProvider>().stadiums);

    if (_filteredStadiums.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        final stadium = _filteredStadiums.first;
        mapController.move(_positionOf(stadium), 12);
      });
    }
  }

  LatLng _positionOf(Stadium stadium) {
    return LatLng(stadium.latitude!, stadium.longitude!);
  }

  void _selectStadium(int index, {bool moveMap = true}) {
    if (index < 0 || index >= _filteredStadiums.length) return;

    setState(() {
      selectedIndex = index;
    });

    if (moveMap) {
      mapController.move(_positionOf(_filteredStadiums[index]), 14);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showMessage(
          'Location services are disabled. Please enable them.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          _showMessage('Location permissions are denied.');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage(
          'Location permission is permanently denied. Please enable it from Settings.',
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        _isFollowingUser = true;
      });

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _isFollowingUser = false;
      });

      mapController.move(
        LatLng(position.latitude, position.longitude),
        14,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isFollowingUser = false;
      });

      _showMessage('Unable to get your current location.');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  String _imageUrl(String image) {
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }

    final serverUrl = ApiClient.baseUrl.replaceFirst('/api', '');

    if (image.startsWith('/')) {
      return '$serverUrl$image';
    }

    return '$serverUrl/$image';
  }

  bool _isAvailable(Stadium stadium) {
    final status = stadium.status.trim().toLowerCase();

    return status == 'approved' ||
        status == 'active' ||
        status == 'available';
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final t = languageProvider.translate;

    return Scaffold(
      backgroundColor: background,
      body: Consumer<StadiumProvider>(
        builder: (context, provider, child) {
          final stadiums = provider.stadiums;

          final providerStadiumIds =
          stadiums.where(_hasCoordinates).map((e) => e.id).toSet();

          final visibleStadiums = _filteredStadiums
              .where((stadium) => providerStadiumIds.contains(stadium.id))
              .toList();

          if (_filteredStadiums.length != visibleStadiums.length) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              _syncFilteredStadiums(stadiums);
            });
          }

          final hasSelection =
              selectedIndex >= 0 && selectedIndex < visibleStadiums.length;

          final currentStadium =
          hasSelection ? visibleStadiums[selectedIndex] : null;

          return Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: _initialMapCenter(visibleStadiums),
                  initialZoom: visibleStadiums.isNotEmpty ? 11 : 10,
                  onTap: (_, __) {
                    if (!mounted) return;
                    setState(() {
                      selectedIndex = -1;
                    });
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.e7gzly',
                  ),
                  MarkerLayer(
                    markers: [
                      for (var index = 0;
                      index < visibleStadiums.length;
                      index++)
                        _buildMarker(
                          visibleStadiums[index],
                          index,
                        ),
                    ],
                  ),
                ],
              ),

              Positioned(
                top: MediaQuery.of(context).padding.top + 12,
                left: 16,
                right: 16,
                child: _SearchBar(
                  controller: searchController,
                  hintText: t('search_stadium_city'),
                  onChanged: _filterStadiums,
                  onClear: () {
                    searchController.clear();
                    _filterStadiums('');
                  },
                ),
              ),

              Positioned(
                top: MediaQuery.of(context).padding.top + 78,
                left: 16,
                child: _MapStatusChip(
                  icon: Icons.stadium_outlined,
                  text: visibleStadiums.isEmpty
                      ? '0'
                      : visibleStadiums.length.toString(),
                ),
              ),

              Positioned(
                right: 16,
                bottom: currentStadium != null ? 350 : 30,
                child: Column(
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'map_zoom_in',
                      backgroundColor: Colors.white,
                      foregroundColor: darkNavy,
                      elevation: 3,
                      onPressed: () {
                        mapController.move(
                          mapController.camera.center,
                          mapController.camera.zoom + 1,
                        );
                      },
                      child: const Icon(Icons.add),
                    ),
                    const SizedBox(height: 10),
                    FloatingActionButton.small(
                      heroTag: 'map_zoom_out',
                      backgroundColor: Colors.white,
                      foregroundColor: darkNavy,
                      elevation: 3,
                      onPressed: () {
                        mapController.move(
                          mapController.camera.center,
                          mapController.camera.zoom - 1,
                        );
                      },
                      child: const Icon(Icons.remove),
                    ),
                  ],
                ),
              ),

              Positioned(
                right: 16,
                bottom: currentStadium != null ? 285 : 30,
                child: GestureDetector(
                  onTap: _isFollowingUser ? null : _getCurrentLocation,
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: _isFollowingUser
                        ? const Padding(
                      padding: EdgeInsets.all(17),
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: primaryGreen,
                      ),
                    )
                        : const Icon(
                      Icons.my_location,
                      color: primaryGreen,
                      size: 26,
                    ),
                  ),
                ),
              ),

              if (provider.isLoading && !provider.hasStadiums)
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    minHeight: 3,
                    color: primaryGreen,
                    backgroundColor: Colors.transparent,
                  ),
                ),

              if (provider.errorMessage != null &&
                  !provider.hasStadiums &&
                  !provider.isLoading)
                Positioned.fill(
                  child: _MapErrorState(
                    message: provider.errorMessage!,
                    onRetry: provider.loadStadiums,
                  ),
                ),

              if (!provider.isLoading &&
                  provider.hasStadiums &&
                  visibleStadiums.isEmpty)
                Positioned(
                  left: 24,
                  right: 24,
                  bottom: 30,
                  child: _NoStadiumsCard(
                    hasSearch: _searchQuery.trim().isNotEmpty,
                    onClear: _searchQuery.trim().isNotEmpty
                        ? () {
                      searchController.clear();
                      _filterStadiums('');
                    }
                        : null,
                  ),
                ),

              if (currentStadium != null)
                Positioned(
                  bottom: 30,
                  left: 16,
                  right: 16,
                  child: _StadiumDetailsCard(
                    stadium: currentStadium,
                    imageUrl: currentStadium.primaryImage == null ||
                        currentStadium.primaryImage!.trim().isEmpty
                        ? null
                        : _imageUrl(currentStadium.primaryImage!),
                    isAvailable: _isAvailable(currentStadium),
                    isFavorite:
                    favoriteStadiumIds.contains(currentStadium.id),
                    onFavorite: () =>
                        _toggleFavorite(currentStadium.id),
                    onViewDetails: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => StadiumDetailsScreen(
                            stadiumId: currentStadium.id,
                          ),
                        ),
                      );
                    },
                    translate: t,
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  LatLng _initialMapCenter(List<Stadium> stadiums) {
    if (stadiums.isEmpty) return cairo;

    final first = stadiums.first;
    return _positionOf(first);
  }

  Marker _buildMarker(Stadium stadium, int index) {
    final isSelected = index == selectedIndex;

    return Marker(
      point: _positionOf(stadium),
      width: isSelected ? 60 : 45,
      height: isSelected ? 60 : 45,
      child: GestureDetector(
        onTap: () => _selectStadium(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? primaryGreen : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : darkNavy,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.20),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            Icons.sports_soccer,
            size: isSelected ? 28 : 22,
            color: isSelected ? Colors.white : darkNavy,
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(16),
      color: Colors.white,
      child: SizedBox(
        height: 55,
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 15),
              child: Icon(Icons.search, color: Colors.grey),
            ),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: hintText,
                  hintStyle: const TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            if (controller.text.isNotEmpty)
              IconButton(
                onPressed: onClear,
                icon: const Icon(
                  Icons.clear,
                  color: Colors.grey,
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.filter_alt_outlined,
                  color: Color(0xff7CC000),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MapStatusChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MapStatusChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.stadium_outlined,
              size: 17,
              color: Color(0xff7CC000),
            ),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: Color(0xff1E1446),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StadiumDetailsCard extends StatelessWidget {
  final Stadium stadium;
  final String? imageUrl;
  final bool isAvailable;
  final bool isFavorite;
  final VoidCallback onFavorite;
  final VoidCallback onViewDetails;
  final String Function(String) translate;

  const _StadiumDetailsCard({
    required this.stadium,
    required this.imageUrl,
    required this.isAvailable,
    required this.isFavorite,
    required this.onFavorite,
    required this.onViewDetails,
    required this.translate,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 7,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                _StadiumImage(
                  imageUrl: imageUrl,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              stadium.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xff1E1446),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? const Color(0xff7CC000)
                                  .withOpacity(0.15)
                                  : Colors.red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isAvailable
                                  ? translate('available')
                                  : translate('full'),
                              style: TextStyle(
                                color: isAvailable
                                    ? const Color(0xff7CC000)
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      if (stadium.cityName != null ||
                          stadium.address != null)
                        Text(
                          stadium.cityName ?? stadium.address ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                        ),
                      const SizedBox(height: 7),
                      Row(
                        children: [
                          if (stadium.pitchType != null)
                            _SmallTag(
                              icon: Icons.sports_soccer,
                              text: stadium.pitchType!,
                            ),
                          if (stadium.capacity != null) ...[
                            const SizedBox(width: 6),
                            _SmallTag(
                              icon: Icons.people_outline,
                              text: '${stadium.capacity}',
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '${stadium.basePrice.toStringAsFixed(0)} EGP',
                        style: const TextStyle(
                          color: Color(0xff7CC000),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: onViewDetails,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff1E1446),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        translate('view_details'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: onFavorite,
                  tooltip: isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color: Colors.red,
                    size: 28,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StadiumImage extends StatelessWidget {
  final String? imageUrl;

  const _StadiumImage({
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 100,
        height: 80,
        child: imageUrl == null
            ? _placeholder()
            : Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;

            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xff7CC000),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.stadium_outlined,
        size: 38,
        color: Colors.grey.shade400,
      ),
    );
  }
}

class _SmallTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SmallTag({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: const Color(0xff7CC000).withOpacity(0.09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.circle,
            size: 4,
            color: Color(0xff7CC000),
          ),
          const SizedBox(width: 5),
          Icon(
            icon,
            size: 13,
            color: const Color(0xff7CC000),
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NoStadiumsCard extends StatelessWidget {
  final bool hasSearch;
  final VoidCallback? onClear;

  const _NoStadiumsCard({
    required this.hasSearch,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              hasSearch
                  ? Icons.search_off_rounded
                  : Icons.stadium_outlined,
              size: 45,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 10),
            Text(
              hasSearch
                  ? 'No stadiums found'
                  : 'No stadiums with location data',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xff1E1446),
              ),
            ),
            if (hasSearch && onClear != null) ...[
              const SizedBox(height: 10),
              TextButton(
                onPressed: onClear,
                child: const Text(
                  'Clear search',
                  style: TextStyle(
                    color: Color(0xff7CC000),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MapErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _MapErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Material(
          color: Colors.white,
          elevation: 5,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.cloud_off_rounded,
                  size: 55,
                  color: Colors.grey,
                ),
                const SizedBox(height: 14),
                const Text(
                  'Unable to load stadiums',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xff1E1446),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff7CC000),
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}