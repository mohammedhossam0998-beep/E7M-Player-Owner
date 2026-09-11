import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:e7m/features/owner/booking/presentation/screens/owner_bookings_screen.dart';
import 'package:e7m/features/owner/profile/presentation/screens/edit_profile_screen.dart';
import 'package:e7m/features/owner/profile/providers/owner_profile_provider.dart';
import 'package:e7m/features/owner/revenue/revenue_screen.dart';
import 'package:e7m/features/owner/reviews/presentation/reviews_screen.dart';
import 'package:e7m/features/owner/settings/about_screen.dart';
import 'package:e7m/features/owner/settings/change_password_screen.dart';
import 'package:e7m/features/owner/settings/help_support_screen.dart';
import 'package:e7m/features/owner/settings/language_screen.dart';
import 'package:e7m/features/owner/notifications/notifications_screen.dart';
import 'package:e7m/features/owner/settings/privacy_policy_screen.dart';
import 'package:e7m/features/owner/stadium/presentation/screens/owner_stadiums_screen.dart';
import 'package:e7m/shared/localization/language_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  static const Color green = Color(0xff7CC000);
  static const Color navy = Color(0xff1E1446);
  static const Color background = Color(0xffF7F8FA);
  static const Color border = Color(0xffE8EAF0);
  static const Color secondary = Color(0xff777B86);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OwnerProfileProvider>().loadProfile();
    });
  }

  Future<void> _refresh() async {
    await context.read<OwnerProfileProvider>().refreshProfile();
  }

  Future<void> _editProfile() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );

    if (!mounted) return;

    if (result == true) {
      await context.read<OwnerProfileProvider>().refreshProfile();
    }
  }

  void _open(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  Future<void> _logout() async {
    final languageProvider = context.read<LanguageProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            languageProvider.translate('logout'),
            style: const TextStyle(
              color: ProfileScreen.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            languageProvider.translate(
              'logout_confirmation',
            ),
            style: const TextStyle(
              color: ProfileScreen.secondary,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                languageProvider.translate('cancel'),
                style: const TextStyle(
                  color: ProfileScreen.secondary,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                languageProvider.translate('logout'),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      'is_logged_in',
      false,
    );

    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      '/welcome',
          (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider =
    context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: ProfileScreen.background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          languageProvider.translate('my_profile'),
          style: const TextStyle(
            color: ProfileScreen.navy,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          Consumer<OwnerProfileProvider>(
            builder: (_, provider, __) {
              return Padding(
                padding: const EdgeInsetsDirectional.only(
                  end: 12,
                ),
                child: IconButton(
                  onPressed:
                  provider.isLoading ? null : _refresh,
                  tooltip: 'Refresh',
                  style: IconButton.styleFrom(
                    backgroundColor:
                    ProfileScreen.background,
                  ),
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: ProfileScreen.navy,
                  ),
                ),
              );
            },
          ),
        ],
      ),

      body: Consumer<OwnerProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading &&
              !provider.hasProfile) {
            return const Center(
              child: CircularProgressIndicator(
                color: ProfileScreen.green,
              ),
            );
          }

          if (!provider.hasProfile) {
            return _ErrorState(
              message: provider.errorMessage ??
                  languageProvider.translate(
                    'something_went_wrong',
                  ),
              onRetry: provider.loadProfile,
            );
          }

          final profile = provider.profile!;

          return RefreshIndicator(
            color: ProfileScreen.green,
            onRefresh: _refresh,
            child: ListView(
              physics:
              const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(
                18,
                18,
                18,
                35,
              ),
              children: [
                _ProfileHeader(
                  name: profile.fullName,
                  email: profile.email,
                  phone: profile.phone,
                  imageUrl: profile.profileImage,
                  isVerified: profile.isVerified,
                  businessName: profile.businessName,
                  onEdit: _editProfile,
                  languageProvider: languageProvider,
                ),

                const SizedBox(height: 24),

                _SectionTitle(
                  title: languageProvider.translate(
                    'account',
                  ),
                ),

                const SizedBox(height: 10),

                _SettingsCard(
                  children: [
                    _SettingTile(
                      icon: Icons.edit_outlined,
                      color: const Color(0xff3B82F6),
                      title: languageProvider.translate(
                        'edit_profile',
                      ),
                      onTap: _editProfile,
                    ),

                    _SettingTile(
                      icon: Icons.stadium_outlined,
                      color: ProfileScreen.green,
                      title: languageProvider.translate(
                        'my_stadium',
                      ),
                      onTap: () {
                        _open(
                          const OwnerStadiumsScreen(),
                        );
                      },
                    ),

                    _SettingTile(
                      icon: Icons.lock_outline_rounded,
                      color: const Color(0xffF97316),
                      title: languageProvider.translate(
                        'change_password',
                      ),
                      onTap: () {
                        _open(
                          const ChangePasswordScreen(),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _SectionTitle(
                  title: languageProvider.translate(
                    'quick_actions',
                  ),
                ),

                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.calendar_month_outlined,
                        title: languageProvider.translate(
                          'bookings',
                        ),
                        onTap: () {
                          _open(
                            const OwnerBookingsScreen(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.bar_chart_rounded,
                        title: languageProvider.translate(
                          'revenue',
                        ),
                        onTap: () {
                          _open(
                            const RevenueScreen(),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.reviews_outlined,
                        title: languageProvider.translate(
                          'reviews',
                        ),
                        onTap: () {
                          _open(
                            const ReviewsScreen(),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _SectionTitle(
                  title: languageProvider.translate(
                    'preferences',
                  ),
                ),

                const SizedBox(height: 10),

                _SettingsCard(
                  children: [
                    _SettingTile(
                      icon:
                      Icons.notifications_none_rounded,
                      color: const Color(0xff8B5CF6),
                      title: languageProvider.translate(
                        'notifications',
                      ),
                      onTap: () {
                        _open(
                          const NotificationsScreen(),
                        );
                      },
                    ),

                    _SettingTile(
                      icon: Icons.language_rounded,
                      color: const Color(0xff14B8A6),
                      title: languageProvider.translate(
                        'language',
                      ),
                      onTap: () {
                        _open(
                          const LanguageScreen(),
                        );
                      },
                    ),

                    _SettingTile(
                      icon:
                      Icons.workspace_premium_outlined,
                      color: ProfileScreen.green,
                      title: languageProvider.translate(
                        'my_subscription',
                      ),
                      onTap: () {
                      },
                    ),

                    _SettingTile(
                      icon: Icons.privacy_tip_outlined,
                      color: const Color(0xff0F766E),
                      title: languageProvider.translate(
                        'privacy_policy',
                      ),
                      onTap: () {
                        _open(
                          const PrivacyPolicyScreen(),
                        );
                      },
                    ),

                    _SettingTile(
                      icon: Icons.help_outline_rounded,
                      color: const Color(0xff6366F1),
                      title: languageProvider.translate(
                        'help_support',
                      ),
                      onTap: () {
                        _open(
                          const HelpSupportScreen(),
                        );
                      },
                    ),

                    _SettingTile(
                      icon: Icons.info_outline_rounded,
                      color: const Color(0xff64748B),
                      title: languageProvider.translate(
                        'about_e7m',
                      ),
                      showDivider: false,
                      onTap: () {
                        _open(
                          const AboutScreen(),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _LogoutButton(
                  title: languageProvider.translate(
                    'logout',
                  ),
                  onTap: _logout,
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
// PROFILE HEADER
// ============================================================

class _ProfileHeader extends StatelessWidget {
  final String? name;
  final String? email;
  final String? phone;
  final String? imageUrl;
  final bool? isVerified;
  final String? businessName;
  final VoidCallback onEdit;
  final LanguageProvider languageProvider;

  const _ProfileHeader({
    required this.name,
    required this.email,
    required this.phone,
    required this.imageUrl,
    required this.isVerified,
    required this.businessName,
    required this.onEdit,
    required this.languageProvider,
  });

  String _value(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '—';
    }

    return value.trim();
  }

  @override
  Widget build(BuildContext context) {
    final ownerName = _value(name);
    final ownerEmail = _value(email);
    final ownerPhone = _value(phone);
    final ownerBusiness = _value(businessName);

    final hasImage =
        imageUrl != null &&
            imageUrl!.trim().isNotEmpty;

    final initial = ownerName == '—'
        ? 'O'
        : ownerName.characters.first.toUpperCase();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: ProfileScreen.border,
        ),
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ProfileScreen.green
                        .withValues(alpha: .25),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor:
                  const Color(0xffEDF7DE),
                  backgroundImage: hasImage
                      ? NetworkImage(imageUrl!)
                      : null,
                  child: hasImage
                      ? null
                      : Text(
                    initial,
                    style: const TextStyle(
                      color: ProfileScreen.green,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: 0,
                right: 0,
                child: Material(
                  color: ProfileScreen.green,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: onEdit,
                    customBorder:
                    const CircleBorder(),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration:
                      const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Colors.white,
                        size: 19,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Text(
            ownerName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ProfileScreen.navy,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            ownerEmail,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ProfileScreen.secondary,
              fontSize: 13.5,
            ),
          ),

          const SizedBox(height: 12),

          if (isVerified == true)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: ProfileScreen.green
                    .withValues(alpha: .10),
                borderRadius:
                BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.verified_rounded,
                    color: ProfileScreen.green,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    languageProvider.translate(
                      'verified_stadium_owner',
                    ),
                    style: const TextStyle(
                      color: ProfileScreen.green,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          const Divider(
            height: 1,
            color: ProfileScreen.border,
          ),

          const SizedBox(height: 8),

          _ProfileInfoRow(
            icon: Icons.phone_outlined,
            title: languageProvider.translate(
              'phone',
            ),
            value: ownerPhone,
          ),

          _ProfileInfoRow(
            icon: Icons.business_outlined,
            title: languageProvider.translate(
              'business_name',
            ),
            value: ownerBusiness,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFILE INFO ROW
// ============================================================

class _ProfileInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _ProfileInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 9,
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: ProfileScreen.background,
              borderRadius:
              BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: ProfileScreen.navy,
              size: 19,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: ProfileScreen.secondary,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: ProfileScreen.navy,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
// SECTION TITLE
// ============================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: ProfileScreen.navy,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

// ============================================================
// SETTINGS CARD
// ============================================================

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(19),
        border: Border.all(
          color: ProfileScreen.border,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// ============================================================
// SETTING TILE
// ============================================================

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding:
          const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 2,
          ),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .10),
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: ProfileScreen.navy,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14,
            color: Color(0xffA1A4AC),
          ),
        ),

        if (showDivider)
          const Divider(
            height: 1,
            indent: 70,
            endIndent: 14,
            color: ProfileScreen.border,
          ),
      ],
    );
  }
}

// ============================================================
// QUICK ACTION
// ============================================================

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(17),
        child: Container(
          height: 88,
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: ProfileScreen.border,
            ),
          ),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: ProfileScreen.green
                      .withValues(alpha: .10),
                  borderRadius:
                  BorderRadius.circular(11),
                ),
                child: Icon(
                  icon,
                  color: ProfileScreen.green,
                  size: 19,
                ),
              ),

              const SizedBox(height: 7),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ProfileScreen.navy,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOGOUT BUTTON
// ============================================================

class _LogoutButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _LogoutButton({
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: const Icon(
          Icons.logout_rounded,
          color: Colors.red,
          size: 20,
        ),
        label: Text(
          title,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w800,
            fontSize: 14.5,
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor:
          Colors.red.withValues(alpha: .035),
          side: BorderSide(
            color: Colors.red.withValues(alpha: .18),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
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
  final Future<bool> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: ProfileScreen.navy
                    .withValues(alpha: .06),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                color: ProfileScreen.secondary,
                size: 34,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ProfileScreen.navy,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: const Text(
                'Retry',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                ProfileScreen.green,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}