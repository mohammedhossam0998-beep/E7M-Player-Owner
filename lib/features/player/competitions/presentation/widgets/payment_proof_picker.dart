import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:e7m/shared/localization/app_translations.dart';

class PaymentProofPicker extends StatefulWidget {
  const PaymentProofPicker({
    super.key,
    this.initialFile,
    required this.onFileSelected,
    this.onFileRemoved,
  });

  final File? initialFile;
  final ValueChanged<File?> onFileSelected;
  final VoidCallback? onFileRemoved;

  @override
  State<PaymentProofPicker> createState() => _PaymentProofPickerState();
}

class _PaymentProofPickerState extends State<PaymentProofPicker> {
  final ImagePicker _imagePicker = ImagePicker();

  File? _selectedFile;
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _selectedFile = widget.initialFile;
  }

  Future<void> _pickImage(ImageSource source) async {
    if (_isPicking) return;

    setState(() {
      _isPicking = true;
    });

    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2000,
        maxHeight: 2000,
      );

      if (!mounted) return;

      if (pickedFile == null) {
        return;
      }

      final file = File(pickedFile.path);

      setState(() {
        _selectedFile = file;
      });

      widget.onFileSelected(file);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to select payment proof: {error}'.trArgs({'error': error}),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPicking = false;
        });
      }
    }
  }

  Future<void> _showPickerOptions() async {
    if (_isPicking) return;

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: Text('Take Photo'.tr),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text('Choose From Gallery'.tr),
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              if (_selectedFile != null)
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text('Remove Proof'.tr),
                  onTap: () {
                    Navigator.of(sheetContext).pop();
                    _removeFile();
                  },
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _removeFile() {
    setState(() {
      _selectedFile = null;
    });

    widget.onFileSelected(null);
    widget.onFileRemoved?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Proof'.tr,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Upload a clear screenshot or photo of your payment.'.tr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _selectedFile == null
              ? _EmptyState(
            key: const ValueKey('empty'),
            isPicking: _isPicking,
            onTap: _showPickerOptions,
          )
              : _SelectedFileView(
            key: const ValueKey('selected'),
            file: _selectedFile!,
            isPicking: _isPicking,
            onChange: _showPickerOptions,
            onRemove: _removeFile,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    super.key,
    required this.isPicking,
    required this.onTap,
  });

  final bool isPicking;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: isPicking ? null : onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 28,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.outline,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 42,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 12),
            Text(
              isPicking
                  ? 'Selecting image...'.tr
                  : 'Add Payment Proof'.tr,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tap to take a photo or choose one from your gallery.'.tr,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isPicking ? null : onTap,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text('Choose Image'.tr),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectedFileView extends StatelessWidget {
  const _SelectedFileView({
    super.key,
    required this.file,
    required this.isPicking,
    required this.onChange,
    required this.onRemove,
  });

  final File file;
  final bool isPicking;
  final VoidCallback onChange;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Image.file(
              file,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    size: 42,
                    color: theme.colorScheme.error,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    file.path.split(Platform.pathSeparator).last,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Change'.tr,
                  onPressed: isPicking ? null : onChange,
                  icon: const Icon(Icons.edit_outlined),
                ),
                IconButton(
                  tooltip: 'Remove'.tr,
                  onPressed: isPicking ? null : onRemove,
                  icon: Icon(
                    Icons.delete_outline,
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}