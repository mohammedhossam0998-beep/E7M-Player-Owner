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
import 'package:e7m/shared/utils/image_url_helper.dart'; // <-- إضافة

class _AppColors {
  static const green = Color(0xff7CC000);
  static const navy = Color(0xff1E1446);
  static const background = Color(0xffF6F8FB);
  static const border = Color(0xffE8EAF0);
  static const textSecondary = Color(0xff7A7D87);
}

class OwnerProfileScreen extends StatefulWidget {
  const OwnerProfileScreen({super.key});

  @override
  State<OwnerProfileScreen> createState() =>
      _OwnerProfileScreenState();
}

class _OwnerProfileScreenState extends State<OwnerProfileScreen> {
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

  Future<void> _openEditProfile() async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const EditProfileScreen(),
      ),
    );

    if (updated == true && mounted) {
      await context.read<OwnerProfileProvider>().refreshProfile();
    }
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
              color: _AppColors.navy,
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            languageProvider.translate(
              'logout_confirmation',
            ),
            style: const TextStyle(
              color: _AppColors.textSecondary,
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
                  color: _AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                languageProvider.translate('logout'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
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
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider =
    context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: _AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: _AppColors.green,
          onRefresh: _refresh,
          child: Consumer<OwnerProfileProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading &&
                  !provider.hasProfile) {
                return const _LoadingView();
              }

              if (!provider.hasProfile) {
                return _ErrorView(
                  message: provider.errorMessage,
                  onRetry: provider.loadProfile,
                );
              }

              final profile = provider.profile!;

              return CustomScrollView(
                physics:
                const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        12,
                        20,
                        0,
                      ),
                      child: Column(
                        children: [
                          _buildTopBar(
                            languageProvider,
                          ),

                          const SizedBox(height: 20),

                          _buildProfileHeader(
                            profile,
                            languageProvider,
                          ),

                          const SizedBox(height: 22),

                          _buildStats(
                            languageProvider,
                          ),

                          const SizedBox(height: 26),

                          _buildSectionTitle(
                            languageProvider.translate(
                              'personal_information',
                            ),
                          ),

                          const SizedBox(height: 12),

                          _buildInformationCard([
                            _InfoRow(
                              icon:
                              Icons.person_outline_rounded,
                              title:
                              languageProvider.translate(
                                'full_name',
                              ),
                              value:
                              _valueOrDash(
                                profile.fullName,
                              ),
                            ),
                            _InfoRow(
                              icon:
                              Icons.email_outlined,
                              title:
                              languageProvider.translate(
                                'email',
                              ),
                              value:
                              _valueOrDash(
                                profile.email,
                              ),
                            ),
                            _InfoRow(
                              icon:
                              Icons.phone_outlined,
                              title:
                              languageProvider.translate(
                                'phone_number',
                              ),
                              value:
                              _valueOrDash(
                                profile.phone,
                              ),
                            ),
                          ]),

                          const SizedBox(height: 22),

                          _buildSectionTitle(
                            languageProvider.translate(
                              'business_information',
                            ),
                          ),

                          const SizedBox(height: 12),

                          _buildInformationCard([
                            _InfoRow(
                              icon:
                              Icons.business_outlined,
                              title:
                              languageProvider.translate(
                                'business_name',
                              ),
                              value:
                              _valueOrDash(
                                profile.businessName,
                              ),
                            ),
                            _InfoRow(
                              icon:
                              Icons.phone_outlined,
                              title:
                              languageProvider.translate(
                                'business_phone',
                              ),
                              value:
                              _valueOrDash(
                                profile.businessPhone,
                              ),
                            ),
                            _InfoRow(
                              icon:
                              Icons.alternate_email_rounded,
                              title:
                              languageProvider.translate(
                                'business_email',
                              ),
                              value:
                              _valueOrDash(
                                profile.businessEmail,
                              ),
                            ),
                          ]),

                          const SizedBox(height: 22),

                          _buildSectionTitle(
                            languageProvider.translate(
                              'quick_actions',
                            ),
                          ),

                          const SizedBox(height: 12),

                          _buildQuickActions(
                            languageProvider,
                          ),

                          const SizedBox(height: 26),

                          _buildSectionTitle(
                            languageProvider.translate(
                              'account',
                            ),
                          ),

                          const SizedBox(height: 12),

                          _buildSettings(
                            languageProvider,
                          ),

                          const SizedBox(height: 18),

                          _buildLogoutButton(
                            languageProvider,
                          ),

                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
      LanguageProvider languageProvider,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(
            languageProvider.translate('profile'),
            style: const TextStyle(
              color: _AppColors.navy,
              fontSize: 25,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),

        Consumer<OwnerProfileProvider>(
          builder: (context, provider, _) {
            return IconButton(
              onPressed: provider.isLoading
                  ? null
                  : _refresh,
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(
                  color: _AppColors.border,
                ),
              ),
              icon: const Icon(
                Icons.refresh_rounded,
                color: _AppColors.navy,
                size: 21,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProfileHeader(
      dynamic profile,
      LanguageProvider languageProvider,
      ) {
    ImageProvider? image;

    // === التعديل هنا ===
    // بدل ما نستخدم profile.profileImage مباشرة في NetworkImage
    // (وهو ممكن يكون مسار نسبي زي /uploads/... مش رابط كامل)،
    // بنمرره على ImageUrlHelper.build عشان يبني الرابط الكامل الصح
    // ويشيل أي سلاش زيادة (//) في الأول.
    final imageUrl = ImageUrlHelper.build(
      profile.profileImage?.toString(),
    );

    if (imageUrl.isNotEmpty) {
      image = NetworkImage(imageUrl);
    }
    // === نهاية التعديل ===

    final name = _valueOrDash(
      profile.fullName,
    );

    final initial = name != '—'
        ? name.substring(0, 1).toUpperCase()
        : 'O';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _AppColors.border,
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
                    color: _AppColors.green
                        .withValues(alpha: .22),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor:
                  const Color(0xffEEF8E1),
                  backgroundImage: image,
                  child: image == null
                      ? Text(
                    initial,
                    style: const TextStyle(
                      color: _AppColors.green,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                      : null,
                ),
              ),

              Positioned(
                right: -2,
                bottom: 2,
                child: Container(
                  width: 31,
                  height: 31,
                  decoration: BoxDecoration(
                    color: _AppColors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _AppColors.navy,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),

          const SizedBox(height: 5),

          Text(
            _valueOrDash(profile.email),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _AppColors.textSecondary,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 14),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: _AppColors.green
                  .withValues(alpha: .10),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.verified_rounded,
                  color: _AppColors.green,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  languageProvider.translate(
                    'verified_stadium_owner',
                  ),
                  style: const TextStyle(
                    color: _AppColors.green,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 46,
            child: OutlinedButton.icon(
              onPressed: _openEditProfile,
              icon: const Icon(
                Icons.edit_outlined,
                size: 18,
              ),
              label: Text(
                languageProvider.translate(
                  'edit_profile',
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: _AppColors.navy,
                side: const BorderSide(
                  color: _AppColors.border,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(
      LanguageProvider languageProvider,
      ) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.stadium_outlined,
            title: languageProvider.translate(
              'stadiums',
            ),
            value: '—',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const OwnerStadiumsScreen(),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _StatCard(
            icon: Icons.book_online_outlined,
            title: languageProvider.translate(
              'bookings',
            ),
            value: '—',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const OwnerBookingsScreen(),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _StatCard(
            icon: Icons.payments_outlined,
            title: languageProvider.translate(
              'revenue',
            ),
            value: '—',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const RevenueScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        title,
        style: const TextStyle(
          color: _AppColors.navy,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildInformationCard(
      List<_InfoRow> rows,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _AppColors.border,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            _buildInfoRow(rows[i]),

            if (i != rows.length - 1)
              const Divider(
                height: 1,
                color: _AppColors.border,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(_InfoRow row) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _AppColors.green
                  .withValues(alpha: .10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              row.icon,
              color: _AppColors.green,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  row.title,
                  style: const TextStyle(
                    color: _AppColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  row.value,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _AppColors.navy,
                    fontSize: 14.5,
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

  Widget _buildQuickActions(
      LanguageProvider languageProvider,
      ) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.stadium_outlined,
            title: languageProvider.translate(
              'my_stadiums',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const OwnerStadiumsScreen(),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _ActionCard(
            icon: Icons.reviews_outlined,
            title: languageProvider.translate(
              'reviews',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const ReviewsScreen(),
                ),
              );
            },
          ),
        ),

        const SizedBox(width: 10),

        Expanded(
          child: _ActionCard(
            icon: Icons.bar_chart_rounded,
            title: languageProvider.translate(
              'revenue',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const RevenueScreen(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSettings(
      LanguageProvider languageProvider,
      ) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _AppColors.border,
        ),
      ),
      child: Column(
        children: [
          _SettingTile(
            icon: Icons.notifications_none_rounded,
            title: languageProvider.translate(
              'notifications',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const NotificationsScreen(),
                ),
              );
            },
          ),

          _SettingTile(
            icon: Icons.lock_outline_rounded,
            title: languageProvider.translate(
              'change_password',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const ChangePasswordScreen(),
                ),
              );
            },
          ),

          _SettingTile(
            icon: Icons.language_rounded,
            title: languageProvider.translate(
              'language',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const LanguageScreen(),
                ),
              );
            },
          ),

          _SettingTile(
            icon: Icons.privacy_tip_outlined,
            title: languageProvider.translate(
              'privacy_policy',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const PrivacyPolicyScreen(),
                ),
              );
            },
          ),

          _SettingTile(
            icon: Icons.help_outline_rounded,
            title: languageProvider.translate(
              'help_support',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const HelpSupportScreen(),
                ),
              );
            },
          ),

          _SettingTile(
            icon: Icons.info_outline_rounded,
            title: languageProvider.translate(
              'about_e7m',
            ),
            showDivider: false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                  const AboutScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(
      LanguageProvider languageProvider,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: _logout,
        icon: const Icon(
          Icons.logout_rounded,
          color: Colors.red,
        ),
        label: Text(
          languageProvider.translate('logout'),
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Colors.red.withValues(alpha: .20),
          ),
          backgroundColor:
          Colors.red.withValues(alpha: .04),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  String _valueOrDash(dynamic value) {
    if (value == null) return '—';

    final text = value.toString().trim();

    if (text.isEmpty || text == 'null') {
      return '—';
    }

    return text;
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
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
          padding: const EdgeInsets.symmetric(
            vertical: 14,
            horizontal: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: _AppColors.border,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: _AppColors.green,
                size: 22,
              ),

              const SizedBox(height: 8),

              Text(
                value,
                style: const TextStyle(
                  color: _AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _AppColors.textSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 82,
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 10,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _AppColors.border,
            ),
          ),
          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _AppColors.green
                      .withValues(alpha: .10),
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: _AppColors.green,
                  size: 19,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _AppColors.navy,
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

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool showDivider;

  const _SettingTile({
    required this.icon,
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
            horizontal: 15,
            vertical: 2,
          ),
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _AppColors.green
                  .withValues(alpha: .10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: _AppColors.green,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              color: _AppColors.navy,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.grey,
            size: 14,
          ),
        ),

        if (showDivider)
          const Divider(
            height: 1,
            indent: 70,
            endIndent: 15,
            color: _AppColors.border,
          ),
      ],
    );
  }
}

class _InfoRow {
  final IconData icon;
  final String title;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: _AppColors.green,
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(
          height: MediaQuery.sizeOf(context).height * .65,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey
                          .withValues(alpha: .10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_off_rounded,
                      color: Colors.grey,
                      size: 34,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    message ?? 'Something went wrong',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: _AppColors.navy,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 14),

                  TextButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: _AppColors.green,
                    ),
                    label: const Text(
                      'Retry',
                      style: TextStyle(
                        color: _AppColors.green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}