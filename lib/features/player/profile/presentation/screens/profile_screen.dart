import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/core/network/api_client.dart';

import 'package:e7m/welcome_screen.dart';
import 'package:e7m/features/player/profile/presentation/providers/player_profile_provider.dart';
import 'package:e7m/features/player/settings/settings_screen.dart';
import 'package:e7m/features/player/academy/presentation/screens/my_academy_enrollments_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? _profile;

  bool _isLoading = true;
  String? _errorMessage;

  // ============================================================
  // BRAND COLORS
  // ============================================================

  static const Color backgroundColor = Color(0xffF7F7F3);
  static const Color primaryGreen = Color(0xff7CC000);
  static const Color darkNavy = Color(0xff1E1446);

  // ============================================================
  // LOAD PROFILE
  // GET /api/player/profile
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final profileProvider = context.read<PlayerProfileProvider>();

      await profileProvider.loadProfile();

      if (!mounted) return;

      if (profileProvider.hasError || profileProvider.profile == null) {
        throw Exception(
          profileProvider.errorMessage ?? 'Profile data not found',
        );
      }

      setState(() {
        _profile = profileProvider.profile!.toJson();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _value(String key, String fallback) {
    final value = _profile?[key];

    if (value == null) {
      return fallback;
    }

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') {
      return fallback;
    }

    return text;
  }

  String _formatValue(String key, String fallback) {
    final value = _value(key, fallback);

    if (value == fallback) {
      return fallback;
    }

    return value
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
          ? word
          : '${word[0].toUpperCase()}${word.substring(1)}',
    )
        .join(' ');
  }

  String _getImageUrl() {
    final image = _profile?['profile_image'];

    if (image == null) {
      return '';
    }

    final imagePath = image.toString().trim();

    if (imagePath.isEmpty) {
      return '';
    }

    if (imagePath.startsWith('http://') ||
        imagePath.startsWith('https://')) {
      return imagePath;
    }

    final serverUrl = ApiClient.baseUrl.replaceFirst('/api', '');

    if (imagePath.startsWith('/')) {
      return '$serverUrl$imagePath';
    }

    return '$serverUrl/$imagePath';
  }

  String _displayName() {
    final name = _value('full_name', 'Player');

    if (name.trim().isEmpty) {
      return 'Player';
    }

    return name;
  }

  String _displayEmail() {
    return _value('email', 'No email');
  }

  String _displayPhone() {
    return _value('phone', 'Not added');
  }

  String _displayCity() {
    return _formatValue('city', 'Not added');
  }

  String _displayPosition() {
    return _formatValue('position', 'Not added');
  }

  String _displayLevel() {
    return _formatValue('skill_level', 'Not added');
  }

  String _displayPlayingStyle() {
    return _formatValue('playing_style', 'Not added');
  }

  String _displayPreferredFoot() {
    return _formatValue('preferred_foot', 'Not added');
  }

  String _displayHeight() {
    final value = _value('height', '');

    if (value.isEmpty) {
      return 'Not added';
    }

    return '$value cm';
  }

  String _displayWeight() {
    final value = _value('weight', '');

    if (value.isEmpty) {
      return 'Not added';
    }

    return '$value kg';
  }

  String _displayExperience() {
    final value = _value('experience', '');

    if (value.isEmpty) {
      return 'Not added';
    }

    return '$value Years';
  }

  String _displayDateOfBirth() {
    final value = _value('date_of_birth', 'Not added');

    if (value == 'Not added') {
      return value;
    }

    return value;
  }

  String _displayBio() {
    return _value('bio', 'No bio added yet.');
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Widget _buildProfileImage() {
    final imageUrl = _getImageUrl();

    if (imageUrl.isEmpty) {
      return const CircleAvatar(
        radius: 45,
        backgroundImage: AssetImage(
          'assets/images/player.png',
        ),
      );
    }

    return CircleAvatar(
      radius: 45,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: NetworkImage(imageUrl),
      onBackgroundImageError: (_, __) {},
      child: null,
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryGreen,
          onRefresh: _loadProfile,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ========================================================
                // TOP BAR
                // ========================================================

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Directionality.of(context) == TextDirection.rtl
                            ? Icons.arrow_forward_ios
                            : Icons.arrow_back_ios,
                      ),
                    ),

                    Text(
                      t('my_profile'),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: darkNavy,
                      ),
                    ),

                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: darkNavy,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ========================================================
                // PROFILE HEADER
                // ========================================================

                _buildProfileHeader(),

                const SizedBox(height: 24),

                // ========================================================
                // STATS
                // ========================================================

                Row(
                  children: [
                    Expanded(
                      child: statCard(
                        context,
                        "—",
                        t("bookings"),
                            () {},
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: statCard(
                        context,
                        "—",
                        t("favorites"),
                            () {},
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: statCard(
                        context,
                        "—",
                        t("teams"),
                            () {},
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // ========================================================
                // PLAYER INFORMATION
                // ========================================================

                _buildPlayerInformation(t),

                const SizedBox(height: 30),

                // ========================================================
                // ACCOUNT SETTINGS
                // ========================================================

                sectionTitle(
                  t('account_settings'),
                ),

                const SizedBox(height: 12),

                sectionBox(
                  children: [
                    item(
                      context,
                      icon: Icons.edit_outlined,
                      title: t('edit_profile'),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const EditProfileScreen(),
                          ),
                        );

                        if (mounted) {
                          _loadProfile();
                        }
                      },
                    ),

                    item(
                      context,
                      icon: Icons.school_outlined,
                      title: t('my_academy_enrollments'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const MyAcademyEnrollmentsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ========================================================
                // LOGOUT
                // ========================================================

                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Colors.red,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(20),
                            ),
                            title: Text(
                              t('logout'),
                            ),
                            content: Text(
                              t('logout_confirm'),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  t('cancel'),
                                ),
                              ),

                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                onPressed: () {
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                      const WelcomeScreen(),
                                    ),
                                        (route) => false,
                                  );
                                },
                                child: Text(
                                  t('logout'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    label: Text(
                      t('logout'),
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // PROFILE HEADER
  // ============================================================

  Widget _buildProfileHeader() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
            ),
          ],
        ),
        child: const SizedBox(
          height: 90,
          child: Center(
            child: CircularProgressIndicator(
              color: primaryGreen,
            ),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 12,
            ),
          ],
        ),
        child: Column(
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 42,
              color: Colors.grey,
            ),

            const SizedBox(height: 10),

            const Text(
              'Unable to load profile',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please try again.',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 15),

            OutlinedButton(
              onPressed: _loadProfile,
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryGreen,
                side: const BorderSide(
                  color: primaryGreen,
                ),
              ),
              child: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          // ==========================================================
          // IMAGE
          // ==========================================================

          Stack(
            children: [
              _buildProfileImage(),

              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: primaryGreen,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt_outlined,
                    size: 18,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 18),

          // ==========================================================
          // NAME + EMAIL
          // ==========================================================

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _displayEmail(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  _displayPosition(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: primaryGreen,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PLAYER INFORMATION
  // ============================================================

  Widget _buildPlayerInformation(
      String Function(String) t,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        sectionTitle(
          t('player_profile'),
        ),

        const SizedBox(height: 12),

        sectionBox(
          children: [
            _infoItem(
              icon: Icons.phone_outlined,
              title: 'Phone',
              value: _displayPhone(),
            ),

            _infoItem(
              icon: Icons.location_on_outlined,
              title: 'City',
              value: _displayCity(),
            ),

            _infoItem(
              icon: Icons.cake_outlined,
              title: 'Date of Birth',
              value: _displayDateOfBirth(),
            ),

            _infoItem(
              icon: Icons.sports_soccer_outlined,
              title: 'Position',
              value: _displayPosition(),
            ),

            _infoItem(
              icon: Icons.trending_up_outlined,
              title: 'Skill Level',
              value: _displayLevel(),
            ),

            _infoItem(
              icon: Icons.style_outlined,
              title: 'Playing Style',
              value: _displayPlayingStyle(),
            ),

            _infoItem(
              icon: Icons.directions_run_outlined,
              title: 'Preferred Foot',
              value: _displayPreferredFoot(),
            ),

            _infoItem(
              icon: Icons.height_outlined,
              title: 'Height',
              value: _displayHeight(),
            ),

            _infoItem(
              icon: Icons.monitor_weight_outlined,
              title: 'Weight',
              value: _displayWeight(),
            ),

            _infoItem(
              icon: Icons.history_outlined,
              title: 'Experience',
              value: _displayExperience(),
            ),

            _buildBioItem(),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // INFO ITEM
  // ============================================================

  Widget _infoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xffEFEFEF),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: primaryGreen,
            size: 22,
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 10),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BIO
  // ============================================================

  Widget _buildBioItem() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: primaryGreen,
                size: 22,
              ),

              const SizedBox(width: 14),

              const Text(
                'About',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            _displayBio(),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // STATS CARD
  // ============================================================

  Widget statCard(
      BuildContext context,
      String number,
      String title,
      VoidCallback onTap,
      ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          height: 95,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                number,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: primaryGreen,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                title,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ============================================================
  // SECTION BOX
  // ============================================================

  Widget sectionBox({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: children,
      ),
    );
  }

  // ============================================================
  // MENU ITEM
  // ============================================================

  Widget item(
      BuildContext context, {
        required IconData icon,
        required String title,
        required VoidCallback onTap,
      }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(0xffEFEFEF),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: primaryGreen,
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_back_ios
                  : Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}