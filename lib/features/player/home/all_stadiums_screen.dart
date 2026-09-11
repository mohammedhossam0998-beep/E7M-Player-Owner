import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/features/player/stadium/presentation/providers/stadium_provider.dart';
import 'package:e7m/features/player/stadium/presentation/screens/stadium_details_screen.dart';

class AllStadiumsScreen extends StatefulWidget {
  const AllStadiumsScreen({super.key});

  @override
  State<AllStadiumsScreen> createState() => _AllStadiumsScreenState();
}

class _AllStadiumsScreenState extends State<AllStadiumsScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';

  static const Color primaryGreen = Color(0xff7CC000);
  static const Color background = Color(0xffF7F7F3);
  static const Color darkNavy = Color(0xff1E1446);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StadiumProvider>().loadStadiums();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();
    final t = languageProvider.translate;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t('all_stadiums'),
          style: const TextStyle(
            color: darkNavy,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Consumer<StadiumProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
              ),
            );
          }

          if (provider.errorMessage != null &&
              !provider.hasStadiums) {
            return _ErrorState(
              message: provider.errorMessage!,
              onRetry: provider.loadStadiums,
            );
          }

          final stadiums = provider.stadiums.where((stadium) {
            if (_searchQuery.trim().isEmpty) {
              return true;
            }

            final query = _searchQuery.toLowerCase();

            return stadium.name.toLowerCase().contains(query) ||
                (stadium.cityName?.toLowerCase().contains(query) ??
                    false) ||
                (stadium.address?.toLowerCase().contains(query) ??
                    false) ||
                (stadium.pitchType?.toLowerCase().contains(query) ??
                    false);
          }).toList();

          return RefreshIndicator(
            color: primaryGreen,
            onRefresh: provider.loadStadiums,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      16,
                    ),
                    child: _SearchField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      hintText: t('search_stadiums'),
                    ),
                  ),
                ),

                if (stadiums.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(
                      searchQuery: _searchQuery,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      0,
                      16,
                      24,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (context, index) {
                          final stadium = stadiums[index];

                          return _StadiumCard(
                            stadium: stadium,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      StadiumDetailsScreen(
                                        stadiumId: stadium.id,
                                      ),
                                ),
                              );
                            },
                          );
                        },
                        childCount: stadiums.length,
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

// ============================================================
// SEARCH FIELD
// ============================================================

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.hintText,
  });

  static const Color primaryGreen = Color(0xff7CC000);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        color: const Color(0xffEEF5E5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: primaryGreen,
          ),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, child) {
              if (value.text.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(
                  Icons.close,
                  size: 20,
                ),
              );
            },
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// STADIUM CARD
// ============================================================

class _StadiumCard extends StatelessWidget {
  final dynamic stadium;
  final VoidCallback onTap;

  const _StadiumCard({
    required this.stadium,
    required this.onTap,
  });

  static const Color primaryGreen = Color(0xff7CC000);
  static const Color darkNavy = Color(0xff1E1446);

  @override
  Widget build(BuildContext context) {
    final image = stadium.primaryImage;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(9),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StadiumImage(
                  image: image,
                ),

                const SizedBox(width: 13),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 4,
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                stadium.name,
                                maxLines: 2,
                                overflow:
                                TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                  color: darkNavy,
                                ),
                              ),
                            ),

                            const SizedBox(width: 6),

                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 15,
                              color: primaryGreen,
                            ),
                          ],
                        ),

                        const SizedBox(height: 7),

                        if (stadium.cityName != null ||
                            stadium.address != null)
                          Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 17,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  stadium.cityName ??
                                      stadium.address ??
                                      '',
                                  maxLines: 2,
                                  overflow:
                                  TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color:
                                    Colors.grey.shade600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),

                        const SizedBox(height: 9),

                        Row(
                          children: [
                            if (stadium.pitchType != null)
                              _SmallTag(
                                icon:
                                Icons.sports_soccer,
                                text:
                                stadium.pitchType!,
                              ),

                            if (stadium.capacity != null) ...[
                              const SizedBox(width: 6),
                              _SmallTag(
                                icon:
                                Icons.people_outline,
                                text:
                                '${stadium.capacity}',
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Text(
                              '${stadium.basePrice.toStringAsFixed(0)} EGP',
                              style: const TextStyle(
                                color: primaryGreen,
                                fontSize: 16,
                                fontWeight:
                                FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'per slot',
                              style: TextStyle(
                                color:
                                Colors.grey.shade500,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// IMAGE
// ============================================================

class _StadiumImage extends StatelessWidget {
  final String? image;

  const _StadiumImage({
    required this.image,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 120,
        height: 125,
        child: image == null || image!.isEmpty
            ? _placeholder()
            : Image.network(
          _imageUrl(image!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return _placeholder();
          },
          loadingBuilder: (
              context,
              child,
              progress,
              ) {
            if (progress == null) {
              return child;
            }

            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xff7CC000),
              ),
            );
          },
        ),
      ),
    );
  }

  String _imageUrl(String image) {
    if (image.startsWith('http://') ||
        image.startsWith('https://')) {
      return image;
    }

    return 'http://192.168.1.2:5000$image';
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.stadium_outlined,
        size: 42,
        color: Colors.grey.shade400,
      ),
    );
  }
}

// ============================================================
// SMALL TAG
// ============================================================

class _SmallTag extends StatelessWidget {
  final IconData icon;
  final String text;

  const _SmallTag({
    required this.icon,
    required this.text,
  });

  static const Color primaryGreen = Color(0xff7CC000);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: primaryGreen.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.circle,
            size: 4,
            color: primaryGreen,
          ),
          const SizedBox(width: 5),
          Icon(
            icon,
            size: 13,
            color: primaryGreen,
          ),
          const SizedBox(width: 3),
          Text(
            text,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyState extends StatelessWidget {
  final String searchQuery;

  const _EmptyState({
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              searchQuery.trim().isEmpty
                  ? Icons.stadium_outlined
                  : Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              searchQuery.trim().isEmpty
                  ? 'No stadiums available'
                  : 'No stadiums found',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR STATE
// ============================================================

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 58,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to load stadiums',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7CC000),
                foregroundColor: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}