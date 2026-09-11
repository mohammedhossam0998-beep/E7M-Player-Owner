import '../models/competition_model.dart';
import '../models/competition_prize_model.dart';
import '../models/competition_registration_model.dart';
import '../models/competition_invitation_model.dart';
import '../models/competition_payment_model.dart';
import '../models/competition_seeding_model.dart';
import '../models/competition_match_model.dart';
import '../models/competition_standing_model.dart';
import '../models/competition_bracket_model.dart';
import '../services/competition_service.dart';

class CompetitionRepository {
  final CompetitionService _service;

  CompetitionRepository(this._service);

  // ============================================================
  // COMPETITIONS
  // ============================================================

  Future<CompetitionModel> createCompetition(
      Map<String, dynamic> data,
      ) async {
    final response = await _service.createCompetition(data);

    return CompetitionModel.fromJson(
      response['competition'] as Map<String, dynamic>,
    );
  }

  Future<List<CompetitionModel>> getOwnerCompetitions() async {
    final response = await _service.getOwnerCompetitions();

    final data = response['competitions'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) => CompetitionModel.fromJson(
        item as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  Future<CompetitionModel> getCompetitionById(
      int competitionId,
      ) async {
    final response = await _service.getCompetitionById(
      competitionId,
    );

    return CompetitionModel.fromJson(
      response['competition'] as Map<String, dynamic>,
    );
  }

  Future<CompetitionModel> updateCompetition(
      int competitionId,
      Map<String, dynamic> data,
      ) async {
    final response = await _service.updateCompetition(
      competitionId,
      data,
    );

    return CompetitionModel.fromJson(
      response['competition'] as Map<String, dynamic>,
    );
  }

  Future<CompetitionModel> updateCompetitionStatus(
      int competitionId,
      String status,
      ) async {
    final response =
    await _service.updateCompetitionStatus(
      competitionId,
      status,
    );

    return CompetitionModel.fromJson(
      response['competition'] as Map<String, dynamic>,
    );
  }

  Future<void> deleteCompetition(
      int competitionId,
      ) async {
    await _service.deleteCompetition(
      competitionId,
    );
  }

  // ============================================================
  // PRIZES
  // ============================================================

  Future<CompetitionPrizeModel> createPrize(
      int competitionId,
      Map<String, dynamic> data,
      ) async {
    final response = await _service.createPrize(
      competitionId,
      data,
    );

    return CompetitionPrizeModel.fromJson(
      response['prize'] as Map<String, dynamic>,
    );
  }

  Future<List<CompetitionPrizeModel>> getCompetitionPrizes(
      int competitionId,
      ) async {
    final response =
    await _service.getCompetitionPrizes(
      competitionId,
    );

    final data = response['prizes'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) => CompetitionPrizeModel.fromJson(
        item as Map<String, dynamic>,
      ),
    )
        .toList();
  }

  Future<CompetitionPrizeModel> getPrizeById(
      int competitionId,
      int prizeId,
      ) async {
    final response = await _service.getPrizeById(
      competitionId,
      prizeId,
    );

    return CompetitionPrizeModel.fromJson(
      response['prize'] as Map<String, dynamic>,
    );
  }

  Future<CompetitionPrizeModel> updatePrize(
      int competitionId,
      int prizeId,
      Map<String, dynamic> data,
      ) async {
    final response = await _service.updatePrize(
      competitionId,
      prizeId,
      data,
    );

    return CompetitionPrizeModel.fromJson(
      response['prize'] as Map<String, dynamic>,
    );
  }

  Future<void> deletePrize(
      int competitionId,
      int prizeId,
      ) async {
    await _service.deletePrize(
      competitionId,
      prizeId,
    );
  }

  // ============================================================
  // REGISTRATIONS
  // ============================================================

  Future<List<CompetitionRegistrationModel>>
  getCompetitionRegistrations(
      int competitionId,
      ) async {
    final response =
    await _service.getCompetitionRegistrations(
      competitionId,
    );

    final data = response['registrations'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) =>
          CompetitionRegistrationModel.fromJson(
            item as Map<String, dynamic>,
          ),
    )
        .toList();
  }

