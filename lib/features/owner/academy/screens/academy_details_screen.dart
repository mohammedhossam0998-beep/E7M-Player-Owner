import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/academy_model.dart';
import '../controller/academy_controller.dart';
import 'edit_academy_screen.dart';

import 'programs_screen.dart';
import 'schedule_screen.dart';
import 'academy_coaches_screen.dart';
import 'academy_players_screen.dart';

class AcademyDetailsScreen extends StatefulWidget {
  final String academyId;

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
  // ============================================================
  // ACADEMY ID
  // ============================================================

  int? get _academyId {
    return int.tryParse(widget.academyId);
  }

  // ============================================================
  // INIT
  // ============================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<AcademyController>()
          .loadAcademyById(widget.academyId);
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Academy Details',
        ),
        centerTitle: true,
        actions: [
          Consumer<AcademyController>(
            builder: (
                context,
                controller,
                child,
                ) {
              final academy =
                  controller.selectedAcademy;

              if (academy == null) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Edit Academy',
                icon: const Icon(
                  Icons.edit_outlined,
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditAcademyScreen(
                            academy: academy,
                          ),
                    ),
                  );

                  if (!mounted) return;

                  await context
                      .read<AcademyController>()
                      .loadAcademyById(
                    widget.academyId,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Consumer<AcademyController>(
        builder: (
            context,
            controller,
            child,
            ) {
          // ========================================================
          // LOADING
          // ========================================================

          if (controller.isLoading &&
              controller.selectedAcademy == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ========================================================
          // ERROR
          // ========================================================

          if (controller.hasError &&
              controller.selectedAcademy == null) {
            return _buildError(
              context,
              controller.errorMessage,
            );
          }

          final academy =
              controller.selectedAcademy;

          // ========================================================
          // NO DATA
          // ========================================================

          if (academy == null) {
            return const Center(
              child: Text(
                'Academy not found',
              ),
            );
          }

          // ========================================================
          // INVALID ID
          // ========================================================

          if (_academyId == null) {
            return const Center(
              child: Text(
                'Invalid academy ID',
              ),
            );
          }

          // ========================================================
          // CONTENT
          // ========================================================

          return RefreshIndicator(
            onRefresh: () async {
              await controller.loadAcademyById(
                widget.academyId,
              );
            },
            child: SingleChildScrollView(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding:
              const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // HEADER
                  // ==================================================

                  _buildAcademyHeader(
                    context,
                    academy,
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // ACADEMY INFORMATION
                  // ==================================================

                  _buildSectionTitle(
                    'Academy Information',
                  ),

                  const SizedBox(height: 10),

                  _buildInfoCard(
                    context,
                    academy,
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // PITCH INFORMATION
                  // ==================================================

                  _buildSectionTitle(
                    'Pitch Information',
                  ),

                  const SizedBox(height: 10),

                  _buildPitchCard(
                    context,
                    academy,
                  ),

                  const SizedBox(height: 24),

                  // ==================================================
                  // MANAGEMENT
                  // ==================================================

                  _buildSectionTitle(
                    'Academy Management',
                  ),

                  const SizedBox(height: 10),

                  _buildManagementGrid(
                    context,
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // ACADEMY HEADER
  // ============================================================

  Widget _buildAcademyHeader(
      BuildContext context,
      AcademyModel academy,
      ) {
    final hasImage =
        academy.imageUrl != null &&
            academy.imageUrl!
                .trim()
                .isNotEmpty;

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        if (hasImage)
          ClipRRect(
            borderRadius:
            BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                academy.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (
                    context,
                    error,
                    stackTrace,
                    ) {
                  return _buildImagePlaceholder();
                },
              ),
            ),
          )
        else
          _buildImagePlaceholder(),

        const SizedBox(height: 16),

        Row(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                academy.name,
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  fontSize: 24,
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ),

            const SizedBox(width: 10),

            _buildStatusChip(
              context,
              academy.status,
            ),
          ],
        ),
      ],
    );
  }

  // ============================================================
  // ACADEMY INFORMATION
  // ============================================================

  Widget _buildInfoCard(
      BuildContext context,
      AcademyModel academy,
      ) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow(
              icon:
              Icons.phone_outlined,
              label: 'Phone',
              value:
              academy.phoneNumber,
            ),

            _buildDivider(),

            _buildDetailRow(
              icon:
              Icons.location_on_outlined,
              label: 'Address',
              value:
              academy.address,
            ),

            _buildDivider(),

            _buildDetailRow(
              icon:
              Icons.location_city_outlined,
              label: 'City ID',
              value:
              academy.cityId,
            ),

            _buildDivider(),

            _buildDetailRow(
              icon:
              Icons.description_outlined,
              label: 'Description',
              value:
              academy.description,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // PITCH INFORMATION
  // ============================================================

  Widget _buildPitchCard(
      BuildContext context,
      AcademyModel academy,
      ) {
    return Card(
      child: Padding(
        padding:
        const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow(
              icon:
              Icons.sports_soccer_outlined,
              label: 'Pitch ID',
              value:
              academy.pitchId,
            ),

            _buildDivider(),

            _buildDetailRow(
              icon:
              Icons.sports_soccer,
              label: 'Pitch Name',
              value:
              academy.pitchName,
            ),

            _buildDivider(),

            _buildDetailRow(
              icon:
              Icons.verified_outlined,
              label: 'Pitch Status',
              value:
              academy.pitchStatus,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MANAGEMENT GRID
  // ============================================================

  Widget _buildManagementGrid(
      BuildContext context,
      ) {
    return LayoutBuilder(
      builder: (
          context,
          constraints,
          ) {
        final double width =
            constraints.maxWidth;

        const double spacing = 12.0;

        final double cardWidth =
        width <= 0.0
            ? 0.0
            : (width - spacing) / 2.0;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: _ManagementCard(
                icon:
                Icons.menu_book_outlined,
                title: 'Programs',
                subtitle:
                'Training programs',
                onTap: () {
                  final academyId =
                      _academyId;

                  if (academyId == null) {
                    _showMessage(
                      'Invalid academy ID',
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProgramsScreen(
                            academyId:
                            academyId,
                          ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: _ManagementCard(
                icon:
                Icons.calendar_month_outlined,
                title: 'Schedule',
                subtitle:
                'Training schedule',
                onTap: () {
                  final academyId =
                      _academyId;

                  if (academyId == null) {
                    _showMessage(
                      'Invalid academy ID',
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ScheduleScreen(
                            academyId:
                            academyId,
                          ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: _ManagementCard(
                icon:
                Icons.person_outline,
                title: 'Coaches',
                subtitle:
                'Manage coaches',
                onTap: () {
                  final academyId =
                      _academyId;

                  if (academyId == null) {
                    _showMessage(
                      'Invalid academy ID',
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AcademyCoachesScreen(
                            academyId:
                            academyId,
                          ),
                    ),
                  );
                },
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: _ManagementCard(
                icon:
                Icons.people_outline,
                title: 'Players',
                subtitle:
                'Enrollments',
                onTap: () {
                  final academyId =
                      _academyId;

                  if (academyId == null) {
                    _showMessage(
                      'Invalid academy ID',
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AcademyPlayersScreen(
                            academyId:
                            academyId,
                          ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // DETAIL ROW
  // ============================================================

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String? value,
  }) {
    final displayValue =
    value != null &&
        value.trim().isNotEmpty
        ? value
        : 'Not available';

    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 21,
        ),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style:
                const TextStyle(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                displayValue,
                maxLines: 5,
                overflow:
                TextOverflow.ellipsis,
                style:
                const TextStyle(
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // DIVIDER
  // ============================================================

  Widget _buildDivider() {
    return const Padding(
      padding:
      EdgeInsets.symmetric(
        vertical: 14,
      ),
      child: Divider(
        height: 1,
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(
      String title,
      ) {
    return Text(
      title,
      maxLines: 1,
      overflow:
      TextOverflow.ellipsis,
      style:
      const TextStyle(
        fontSize: 19,
        fontWeight:
        FontWeight.w700,
      ),
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _buildStatusChip(
      BuildContext context,
      String status,
      ) {
    final normalized =
    status.toLowerCase();

    IconData icon;

    if (normalized == 'approved') {
      icon =
          Icons.check_circle_outline;
    } else if (normalized == 'pending') {
      icon =
          Icons.access_time;
    } else if (normalized == 'inactive') {
      icon =
          Icons.pause_circle_outline;
    } else {
      icon =
          Icons.info_outline;
    }

    return Container(
      constraints:
      const BoxConstraints(
        maxWidth: 110,
      ),
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration:
      BoxDecoration(
        borderRadius:
        BorderRadius.circular(20),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize:
        MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
          ),

          const SizedBox(width: 5),

          Flexible(
            child: Text(
              status,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style:
              const TextStyle(
                fontSize: 12,
                fontWeight:
                FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _buildImagePlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration:
        BoxDecoration(
          borderRadius:
          BorderRadius.circular(16),
          color:
          Colors.grey.shade200,
        ),
        child: Icon(
          Icons.school_outlined,
          size: 64,
          color:
          Colors.grey.shade500,
        ),
      ),
    );
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildError(
      BuildContext context,
      String? message,
      ) {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
            ),

            const SizedBox(height: 16),

            Text(
              message ??
                  'Failed to load academy',
              textAlign:
              TextAlign.center,
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                context
                    .read<AcademyController>()
                    .loadAcademyById(
                  widget.academyId,
                );
              },
              child:
              const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _showMessage(
      String message,
      ) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}

// ============================================================================
// MANAGEMENT CARD
// ============================================================================

class _ManagementCard
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ManagementCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(
      BuildContext context,
      ) {
    return Card(
      elevation: 2,
      clipBehavior:
      Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 105,
          child: Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 10,
            ),
            child: Column(
              mainAxisAlignment:
              MainAxisAlignment.center,
              mainAxisSize:
              MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: Theme.of(context)
                      .colorScheme
                      .primary,
                ),

                const SizedBox(height: 6),

                Text(
                  title,
                  textAlign:
                  TextAlign.center,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  subtitle,
                  textAlign:
                  TextAlign.center,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color:
                    Colors.grey.shade600,
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