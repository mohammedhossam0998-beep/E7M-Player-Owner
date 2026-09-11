import '../../../../core/network/api_client.dart';
import '../models/academy_model.dart';

class AcademyService {
  final ApiClient _apiClient;

  AcademyService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET OWNER ACADEMIES
  // GET /api/owner/academies
  // ============================================================

  Future<List<AcademyModel>> getOwnerAcademies() async {
    final response = await _apiClient.get(
      '/owner/academies',
    );

    final data = response as Map<String, dynamic>;

    final academies = data['academies'];

    if (academies is! List) {
      return [];
    }

    return academies
        .map(
          (academy) => AcademyModel.fromJson(
        Map<String, dynamic>.from(academy as Map),
      ),
    )
        .toList();
  }

  // ============================================================
  // GET OWNER ACADEMY BY ID
  // GET /api/owner/academies/:id
  // ============================================================

  Future<AcademyModel> getOwnerAcademyById(
      String academyId,
      ) async {
    final response = await _apiClient.get(
      '/owner/academies/$academyId',
    );

    final data = response as Map<String, dynamic>;

    final academy = data['academy'];

    if (academy is! Map) {
      throw Exception(
        'Academy data not found in response',
      );
    }

    return AcademyModel.fromJson(
      Map<String, dynamic>.from(academy),
    );
  }

  // ============================================================
  // CREATE ACADEMY
  // POST /api/owner/academies
  // ============================================================

  Future<AcademyModel> createAcademy({
    required String name,
    required String phoneNumber,
    String? description,
    String? address,
    String? cityId,
    String? imageUrl,
    required String pitchId,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'phone_number': phoneNumber,
      'description': description,
      'address': address,
      'city_id': cityId,
      'image_url': imageUrl,
      'pitch_id': pitchId,
    };

    final response = await _apiClient.post(
      '/owner/academies',
      body,
    );

    final data = response as Map<String, dynamic>;

    final academy = data['academy'];

    if (academy is! Map) {
      throw Exception(
        'Academy data not found in response',
      );
    }

    return AcademyModel.fromJson(
      Map<String, dynamic>.from(academy),
    );
  }

  // ============================================================
  // UPDATE ACADEMY
  // PUT /api/owner/academies/:id
  // ============================================================

  Future<AcademyModel> updateAcademy({
    required String academyId,
    String? name,
    String? phoneNumber,
    String? description,
    String? address,
    String? cityId,
    String? imageUrl,
    String? pitchId,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'phone_number': phoneNumber,
      'description': description,
      'address': address,
      'city_id': cityId,
      'image_url': imageUrl,
      'pitch_id': pitchId,
    };

    final response = await _apiClient.put(
      '/owner/academies/$academyId',
      body,
    );

    final data = response as Map<String, dynamic>;

    final academy = data['academy'];

    if (academy is! Map) {
      throw Exception(
        'Academy data not found in response',
      );
    }

    return AcademyModel.fromJson(
      Map<String, dynamic>.from(academy),
    );
  }
}