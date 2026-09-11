import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:e7m/features/player/competitions/models/competition_goal_model.dart';
import 'package:e7m/features/player/competitions/models/competition_invitation_model.dart';
import 'package:e7m/features/player/competitions/models/competition_match_model.dart';
import 'package:e7m/features/player/competitions/models/competition_model.dart';
import 'package:e7m/features/player/competitions/models/competition_payment_account_model.dart';
import 'package:e7m/features/player/competitions/models/competition_payment_model.dart';
import 'package:e7m/features/player/competitions/models/competition_registration_model.dart';
import 'package:e7m/features/player/competitions/repositories/competition_repository.dart';

class CompetitionProvider extends ChangeNotifier {
  CompetitionProvider({
    CompetitionRepository? repository,
  }) : _repository =
      repository ?? CompetitionRepository();

  final CompetitionRepository _repository;

  // ============================================================
  // STATE
  // ============================================================

  bool _isLoading = false;

  String? _errorMessage;

  List<CompetitionModel> _competitions = [];

  List<CompetitionModel> _myCompetitions = [];

  List<CompetitionInvitationModel> _invitations = [];

  String _search = '';

  String _location = '';

  String? _date;

  String? _competitionType;

  String? _price;

  String? _status;

  List<CompetitionPaymentAccountModel>
  _paymentAccounts = [];

  CompetitionRegistrationModel? _registration;

  CompetitionInvitationModel? _invitation;

  CompetitionPaymentModel? _payment;

  // ============================================================
  // COMPETITION DETAILS DATA
  // ============================================================

  Map<String, dynamic>? _standings;

  List<CompetitionMatchModel> _matches = [];

  List<CompetitionGoalModel> _goals = [];

  Map<String, dynamic>? _bracket;

  // ============================================================
  // GETTERS
  // ============================================================

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  List<CompetitionModel> get competitions =>
      List.unmodifiable(_competitions);

  List<CompetitionModel> get myCompetitions =>
      List.unmodifiable(_myCompetitions);

  List<CompetitionInvitationModel> get invitations =>
      List.unmodifiable(_invitations);

  String get search => _search;

  String get location => _location;

  String? get selectedDate => _date;

  String? get competitionType => _competitionType;

  String? get price => _price;

  String? get status => _status;

  bool get hasMyCompetitions =>
      _myCompetitions.isNotEmpty;

  bool get hasInvitations =>
      _invitations.isNotEmpty;

  List<CompetitionPaymentAccountModel>
  get paymentAccounts =>
      List.unmodifiable(_paymentAccounts);

  CompetitionRegistrationModel? get registration =>
      _registration;

  CompetitionInvitationModel? get invitation =>
      _invitation;

  CompetitionPaymentModel? get payment =>
      _payment;

  // ============================================================
  // STANDINGS / MATCHES / GOALS / BRACKET GETTERS
  // ============================================================

  Map<String, dynamic>? get standings =>
      _standings == null
          ? null
          : Map<String, dynamic>.unmodifiable(
        _standings!,
      );

  List<CompetitionMatchModel> get matches =>
      List.unmodifiable(_matches);

  List<CompetitionGoalModel> get goals =>
      List.unmodifiable(_goals);

  Map<String, dynamic>? get bracket =>
      _bracket == null
          ? null
          : Map<String, dynamic>.unmodifiable(
        _bracket!,
      );

  bool get hasStandings =>
      _standings != null;

  bool get hasMatches =>
      _matches.isNotEmpty;

  bool get hasGoals =>
      _goals.isNotEmpty;

  bool get hasError =>
      _errorMessage != null &&
          _errorMessage!.isNotEmpty;

  bool get hasCompetitions =>
      _competitions.isNotEmpty;

  bool get hasPaymentAccounts =>
      _paymentAccounts.isNotEmpty;

  bool get hasRegistration =>
      _registration != null;

  bool get hasInvitation =>
      _invitation != null;

  bool get hasPayment =>
      _payment != null;

  bool get hasBracket =>
      _bracket != null;

  // ============================================================
  // GET PLAYER COMPETITIONS
  // ============================================================

