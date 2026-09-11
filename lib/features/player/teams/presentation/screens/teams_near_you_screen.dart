import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../../data/models/team_model.dart';
import '../providers/team_provider.dart';
import '../widgets/team_card.dart';
import '../widgets/team_empty_state.dart';
import '../widgets/team_filter_sheet.dart';
import 'team_details_screen.dart';

import 'package:e7m/shared/localization/language_provider.dart';

class TeamsNearYouScreen extends StatefulWidget {
  const TeamsNearYouScreen({
    super.key,
  });

  @override
  State<TeamsNearYouScreen> createState() =>
      _TeamsNearYouScreenState();
}

class _TeamsNearYouScreenState
    extends State<TeamsNearYouScreen> {
  static const Color primaryGreen =
  Color(0xff7CC000);

  static const Color darkNavy =
  Color(0xff1E1446);

  static const Color background =
  Color(0xffF7F7F3);

  final TextEditingController
  _searchController =
  TextEditingController();

  double? _latitude;
  double? _longitude;

  TeamFilterResult _filters =
  const TeamFilterResult(
    radius: 20,
  );

  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      if (!mounted) return;

      _loadTeams();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOAD TEAMS
  // ============================================================

  Future<void> _loadTeams() async {
    final position =
    await _getCurrentPosition();

    if (position == null ||
        !mounted) {
      return;
    }

    _latitude = position.latitude;
    _longitude = position.longitude;

    await _fetchTeams();
  }

  // ============================================================
  // FETCH TEAMS
  // ============================================================

  Future<void> _fetchTeams() async {
    if (_latitude == null ||
        _longitude == null) {
      return;
    }

    await context
        .read<TeamProvider>()
        .loadNearbyTeams(
      latitude: _latitude!,
      longitude: _longitude!,
      radius: _filters.radius,
      search:
      _searchController.text
          .trim()
          .isEmpty
          ? null
          : _searchController.text.trim(),
      gameType: _filters.gameType,
      skillLevel: _filters.skillLevel,
      city: _filters.city,
      onlyAvailable:
      _filters.onlyAvailable,
    );
  }

  // ============================================================
  // LOCATION
  // ============================================================

  Future<Position?> _getCurrentPosition() async {
    if (_isGettingLocation) {
      return null;
    }

    setState(() {
      _isGettingLocation = true;
    });

    try {
      final serviceEnabled =
      await Geolocator
          .isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showMessage(
          'Location services are disabled.',
        );

        return null;
      }

      var permission =
      await Geolocator.checkPermission();

      if (permission ==
          LocationPermission.denied) {
        permission =
        await Geolocator
            .requestPermission();

        if (permission ==
            LocationPermission.denied) {
          _showMessage(
            'Location permission was denied.',
          );

          return null;
        }
      }

      if (permission ==
          LocationPermission.deniedForever) {
        _showMessage(
          'Location permission is permanently denied. Please enable it from Settings.',
        );

        return null;
      }

      return await Geolocator
          .getCurrentPosition(
        locationSettings:
        const LocationSettings(
          accuracy:
          LocationAccuracy.high,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  // ============================================================
  // SEARCH
  // ============================================================

  Future<void> _onSearchSubmitted(
      String value,
      ) async {
    await _fetchTeams();
  }

  // ============================================================
  // FILTERS
  // ============================================================

  Future<void> _openFilters() async {
    final result =
    await TeamFilterSheet.show(
      context,
      initialFilter: _filters,
    );

    if (result == null ||
        !mounted) {
      return;
    }

    setState(() {
      _filters = result;
    });

    await _fetchTeams();
  }

  // ============================================================
  // CLEAR SEARCH
  // ============================================================

  Future<void> _clearSearch() async {
    _searchController.clear();

    setState(() {});

    await _fetchTeams();
  }

  // ============================================================
  // JOIN TEAM
  // ============================================================

  Future<void> _joinTeam(
      TeamModel team,
      String Function(String) t,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(
            borderRadius:
            BorderRadius.circular(18),
          ),
          title: Text(
            t('join_team'),
            style: const TextStyle(
              fontWeight:
              FontWeight.bold,
              color: darkNavy,
            ),
          ),
          content: Text(
            '${t('join_team_question')} ${team.name}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(false);
              },
              child: Text(
                t('cancel'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(
                  dialogContext,
                ).pop(true);
              },
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                primaryGreen,
                foregroundColor:
                Colors.white,
              ),
              child: Text(
                t('join'),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true ||
        !mounted) {
      return;
    }

    final success =
    await context
        .read<TeamProvider>()
        .requestToJoinTeam(
      team.id,
    );

    if (!mounted) {
      return;
    }

    final provider =
    context.read<TeamProvider>();

    if (success) {
      _showMessage(
        t('join_request_sent'),
      );
    } else {
      _showMessage(
        provider.errorMessage ??
            t('something_went_wrong'),
      );
    }
  }

  // ============================================================
  // TEAM DETAILS
  // ============================================================

  void _openTeamDetails(TeamModel team) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TeamDetailsScreen(
          teamId: team.id,
        ),
      ),
    );
  }

  // ============================================================
  // ACTIVE FILTERS COUNT
  // ============================================================

  int get _activeFiltersCount {
    int count = 0;

    if (_filters.radius != 20) {
      count++;
    }

    if (_filters.gameType != null) {
      count++;
    }

    if (_filters.skillLevel != null) {
      count++;
    }

    if (_filters.city != null) {
      count++;
    }

    if (_filters.onlyAvailable) {
      count++;
    }

    return count;
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================

  Widget _buildSearchBar(
      String Function(String) t,
      ) {
    final hasSearch =
        _searchController.text
            .trim()
            .isNotEmpty;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(17),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),

          const Icon(
            Icons.search_rounded,
            color: Colors.grey,
          ),

          const SizedBox(width: 10),

          Expanded(
            child: TextField(
              controller:
              _searchController,
              onChanged: (_) {
                setState(() {});
              },
              onSubmitted:
              _onSearchSubmitted,
              textInputAction:
              TextInputAction.search,
              decoration:
              InputDecoration(
                border: InputBorder.none,
                hintText:
                t('search_teams'),
                hintStyle:
                TextStyle(
                  color:
                  Colors.grey.shade500,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          if (hasSearch)
            IconButton(
              onPressed:
              _clearSearch,
              icon: const Icon(
                Icons.clear_rounded,
                color: Colors.grey,
              ),
            ),

          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed:
                _openFilters,
                icon: const Icon(
                  Icons
                      .tune_rounded,
                  color:
                  primaryGreen,
                ),
              ),

              if (_activeFiltersCount >
                  0)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 17,
                    height: 17,
                    alignment:
                    Alignment.center,
                    decoration:
                    const BoxDecoration(
                      color: darkNavy,
                      shape:
                      BoxShape.circle,
                    ),
                    child: Text(
                      '$_activeFiltersCount',
                      style:
                      const TextStyle(
                        color:
                        Colors.white,
                        fontSize: 9,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
      String Function(String) t,
      int teamsCount,
      ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                t('teams_near_you'),
                style:
                const TextStyle(
                  fontSize: 22,
                  fontWeight:
                  FontWeight.bold,
                  color: darkNavy,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                '$teamsCount ${t('teams_found')}',
                style: TextStyle(
                  fontSize: 13,
                  color:
                  Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),

        if (_latitude != null &&
            _longitude != null)
          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 7,
            ),
            decoration:
            BoxDecoration(
              color: primaryGreen
                  .withOpacity(0.10),
              borderRadius:
              BorderRadius.circular(
                12,
              ),
            ),
            child: const Row(
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Icon(
                  Icons
                      .location_on_rounded,
                  size: 16,
                  color:
                  primaryGreen,
                ),
                SizedBox(width: 4),
                Text(
                  'Nearby',
                  style:
                  TextStyle(
                    fontSize: 11,
                    fontWeight:
                    FontWeight.bold,
                    color: darkNavy,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ============================================================
  // LOADING
  // ============================================================

  Widget _buildLoading() {
    return const Center(
      child:
      CircularProgressIndicator(
        color: primaryGreen,
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
      String message,
      String Function(String) t,
      ) {
    return TeamEmptyState(
      icon:
      Icons.cloud_off_rounded,
      title:
      t('something_went_wrong'),
      message: message,
      buttonText:
      t('try_again'),
      onRetry: _loadTeams,
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty(
      String Function(String) t,
      ) {
    return TeamEmptyState(
      onRetry: _loadTeams,
    );
  }

  // ============================================================
  // TEAM LIST
  // ============================================================

  Widget _buildTeamList(
      TeamProvider provider,
      String Function(String) t,
      ) {
    return RefreshIndicator(
      color: primaryGreen,
      onRefresh: _fetchTeams,
      child: ListView.separated(
        padding:
        const EdgeInsets.only(
          top: 4,
          bottom: 24,
        ),
        itemCount:
        provider.teams.length,
        separatorBuilder:
            (_, __) =>
        const SizedBox(
          height: 12,
        ),
        itemBuilder:
            (context, index) {
          final team =
          provider.teams[index];

          return TeamCard(
            team: team,
            onTap: () =>
                _openTeamDetails(team),
            onJoin: () =>
                _joinTeam(team, t),
          );
        },
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content:
          Text(message),
          behavior:
          SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final t =
        context
            .read<LanguageProvider>()
            .translate;

    return Scaffold(
      backgroundColor:
      background,
      appBar: AppBar(
        backgroundColor:
        background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t('teams'),
          style:
          const TextStyle(
            color: darkNavy,
            fontWeight:
            FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/my-teams');
            },
            tooltip: t('my_teams'),
            icon: const Icon(
              Icons.groups_rounded,
              color: primaryGreen,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child:
        Consumer<TeamProvider>(
          builder: (
              context,
              provider,
              _,
              ) {
            final hasTeams =
                provider.hasTeams;

            final isInitialLoading =
                (_isGettingLocation ||
                    provider.isLoading) &&
                    !hasTeams;

            return Padding(
              padding:
              const EdgeInsets
                  .symmetric(
                horizontal: 16,
              ),
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),

                  _buildSearchBar(t),

                  const SizedBox(
                    height: 18,
                  ),

                  _buildHeader(
                    t,
                    provider.teams.length,
                  ),

                  const SizedBox(
                    height: 14,
                  ),

                  Expanded(
                    child:
                    isInitialLoading
                        ? _buildLoading()
                        : provider
                        .errorMessage !=
                        null &&
                        !hasTeams
                        ? _buildError(
                      provider
                          .errorMessage!,
                      t,
                    )
                        : !hasTeams
                        ? _buildEmpty(
                      t,
                    )
                        : _buildTeamList(
                      provider,
                      t,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}