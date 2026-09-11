import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/program_controller.dart';
import '../models/program_model.dart';

class EditProgramScreen extends StatefulWidget {
  final int academyId;
  final ProgramModel program;

  const EditProgramScreen({
    super.key,
    required this.academyId,
    required this.program,
  });

  @override
  State<EditProgramScreen> createState() =>
      _EditProgramScreenState();
}

class _EditProgramScreenState
    extends State<EditProgramScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _durationController;

  late String? _selectedLevel;

  final List<String> _levels = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(
      text: widget.program.name,
    );

    _descriptionController =
        TextEditingController(
          text: widget.program.description ?? '',
        );

    _priceController =
        TextEditingController(
          text: widget.program.price?.toString() ?? '',
        );

    _durationController =
        TextEditingController(
          text:
          widget.program.durationWeeks?.toString() ??
              '',
        );

    _selectedLevel =
        widget.program.level;
  }

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

    final updatedProgram =
    widget.program.copyWith(
      name: _nameController.text.trim(),
      description:
      _nullable(_descriptionController.text),
      level: _selectedLevel,
      price: price,
      durationWeeks: durationWeeks,
    );

    final controller =
    context.read<ProgramController>();

    final result =
    await controller.updateProgram(
      academyId: widget.academyId,
      programId: widget.program.id,
      program: updatedProgram,
    );

    if (!mounted) return;

    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Program updated successfully',
          ),
        ),
      );

      Navigator.of(context).pop(true);
      return;
    }

    _showMessage(
      controller.errorMessage ??
          'Failed to update program',
    );
  }

  String? _nullable(String value) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Program',
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
                TextFormField(
                  controller: _nameController,
                  enabled:
                  !controller.isUpdating,
                  decoration:
                  const InputDecoration(
                    labelText: 'Program Name',
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

                TextFormField(
                  controller:
                  _descriptionController,
                  enabled:
                  !controller.isUpdating,
                  maxLines: 4,
                  decoration:
                  const InputDecoration(
                    labelText: 'Description',
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

                DropdownButtonFormField<String>(
                  initialValue: _selectedLevel,
                  decoration:
                  const InputDecoration(
                    labelText: 'Level',
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
                  controller.isUpdating
                      ? null
                      : (value) {
                    setState(() {
                      _selectedLevel =
                          value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller:
                  _priceController,
                  enabled:
                  !controller.isUpdating,
                  keyboardType:
                  const TextInputType
                      .numberWithOptions(
                    decimal: true,
                  ),
                  decoration:
                  const InputDecoration(
                    labelText: 'Price',
                    prefixIcon: Icon(
                      Icons.payments_outlined,
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

                TextFormField(
                  controller:
                  _durationController,
                  enabled:
                  !controller.isUpdating,
                  keyboardType:
                  TextInputType.number,
                  decoration:
                  const InputDecoration(
                    labelText: 'Duration',
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
                ),

                const SizedBox(height: 28),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed:
                    controller.isUpdating
                        ? null
                        : _submit,
                    child:
                    controller.isUpdating
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Save Changes',
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