  Future<bool> loadCompetitions({
    String? search,
    String? location,
    String? date,
    String? competitionType,
    String? price,
    String? status,
  }) async {
    if (search != null) {
      _search = search.trim();
    }

    if (location != null) {
      _location = location.trim();
    }

    if (date != null) {
      _date =
      date.trim().isEmpty ? null : date.trim();
    }

    if (competitionType != null) {
      _competitionType = competitionType;
    }

    if (price != null) {
      _price = price;
    }

    if (status != null) {
      _status = status;
    }

    _startLoading();

    try {
      final result =
      await _repository.getPlayerCompetitions(
        search: _search,
        location: _location,
        date: _date,
        competitionType: _competitionType,
        price: _price,
        status: _status,
      );

      _competitions = result;

      _clearError();

      return true;
    } catch (error) {
      _setError(error);

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // MY COMPETITIONS
  // ============================================================

  Future<bool> loadMyCompetitions() async {
    _startLoading();

    try {
      _myCompetitions =
      await _repository.getPlayerMyCompetitions();

      _clearError();

      return true;
    } catch (error) {
      _setError(error);

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // INVITATIONS
  // ============================================================

  Future<bool> loadInvitations({
    String? status,
  }) async {
    _startLoading();

    try {
      _invitations =
      await _repository
          .getPlayerCompetitionInvitations(
        status: status,
      );

      _clearError();

      return true;
    } catch (error) {
      _setError(error);

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Future<bool> setSearch(
      String value,
      ) =>
      loadCompetitions(
        search: value,
      );

  Future<bool> setLocation(
      String? value,
      ) =>
      loadCompetitions(
        location: value ?? '',
      );

  Future<bool> setDate(
      DateTime? value,
      ) =>
      loadCompetitions(
        date: value == null
            ? ''
            : _dateOnly(value),
      );

  Future<bool> setCompetitionType(
      String? value,
      ) =>
      loadCompetitions(
        competitionType: value,
      );

  Future<bool> setPrice(
      String? value,
      ) =>
      loadCompetitions(
        price: value,
      );

  Future<bool> setStatus(
      String? value,
      ) =>
      loadCompetitions(
        status: value,
      );

  Future<bool> applyFilters({
    String? search,
    String? location,
    DateTime? date,
    String? competitionType,
    String? price,
    String? status,
  }) =>
      loadCompetitions(
        search: search ?? _search,
        location: location ?? _location,
        date: date == null
            ? (_date ?? '')
            : _dateOnly(date),
        competitionType: competitionType,
        price: price,
        status: status,
      );

  Future<bool> clearFilters() async {
    _search = '';

    _location = '';

    _date = null;

    _competitionType = null;

    _price = null;

    _status = null;

    return loadCompetitions();
  }

  static String _dateOnly(
      DateTime value,
      ) {
    final local = value.toLocal();

    final month =
    local.month.toString().padLeft(2, '0');

    final day =
    local.day.toString().padLeft(2, '0');

    return '${local.year}-$month-$day';
  }

  // ============================================================
  // LOAD COMPETITION STANDINGS
  // ============================================================

  Future<bool> loadCompetitionStandings(
      int competitionId,
      ) async {
    _startLoading();

    try {
      final result =
      await _repository
          .getCompetitionStandings(
        competitionId,
      );

      _standings =
      Map<String, dynamic>.from(result);

      _clearError();

      return true;
    } catch (error) {
      _setError(error);

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // LOAD COMPETITION MATCHES
  // ============================================================

  Future<bool> loadCompetitionMatches(
      int competitionId,
      ) async {
    _startLoading();

    try {
      final result =
      await _repository
          .getCompetitionMatchModels(
        competitionId,
      );

      _matches = result;

      _clearError();

      return true;
    } catch (error) {
      _setError(error);

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // LOAD COMPETITION GOALS
  // ============================================================

  Future<bool> loadCompetitionGoals(
      int competitionId,
      ) async {
    _startLoading();

    try {
      final result =
      await _repository
          .getCompetitionGoalModels(
        competitionId,
      );

      _goals = result;

      _clearError();

      return true;
    } catch (error) {
      _setError(error);

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // LOAD COMPETITION BRACKET
  // ============================================================

  Future<bool> loadCompetitionBracket(
      int competitionId,
      ) async {
    _startLoading();

    try {
      final result =
      await _repository
          .getCompetitionBracket(
        competitionId,
      );

      _bracket =
      Map<String, dynamic>.from(result);

      _clearError();

      return true;
    } catch (error) {
      _setError(error);

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // LOAD ALL COMPETITION DATA
  // ============================================================

  Future<bool> loadCompetitionData(
      int competitionId,
      ) async {
    _startLoading();

    try {
      final standings =
      await _repository
          .getCompetitionStandings(
        competitionId,
      );

      final matches =
      await _repository
          .getCompetitionMatchModels(
        competitionId,
      );

      final goals =
      await _repository
          .getCompetitionGoals(
        competitionId,
      );

      final bracket =
      await _repository
          .getCompetitionBracket(
        competitionId,
      );

      _standings =
      Map<String, dynamic>.from(
        standings,
      );

      _matches = matches;

      _goals =
      (goals['goals'] is List)
          ? (goals['goals'] as List)
          .whereType<Map>()
          .map(
            (item) =>
            CompetitionGoalModel
                .fromJson(
              Map<String, dynamic>.from(
                item,
              ),
            ),
      )
          .toList()
          : [];

      _bracket =
      Map<String, dynamic>.from(
        bracket,
      );

      _clearError();

      return true;
    } catch (error) {
      _setError(error);

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // GET COMPETITION PAYMENT ACCOUNTS
  // ============================================================

  Future<bool> loadPaymentAccounts(
      int competitionId,
      ) async {
    _startLoading();

    try {
      final result =
      await _repository
          .getCompetitionPaymentAccounts(
        competitionId,
      );

      _paymentAccounts = result;

      _clearError();

      return true;
    } catch (error) {
      _setError(error);

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // REGISTER
  // ============================================================

  Future<bool> registerForCompetition(
      int competitionId,
      ) async {
    _startLoading();

    try {
      final result =
      await _repository
          .registerForCompetition(
        competitionId,
      );

      _registration = result;

      _clearError();

      return true;
    } catch (error) {
      _setError(error);

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // ACCEPT INVITATION
  // ============================================================

  Future<bool> acceptInvitation(
      int invitationId,
      ) async {
    _startLoading();

    try {
      final result =
      await _repository
          .acceptInvitation(
        invitationId,
      );

      _invitation = result;

      _clearError();

      return true;
    } catch (error) {
      _setError(error);

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // REJECT INVITATION
  // ============================================================

  Future<bool> rejectInvitation(
      int invitationId,
      ) async {
    _startLoading();

    try {
      final result =
      await _repository
          .rejectInvitation(
        invitationId,
      );

      _invitation = result;

      _clearError();

      return true;
    } catch (error) {
      _setError(error);

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // SUBMIT PAYMENT
  // ============================================================

  Future<bool> submitCompetitionPayment({
    required int registrationId,
    required int ownerPaymentAccountId,
    required String transactionReference,
    required File proofImage,
  }) async {
    _startLoading();

    try {
      final result =
      await _repository
          .submitCompetitionPayment(
        registrationId: registrationId,
        ownerPaymentAccountId:
        ownerPaymentAccountId,
        transactionReference:
        transactionReference,
        proofImage: proofImage,
      );

      _payment = result;

      _clearError();

      return true;
    } catch (error) {
      _setError(error);

      return false;
    } finally {
      _stopLoading();
    }
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _clearError();

    notifyListeners();
  }

  // ============================================================
  // CLEAR COMPETITIONS
  // ============================================================

  void clearCompetitions() {
    _competitions = [];

    notifyListeners();
  }

  // ============================================================
  // CLEAR PAYMENT ACCOUNTS
  // ============================================================

  void clearPaymentAccounts() {
    _paymentAccounts = [];

    notifyListeners();
  }

  // ============================================================
  // CLEAR REGISTRATION
  // ============================================================

  void clearRegistration() {
    _registration = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR INVITATION
  // ============================================================

  void clearInvitation() {
    _invitation = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR PAYMENT
  // ============================================================

  void clearPayment() {
    _payment = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR STANDINGS
  // ============================================================

  void clearStandings() {
    _standings = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR MATCHES
  // ============================================================

  void clearMatches() {
    _matches = [];

    notifyListeners();
  }

  // ============================================================
  // CLEAR GOALS
  // ============================================================

  void clearGoals() {
    _goals = [];

    notifyListeners();
  }

  // ============================================================
  // CLEAR BRACKET
  // ============================================================

  void clearBracket() {
    _bracket = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR ALL
  // ============================================================

  void clearAll() {
    _competitions = [];

    _myCompetitions = [];

    _invitations = [];

    _search = '';

    _location = '';

    _date = null;

    _competitionType = null;

    _price = null;

    _status = null;

    _paymentAccounts = [];

    _registration = null;

    _invitation = null;

    _payment = null;

    _standings = null;

    _matches = [];

    _goals = [];

    _bracket = null;

    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // INTERNAL STATE HELPERS
  // ============================================================

  void _startLoading() {
    _isLoading = true;

    _errorMessage = null;

    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;

    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(
      Object error,
      ) {
    _errorMessage =
        _extractErrorMessage(error);

    notifyListeners();
  }

  String _extractErrorMessage(
      Object error,
      ) {
    final message =
    error.toString().trim();

    if (message.isEmpty) {
      return 'Something went wrong. Please try again.';
    }

    if (message.startsWith(
      'Exception: ',
    )) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }
}