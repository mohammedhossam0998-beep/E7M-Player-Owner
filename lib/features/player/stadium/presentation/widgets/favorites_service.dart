import 'package:e7m/core/network/api_client.dart';

class FavoritesService {
  static final ApiClient _apiClient = ApiClient();

  /// Get all favorite stadium IDs for the current player.
  static Future<Set<String>> getFavoriteIds() async {
    final response = await _apiClient.get('/player/favorites');

    if (response is! Map) {
      throw Exception('Invalid favorites response');
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to load favorites',
      );
    }

    final favorites = response['favorites'];

    if (favorites is! List) {
      return <String>{};
    }

    final ids = <String>{};

    for (final favorite in favorites) {
      if (favorite is! Map) continue;

      final pitchId = favorite['pitch_id'];

      if (pitchId != null) {
        ids.add(pitchId.toString());
      }
    }

    return ids;
  }

  /// Check whether a stadium is currently a favorite.
  static Future<bool> isFavorite(String stadiumId) async {
    if (stadiumId.trim().isEmpty) {
      return false;
    }

    final response = await _apiClient.get(
      '/player/favorites/$stadiumId/check',
    );

    if (response is! Map) {
      throw Exception('Invalid favorite check response');
    }

    if (response['success'] != true) {
      throw Exception(
        response['message']?.toString() ??
            'Failed to check favorite',
      );
    }

    return response['isFavorite'] == true;
  }

  /// Add/remove a stadium from favorites.
  ///
  /// Returns the updated set of favorite stadium IDs.
  static Future<Set<String>> toggleFavorite(
      String stadiumId,
      ) async {
    if (stadiumId.trim().isEmpty) {
      throw Exception('Invalid stadium ID');
    }

    final currentlyFavorite = await isFavorite(stadiumId);

    if (currentlyFavorite) {
      await _apiClient.delete(
        '/player/favorites/$stadiumId',
      );
    } else {
      await _apiClient.post(
        '/player/favorites/$stadiumId',
        {},
      );
    }

    return getFavoriteIds();
  }
}