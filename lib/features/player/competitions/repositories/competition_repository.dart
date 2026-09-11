import 'dart:io';

import 'package:e7m/features/player/competitions/data/competition_api.dart';
import 'package:e7m/features/player/competitions/models/competition_goal_model.dart';
import 'package:e7m/features/player/competitions/models/competition_invitation_model.dart';
import 'package:e7m/features/player/competitions/models/competition_match_model.dart';
import 'package:e7m/features/player/competitions/models/competition_model.dart';
import 'package:e7m/features/player/competitions/models/competition_payment_account_model.dart';
import 'package:e7m/features/player/competitions/models/competition_payment_model.dart';
import 'package:e7m/features/player/competitions/models/competition_registration_model.dart';

class CompetitionRepository {
  CompetitionRepository({
    CompetitionApi? competitionApi,
  }) : _competitionApi =
      competitionApi ?? CompetitionApi();

  final CompetitionApi _competitionApi;

  // ============================================================
  // GET PLAYER COMPETITIONS
  // ============================================================

  /// Get public competitions available for the authenticated player.
  Future<List<CompetitionModel>>
  getPlayerCompetitions({
    String? search,
    String? location,
    String? date,
    String? competitionType,
    String? price,
    String? status,
  }) async {
    final response =
    await _competitionApi.getPlayerCompetitions(
      search: search,
      location: location,
      date: date,
      competitionType: competitionType,
      price: price,
      status: status,
    );

    final competitions =
    response['competitions'];

    if (competitions is! List) {
      return const [];
    }

    return competitions
        .whereType<Map>()
        .map(
          (item) =>
          CompetitionModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
    )
        .toList();
  }

  // ============================================================
  // MY COMPETITIONS
  // ============================================================

  Future<List<CompetitionModel>>
  getPlayerMyCompetitions() async {
    final response =
    await _competitionApi.getPlayerMyCompetitions();

    final competitions =
    response['competitions'];

    if (competitions is! List) {
      return const [];
    }

    return competitions
        .whereType<Map>()
        .map(
          (item) =>
          CompetitionModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
    )
        .toList();
  }

  // ============================================================
  // COMPETITION STANDINGS
  // ============================================================

