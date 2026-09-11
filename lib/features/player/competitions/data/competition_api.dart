import 'dart:io';

import 'package:e7m/core/network/api_client.dart';

class CompetitionApi {
  CompetitionApi({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  final ApiClient _apiClient;

  // ============================================================
  // GET PLAYER COMPETITIONS
  // ============================================================

  /// Get public competitions available for the authenticated player.
  ///
  /// GET:
  /// /api/player/competitions
  Future<Map<String, dynamic>> getPlayerCompetitions({
    String? search,
    String? location,
    String? date,
    String? competitionType,
    String? price,
    String? status,
  }) async {
    final query = <String, String>{};

    void addQuery(String key, String? value) {
      final trimmed = value?.trim() ?? '';

      if (trimmed.isNotEmpty) {
        query[key] = trimmed;
      }
    }

    addQuery('search', search);
    addQuery('location', location);
    addQuery('date', date);
    addQuery('competition_type', competitionType);
    addQuery('price', price);
    addQuery('status', status);

    final endpoint = query.isEmpty
        ? '/player/competitions'
        : '/player/competitions?${Uri(queryParameters: query).query}';

    final response = await _apiClient.get(endpoint);

    if (response is! Map) {
      throw const FormatException(
        'Invalid player competitions response.',
      );
    }

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // MY COMPETITIONS
  // ============================================================

  /// Get competitions in which the authenticated player participates.
  ///
  /// GET:
  /// /api/player/competitions/my
  Future<Map<String, dynamic>> getPlayerMyCompetitions() async {
    final response = await _apiClient.get(
      '/player/competitions/my',
    );

    if (response is! Map) {
      throw const FormatException(
        'Invalid my competitions response.',
      );
    }

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // COMPETITION STANDINGS
  // ============================================================

  /// Get standings for a competition in which the player participates.
  ///
  /// GET:
  /// /api/player/competitions/:competitionId/standings
  Future<Map<String, dynamic>> getCompetitionStandings(
      int competitionId,
      ) async {
    if (competitionId <= 0) {
      throw ArgumentError.value(
        competitionId,
        'competitionId',
        'Competition ID must be greater than zero.',
      );
    }

    final response = await _apiClient.get(
      '/player/competitions/$competitionId/standings',
    );

    if (response is! Map) {
      throw const FormatException(
        'Invalid competition standings response.',
      );
    }

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // COMPETITION MATCHES
  // ============================================================

  /// Get matches involving the authenticated player in a competition.
  ///
  /// GET:
  /// /api/player/competitions/:competitionId/matches
  Future<Map<String, dynamic>> getCompetitionMatches(
      int competitionId,
      ) async {
    if (competitionId <= 0) {
      throw ArgumentError.value(
        competitionId,
        'competitionId',
        'Competition ID must be greater than zero.',
      );
    }

    final response = await _apiClient.get(
      '/player/competitions/$competitionId/matches',
    );

    if (response is! Map) {
      throw const FormatException(
        'Invalid competition matches response.',
      );
    }

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // COMPETITION GOALS
  // ============================================================

  /// Get goals from the player's competition matches.
  ///
  /// GET:
  /// /api/player/competitions/:competitionId/goals
  Future<Map<String, dynamic>> getCompetitionGoals(
      int competitionId,
      ) async {
    if (competitionId <= 0) {
      throw ArgumentError.value(
        competitionId,
        'competitionId',
        'Competition ID must be greater than zero.',
      );
    }

    final response = await _apiClient.get(
      '/player/competitions/$competitionId/goals',
    );

    if (response is! Map) {
      throw const FormatException(
        'Invalid competition goals response.',
      );
    }

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // COMPETITION BRACKET
  // ============================================================

  /// Get tournament bracket for a competition in which the player
  /// participates.
  ///
  /// GET:
  /// /api/player/competitions/:competitionId/bracket
  Future<Map<String, dynamic>> getCompetitionBracket(
      int competitionId,
      ) async {
    if (competitionId <= 0) {
      throw ArgumentError.value(
        competitionId,
        'competitionId',
        'Competition ID must be greater than zero.',
      );
    }

    final response = await _apiClient.get(
      '/player/competitions/$competitionId/bracket',
    );

    if (response is! Map) {
      throw const FormatException(
        'Invalid competition bracket response.',
      );
    }

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // INVITATIONS
  // ============================================================

  /// Get competition invitations for the authenticated player.
  ///
  /// GET:
  /// /api/player/competitions/invitations
  Future<Map<String, dynamic>> getPlayerCompetitionInvitations({
    String? status,
  }) async {
    final value = status?.trim() ?? '';

    final endpoint = value.isEmpty
        ? '/player/competitions/invitations'
        : '/player/competitions/invitations?status=${Uri.encodeQueryComponent(value)}';

    final response = await _apiClient.get(endpoint);

    if (response is! Map) {
      throw const FormatException(
        'Invalid competition invitations response.',
      );
    }

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // REGISTER
  // ============================================================

  /// Register the authenticated player for a competition.
  ///
  /// POST:
  /// /api/player/competitions/:competitionId/register
  Future<Map<String, dynamic>> registerForCompetition(
      int competitionId,
      ) async {
    if (competitionId <= 0) {
      throw ArgumentError.value(
        competitionId,
        'competitionId',
        'Competition ID must be greater than zero.',
      );
    }

    final response = await _apiClient.post(
      '/player/competitions/$competitionId/register',
      <String, dynamic>{},
    );

    if (response is! Map) {
      throw const FormatException(
        'Invalid competition registration response.',
      );
    }

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // PAYMENT ACCOUNTS
  // ============================================================

  /// Get active payment accounts for the competition.
  ///
  /// GET:
  /// /api/player/competitions/:competitionId/payment-accounts
  Future<Map<String, dynamic>> getCompetitionPaymentAccounts(
      int competitionId,
      ) async {
    if (competitionId <= 0) {
      throw ArgumentError.value(
        competitionId,
        'competitionId',
        'Competition ID must be greater than zero.',
      );
    }

    final response = await _apiClient.get(
      '/player/competitions/$competitionId/payment-accounts',
    );

    if (response is! Map) {
      throw const FormatException(
        'Invalid competition payment accounts response.',
      );
    }

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // ACCEPT INVITATION
  // ============================================================

  /// Accept a private competition invitation.
  ///
  /// POST:
  /// /api/player/competitions/invitations/:invitationId/accept
  Future<Map<String, dynamic>> acceptInvitation(
      int invitationId,
      ) async {
    if (invitationId <= 0) {
      throw ArgumentError.value(
        invitationId,
        'invitationId',
        'Invitation ID must be greater than zero.',
      );
    }

    final response = await _apiClient.post(
      '/player/competitions/invitations/$invitationId/accept',
      <String, dynamic>{},
    );

    if (response is! Map) {
      throw const FormatException(
        'Invalid invitation acceptance response.',
      );
    }

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // REJECT INVITATION
  // ============================================================

  /// Reject a private competition invitation.
  ///
  /// POST:
  /// /api/player/competitions/invitations/:invitationId/reject
  Future<Map<String, dynamic>> rejectInvitation(
      int invitationId,
      ) async {
    if (invitationId <= 0) {
      throw ArgumentError.value(
        invitationId,
        'invitationId',
        'Invitation ID must be greater than zero.',
      );
    }

    final response = await _apiClient.post(
      '/player/competitions/invitations/$invitationId/reject',
      <String, dynamic>{},
    );

    if (response is! Map) {
      throw const FormatException(
        'Invalid invitation rejection response.',
      );
    }

    return Map<String, dynamic>.from(response);
  }

  // ============================================================
  // SUBMIT PAYMENT
  // ============================================================

  /// Submit competition payment proof.
  ///
  /// POST:
  /// /api/player/competitions/registrations/:registrationId/payment
  ///
  /// Multipart fields:
  /// - owner_payment_account_id
  /// - transaction_reference
  /// - proof_image
  Future<Map<String, dynamic>> submitCompetitionPayment({
    required int registrationId,
    required int ownerPaymentAccountId,
    required String transactionReference,
    required File proofImage,
  }) async {
    if (registrationId <= 0) {
      throw ArgumentError.value(
        registrationId,
        'registrationId',
        'Registration ID must be greater than zero.',
      );
    }

    if (ownerPaymentAccountId <= 0) {
      throw ArgumentError.value(
        ownerPaymentAccountId,
        'ownerPaymentAccountId',
        'Owner payment account ID must be greater than zero.',
      );
    }

    final reference = transactionReference.trim();

    if (reference.length < 3) {
      throw ArgumentError.value(
        transactionReference,
        'transactionReference',
        'Transaction reference must contain at least 3 characters.',
      );
    }

    if (!await proofImage.exists()) {
      throw ArgumentError.value(
        proofImage.path,
        'proofImage',
        'Payment proof file does not exist.',
      );
    }

    final response = await _apiClient.uploadMultipart(
      endpoint:
      '/player/competitions/registrations/$registrationId/payment',
      fields: <String, String>{
        'owner_payment_account_id':
        ownerPaymentAccountId.toString(),
        'transaction_reference': reference,
      },
      files: <File>[proofImage],
      fieldName: 'proof_image',
    );

    if (response is! Map) {
      throw const FormatException(
        'Invalid competition payment response.',
      );
    }

    return Map<String, dynamic>.from(response);
  }
}