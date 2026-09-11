import 'package:flutter/foundation.dart';

import '../../data/models/team_model.dart';
import '../../data/models/team_member_model.dart';
import '../../data/models/team_details_model.dart';
import '../../data/models/team_message_model.dart';
import '../../data/repositories/team_repository.dart';

class TeamProvider extends ChangeNotifier {
  final TeamRepository _repository;

  TeamProvider({
    TeamRepository? repository,
  }) : _repository = repository ?? TeamRepository();

  // ============================================================
  // STATE
  // ============================================================

  List<TeamModel> _teams = [];

  List<TeamModel> _myTeams = [];

  TeamModel? _selectedTeam;

  List<TeamMemberModel> _teamMembers = [];

  List<Map<String, dynamic>> _joinRequests = [];

  // ============================================================
  // TEAM CHAT STATE
  // ============================================================

  List<TeamMessageModel> _teamMessages = [];

  bool _isLoadingMessages = false;

  bool _isSendingMessage = false;

  // ============================================================
  // LOADING STATE
  // ============================================================

  bool _isLoading = false;
  bool _isLoadingDetails = false;
  bool _isLoadingMyTeams = false;
  bool _isLoadingRequests = false;

  bool _isJoiningTeam = false;
  bool _isCreatingTeam = false;
  bool _isUpdatingTeam = false;
  bool _isLeavingTeam = false;
  bool _isTransferringCaptaincy = false;

  String? _errorMessage;

  // ============================================================
  // GETTERS
  // ============================================================

  List<TeamModel> get teams =>
      List.unmodifiable(_teams);

  List<TeamModel> get myTeams =>
      List.unmodifiable(_myTeams);

  TeamModel? get selectedTeam =>
      _selectedTeam;

  List<TeamMemberModel> get teamMembers =>
      List.unmodifiable(_teamMembers);

  List<Map<String, dynamic>> get joinRequests =>
      List.unmodifiable(_joinRequests);

  // ============================================================
  // TEAM CHAT GETTERS
  // ============================================================

  List<TeamMessageModel> get teamMessages =>
      List.unmodifiable(_teamMessages);

  bool get isLoadingMessages =>
      _isLoadingMessages;

  bool get isSendingMessage =>
      _isSendingMessage;

  bool get hasTeamMessages =>
      _teamMessages.isNotEmpty;

  // ============================================================
  // LOADING GETTERS
  // ============================================================

  bool get isLoading =>
      _isLoading;

  bool get isLoadingDetails =>
      _isLoadingDetails;

  bool get isLoadingMyTeams =>
      _isLoadingMyTeams;

  bool get isLoadingRequests =>
      _isLoadingRequests;

  bool get isJoiningTeam =>
      _isJoiningTeam;

  bool get isCreatingTeam =>
      _isCreatingTeam;

  bool get isUpdatingTeam =>
      _isUpdatingTeam;

  bool get isLeavingTeam =>
      _isLeavingTeam;

  bool get isTransferringCaptaincy =>
      _isTransferringCaptaincy;

  String? get errorMessage =>
      _errorMessage;

  bool get hasTeams =>
      _teams.isNotEmpty;

  bool get hasMyTeams =>
      _myTeams.isNotEmpty;

  bool get hasJoinRequests =>
      _joinRequests.isNotEmpty;

  // ============================================================
  // GET NEARBY TEAMS
  // ============================================================

  Future<void> loadNearbyTeams({
    required double latitude,
    required double longitude,
    double radius = 20,
    String? search,
    String? gameType,
    String? skillLevel,
    String? city,
    bool onlyAvailable = false,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await _repository.getNearbyTeams(
        latitude: latitude,
        longitude: longitude,
        radius: radius,
        search: search,
        gameType: gameType,
        skillLevel: skillLevel,
        city: city,
        onlyAvailable: onlyAvailable,
      );

      _teams = result;
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // GET TEAM DETAILS
  // ============================================================

  Future<void> loadTeamDetails(
      int teamId,
      ) async {
    _isLoadingDetails = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final TeamDetailsModel result =
      await _repository.getTeamDetails(teamId);

      _selectedTeam = result.team;
      _teamMembers = result.members;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _teamMembers = [];
    } finally {
      _isLoadingDetails = false;

      notifyListeners();
    }
  }

  // ============================================================
  // GET MY TEAMS
  // ============================================================

  Future<void> loadMyTeams() async {
    _isLoadingMyTeams = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await _repository.getMyTeams();

      _myTeams = result;
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isLoadingMyTeams = false;

      notifyListeners();
    }
  }

