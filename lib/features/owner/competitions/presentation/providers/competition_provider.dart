import 'package:flutter/foundation.dart';

import '../../data/models/competition_model.dart';
import '../../data/models/competition_prize_model.dart';
import '../../data/models/competition_registration_model.dart';
import '../../data/models/competition_invitation_model.dart';
import '../../data/models/competition_payment_model.dart';
import '../../data/models/competition_seeding_model.dart';
import '../../data/models/competition_match_model.dart';
import '../../data/models/competition_standing_model.dart';
import '../../data/models/competition_bracket_model.dart';
import '../../data/repositories/competition_repository.dart';

class CompetitionProvider extends ChangeNotifier {
  final CompetitionRepository _repository;

  CompetitionProvider(this._repository);

  bool _isLoading = false;
  String? _errorMessage;

  List<CompetitionModel> _competitions = [];
  CompetitionModel? _selectedCompetition;
  List<CompetitionPrizeModel> _prizes = [];
  List<CompetitionRegistrationModel> _registrations = [];
  List<CompetitionInvitationModel> _invitations = [];

  List<CompetitionPaymentModel> _payments = [];
  int _paymentSessionVersion = 0;
  int _paymentRequestVersion = 0;

  List<CompetitionSeedingModel> _seeding = [];
  List<CompetitionMatchModel> _matches = [];
  CompetitionMatchModel? _selectedMatch;
  List<CompetitionStandingModel> _standings = [];
  CompetitionBracketModel? _bracket;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<CompetitionModel> get competitions =>
      List.unmodifiable(_competitions);

  CompetitionModel? get selectedCompetition => _selectedCompetition;

  List<CompetitionPrizeModel> get prizes =>
      List.unmodifiable(_prizes);

  List<CompetitionRegistrationModel> get registrations =>
      List.unmodifiable(_registrations);

  List<CompetitionInvitationModel> get invitations =>
      List.unmodifiable(_invitations);

  List<CompetitionPaymentModel> get payments =>
      List.unmodifiable(_payments);

  List<CompetitionSeedingModel> get seeding =>
      List.unmodifiable(_seeding);

  List<CompetitionMatchModel> get matches =>
      List.unmodifiable(_matches);

  CompetitionMatchModel? get selectedMatch => _selectedMatch;

  List<CompetitionStandingModel> get standings =>
      List.unmodifiable(_standings);

