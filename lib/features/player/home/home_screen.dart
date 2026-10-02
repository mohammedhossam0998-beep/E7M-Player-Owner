import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';

import 'package:e7m/features/auth/presentation/controllers/auth_controller.dart';
import 'package:e7m/features/player/profile/presentation/providers/player_profile_provider.dart';
import 'package:e7m/core/network/api_client.dart';

import 'package:e7m/features/player/home/map_screen.dart';
import 'package:e7m/features/player/booking/my_bookings_screen.dart';
import 'package:e7m/features/player/teams/presentation/screens/teams_near_you_screen.dart';
import 'package:e7m/features/player/teams/presentation/screens/create_team_screen.dart';
import 'package:e7m/features/player/stadium/presentation/screens/stadiums_screen.dart';
import 'package:e7m/features/player/stadium/presentation/screens/favorites_screen.dart';
import 'package:e7m/features/player/notifications/presentation/screens/notifications_screen.dart';
import 'package:e7m/features/player/notifications/providers/notification_provider.dart';


import 'package:e7m/features/player/profile/presentation/screens/profile_screen.dart';
import 'package:e7m/features/player/stadium/presentation/widgets/favorites_service.dart';
import 'package:e7m/features/player/stadium/data/models/stadium.dart';
import 'package:e7m/features/player/stadium/presentation/providers/stadium_provider.dart';
import 'package:e7m/features/player/stadium/presentation/screens/stadium_details_screen.dart';
import 'package:e7m/features/player/stadium/presentation/widgets/featured_stadium_card.dart';
import 'package:e7m/features/player/stadium/presentation/widgets/stadium_card.dart';
import 'package:e7m/features/player/stadium/presentation/widgets/stadium_filter_sheet.dart';
import 'package:e7m/features/player/stadium/presentation/widgets/stadium_loading_skeleton.dart';
import 'package:e7m/features/player/stadium/presentation/widgets/stadium_search_bar.dart';
import 'package:e7m/features/player/academy/presentation/screens/academies_screen.dart';
import 'package:e7m/features/player/competitions/presentation/screens/competitions_screen.dart';

/// Centralized brand colors
class _AppColors {
  static const background = Color(0xffF7F7F3);
  static const primaryGreen = Color(0xff7CC000);
  static const darkNavy = Color(0xff1E1446);
  static const subtitleGrey = Color(0xff8FA18D);
  static const forestGreen = Color(0xff145A32);
  static const violet = Color(0xff3F2B96);
  static const crimson = Color(0xffC0392B);
  static const orange = Color(0xffF39C12);
  static const teal = Color(0xff00695C);
  static const tealLight = Color(0xff26A69A);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  String _searchQuery = '';

  StadiumFilterResult _stadiumFilter =
  const StadiumFilterResult();

  Set<String> _favoriteIds = {};

