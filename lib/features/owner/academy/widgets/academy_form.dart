import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../stadium/presentation/providers/stadium_provider.dart';
import '../../stadium/data/models/stadium_model.dart';

class AcademyForm extends StatefulWidget {
  final String? initialName;
  final String? initialPhoneNumber;
  final String? initialDescription;
  final String? initialAddress;
  final String? initialCityId;
  final String? initialImageUrl;
  final String? initialPitchId;

  final bool isLoading;
  final String submitLabel;

  final void Function({
  required String name,
  required String phoneNumber,
  String? description,
  String? address,
  String? cityId,
  String? imageUrl,
  required String pitchId,
  }) onSubmit;

  const AcademyForm({
    super.key,
    this.initialName,
    this.initialPhoneNumber,
    this.initialDescription,
    this.initialAddress,
    this.initialCityId,
    this.initialImageUrl,
    this.initialPitchId,
    this.isLoading = false,
    required this.submitLabel,
    required this.onSubmit,
  });

  @override
  State<AcademyForm> createState() => _AcademyFormState();
}

class _AcademyFormState extends State<AcademyForm> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _addressController;
  late final TextEditingController _imageUrlController;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int? _selectedCityId;
  int? _selectedPitchId;

  bool _requestedData = false;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.initialName ?? '',
    );

    _phoneController = TextEditingController(
      text: widget.initialPhoneNumber ?? '',
    );

    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );

    _addressController = TextEditingController(
      text: widget.initialAddress ?? '',
    );

    _imageUrlController = TextEditingController(
      text: widget.initialImageUrl ?? '',
    );

    _selectedCityId = int.tryParse(
      widget.initialCityId ?? '',
    );

    _selectedPitchId = int.tryParse(
      widget.initialPitchId ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _imageUrlController.dispose();

    super.dispose();
  }

  // ============================================================
  // LOAD OWNER DATA
  // ============================================================

  void _loadOwnerData(
      StadiumProvider provider,
      ) {
    if (_requestedData) return;

    _requestedData = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      provider.fetchOwnerStadiums();
      provider.fetchCities();
    });
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCityId == null) {
      return;
    }

    if (_selectedPitchId == null) {
      return;
    }

    widget.onSubmit(
      name: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      description: _nullable(
        _descriptionController.text,
      ),
      address: _nullable(
        _addressController.text,
      ),
      cityId: _selectedCityId.toString(),
      imageUrl: _nullable(
        _imageUrlController.text,
      ),
      pitchId: _selectedPitchId.toString(),
    );
  }

  // ============================================================
  // NULLABLE
  // ============================================================

  String? _nullable(String value) {
    final text = value.trim();

    return text.isEmpty ? null : text;
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Consumer<StadiumProvider>(
      builder: (
          context,
          provider,
          _,
          ) {
        _loadOwnerData(provider);

        return Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.stretch,
            children: [
              // ========================================================
              // NAME
              // ========================================================

              TextFormField(
                controller: _nameController,
                enabled: !widget.isLoading,
                textInputAction:
                TextInputAction.next,
                decoration:
                const InputDecoration(
                  labelText: 'Academy Name',
                  hintText:
                  'Enter academy name',
                  prefixIcon: Icon(
                    Icons.school_outlined,
                  ),
                  border:
                  OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Academy name is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ========================================================
              // PHONE
              // ========================================================

              TextFormField(
                controller:
                _phoneController,
                enabled: !widget.isLoading,
                keyboardType:
                TextInputType.phone,
                textInputAction:
                TextInputAction.next,
                decoration:
                const InputDecoration(
                  labelText: 'Phone Number',
                  hintText:
                  'Enter phone number',
                  prefixIcon: Icon(
                    Icons.phone_outlined,
                  ),
                  border:
                  OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null ||
                      value.trim().isEmpty) {
                    return 'Phone number is required';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 16),

              // ========================================================
              // DESCRIPTION
              // ========================================================

              TextFormField(
                controller:
                _descriptionController,
                enabled: !widget.isLoading,
                maxLines: 4,
                decoration:
                const InputDecoration(
                  labelText: 'Description',
                  hintText:
                  'Enter academy description',
                  prefixIcon: Icon(
                    Icons.description_outlined,
                  ),
                  border:
                  OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 16),

              // ========================================================
              // ADDRESS
              // ========================================================

              TextFormField(
                controller:
                _addressController,
                enabled: !widget.isLoading,
                textInputAction:
                TextInputAction.next,
                decoration:
                const InputDecoration(
                  labelText: 'Address',
                  hintText:
                  'Enter academy address',
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                  ),
                  border:
                  OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // ========================================================
              // CITY
              // ============================================================

              _buildCityDropdown(provider),

              const SizedBox(height: 16),

              // ========================================================
              // IMAGE URL
              // ========================================================

              TextFormField(
                controller:
                _imageUrlController,
                enabled: !widget.isLoading,
                keyboardType:
                TextInputType.url,
                decoration:
                const InputDecoration(
                  labelText: 'Image URL',
                  hintText:
                  'Enter image URL',
                  prefixIcon: Icon(
                    Icons.image_outlined,
                  ),
                  border:
                  OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              // ========================================================
              // PITCH
              // ========================================================

              DropdownButtonFormField<int>(
                initialValue:
                _selectedPitchId,
                isExpanded: true,
                decoration:
                const InputDecoration(
                  labelText: 'Pitch',
                  hintText:
                  'Select your pitch',
                  prefixIcon: Icon(
                    Icons.sports_soccer_outlined,
                  ),
                  border:
                  OutlineInputBorder(),
                ),
                items: provider.stadiums
                    .map(
                      (StadiumModel stadium) {
                    return DropdownMenuItem<int>(
                      value: stadium.id,
                      child: Text(
                        stadium.name,
                        overflow:
                        TextOverflow.ellipsis,
                      ),
                    );
                  },
                )
                    .toList(),
                onChanged:
                widget.isLoading ||
                    provider.isLoading
                    ? null
                    : (value) {
                  setState(() {
                    _selectedPitchId =
                        value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select a pitch';
                  }

                  return null;
                },
              ),

              if (provider.isLoading)
                const Padding(
                  padding:
                  EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        height: 16,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Loading data...',
                      ),
                    ],
                  ),
                ),

              // ========================================================
              // STADIUM ERROR
              // ========================================================

              if (provider.hasError)
                Padding(
                  padding:
                  const EdgeInsets.only(
                    top: 8,
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          provider.errorMessage ??
                              'Failed to load pitches',
                        ),
                      ),
                      TextButton(
                        onPressed:
                        provider.isLoading
                            ? null
                            : () {
                          context
                              .read<
                              StadiumProvider>()
                              .fetchOwnerStadiums();
                        },
                        child: const Text(
                          'Retry',
                        ),
                      ),
                    ],
                  ),
                ),

              // ========================================================
              // NO PITCHES
              // ========================================================

              if (!provider.isLoading &&
                  !provider.hasError &&
                  provider.stadiums.isEmpty)
                Padding(
                  padding:
                  const EdgeInsets.only(
                    top: 8,
                  ),
                  child: Text(
                    'No pitches found for your account.',
                    style: TextStyle(
                      color:
                      Colors.grey.shade600,
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              // ========================================================
              // SUBMIT
              // ========================================================

              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed:
                  widget.isLoading
                      ? null
                      : _submit,
                  child: widget.isLoading
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    widget.submitLabel,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================================================
  // CITY DROPDOWN
  // ============================================================

  Widget _buildCityDropdown(
      StadiumProvider provider,
      ) {
    if (provider.isLoadingCities) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'City',
          prefixIcon: Icon(
            Icons.location_city_outlined,
          ),
          border:
          OutlineInputBorder(),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Loading cities...',
            ),
          ],
        ),
      );
    }

    if (provider.hasCitiesError) {
      return Container(
        padding:
        const EdgeInsets.all(14),
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.red.shade200,
          ),
          borderRadius:
          BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                provider.citiesErrorMessage ??
                    'Failed to load cities',
              ),
            ),
            TextButton(
              onPressed:
              provider.isLoadingCities
                  ? null
                  : provider.fetchCities,
              child:
              const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (provider.cities.isEmpty) {
      return const InputDecorator(
        decoration: InputDecoration(
          labelText: 'City',
          prefixIcon: Icon(
            Icons.location_city_outlined,
          ),
          border:
          OutlineInputBorder(),
        ),
        child: Text(
          'No cities available',
        ),
      );
    }

    return DropdownButtonFormField<int>(
      initialValue: _selectedCityId,
      isExpanded: true,
      decoration:
      const InputDecoration(
        labelText: 'City',
        hintText: 'Select your city',
        prefixIcon: Icon(
          Icons.location_city_outlined,
        ),
        border:
        OutlineInputBorder(),
      ),
      items: provider.cities
          .map(
            (city) {
          return DropdownMenuItem<int>(
            value: city.id,
            child: Text(
              city.name,
              overflow:
              TextOverflow.ellipsis,
            ),
          );
        },
      )
          .toList(),
      onChanged:
      widget.isLoading ||
          provider.isLoadingCities
          ? null
          : (value) {
        setState(() {
          _selectedCityId = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a city';
        }

        return null;
      },
    );
  }
}