import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';

import '../../data/models/academy_program_model.dart';
import '../providers/academy_provider.dart';
import '../widgets/academy_program_card.dart';

class AcademyDetailsScreen extends StatefulWidget {
  final int academyId;

  const AcademyDetailsScreen({
    super.key,
    required this.academyId,
  });

  @override
  State<AcademyDetailsScreen> createState() =>
      _AcademyDetailsScreenState();
}

class _AcademyDetailsScreenState
    extends State<AcademyDetailsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<AcademyProvider>()
          .loadAcademyData(widget.academyId);
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

        title: Text(
          t('academy_details'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),

// ============================================================
// BODY
// ============================================================

      body: _buildBody(
        context,
        provider,
        t,
      ),
    );
  }

// ================================================================
// BODY
// ================================================================

  Widget _buildBody(
      BuildContext context,
      AcademyProvider provider,
      String Function(String) t,
      ) {
    if (provider.isLoadingDetails &&
        provider.selectedAcademy == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xff7CC000),
        ),
      );
    }

    if (provider.selectedAcademy == null &&
        provider.errorMessage != null) {
      return _buildErrorState(
        provider,
        t,
      );
    }

    final academy = provider.selectedAcademy;

    if (academy == null) {
      return _buildErrorState(
        provider,
        t,
      );
    }

    return RefreshIndicator(
      color: const Color(0xff7CC000),

      onRefresh: () async {
        await provider.loadAcademyData(
          widget.academyId,
        );
      },

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          30,
        ),
        children: [
// ==========================================================
// HERO
// ==========================================================

          _buildHeroImage(
            academy.imageUrl,
          ),

          const SizedBox(height: 18),

// ==========================================================
// ACADEMY NAME
// ==========================================================

          Text(
            academy.name,
            style: const TextStyle(
              color: Color(0xff1E1446),
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

// ==========================================================
// LOCATION
// ==========================================================

          if (_hasLocation(
            academy.cityName,
            academy.address,
          ))
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 20,
                  color: Color(0xff7CC000),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    _locationText(
                      academy.cityName,
                      academy.address,
                    ),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

// ==========================================================
// DESCRIPTION
// ==========================================================

          if (academy.description != null &&
              academy.description!.trim().isNotEmpty) ...[
            const SizedBox(height: 20),

            _buildSectionTitle(
              t('about_academy'),
            ),

            const SizedBox(height: 8),

            Text(
              academy.description!.trim(),
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
                height: 1.55,
              ),
            ),
          ],

          const SizedBox(height: 28),

// ==========================================================
// PROGRAMS TITLE
// ==========================================================

          Row(
            children: [
              Expanded(
                child: _buildSectionTitle(
                  t('training_programs'),
                ),
              ),

              if (provider.isLoadingPrograms)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xff7CC000),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

// ==========================================================
// PROGRAMS
// ==========================================================

          if (provider.programs.isEmpty &&
              !provider.isLoadingPrograms)
            _buildNoProgramsState(t)
          else
            ...provider.programs.map(
                  (program) => Padding(
                padding: const EdgeInsets.only(
                  bottom: 14,
                ),
                child: AcademyProgramCard(
                  program: program,
                  isLoading: provider.isEnrolling,
                  onApply: () => _handleEnrollment(
                    context,
                    provider,
                    program,
                    t,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

// ================================================================
// HERO IMAGE
// ================================================================

  Widget _buildHeroImage(
      String? imageUrl,
      ) {
    final url = imageUrl?.trim();

    return Container(
      height: 210,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xffECEDE8),
        borderRadius: BorderRadius.circular(22),
      ),
      clipBehavior: Clip.antiAlias,
      child: url == null || url.isEmpty
          ? const Center(
        child: Icon(
          Icons.sports_soccer_rounded,
          size: 70,
          color: Color(0xff7CC000),
        ),
      )
          : Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (
            context,
            error,
            stackTrace,
            ) {
          return const Center(
            child: Icon(
              Icons.sports_soccer_rounded,
              size: 70,
              color: Color(0xff7CC000),
            ),
          );
        },
        loadingBuilder: (
            context,
            child,
            loadingProgress,
            ) {
          if (loadingProgress == null) {
            return child;
          }

          return const Center(
            child: CircularProgressIndicator(
              color: Color(0xff7CC000),
            ),
          );
        },
      ),
    );
  }

// ================================================================
// ENROLLMENT
// ================================================================

  Future<void> _handleEnrollment(
      BuildContext context,
      AcademyProvider provider,
      AcademyProgramModel program,
      String Function(String) t,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),

          title: Text(
            t('confirm_application'),
            style: const TextStyle(
              color: Color(0xff1E1446),
              fontWeight: FontWeight.bold,
            ),
          ),

          content: Text(
            '${t('apply_for_program')} "${program.name}"?',
            style: const TextStyle(
              color: Colors.black54,
              height: 1.4,
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(
                t('cancel'),
                style: const TextStyle(
                  color: Color(0xff1E1446),
                ),
              ),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7CC000),
                foregroundColor: Colors.white,
                elevation: 0,
              ),
              child: Text(
                t('confirm'),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final success = await provider.enrollInProgram(
      academyId: widget.academyId,
      programId: program.id,
    );

    if (!context.mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            t('application_submitted_successfully'),
          ),
          backgroundColor: const Color(0xff7CC000),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                t('unable_to_submit_application'),
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

// ================================================================
// SECTION TITLE
// ================================================================

  Widget _buildSectionTitle(
      String title,
      ) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xff1E1446),
        fontSize: 19,
        fontWeight: FontWeight.bold,
      ),
    );
  }

// ================================================================
// NO PROGRAMS
// ================================================================

  Widget _buildNoProgramsState(
      String Function(String) t,
      ) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.event_busy_rounded,
            size: 46,
            color: Color(0xff7CC000),
          ),

          const SizedBox(height: 12),

          Text(
            t('no_programs_available'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xff1E1446),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

// ================================================================
// ERROR
// ================================================================

  Widget _buildErrorState(
      AcademyProvider provider,
      String Function(String) t,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 60,
              color: Color(0xff1E1446),
            ),

            const SizedBox(height: 18),

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
                  t('unable_to_load_academy'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                provider.loadAcademyData(
                  widget.academyId,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7CC000),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: Text(
                t('try_again'),
              ),
            ),
          ],
        ),
      ),
    );
  }

// ================================================================
// LOCATION HELPERS
// ================================================================

  bool _hasLocation(
      String? city,
      String? address,
      ) {
    return (city != null && city.trim().isNotEmpty) ||
        (address != null && address.trim().isNotEmpty);
  }

  String _locationText(
      String? city,
      String? address,
      ) {
    final cleanCity = city?.trim();
    final cleanAddress = address?.trim();

    if (cleanCity != null &&
        cleanCity.isNotEmpty &&
        cleanAddress != null &&
        cleanAddress.isNotEmpty) {
      return '$cleanCity • $cleanAddress';
    }

    if (cleanCity != null && cleanCity.isNotEmpty) {
      return cleanCity;
    }

    return cleanAddress ?? '';
  }
}