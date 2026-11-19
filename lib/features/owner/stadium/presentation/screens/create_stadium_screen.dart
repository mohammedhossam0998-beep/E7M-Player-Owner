
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../../data/models/city_model.dart';
import '../../data/models/stadium_model.dart';
import '../providers/stadium_provider.dart';
import 'stadium_images_screen.dart';
import 'stadium_location_picker_screen.dart';

class CreateStadiumScreen extends StatefulWidget {
  final StadiumModel? stadium;

  const CreateStadiumScreen({
    super.key,
    this.stadium,
  });

  bool get isEditMode => stadium != null;

  @override
  State<CreateStadiumScreen> createState() =>
      _CreateStadiumScreenState();
}

class _CreateStadiumScreenState
    extends State<CreateStadiumScreen> {
  static const Color _green = Color(0xFF7CC000);
  static const Color _navy = Color(0xFF1E1446);

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _priceController = TextEditingController();
  final _depositController = TextEditingController();

  int? _selectedCityId;
  String? _selectedPitchType;

  bool _saving = false;
  bool _locating = false;

  static const Map<String, String> _pitchTypes = {
    '5-a-side': '5 لاعبين',
    '6-a-side': '6 لاعبين',
    '7-a-side': '7 لاعبين',
  };

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    final stadium = widget.stadium;

    if (stadium != null) {
      _selectedCityId = stadium.cityId;
      _selectedPitchType = stadium.pitchType;

      _nameController.text = stadium.name;

      _descriptionController.text =
          stadium.description ?? '';

      _addressController.text =
          stadium.address ?? '';

      _latitudeController.text =
          stadium.latitude?.toString() ?? '';

      _longitudeController.text =
          stadium.longitude?.toString() ?? '';

      _capacityController.text =
          stadium.capacity.toString();

      _priceController.text =
          stadium.basePrice.toString();

      _depositController.text =
          stadium.depositAmount.toString();
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StadiumProvider>().fetchCities();
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _capacityController.dispose();
    _priceController.dispose();
    _depositController.dispose();

    super.dispose();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  double? _number(String value) {
    return double.tryParse(
      value.trim().replaceAll(',', '.'),
    );
  }

  String? _optional(String value) {
    final text = value.trim();
    return text.isEmpty ? null : text;
  }

  void _message(
      String message, {
        bool error = false,
      }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
          error ? Colors.red.shade700 : _navy,
        ),
      );
  }

  // ============================================================
  // USE CURRENT LOCATION
  // ============================================================

  Future<void> _useCurrentLocation() async {
    if (_locating || _saving) return;

    setState(() {
      _locating = true;
    });

    try {
      final enabled =
      await Geolocator.isLocationServiceEnabled();

      if (!enabled) {
        _message(
          'فعّل خدمات الموقع على جهازك أولًا.',
          error: true,
        );
        return;
      }

      var permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        _message(
          'لم يتم السماح بالوصول إلى الموقع.',
          error: true,
        );
        return;
      }

      if (permission ==
          LocationPermission.deniedForever) {
        _message(
          'إذن الموقع مرفوض نهائيًا. فعّله من إعدادات الجهاز.',
          error: true,
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
        _latitudeController.text =
            position.latitude.toStringAsFixed(6);

        _longitudeController.text =
            position.longitude.toStringAsFixed(6);
      });

      _message(
        'تم تحديد الموقع. تأكد أنه موقع الملعب نفسه.',
      );
    } catch (_) {
      _message(
        'تعذر تحديد الموقع. يمكنك إدخال الإحداثيات يدويًا.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _locating = false;
        });
      }
    }
  }

  // ============================================================
  // PICK LOCATION FROM MAP
  // ============================================================

  Future<void> _pickLocationOnMap() async {
    if (_saving || _locating) return;

    FocusScope.of(context).unfocus();

    final latitude = _number(
      _latitudeController.text,
    );

    final longitude = _number(
      _longitudeController.text,
    );

    final hasValidCoordinates =
        latitude != null &&
            longitude != null &&
            latitude.isFinite &&
            longitude.isFinite &&
            latitude >= -90 &&
            latitude <= 90 &&
            longitude >= -180 &&
            longitude <= 180;

    final point =
    await Navigator.of(context).push<LatLng>(
      MaterialPageRoute<LatLng>(
        builder: (_) => StadiumLocationPickerScreen(
          initialPoint: hasValidCoordinates
              ? LatLng(latitude, longitude)
              : null,
        ),
      ),
    );

    if (!mounted || point == null) return;

    setState(() {
      _latitudeController.text =
          point.latitude.toStringAsFixed(6);

      _longitudeController.text =
          point.longitude.toStringAsFixed(6);
    });

    _message(
      'تم تحديد موقع الملعب على الخريطة. احفظ البيانات لتأكيده.',
    );
  }

  // ============================================================
  // OPEN IMAGES
  // ============================================================

  Future<void> _openImages(
      int stadiumId,
      String stadiumName,
      ) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => StadiumImagesScreen(
          stadiumId: stadiumId,
          stadiumName: stadiumName,
        ),
      ),
    );
  }

  // ============================================================
  // CREATE / UPDATE STADIUM
  // ============================================================

  Future<void> _submit() async {
    if (_saving || _locating) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final availableCities =
        context.read<StadiumProvider>().cities;

    if (_selectedCityId == null ||
        !availableCities.any(
              (city) => city.id == _selectedCityId,
        )) {
      _message(
        'اختر مدينة صحيحة من القائمة أولًا.',
        error: true,
      );
      return;
    }

    if (_selectedPitchType == null) {
      _message(
        'اختر نوع الملعب.',
        error: true,
      );
      return;
    }

    final capacity = int.tryParse(
      _capacityController.text.trim(),
    );

    final price = _number(
      _priceController.text,
    );

    final deposit = _number(
      _depositController.text,
    );

    final latitude = _number(
      _latitudeController.text,
    );

    final longitude = _number(
      _longitudeController.text,
    );

    if (capacity == null ||
        capacity <= 0 ||
        price == null ||
        !price.isFinite ||
        price <= 0 ||
        deposit == null ||
        !deposit.isFinite ||
        deposit < 0 ||
        deposit > price ||
        latitude == null ||
        longitude == null ||
        !latitude.isFinite ||
        !longitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      _formKey.currentState!.validate();

      _message(
        'راجع بيانات السعر والعربون والموقع.',
        error: true,
      );
      return;
    }

    final stadium = StadiumModel(
      id: widget.stadium?.id ?? 0,
      ownerId: widget.stadium?.ownerId ?? 0,
      cityId: _selectedCityId!,
      name: _nameController.text.trim(),
      description:
      _optional(_descriptionController.text),
      address:
      _optional(_addressController.text),
      latitude: latitude,
      longitude: longitude,
      pitchType: _selectedPitchType!,
      capacity: capacity,
      basePrice: price,
      depositAmount: deposit,
      status: widget.stadium?.status ?? 'pending',
      createdAt: widget.stadium?.createdAt,
      updatedAt: widget.stadium?.updatedAt,
    );

    setState(() {
      _saving = true;
    });

    try {
      final provider =
      context.read<StadiumProvider>();

      // ========================================================
      // UPDATE STADIUM
      // ========================================================

      if (widget.isEditMode) {
        final updated =
        await provider.updateStadium(
          widget.stadium!.id,
          stadium,
        );

        if (!mounted) return;

        if (updated == null) {
          _message(
            provider.errorMessage ??
                'فشل تعديل الملعب.',
            error: true,
          );
          return;
        }

        _message(
          'تم حفظ التعديلات بنجاح.',
        );

        Navigator.of(context).pop(true);
        return;
      }

      // ========================================================
      // CREATE STADIUM
      // ========================================================

      final created =
      await provider.createStadium(stadium);

      if (!mounted) return;

      if (created == null) {
        _message(
          provider.errorMessage ??
              'فشل إنشاء الملعب.',
          error: true,
        );
        return;
      }

      // ========================================================
      // OFFER IMAGE UPLOAD
      // ========================================================

      final addImages = await showDialog<bool>(
        context: context,
        barrierDismissible: false,

        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              'تم إنشاء الملعب بنجاح',
            ),

            content: const Text(
              'تحب تضيف صور الملعب دلوقتي؟ '
                  'تقدر تضيفها لاحقًا من تفاصيل الملعب.',
            ),

            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    false,
                  );
                },

                child: const Text('لاحقًا'),
              ),

              FilledButton.icon(
                onPressed: () {
                  Navigator.pop(
                    dialogContext,
                    true,
                  );
                },

                icon: const Icon(
                  Icons.add_photo_alternate_outlined,
                ),

                label: const Text(
                  'إضافة الصور',
                ),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      if (addImages == true) {
        await _openImages(
          created.id,
          created.name,
        );

        if (!mounted) return;
      }

      Navigator.of(context).pop(true);
    } catch (_) {
      _message(
        'حدث خطأ غير متوقع. حاول مرة أخرى.',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
      const Color(0xFFF6F8FB),

      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: _navy,

        title: Text(
          widget.isEditMode
              ? 'تعديل الملعب'
              : 'إضافة ملعب',

          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),

        actions: [
          if (widget.isEditMode)
            IconButton(
              tooltip: 'إدارة الصور',

              icon: const Icon(
                Icons.photo_library_outlined,
              ),

              onPressed: _saving
                  ? null
                  : () {
                _openImages(
                  widget.stadium!.id,
                  widget.stadium!.name,
                );
              },
            ),
        ],
      ),

      body: Consumer<StadiumProvider>(
        builder: (context, provider, _) {
          final busy =
              _saving ||
                  provider.isCreating ||
                  provider.isUpdating;

          return Form(
            key: _formKey,

            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                36,
              ),

              children: [
                // ==============================================
                // BASIC DATA
                // ==============================================

                _section(
                  'البيانات الأساسية',
                  widget.isEditMode
                      ? 'عدّل البيانات المطلوبة واحفظ التغييرات.'
                      : 'أضف البيانات الرئيسية للملعب.',
                ),

                const SizedBox(height: 15),

                _field(
                  controller: _nameController,
                  label: 'اسم الملعب',
                  hint: 'مثال: E7M Arena',
                  icon: Icons.stadium_rounded,

                  validator: (value) {
                    if ((value?.trim().length ?? 0) < 3) {
                      return 'اكتب اسم الملعب (3 أحرف على الأقل)';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                _cityPicker(
                  provider,
                  busy,
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  key: ValueKey(
                    'type_$_selectedPitchType',
                  ),

                  initialValue:
                  _selectedPitchType,

                  isExpanded: true,

                  decoration: _decoration(
                    'نوع الملعب',
                    Icons.sports_soccer,
                  ),

                  items: {
                    ..._pitchTypes,

                    if (_selectedPitchType != null &&
                        !_pitchTypes.containsKey(
                          _selectedPitchType,
                        ))
                      _selectedPitchType!:
                      _selectedPitchType!,
                  }.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),

                  onChanged: busy
                      ? null
                      : (value) {
                    setState(() {
                      _selectedPitchType = value;
                    });
                  },

                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'اختر نوع الملعب';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                _field(
                  controller: _capacityController,
                  label: 'السعة',
                  hint: 'مثال: 10',
                  icon: Icons.groups_rounded,
                  keyboard: TextInputType.number,

                  validator: (value) {
                    final number = int.tryParse(
                      value?.trim() ?? '',
                    );

                    if (number == null ||
                        number <= 0) {
                      return 'أدخل عدد لاعبين صحيحًا';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 22),

                // ==============================================
                // PRICES
                // ==============================================

                _section(
                  'الأسعار والعربون',
                  'السعر لازم يكون أكبر من صفر، '
                      'والعربون لا يتجاوز السعر.',
                ),

                const SizedBox(height: 15),

                _field(
                  controller: _priceController,
                  label: 'السعر الأساسي (جنيه)',
                  hint: 'مثال: 500',
                  icon: Icons.payments_outlined,

                  keyboard:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  validator: (value) {
                    final number = _number(
                      value ?? '',
                    );

                    if (number == null ||
                        !number.isFinite ||
                        number <= 0) {
                      return 'السعر لازم يكون أكبر من صفر';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 12),

                _field(
                  controller: _depositController,
                  label: 'العربون (جنيه)',
                  hint: 'مثال: 100 أو 0',

                  icon:
                  Icons.account_balance_wallet_outlined,

                  keyboard:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),

                  validator: (value) {
                    final number = _number(
                      value ?? '',
                    );

                    final price = _number(
                      _priceController.text,
                    );

                    if (number == null ||
                        !number.isFinite ||
                        number < 0) {
                      return 'أدخل قيمة عربون صحيحة (صفر أو أكثر)';
                    }

                    if (price != null &&
                        price.isFinite &&
                        number > price) {
                      return 'العربون لا يمكن أن يزيد عن السعر';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 22),

                // ==============================================
                // LOCATION
                // ==============================================

                _section(
                  'الموقع والعنوان',
                  'اختر مكان الملعب على الخريطة أو '
                      'استخدم GPS، وتأكد من دقة العلامة.',
                ),

                const SizedBox(height: 15),

                _field(
                  controller: _addressController,
                  label: 'العنوان التفصيلي',

                  hint:
                  'الشارع والمنطقة وعلامة مميزة',

                  icon: Icons.location_on_outlined,
                  lines: 2,
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _field(
                        controller:
                        _latitudeController,

                        label: 'Latitude',
                        icon: Icons.my_location,

                        keyboard:
                        const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),

                        validator: (value) {
                          final number = _number(
                            value ?? '',
                          );

                          if (number == null ||
                              !number.isFinite ||
                              number < -90 ||
                              number > 90) {
                            return 'خط عرض غير صحيح';
                          }

                          return null;
                        },
                      ),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: _field(
                        controller:
                        _longitudeController,

                        label: 'Longitude',
                        icon: Icons.explore_outlined,

                        keyboard:
                        const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),

                        validator: (value) {
                          final number = _number(
                            value ?? '',
                          );

                          if (number == null ||
                              !number.isFinite ||
                              number < -180 ||
                              number > 180) {
                            return 'خط طول غير صحيح';
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // ==============================================
                // GPS BUTTON
                // ==============================================

                OutlinedButton.icon(
                  onPressed: busy || _locating
                      ? null
                      : _useCurrentLocation,

                  icon: _locating
                      ? const SizedBox(
                    width: 17,
                    height: 17,

                    child:
                    CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(
                    Icons.my_location_rounded,
                  ),

                  label: Text(
                    _locating
                        ? 'جاري تحديد الموقع...'
                        : 'استخدام موقعي الحالي',
                  ),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: _green,

                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 14,
                    ),

                    side: const BorderSide(
                      color: _green,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ==============================================
                // MAP PICKER BUTTON - NEW
                // ==============================================

                OutlinedButton.icon(
                  onPressed: busy || _locating
                      ? null
                      : _pickLocationOnMap,

                  icon: const Icon(
                    Icons.map_outlined,
                  ),

                  label: const Text(
                    'اختيار الموقع من الخريطة',
                  ),

                  style: OutlinedButton.styleFrom(
                    foregroundColor: _navy,

                    padding:
                    const EdgeInsets.symmetric(
                      vertical: 14,
                    ),

                    side: const BorderSide(
                      color: _navy,
                    ),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // ==============================================
                // DESCRIPTION
                // ==============================================

                _section(
                  'وصف الملعب',
                  'اختياري، ويساعد اللاعب يعرف مميزات الملعب.',
                ),

                const SizedBox(height: 15),

                _field(
                  controller:
                  _descriptionController,

                  label: 'وصف الملعب',

                  hint:
                  'الإضاءة، الأرضية، الخدمات المتاحة...',

                  icon: Icons.description_outlined,
                  lines: 4,
                ),

                const SizedBox(height: 25),

                // ==============================================
                // SAVE
                // ==============================================

                SizedBox(
                  height: 54,

                  child: ElevatedButton.icon(
                    onPressed: busy || _locating
                        ? null
                        : _submit,

                    icon: busy
                        ? const SizedBox(
                      width: 18,
                      height: 18,

                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Icon(
                      Icons.save_outlined,
                    ),

                    label: Text(
                      busy
                          ? 'جاري الحفظ...'
                          : widget.isEditMode
                          ? 'حفظ التعديلات'
                          : 'إنشاء الملعب',

                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                      ),
                    ),

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      foregroundColor:
                      Colors.white,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                if (provider.errorMessage != null) ...[
                  const SizedBox(height: 12),

                  Text(
                    provider.errorMessage!,

                    style: const TextStyle(
                      color: Colors.red,
                    ),

                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // CITY PICKER
  // ============================================================

  Widget _cityPicker(
      StadiumProvider provider,
      bool busy,
      ) {
    if (provider.isLoadingCities) {
      return const ListTile(
        tileColor: Colors.white,

        leading: Icon(
          Icons.location_city,
          color: _green,
        ),

        title: Text(
          'جاري تحميل المدن...',
        ),

        trailing: SizedBox(
          height: 18,
          width: 18,

          child: CircularProgressIndicator(
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (provider.hasCitiesError ||
        provider.cities.isEmpty) {
      return Card(
        child: ListTile(
          leading: const Icon(
            Icons.error_outline,
            color: Colors.red,
          ),

          title: Text(
            provider.citiesErrorMessage ??
                'المدن غير متاحة',
          ),

          trailing: TextButton(
            onPressed: provider.fetchCities,

            child: const Text(
              'إعادة المحاولة',
            ),
          ),
        ),
      );
    }

    final selectedExists =
    provider.cities.any(
          (city) => city.id == _selectedCityId,
    );

    return DropdownButtonFormField<int>(
      key: ValueKey(
        'city_$_selectedCityId',
      ),

      initialValue: selectedExists
          ? _selectedCityId
          : null,

      isExpanded: true,

      decoration: _decoration(
        'المدينة',
        Icons.location_city_outlined,
      ),

      items: provider.cities.map(
            (CityModel city) {
          return DropdownMenuItem<int>(
            value: city.id,

            child: Text(
              city.name,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ).toList(),

      onChanged: busy
          ? null
          : (value) {
        setState(() {
          _selectedCityId = value;
        });
      },

      validator: (value) {
        if (value == null) {
          return 'اختر المدينة';
        }

        return null;
      },
    );
  }

  // ============================================================
  // SECTION
  // ============================================================

  Widget _section(
      String title,
      String description,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Text(
          title,

          style: const TextStyle(
            color: _navy,
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 5),

        Text(
          description,

          style: TextStyle(
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // INPUT FIELD
  // ============================================================

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType? keyboard,
    int lines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: lines,
      keyboardType: keyboard,
      validator: validator,

      textInputAction: lines > 1
          ? TextInputAction.newline
          : TextInputAction.next,

      decoration: _decoration(
        label,
        icon,
      ).copyWith(
        hintText: hint,
      ),
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _decoration(
      String label,
      IconData icon,
      ) {
    OutlineInputBorder outline(
        Color color, [
          double width = 1,
        ]) {
      return OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(14),

        borderSide: BorderSide(
          color: color,
          width: width,
        ),
      );
    }

    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,

      prefixIcon: Icon(
        icon,
        color: _green,
      ),

      border: outline(
        Colors.grey.shade300,
      ),

      enabledBorder: outline(
        Colors.grey.shade300,
      ),

      focusedBorder: outline(
        _green,
        1.6,
      ),

      errorBorder: outline(
        Colors.red,
      ),

      focusedErrorBorder: outline(
        Colors.red,
        1.6,
      ),
    );
  }
}