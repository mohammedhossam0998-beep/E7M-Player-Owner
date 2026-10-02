import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/competition_provider.dart';
import '../widgets/competition_card.dart';
import 'competition_details_screen.dart';
import 'competition_invitations_screen.dart';
import 'my_competitions_screen.dart';
import 'package:e7m/shared/localization/app_translations.dart';

class CompetitionsScreen extends StatelessWidget {
  const CompetitionsScreen({super.key});

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);
  static const Color background = Color(0xFFF7F9FC);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CompetitionProvider()..loadCompetitions(),
      child: const _CompetitionsView(),
    );
  }
}

class _CompetitionsView extends StatefulWidget {
  const _CompetitionsView();

  @override
  State<_CompetitionsView> createState() => _CompetitionsViewState();
}

class _CompetitionsViewState extends State<_CompetitionsView> {
  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);
  static const Color background = Color(0xFFF7F9FC);

  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      context.read<CompetitionProvider>().setSearch(value);
    });
  }

  Future<void> _openFilters() async {
    final provider = context.read<CompetitionProvider>();
    String? location = provider.location.isEmpty ? null : provider.location;
    String? type = provider.competitionType;
    String? price = provider.price;
    String? status = provider.status;
    DateTime? date = provider.selectedDate == null
        ? null
        : DateTime.tryParse(provider.selectedDate!);

    final result = await showModalBottomSheet<_FilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FiltersSheet(
        initialLocation: location,
        initialType: type,
        initialPrice: price,
        initialStatus: status,
        initialDate: date,
      ),
    );

    if (!mounted || result == null) return;

    if (result.clear) {
      await provider.clearFilters();
      _searchController.clear();
      return;
    }

    await provider.applyFilters(
      search: _searchController.text,
      location: result.location,
      date: result.date,
      competitionType: result.type,
      price: result.price,
      status: result.status,
    );
  }

  bool _hasFilters(CompetitionProvider p) =>
      p.search.isNotEmpty ||
          p.location.isNotEmpty ||
          p.selectedDate != null ||
          p.competitionType != null ||
          p.price != null ||
          p.status != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        title: Text(
          'Competitions'.tr,
          style: TextStyle(
            color: e7mNavy,
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'My Competitions'.tr,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MyCompetitionsScreen()),
            ),
            icon: const Icon(Icons.person_rounded, color: e7mNavy),
          ),
          IconButton(
            tooltip: 'Invitations'.tr,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const CompetitionInvitationsScreen(),
              ),
            ),
            icon: const Icon(Icons.mail_outline_rounded, color: e7mNavy),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: e7mGreen.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              tooltip: 'Refresh'.tr,
              onPressed: () => context.read<CompetitionProvider>().loadCompetitions(),
              icon: const Icon(Icons.refresh_rounded, color: e7mGreen),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: e7mGreen,
        onRefresh: () => context.read<CompetitionProvider>().loadCompetitions(),
        child: Consumer<CompetitionProvider>(
          builder: (context, provider, _) {
            return CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                const SliverToBoxAdapter(child: _PageHeader()),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            onChanged: _onSearchChanged,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search competitions'.tr,
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                onPressed: () {
                                  _searchController.clear();
                                  provider.setSearch('');
                                  setState(() {});
                                },
                                icon: const Icon(Icons.close_rounded),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Material(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              child: InkWell(
                                onTap: _openFilters,
                                borderRadius: BorderRadius.circular(15),
                                child: const SizedBox(
                                  width: 52,
                                  height: 52,
                                  child: Icon(Icons.tune_rounded, color: e7mNavy),
                                ),
                              ),
                            ),
                            if (_hasFilters(provider))
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  width: 11,
                                  height: 11,
                                  decoration: const BoxDecoration(
                                    color: e7mGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                if (_hasFilters(provider))
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () async {
                            await provider.clearFilters();
                            _searchController.clear();
                          },
                          icon: const Icon(Icons.clear_all_rounded, size: 18),
                          label: Text('Clear filters'.tr),
                        ),
                      ),
                    ),
                  ),
                if (provider.isLoading && provider.competitions.isEmpty)
                  const SliverFillRemaining(hasScrollBody: false, child: _LoadingView())
                else if (provider.hasError && provider.competitions.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _ErrorView(
                      message: provider.errorMessage ?? 'Failed to load competitions.'.tr,
                      onRetry: provider.loadCompetitions,
                    ),
                  )
                else if (!provider.hasCompetitions)
                    const SliverFillRemaining(hasScrollBody: false, child: _EmptyView())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
                      sliver: SliverList.builder(
                        itemCount: provider.competitions.length,
                        itemBuilder: (context, index) {
                          final competition = provider.competitions[index];
                          return CompetitionCard(
                            competition: competition,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CompetitionDetailsScreen(
                                  competition: competition,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _FilterResult {
  const _FilterResult({
    this.location,
    this.date,
    this.type,
    this.price,
    this.status,
    this.clear = false,
  });

  final String? location;
  final DateTime? date;
  final String? type;
  final String? price;
  final String? status;
  final bool clear;
}

class _FiltersSheet extends StatefulWidget {
  const _FiltersSheet({
    this.initialLocation,
    this.initialDate,
    this.initialType,
    this.initialPrice,
    this.initialStatus,
  });

  final String? initialLocation;
  final DateTime? initialDate;
  final String? initialType;
  final String? initialPrice;
  final String? initialStatus;

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late final TextEditingController _locationController;
  DateTime? _date;
  String? _type;
  String? _price;
  String? _status;

  @override
  void initState() {
    super.initState();
    _locationController = TextEditingController(text: widget.initialLocation ?? '');
    _date = widget.initialDate;
    _type = widget.initialType;
    _price = widget.initialPrice;
    _status = widget.initialStatus;
  }

  @override
  void dispose() {
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDate: _date ?? DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Filters'.tr, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              const SizedBox(height: 18),
              TextField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location'.tr,
                  prefixIcon: const Icon(Icons.location_on_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const SizedBox(height: 14),
              _DateButton(date: _date, onTap: _pickDate, onClear: () => setState(() => _date = null)),
              const SizedBox(height: 18),
              Text('Competition Type'.tr, style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _ChoiceChip(label: 'All'.tr, selected: _type == null, onTap: () => setState(() => _type = null)),
                  _ChoiceChip(label: 'Individual'.tr, selected: _type == 'individual', onTap: () => setState(() => _type = 'individual')),
                  _ChoiceChip(label: 'Team'.tr, selected: _type == 'team', onTap: () => setState(() => _type = 'team')),
                ],
              ),
              const SizedBox(height: 18),
              Text('Price'.tr, style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _ChoiceChip(label: 'All'.tr, selected: _price == null, onTap: () => setState(() => _price = null)),
                  _ChoiceChip(label: 'Free'.tr, selected: _price == 'free', onTap: () => setState(() => _price = 'free')),
                  _ChoiceChip(label: 'Paid'.tr, selected: _price == 'paid', onTap: () => setState(() => _price = 'paid')),
                ],
              ),
              const SizedBox(height: 18),
              Text('Status'.tr, style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  _ChoiceChip(label: 'Available'.tr, selected: _status == null || _status == 'available', onTap: () => setState(() => _status = 'available')),
                  _ChoiceChip(label: 'Upcoming'.tr, selected: _status == 'upcoming', onTap: () => setState(() => _status = 'upcoming')),
                  _ChoiceChip(label: 'All'.tr, selected: _status == 'all', onTap: () => setState(() => _status = 'all')),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, const _FilterResult(clear: true)),
                      child: Text('Clear'.tr),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(
                        context,
                        _FilterResult(
                          location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
                          date: _date,
                          type: _type,
                          price: _price,
                          status: _status,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7CC000),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text('Apply Filters'.tr, style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ChoiceChip(
    label: Text(label),
    selected: selected,
    onSelected: (_) => onTap(),
    selectedColor: const Color(0xFF7CC000).withValues(alpha: 0.18),
  );
}

class _DateButton extends StatelessWidget {
  const _DateButton({required this.date, required this.onTap, required this.onClear});
  final DateTime? date;
  final VoidCallback onTap;
  final VoidCallback onClear;
  @override
  Widget build(BuildContext context) {
    final label = date == null ? 'Select date'.tr : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date'.tr,
          prefixIcon: const Icon(Icons.calendar_today_outlined),
          suffixIcon: date == null ? null : IconButton(onPressed: onClear, icon: const Icon(Icons.clear_rounded)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label),
      ),
    );
  }
}

// ============================================================
// PAGE HEADER
// ============================================================

class _PageHeader extends StatelessWidget {
  const _PageHeader();

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);
  static const Color e7mDarkNavy = Color(0xFF031B3A);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        18,
        16,
        18,
      ),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            e7mNavy,
            e7mDarkNavy,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: e7mNavy.withValues(alpha: 0.14),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: e7mGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: e7mGreen,
              size: 28,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Beyond The Game'.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Find your next challenge'.tr,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
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

// ============================================================
// LOADING
// ============================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: e7mNavy.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 3,
                color: e7mGreen,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Loading competitions...'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: e7mNavy,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY
// ============================================================

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: e7mGreen.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_outlined,
                color: e7mGreen,
                size: 45,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'No Competitions Yet'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: e7mNavy,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'There are no available competitions right now.'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ERROR
// ============================================================

class _ErrorView extends StatelessWidget {
  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  static const Color e7mGreen = Color(0xFF7CC000);
  static const Color e7mNavy = Color(0xFF082B5C);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 82,
              height: 82,
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: Colors.redAccent,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: e7mNavy,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 20,
                ),
                label: Text(
                  'Try Again'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: e7mGreen,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}