import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:e7m/features/owner/dashboard/owner_dashboard_screen.dart';
import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/core/theme/app_colors.dart';
import 'package:e7m/core/theme/app_spacing.dart';

class AccountApprovedScreen extends StatefulWidget {
  const AccountApprovedScreen({super.key});

  @override
  State<AccountApprovedScreen> createState() =>
      _AccountApprovedScreenState();
}

class _AccountApprovedScreenState
    extends State<AccountApprovedScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const OwnerDashboardScreen(),
        ),
            (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 70),
                ),
                const SizedBox(height: 30),
                Text(
                  t('account_approved'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkNavy,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  t('welcome_to_e7m'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
                const SizedBox(height: 40),

                const CircularProgressIndicator(
                  color: AppColors.secondary,
                ),

                const SizedBox(height: 20),

                const Text(
                  "Redirecting to Dashboard...",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
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