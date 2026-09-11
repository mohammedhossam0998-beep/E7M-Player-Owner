import '../models/academy_model.dart';
import '../services/academy_service.dart';

class AcademyRepositoryImpl {
  final AcademyService service;

  AcademyRepositoryImpl({
    required this.service,
  });

  // ============================================================
  // GET OWNER ACADEMIES
  // ============================================================

  Future<List<AcademyModel>> getOwnerAcademies() async {
    return service.getOwnerAcademies();
  }

  // ============================================================
  // GET OWNER ACADEMY BY ID
  // ============================================================

  Future<AcademyModel> getOwnerAcademyById(
      String academyId,
      ) async {
    return service.getOwnerAcademyById(
      academyId,
    );
  }

  // ============================================================
  // CREATE ACADEMY
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
    return service.createAcademy(
      name: name,
      phoneNumber: phoneNumber,
      description: description,
      address: address,
      cityId: cityId,
      imageUrl: imageUrl,
      pitchId: pitchId,
    );
  }

  // ============================================================
  // UPDATE ACADEMY
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
    return service.updateAcademy(
      academyId: academyId,
      name: name,
      phoneNumber: phoneNumber,
      description: description,
      address: address,
      cityId: cityId,
      imageUrl: imageUrl,
      pitchId: pitchId,
    );
  }
}