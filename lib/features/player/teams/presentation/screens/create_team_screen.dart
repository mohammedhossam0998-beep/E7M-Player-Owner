import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import '../providers/team_provider.dart';
import '../../data/models/team_model.dart';
import '../../../../../shared/localization/language_provider.dart';

class CreateTeamScreen extends StatefulWidget {
  /// null = Create mode
  /// team != null = Edit mode
  final TeamModel? team;

  const CreateTeamScreen({
    super.key,
    this.team,
  });

  bool get isEditMode => team != null;

  @override
  State<CreateTeamScreen> createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  static const Color primaryGreen = Color(0xff7CC000);
  static const Color darkNavy = Color(0xff1E1446);
  static const Color background = Color(0xffF7F7F3);

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cityController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxPlayersController = TextEditingController();

  String? _gameType;
  String? _skillLevel;

  double? _latitude;
  double? _longitude;

  bool _isGettingLocation = false;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.team != null;

  @override
  void initState() {
    super.initState();

    if (_isEditMode) {
      _fillFormFromTeam(widget.team!);
    }
  }

  void _fillFormFromTeam(TeamModel team) {
    _nameController.text = team.name;
    _descriptionController.text = team.description ?? '';
    _cityController.text = team.city ?? '';
    _locationController.text = team.locationName ?? '';
    _maxPlayersController.text =
        team.maxPlayers?.toString() ?? '';

    _gameType = team.gameType;
    _skillLevel = team.skillLevel;

    _latitude = team.latitude;
    _longitude = team.longitude;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cityController.dispose();
    _locationController.dispose();
    _maxPlayersController.dispose();
    super.dispose();
  }

  // ============================================================
  // LOCATION
  // ============================================================

