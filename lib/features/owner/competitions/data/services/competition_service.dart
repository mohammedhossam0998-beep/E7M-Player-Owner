import '../../../../../core/network/api_client.dart';

class CompetitionService {
  final ApiClient _apiClient;

  CompetitionService(this._apiClient);

  // ============================================================
  // COMPETITIONS
  // ============================================================

  Future<Map<String, dynamic>> createCompetition(
      Map<String, dynamic> data,
      ) async {
    return await _apiClient.post(
      '/owner/competitions',
      data,
    );
  }

  Future<Map<String, dynamic>> getOwnerCompetitions() async {
    return await _apiClient.get(
      '/owner/competitions',
    );
  }

  Future<Map<String, dynamic>> getCompetitionById(
      int competitionId,
      ) async {
    return await _apiClient.get(
      '/owner/competitions/$competitionId',
    );
  }

  Future<Map<String, dynamic>> updateCompetition(
      int competitionId,
      Map<String, dynamic> data,
      ) async {
    return await _apiClient.put(
      '/owner/competitions/$competitionId',
      data,
    );
  }

  Future<Map<String, dynamic>> updateCompetitionStatus(
      int competitionId,
      String status,
      ) async {
    return await _apiClient.patch(
      '/owner/competitions/$competitionId/status',
      {
        'status': status,
      },
    );
  }

  Future<Map<String, dynamic>> deleteCompetition(
      int competitionId,
      ) async {
    return await _apiClient.delete(
      '/owner/competitions/$competitionId',
    );
  }

  // ============================================================
  // PRIZES
  // ============================================================

  Future<Map<String, dynamic>> createPrize(
      int competitionId,
      Map<String, dynamic> data,
      ) async {
    return await _apiClient.post(
      '/owner/competitions/$competitionId/prizes',
      data,
    );
  }

  Future<Map<String, dynamic>> getCompetitionPrizes(
      int competitionId,
      ) async {
    return await _apiClient.get(
      '/owner/competitions/$competitionId/prizes',
    );
  }

  Future<Map<String, dynamic>> getPrizeById(
      int competitionId,
      int prizeId,
      ) async {
    return await _apiClient.get(
      '/owner/competitions/$competitionId/prizes/$prizeId',
    );
  }

  Future<Map<String, dynamic>> updatePrize(
      int competitionId,
      int prizeId,
      Map<String, dynamic> data,
      ) async {
    return await _apiClient.put(
      '/owner/competitions/$competitionId/prizes/$prizeId',
      data,
    );
  }

  Future<Map<String, dynamic>> deletePrize(
      int competitionId,
      int prizeId,
      ) async {
    return await _apiClient.delete(
      '/owner/competitions/$competitionId/prizes/$prizeId',
    );
  }

  // ============================================================
  // REGISTRATIONS
  // ============================================================

  Future<Map<String, dynamic>> getCompetitionRegistrations(
      int competitionId,
      ) async {
    return await _apiClient.get(
      '/owner/competitions/$competitionId/registrations',
    );
  }

  Future<Map<String, dynamic>> approveRegistration(
      int competitionId,
      int registrationId,
      ) async {
    return await _apiClient.patch(
      '/owner/competitions/$competitionId/registrations/$registrationId/approve',
      {},
    );
  }

  Future<Map<String, dynamic>> rejectRegistration(
      int competitionId,
      int registrationId,
      ) async {
    return await _apiClient.patch(
      '/owner/competitions/$competitionId/registrations/$registrationId/reject',
      {},
    );
  }

  Future<Map<String, dynamic>> moveRegistrationToWaitlist(
      int competitionId,
      int registrationId,
      ) async {
    return await _apiClient.patch(
      '/owner/competitions/$competitionId/registrations/$registrationId/waitlist',
      {},
    );
  }

  // ============================================================
  // INVITATIONS
  // ============================================================

  Future<Map<String, dynamic>> sendInvitation(
      int competitionId,
      Map<String, dynamic> data,
      ) async {
    return await _apiClient.post(
      '/owner/competitions/$competitionId/invitations',
      data,
    );
  }

