import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';

import '../providers/academy_provider.dart';
import '../widgets/academy_card.dart';

class AcademiesScreen extends StatefulWidget {
  const AcademiesScreen({super.key});
  @override
  State<AcademiesScreen> createState() => _AcademiesScreenState();
}

class _AcademiesScreenState extends State<AcademiesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<AcademyProvider>().loadAcademies();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;
    final provider = context.watch<AcademyProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),

      // ============================================================
      // APP BAR
      // ============================================================

      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,

        title: Text(
          t('academies'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),

      // ============================================================
      // BODY
      // ============================================================

      body: RefreshIndicator(
        color: const Color(0xff7CC000),

        onRefresh: () async {
          await provider.loadAcademies();
        },

        child: _buildBody(
          context,
          provider,
          t,
        ),
      ),
    );
  }

  // ================================================================
  // BODY BUILDER
  // ================================================================

  Widget _buildBody(
      BuildContext context,
      AcademyProvider provider,
      String Function(String) t,
      ) {
    // ==============================================================
    // LOADING
    // ==============================================================

    if (provider.isLoadingAcademies &&
        provider.academies.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xff7CC000),
        ),
      );
    }

    // ==============================================================
    // ERROR
    // ==============================================================

    if (provider.errorMessage != null &&
        provider.academies.isEmpty) {
      return _buildErrorState(
        provider,
        t,
      );
    }

    // ==============================================================
    // EMPTY
    // ==============================================================

    if (provider.academies.isEmpty) {
      return _buildEmptyState(t);
    }

    // ==============================================================
    // SUCCESS
    // ==============================================================

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        24,
      ),

      children: [
        // ----------------------------------------------------------
        // HEADER
        // ----------------------------------------------------------

        Text(
          t('discover_academies'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          t('find_the_right_academy_for_you'),
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 20),

        // ----------------------------------------------------------
        // ACADEMIES
        // ----------------------------------------------------------

        ...provider.academies.map(
              (academy) => Padding(
            padding: const EdgeInsets.only(
              bottom: 16,
            ),
            child: AcademyCard(
              academy: academy,
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // ERROR STATE
  // ================================================================

  Widget _buildErrorState(
      AcademyProvider provider,
      String Function(String) t,
      ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),

      children: [
        const SizedBox(height: 120),

        const Icon(
          Icons.cloud_off_rounded,
          size: 64,
          color: Color(0xff1E1446),
        ),

        const SizedBox(height: 20),

        Text(
          t('something_went_wrong'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          provider.errorMessage ??
              t('unable_to_load_academies'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),

        const SizedBox(height: 24),

        Center(
          child: ElevatedButton(
            onPressed: provider.isLoadingAcademies
                ? null
                : provider.loadAcademies,

            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff7CC000),
              foregroundColor: Colors.white,
              elevation: 0,

              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 14,
              ),

              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),

            child: Text(
              t('try_again'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ================================================================
  // EMPTY STATE
  // ================================================================

  Widget _buildEmptyState(
      String Function(String) t,
      ) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.symmetric(
        horizontal: 24,
      ),

      children: [
        const SizedBox(height: 120),

        const Icon(
          Icons.sports_soccer_rounded,
          size: 72,
          color: Color(0xff7CC000),
        ),

        const SizedBox(height: 20),

        Text(
          t('no_academies_available'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          t('check_back_later_for_new_academies'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}