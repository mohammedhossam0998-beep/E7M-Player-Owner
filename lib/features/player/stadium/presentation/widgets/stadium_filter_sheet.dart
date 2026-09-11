import 'package:flutter/material.dart';

class StadiumFilterResult {
  final String? city;
  final String? pitchType;
  final double? maxPrice;

  const StadiumFilterResult({
    this.city,
    this.pitchType,
    this.maxPrice,
  });

  StadiumFilterResult copyWith({
    String? city,
    String? pitchType,
    double? maxPrice,
    bool clearCity = false,
    bool clearPitchType = false,
    bool clearMaxPrice = false,
  }) {
    return StadiumFilterResult(
      city: clearCity ? null : (city ?? this.city),
      pitchType:
      clearPitchType ? null : (pitchType ?? this.pitchType),
      maxPrice:
      clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
    );
  }

  bool get hasFilters =>
      city != null ||
          pitchType != null ||
          maxPrice != null;
}

class StadiumFilterSheet extends StatefulWidget {
  final StadiumFilterResult initialFilter;
  final List<String> cities;
  final List<String> pitchTypes;
  final double? maximumPrice;

  const StadiumFilterSheet({
    super.key,
    this.initialFilter = const StadiumFilterResult(),
    this.cities = const [],
    this.pitchTypes = const [],
    this.maximumPrice,
  });

  @override
  State<StadiumFilterSheet> createState() =>
      _StadiumFilterSheetState();
}

class _StadiumFilterSheetState
    extends State<StadiumFilterSheet> {
  String? _selectedCity;
  String? _selectedPitchType;
  double? _selectedMaxPrice;

  static const Color primaryGreen =
  Color(0xFF7CC000);

  static const Color darkNavy =
  Color(0xFF1E1446);

  @override
  void initState() {
    super.initState();

    _selectedCity = widget.initialFilter.city;
    _selectedPitchType =
        widget.initialFilter.pitchType;
    _selectedMaxPrice =
        widget.initialFilter.maxPrice;
  }

  void _reset() {
    setState(() {
      _selectedCity = null;
      _selectedPitchType = null;
      _selectedMaxPrice = null;
    });
  }

  void _apply() {
    Navigator.of(context).pop(
      StadiumFilterResult(
        city: _selectedCity,
        pitchType: _selectedPitchType,
        maxPrice: _selectedMaxPrice,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxPrice =
        widget.maximumPrice ?? 1000;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 12,
          bottom:
          MediaQuery.of(context).viewInsets.bottom +
              20,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius:
                    BorderRadius.circular(10),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filter Stadiums',
                      style: TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: darkNavy,
                      ),
                    ),
                  ),

                  TextButton(
                    onPressed: _reset,
                    child: const Text(
                      'Reset',
                      style: TextStyle(
                        color: primaryGreen,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              if (widget.cities.isNotEmpty) ...[
                const Text(
                  'City',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: darkNavy,
                  ),
                ),

                const SizedBox(height: 10),

                DropdownButtonFormField<String>(
                  value: _selectedCity,
                  isExpanded: true,
                  decoration:
                  _inputDecoration(
                    'Select city',
                  ),
                  items: widget.cities
                      .where(
                        (city) =>
                    city.trim().isNotEmpty,
                  )
                      .map(
                        (city) =>
                        DropdownMenuItem<String>(
                          value: city,
                          child: Text(
                            city,
                            overflow:
                            TextOverflow.ellipsis,
                          ),
                        ),
                  )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCity = value;
                    });
                  },
                ),

                const SizedBox(height: 22),
              ],

              if (widget.pitchTypes.isNotEmpty) ...[
                const Text(
                  'Pitch Type',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: darkNavy,
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.pitchTypes
                      .where(
                        (type) =>
                    type.trim().isNotEmpty,
                  )
                      .map(
                        (type) {
                      final selected =
                          _selectedPitchType ==
                              type;

                      return ChoiceChip(
                        label: Text(type),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            _selectedPitchType =
                            selected
                                ? null
                                : type;
                          });
                        },
                        selectedColor:
                        primaryGreen
                            .withValues(
                          alpha: 0.20,
                        ),
                        checkmarkColor:
                        primaryGreen,
                        labelStyle: TextStyle(
                          fontWeight:
                          FontWeight.w700,
                          color: selected
                              ? darkNavy
                              : Colors
                              .grey
                              .shade700,
                        ),
                        side: BorderSide(
                          color: selected
                              ? primaryGreen
                              : Colors.grey
                              .shade300,
                        ),
                      );
                    },
                  )
                      .toList(),
                ),

                const SizedBox(height: 22),
              ],

              if (widget.maximumPrice != null) ...[
                const Text(
                  'Maximum Price',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: darkNavy,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _selectedMaxPrice == null
                      ? 'Any price'
                      : '${_selectedMaxPrice!.round()} EGP',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade600,
                  ),
                ),

                Slider(
                  value: (_selectedMaxPrice ??
                      maxPrice)
                      .clamp(0, maxPrice),
                  min: 0,
                  max: maxPrice,
                  divisions:
                  maxPrice > 0
                      ? 20
                      : null,
                  activeColor: primaryGreen,
                  inactiveColor:
                  Colors.grey.shade300,
                  label: _selectedMaxPrice == null
                      ? null
                      : '${_selectedMaxPrice!.round()} EGP',
                  onChanged: (value) {
                    setState(() {
                      _selectedMaxPrice =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 20),
              ],

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _apply,
                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    primaryGreen,
                    foregroundColor:
                    Colors.black,
                    elevation: 0,
                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Apply Filters',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
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

  InputDecoration _inputDecoration(
      String hint,
      ) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade50,
      contentPadding:
      const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryGreen,
          width: 1.5,
        ),
      ),
    );
  }
}