  Future<Map<String, dynamic>> getCompetitionInvitations(
      int competitionId,
      ) async {
    return await _apiClient.get(
      '/owner/competitions/$competitionId/invitations',
    );
  }

  // ============================================================
  // COMPETITION PAYMENTS
  // ============================================================

  Future<Map<String, dynamic>> getCompetitionPayments() async {
    return await _apiClient.get(
      '/owner/competition-payments',
    );
  }

  Future<Map<String, dynamic>> approveCompetitionPayment(
      int paymentId,
      ) async {
    return await _apiClient.patch(
      '/owner/competition-payments/$paymentId/approve',
      {},
    );
  }

  Future<Map<String, dynamic>> rejectCompetitionPayment(
      int paymentId, {
        String? rejectionReason,
      }) async {
    return await _apiClient.patch(
      '/owner/competition-payments/$paymentId/reject',
      {
        if (rejectionReason != null &&
            rejectionReason.trim().isNotEmpty)
          'rejection_reason': rejectionReason.trim(),
      },
    );
  }

  // ============================================================
  // COMPETITION SEEDING
  // ============================================================

  Future<Map<String, dynamic>> generateSeeding(
      int competitionId,
      ) async {
    return await _apiClient.post(
      '/owner/competitions/$competitionId/seeding/generate',
      {},
    );
  }

  Future<Map<String, dynamic>> getCompetitionSeeding(
      int competitionId,
      ) async {
    return await _apiClient.get(
      '/owner/competitions/$competitionId/seeding',
    );
  }

  Future<Map<String, dynamic>> updateManualSeeding(
      int competitionId,
      List<Map<String, dynamic>> seeding,
      ) async {
    return await _apiClient.put(
      '/owner/competitions/$competitionId/seeding/manual',
      {
        'seeding': seeding,
      },
    );
  }

  Future<Map<String, dynamic>> confirmSeeding(
      int competitionId,
      ) async {
    return await _apiClient.post(
      '/owner/competitions/$competitionId/seeding/confirm',
      {},
    );
  }

  // ============================================================
  // GENERATE TOURNAMENT
  // ============================================================

  Future<Map<String, dynamic>> generateTournament(
      int competitionId,
      ) async {
    return await _apiClient.post(
      '/owner/competitions/$competitionId/tournament/generate',
      {},
    );
  }

  // ============================================================
  // MATCHES
  // ============================================================

  Future<Map<String, dynamic>> getCompetitionMatches(
      int competitionId,
      ) async {
    return await _apiClient.get(
      '/owner/competitions/$competitionId/matches',
    );
  }

  Future<Map<String, dynamic>> getCompetitionMatchById(
      int competitionId,
      int matchId,
      ) async {
    return await _apiClient.get(
      '/owner/competitions/$competitionId/matches/$matchId',
    );
  }

  Future<Map<String, dynamic>> updateCompetitionMatch(
      int competitionId,
      int matchId,
      Map<String, dynamic> data,
      ) async {
    return await _apiClient.put(
      '/owner/competitions/$competitionId/matches/$matchId',
      data,
    );
  }

  Future<Map<String, dynamic>> cancelCompetitionMatch(
      int competitionId,
      int matchId,
      ) async {
    return await _apiClient.patch(
      '/owner/competitions/$competitionId/matches/$matchId/cancel',
      {},
    );
  }

  // ============================================================
  // MATCH RESULTS
  // ============================================================

  Future<Map<String, dynamic>> submitCompetitionMatchResult(
      int competitionId,
      int matchId,
      Map<String, dynamic> data,
      ) async {
    return await _apiClient.put(
      '/owner/competitions/$competitionId/matches/$matchId/result',
      data,
    );
  }

  // ============================================================
  // STANDINGS
  // ============================================================

  Future<Map<String, dynamic>> getCompetitionStandings(
      int competitionId,
      ) async {
    return await _apiClient.get(
      '/owner/competitions/$competitionId/standings',
    );
  }

  // ============================================================
  // BRACKET
  // ============================================================

  Future<Map<String, dynamic>> getCompetitionBracket(
      int competitionId,
      ) async {
    return await _apiClient.get(
      '/owner/competitions/$competitionId/bracket',
    );
  }
}