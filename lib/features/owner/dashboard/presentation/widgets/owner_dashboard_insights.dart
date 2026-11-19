
import 'package:flutter/material.dart';

import 'package:e7m/core/network/api_client.dart';
import 'package:e7m/core/theme/app_colors.dart';
import 'package:e7m/features/owner/dashboard/presentation/providers/owner_dashboard_provider.dart';
import 'package:e7m/features/owner/booking/presentation/screens/owner_bookings_screen.dart';
import 'package:e7m/features/owner/payout/presentation/screens/owner_payments_screen.dart';
import 'package:e7m/features/owner/academy/screens/academy_dashboard_screen.dart';

class OwnerDashboardInsights extends StatefulWidget {
  final OwnerDashboardProvider dashboard;

  const OwnerDashboardInsights({
    super.key,
    required this.dashboard,
  });

  @override
  State<OwnerDashboardInsights> createState() =>
      _OwnerDashboardInsightsState();
}

class _OwnerDashboardInsightsState
    extends State<OwnerDashboardInsights> {
  final ApiClient _apiClient = ApiClient();

  List<Map<String, dynamic>> _academyPayments = [];
  bool _loadingAcademy = true;
  String? _academyError;

  @override
  void initState() {
    super.initState();
    _loadAcademyPayments();
  }

  Future<void> _loadAcademyPayments() async {
    if (!mounted) return;

    setState(() {
      _loadingAcademy = true;
      _academyError = null;
    });

    try {
      final response = await _apiClient.get(
        '/payments/academy/owner',
      );

      if (response is! Map ||
          response['success'] != true) {
        throw Exception(
          response is Map
              ? response['message']?.toString() ??
              'Could not load academy payments'
              : 'Invalid academy payments response',
        );
      }

      final rawPayments = response['payments'];

      if (rawPayments is! List) {
        throw Exception(
          'Academy payments list is missing',
        );
      }

      final parsed = rawPayments
          .map<Map<String, dynamic>>((item) {
        if (item is! Map) {
          throw Exception(
            'Invalid academy payment entry',
          );
        }

        return Map<String, dynamic>.from(item);
      }).toList();

      if (!mounted) return;

      setState(() {
        _academyPayments = parsed;
        _academyError = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _academyPayments = [];
        _academyError = error
            .toString()
            .replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _loadingAcademy = false;
        });
      }
    }
  }

  Future<void> _refreshAll() async {
    await widget.dashboard.refreshDashboard();

    if (!mounted) return;

    await _loadAcademyPayments();
  }

  bool _isPending(Map<String, dynamic> item) {
    return item['status']
        ?.toString()
        .toLowerCase() ==
        'pending';
  }

  bool _hasReference(Map<String, dynamic> item) {
    return (item['transaction_reference']
        ?.toString()
        .trim() ??
        '')
        .isNotEmpty;
  }

  bool _isPaid(Map<String, dynamic> item) {
    final status =
    item['status']?.toString().toLowerCase();

    return status == 'paid' ||
        status == 'completed' ||
        status == 'success';
  }

  double _amount(Map<String, dynamic> item) {
    final value = item['amount'];

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value?.toString() ?? '',
    ) ??
        0;
  }

  int get _pendingBookings {
    return widget.dashboard.bookings.where((booking) {
      final status = booking['status']
          ?.toString()
          .toLowerCase();

      return status == 'pending';
    }).length;
  }

  int get _stadiumPaymentsToReview {
    return widget.dashboard.payments.where((payment) {
      return _isPending(payment) &&
          _hasReference(payment);
    }).length;
  }

  int get _academyPaymentsToReview {
    return _academyPayments.where((payment) {
      return _isPending(payment) &&
          _hasReference(payment);
    }).length;
  }

  int get _academyWaitingForReference {
    return _academyPayments.where((payment) {
      return _isPending(payment) &&
          !_hasReference(payment);
    }).length;
  }

  double get _academyApprovedAmount {
    return _academyPayments
        .where(_isPaid)
        .fold<double>(
      0,
          (sum, payment) =>
      sum + _amount(payment),
    );
  }

  void _open(Widget screen) {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    )
        .then((_) {
      if (mounted) {
        _refreshAll();
      }
    });
  }

  Widget _metric({
    required String label,
    required String value,
    required String hint,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xffE9EBF0),
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: color,
                size: 25,
              ),
              const SizedBox(height: 9),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xff1E1446),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xff1E1446),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                hint,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final academyReady =
        !_loadingAcademy && _academyError == null;

    final academyCount = academyReady
        ? _academyPaymentsToReview.toString()
        : '—';

    final academyAmount = academyReady
        ? '${_academyApprovedAmount.toStringAsFixed(2)} EGP'
        : '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Expanded(
              child: Text(
                'Needs Your Attention',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff1E1446),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Refresh summaries',
              onPressed: _loadingAcademy ||
                  widget.dashboard.isLoading
                  ? null
                  : _refreshAll,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              color: AppColors.secondary,
            ),
          ],
        ),

        const SizedBox(height: 12),

        LayoutBuilder(
          builder: (context, constraints) {
            final twoColumns =
                constraints.maxWidth >= 340;

            final cardWidth = twoColumns
                ? (constraints.maxWidth - 12) / 2
                : constraints.maxWidth;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: cardWidth,
                  child: _metric(
                    label: 'Pending Bookings',
                    value:
                    _pendingBookings.toString(),
                    hint:
                    'Waiting for your decision',
                    icon:
                    Icons.calendar_month_outlined,
                    color: const Color(0xff3B82F6),
                    onTap: () => _open(
                      const OwnerBookingsScreen(),
                    ),
                  ),
                ),

                SizedBox(
                  width: cardWidth,
                  child: _metric(
                    label: 'Stadium Transfers',
                    value:
                    _stadiumPaymentsToReview
                        .toString(),
                    hint:
                    'References ready to review',
                    icon:
                    Icons.receipt_long_outlined,
                    color: const Color(0xffF59E0B),
                    onTap: () => _open(
                      const OwnerPaymentsScreen(),
                    ),
                  ),
                ),

                SizedBox(
                  width: cardWidth,
                  child: _metric(
                    label: 'Academy Transfers',
                    value: academyCount,
                    hint: academyReady
                        ? '$_academyWaitingForReference awaiting reference'
                        : 'Data not available yet',
                    icon: Icons.school_outlined,
                    color: AppColors.secondary,
                    onTap: () => _open(
                      const AcademyDashboardScreen(),
                    ),
                  ),
                ),

                SizedBox(
                  width: cardWidth,
                  child: _metric(
                    label:
                    'Academy Approved Payments',
                    value: academyAmount,
                    hint:
                    'Kept separate from stadium revenue',
                    icon: Icons
                        .account_balance_wallet_outlined,
                    color: const Color(0xff16A34A),
                    onTap: () => _open(
                      const AcademyDashboardScreen(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        if (_academyError != null) ...[
          const SizedBox(height: 9),
          Text(
            'Academy summary unavailable: '
                '$_academyError',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.deepOrange,
            ),
          ),
        ],
      ],
    );
  }
}
