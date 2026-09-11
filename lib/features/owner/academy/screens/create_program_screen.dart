import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/program_controller.dart';
import '../models/program_model.dart';

class CreateProgramScreen extends StatefulWidget {
  final int academyId;

  const CreateProgramScreen({
    super.key,
    required this.academyId,
  });

  @override
  State<CreateProgramScreen> createState() =>
      _CreateProgramScreenState();
}

class _CreateProgramScreenState
    extends State<CreateProgramScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController =
  TextEditingController();
  final _priceController = TextEditingController();
  final _durationController =
  TextEditingController();

  String? _selectedLevel;

  final List<String> _levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _durationController.dispose();

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

    final price = double.tryParse(
      _priceController.text.trim(),
    );

    final durationWeeks = int.tryParse(
      _durationController.text.trim(),
    );

    if (price == null || price < 0) {
      _showMessage('Enter a valid price');
      return;
    }

    if (durationWeeks == null ||
        durationWeeks <= 0) {
      _showMessage(
        'Enter a valid duration',
      );
      return;
    }

    final program = ProgramModel(
      id: 0,
      academyId: widget.academyId,
      name: _nameController.text.trim(),
      description:
      _nullable(_descriptionController.text),
      level: _selectedLevel,
      price: price,
      durationWeeks: durationWeeks,
    );

    final controller =
    context.read<ProgramController>();

    final created =
    await controller.createProgram(
      academyId: widget.academyId,
      program: program,
    );

    if (!mounted) return;

    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Program created successfully',
          ),
        ),
      );

      Navigator.of(context).pop(true);
      return;
    }

    _showMessage(
      controller.errorMessage ??
          'Failed to create program',
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
  // MESSAGE
  // ============================================================

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
      appBar: AppBar(
        title: const Text(
          'Create Program',
        ),
        centerTitle: true,
      ),

      body: Consumer<ProgramController>(
        builder: (
            context,
            controller,
            _,
            ) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ========================================================
                // NAME
                // ========================================================

                TextFormField(
                  controller:
                  _nameController,
                  enabled:
                  !controller.isCreating,
                  textInputAction:
                  TextInputAction.next,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Program Name',
                    hintText:
                    'Enter program name',
                    prefixIcon: Icon(
                      Icons.menu_book_outlined,
                    ),
                    border:
                    OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return
                        'Program name is required';
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
                  enabled:
                  !controller.isCreating,
                  maxLines: 4,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Description',
                    hintText:
                    'Enter program description',
                    prefixIcon: Icon(
                      Icons.description_outlined,
                    ),
                    border:
                    OutlineInputBorder(),
                    alignLabelWithHint:
                    true,
                  ),
                ),

                const SizedBox(height: 16),

                // ========================================================
                // LEVEL
                // ========================================================

                DropdownButtonFormField<String>(
                  initialValue:
                  _selectedLevel,
                  decoration:
                  const InputDecoration(
                    labelText: 'Level',
                    hintText:
                    'Select program level',
                    prefixIcon: Icon(
                      Icons
                          .signal_cellular_alt_rounded,
                    ),
                    border:
                    OutlineInputBorder(),
                  ),
                  items: _levels.map(
                        (level) {
                      return DropdownMenuItem<
                          String>(
                        value: level,
                        child: Text(level),
                      );
                    },
                  ).toList(),
                  onChanged:
                  controller.isCreating
                      ? null
                      : (value) {
                    setState(() {
                      _selectedLevel =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                // ========================================================
                // PRICE
                // ========================================================

                TextFormField(
                  controller:
                  _priceController,
                  enabled:
                  !controller.isCreating,
                  keyboardType:
                  const TextInputType
                      .numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction:
                  TextInputAction.next,
                  decoration:
                  const InputDecoration(
                    labelText: 'Price',
                    hintText:
                    'Example: 1500',
                    prefixIcon: Icon(
                      Icons
                          .payments_outlined,
                    ),
                    suffixText: 'EGP',
                    border:
                    OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final price =
                    double.tryParse(
                      value?.trim() ?? '',
                    );

                    if (price == null ||
                        price < 0) {
                      return
                        'Enter a valid price';
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // ========================================================
                // DURATION
                // ========================================================

                TextFormField(
                  controller:
                  _durationController,
                  enabled:
                  !controller.isCreating,
                  keyboardType:
                  TextInputType.number,
                  textInputAction:
                  TextInputAction.done,
                  decoration:
                  const InputDecoration(
                    labelText:
                    'Duration',
                    hintText:
                    'Example: 12',
                    prefixIcon: Icon(
                      Icons
                          .calendar_today_outlined,
                    ),
                    suffixText: 'weeks',
                    border:
                    OutlineInputBorder(),
                  ),
                  validator: (value) {
                    final duration =
                    int.tryParse(
                      value?.trim() ?? '',
                    );

                    if (duration == null ||
                        duration <= 0) {
                      return
                        'Enter a valid duration';
                    }

                    return null;
                  },
                  onFieldSubmitted: (_) {
                    if (!controller.isCreating) {
                      _submit();
                    }
                  },
                ),

                const SizedBox(height: 28),

                // ========================================================
                // CREATE BUTTON
                // ========================================================

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                    controller.isCreating
                        ? null
                        : _submit,
                    child:
                    controller.isCreating
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Create Program',
                    ),
                  ),
                ),

                // ========================================================
                // ERROR
                // ========================================================

                if (controller.hasError)
                  Padding(
                    padding:
                    const EdgeInsets.only(
                      top: 14,
                    ),
                    child: Text(
                      controller.errorMessage ??
                          'Something went wrong',
                      textAlign:
                      TextAlign.center,
                      style: const TextStyle(
                        color: Colors.red,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}