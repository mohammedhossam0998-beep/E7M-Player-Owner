import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/competition_model.dart';
import '../providers/competition_provider.dart';
import '../widgets/competition_card.dart';
import 'competition_details_screen.dart';
import 'create_competition_screen.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class CompetitionsScreen extends StatefulWidget {
  const CompetitionsScreen({super.key});

  @override
  State<CompetitionsScreen> createState() =>
      _CompetitionsScreenState();
}

class _CompetitionsScreenState
    extends State<CompetitionsScreen> {
  static const Color primaryColor =
  Color(0xff7CC000);

  static const Color darkColor =
  Color(0xff1E1446);

  final TextEditingController _searchController =
  TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CompetitionProvider>().loadCompetitions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _t(
      BuildContext context,
      String key,
      ) {
    return context
        .read<LanguageProvider>()
        .translate(key);
  }

  List<CompetitionModel> _filteredCompetitions(
      List<CompetitionModel> competitions,
      ) {
    final query = _searchQuery.trim().toLowerCase();

    if (query.isEmpty) {
      return competitions;
    }

    return competitions.where((competition) {
      final name =
      competition.name.toLowerCase();

      final location =
          competition.location?.toLowerCase() ?? '';

      return name.contains(query) ||
          location.contains(query);
    }).toList();
  }

  Future<void> _refresh() async {
    await context
        .read<CompetitionProvider>()
        .loadCompetitions();
  }

  Future<void> _openCreateCompetition() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
        const CreateCompetitionScreen(),
      ),
    );

    if (!mounted) return;

    // Always refresh from the backend after returning from the
    // create screen. This keeps the owner list as the source of truth
    // and also handles cases where the create screen used a different
    // provider instance.
    await context
        .read<CompetitionProvider>()
        .loadCompetitions();

    if (!mounted) return;

    if (result is CompetitionModel) {
      setState(() {
        _searchController.clear();
        _searchQuery = '';
      });
    }
  }

  Widget _buildEmptyState(
      BuildContext context,
      ) {
    final isSearching =
        _searchQuery.trim().isNotEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: primaryColor.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                color: primaryColor,
                size: 46,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              isSearching
                  ? _t(
                context,
                'no_results_found',
              )
                  : _t(
                context,
                'no_competitions_yet',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkColor,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 8),

            if (isSearching)
              Text(
                _t(
                  context,
                  'try_different_search',
                ),
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),

            if (!isSearching) ...[
              const SizedBox(height: 18),
              ElevatedButton.icon(
                onPressed:
                _openCreateCompetition,
                icon: const Icon(
                  Icons.add,
                ),
                label: Text(
                  _t(
                    context,
                    'create_competition',
                  ),
                ),
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  primaryColor,
                  foregroundColor:
                  Colors.white,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      14,
                    ),
                  ),
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context,
      String message,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red.shade400,
            ),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: _refresh,
              icon: const Icon(
                Icons.refresh,
              ),
              label: Text(
                _t(
                  context,
                  'retry',
                ),
              ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                primaryColor,
                foregroundColor:
                Colors.white,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider =
    context.watch<LanguageProvider>();

    final provider =
    context.watch<CompetitionProvider>();

    final isArabic =
        languageProvider.locale.languageCode ==
            'ar';

    final competitions =
    _filteredCompetitions(
      provider.competitions,
    );

    return Directionality(
      textDirection: isArabic
          ? TextDirection.rtl
          : TextDirection.ltr,
      child: Scaffold(
        backgroundColor:
        const Color(0xffF6F8FB),

        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: darkColor,
          elevation: 0,
          centerTitle: true,
          title: Text(
            _t(
              context,
              'my_competitions',
            ),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        floatingActionButton:
        FloatingActionButton.extended(
          onPressed:
          provider.isLoading
              ? null
              : _openCreateCompetition,
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: Text(
            _t(
              context,
              'create_competition',
            ),
          ),
        ),

        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding:
                const EdgeInsets.fromLTRB(
                  16,
                  16,
                  16,
                  10,
                ),
                child: TextField(
                  controller:
                  _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: _t(
                      context,
                      'search_competition',
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                    ),
                    suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                      onPressed: () {
                        _searchController
                            .clear();

                        setState(() {
                          _searchQuery =
                          '';
                        });
                      },
                      icon: const Icon(
                        Icons.clear,
                      ),
                    )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    border:
                    OutlineInputBorder(
                      borderRadius:
                      BorderRadius.circular(
                        16,
                      ),
                      borderSide:
                      BorderSide.none,
                    ),
                  ),
                ),
              ),

              Expanded(
                child: Builder(
                  builder: (context) {
                    if (provider.isLoading &&
                        provider.competitions
                            .isEmpty) {
                      return const Center(
                        child:
                        CircularProgressIndicator(
                          color: primaryColor,
                        ),
                      );
                    }

                    if (provider.errorMessage !=
                        null &&
                        provider.competitions
                            .isEmpty) {
                      return _buildErrorState(
                        context,
                        provider
                            .errorMessage!,
                      );
                    }

                    if (competitions.isEmpty) {
                      return _buildEmptyState(
                        context,
                      );
                    }

                    return RefreshIndicator(
                      color: primaryColor,
                      onRefresh: _refresh,
                      child: ListView.builder(
                        padding:
                        const EdgeInsets.fromLTRB(
                          16,
                          8,
                          16,
                          100,
                        ),
                        itemCount:
                        competitions.length,
                        itemBuilder:
                            (context, index) {
                          return CompetitionCard(
                            competition:
                            competitions[index],
                            languageProvider:
                            languageProvider,
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CompetitionDetailsScreen(
                                        competition:
                                        competitions[index],
                                      ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}