  final PageController _cardsController = PageController(
    viewportFraction: 0.88,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StadiumProvider>().loadStadiums();
      context.read<NotificationProvider>().loadUnreadCount();
      context.read<PlayerProfileProvider>().loadProfile();
    });

    _loadFavoriteIds();
  }

  @override
  void dispose() {
    _cardsController.dispose();
    super.dispose();
  }

  String _getUserName() {
    final authController = context.read<AuthController>();

    final user = authController.user;

    if (user == null) {
      return '';
    }

    final fullName = user['full_name']?.toString().trim();

    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }

    final name = user['name']?.toString().trim();

    if (name != null && name.isNotEmpty) {
      return name;
    }

    return '';
  }

  Future<void> _loadFavoriteIds() async {
    final ids = await FavoritesService.getFavoriteIds();

    if (!mounted) return;

    setState(() {
      _favoriteIds = ids;
    });
  }

  Future<void> _toggleFavorite(String stadiumId) async {
    final updatedIds = await FavoritesService.toggleFavorite(stadiumId);

    if (!mounted) return;

    setState(() {
      _favoriteIds = updatedIds;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: _AppColors.background,

      body: IndexedStack(
        index: currentIndex,
        children: [
          buildHomeContent(),
          const MyBookingsScreen(),
          const MapScreen(),
          const FavoritesScreen(),
          const ProfileScreen(),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: _AppColors.primaryGreen,
        unselectedItemColor: Colors.black,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home_outlined),
            label: t('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.calendar_today),
            label: t('booking'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.map),
            label: t('map'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: t('favourite'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person_outline),
            label: t('profile'),
          ),
        ],
      ),
    );
  }

  Future<void> _openStadiumFilters() async {
    final provider =
    context.read<StadiumProvider>();

    final cities = provider.stadiums
        .map((stadium) => stadium.cityName)
        .whereType<String>()
        .where(
          (city) => city.trim().isNotEmpty,
    )
        .toSet()
        .toList()
      ..sort();

    final pitchTypes = provider.stadiums
        .map((stadium) => stadium.pitchType)
        .whereType<String>()
        .where(
          (type) => type.trim().isNotEmpty,
    )
        .toSet()
        .toList()
      ..sort();

    final prices = provider.stadiums
        .map((stadium) => stadium.basePrice)
        .where((price) => price >= 0)
        .toList();

    final maximumPrice = prices.isEmpty
        ? null
        : prices.reduce(
          (current, next) =>
      current > next ? current : next,
    );

    final result =
    await showModalBottomSheet<StadiumFilterResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) {
        return StadiumFilterSheet(
          cities: cities,
          pitchTypes: pitchTypes,
          maximumPrice: maximumPrice,
          initialFilter: _stadiumFilter,
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _stadiumFilter = result;
    });
  }

  Widget buildHomeContent() {
    final languageProvider =
    context.watch<LanguageProvider>();

    final t = languageProvider.translate;

    // Uses the translation when the key exists, otherwise the fallback.
    String tr(String key, String fallback) {
      final value = t(key);

      return value == key ? fallback : value;
    }

    final stadiumProvider =
    context.watch<StadiumProvider>();

    final filteredStadiums =
    stadiumProvider.stadiums.where((stadium) {
      final query =
      _searchQuery.trim().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
              stadium.name.toLowerCase().contains(query) ||
              (stadium.cityName
                  ?.toLowerCase()
                  .contains(query) ??
                  false) ||
              (stadium.address
                  ?.toLowerCase()
                  .contains(query) ??
                  false) ||
              (stadium.pitchType
                  ?.toLowerCase()
                  .contains(query) ??
                  false);

      final matchesCity =
          _stadiumFilter.city == null ||
              stadium.cityName == _stadiumFilter.city;

      final matchesPitchType =
          _stadiumFilter.pitchType == null ||
              stadium.pitchType ==
                  _stadiumFilter.pitchType;

      final matchesPrice =
          _stadiumFilter.maxPrice == null ||
              stadium.basePrice <=
                  _stadiumFilter.maxPrice!;

      return matchesSearch &&
          matchesCity &&
          matchesPitchType &&
          matchesPrice;
    }).toList();

    final horizontalCards = [
      _CardData(
        title: t('create_team'),
        subtitle: t('build_dream_team'),
        buttonLabel: t('create'),
        colors: const [
          _AppColors.forestGreen,
          _AppColors.primaryGreen,
        ],
        buttonColor: _AppColors.forestGreen,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateTeamScreen(),
            ),
          );
        },
      ),

      _CardData(
        title: t('find_team'),
        subtitle: t('join_matches'),
        buttonLabel: t('find'),
        colors: const [
          _AppColors.darkNavy,
          _AppColors.violet,
        ],
        buttonColor: _AppColors.darkNavy,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TeamsNearYouScreen(),
            ),
          );
        },
      ),
      _CardData(
        title: t('join_academy'),
        subtitle: t('find_best_football_academies'),
        buttonLabel: t('explore'),
        colors: const [
          _AppColors.teal,
          _AppColors.tealLight,
        ],
        buttonColor: _AppColors.teal,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AcademiesScreen(),
            ),
          );
        },
      ),

      _CardData(
        title: t('competitions'),
        subtitle: tr(
          'join_football_competitions',
          'Join football competitions',
        ),
        buttonLabel: t('explore'),
        colors: const [
          _AppColors.darkNavy,
          _AppColors.primaryGreen,
        ],
        buttonColor: _AppColors.darkNavy,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CompetitionsScreen(),
            ),
          );
        },
      ),
    ];

    return SafeArea(
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              10,
              16,
              12,
            ),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Consumer<PlayerProfileProvider>(
                    builder: (context, profileProvider, _) {
                      final imageUrl = ApiClient.resolveMediaUrl(
                        profileProvider.profile?.profileImage,
                      );

                      // The default avatar stays visible if the network
                      // image is missing or fails to load.
                      return CircleAvatar(
                        radius: 26,
                        backgroundImage: const AssetImage(
                          'assets/images/player.png',
                        ),
                        foregroundImage: imageUrl.isNotEmpty
                            ? NetworkImage(imageUrl)
                            : null,
                        onForegroundImageError: imageUrl.isNotEmpty
                            ? (error, stackTrace) {}
                            : null,
                      );
                    },
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "${t('hello')}, ",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight:
                                FontWeight.w500,
                              ),
                            ),
                            Flexible(
                              child: Consumer<PlayerProfileProvider>(
                                builder: (context, profileProvider, _) {
                                  // Profile name is updated right after
                                  // Edit Profile; the login name is the
                                  // fallback.
                                  final profileName =
                                  profileProvider.profile?.fullName?.trim();

                                  final name = (profileName != null &&
                                      profileName.isNotEmpty)
                                      ? profileName
                                      : _getUserName();

                                  return Text(
                                    name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Text(
                          t('find_book_field'),
                          style: const TextStyle(
                            fontSize: 14,
                            color:
                            _AppColors.subtitleGrey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Consumer<NotificationProvider>(
                    builder: (context, notificationProvider, _) {
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const NotificationsScreen(),
                            ),
                          );

                          if (mounted) {
                            context
                                .read<NotificationProvider>()
                                .loadUnreadCount();
                          }
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: const BoxDecoration(
                                color: _AppColors.primaryGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_none,
                                color: Colors.white,
                              ),
                            ),

                            if (notificationProvider.unreadCount > 0)
                              Positioned(
                                right: -3,
                                top: -3,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 20,
                                    minHeight: 20,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: _AppColors.background,
                                      width: 2,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      notificationProvider.unreadCount > 99
                                          ? '99+'
                                          : notificationProvider.unreadCount
                                          .toString(),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          SliverAppBar(
            pinned: true,
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor:
            _AppColors.background,
            automaticallyImplyLeading: false,
            toolbarHeight: 72,
            titleSpacing: 0,
            title: Padding(
              padding:
              const EdgeInsets.fromLTRB(
                16,
                8,
                16,
                8,
              ),
              child: StadiumSearchBar(
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                onFilterTap: _openStadiumFilters,
                hintText: t('search_stadiums'),
              ),
            ),
          ),

          SliverPadding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100,
                    child: PageView.builder(
                      controller:
                      _cardsController,
                      padEnds: false,
                      itemCount:
                      horizontalCards.length,
                      itemBuilder:
                          (context, index) {
                        final card =
                        horizontalCards[index];

                        return Padding(
                          padding:
                          const EdgeInsets.only(
                            right: 12,
                          ),
                          child:
                          _buildHomeCard(card),
                        );
                      },
                    ),
                  ),


                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment
                        .spaceBetween,
                    children: [
                      Text(
                        t('featured_stadiums'),
                        style:
                        const TextStyle(
                          fontSize: 22,
                          fontWeight:
                          FontWeight.bold,
                          color:
                          _AppColors.darkNavy,
                        ),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const StadiumsScreen(),
                            ),
                          );
                        },
                        child: Text(
                          t('see_all'),
                          style:
                          const TextStyle(
                            color:
                            _AppColors
                                .primaryGreen,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  if (stadiumProvider.isLoading)
                    const SizedBox(
                      height: 250,
                      child: StadiumLoadingSkeleton(
                        itemCount: 2,
                      ),
                    )
                  else if (stadiumProvider.stadiums.isNotEmpty)
                    SizedBox(
                      height: 250,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(
                          right: 4,
                        ),
                        itemCount:
                        stadiumProvider.stadiums.length,
                        separatorBuilder: (_, _) =>
                        const SizedBox(width: 12),
                        itemBuilder: (context, index) {
                          final stadium =
                          stadiumProvider.stadiums[index];

                          return FeaturedStadiumCard(
                            stadium: stadium,
                            isFavorite: _favoriteIds.contains(stadium.id),
                            onFavoritePressed: () => _toggleFavorite(stadium.id),
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
                      ),
                    ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          if (stadiumProvider.isLoading)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 40,
                ),
                child: Center(
                  child: CircularProgressIndicator(
                    color: _AppColors.primaryGreen,
                  ),
                ),
              ),
            )
          else if (stadiumProvider.errorMessage != null &&
              !stadiumProvider.hasStadiums)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 35,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),

                    const SizedBox(height: 12),

                    Text(
                      tr(
                        'unable_to_load_stadiums',
                        'Unable to load stadiums',
                      ),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 14),

                    ElevatedButton.icon(
                      onPressed:
                      stadiumProvider.loadStadiums,
                      icon: const Icon(Icons.refresh),
                      label: Text(t('try_again')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        _AppColors.primaryGreen,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (filteredStadiums.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 40,
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.search_off,
                        size: 48,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        t('no_results_found'),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final Stadium stadium =
                      filteredStadiums[index];

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        child: StadiumCard(
                          stadium: stadium,
                          isFavorite: _favoriteIds.contains(stadium.id),
                          onFavoritePressed: () => _toggleFavorite(stadium.id),
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
                    childCount: filteredStadiums.length,
                  ),
                ),
              ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeCard(
      _CardData card,
      ) {
    return GestureDetector(
      onTap: card.onTap,
      child: Container(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 15,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: card.colors,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Text(
                    card.title,
                    style:
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight:
                      FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    card.subtitle,
                    style:
                    const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow:
                    TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            ElevatedButton(
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                Colors.white,
                foregroundColor:
                card.buttonColor,
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              onPressed: card.onTap,
              child: Text(
                card.buttonLabel,
                style:
                const TextStyle(
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardData {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final List<Color> colors;
  final Color buttonColor;
  final VoidCallback onTap;
  _CardData({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.colors,
    required this.buttonColor,
    required this.onTap,
  });
}