import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/stadium_model.dart';
import '../../data/models/city_model.dart';
import '../providers/stadium_provider.dart';

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
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _capacityController = TextEditingController();
  final _basePriceController = TextEditingController();
  final _depositAmountController =
  TextEditingController();

  int? _selectedCityId;
  String? _selectedPitchType;

  final List<_PitchTypeOption> _pitchTypes = const [
    _PitchTypeOption(
      value: '5-a-side',
      label: '5 لاعبين',
    ),
    _PitchTypeOption(
      value: '7-a-side',
      label: '7 لاعبين',
    ),
    _PitchTypeOption(
      value: '6-a-side',
      label: '6 لاعب',
    ),
  ];

  @override
  void initState() {
    super.initState();

    // FIX: this callback must be `async` because we `await` inside it.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final provider = context.read<StadiumProvider>();
      await provider.fetchCities();

      if (!mounted || widget.stadium == null) return;

      final stadium = widget.stadium!;

      setState(() {
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
        _basePriceController.text =
            stadium.basePrice.toString();
        _depositAmountController.text =
            stadium.depositAmount.toString();
      });
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
    _basePriceController.dispose();
    _depositAmountController.dispose();

    super.dispose();
  }

  // ============================================================
  // SUBMIT
  // ============================================================

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedCityId == null) {
      _showMessage('من فضلك اختر المدينة');
      return;
    }

    if (_selectedPitchType == null) {
      _showMessage('من فضلك اختر نوع الملعب');
      return;
    }

    final capacity = int.tryParse(
      _capacityController.text.trim(),
    );

    final basePrice = double.tryParse(
      _basePriceController.text.trim(),
    );

    final depositAmount = double.tryParse(
      _depositAmountController.text.trim(),
    );

    final latitudeText = _latitudeController.text.trim();
    final longitudeText = _longitudeController.text.trim();

    final latitude = latitudeText.isEmpty
        ? null
        : double.tryParse(latitudeText);

    final longitude = longitudeText.isEmpty
        ? null
        : double.tryParse(longitudeText);

    if (capacity == null || capacity <= 0) {
      _showMessage('عدد اللاعبين غير صحيح');
      return;
    }

    if (basePrice == null || basePrice < 0) {
      _showMessage('السعر الأساسي غير صحيح');
      return;
    }

    if (depositAmount == null ||
        depositAmount < 0) {
      _showMessage('العربون غير صحيح');
      return;
    }

    if (latitudeText.isNotEmpty && latitude == null) {
      _showMessage('خط العرض غير صحيح');
      return;
    }

    if (longitudeText.isNotEmpty && longitude == null) {
      _showMessage('خط الطول غير صحيح');
      return;
    }

    final stadium = StadiumModel(
      id: widget.stadium?.id ?? 0,
      ownerId: widget.stadium?.ownerId ?? 0,
      cityId: _selectedCityId!,
      name: _nameController.text.trim(),
      description: _toNullable(_descriptionController.text),
      address: _toNullable(_addressController.text),
      latitude: latitude,
      longitude: longitude,
      pitchType: _selectedPitchType!,
      capacity: capacity,
      basePrice: basePrice,
      depositAmount: depositAmount,
      status: widget.stadium?.status ?? 'pending',
      createdAt: widget.stadium?.createdAt,
      updatedAt: widget.stadium?.updatedAt,
    );

    final provider = context.read<StadiumProvider>();

    if (widget.isEditMode) {
      final updated = await provider.updateStadium(
        widget.stadium!.id,
        stadium,
      );

      if (!mounted) return;

      if (updated != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تعديل الملعب بنجاح'),
          ),
        );

        Navigator.of(context).pop(true);
        return;
      }

      _showMessage(
        provider.errorMessage ??
            'حدث خطأ أثناء تعديل الملعب',
      );
      return;
    }

    final created = await provider.createStadium(stadium);

    if (!mounted) return;

    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم إنشاء الملعب بنجاح'),
        ),
      );

      Navigator.of(context).pop(true);
      return;
    }

    _showMessage(
      provider.errorMessage ??
          'حدث خطأ أثناء إنشاء الملعب',
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String? _toNullable(String value) {
    final text = value.trim();

    return text.isEmpty ? null : text;
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      appBar: AppBar(
        title: Text(
          widget.isEditMode ? 'تعديل الملعب' : 'إضافة ملعب',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff1E1446),
        elevation: 0,
      ),
      body: Consumer<StadiumProvider>(
        builder: (context, provider, _) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                20,
                20,
                40,
              ),
              children: [
                _SectionTitle(
                  title: widget.isEditMode
                      ? 'تعديل بيانات الملعب'
                      : 'بيانات الملعب',
                  subtitle: widget.isEditMode
                      ? 'عدّل البيانات المطلوبة ثم احفظ التغييرات.'
                      : 'أدخل البيانات الأساسية للملعب.',
                ),

                const SizedBox(height: 24),

                // =====================================================
                // NAME
                // =====================================================

                _Field(
                  controller: _nameController,
                  label: 'اسم الملعب',
                  hint: 'مثال: E7M Arena',
                  icon: Icons.stadium_rounded,
                  textInputAction:
                  TextInputAction.next,
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'اسم الملعب مطلوب';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // =====================================================
                // CITY
                // =====================================================

                _buildCityDropdown(provider),

                const SizedBox(height: 16),

                // =====================================================
                // PITCH TYPE
                // =====================================================

                DropdownButtonFormField<String>(
                  initialValue: _selectedPitchType,
                  decoration: _inputDecoration(
                    label: 'نوع الملعب',
                    icon:
                    Icons.sports_soccer_rounded,
                  ),
                  items: _pitchTypes.map(
                        (type) {
                      return DropdownMenuItem<String>(
                        value: type.value,
                        child: Text(type.label),
                      );
                    },
                  ).toList(),
                  onChanged: (provider.isCreating || provider.isUpdating)
                      ? null
                      : (value) {
                    setState(() {
                      _selectedPitchType =
                          value;
                    });
                  },
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty) {
                      return 'نوع الملعب مطلوب';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // =====================================================
                // CAPACITY
                // =====================================================

                _Field(
                  controller: _capacityController,
                  label: 'السعة',
                  hint: 'مثال: 10',
                  icon:
                  Icons.people_alt_rounded,
                  keyboardType:
                  TextInputType.number,
                  textInputAction:
                  TextInputAction.next,
                  validator: (value) {
                    final number = int.tryParse(
                      value?.trim() ?? '',
                    );

                    if (number == null ||
                        number <= 0) {
                      return 'أدخل سعة صحيحة';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // =====================================================
                // BASE PRICE
                // =====================================================

                _Field(
                  controller:
                  _basePriceController,
                  label: 'السعر الأساسي',
                  hint: 'مثال: 500',
                  icon:
                  Icons.payments_rounded,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction:
                  TextInputAction.next,
                  validator: (value) {
                    final number = double.tryParse(
                      value?.trim() ?? '',
                    );

                    if (number == null ||
                        number < 0) {
                      return 'أدخل سعرًا صحيحًا';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // =====================================================
                // DEPOSIT AMOUNT
                // =====================================================

                _Field(
                  controller: _depositAmountController,
                  label: 'العربون',
                  hint: 'مثال: 100',
                  icon: Icons.account_balance_wallet_rounded,
                  keyboardType:
                  const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    final number = double.tryParse(
                      value?.trim() ?? '',
                    );

                    if (number == null || number < 0) {
                      return 'أدخل عربونًا صحيحًا';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // =====================================================
                // ADDRESS
                // =====================================================

                _Field(
                  controller: _addressController,
                  label: 'العنوان',
                  hint: 'عنوان الملعب',
                  icon:
                  Icons.location_on_rounded,
                  maxLines: 2,
                  textInputAction:
                  TextInputAction.next,
                ),

                const SizedBox(height: 16),

                // =====================================================
                // LOCATION
                // =====================================================

                Row(
                  children: [
                    Expanded(
                      child: _Field(
                        controller:
                        _latitudeController,
                        label: 'Latitude',
                        hint: 'خط العرض',
                        icon:
                        Icons.my_location_rounded,
                        keyboardType:
                        const TextInputType
                            .numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        textInputAction:
                        TextInputAction.next,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Field(
                        controller:
                        _longitudeController,
                        label: 'Longitude',
                        hint: 'خط الطول',
                        icon:
                        Icons.explore_rounded,
                        keyboardType:
                        const TextInputType
                            .numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // =====================================================
                // DESCRIPTION
                // =====================================================

                _Field(
                  controller:
                  _descriptionController,
                  label: 'وصف الملعب',
                  hint:
                  'اكتب وصفًا مختصرًا للملعب',
                  icon:
                  Icons.description_rounded,
                  maxLines: 4,
                ),

                const SizedBox(height: 28),

                // =====================================================
                // CREATE BUTTON
                // =====================================================

                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed:
                    (provider.isCreating ||
                        provider.isUpdating)
                        ? null
                        : _submit,
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      const Color(0xff7CC000),
                      foregroundColor:
                      Colors.white,
                      disabledBackgroundColor:
                      Colors.grey.shade300,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                    child: (provider.isCreating ||
                        provider.isUpdating)
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : Text(
                      widget.isEditMode
                          ? 'حفظ التعديلات'
                          : 'إنشاء الملعب',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.w800,
                      ),
                    ),
                  ),
                ),

                // =====================================================
                // ERROR
                // =====================================================

                if (provider.errorMessage !=
                    null) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding:
                    const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.red
                          .withValues(alpha: 0.08),
                      borderRadius:
                      BorderRadius.circular(14),
                    ),
                    child: Text(
                      provider.errorMessage!,
                      style:
                      const TextStyle(
                        color: Colors.red,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
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
  // CITY DROPDOWN
  // ============================================================

  Widget _buildCityDropdown(
      StadiumProvider provider,
      ) {
    if (provider.isLoadingCities) {
      return Container(
        height: 56,
        padding:
        const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.location_city_rounded,
              color: Color(0xff7CC000),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'جاري تحميل المدن...',
              ),
            ),
            SizedBox(
              width: 20,
              height: 20,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
              ),
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
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color: Colors.red.shade200,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                provider.citiesErrorMessage ??
                    'فشل تحميل المدن',
                style:
                const TextStyle(
                  color: Colors.red,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed:
              provider.fetchCities,
              child: const Text(
                'إعادة المحاولة',
              ),
            ),
          ],
        ),
      );
    }

    if (provider.cities.isEmpty) {
      return Container(
        padding:
        const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.location_city_rounded,
              color: Color(0xff7CC000),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'لا توجد مدن متاحة',
              ),
            ),
          ],
        ),
      );
    }

    return DropdownButtonFormField<int>(
      initialValue: _selectedCityId,
      decoration: _inputDecoration(
        label: 'المدينة',
        icon:
        Icons.location_city_rounded,
      ),
      items: provider.cities.map(
            (CityModel city) {
          return DropdownMenuItem<int>(
            value: city.id,
            child: Text(
              city.name,
              overflow:
              TextOverflow.ellipsis,
            ),
          );
        },
      ).toList(),
      onChanged: (provider.isCreating || provider.isUpdating)
          ? null
          : (value) {
        setState(() {
          _selectedCityId = value;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'المدينة مطلوبة';
        }

        return null;
      },
    );
  }

  // ============================================================
  // INPUT DECORATION
  // ============================================================

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: const Color(0xff7CC000),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Color(0xff7CC000),
          width: 1.5,
        ),
      ),
      errorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder:
      OutlineInputBorder(
        borderRadius:
        BorderRadius.circular(16),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }
}

// ============================================================
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xff1E1446),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// FIELD
// ============================================================

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(
          icon,
          color: const Color(0xff7CC000),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        enabledBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),
        focusedBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Color(0xff7CC000),
            width: 1.5,
          ),
        ),
        errorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        focusedErrorBorder:
        OutlineInputBorder(
          borderRadius:
          BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PITCH TYPE OPTION
// ============================================================

class _PitchTypeOption {
  final String value;
  final String label;

  const _PitchTypeOption({
    required this.value,
    required this.label,
  });
}