  /// Get standings for a competition in which
  /// the authenticated player participates.
  ///
  /// GET:
  /// /api/player/competitions/:competitionId/standings
  Future<Map<String, dynamic>>
  getCompetitionStandings(
      int competitionId,
      ) async {
    final response =
    await _competitionApi.getCompetitionStandings(
      competitionId,
    );

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // COMPETITION MATCHES
  // ============================================================

  /// Get matches for a competition in which
  /// the authenticated player participates.
  ///
  /// GET:
  /// /api/player/competitions/:competitionId/matches
  Future<Map<String, dynamic>>
  getCompetitionMatches(
      int competitionId,
      ) async {
    final response =
    await _competitionApi.getCompetitionMatches(
      competitionId,
    );

    return Map<String, dynamic>.from(response);
  }

  /// Get competition matches as typed models.
  ///
  /// The raw API response is kept available through
  /// [getCompetitionMatches].
  Future<List<CompetitionMatchModel>>
  getCompetitionMatchModels(
      int competitionId,
      ) async {
    final response =
    await getCompetitionMatches(
      competitionId,
    );

    final matches = response['matches'];

    if (matches is! List) {
      return const [];
    }

    return matches
        .whereType<Map>()
        .map(
          (item) =>
          CompetitionMatchModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
    )
        .toList();
  }

  // ============================================================
  // COMPETITION GOALS
  // ============================================================

  /// Get goals from the competition matches
  /// available to the authenticated player.
  ///
  /// GET:
  /// /api/player/competitions/:competitionId/goals
  Future<Map<String, dynamic>>
  getCompetitionGoals(
      int competitionId,
      ) async {
    final response =
    await _competitionApi.getCompetitionGoals(
      competitionId,
    );

    return Map<String, dynamic>.from(response);
  }

  /// Get competition goals as typed models.
  ///
  /// The raw API response is kept available through
  /// [getCompetitionGoals].
  Future<List<CompetitionGoalModel>>
  getCompetitionGoalModels(
      int competitionId,
      ) async {
    final response =
    await getCompetitionGoals(
      competitionId,
    );

    final goals = response['goals'];

    if (goals is! List) {
      return const [];
    }

    return goals
        .whereType<Map>()
        .map(
          (item) =>
          CompetitionGoalModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
    )
        .toList();
  }

  // ============================================================
  // COMPETITION BRACKET
  // ============================================================

  /// Get tournament bracket for a competition
  /// in which the authenticated player participates.
  ///
  /// GET:
  /// /api/player/competitions/:competitionId/bracket
  Future<Map<String, dynamic>>
  getCompetitionBracket(
      int competitionId,
      ) async {
    final response =
    await _competitionApi.getCompetitionBracket(
      competitionId,
    );

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // INVITATIONS
  // ============================================================

  Future<List<CompetitionInvitationModel>>
  getPlayerCompetitionInvitations({
    String? status,
  }) async {
    final response =
    await _competitionApi
        .getPlayerCompetitionInvitations(
      status: status,
    );

    final invitations =
    response['invitations'];

    if (invitations is! List) {
      return const [];
    }

    return invitations
        .whereType<Map>()
        .map(
          (item) =>
          CompetitionInvitationModel.fromJson(
            Map<String, dynamic>.from(item),
          ),
    )
        .toList();
  }

  // ============================================================
  // GET COMPETITION PAYMENT ACCOUNTS
  // ============================================================

  /// Get active payment accounts of the competition owner.
  Future<List<CompetitionPaymentAccountModel>>
  getCompetitionPaymentAccounts(
      int competitionId,
      ) async {
    final response =
    await _competitionApi
        .getCompetitionPaymentAccounts(
      competitionId,
    );

    final accounts =
    response['accounts'];

    if (accounts is! List) {
      return const [];
    }

    return accounts
        .whereType<Map>()
        .map(
          (item) =>
          CompetitionPaymentAccountModel
              .fromJson(
            Map<String, dynamic>.from(item),
          ),
    )
        .toList();
  }

  // ============================================================
  // REGISTER
  // ============================================================

  /// Register the authenticated player for a competition.
  Future<CompetitionRegistrationModel>
  registerForCompetition(
      int competitionId,
      ) async {
    final response =
    await _competitionApi
        .registerForCompetition(
      competitionId,
    );

    final data = _extractEntity(
      response,
      const [
        'registration',
        'data',
      ],
    );

    return CompetitionRegistrationModel
        .fromJson(data);
  }

  // ============================================================
  // ACCEPT INVITATION
  // ============================================================

  /// Accept a private competition invitation.
  Future<CompetitionInvitationModel>
  acceptInvitation(
      int invitationId,
      ) async {
    final response =
    await _competitionApi
        .acceptInvitation(
      invitationId,
    );

    final data = _extractEntity(
      response,
      const [
        'invitation',
        'data',
      ],
    );

    return CompetitionInvitationModel
        .fromJson(data);
  }

  // ============================================================
  // REJECT INVITATION
  // ============================================================

  /// Reject a private competition invitation.
  Future<CompetitionInvitationModel>
  rejectInvitation(
      int invitationId,
      ) async {
    final response =
    await _competitionApi
        .rejectInvitation(
      invitationId,
    );

    final data = _extractEntity(
      response,
      const [
        'invitation',
        'data',
      ],
    );

    return CompetitionInvitationModel
        .fromJson(data);
  }

  // ============================================================
  // SUBMIT PAYMENT
  // ============================================================

  /// Submit competition payment proof.
  Future<CompetitionPaymentModel>
  submitCompetitionPayment({
    required int registrationId,
    required int ownerPaymentAccountId,
    required String transactionReference,
    required File proofImage,
  }) async {
    final response =
    await _competitionApi
        .submitCompetitionPayment(
      registrationId: registrationId,
      ownerPaymentAccountId:
      ownerPaymentAccountId,
      transactionReference:
      transactionReference,
      proofImage: proofImage,
    );

    final data = _extractEntity(
      response,
      const [
        'payment',
        'competition_payment',
        'data',
      ],
    );

    return CompetitionPaymentModel
        .fromJson(data);
  }

  // ============================================================
  // RESPONSE PARSER
  // ============================================================

  /// Extracts the actual entity from the API response.
  ///
  /// The backend may return:
  ///
  /// {
  ///   "registration": {...}
  /// }
  ///
  /// or:
  ///
  /// {
  ///   "data": {...}
  /// }
  ///
  /// or the entity itself.
  Map<String, dynamic> _extractEntity(
      Map<String, dynamic> response,
      List<String> possibleKeys,
      ) {
    for (final key in possibleKeys) {
      final value = response[key];

      if (value is Map) {
        return Map<String, dynamic>.from(
          value,
        );
      }
    }

    return response;
  }
}