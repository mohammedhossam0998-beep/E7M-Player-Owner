import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/owner_booking_model.dart';
import '../../providers/owner_bookings_provider.dart';

class OwnerBookingsScreen extends StatelessWidget {
  const OwnerBookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => OwnerBookingsProvider()..loadBookings(),
      child: const _OwnerBookingsView(),
    );
  }
}

class _OwnerBookingsView extends StatefulWidget {
  const _OwnerBookingsView();

  @override
  State<_OwnerBookingsView> createState() =>
      _OwnerBookingsViewState();
}

class _OwnerBookingsViewState
    extends State<_OwnerBookingsView> {
  int _selectedTab = 0;

  final List<String> _tabs = const [
    'All',
    'Pending',
    'Confirmed',
    'Rejected',
    'Cancelled',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<OwnerBookingsProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF7F8FA),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            title: const Text(
              'Bookings',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            actions: [
              IconButton(
                tooltip: 'Refresh',
                onPressed: provider.loading
                    ? null
                    : provider.refreshBookings,
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          body: _buildBody(context, provider),
        );
      },
    );
  }

  Widget _buildBody(
      BuildContext context,
      OwnerBookingsProvider provider,
      ) {
    if (provider.loading && provider.bookings.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (provider.errorMessage != null &&
        provider.bookings.isEmpty) {
      return _buildErrorState(
        context,
        provider,
      );
    }

    return RefreshIndicator(
      onRefresh: provider.refreshBookings,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildSummary(provider),
          ),

          SliverToBoxAdapter(
            child: _buildTabs(provider),
          ),

          if (provider.errorMessage != null)
            SliverToBoxAdapter(
              child: _buildErrorBanner(provider),
            ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              16,
              8,
              16,
              32,
            ),
            sliver: _buildBookingsList(provider),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SUMMARY
  // ============================================================

  Widget _buildSummary(
      OwnerBookingsProvider provider,
      ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        8,
      ),
      child: Row(
        children: [
          Expanded(
            child: _statCard(
              title: 'Total',
              value: provider.totalBookings,
              icon: Icons.calendar_month_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _statCard(
              title: 'Pending',
              value: provider.pendingBookings,
              icon: Icons.pending_actions_rounded,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _statCard(
              title: 'Confirmed',
              value: provider.confirmedBookings,
              icon: Icons.check_circle_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required int value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE9EBEF),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: const Color(0xFF7CC000),
          ),
          const SizedBox(height: 10),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // TABS
  // ============================================================

  Widget _buildTabs(
      OwnerBookingsProvider provider,
      ) {
    return SizedBox(
      height: 54,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: _tabs.length,
        separatorBuilder: (_, __) =>
        const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final selected = _selectedTab == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTab = index;
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 17,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFF7CC000)
                    : Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: selected
                      ? const Color(0xFF7CC000)
                      : const Color(0xFFE3E5E8),
                ),
              ),
              child: Text(
                _tabs[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : Colors.grey.shade700,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================================
  // BOOKINGS LIST
  // ============================================================

  Widget _buildBookingsList(
      OwnerBookingsProvider provider,
      ) {
    final bookings = _filteredBookings(
      provider.bookings,
    );

    if (bookings.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(),
      );
    }

    return SliverList.separated(
      itemCount: bookings.length,
      separatorBuilder: (_, __) =>
      const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _buildBookingCard(
          context,
          provider,
          bookings[index],
        );
      },
    );
  }

  List<OwnerBookingModel> _filteredBookings(
      List<OwnerBookingModel> bookings,
      ) {
    if (_selectedTab == 0) {
      return bookings;
    }

    final status = _tabs[_selectedTab].toLowerCase();

    return bookings.where((booking) {
      return booking.status.toLowerCase() == status;
    }).toList();
  }

  // ============================================================
  // BOOKING CARD
  // ============================================================

  Widget _buildBookingCard(
      BuildContext context,
      OwnerBookingsProvider provider,
      OwnerBookingModel booking,
      ) {
    final isPending =
        booking.status.toLowerCase() == 'pending';

    final isProcessing =
        provider.processingBookingId == booking.id;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE7E9ED),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBookingHeader(booking),

            const SizedBox(height: 16),

            _buildInfoRow(
              icon: Icons.person_outline_rounded,
              title: 'Player',
              value: _displayValue(
                booking.playerName,
                fallback: 'Unknown player',
              ),
            ),

            const SizedBox(height: 11),

            _buildInfoRow(
              icon: Icons.stadium_outlined,
              title: 'Stadium',
              value: _displayValue(
                booking.pitchName,
                fallback: 'Unknown stadium',
              ),
            ),

            if (booking.pitchAddress != null &&
                booking.pitchAddress!.trim().isNotEmpty) ...[
              const SizedBox(height: 7),
              _buildInfoRow(
                icon: Icons.location_on_outlined,
                title: 'Address',
                value: booking.pitchAddress!,
              ),
            ],

            const SizedBox(height: 11),

            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              title: 'Date',
              value: _formatDate(
                booking.slotDate,
              ),
            ),

            const SizedBox(height: 11),

            _buildInfoRow(
              icon: Icons.access_time_rounded,
              title: 'Time',
              value: _formatTimeRange(
                booking.startTime,
                booking.endTime,
              ),
            ),

            const SizedBox(height: 16),

            const Divider(
              height: 1,
              color: Color(0xFFEDEFF2),
            ),

            const SizedBox(height: 14),

            _buildPaymentSection(booking),

            if (isPending) ...[
              const SizedBox(height: 16),
              _buildActionButtons(
                context,
                provider,
                booking,
                isProcessing,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================

  Widget _buildBookingHeader(
      OwnerBookingModel booking,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              const Text(
                'Booking',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '#${booking.id}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        _statusBadge(booking.status),
      ],
    );
  }

  Widget _statusBadge(String status) {
    final normalized = status.toLowerCase();

    Color background;
    Color foreground;

    switch (normalized) {
      case 'confirmed':
        background = const Color(0xFFEAF8D8);
        foreground = const Color(0xFF4F8500);
        break;

      case 'pending':
        background = const Color(0xFFFFF4D6);
        foreground = const Color(0xFF9A6A00);
        break;

      case 'rejected':
        background = const Color(0xFFFFE5E5);
        foreground = const Color(0xFFC0392B);
        break;

      case 'cancelled':
        background = const Color(0xFFEDEEF0);
        foreground = const Color(0xFF666A70);
        break;

      default:
        background = const Color(0xFFEDEEF0);
        foreground = const Color(0xFF666A70);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _capitalize(status),
        style: TextStyle(
          color: foreground,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ============================================================
  // INFO ROW
  // ============================================================

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8E8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.circle,
            size: 7,
            color: Color(0xFF7CC000),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAYMENT
  // ============================================================

  Widget _buildPaymentSection(
      OwnerBookingModel booking,
      ) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        children: [
          _paymentRow(
            'Total',
            _money(booking.totalPrice),
            bold: true,
          ),
          const SizedBox(height: 8),
          _paymentRow(
            'Deposit',
            _money(booking.depositAmount),
          ),
          const SizedBox(height: 8),
          _paymentRow(
            'Remaining',
            _money(booking.remainingAmount),
          ),
          if (booking.paymentStatus != null) ...[
            const SizedBox(height: 8),
            _paymentRow(
              'Payment status',
              _capitalize(
                booking.paymentStatus!,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _paymentRow(
      String title,
      String value, {
        bool bold = false,
      }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: bold
                  ? FontWeight.w700
                  : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold
                ? FontWeight.w800
                : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // ACTION BUTTONS
  // ============================================================

  Widget _buildActionButtons(
      BuildContext context,
      OwnerBookingsProvider provider,
      OwnerBookingModel booking,
      bool isProcessing,
      ) {
    if (isProcessing) {
      return Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFF4F5F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const SizedBox(
          width: 21,
          height: 21,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _showRejectDialog(
                context,
                provider,
                booking,
              );
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor:
              const Color(0xFFC0392B),
              side: const BorderSide(
                color: Color(0xFFE1A7A2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Reject',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              _showApproveDialog(
                context,
                provider,
                booking,
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor:
              const Color(0xFF7CC000),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Approve',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // APPROVE DIALOG
  // ============================================================

  Future<void> _showApproveDialog(
      BuildContext context,
      OwnerBookingsProvider provider,
      OwnerBookingModel booking,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Approve booking?',
          ),
          content: Text(
            'Are you sure you want to approve booking #${booking.id}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFF7CC000),
                foregroundColor: Colors.white,
              ),
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final success =
    await provider.approveBooking(
      booking.id,
    );

    if (!context.mounted) return;

    if (success) {
      _showMessage(
        context,
        'Booking approved successfully',
      );
    } else if (provider.errorMessage != null) {
      _showMessage(
        context,
        provider.errorMessage!,
        isError: true,
      );
    }
  }

  // ============================================================
  // REJECT DIALOG
  // ============================================================

  Future<void> _showRejectDialog(
      BuildContext context,
      OwnerBookingsProvider provider,
      OwnerBookingModel booking,
      ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Reject booking?',
          ),
          content: Text(
            'Are you sure you want to reject booking #${booking.id}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                const Color(0xFFC0392B),
                foregroundColor: Colors.white,
              ),
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final success =
    await provider.rejectBooking(
      booking.id,
    );

    if (!context.mounted) return;

    if (success) {
      _showMessage(
        context,
        'Booking rejected successfully',
      );
    } else if (provider.errorMessage != null) {
      _showMessage(
        context,
        provider.errorMessage!,
        isError: true,
      );
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  Widget _buildErrorState(
      BuildContext context,
      OwnerBookingsProvider provider,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 58,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ??
                  'Unable to load bookings.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: provider.loadBookings,
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(
      OwnerBookingsProvider provider,
      ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
        16,
        4,
        16,
        8,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              provider.errorMessage!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.redAccent,
              ),
            ),
          ),
          IconButton(
            onPressed: provider.clearError,
            icon: const Icon(
              Icons.close,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // EMPTY
  // ============================================================

  Widget _buildEmptyState() {
    final title = _selectedTab == 0
        ? 'No bookings yet'
        : 'No ${_tabs[_selectedTab].toLowerCase()} bookings';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFF1F8E8),
                borderRadius:
                BorderRadius.circular(22),
              ),
              child: const Icon(
                Icons.calendar_month_outlined,
                size: 34,
                color: Color(0xFF7CC000),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Bookings will appear here.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // HELPERS
  // ============================================================

  String _displayValue(
      String? value, {
        required String fallback,
      }) {
    if (value == null || value.trim().isEmpty) {
      return fallback;
    }

    return value;
  }

  String _money(double value) {
    return '${value.toStringAsFixed(2)} EGP';
  }

  String _formatDate(String? date) {
    if (date == null || date.trim().isEmpty) {
      return 'Not available';
    }

    return date;
  }

  String _formatTimeRange(
      String? start,
      String? end,
      ) {
    if (start == null || start.isEmpty) {
      return 'Not available';
    }

    if (end == null || end.isEmpty) {
      return start;
    }

    return '$start - $end';
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;

    return value[0].toUpperCase() +
        value.substring(1).toLowerCase();
  }

  void _showMessage(
      BuildContext context,
      String message, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Colors.redAccent
              : const Color(0xFF7CC000),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
