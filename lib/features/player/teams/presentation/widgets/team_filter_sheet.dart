import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';

class TeamFilterResult {
  final double radius;
  final String? gameType;
  final String? skillLevel;
  final String? city;
  final bool onlyAvailable;

  const TeamFilterResult({
    required this.radius,
    this.gameType,
    this.skillLevel,
    this.city,
    this.onlyAvailable = false,
  });

  TeamFilterResult copyWith({
    double? radius,
    String? gameType,
    bool clearGameType = false,
    String? skillLevel,
    bool clearSkillLevel = false,
    String? city,
    bool clearCity = false,
    bool? onlyAvailable,
  }) {
    return TeamFilterResult(
      radius: radius ?? this.radius,
      gameType: clearGameType
          ? null
          : gameType ?? this.gameType,
      skillLevel: clearSkillLevel
          ? null
          : skillLevel ?? this.skillLevel,
      city: clearCity
          ? null
          : city ?? this.city,
      onlyAvailable:
      onlyAvailable ?? this.onlyAvailable,
    );
  }
}

class TeamFilterSheet extends StatefulWidget {
  final TeamFilterResult? initialFilter;

  const TeamFilterSheet({
    super.key,
    this.initialFilter,
  });

  static Future<TeamFilterResult?> show(
      BuildContext context, {
        TeamFilterResult? initialFilter,
      }) {
    return showModalBottomSheet<TeamFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return TeamFilterSheet(
          initialFilter: initialFilter,
        );
      },
    );
  }

  @override
  State<TeamFilterSheet> createState() =>
      _TeamFilterSheetState();
}