  Future<void> _getCurrentLocation() async {
    if (_isGettingLocation) return;

    setState(() {
      _isGettingLocation = true;
    });

    try {
      final serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        _showMessage(
          'Location services are disabled.',
        );
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          _showMessage(
            'Location permission was denied.',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showMessage(
          'Location permission is permanently denied. '
              'Please enable it from Settings.',
        );
        return;
      }

      final position =
      await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      _showMessage(
        'Location selected successfully.',
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
  // CREATE / UPDATE TEAM
  // ============================================================

  Future<void> _submitTeam() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_gameType == null) {
      _showMessage(
        'Please select the game type.',
      );
      return;
    }

    if (_skillLevel == null) {
      _showMessage(
        'Please select the skill level.',
      );
      return;
    }

    final maxPlayers = int.tryParse(
      _maxPlayersController.text.trim(),
    );

    if (maxPlayers == null || maxPlayers <= 0) {
      _showMessage(
        'Please enter a valid maximum number of players.',
      );
      return;
    }

    // ----------------------------------------------------------
    // Prevent reducing max players below current members.
    // ----------------------------------------------------------

    if (_isEditMode) {
      final currentMembers =
          widget.team!.membersCount;

      if (maxPlayers < currentMembers) {
        _showMessage(
          'Maximum players cannot be less than the current number of members.',
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final provider = context.read<TeamProvider>();

      final description =
      _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim();

      final city =
      _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim();

      final locationName =
      _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim();

      TeamModel? result;

      // ========================================================
      // EDIT
      // ========================================================

      if (_isEditMode) {
        result = await provider.updateTeam(
          teamId: widget.team!.id,
          name: _nameController.text.trim(),
          description: description,
          gameType: _gameType,
          skillLevel: _skillLevel,
          city: city,
          maxPlayers: maxPlayers,
          locationName: locationName,
          latitude: _latitude,
          longitude: _longitude,
        );
      }

      // ========================================================
      // CREATE
      // ========================================================

      else {
        result = await provider.createTeam(
          name: _nameController.text.trim(),
          description: description,
          gameType: _gameType!,
          skillLevel: _skillLevel!,
          city: city,
          maxPlayers: maxPlayers,
          locationName: locationName,
          latitude: _latitude,
          longitude: _longitude,
        );
      }

      if (!mounted) return;

      if (result != null) {
        _showMessage(
          _isEditMode
              ? 'Team updated successfully.'
              : 'Team created successfully.',
        );

        Navigator.of(context).pop(result);
      } else {
        _showMessage(
          provider.errorMessage ??
              'Something went wrong.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  // ============================================================
  // INPUT
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(
        icon,
        color: primaryGreen,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: primaryGreen,
          width: 1.5,
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final t =
        context.watch<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          _isEditMode
              ? t('edit_team')
              : t('create_team'),
          style: const TextStyle(
            color: darkNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              12,
              16,
              30,
            ),
            children: [
              _buildIntro(t),

              const SizedBox(height: 20),

              // ==================================================
              // TEAM NAME
              // ==================================================

              TextFormField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration(
                  label: t('team_name'),
                  icon: Icons.groups_rounded,
                  hint: t('enter_team_name'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return t('team_name_required');
                  }

                  if (value.trim().length < 2) {
                    return t('team_name_too_short');
                  }

                  return null;
                },
              ),

              const SizedBox(height: 14),

              // ==================================================
              // DESCRIPTION
              // ==================================================

              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                textInputAction:
                TextInputAction.newline,
                decoration: _inputDecoration(
                  label: t('description'),
                  icon: Icons.description_outlined,
                  hint: t('enter_team_description'),
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // GAME TYPE
              // ==================================================

              _buildDropdown<String>(
                value: _gameType,
                label: t('game_type'),
                icon: Icons.sports_soccer,
                hint: t('select_game_type'),
                items: const [
                  DropdownMenuItem(
                    value: '5v5',
                    child: Text('5v5'),
                  ),
                  DropdownMenuItem(
                    value: '6v6',
                    child: Text('6v6'),
                  ),
                  DropdownMenuItem(
                    value: '7v7',
                    child: Text('7v7'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _gameType = value;
                  });
                },
              ),

              const SizedBox(height: 14),

              // ==================================================
              // SKILL LEVEL
              // ==================================================

              _buildDropdown<String>(
                value: _skillLevel,
                label: t('skill_level'),
                icon: Icons.bar_chart_rounded,
                hint: t('select_skill_level'),
                items: [
                  DropdownMenuItem(
                    value: 'Beginner',
                    child: Text(t('beginner')),
                  ),
                  DropdownMenuItem(
                    value: 'Intermediate',
                    child: Text(t('intermediate')),
                  ),
                  DropdownMenuItem(
                    value: 'Advanced',
                    child: Text(t('advanced')),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _skillLevel = value;
                  });
                },
              ),

              const SizedBox(height: 14),

              // ==================================================
              // MAX PLAYERS
              // ==================================================

              TextFormField(
                controller: _maxPlayersController,
                keyboardType: TextInputType.number,
                textInputAction:
                TextInputAction.next,
                decoration: _inputDecoration(
                  label: t('max_players'),
                  icon: Icons.people_alt_outlined,
                  hint: t('enter_max_players'),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return t('max_players_required');
                  }

                  final number =
                  int.tryParse(value.trim());

                  if (number == null ||
                      number <= 0) {
                    return t('invalid_max_players');
                  }

                  return null;
                },
              ),

              if (_isEditMode) ...[
                const SizedBox(height: 6),
                Padding(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  child: Text(
                    '${t('current_players')}: '
                        '${widget.team!.membersCount}',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // ==================================================
              // CITY
              // ==================================================

              TextFormField(
                controller: _cityController,
                textInputAction:
                TextInputAction.next,
                decoration: _inputDecoration(
                  label: t('city'),
                  icon:
                  Icons.location_city_outlined,
                  hint: t('enter_city'),
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // LOCATION NAME
              // ==================================================

              TextFormField(
                controller: _locationController,
                textInputAction:
                TextInputAction.done,
                decoration: _inputDecoration(
                  label: t('location_name'),
                  icon: Icons.place_outlined,
                  hint: t('enter_location_name'),
                ),
              ),

              const SizedBox(height: 14),

              // ==================================================
              // GPS LOCATION
              // ==================================================

              _buildLocationCard(t),

              const SizedBox(height: 24),

              // ==================================================
              // SUBMIT
              // ==================================================

              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed:
                  _isSubmitting
                      ? null
                      : _submitTeam,
                  icon: _isSubmitting
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Icon(
                    _isEditMode
                        ? Icons.save_rounded
                        : Icons.add_rounded,
                  ),
                  label: Text(
                    _isSubmitting
                        ? (_isEditMode
                        ? t('updating_team')
                        : t('creating_team'))
                        : (_isEditMode
                        ? t('update_team')
                        : t('create_team')),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INTRO
  // ============================================================

  Widget _buildIntro(
      String Function(String) t,
      ) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: primaryGreen.withValues(
          alpha: 0.10,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: primaryGreen,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _isEditMode
                  ? Icons.edit_rounded
                  : Icons.groups_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  _isEditMode
                      ? t('edit_your_team')
                      : t('create_your_team'),
                  style: const TextStyle(
                    color: darkNavy,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _isEditMode
                      ? t('edit_team_description')
                      : t('create_team_description'),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    height: 1.4,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // DROPDOWN
  // ============================================================

  Widget _buildDropdown<T>({
    required T? value,
    required String label,
    required IconData icon,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: _inputDecoration(
        label: label,
        icon: icon,
      ),
      hint: Text(hint),
    );
  }

  // ============================================================
  // LOCATION CARD
  // ============================================================

  Widget _buildLocationCard(
      String Function(String) t,
      ) {
    final hasLocation =
        _latitude != null &&
            _longitude != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.my_location_rounded,
                color: primaryGreen,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  t('team_location'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkNavy,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            hasLocation
                ? '${_latitude!.toStringAsFixed(6)}, '
                '${_longitude!.toStringAsFixed(6)}'
                : t('location_not_selected'),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isGettingLocation
                  ? null
                  : _getCurrentLocation,
              icon: _isGettingLocation
                  ? const SizedBox(
                width: 18,
                height: 18,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              )
                  : const Icon(
                Icons.gps_fixed_rounded,
              ),
              label: Text(
                hasLocation
                    ? t('update_location')
                    : t('use_current_location'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}