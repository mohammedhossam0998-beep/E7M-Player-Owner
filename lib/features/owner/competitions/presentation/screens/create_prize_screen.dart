import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/competition_model.dart';
import '../providers/competition_provider.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class CreatePrizeScreen extends StatefulWidget {
  final CompetitionModel competition;

  const CreatePrizeScreen({
    super.key,
    required this.competition,
  });

  @override
  State<CreatePrizeScreen> createState() => _CreatePrizeScreenState();
}

class _CreatePrizeScreenState extends State<CreatePrizeScreen> {
  static const Color primaryColor = Color(0xff7CC000);
  static const Color darkColor = Color(0xff1E1446);

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _currencyController = TextEditingController();
  final _positionController = TextEditingController();

  String _prizeType = 'cash';

  final List<String> _prizeTypes = const [
    'cash',
    'trophy',
    'medal',
    'equipment',
    'other',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _amountController.dispose();
    _currencyController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  String _prizeTypeLabel(String value) {
    switch (value) {
      case 'cash':
        return 'Cash';

      case 'trophy':
        return 'Trophy';

      case 'medal':
        return 'Medal';

      case 'equipment':
        return 'Equipment';

      case 'other':
        return 'Other';

      default:
        return value;
    }
  }

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
        color: primaryColor,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryColor,
          width: 1.5,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Colors.red,
          width: 1.5,
        ),
      ),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Prize name is required';
    }

    return null;
  }

  String? _validateAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final amount = double.tryParse(value.trim());

    if (amount == null) {
      return 'Enter a valid amount';
    }

    if (amount < 0) {
      return 'Amount cannot be negative';
    }

    return null;
  }

  String? _validatePosition(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final position = int.tryParse(value.trim());

    if (position == null) {
      return 'Enter a valid position';
    }

    if (position <= 0) {
      return 'Position must be greater than 0';
    }

    return null;
  }

  Future<void> _createPrize() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    FocusScope.of(context).unfocus();

    final data = <String, dynamic>{
      'name': _nameController.text.trim(),
      'description':
      _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      'prize_type': _prizeType,
      'amount': _amountController.text.trim().isEmpty
          ? null
          : double.parse(
        _amountController.text.trim(),
      ),
      'currency':
      _currencyController.text.trim().isEmpty
          ? null
          : _currencyController.text.trim(),
      'position':
      _positionController.text.trim().isEmpty
          ? null
          : int.parse(
        _positionController.text.trim(),
      ),
    };

    final provider =
    context.read<CompetitionProvider>();

    final prize = await provider.createPrize(
      widget.competition.id,
      data,
    );

    if (!mounted) {
      return;
    }

    if (prize != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Prize created successfully',
          ),
        ),
      );

      Navigator.of(context).pop(prize);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          provider.errorMessage ??
              'Failed to create prize',
        ),
      ),
    );
  }

  Widget _buildPrizeTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prize Type',
          style: TextStyle(
            color: darkColor,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),

        const SizedBox(height: 10),

        DropdownButtonFormField<String>(
          initialValue: _prizeType,
          decoration: _inputDecoration(
            label: 'Prize Type',
            icon: Icons.emoji_events_outlined,
          ),
          items: _prizeTypes.map((type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(
                _prizeTypeLabel(type),
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() {
              _prizeType = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildCompetitionInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.20),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_outlined,
              color: primaryColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Competition',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  widget.competition.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<CompetitionProvider>();

    final languageProvider =
    context.watch<LanguageProvider>();

    final isArabic =
        languageProvider.locale.languageCode == 'ar';

    final isLoading = provider.isLoading;

    return Directionality(
      textDirection: isArabic
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xffF6F8FB),

        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: darkColor,
          elevation: 0,
          title: const Text(
            'Create Prize',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        body: SafeArea(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                16,
                18,
                16,
                30,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  _buildCompetitionInfo(),

                  const SizedBox(height: 24),

                  const Text(
                    'Prize Information',
                    style: TextStyle(
                      color: darkColor,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Add the prize details for this competition.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _nameController,
                    textInputAction:
                    TextInputAction.next,
                    textCapitalization:
                    TextCapitalization.words,
                    decoration: _inputDecoration(
                      label: 'Prize Name',
                      icon: Icons.card_giftcard_outlined,
                      hint: 'Enter prize name',
                    ),
                    validator: _validateName,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller:
                    _descriptionController,
                    maxLines: 4,
                    textCapitalization:
                    TextCapitalization.sentences,
                    decoration: _inputDecoration(
                      label: 'Description',
                      icon: Icons.description_outlined,
                      hint: 'Enter prize description',
                    ),
                  ),

                  const SizedBox(height: 16),

                  _buildPrizeTypeSelector(),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _amountController,
                    keyboardType:
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    textInputAction:
                    TextInputAction.next,
                    decoration: _inputDecoration(
                      label: 'Amount',
                      icon: Icons.payments_outlined,
                      hint: 'Optional',
                    ),
                    validator: _validateAmount,
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _currencyController,
                    textInputAction:
                    TextInputAction.next,
                    textCapitalization:
                    TextCapitalization.characters,
                    decoration: _inputDecoration(
                      label: 'Currency',
                      icon: Icons.currency_exchange,
                      hint: 'Optional',
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _positionController,
                    keyboardType:
                    TextInputType.number,
                    textInputAction:
                    TextInputAction.done,
                    decoration: _inputDecoration(
                      label: 'Position',
                      icon:
                      Icons.format_list_numbered,
                      hint: 'Optional',
                    ),
                    validator: _validatePosition,
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed:
                      isLoading ? null : _createPrize,
                      style:
                      ElevatedButton.styleFrom(
                        backgroundColor:
                        primaryColor,
                        foregroundColor:
                        Colors.white,
                        disabledBackgroundColor:
                        Colors.grey.shade300,
                        elevation: 0,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                        width: 23,
                        height: 23,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Create Prize',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                          FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}