  CompetitionBracketModel? get bracket => _bracket;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void _setError(Object error) {
    _errorMessage = error.toString();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> loadCompetitions() async {
    _setLoading(true);
    _clearError();

    try {
      _competitions = await _repository.getOwnerCompetitions();
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loadCompetition(int competitionId) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedCompetition =
      await _repository.getCompetitionById(competitionId);
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<CompetitionModel?> createCompetition(
      Map<String, dynamic> data,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      final competition = await _repository.createCompetition(data);
      _competitions.insert(0, competition);
      return competition;
    } catch (error) {
      _setError(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<CompetitionModel?> updateCompetition(
      int competitionId,
      Map<String, dynamic> data,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedCompetition =
      await _repository.updateCompetition(competitionId, data);

      final index = _competitions.indexWhere(
            (competition) => competition.id == competitionId,
      );

      if (index != -1) {
        _competitions[index] = updatedCompetition;
      }

      if (_selectedCompetition?.id == competitionId) {
        _selectedCompetition = updatedCompetition;
      }

      notifyListeners();
      return updatedCompetition;
    } catch (error) {
      _setError(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<CompetitionModel?> updateCompetitionStatus(
      int competitionId,
      String status,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedCompetition =
      await _repository.updateCompetitionStatus(
        competitionId,
        status,
      );

      final index = _competitions.indexWhere(
            (competition) => competition.id == competitionId,
      );

      if (index != -1) {
        _competitions[index] = updatedCompetition;
      }

      if (_selectedCompetition?.id == competitionId) {
        _selectedCompetition = updatedCompetition;
      }

      notifyListeners();
      return updatedCompetition;
    } catch (error) {
      _setError(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteCompetition(int competitionId) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deleteCompetition(competitionId);

      _competitions.removeWhere(
            (competition) => competition.id == competitionId,
      );

      if (_selectedCompetition?.id == competitionId) {
        _selectedCompetition = null;
        _prizes = [];
        _registrations = [];
        _invitations = [];
        _seeding = [];
        _matches = [];
        _selectedMatch = null;
        _standings = [];
        _bracket = null;
      }

      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loadPrizes(int competitionId) async {
    _setLoading(true);
    _clearError();

    try {
      _prizes =
      await _repository.getCompetitionPrizes(competitionId);
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<CompetitionPrizeModel?> createPrize(
      int competitionId,
      Map<String, dynamic> data,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      final prize = await _repository.createPrize(
        competitionId,
        data,
      );

      _prizes.add(prize);
      return prize;
    } catch (error) {
      _setError(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<CompetitionPrizeModel?> updatePrize(
      int competitionId,
      int prizeId,
      Map<String, dynamic> data,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedPrize = await _repository.updatePrize(
        competitionId,
        prizeId,
        data,
      );

      final index = _prizes.indexWhere(
            (prize) => prize.id == prizeId,
      );

      if (index != -1) {
        _prizes[index] = updatedPrize;
      }

      notifyListeners();
      return updatedPrize;
    } catch (error) {
      _setError(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deletePrize(
      int competitionId,
      int prizeId,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.deletePrize(competitionId, prizeId);

      _prizes.removeWhere((prize) => prize.id == prizeId);
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loadRegistrations(int competitionId) async {
    _setLoading(true);
    _clearError();

    try {
      _registrations =
      await _repository.getCompetitionRegistrations(
        competitionId,
      );
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<CompetitionRegistrationModel?> approveRegistration(
      int competitionId,
      int registrationId,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedRegistration =
      await _repository.approveRegistration(
        competitionId,
        registrationId,
      );

      _updateRegistrationInList(updatedRegistration);
      return updatedRegistration;
    } catch (error) {
      _setError(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<CompetitionRegistrationModel?> rejectRegistration(
      int competitionId,
      int registrationId,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedRegistration =
      await _repository.rejectRegistration(
        competitionId,
        registrationId,
      );

      _updateRegistrationInList(updatedRegistration);
      return updatedRegistration;
    } catch (error) {
      _setError(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<CompetitionRegistrationModel?> moveRegistrationToWaitlist(
      int competitionId,
      int registrationId,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedRegistration =
      await _repository.moveRegistrationToWaitlist(
        competitionId,
        registrationId,
      );

      _updateRegistrationInList(updatedRegistration);
      return updatedRegistration;
    } catch (error) {
      _setError(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _updateRegistrationInList(
      CompetitionRegistrationModel registration,
      ) {
    final index = _registrations.indexWhere(
          (item) => item.id == registration.id,
    );

    if (index != -1) {
      _registrations[index] = registration;
    } else {
      _registrations.add(registration);
    }

    notifyListeners();
  }

  Future<bool> loadInvitations(int competitionId) async {
    _setLoading(true);
    _clearError();

    try {
      _invitations =
      await _repository.getCompetitionInvitations(
        competitionId,
      );
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<CompetitionInvitationModel?> sendInvitation(
      int competitionId,
      Map<String, dynamic> data,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      final invitation = await _repository.sendInvitation(
        competitionId,
        data,
      );

      _invitations.insert(0, invitation);
      return invitation;
    } catch (error) {
      _setError(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loadPayments() async {
    final session = _paymentSessionVersion;
    final request = ++_paymentRequestVersion;

    _setLoading(true);
    _clearError();

    try {
      final payments = await _repository.getCompetitionPayments();

      if (session != _paymentSessionVersion ||
          request != _paymentRequestVersion) {
        return false;
      }

      _payments = payments;
      return true;
    } catch (error) {
      if (session == _paymentSessionVersion &&
          request == _paymentRequestVersion) {
        _setError(error);
      }

      return false;
    } finally {
      if (session == _paymentSessionVersion &&
          request == _paymentRequestVersion) {
        _setLoading(false);
      }
    }
  }

  Future<CompetitionPaymentModel?> approveCompetitionPayment(
      int paymentId,
      ) async {
    final session = _paymentSessionVersion;
    _paymentRequestVersion++;

    _setLoading(true);
    _clearError();

    try {
      final updatedPayment =
      await _repository.approveCompetitionPayment(paymentId);

      if (session != _paymentSessionVersion) return null;

      _updatePaymentInList(updatedPayment);
      return updatedPayment;
    } catch (error) {
      if (session == _paymentSessionVersion) {
        _setError(error);
      }

      return null;
    } finally {
      if (session == _paymentSessionVersion) {
        _setLoading(false);
      }
    }
  }

  Future<CompetitionPaymentModel?> rejectCompetitionPayment(
      int paymentId, {
        String? rejectionReason,
      }) async {
    final session = _paymentSessionVersion;
    _paymentRequestVersion++;

    _setLoading(true);
    _clearError();

    try {
      final updatedPayment =
      await _repository.rejectCompetitionPayment(
        paymentId,
        rejectionReason: rejectionReason,
      );

      if (session != _paymentSessionVersion) return null;

      _updatePaymentInList(updatedPayment);
      return updatedPayment;
    } catch (error) {
      if (session == _paymentSessionVersion) {
        _setError(error);
      }

      return null;
    } finally {
      if (session == _paymentSessionVersion) {
        _setLoading(false);
      }
    }
  }

  void _updatePaymentInList(CompetitionPaymentModel payment) {
    final index = _payments.indexWhere(
          (item) => item.id == payment.id,
    );

    if (index != -1) {
      _payments[index] = payment;
    } else {
      _payments.insert(0, payment);
    }

    notifyListeners();
  }

  Future<bool> loadSeeding(int competitionId) async {
    _setLoading(true);
    _clearError();

    try {
      _seeding =
      await _repository.getCompetitionSeeding(competitionId);
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> generateSeeding(int competitionId) async {
    _setLoading(true);
    _clearError();

    try {
      _seeding =
      await _repository.generateSeeding(competitionId);
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateManualSeeding(
      int competitionId,
      List<Map<String, dynamic>> seeding,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      _seeding = await _repository.updateManualSeeding(
        competitionId,
        seeding,
      );
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> confirmSeeding(int competitionId) async {
    _setLoading(true);
    _clearError();

    try {
      _seeding =
      await _repository.confirmSeeding(competitionId);
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> generateTournament(int competitionId) async {
    _setLoading(true);
    _clearError();

    try {
      _matches =
      await _repository.generateTournament(competitionId);
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loadMatches(int competitionId) async {
    _setLoading(true);
    _clearError();

    try {
      _matches =
      await _repository.getCompetitionMatches(competitionId);
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loadMatch(
      int competitionId,
      int matchId,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      _selectedMatch =
      await _repository.getCompetitionMatchById(
        competitionId,
        matchId,
      );
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<CompetitionMatchModel?> updateMatch(
      int competitionId,
      int matchId,
      Map<String, dynamic> data,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedMatch =
      await _repository.updateCompetitionMatch(
        competitionId,
        matchId,
        data,
      );

      _updateMatchInList(updatedMatch);
      return updatedMatch;
    } catch (error) {
      _setError(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<CompetitionMatchModel?> cancelMatch(
      int competitionId,
      int matchId,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedMatch =
      await _repository.cancelCompetitionMatch(
        competitionId,
        matchId,
      );

      _updateMatchInList(updatedMatch);
      return updatedMatch;
    } catch (error) {
      _setError(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  void _updateMatchInList(CompetitionMatchModel match) {
    final index = _matches.indexWhere(
          (item) => item.id == match.id,
    );

    if (index != -1) {
      _matches[index] = match;
    } else {
      _matches.add(match);
    }

    _selectedMatch = match;
    notifyListeners();
  }

  Future<CompetitionMatchModel?> submitMatchResult(
      int competitionId,
      int matchId,
      Map<String, dynamic> data,
      ) async {
    _setLoading(true);
    _clearError();

    try {
      final updatedMatch =
      await _repository.submitCompetitionMatchResult(
        competitionId,
        matchId,
        data,
      );

      _updateMatchInList(updatedMatch);
      return updatedMatch;
    } catch (error) {
      _setError(error);
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loadStandings(int competitionId) async {
    _setLoading(true);
    _clearError();

    try {
      _standings =
      await _repository.getCompetitionStandings(competitionId);
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> loadBracket(int competitionId) async {
    _setLoading(true);
    _clearError();

    try {
      _bracket =
      await _repository.getCompetitionBracket(competitionId);
      return true;
    } catch (error) {
      _setError(error);
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void clearSelectedCompetition() {
    _selectedCompetition = null;
    _prizes = [];
    _registrations = [];
    _invitations = [];
    _seeding = [];
    _matches = [];
    _selectedMatch = null;
    _standings = [];
    _bracket = null;
    _errorMessage = null;

    notifyListeners();
  }

  void clearRegistrations() {
    _registrations = [];
    notifyListeners();
  }

  void clearInvitations() {
    _invitations = [];
    notifyListeners();
  }

  void clearPayments() {
    _payments = [];
    notifyListeners();
  }

  void clearSeeding() {
    _seeding = [];
    notifyListeners();
  }

  void clearMatches() {
    _matches = [];
    _selectedMatch = null;
    notifyListeners();
  }

  void clearStandings() {
    _standings = [];
    notifyListeners();
  }

  void clearBracket() {
    _bracket = null;
    notifyListeners();
  }

  void reset() {
    _paymentSessionVersion++;
    _paymentRequestVersion++;

    _isLoading = false;
    _errorMessage = null;

    _competitions = [];
    _selectedCompetition = null;
    _prizes = [];
    _registrations = [];
    _invitations = [];
    _payments = [];
    _seeding = [];
    _matches = [];
    _selectedMatch = null;
    _standings = [];
    _bracket = null;

    notifyListeners();
  }
}