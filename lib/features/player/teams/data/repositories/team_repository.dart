import '../../../../../core/network/api_client.dart';
import '../models/team_model.dart';
import '../models/team_details_model.dart';
import '../models/team_member_model.dart';
import '../models/team_message_model.dart';

class TeamRepository {
  final ApiClient _apiClient;

  TeamRepository({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // GET NEARBY TEAMS
  // ============================================================

  Future<List<TeamModel>> getNearbyTeams({
    required double latitude,
    required double longitude,
    double radius = 20,
    String? search,
    String? gameType,
    String? skillLevel,
    String? city,
    bool onlyAvailable = false,
  }) async {
    final queryParameters = <String, String>{
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'radius': radius.toString(),
    };

    if (search != null && search.trim().isNotEmpty) {
      queryParameters['search'] = search.trim();
    }

    if (gameType != null && gameType.isNotEmpty) {
      queryParameters['game_type'] = gameType;
    }

    if (skillLevel != null && skillLevel.isNotEmpty) {
      queryParameters['skill_level'] = skillLevel;
    }

    if (city != null && city.isNotEmpty) {
      queryParameters['city'] = city;
    }

    if (onlyAvailable) {
      queryParameters['only_available'] = 'true';
    }

    final query = Uri(queryParameters: queryParameters).query;

    final response = await _apiClient.get(
      '/player/teams/nearby?$query',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid nearby teams response');
    }

    final teamsData = response['teams'];

    if (teamsData is! List) {
      return [];
    }

    return teamsData
        .whereType<Map>()
        .map(
          (team) => TeamModel.fromJson(
        Map<String, dynamic>.from(team),
      ),
    )
        .toList();
  }

  // ============================================================
  // GET TEAM DETAILS
  // ============================================================

  Future<TeamDetailsModel> getTeamDetails(int teamId) async {
    final response = await _apiClient.get(
      '/player/teams/$teamId',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid team details response');
    }

    final teamData = response['team'];

    if (teamData is! Map) {
      throw Exception('Team data not found');
    }

    final teamJson = Map<String, dynamic>.from(teamData);

    final membersData = teamJson['members'];

    final members = membersData is List
        ? membersData
        .whereType<Map>()
        .map(
          (member) => TeamMemberModel.fromJson(
        Map<String, dynamic>.from(member),
      ),
    )
        .toList()
        : <TeamMemberModel>[];

    final team = TeamModel.fromJson(teamJson);

    return TeamDetailsModel(
      team: team,
      members: members,
    );
  }

  // ============================================================
  // GET MY TEAMS
  // ============================================================

  Future<List<TeamModel>> getMyTeams() async {
    final response = await _apiClient.get(
      '/player/teams/my',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid my teams response');
    }

    final teamsData = response['teams'];

    if (teamsData is! List) {
      return [];
    }

    return teamsData
        .whereType<Map>()
        .map(
          (team) => TeamModel.fromJson(
        Map<String, dynamic>.from(team),
      ),
    )
        .toList();
  }

  // ============================================================
  // CREATE TEAM
  // ============================================================

  Future<TeamModel> createTeam({
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
    final body = <String, dynamic>{
      'name': name,
    };

    if (description != null) {
      body['description'] = description;
    }

    if (logo != null) {
      body['logo'] = logo;
    }

    if (gameType != null) {
      body['game_type'] = gameType;
    }

    if (skillLevel != null) {
      body['skill_level'] = skillLevel;
    }

    if (city != null) {
      body['city'] = city;
    }

    if (maxPlayers != null) {
      body['max_players'] = maxPlayers;
    }

    if (locationName != null) {
      body['location_name'] = locationName;
    }

    if (latitude != null) {
      body['latitude'] = latitude;
    }

    if (longitude != null) {
      body['longitude'] = longitude;
    }

    final response = await _apiClient.post(
      '/player/teams',
      body,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid create team response');
    }

    final teamData = response['team'];

    if (teamData is! Map) {
      throw Exception('Created team data not found');
    }

    return TeamModel.fromJson(
      Map<String, dynamic>.from(teamData),
    );
  }

  // ============================================================
  // REQUEST TO JOIN TEAM
  // ============================================================

  Future<void> requestToJoinTeam(int teamId) async {
    await _apiClient.post(
      '/player/teams/$teamId/join',
      {},
    );
  }

  // ============================================================
  // GET JOIN REQUESTS
  // ============================================================

  Future<List<Map<String, dynamic>>> getJoinRequests(
      int teamId,
      ) async {
    final response = await _apiClient.get(
      '/player/teams/$teamId/join-requests',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid join requests response');
    }

    final requests = response['requests'];

    if (requests is! List) {
      return [];
    }

    return requests
        .whereType<Map>()
        .map(
          (request) => Map<String, dynamic>.from(request),
    )
        .toList();
  }

  // ============================================================
  // APPROVE JOIN REQUEST
  // ============================================================

  Future<void> approveJoinRequest({
    required int teamId,
    required int requestId,
  }) async {
    await _apiClient.patch(
      '/player/teams/$teamId/join-requests/$requestId',
      {
        'status': 'approved',
      },
    );
  }

  // ============================================================
  // REJECT JOIN REQUEST
  // ============================================================

  Future<void> rejectJoinRequest({
    required int teamId,
    required int requestId,
  }) async {
    await _apiClient.patch(
      '/player/teams/$teamId/join-requests/$requestId/reject',
      {},
    );
  }

  // ============================================================
  // UPDATE TEAM
  // ============================================================

  Future<TeamModel> updateTeam({
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
    final body = <String, dynamic>{};

    if (name != null) {
      body['name'] = name;
    }

    if (description != null) {
      body['description'] = description;
    }

    if (logo != null) {
      body['logo'] = logo;
    }

    if (gameType != null) {
      body['game_type'] = gameType;
    }

    if (skillLevel != null) {
      body['skill_level'] = skillLevel;
    }

    if (city != null) {
      body['city'] = city;
    }

    if (maxPlayers != null) {
      body['max_players'] = maxPlayers;
    }

    if (locationName != null) {
      body['location_name'] = locationName;
    }

    if (latitude != null) {
      body['latitude'] = latitude;
    }

    if (longitude != null) {
      body['longitude'] = longitude;
    }

    final response = await _apiClient.patch(
      '/player/teams/$teamId',
      body,
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid update team response');
    }

    final teamData = response['team'];

    if (teamData is! Map) {
      throw Exception('Updated team data not found');
    }

    return TeamModel.fromJson(
      Map<String, dynamic>.from(teamData),
    );
  }

  // ============================================================
  // REMOVE PLAYER FROM TEAM
  // ============================================================

  Future<void> removePlayerFromTeam({
    required int teamId,
    required int playerId,
  }) async {
    await _apiClient.delete(
      '/player/teams/$teamId/members/$playerId',
    );
  }

  // ============================================================
  // LEAVE TEAM
  // ============================================================

  Future<void> leaveTeam(int teamId) async {
    await _apiClient.delete(
      '/player/teams/$teamId/leave',
    );
  }

  // ============================================================
  // TRANSFER CAPTAINCY
  // ============================================================

  Future<void> transferCaptaincy({
    required int teamId,
    required int newCaptainId,
  }) async {
    await _apiClient.patch(
      '/player/teams/$teamId/captain',
      {
        'new_captain_id': newCaptainId,
      },
    );
  }

  // ============================================================
  // GET TEAM MESSAGES
  // ============================================================

  Future<List<TeamMessageModel>> getTeamMessages(int teamId) async {
    final response = await _apiClient.get(
      '/player/teams/$teamId/messages',
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid team messages response');
    }

    final messagesData = response['messages'];

    if (messagesData is! List) {
      return [];
    }

    return messagesData
        .whereType<Map>()
        .map(
          (message) => TeamMessageModel.fromJson(
        Map<String, dynamic>.from(message),
      ),
    )
        .toList();
  }

  // ============================================================
  // SEND TEAM MESSAGE
  // ============================================================

  Future<TeamMessageModel> sendTeamMessage({
    required int teamId,
    required String message,
  }) async {
    final trimmedMessage = message.trim();

    if (trimmedMessage.isEmpty) {
      throw Exception('Message cannot be empty');
    }

    final response = await _apiClient.post(
      '/player/teams/$teamId/messages',
      {
        'message': trimmedMessage,
      },
    );

    if (response is! Map<String, dynamic>) {
      throw Exception('Invalid send message response');
    }

    final messageData = response['data'];

    if (messageData is! Map) {
      throw Exception('Sent message data not found');
    }

    return TeamMessageModel.fromJson(
      Map<String, dynamic>.from(messageData),
    );
  }
}