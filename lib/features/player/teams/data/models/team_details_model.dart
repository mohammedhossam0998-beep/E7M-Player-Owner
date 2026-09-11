import 'team_model.dart';
import 'team_member_model.dart';

class TeamDetailsModel {
  final TeamModel team;
  final List<TeamMemberModel> members;

  const TeamDetailsModel({
    required this.team,
    required this.members,
  });
}