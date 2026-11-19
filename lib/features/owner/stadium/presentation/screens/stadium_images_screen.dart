
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:e7m/core/network/api_client.dart';

import '../../data/models/stadium_image_model.dart';
import '../providers/stadium_provider.dart';

class StadiumImagesScreen extends StatefulWidget {
  final int stadiumId;
  final String stadiumName;

  const StadiumImagesScreen({
    super.key,
    required this.stadiumId,
    required this.stadiumName,
  });

  @override
  State<StadiumImagesScreen> createState() =>
      _StadiumImagesScreenState();
}

class _ImageToUpload {
  final Uint8List bytes;
  final String filename;

  const _ImageToUpload({
    required this.bytes,
    required this.filename,
  });
}

class _StadiumImagesScreenState
    extends State<StadiumImagesScreen> {
  static const Color _green = Color(0xFF7CC000);
  static const int _maxImages = 10;
  static const int _maxImageBytes = 5 * 1024 * 1024;

  final ImagePicker _picker = ImagePicker();
  final ApiClient _api = ApiClient();

  bool _uploading = false;
  int _completedUploads = 0;
  int _totalUploads = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.stadiumId <= 0) return;

      final provider = context.read<StadiumProvider>();

      provider.clearStadiumImages();
      provider.fetchStadiumImages(widget.stadiumId);
    });
  }

  bool _busy(StadiumProvider provider) =>
      _uploading ||
          provider.isLoadingImages ||
          provider.isUploadingImages ||
          provider.isDeletingImage ||
          provider.isSettingPrimaryImage;

  void _message(String text, {bool error = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          backgroundColor:
          error ? Colors.red.shade700 : _green,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // PREPARE IMAGE - WEB + MOBILE
  // ============================================================

  Future<_ImageToUpload?> _prepareImage(
      XFile file,
      int index,
      ) async {
    try {
      final bytes = await file.readAsBytes();

      if (bytes.isEmpty) return null;

      final decoded = img.decodeImage(bytes);

      if (decoded == null) return null;

      img.Image resized = decoded;

      if (decoded.width > 1600 ||
          decoded.height > 1600) {
        resized = decoded.width >= decoded.height
            ? img.copyResize(
          decoded,
          width: 1600,
        )
            : img.copyResize(
          decoded,
          height: 1600,
        );
      }

      var jpeg = img.encodeJpg(
        resized,
        quality: 85,
      );

      if (jpeg.length > _maxImageBytes) {
        jpeg = img.encodeJpg(
          resized,
          quality: 65,
        );
      }

      if (jpeg.isEmpty ||
          jpeg.length > _maxImageBytes) {
        return null;
      }

      return _ImageToUpload(
        bytes: Uint8List.fromList(jpeg),
        filename:
        'pitch_${widget.stadiumId}_${DateTime.now().microsecondsSinceEpoch}_$index.jpg',
      );
    } catch (error) {
      debugPrint(
        'STADIUM IMAGE PREPARE ERROR: $error',
      );
      return null;
    }
  }

  // ============================================================
  // PREVIEW BEFORE UPLOAD
  // ============================================================

  Future<bool> _showPreview(
      List<_ImageToUpload> images,
      ) async {
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Upload ${images.length} image(s)?',
        ),
        content: SizedBox(
          width: 420,
          height: 285,
          child: GridView.builder(
            itemCount: images.length,
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (_, index) => ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.memory(
                images[index].bytes,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Upload'),
          ),
        ],
      ),
    );

    return accepted == true;
  }

  // ============================================================
  // PICK AND UPLOAD IMAGES
  // ============================================================

  Future<void> _pickImages() async {
    final provider = context.read<StadiumProvider>();

    if (_busy(provider)) return;

    if (widget.stadiumId <= 0) {
      _message(
        'Invalid stadium ID. Open the stadium again.',
        error: true,
      );
      return;
    }

    if (provider.hasImagesError) {
      _message(
        'Refresh the images before uploading.',
        error: true,
      );
      return;
    }

    final remaining =
        _maxImages - provider.stadiumImages.length;

    if (remaining <= 0) {
      _message(
        'Maximum 10 images per stadium.',
        error: true,
      );
      return;
    }

    try {
      final selected = await _picker.pickMultiImage(
        imageQuality: 90,
      );

      if (!mounted || selected.isEmpty) return;

      final prepared = <_ImageToUpload>[];
      int skipped = 0;

      final toProcess =
      selected.take(remaining).toList();

      for (var i = 0; i < toProcess.length; i++) {
        final image = await _prepareImage(
          toProcess[i],
          i,
        );

        if (image != null) {
          prepared.add(image);
        } else {
          skipped++;
        }
      }

      if (!mounted) return;

      if (prepared.isEmpty) {
        _message(
          'Could not read these images. Try JPG or PNG under 5 MB.',
          error: true,
        );
        return;
      }

      final confirmed = await _showPreview(prepared);

      if (!mounted || !confirmed) return;

      setState(() {
        _uploading = true;
        _completedUploads = 0;
        _totalUploads = prepared.length;
      });

      String? uploadError;

      for (final image in prepared) {
        try {
          // Backend expects upload.array('images', 10).
          await _api.uploadBytes(
            '/owner/pitches/${widget.stadiumId}/images',
            bytes: image.bytes,
            filename: image.filename,
            fieldName: 'images',
          );

          if (mounted) {
            setState(() {
              _completedUploads++;
            });
          }
        } catch (error) {
          uploadError = error.toString();
          break;
        }
      }

      // Refresh the existing Provider after upload.
      await provider.fetchStadiumImages(
        widget.stadiumId,
      );

      if (!mounted) return;

      if (uploadError != null) {
        _message(
          'Uploaded $_completedUploads/${prepared.length}. $uploadError',
          error: true,
        );
      } else if (provider.hasImagesError) {
        _message(
          provider.imagesErrorMessage ??
              'Could not refresh the image list.',
          error: true,
        );
      } else {
        _message(
          'Uploaded $_completedUploads image(s) successfully.'
              '${skipped > 0 ? ' Skipped $skipped invalid image(s).' : ''}',
        );
      }
    } catch (error) {
      _message(
        'Could not select images: $error',
        error: true,
      );
    } finally {
      if (mounted) {
        setState(() {
          _uploading = false;
          _totalUploads = 0;
        });
      }
    }
  }

  // ============================================================
  // DELETE IMAGE
  // ============================================================

  Future<void> _deleteImage(
      StadiumImageModel image,
      ) async {
    final provider = context.read<StadiumProvider>();

    if (_busy(provider)) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete image?'),
        content: const Text(
          'This image will be removed from the stadium.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    final success = await provider.deleteStadiumImage(
      widget.stadiumId,
      image.id,
    );

    if (!mounted) return;

    _message(
      success
          ? 'Image deleted successfully.'
          : provider.imagesErrorMessage ??
          'Could not delete image.',
      error: !success,
    );
  }

  // ============================================================
  // SET PRIMARY IMAGE
  // ============================================================

  Future<void> _setPrimary(
      StadiumImageModel image,
      ) async {
    final provider = context.read<StadiumProvider>();

    if (image.isPrimary || _busy(provider)) return;

    final success =
    await provider.setPrimaryStadiumImage(
      widget.stadiumId,
      image.id,
    );

    if (!mounted) return;

    _message(
      success
          ? 'Main image updated.'
          : provider.imagesErrorMessage ??
          'Could not set main image.',
      error: !success,
    );
  }

  // ============================================================
  // IMAGE CARD
  // ============================================================

  Widget _imageCard(
      StadiumImageModel image,
      StadiumProvider provider,
      ) {
    final url = ApiClient.resolveMediaUrl(
      image.imageUrl,
    );

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 1,
      child: Stack(
        children: [
          Positioned.fill(
            child: url.isEmpty
                ? const Center(
              child: Icon(
                Icons.broken_image_outlined,
              ),
            )
                : Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
              const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 40,
                ),
              ),
            ),
          ),

          if (image.isPrimary)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      size: 15,
                      color: Colors.amber,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Primary',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          Positioned(
            top: 4,
            right: 4,
            child: PopupMenuButton<String>(
              enabled: !_busy(provider),
              onSelected: (choice) {
                if (choice == 'primary') {
                  _setPrimary(image);
                }
                if (choice == 'delete') {
                  _deleteImage(image);
                }
              },
              itemBuilder: (_) => [
                if (!image.isPrimary)
                  const PopupMenuItem(
                    value: 'primary',
                    child: Text('Set as Primary'),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _emptyState(
      StadiumProvider provider,
      ) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.photo_library_outlined,
                size: 62,
              ),
              const SizedBox(height: 12),
              const Text(
                'No images yet',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add photos so players can see your stadium.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: _busy(provider)
                    ? null
                    : _pickImages,
                icon: const Icon(
                  Icons.add_photo_alternate_outlined,
                ),
                label: const Text('Add First Image'),
              ),
            ],
          ),
        ),
      );

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _errorState(
      StadiumProvider provider,
      String message,
      ) =>
      Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 58,
              ),
              const SizedBox(height: 12),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: () =>
                    provider.fetchStadiumImages(
                      widget.stadiumId,
                    ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Consumer<StadiumProvider>(
      builder: (context, provider, _) {
        final busy = _busy(provider);

        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1E1446),
            title: Text('${widget.stadiumName} Images'),
            actions: [
              IconButton(
                tooltip: 'Refresh images',
                icon: const Icon(Icons.refresh),
                onPressed: busy || widget.stadiumId <= 0
                    ? null
                    : () => provider.fetchStadiumImages(
                  widget.stadiumId,
                ),
              ),
            ],
          ),

          body: widget.stadiumId <= 0
              ? const Center(
            child: Text(
              'Invalid stadium ID. Reopen it.',
            ),
          )
              : provider.isLoadingImages &&
              provider.stadiumImages.isEmpty
              ? const Center(
            child: CircularProgressIndicator(),
          )
              : provider.hasImagesError &&
              provider.stadiumImages.isEmpty
              ? _errorState(
            provider,
            provider.imagesErrorMessage ??
                'Could not load images.',
          )
              : RefreshIndicator(
            onRefresh: () =>
                provider.fetchStadiumImages(
                  widget.stadiumId,
                ),
            child: CustomScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      16,
                      18,
                      16,
                      10,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Stadium Images',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${provider.stadiumImages.length}/$_maxImages images',
                        ),

                        if (_uploading) ...[
                          const SizedBox(
                            height: 12,
                          ),
                          LinearProgressIndicator(
                            value: _totalUploads > 0
                                ? _completedUploads /
                                _totalUploads
                                : null,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            'Uploading $_completedUploads/$_totalUploads',
                          ),
                        ],

                        if (provider.hasImagesError) ...[
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            provider.imagesErrorMessage ??
                                '',
                            style: const TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                if (provider.stadiumImages.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _emptyState(provider),
                  )
                else
                  SliverPadding(
                    padding:
                    const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      90,
                    ),
                    sliver: SliverGrid(
                      delegate:
                      SliverChildBuilderDelegate(
                            (_, index) => _imageCard(
                          provider.stadiumImages[index],
                          provider,
                        ),
                        childCount:
                        provider.stadiumImages.length,
                      ),
                      gridDelegate:
                      const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 260,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.9,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          floatingActionButton:
          widget.stadiumId <= 0 ||
              provider.hasImagesError ||
              provider.stadiumImages.length >= _maxImages
              ? null
              : FloatingActionButton.extended(
            backgroundColor: _green,
            foregroundColor: Colors.white,
            onPressed: busy ? null : _pickImages,
            icon: const Icon(
              Icons.add_photo_alternate_outlined,
            ),
            label: Text(
              _uploading
                  ? 'Uploading...'
                  : 'Add Images',
            ),
          ),
        );
      },
    );
  }
}
