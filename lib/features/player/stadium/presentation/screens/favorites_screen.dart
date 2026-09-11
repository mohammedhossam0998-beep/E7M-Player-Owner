import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/features/player/stadium/data/models/stadium.dart';
import 'package:e7m/features/player/stadium/presentation/providers/stadium_provider.dart';
import 'package:e7m/features/player/stadium/presentation/widgets/favorites_service.dart';
import 'package:e7m/features/player/stadium/presentation/widgets/stadium_card.dart';
import 'stadium_details_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  static const Color primaryGreen = Color(0xFF7CC000);
  static const Color darkNavy = Color(0xFF1E1446);

  Set<String> _favoriteIds = {};
  bool _isLoadingFavorites = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    try {
      final ids = await FavoritesService.getFavoriteIds();

      if (!mounted) return;

      setState(() {
        _favoriteIds = ids;
        _isLoadingFavorites = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _favoriteIds = {};
        _isLoadingFavorites = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadFavorites();

    if (!mounted) return;

    await context.read<StadiumProvider>().loadStadiums();
  }

  @override
  Widget build(BuildContext context) {
    final stadiumProvider = context.watch<StadiumProvider>();

    final favoriteStadiums = stadiumProvider.stadiums
        .where((stadium) => _favoriteIds.contains(stadium.id))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F3),
        elevation: 0,
        foregroundColor: darkNavy,
        title: const Text(
          'Favourite Stadiums',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: RefreshIndicator(
        color: primaryGreen,
        onRefresh: _refresh,
        child: _buildBody(
          stadiumProvider: stadiumProvider,
          favoriteStadiums: favoriteStadiums,
        ),
      ),
    );
  }

  Widget _buildBody({
    required StadiumProvider stadiumProvider,
    required List<Stadium> favoriteStadiums,
  }) {
    if (_isLoadingFavorites || stadiumProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: primaryGreen),
      );
    }

    if (stadiumProvider.errorMessage != null &&
        !stadiumProvider.hasStadiums) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 60,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.cloud_off_rounded,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Unable to load stadiums',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: stadiumProvider.loadStadiums,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryGreen,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (favoriteStadiums.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 80,
            ),
            child: Column(
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 52,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 14),
                Text(
                  'No favourite stadiums yet',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Tap the heart icon on a stadium to add it here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: favoriteStadiums.length,
      itemBuilder: (context, index) {
        final stadium = favoriteStadiums[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: StadiumCard(
            stadium: stadium,
            isFavorite: true,
            onFavoritePressed: () async {
              try {
                final updatedIds =
                await FavoritesService.toggleFavorite(stadium.id);

                if (!mounted) return;

                setState(() {
                  _favoriteIds = updatedIds;
                });
              } catch (e) {
                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update favorite'),
                  ),
                );
              }
            },
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StadiumDetailsScreen(
                    stadiumId: stadium.id,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