class _TeamFilterSheetState
    extends State<TeamFilterSheet> {
  static const Color primaryGreen =
  Color(0xff7CC000);

  static const Color darkNavy =
  Color(0xff1E1446);

  late double _radius;

  String? _gameType;
  String? _skillLevel;
  String? _city;

  bool _onlyAvailable = false;

  @override
  void initState() {
    super.initState();

    final initial = widget.initialFilter;

    _radius = initial?.radius ?? 20;

    _gameType = initial?.gameType;

    _skillLevel = initial?.skillLevel;

    _city = initial?.city;

    _onlyAvailable =
        initial?.onlyAvailable ?? false;
  }

  // ============================================================
  // RESET
  // ============================================================

  void _resetFilters() {
    setState(() {
      _radius = 20;
      _gameType = null;
      _skillLevel = null;
      _city = null;
      _onlyAvailable = false;
    });
  }

  // ============================================================
  // APPLY
  // ============================================================

  void _applyFilters() {
    Navigator.of(context).pop(
      TeamFilterResult(
        radius: _radius,
        gameType: _gameType,
        skillLevel: _skillLevel,
        city: _city,
        onlyAvailable: _onlyAvailable,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final t =
        context.read<LanguageProvider>().translate;

    return SafeArea(
      child: Container(
        constraints:
        const BoxConstraints(
          maxHeight: 700,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(26),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ==================================================
            // HEADER
            // ==================================================

            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                20,
                16,
                12,
                10,
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),

                  const Spacer(),

                  Text(
                    t('filters'),
                    style:
                    const TextStyle(
                      fontSize: 20,
                      fontWeight:
                      FontWeight.bold,
                      color: darkNavy,
                    ),
                  ),

                  const Spacer(),

                  TextButton(
                    onPressed: _resetFilters,
                    child: Text(
                      t('reset'),
                      style:
                      const TextStyle(
                        color: primaryGreen,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // ==================================================
            // CONTENT
            // ==================================================

            Flexible(
              child: SingleChildScrollView(
                padding:
                const EdgeInsets.fromLTRB(
                  20,
                  20,
                  20,
                  12,
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    // ==========================================
                    // DISTANCE
                    // ==========================================

                    _buildSectionTitle(
                      t('distance'),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(
                          Icons.near_me_outlined,
                          color: primaryGreen,
                          size: 20,
                        ),

                        const SizedBox(width: 8),

                        Text(
                          '${_radius.toInt()} km',
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            color: darkNavy,
                          ),
                        ),
                      ],
                    ),

                    Slider(
                      value: _radius,
                      min: 5,
                      max: 100,
                      divisions: 19,
                      activeColor:
                      primaryGreen,
                      inactiveColor:
                      Colors.grey.shade300,
                      label:
                      '${_radius.toInt()} km',
                      onChanged: (value) {
                        setState(() {
                          _radius = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    // ==========================================
                    // GAME TYPE
                    // ==========================================

                    _buildSectionTitle(
                      t('game_type'),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChoiceChip(
                          label: '5v5',
                          selected:
                          _gameType == '5v5',
                          onSelected: () {
                            setState(() {
                              _gameType =
                              _gameType == '5v5'
                                  ? null
                                  : '5v5';
                            });
                          },
                        ),
                        _buildChoiceChip(
                          label: '6v6',
                          selected:
                          _gameType == '6v6',
                          onSelected: () {
                            setState(() {
                              _gameType =
                              _gameType == '6v6'
                                  ? null
                                  : '6v6';
                            });
                          },
                        ),
                        _buildChoiceChip(
                          label: '7v7',
                          selected:
                          _gameType == '7v7',
                          onSelected: () {
                            setState(() {
                              _gameType =
                              _gameType == '7v7'
                                  ? null
                                  : '7v7';
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ==========================================
                    // SKILL LEVEL
                    // ==========================================

                    _buildSectionTitle(
                      t('skill_level'),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildChoiceChip(
                          label: t('beginner'),
                          selected:
                          _skillLevel ==
                              'Beginner',
                          onSelected: () {
                            setState(() {
                              _skillLevel =
                              _skillLevel ==
                                  'Beginner'
                                  ? null
                                  : 'Beginner';
                            });
                          },
                        ),
                        _buildChoiceChip(
                          label: t('intermediate'),
                          selected:
                          _skillLevel ==
                              'Intermediate',
                          onSelected: () {
                            setState(() {
                              _skillLevel =
                              _skillLevel ==
                                  'Intermediate'
                                  ? null
                                  : 'Intermediate';
                            });
                          },
                        ),
                        _buildChoiceChip(
                          label: t('advanced'),
                          selected:
                          _skillLevel ==
                              'Advanced',
                          onSelected: () {
                            setState(() {
                              _skillLevel =
                              _skillLevel ==
                                  'Advanced'
                                  ? null
                                  : 'Advanced';
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ==========================================
                    // CITY
                    // ==========================================

                    _buildSectionTitle(
                      t('city'),
                    ),

                    const SizedBox(height: 10),

                    DropdownButtonFormField<String>(
                      value: _city,
                      isExpanded: true,
                      decoration:
                      InputDecoration(
                        hintText:
                        t('select_city'),
                        prefixIcon:
                        const Icon(
                          Icons.location_city_outlined,
                        ),
                        filled: true,
                        fillColor:
                        const Color(
                          0xffF7F7F3,
                        ),
                        border:
                        OutlineInputBorder(
                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                          borderSide:
                          BorderSide.none,
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Alexandria',
                          child:
                          Text('Alexandria'),
                        ),
                        DropdownMenuItem(
                          value: 'Cairo',
                          child: Text('Cairo'),
                        ),
                        DropdownMenuItem(
                          value: 'Giza',
                          child: Text('Giza'),
                        ),
                        DropdownMenuItem(
                          value: 'Mansoura',
                          child:
                          Text('Mansoura'),
                        ),
                        DropdownMenuItem(
                          value: 'Tanta',
                          child: Text('Tanta'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _city = value;
                        });
                      },
                    ),

                    const SizedBox(height: 14),

                    // ==========================================
                    // AVAILABLE ONLY
                    // ==========================================

                    Container(
                      decoration:
                      BoxDecoration(
                        color:
                        const Color(
                          0xffF7F7F3,
                        ),
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),
                      child: SwitchListTile(
                        value: _onlyAvailable,
                        activeColor:
                        primaryGreen,
                        contentPadding:
                        const EdgeInsets
                            .symmetric(
                          horizontal: 14,
                        ),
                        secondary:
                        const Icon(
                          Icons
                              .person_add_alt_1_outlined,
                          color:
                          primaryGreen,
                        ),
                        title: Text(
                          t('only_available'),
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.w700,
                            color: darkNavy,
                          ),
                        ),
                        subtitle: Text(
                          t(
                            'show_teams_with_available_slots',
                          ),
                          style:
                          TextStyle(
                            color: Colors
                                .grey
                                .shade600,
                            fontSize: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _onlyAvailable =
                                value;
                          });
                        },
                      ),
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // ==================================================
            // APPLY BUTTON
            // ==================================================

            Padding(
              padding:
              const EdgeInsets.fromLTRB(
                20,
                8,
                20,
                18,
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    primaryGreen,
                    foregroundColor:
                    Colors.white,
                    elevation: 0,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        15,
                      ),
                    ),
                  ),
                  child: Text(
                    t('apply_filters'),
                    style:
                    const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
      String text,
      ) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: darkNavy,
      ),
    );
  }

  // ============================================================
  // CHOICE CHIP
  // ============================================================

  Widget _buildChoiceChip({
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
      selectedColor:
      primaryGreen.withOpacity(0.18),
      backgroundColor:
      const Color(0xffF7F7F3),
      side: BorderSide(
        color: selected
            ? primaryGreen
            : Colors.grey.shade300,
      ),
      labelStyle: TextStyle(
        color: selected
            ? darkNavy
            : Colors.grey.shade700,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      checkmarkColor: primaryGreen,
    );
  }
}