  Future<CompetitionRegistrationModel>
  approveRegistration(
      int competitionId,
      int registrationId,
      ) async {
    final response =
    await _service.approveRegistration(
      competitionId,
      registrationId,
    );

    return CompetitionRegistrationModel.fromJson(
      response['registration']
      as Map<String, dynamic>,
    );
  }

  Future<CompetitionRegistrationModel>
  rejectRegistration(
      int competitionId,
      int registrationId,
      ) async {
    final response =
    await _service.rejectRegistration(
      competitionId,
      registrationId,
    );

    return CompetitionRegistrationModel.fromJson(
      response['registration']
      as Map<String, dynamic>,
    );
  }

  Future<CompetitionRegistrationModel>
  moveRegistrationToWaitlist(
      int competitionId,
      int registrationId,
      ) async {
    final response =
    await _service.moveRegistrationToWaitlist(
      competitionId,
      registrationId,
    );

    return CompetitionRegistrationModel.fromJson(
      response['registration']
      as Map<String, dynamic>,
    );
  }

  // ============================================================
  // INVITATIONS
  // ============================================================

  Future<CompetitionInvitationModel>
  sendInvitation(
      int competitionId,
      Map<String, dynamic> data,
      ) async {
    final response =
    await _service.sendInvitation(
      competitionId,
      data,
    );

    return CompetitionInvitationModel.fromJson(
      response['invitation']
      as Map<String, dynamic>,
    );
  }

