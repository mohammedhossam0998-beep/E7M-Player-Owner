import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/features/player/settings/language_settings_screen.dart';

// Profile
import '../profile/presentation/screens/player_profile_screen.dart';

// Settings screens
import '../settings/presentation/screens/change_password_screen.dart';
import 'package:e7m/features/player/settings/notification_settings_screen.dart';
import 'about_e7m_screen.dart';
import 'privacy_security_screen.dart';
import 'help_support_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ============================================================
  // BRAND COLORS (calm palette)
  // ============================================================

  static const Color backgroundColor = Color(0xffFBFBF9);
  static const Color darkNavy = Color(0xff1E1446);
  static const Color calmGreen = Color(0xff5C7A2A);
  static const Color mutedText = Color(0xff9A9A8F);
  static const Color hairline = Color(0xffF0F0EA);
  static const Color iconBadgeBg = Color(0xffF1F3EC);

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: backgroundColor,

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          t('settings'),
          style: const TextStyle(
            color: darkNavy,
            fontWeight: FontWeight.w500,
            fontSize: 20,
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ======================================================
            // SETTINGS LIST
            // ======================================================

            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: darkNavy.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ==================================================
                      // EDIT PROFILE
                      // ==================================================

                      buildItem(
                        context,
                        Icons.person_outline,
                        t('edit_profile'),
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const PlayerProfileScreen(),
                            ),
                          );
                        },
                      ),

                      // ==================================================
                      // CHANGE PASSWORD
                      // ==================================================

                      buildItem(
                        context,
                        Icons.lock_outline,
                        t('change_password'),
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const ChangePasswordScreen(),
                            ),
                          );
                        },
                      ),

                      // ==================================================
                      // NOTIFICATION SETTINGS
                      // ==================================================

                      buildItem(
                        context,
                        Icons.notifications_none,
                        t('notification_settings'),
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const NotificationSettingsScreen(),
                            ),
                          );
                        },
                      ),

                      // ==================================================
                      // PRIVACY & SECURITY
                      // ==================================================

                      buildItem(
                        context,
                        Icons.security,
                        t('privacy_security'),
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const PrivacySecurityScreen(),
                            ),
                          );
                        },
                      ),

                      // ==================================================
                      // HELP & SUPPORT
                      // ==================================================

                      buildItem(
                        context,
                        Icons.help_outline,
                        t('help_support'),
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const HelpSupportScreen(),
                            ),
                          );
                        },
                      ),

                      // ==================================================
                      // ABOUT E7M
                      // ==================================================

                      buildItem(
                        context,
                        Icons.info_outline,
                        t('about_e7m'),
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const Aboute7mScreen(),
                            ),
                          );
                        },
                      ),

                      // ==================================================
                      // LANGUAGE
                      // ==================================================

                      buildItem(
                        context,
                        Icons.language,
                        t('language'),
                            () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                              const LanguageSettingsScreen(),
                            ),
                          );
                        },
                        showDivider: false,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================================================================
  // SETTINGS ITEM
  // ================================================================

  Widget buildItem(
      BuildContext context,
      IconData icon,
      String title,
      VoidCallback onTap, {
        bool showDivider = true,
      }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: iconBadgeBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: calmGreen,
                    size: 20,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: darkNavy,
                    ),
                  ),
                ),

                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left
                      : Icons.chevron_right,
                  size: 20,
                  color: mutedText,
                ),
              ],
            ),
          ),
        ),

        if (showDivider)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18),
            child: Divider(
              height: 1,
              thickness: 0.5,
              color: hairline,
            ),
          ),
      ],
    );
  }
}