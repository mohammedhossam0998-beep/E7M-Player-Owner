import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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

class _StadiumImagesScreenState
    extends State<StadiumImagesScreen> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<StadiumProvider>()
          .fetchStadiumImages(widget.stadiumId);
    });
  }

  // ============================================================
  // PICK + PREPARE IMAGES
  // ============================================================

  Future<void> _pickImages() async {
    try {
      final pickedFiles =
      await _imagePicker.pickMultiImage(
        imageQuality: 85,
      );

      if (pickedFiles.isEmpty || !mounted) {
        return;
      }

      final provider =
      context.read<StadiumProvider>();

      final currentImages =
          provider.stadiumImages;

      final remainingSlots =
          10 - currentImages.length;

      if (remainingSlots <= 0) {
        _showMessage(
          'You can upload up to 10 images.',
          isError: true,
        );
        return;
      }

      final filesToProcess =
      pickedFiles.take(remainingSlots).toList();

      final preparedFiles = <File>[];

      for (final pickedFile in filesToProcess) {
        final preparedFile =
        await _prepareImageForUpload(
          pickedFile,
        );

        if (preparedFile != null) {
          preparedFiles.add(preparedFile);
        }
      }

      if (!mounted) {
        return;
      }

      if (preparedFiles.isEmpty) {
        _showMessage(
          'No valid images were selected.',
          isError: true,
        );
        return;
      }

      final success =
      await provider.uploadStadiumImages(
        widget.stadiumId,
        preparedFiles,
      );

      if (!mounted) {
        return;
      }

      if (success) {
        _showMessage(
          'Images uploaded successfully.',
        );
      } else {
        _showMessage(
          provider.imagesErrorMessage ??
              'Failed to upload images.',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      _showMessage(
        'Failed to prepare images.',
        isError: true,
      );
    }
  }

  // ============================================================
  // CONVERT IMAGE TO JPEG
  // ============================================================

  Future<File?> _prepareImageForUpload(
      XFile pickedFile,
      ) async {
    try {
      final originalFile =
      File(pickedFile.path);

      if (!await originalFile.exists()) {
        return null;
      }

      final bytes =
      await originalFile.readAsBytes();

      final decodedImage =
      img.decodeImage(bytes);

      if (decodedImage == null) {
        return null;
      }

      // --------------------------------------------------------
      // Temporary directory
      // --------------------------------------------------------

      final tempDirectory =
          Directory.systemTemp;

      final fileName =
          'stadium_${DateTime.now().microsecondsSinceEpoch}.jpg';

      final outputFile = File(
        '${tempDirectory.path}/$fileName',
      );

      // --------------------------------------------------------
      // Encode as JPEG
      // --------------------------------------------------------

      final jpegBytes =
      img.encodeJpg(
        decodedImage,
        quality: 90,
      );

      await outputFile.writeAsBytes(
        jpegBytes,
        flush: true,
      );

      return outputFile;
    } catch (e) {
      debugPrint(
        'IMAGE PREPARATION ERROR: $e',
      );

      return null;
    }
  }

  // ============================================================
  // DELETE IMAGE
  // ============================================================

  Future<void> _deleteImage(
      StadiumImageModel image,
      ) async {
    final confirmed =
    await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Delete Image',
          ),
          content: const Text(
            'Are you sure you want to delete this image?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Delete',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final provider =
    context.read<StadiumProvider>();

    final success =
    await provider.deleteStadiumImage(
      widget.stadiumId,
      image.id,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _showMessage(
        'Image deleted successfully.',
      );
    } else {
      _showMessage(
        provider.imagesErrorMessage ??
            'Failed to delete image.',
        isError: true,
      );
    }
  }

  // ============================================================
  // SET PRIMARY
  // ============================================================

  Future<void> _setPrimary(
      StadiumImageModel image,
      ) async {
    if (image.isPrimary) {
      return;
    }

    final provider =
    context.read<StadiumProvider>();

    final success =
    await provider.setPrimaryStadiumImage(
      widget.stadiumId,
      image.id,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      _showMessage(
        'Primary image updated.',
      );
    } else {
      _showMessage(
        provider.imagesErrorMessage ??
            'Failed to update primary image.',
        isError: true,
      );
    }
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior:
          SnackBarBehavior.floating,
        ),
      );
  }

  // ============================================================
  // IMAGE URL
  // ============================================================

  String _getImageUrl(String imageUrl) {
    final value = imageUrl.trim();

    if (value.isEmpty) {
      return '';
    }

    if (value.startsWith('http://') ||
        value.startsWith('https://')) {
      return value;
    }

    const baseUrl = 'http://192.168.1.2:5000';

    if (value.startsWith('/')) {
      return '$baseUrl$value';
    }

    return '$baseUrl/$value';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.stadiumName} Images',
        ),
      ),

      body: Consumer<StadiumProvider>(
        builder: (
            context,
            provider,
            child,
            ) {
          if (provider.isLoadingImages) {
            return const Center(
              child:
              CircularProgressIndicator(),
            );
          }

          if (provider.hasImagesError &&
              provider.stadiumImages.isEmpty) {
            return _buildErrorState(
              provider.imagesErrorMessage ??
                  'Failed to load images.',
            );
          }

          return RefreshIndicator(
            onRefresh: () {
              return provider
                  .fetchStadiumImages(
                widget.stadiumId,
              );
            },
            child: CustomScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _buildHeader(
                    provider,
                  ),
                ),
                if (provider.stadiumImages.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child:
                    _buildEmptyState(),
                  )
                else
                  SliverPadding(
                    padding:
                    const EdgeInsets.all(16),
                    sliver: SliverGrid(
                      delegate:
                      SliverChildBuilderDelegate(
                            (
                            context,
                            index,
                            ) {
                          final image =
                          provider
                              .stadiumImages[index];

                          return _buildImageCard(
                            image,
                          );
                        },
                        childCount:
                        provider
                            .stadiumImages
                            .length,
                      ),
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio:
                        0.85,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),

      floatingActionButton:
      Consumer<StadiumProvider>(
        builder: (
            context,
            provider,
            child,
            ) {
          final canUpload =
              provider.stadiumImages.length <
                  10;

          if (!canUpload) {
            return const SizedBox.shrink();
          }

          return FloatingActionButton.extended(
            onPressed:
            provider.isUploadingImages
                ? null
                : _pickImages,
            icon:
            provider.isUploadingImages
                ? const SizedBox(
              width: 20,
              height: 20,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
              ),
            )
                : const Icon(
              Icons
                  .add_photo_alternate,
            ),
            label: Text(
              provider.isUploadingImages
                  ? 'Uploading...'
                  : 'Add Images',
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildHeader(
      StadiumProvider provider,
      ) {
    return Padding(
      padding:
      const EdgeInsets.fromLTRB(
        16,
        20,
        16,
        4,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                const Text(
                  'Stadium Images',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${provider.stadiumImages.length}/10 images',
                  style: TextStyle(
                    color:
                    Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          if (provider.isUploadingImages)
            const SizedBox(
              width: 22,
              height: 22,
              child:
              CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGE CARD
  // ============================================================

  Widget _buildImageCard(
      StadiumImageModel image,
      ) {
    return Card(
      clipBehavior:
      Clip.antiAlias,
      elevation: 2,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              _getImageUrl(
                image.imageUrl,
              ),
              fit: BoxFit.cover,
              errorBuilder: (
                  context,
                  error,
                  stackTrace,
                  ) {
                return Container(
                  color:
                  Colors.grey.shade200,
                  child: const Center(
                    child: Icon(
                      Icons
                          .broken_image_outlined,
                      size: 42,
                    ),
                  ),
                );
              },
              loadingBuilder: (
                  context,
                  child,
                  loadingProgress,
                  ) {
                if (loadingProgress ==
                    null) {
                  return child;
                }

                return const Center(
                  child:
                  CircularProgressIndicator(),
                );
              },
            ),
          ),

          // PRIMARY BADGE
          if (image.isPrimary)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration:
                BoxDecoration(
                  color: Colors.black87,
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),
                child: const Row(
                  mainAxisSize:
                  MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Primary',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ACTION MENU
          Positioned(
            top: 8,
            right: 8,
            child:
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'primary') {
                  _setPrimary(image);
                }

                if (value == 'delete') {
                  _deleteImage(image);
                }
              },
              itemBuilder: (context) {
                return [
                  if (!image.isPrimary)
                    const PopupMenuItem(
                      value: 'primary',
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_outline,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'Set as Primary',
                          ),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                        ),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                ];
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY STATE
  // ============================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo_library_outlined,
              size: 72,
              color:
              Colors.grey.shade400,
            ),
            const SizedBox(height: 18),
            const Text(
              'No Images Yet',
              style: TextStyle(
                fontSize: 21,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add photos of your stadium so players can see it clearly.',
              textAlign:
              TextAlign.center,
              style: TextStyle(
                color:
                Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _pickImages,
              icon: const Icon(
                Icons
                    .add_photo_alternate,
              ),
              label: const Text(
                'Add First Image',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ERROR STATE
  // ============================================================

  Widget _buildErrorState(
      String message,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                context
                    .read<StadiumProvider>()
                    .fetchStadiumImages(
                  widget.stadiumId,
                );
              },
              child: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }
}