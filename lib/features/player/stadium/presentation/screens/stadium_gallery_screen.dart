import 'package:flutter/material.dart';

import '../../data/models/stadium_image.dart';

class StadiumGalleryScreen extends StatefulWidget {
  final String stadiumName;
  final List<StadiumImage> images;
  final int initialIndex;

  const StadiumGalleryScreen({
    super.key,
    required this.stadiumName,
    required this.images,
    this.initialIndex = 0,
  });

  @override
  State<StadiumGalleryScreen> createState() =>
      _StadiumGalleryScreenState();
}

class _StadiumGalleryScreenState
    extends State<StadiumGalleryScreen> {
  late final PageController _pageController;
  late int _currentIndex;

  static const Color primaryGreen = Color(0xFF7CC000);

  @override
  void initState() {
    super.initState();

    _currentIndex = widget.initialIndex.clamp(
      0,
      widget.images.isEmpty
          ? 0
          : widget.images.length - 1,
    );

    _pageController = PageController(
      initialPage: _currentIndex,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ============================================================
  // IMAGE URL
  // ============================================================

  String _resolveImageUrl(String imageUrl) {
    if (imageUrl.startsWith('http://') ||
        imageUrl.startsWith('https://')) {
      return imageUrl;
    }

    return 'http://192.168.1.3:5000$imageUrl';
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(widget.stadiumName),
        ),
        body: const Center(
          child: _EmptyGallery(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.stadiumName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 16,
            ),
            child: Center(
              child: Text(
                '${_currentIndex + 1}/${widget.images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (_, index) {
                final imageUrl = _resolveImageUrl(
                  widget.images[index].imageUrl,
                );

                return InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Center(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (
                          context,
                          child,
                          loadingProgress,
                          ) {
                        if (loadingProgress == null) {
                          return child;
                        }

                        return const Center(
                          child: CircularProgressIndicator(
                            color: primaryGreen,
                          ),
                        );
                      },
                      errorBuilder: (
                          context,
                          error,
                          stackTrace,
                          ) {
                        return const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: Colors.white54,
                            size: 64,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          if (widget.images.length > 1)
            _buildThumbnails(),
        ],
      ),
    );
  }

  // ============================================================
  // THUMBNAILS
  // ============================================================

  Widget _buildThumbnails() {
    return SafeArea(
      top: false,
      child: Container(
        height: 86,
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),
          scrollDirection: Axis.horizontal,
          itemCount: widget.images.length,
          separatorBuilder: (_, __) =>
          const SizedBox(width: 10),
          itemBuilder: (_, index) {
            final isSelected =
                index == _currentIndex;

            final imageUrl = _resolveImageUrl(
              widget.images[index].imageUrl,
            );

            return GestureDetector(
              onTap: () {
                _pageController.animateToPage(
                  index,
                  duration: const Duration(
                    milliseconds: 300,
                  ),
                  curve: Curves.easeInOut,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(
                  milliseconds: 200,
                ),
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  borderRadius:
                  BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? primaryGreen
                        : Colors.white24,
                    width: isSelected ? 2.5 : 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius:
                  BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (
                        context,
                        error,
                        stackTrace,
                        ) {
                      return const Icon(
                        Icons.image_outlined,
                        color: Colors.white54,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY GALLERY
// ============================================================

class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.photo_library_outlined,
          color: Colors.white38,
          size: 64,
        ),
        SizedBox(height: 14),
        Text(
          'No images available',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}