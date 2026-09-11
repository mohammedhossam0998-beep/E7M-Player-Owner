import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/stadium_provider.dart';
import '../../../availability/availability_calendar_screen.dart';
import '../../../availability/manage_availability_screen.dart';
import 'create_stadium_screen.dart';
import 'stadium_images_screen.dart';

class StadiumDetailsScreen extends StatefulWidget {
  final int stadiumId;

  const StadiumDetailsScreen({
    super.key,
    required this.stadiumId,
  });

  @override
  State<StadiumDetailsScreen> createState() => _StadiumDetailsScreenState();
}

class _StadiumDetailsScreenState extends State<StadiumDetailsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<StadiumProvider>().fetchStadiumById(widget.stadiumId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),

      // ============================================================
      // APP BAR
      // ============================================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff1E1446),
        elevation: 0,
        title: const Text(
          'Stadium Details',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: true,

        // ============================================================
        // ACTIONS
        // ============================================================
        actions: [
          Consumer<StadiumProvider>(
            builder: (context, provider, _) {
              final stadium = provider.selectedStadium;

              if (stadium == null) {
                return const SizedBox.shrink();
              }

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ==================================================
                  // STADIUM IMAGES
                  // ==================================================
                  IconButton(
                    tooltip: 'Stadium Images',
                    icon: const Icon(Icons.photo_library_outlined),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => StadiumImagesScreen(
                            stadiumId: stadium.id,
                            stadiumName: stadium.name,
                          ),
                        ),
                      );
                    },
                  ),

                  // ==================================================
                  // STADIUM SLOTS
                  // ==================================================
                  IconButton(
                    tooltip: 'Manage Slots',
                    icon: const Icon(Icons.schedule_rounded),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ManageAvailabilityScreen(
                            stadiumId: stadium.id,
                          ),
                        ),
                      );
                    },
                  ),

                  // ==================================================
                  // AVAILABILITY CALENDAR
                  // ==================================================
                  IconButton(
                    tooltip: 'Availability Calendar',
                    icon: const Icon(Icons.calendar_month_rounded),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => AvailabilityCalendarScreen(
                            stadiumId: stadium.id,
                          ),
                        ),
                      );
                    },
                  ),

                  // ==================================================
                  // EDIT STADIUM
                  // ==================================================
                  IconButton(
                    tooltip: 'Edit Stadium',
                    icon: const Icon(Icons.edit_rounded),
                    onPressed: () async {
                      final result = await Navigator.of(context).push<bool>(
                        MaterialPageRoute(
                          builder: (_) => CreateStadiumScreen(
                            stadium: stadium,
                          ),
                        ),
                      );

                      if (!context.mounted) return;
                      if (result != true) return;

                      await context
                          .read<StadiumProvider>()
                          .fetchStadiumById(widget.stadiumId);
                    },
                  ),
                ],
              );
            },
          ),
        ],
      ),

      // ============================================================
      // BODY
      // ============================================================
      body: Consumer<StadiumProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xff7CC000),
              ),
            );
          }

          if (provider.hasError) {
            return _ErrorView(
              message: provider.errorMessage ?? 'Failed to load stadium',
              onRetry: () {
                provider.fetchStadiumById(widget.stadiumId);
              },
            );
          }

          final stadium = provider.selectedStadium;

          if (stadium == null) {
            return const Center(
              child: Text(
                'Stadium not found',
                style: TextStyle(
                  color: Color(0xff1E1446),
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          }

          final status = stadium.status.toLowerCase();

          final Color statusColor;

          switch (status) {
            case 'approved':
            case 'active':
              statusColor = const Color(0xff16A34A);
              break;

            case 'rejected':
            case 'inactive':
              statusColor = Colors.red;
              break;

            default:
              statusColor = const Color(0xffF59E0B);
          }

          return RefreshIndicator(
            color: const Color(0xff7CC000),
            onRefresh: () async {
              await provider.fetchStadiumById(widget.stadiumId);
            },
            child: ListView(
              padding: const EdgeInsets.all(18),
              children: [
                // ==================================================
                // STADIUM HEADER
                // ==================================================
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 82,
                        height: 82,
                        decoration: BoxDecoration(
                          color: const Color(0xff7CC000)
                              .withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: const Icon(
                          Icons.stadium_rounded,
                          color: Color(0xff7CC000),
                          size: 42,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        stadium.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff1E1446),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        stadium.pitchType,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _statusText(stadium.status),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // ==================================================
                // IMAGES QUICK ACCESS
                // ==================================================
                _SectionCard(
                  title: 'Stadium Images',
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => StadiumImagesScreen(
                              stadiumId: stadium.id,
                              stadiumName: stadium.name,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xff7CC000)
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xff7CC000)
                                .withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xff7CC000)
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.photo_library_outlined,
                                color: Color(0xff7CC000),
                              ),
                            ),

                            const SizedBox(width: 14),

                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Manage Stadium Images',
                                    style: TextStyle(
                                      color: Color(0xff1E1446),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Upload, delete and set the primary image',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 17,
                              color: Color(0xff7CC000),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ==================================================
                // AVAILABILITY / SLOTS
                // ==================================================
                _SectionCard(
                  title: 'Availability & Slots',
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ManageAvailabilityScreen(
                              stadiumId: stadium.id,
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xff2563EB)
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xff2563EB)
                                .withValues(alpha: 0.18),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xff2563EB)
                                    .withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                color: Color(0xff2563EB),
                              ),
                            ),

                            const SizedBox(width: 14),

                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Manage Availability',
                                    style: TextStyle(
                                      color: Color(0xff1E1446),
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Create and manage available time slots',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 17,
                              color: Color(0xff2563EB),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ==================================================
                // BASIC INFORMATION
                // ==================================================
                _SectionCard(
                  title: 'Basic Information',
                  children: [
                    _DetailItem(
                      icon: Icons.people_alt_outlined,
                      title: 'Capacity',
                      value: '${stadium.capacity} players',
                    ),
                    _DetailItem(
                      icon: Icons.payments_outlined,
                      title: 'Base Price',
                      value: stadium.basePrice.toStringAsFixed(2),
                    ),
                    _DetailItem(
                      icon: Icons.location_city_outlined,
                      title: 'City ID',
                      value: stadium.cityId.toString(),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ==================================================
                // LOCATION
                // ==================================================
                _SectionCard(
                  title: 'Location',
                  children: [
                    _DetailItem(
                      icon: Icons.location_on_outlined,
                      title: 'Address',
                      value: stadium.address?.trim().isNotEmpty == true
                          ? stadium.address!
                          : 'Not provided',
                    ),
                    _DetailItem(
                      icon: Icons.map_outlined,
                      title: 'Latitude',
                      value: stadium.latitude?.toString() ?? 'Not provided',
                    ),
                    _DetailItem(
                      icon: Icons.map_outlined,
                      title: 'Longitude',
                      value: stadium.longitude?.toString() ?? 'Not provided',
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ==================================================
                // DESCRIPTION
                // ==================================================
                _SectionCard(
                  title: 'Description',
                  children: [
                    Text(
                      stadium.description?.trim().isNotEmpty == true
                          ? stadium.description!
                          : 'No description provided.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // ==================================================
                // SYSTEM INFORMATION
                // ==================================================
                _SectionCard(
                  title: 'System Information',
                  children: [
                    _DetailItem(
                      icon: Icons.numbers_rounded,
                      title: 'Stadium ID',
                      value: stadium.id.toString(),
                    ),
                    _DetailItem(
                      icon: Icons.verified_user_outlined,
                      title: 'Owner ID',
                      value: stadium.ownerId.toString(),
                    ),
                    _DetailItem(
                      icon: Icons.access_time_rounded,
                      title: 'Created At',
                      value: _formatDate(stadium.createdAt),
                    ),
                    _DetailItem(
                      icon: Icons.update_rounded,
                      title: 'Updated At',
                      value: _formatDate(stadium.updatedAt),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // STATUS TEXT
  // ============================================================
  String _statusText(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return 'Approved';

      case 'active':
        return 'Active';

      case 'rejected':
        return 'Rejected';

      case 'inactive':
        return 'Inactive';

      default:
        return 'Pending';
    }
  }

  // ============================================================
  // FORMAT DATE
  // ============================================================
  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Not available';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}

// ==================================================================
// SECTION CARD
// ==================================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xff1E1446),
            ),
          ),

          const SizedBox(height: 16),

          ...children,
        ],
      ),
    );
  }
}

// ==================================================================
// DETAIL ITEM
// ==================================================================

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xff7CC000).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xff7CC000),
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xff1E1446),
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

// ==================================================================
// ERROR VIEW
// ==================================================================

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: Colors.red,
              size: 58,
            ),

            const SizedBox(height: 18),

            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xff1E1446),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),

            const SizedBox(height: 22),

            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7CC000),
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}