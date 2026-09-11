import 'package:flutter/material.dart';

import '../models/academy_model.dart';

class AcademyCard extends StatelessWidget {
  final AcademyModel academy;
  final VoidCallback? onTap;

  const AcademyCard({
    super.key,
    required this.academy,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = academy.status.toLowerCase() == 'approved';
    final isPending = academy.status.toLowerCase() == 'pending';
    final isInactive = academy.status.toLowerCase() == 'inactive';

    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================================
              // IMAGE
              // ==========================================================

              if (academy.imageUrl != null &&
                  academy.imageUrl!.trim().isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
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

              const SizedBox(height: 14),

              // ==========================================================
              // NAME + STATUS
              // ==========================================================

              Row(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      academy.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  _buildStatusChip(
                    context,
                    status: academy.status,
                    isApproved: isApproved,
                    isPending: isPending,
                    isInactive: isInactive,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // ==========================================================
              // ADDRESS
              // ==========================================================

              if (academy.address != null &&
                  academy.address!.trim().isNotEmpty)
                _buildInfoRow(
                  icon: Icons.location_on_outlined,
                  text: academy.address!,
                ),

              // ==========================================================
              // PHONE
              // ==========================================================

              if (academy.phoneNumber != null &&
                  academy.phoneNumber!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: _buildInfoRow(
                    icon: Icons.phone_outlined,
                    text: academy.phoneNumber!,
                  ),
                ),

              // ==========================================================
              // PITCH
              // ==========================================================

              if (academy.pitchName != null &&
                  academy.pitchName!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: _buildInfoRow(
                    icon: Icons.sports_soccer_outlined,
                    text:
                    'Pitch: ${academy.pitchName!}',
                  ),
                ),

              // ==========================================================
              // PITCH STATUS
              // ==========================================================

              if (academy.pitchStatus != null &&
                  academy.pitchStatus!.trim().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    top: 8,
                  ),
                  child: _buildInfoRow(
                    icon: Icons.verified_outlined,
                    text:
                    'Pitch Status: ${academy.pitchStatus!}',
                  ),
                ),

              const SizedBox(height: 14),

              // ==========================================================
              // OPEN DETAILS
              // ==========================================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.end,
                children: [
                  Text(
                    'View Details',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Theme.of(context)
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
  // IMAGE PLACEHOLDER
  // ============================================================

  Widget _buildImagePlaceholder() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.school_outlined,
          size: 52,
          color: Colors.grey.shade500,
        ),
      ),
    );
  }

  // ============================================================
  // STATUS CHIP
  // ============================================================

  Widget _buildStatusChip(
      BuildContext context, {
        required String status,
        required bool isApproved,
        required bool isPending,
        required bool isInactive,
      }) {
    IconData icon;

    if (isApproved) {
      icon = Icons.check_circle_outline;
    } else if (isPending) {
      icon = Icons.access_time;
    } else if (isInactive) {
      icon = Icons.pause_circle_outline;
    } else {
      icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}