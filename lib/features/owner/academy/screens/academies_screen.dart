import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/academy_controller.dart';
import '../models/academy_model.dart';
import 'academy_details_screen.dart';
import 'create_academy_screen.dart';

class AcademiesScreen extends StatefulWidget {
  const AcademiesScreen({
    super.key,
  });

  @override
  State<AcademiesScreen> createState() =>
      _AcademiesScreenState();
}

class _AcademiesScreenState
    extends State<AcademiesScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        context
            .read<AcademyController>()
            .loadAcademies();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Academies',
        ),
        centerTitle: true,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const CreateAcademyScreen(),
            ),
          );

          if (!mounted) return;

          if (result == true) {
            await context
                .read<AcademyController>()
                .refreshAcademies();
          }
        },
        icon: const Icon(
          Icons.add,
        ),
        label: const Text(
          'Create Academy',
        ),
      ),

      body: Consumer<AcademyController>(
        builder: (
            context,
            controller,
            child,
            ) {
          // ========================================================
          // INITIAL LOADING
          // ========================================================

          if (controller.isLoading &&
              controller.academies.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ========================================================
          // ERROR
          // ========================================================

          if (controller.hasError &&
              controller.academies.isEmpty) {
            return _buildError(
              context,
              controller.errorMessage,
            );
          }

          // ========================================================
          // EMPTY
          // ========================================================

          if (controller.academies.isEmpty) {
            return _buildEmpty(
              context,
            );
          }

          // ========================================================
          // LIST
          // ========================================================

          return RefreshIndicator(
            onRefresh:
            controller.refreshAcademies,
            child: ListView.separated(
              physics:
              const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount:
              controller.academies.length,
              separatorBuilder: (
                  context,
                  index,
                  ) {
                return const SizedBox(
                  height: 12,
                );
              },
              itemBuilder: (
                  context,
                  index,
                  ) {
                final academy =
                controller.academies[index];

                return _AcademyListCard(
                  academy: academy,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AcademyDetailsScreen(
                              academyId:
                              academy.id,
                            ),
                      ),
                    );

                    if (!mounted) return;

                    await controller
                        .refreshAcademies();
                  },
                );
              },
            ),
          );
        },
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
                  'Failed to load academies',
              textAlign:
              TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<AcademyController>()
                    .loadAcademies();
              },
              icon: const Icon(
                Icons.refresh,
              ),
              label: const Text(
                'Retry',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmpty(
      BuildContext context,
      ) {
    return RefreshIndicator(
      onRefresh: context
          .read<AcademyController>()
          .refreshAcademies,
      child: ListView(
        physics:
        const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height:
            MediaQuery.of(context).size.height *
                0.65,
            child: Center(
              child: Padding(
                padding:
                const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment:
                  MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.school_outlined,
                      size: 72,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    const Text(
                      'No academies found',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      'Create your first academy to get started.',
                      textAlign:
                      TextAlign.center,
                    ),
                    const SizedBox(
                      height: 24,
                    ),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result =
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                            const CreateAcademyScreen(),
                          ),
                        );

                        if (!context.mounted) {
                          return;
                        }

                        if (result == true) {
                          await context
                              .read<
                              AcademyController>()
                              .refreshAcademies();
                        }
                      },
                      icon: const Icon(
                        Icons.add,
                      ),
                      label: const Text(
                        'Create Academy',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ACADEMY LIST CARD
// ============================================================================

class _AcademyListCard
    extends StatelessWidget {
  final AcademyModel academy;
  final VoidCallback? onTap;

  const _AcademyListCard({
    required this.academy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status =
    academy.status.toLowerCase();

    return Card(
      clipBehavior:
      Clip.antiAlias,
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding:
          const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              // ======================================================
              // IMAGE
              // ======================================================

              ClipRRect(
                borderRadius:
                BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child:
                  _buildImage(),
                ),
              ),

              const SizedBox(
                height: 14,
              ),

              // ======================================================
              // NAME + STATUS
              // ======================================================

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
                        fontSize: 18,
                        fontWeight:
                        FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  _StatusChip(
                    status:
                    status,
                  ),
                ],
              ),

              const SizedBox(
                height: 10,
              ),

              // ======================================================
              // ADDRESS
              // ======================================================

              if (_hasValue(
                academy.address,
              ))
                _InfoRow(
                  icon: Icons
                      .location_on_outlined,
                  text:
                  academy.address!,
                ),

              // ======================================================
              // PHONE
              // ======================================================

              if (_hasValue(
                academy.phoneNumber,
              ))
                Padding(
                  padding:
                  const EdgeInsets.only(
                    top: 8,
                  ),
                  child: _InfoRow(
                    icon: Icons
                        .phone_outlined,
                    text:
                    academy.phoneNumber!,
                  ),
                ),

              const SizedBox(
                height: 14,
              ),

              // ======================================================
              // DETAILS
              // ======================================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.end,
                children: [
                  Text(
                    'View Details',
                    style: TextStyle(
                      fontWeight:
                      FontWeight.w600,
                      color: Theme.of(
                        context,
                      )
                          .colorScheme
                          .primary,
                    ),
                  ),
                  const SizedBox(
                    width: 6,
                  ),
                  Icon(
                    Icons
                        .arrow_forward_ios,
                    size: 14,
                    color: Theme.of(
                      context,
                    )
                        .colorScheme
                        .primary,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE
  // ============================================================

  Widget _buildImage() {
    if (!_hasValue(
      academy.imageUrl,
    )) {
      return _placeholder();
    }

    return Image.network(
      academy.imageUrl!,
      fit: BoxFit.cover,
      errorBuilder: (
          context,
          error,
          stackTrace,
          ) {
        return _placeholder();
      },
    );
  }

  Widget _placeholder() {
    return Container(
      color: Colors.grey.shade200,
      alignment: Alignment.center,
      child: Icon(
        Icons.school_outlined,
        size: 56,
        color: Colors.grey.shade500,
      ),
    );
  }

  static bool _hasValue(
      String? value,
      ) {
    return value != null &&
        value.trim().isNotEmpty;
  }
}

// ============================================================================
// STATUS CHIP
// ============================================================================

class _StatusChip
    extends StatelessWidget {
  final String status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;

    switch (status) {
      case 'approved':
        icon =
            Icons.check_circle_outline;
        break;

      case 'pending':
        icon = Icons.access_time;
        break;

      case 'inactive':
        icon =
            Icons.pause_circle_outline;
        break;

      default:
        icon = Icons.info_outline;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
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
          const SizedBox(
            width: 5,
          ),
          Text(
            status,
            style:
            const TextStyle(
              fontSize: 12,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// INFO ROW
// ============================================================================

class _InfoRow
    extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow:
            TextOverflow.ellipsis,
            style:
            const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}