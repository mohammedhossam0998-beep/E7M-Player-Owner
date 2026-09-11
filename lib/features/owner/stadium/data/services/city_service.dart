import 'package:e7m/core/network/api_client.dart';

import '../models/city_model.dart';

class CityService {
  final ApiClient _apiClient;

  CityService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET CITIES
  // ============================================================

  Future<List<CityModel>> getCities() async {
    final response = await _apiClient.get(
      '/cities',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid cities response',
      );
    }

    final cities = response['cities'];

    if (cities is! List) {
      return [];
    }

    return cities
        .whereType<Map<String, dynamic>>()
        .map(CityModel.fromJson)
        .toList();
  }

  // ============================================================
  // GET CITY BY ID
  // ============================================================

  Future<CityModel> getCityById(
      int cityId,
      ) async {
    final response = await _apiClient.get(
      '/cities/$cityId',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception(
        'Invalid city response',
      );
    }

    final city = response['city'];

    if (city is! Map<String, dynamic>) {
      throw Exception(
        'City data not found',
      );
    }

    return CityModel.fromJson(city);
  }
}