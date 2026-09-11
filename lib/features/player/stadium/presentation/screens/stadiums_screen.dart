import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/stadium_provider.dart';
import '../widgets/stadium_card.dart';
import '../widgets/stadium_filter_sheet.dart';
import '../widgets/stadium_loading_skeleton.dart';
import '../widgets/stadium_search_bar.dart';
import 'stadium_details_screen.dart';

class StadiumsScreen extends StatefulWidget {
  const StadiumsScreen({super.key});

  @override
  State<StadiumsScreen> createState() => _StadiumsScreenState();
}

class _StadiumsScreenState extends State<StadiumsScreen> {
  String _searchQuery = '';
  StadiumFilterResult _filter = const StadiumFilterResult();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<StadiumProvider>().loadStadiums();
    });
  }

  Future<void> _openFilters() async {
    final provider = context.read<StadiumProvider>();

    final cities = provider.stadiums
        .map((stadium) => stadium.cityName)
        .whereType<String>()
        .where((city) => city.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final pitchTypes = provider.stadiums
        .map((stadium) => stadium.pitchType)
        .whereType<String>()
        .where((type) => type.trim().isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final prices = provider.stadiums
        .map((stadium) => stadium.basePrice)
        .where((price) => price > 0)
        .toList();

    final maximumPrice =
    prices.isEmpty ? null : prices.reduce((a, b) => a > b ? a : b);

    final result = await showModalBottomSheet<StadiumFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StadiumFilterSheet(
          cities: cities,
          pitchTypes: pitchTypes,
          maximumPrice: maximumPrice,
          initialFilter: _filter,
        );
      },
    );

    if (!mounted || result == null) return;

    setState(() {
      _filter = result;
    });
  }

  List<dynamic> _filteredStadiums(StadiumProvider provider) {
    final query = _searchQuery.trim().toLowerCase();

    return provider.stadiums.where((stadium) {
      final matchesSearch =
          query.isEmpty ||
              stadium.name.toLowerCase().contains(query) ||
              (stadium.cityName?.toLowerCase().contains(query) ?? false) ||
              (stadium.address?.toLowerCase().contains(query) ?? false) ||
              (stadium.pitchType?.toLowerCase().contains(query) ?? false);

      final matchesCity =
          _filter.city == null ||
              stadium.cityName == _filter.city;

      final matchesPitchType =
          _filter.pitchType == null ||
              stadium.pitchType == _filter.pitchType;

      final matchesPrice =
          _filter.maxPrice == null ||
              stadium.basePrice <= _filter.maxPrice!;

      return matchesSearch &&
          matchesCity &&
          matchesPitchType &&
          matchesPrice;
    }).toList();
  }

  bool get _hasActiveFilter {
    return _filter.city != null ||
        _filter.pitchType != null ||
        _filter.maxPrice != null;
  }

  void _clearFilters() {
    setState(() {
      _filter = const StadiumFilterResult();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Stadiums',
          style: TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Consumer<StadiumProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && !provider.hasStadiums) {
            return const StadiumLoadingSkeleton();
          }

          if (provider.errorMessage != null &&
              !provider.hasStadiums) {
            return _ErrorView(
              message: provider.errorMessage!,
              onRetry: provider.loadStadiums,
            );
          }

          if (!provider.hasStadiums) {
            return const _EmptyView();
          }

          final stadiums = _filteredStadiums(provider);

          return RefreshIndicator(
            color: const Color(0xff7CC000),
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
                      12,
                      16,
                      12,
                    ),
                    child: StadiumSearchBar(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      onFilterTap: _openFilters,
                      hintText: 'Search stadiums',
                    ),
                  ),
                ),

                if (_hasActiveFilter)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        12,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.filter_alt_rounded,
                            size: 18,
                            color: Color(0xff7CC000),
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Filters applied',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Color(0xff1E1446),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _clearFilters,
                            child: const Text(
                              'Clear',
                              style: TextStyle(
                                color: Color(0xff7CC000),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      4,
                      16,
                      12,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.stadium_outlined,
                          color: Color(0xff7CC000),
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${stadiums.length} stadium${stadiums.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            color: Color(0xff1E1446),
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                if (stadiums.isEmpty)
                  const SliverFillRemaining(
                    hasScrollBody: false,
                    child: _NoResultsView(),
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

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: StadiumCard(
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
                            ),
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

class _NoResultsView extends StatelessWidget {
  const _NoResultsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            const Text(
              'No stadiums found',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xff1E1446),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try changing your search or filters.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
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
                color: Color(0xff1E1446),
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

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      color: const Color(0xff7CC000),
      onRefresh: context.read<StadiumProvider>().loadStadiums,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        children: const [
          SizedBox(height: 220),
          Icon(
            Icons.stadium_outlined,
            size: 64,
            color: Color(0xffB0B0B0),
          ),
          SizedBox(height: 16),
          Center(
            child: Text(
              'No stadiums are available right now.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xff1E1446),
              ),
            ),
          ),
          SizedBox(height: 220),
        ],
      ),
    );
  }
}