  // ============================================================
  // REQUEST TO JOIN TEAM
  // ============================================================

  Future<bool> requestToJoinTeam(
      int teamId,
      ) async {
    _isJoiningTeam = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _repository.requestToJoinTeam(
        teamId,
      );

      // تحديث بيانات الفريق بعد إرسال الطلب
      if (_selectedTeam?.id == teamId) {
        _selectedTeam =
            _selectedTeam!.copyWith(
              hasPendingRequest: true,
            );
      }

      // تحديث القائمة لو الفريق موجود فيها
      final index = _teams.indexWhere(
            (team) => team.id == teamId,
      );

      if (index != -1) {
        _teams[index] =
            _teams[index].copyWith(
              hasPendingRequest: true,
            );
      }

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return false;
    } finally {
      _isJoiningTeam = false;

      notifyListeners();
    }
  }

  // ============================================================
  // GET JOIN REQUESTS
  // ============================================================

  Future<void> loadJoinRequests(
      int teamId,
      ) async {
    _isLoadingRequests = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await _repository.getJoinRequests(
        teamId,
      );

      _joinRequests = result;
    } catch (e) {
      _errorMessage = _cleanError(e);
    } finally {
      _isLoadingRequests = false;

      notifyListeners();
    }
  }

  // ============================================================
  // APPROVE JOIN REQUEST
  // ============================================================

  Future<bool> approveJoinRequest({
    required int teamId,
    required int requestId,
  }) async {
    _errorMessage = null;

    notifyListeners();

    try {
      await _repository.approveJoinRequest(
        teamId: teamId,
        requestId: requestId,
      );

      await loadJoinRequests(teamId);

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // REJECT JOIN REQUEST
  // ============================================================

  Future<bool> rejectJoinRequest({
    required int teamId,
    required int requestId,
  }) async {
    _errorMessage = null;

    notifyListeners();

    try {
      await _repository.rejectJoinRequest(
        teamId: teamId,
        requestId: requestId,
      );

      await loadJoinRequests(teamId);

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // CREATE TEAM
  // ============================================================

  Future<TeamModel?> createTeam({
    required String name,
    String? description,
    String? logo,
    String? gameType,
    String? skillLevel,
    String? city,
    int? maxPlayers,
    String? locationName,
    double? latitude,
    double? longitude,
  }) async {
    _isCreatingTeam = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final team =
      await _repository.createTeam(
        name: name,
        description: description,
        logo: logo,
        gameType: gameType,
        skillLevel: skillLevel,
        city: city,
        maxPlayers: maxPlayers,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
      );

      _myTeams = [
        ..._myTeams,
        team,
      ];

      return team;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return null;
    } finally {
      _isCreatingTeam = false;

      notifyListeners();
    }
  }

  // ============================================================
  // UPDATE TEAM
  // ============================================================

  Future<TeamModel?> updateTeam({
    required int teamId,
    String? name,
    String? description,
    String? logo,
    String? gameType,
    String? skillLevel,
    String? city,
    int? maxPlayers,
    String? locationName,
    double? latitude,
    double? longitude,
  }) async {
    _isUpdatingTeam = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final team =
      await _repository.updateTeam(
        teamId: teamId,
        name: name,
        description: description,
        logo: logo,
        gameType: gameType,
        skillLevel: skillLevel,
        city: city,
        maxPlayers: maxPlayers,
        locationName: locationName,
        latitude: latitude,
        longitude: longitude,
      );

      _selectedTeam = team;

      final index = _myTeams.indexWhere(
            (item) => item.id == teamId,
      );

      if (index != -1) {
        _myTeams[index] = team;
      }

      return team;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return null;
    } finally {
      _isUpdatingTeam = false;

      notifyListeners();
    }
  }

  // ============================================================
  // REMOVE PLAYER
  // ============================================================

  Future<bool> removePlayerFromTeam({
    required int teamId,
    required int playerId,
  }) async {
    _errorMessage = null;

    notifyListeners();

    try {
      await _repository.removePlayerFromTeam(
        teamId: teamId,
        playerId: playerId,
      );

      // تحديث تفاصيل الفريق بعد إزالة اللاعب
      await loadTeamDetails(teamId);

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      notifyListeners();

      return false;
    }
  }

  // ============================================================
  // LEAVE TEAM
  // ============================================================

  Future<bool> leaveTeam(
      int teamId,
      ) async {
    _isLeavingTeam = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _repository.leaveTeam(
        teamId,
      );

      _myTeams.removeWhere(
            (team) => team.id == teamId,
      );

      if (_selectedTeam?.id == teamId) {
        _selectedTeam = null;
      }

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return false;
    } finally {
      _isLeavingTeam = false;

      notifyListeners();
    }
  }

  // ============================================================
  // TRANSFER CAPTAINCY
  // ============================================================

  Future<bool> transferCaptaincy({
    required int teamId,
    required int newCaptainId,
  }) async {
    _isTransferringCaptaincy = true;
    _errorMessage = null;

    notifyListeners();

    try {
      await _repository.transferCaptaincy(
        teamId: teamId,
        newCaptainId: newCaptainId,
      );

      await loadTeamDetails(teamId);

      return true;
    } catch (e) {
      _errorMessage = _cleanError(e);

      notifyListeners();

      return false;
    } finally {
      _isTransferringCaptaincy = false;

      notifyListeners();
    }
  }

  // ============================================================
  // GET TEAM MESSAGES
  // ============================================================

  Future<void> loadTeamMessages(
      int teamId,
      ) async {
    _isLoadingMessages = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await _repository.getTeamMessages(
        teamId,
      );

      _teamMessages = result;
    } catch (e) {
      _errorMessage = _cleanError(e);
      _teamMessages = [];
    } finally {
      _isLoadingMessages = false;

      notifyListeners();
    }
  }

  // ============================================================
  // SEND TEAM MESSAGE
  // ============================================================

  Future<TeamMessageModel?> sendTeamMessage({
    required int teamId,
    required String message,
  }) async {
    final trimmedMessage = message.trim();

    if (trimmedMessage.isEmpty) {
      return null;
    }

    _isSendingMessage = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final sentMessage =
      await _repository.sendTeamMessage(
        teamId: teamId,
        message: trimmedMessage,
      );

      _teamMessages = [
        ..._teamMessages,
        sentMessage,
      ];

      return sentMessage;
    } catch (e) {
      _errorMessage = _cleanError(e);

      return null;
    } finally {
      _isSendingMessage = false;

      notifyListeners();
    }
  }

  // ============================================================
  // ADD INCOMING MESSAGE (SOCKET)
  // ============================================================

  void addIncomingMessage(TeamMessageModel message) {
    final exists = _teamMessages.any(
          (item) => item.id == message.id,
    );

    if (exists) return;

    _teamMessages = [
      ..._teamMessages,
      message,
    ];

    notifyListeners();
  }

  // ============================================================
  // CLEAR SELECTED TEAM
  // ============================================================

  void clearSelectedTeam() {
    _selectedTeam = null;
    _teamMembers = [];
    _joinRequests = [];
    _teamMessages = [];

    notifyListeners();
  }

  // ============================================================
  // CLEAR JOIN REQUESTS
  // ============================================================

  void clearJoinRequests() {
    _joinRequests = [];

    notifyListeners();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // ERROR HANDLING
  // ============================================================

  String _cleanError(Object error) {
    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.substring(
        'Exception: '.length,
      );
    }

    return message;
  }
}