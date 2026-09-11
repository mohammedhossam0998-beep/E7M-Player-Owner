import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/stadium_model.dart';
import '../providers/stadium_provider.dart';
import 'create_stadium_screen.dart';
import 'stadium_details_screen.dart';

class OwnerStadiumsScreen extends StatefulWidget {
  const OwnerStadiumsScreen({super.key});

  @override
  State<OwnerStadiumsScreen> createState() =>
      _OwnerStadiumsScreenState();
}

class _OwnerStadiumsScreenState
    extends State<OwnerStadiumsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<StadiumProvider>().fetchOwnerStadiums();
    });
  }

  Future<void> _refresh() async {
    await context.read<StadiumProvider>().fetchOwnerStadiums();
  }

  Future<void> _openCreateStadium() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CreateStadiumScreen(),
      ),
    );

    if (!mounted) return;

    if (created == true) {
      await _refresh();
    }
  }

  Future<void> _openStadiumDetails(
      StadiumModel stadium,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StadiumDetailsScreen(
          stadiumId: stadium.id,
        ),
      ),
    );

    if (!mounted) return;

    await _refresh();
  }

  Future<void> _confirmDelete(
      StadiumModel stadium,
      ) async {
    final provider = context.read<StadiumProvider>();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Stadium'),
          content: Text(
            'Are you sure you want to delete "${stadium.name}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final success = await provider.deleteStadium(
      stadium.id,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Stadium deleted successfully',
          ),
        ),
      );
    } else {
      final error = provider.errorMessage;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error ?? 'Failed to delete stadium',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      appBar: AppBar(
        title: const Text(
          'My Stadiums',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xff1E1446),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateStadium,
        backgroundColor: const Color(0xff7CC000),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Stadium',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Consumer<StadiumProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xff7CC000),
              ),
            );
          }

          if (provider.hasError &&
              provider.stadiums.isEmpty) {
            return _ErrorState(
              message:
              provider.errorMessage ??
                  'Failed to load stadiums',
              onRetry: _refresh,
            );
          }

          if (provider.stadiums.isEmpty) {
            return _EmptyState(
              onAddStadium: _openCreateStadium,
            );
          }

          return RefreshIndicator(
            color: const Color(0xff7CC000),
            onRefresh: _refresh,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                16,
                20,
                16,
                110,
              ),
              itemCount: provider.stadiums.length,
              separatorBuilder: (_, __) =>
              const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final stadium =
                provider.stadiums[index];

                return _StadiumCard(
                  stadium: stadium,
                  onTap: () =>
                      _openStadiumDetails(stadium),
                  onDelete: () =>
                      _confirmDelete(stadium),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _StadiumCard extends StatelessWidget {
  final StadiumModel stadium;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _StadiumCard({
    required this.stadium,
    required this.onTap,
    required this.onDelete,
  });

  Color _statusColor() {
    switch (stadium.status.toLowerCase()) {
      case 'approved':
      case 'active':
        return const Color(0xff16A34A);

      case 'rejected':
      case 'inactive':
        return Colors.red;

      case 'pending':
      default:
        return const Color(0xffF59E0B);
    }
  }

  String _statusText() {
    switch (stadium.status.toLowerCase()) {
      case 'approved':
        return 'Approved';

      case 'active':
        return 'Active';

      case 'rejected':
        return 'Rejected';

      case 'inactive':
        return 'Inactive';

      case 'pending':
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: const Color(0xff7CC000)
                            .withValues(alpha: 0.12),
                        borderRadius:
                        BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.stadium_rounded,
                        color: Color(0xff7CC000),
                        size: 30,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(
                            stadium.name,
                            maxLines: 2,
                            overflow:
                            TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight:
                              FontWeight.w800,
                              color:
                              Color(0xff1E1446),
                            ),
                          ),
                          const SizedBox(height: 7),
                          Text(
                            stadium.pitchType,
                            style: TextStyle(
                              color:
                              Colors.grey.shade600,
                              fontSize: 13,
                              fontWeight:
                              FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'details') {
                          onTap();
                        }

                        if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(
                          value: 'details',
                          child: Row(
                            children: [
                              Icon(
                                Icons
                                    .visibility_outlined,
                                color:
                                Color(0xff1E1446),
                              ),
                              SizedBox(width: 10),
                              Text('View Details'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons
                                    .delete_outline_rounded,
                                color: Colors.red,
                              ),
                              SizedBox(width: 10),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                Container(
                  padding:
                  const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(
                      alpha: 0.10,
                    ),
                    borderRadius:
                    BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        _statusText(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight:
                          FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                const Divider(height: 1),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _InfoItem(
                        icon:
                        Icons.people_alt_outlined,
                        label: 'Capacity',
                        value:
                        '${stadium.capacity} players',
                      ),
                    ),
                    Expanded(
                      child: _InfoItem(
                        icon:
                        Icons.payments_outlined,
                        label: 'Base Price',
                        value: stadium.basePrice
                            .toStringAsFixed(2),
                      ),
                    ),
                  ],
                ),

                if (stadium.address != null &&
                    stadium.address!
                        .trim()
                        .isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _InfoItem(
                    icon:
                    Icons.location_on_outlined,
                    label: 'Address',
                    value: stadium.address!,
                  ),
                ],

                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.end,
                  children: [
                    Text(
                      'Tap to view details',
                      style: TextStyle(
                        color:
                        Colors.grey.shade500,
                        fontSize: 11,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color:
                      Colors.grey.shade500,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xff7CC000),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xff1E1446),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAddStadium;

  const _EmptyState({
    required this.onAddStadium,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xff7CC000)
                    .withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.stadium_outlined,
                size: 52,
                color: Color(0xff7CC000),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No Stadiums Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xff1E1446),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Create your first stadium and add its basic information.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 26),
            ElevatedButton.icon(
              onPressed: onAddStadium,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Add Stadium',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xff7CC000),
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 58,
              color: Colors.red,
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
                backgroundColor:
                const Color(0xff7CC000),
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 13,
                ),
                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}