  Future<List<CompetitionInvitationModel>>
  getCompetitionInvitations(
      int competitionId,
      ) async {
    final response =
    await _service.getCompetitionInvitations(
      competitionId,
    );

    final data = response['invitations'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) =>
          CompetitionInvitationModel.fromJson(
            item as Map<String, dynamic>,
          ),
    )
        .toList();
  }

  // ============================================================
  // COMPETITION PAYMENTS
  // ============================================================

  Future<List<CompetitionPaymentModel>>
  getCompetitionPayments() async {
    final response =
    await _service.getCompetitionPayments();

    final data = response['payments'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) =>
          CompetitionPaymentModel.fromJson(
            item as Map<String, dynamic>,
          ),
    )
        .toList();
  }

  Future<CompetitionPaymentModel>
  approveCompetitionPayment(
      int paymentId,
      ) async {
    final response =
    await _service.approveCompetitionPayment(
      paymentId,
    );

    return CompetitionPaymentModel.fromJson(
      response['payment'] as Map<String, dynamic>,
    );
  }

  Future<CompetitionPaymentModel>
  rejectCompetitionPayment(
      int paymentId, {
        String? rejectionReason,
      }) async {
    final response =
    await _service.rejectCompetitionPayment(
      paymentId,
      rejectionReason: rejectionReason,
    );

    return CompetitionPaymentModel.fromJson(
      response['payment'] as Map<String, dynamic>,
    );
  }

  // ============================================================
  // COMPETITION SEEDING
  // ============================================================

  Future<List<CompetitionSeedingModel>>
  generateSeeding(
      int competitionId,
      ) async {
    final response =
    await _service.generateSeeding(
      competitionId,
    );

    final data = response['seeding'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) =>
          CompetitionSeedingModel.fromJson(
            item as Map<String, dynamic>,
          ),
    )
        .toList();
  }

  Future<List<CompetitionSeedingModel>>
  getCompetitionSeeding(
      int competitionId,
      ) async {
    final response =
    await _service.getCompetitionSeeding(
      competitionId,
    );

    final data = response['seeding'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) =>
          CompetitionSeedingModel.fromJson(
            item as Map<String, dynamic>,
          ),
    )
        .toList();
  }

  Future<List<CompetitionSeedingModel>>
  updateManualSeeding(
      int competitionId,
      List<Map<String, dynamic>> seeding,
      ) async {
    final response =
    await _service.updateManualSeeding(
      competitionId,
      seeding,
    );

    final data = response['seeding'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) =>
          CompetitionSeedingModel.fromJson(
            item as Map<String, dynamic>,
          ),
    )
        .toList();
  }

  Future<List<CompetitionSeedingModel>>
  confirmSeeding(
      int competitionId,
      ) async {
    final response =
    await _service.confirmSeeding(
      competitionId,
    );

    final data = response['seeding'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) =>
          CompetitionSeedingModel.fromJson(
            item as Map<String, dynamic>,
          ),
    )
        .toList();
  }

  // ============================================================
  // GENERATE TOURNAMENT
  // ============================================================

  Future<List<CompetitionMatchModel>>
  generateTournament(
      int competitionId,
      ) async {
    final response =
    await _service.generateTournament(
      competitionId,
    );

    final data = response['matches'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) =>
          CompetitionMatchModel.fromJson(
            item as Map<String, dynamic>,
          ),
    )
        .toList();
  }

  // ============================================================
  // MATCHES
  // ============================================================

  Future<List<CompetitionMatchModel>>
  getCompetitionMatches(
      int competitionId,
      ) async {
    final response =
    await _service.getCompetitionMatches(
      competitionId,
    );

    final data = response['matches'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) =>
          CompetitionMatchModel.fromJson(
            item as Map<String, dynamic>,
          ),
    )
        .toList();
  }

  Future<CompetitionMatchModel>
  getCompetitionMatchById(
      int competitionId,
      int matchId,
      ) async {
    final response =
    await _service.getCompetitionMatchById(
      competitionId,
      matchId,
    );

    return CompetitionMatchModel.fromJson(
      response['match'] as Map<String, dynamic>,
    );
  }

  Future<CompetitionMatchModel>
  updateCompetitionMatch(
      int competitionId,
      int matchId,
      Map<String, dynamic> data,
      ) async {
    final response =
    await _service.updateCompetitionMatch(
      competitionId,
      matchId,
      data,
    );

    return CompetitionMatchModel.fromJson(
      response['match'] as Map<String, dynamic>,
    );
  }

  Future<CompetitionMatchModel>
  cancelCompetitionMatch(
      int competitionId,
      int matchId,
      ) async {
    final response =
    await _service.cancelCompetitionMatch(
      competitionId,
      matchId,
    );

    return CompetitionMatchModel.fromJson(
      response['match'] as Map<String, dynamic>,
    );
  }

  // ============================================================
  // MATCH RESULTS
  // ============================================================

  Future<CompetitionMatchModel>
  submitCompetitionMatchResult(
      int competitionId,
      int matchId,
      Map<String, dynamic> data,
      ) async {
    final response =
    await _service.submitCompetitionMatchResult(
      competitionId,
      matchId,
      data,
    );

    return CompetitionMatchModel.fromJson(
      response['match'] as Map<String, dynamic>,
    );
  }

  // ============================================================
  // STANDINGS
  // ============================================================

  Future<List<CompetitionStandingModel>>
  getCompetitionStandings(
      int competitionId,
      ) async {
    final response =
    await _service.getCompetitionStandings(
      competitionId,
    );

    final data = response['standings'];

    if (data is! List) {
      return [];
    }

    return data
        .map(
          (item) =>
          CompetitionStandingModel.fromJson(
            item as Map<String, dynamic>,
          ),
    )
        .toList();
  }

  // ============================================================
  // BRACKET
  // ============================================================

  Future<CompetitionBracketModel>
  getCompetitionBracket(
      int competitionId,
      ) async {
    final response =
    await _service.getCompetitionBracket(
      competitionId,
    );

    return CompetitionBracketModel.fromJson(
      response,
    );
  }
}