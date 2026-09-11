
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

import 'package:e7m/shared/localization/language_provider.dart';
import 'package:e7m/core/theme/app_colors.dart';

import 'package:e7m/features/owner/dashboard/presentation/providers/owner_dashboard_provider.dart';

import 'package:e7m/features/owner/notifications/notifications_screen.dart';
import 'package:e7m/features/owner/reviews/presentation/reviews_screen.dart';
import 'package:e7m/features/owner/revenue/revenue_screen.dart';
import 'package:e7m/features/owner/profile/presentation/screens/owner_profile_screen.dart';

import 'package:e7m/features/owner/booking/presentation/screens/owner_bookings_screen.dart';

import 'package:e7m/features/owner/academy/screens/academy_dashboard_screen.dart';

import 'package:e7m/features/owner/stadium/presentation/screens/owner_stadiums_screen.dart';
import 'package:e7m/features/owner/stadium/presentation/screens/create_stadium_screen.dart';

import 'package:e7m/features/owner/payout/presentation/%20screens/owner_payments_screen.dart';
import 'package:e7m/features/owner/competitions/presentation/screens/competitions_screen.dart';
import 'package:e7m/features/owner/competitions/presentation/screens/competition_payments_screen.dart';
class OwnerDashboardScreen extends StatefulWidget {
  const OwnerDashboardScreen({super.key});

  @override
  State<OwnerDashboardScreen> createState() =>
      _OwnerDashboardScreenState();
}

class _OwnerDashboardScreenState
    extends State<OwnerDashboardScreen> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context
          .read<OwnerDashboardProvider>()
          .loadDashboard();
    });
  }

// ============================================================
// BUILD
// ============================================================

  @override
  Widget build(BuildContext context) {
    final languageProvider =
    context.watch<LanguageProvider>();

    final dashboard =
    context.watch<OwnerDashboardProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF7F8FA),

      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.secondary,
          onRefresh: dashboard.refreshDashboard,
          child: _buildBody(
            context,
            languageProvider,
            dashboard,
          ),
        ),
      ),

// ========================================================
// BOTTOM NAVIGATION
// ========================================================

      bottomNavigationBar: _buildBottomNavigation(
        context,
        languageProvider,
      ),
    );
  }

// ============================================================
// BODY
// ============================================================

  Widget _buildBody(
      BuildContext context,
      LanguageProvider languageProvider,
      OwnerDashboardProvider dashboard,
      ) {
    if (dashboard.isLoading && !dashboard.hasData) {
      return const SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: 650,
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (dashboard.errorMessage != null &&
        !dashboard.hasData) {
      return _buildErrorState(
        context,
        languageProvider,
        dashboard,
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),

      padding: const EdgeInsets.fromLTRB(
        16,
        12,
        16,
        28,
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
// ======================================================
// HEADER
// ======================================================

          _staggered(
            0,
            _buildHeader(
              context,
              languageProvider,
              dashboard,
            ),
          ),

          const SizedBox(height: 16),

// ======================================================
// STADIUM SUMMARY
// ======================================================

          _staggered(
            1,
            _buildStadiumSummary(
              context,
              languageProvider,
              dashboard,
            ),
          ),

          const SizedBox(height: 18),

// ======================================================
// STATISTICS
// ======================================================

          _staggered(
            2,
            _buildStatistics(
              context,
              languageProvider,
              dashboard,
            ),
          ),

          const SizedBox(height: 26),

// ======================================================
// REVENUE OVERVIEW
// ======================================================

          _staggered(
            3,
            _buildRevenueSection(
              context,
              languageProvider,
              dashboard,
            ),
          ),

          const SizedBox(height: 26),

// ======================================================
// RECENT BOOKINGS
// ======================================================

          _staggered(
            4,
            _buildRecentBookings(
              context,
              languageProvider,
              dashboard,
            ),
          ),

          const SizedBox(height: 26),

// ======================================================
// QUICK ACTIONS
// ======================================================

          _staggered(
            5,
            _buildQuickActions(
              context,
              languageProvider,
            ),
          ),

          if (dashboard.errorMessage != null) ...[
            const SizedBox(height: 18),
            _buildSmallError(
              dashboard.errorMessage!,
            ),
          ],
        ],
      ),
    );
  }

// ============================================================
// HEADER
// ============================================================

  Widget _buildHeader(
      BuildContext context,
      LanguageProvider languageProvider,
      OwnerDashboardProvider dashboard,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,

          colors: [
            AppColors.secondary.withValues(alpha: 0.10),
            Colors.white,
          ],
        ),

        borderRadius: BorderRadius.circular(22),

        boxShadow: [
          BoxShadow(
            color: AppColors.secondary
                .withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),

      child: Row(
        children: [
// ====================================================
// AVATAR
// ====================================================

          Container(
            padding: const EdgeInsets.all(2.5),

            decoration: BoxDecoration(
              shape: BoxShape.circle,

              gradient: LinearGradient(
                colors: [
                  AppColors.secondary,
                  AppColors.secondary
                      .withValues(alpha: 0.35),
                ],
              ),
            ),

            child: const CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,

              backgroundImage: AssetImage(
                'assets/images/profile.png',
              ),
            ),
          ),

          const SizedBox(width: 13),

// ====================================================
// NAME
// ====================================================

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  "${languageProvider.translate('hello_owner')} 👋",

                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  dashboard.ownerName,

                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 18,
                    letterSpacing: -0.2,
                    color: Color(0xff1E1446),
                  ),
                ),
              ],
            ),
          ),

// ====================================================
// NOTIFICATIONS
// ====================================================

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,

              boxShadow: [
                BoxShadow(
                  color:
                  Colors.black.withValues(alpha: 0.05),
                  blurRadius: 9,
                  offset: const Offset(0, 3),
                ),
              ],
            ),

            child: IconButton(
              icon: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xff1E1446),
              ),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const NotificationsScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

// ============================================================
// STADIUM SUMMARY
// ============================================================

  Widget _buildStadiumSummary(
      BuildContext context,
      LanguageProvider languageProvider,
      OwnerDashboardProvider dashboard,
      ) {
    final pitchName = dashboard.firstPitchName;

    return InkWell(
      borderRadius: BorderRadius.circular(20),

      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
            const OwnerStadiumsScreen(),
          ),
        );
      },

      child: Container(
        padding: const EdgeInsets.all(17),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),

          border: Border.all(
            color: Colors.grey.shade200,
          ),

          boxShadow: [
            BoxShadow(
              color:
              Colors.black.withValues(alpha: 0.035),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(11),

              decoration: BoxDecoration(
                color: const Color(0xff3B82F6)
                    .withValues(alpha: 0.10),

                borderRadius:
                BorderRadius.circular(14),
              ),

              child: const Icon(
                Icons.stadium_rounded,
                color: Color(0xff3B82F6),
                size: 24,
              ),
            ),

            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  Text(
                    languageProvider.translate(
                      'my_stadiums',
                    ),

                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    pitchName ??
                        languageProvider.translate(
                          'no_stadiums',
                        ),

                    maxLines: 1,
                    overflow:
                    TextOverflow.ellipsis,

                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff1E1446),
                    ),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '${dashboard.totalPitches} ${languageProvider.translate('stadiums')}',

                    style: TextStyle(
                      fontSize: 11.5,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Color(0xffA0A4AB),
            ),
          ],
        ),
      ),
    );
  }

// ============================================================
// STATISTICS
// ============================================================

  Widget _buildStatistics(
      BuildContext context,
      LanguageProvider languageProvider,
      OwnerDashboardProvider dashboard,
      ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: statCard(
                languageProvider.translate(
                  'total_bookings',
                ),

                dashboard.totalBookings.toString(),

                "${languageProvider.translate('today')}: ${dashboard.todayBookings}",

                const Color(0xff3B82F6),

                Icons.calendar_month_rounded,

                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const OwnerBookingsScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: statCard(
                languageProvider.translate(
                  'my_stadiums',
                ),

                dashboard.totalPitches.toString(),

                languageProvider.translate(
                  'stadiums',
                ),

                const Color(0xff8B5CF6),

                Icons.stadium_rounded,

                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const OwnerStadiumsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: statCard(
                languageProvider.translate(
                  'revenue',
                ),

                '${_formatMoney(dashboard.totalRevenue)} EGP',

                languageProvider.translate(
                  'this_month',
                ),

                const Color(0xff22C55E),

                Icons.payments_rounded,

                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const RevenueScreen(),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: statCard(
                languageProvider.translate(
                  'payments',
                ),

                _paidPaymentsCount(
                  dashboard,
                ).toString(),

                languageProvider.translate(
                  'successful',
                ),

                const Color(0xff06B6D4),

                Icons.check_circle_rounded,

                    () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                      const OwnerPaymentsScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

// ============================================================
// REVENUE SECTION
// ============================================================

  Widget _buildRevenueSection(
      BuildContext context,
      LanguageProvider languageProvider,
      OwnerDashboardProvider dashboard,
      ) {
    final spots = _buildRevenueSpots(
      dashboard,
    );

    final maxY = _getMaxRevenue(
      spots,
    );

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),

              decoration: BoxDecoration(
                color: AppColors.secondary
                    .withValues(alpha: 0.10),

                borderRadius:
                BorderRadius.circular(10),
              ),

              child: Icon(
                Icons.show_chart_rounded,
                size: 19,
                color: AppColors.secondary,
              ),
            ),

            const SizedBox(width: 9),

            Expanded(
              child: Text(
                languageProvider.translate(
                  'revenue_overview',
                ),

                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: Color(0xff1E1446),
                ),
              ),
            ),

            if (dashboard.isLoading)
              const SizedBox(
                width: 16,
                height: 16,
                child:
                CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
          ],
        ),

        const SizedBox(height: 13),

        Container(
          height: 285,
          padding: const EdgeInsets.fromLTRB(
            10,
            20,
            18,
            12,
          ),

          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(20),

            boxShadow: [
              BoxShadow(
                color:
                Colors.black.withValues(alpha: 0.04),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),

          child: LineChart(
            LineChartData(
              minX: 0,
              maxX: 6,
              minY: 0,
              maxY: maxY,

              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,

                horizontalInterval:
                _getHorizontalInterval(
                  maxY,
                ),

                getDrawingHorizontalLine:
                    (value) => FlLine(
                  color: Colors.grey.shade200,
                  strokeWidth: 1,
                ),
              ),

              borderData:
              FlBorderData(
                show: false,
              ),

              titlesData:
              FlTitlesData(
                leftTitles:
                AxisTitles(
                  sideTitles:
                  SideTitles(
                    showTitles: true,
                    reservedSize: 42,

                    interval:
                    _getHorizontalInterval(
                      maxY,
                    ),

                    getTitlesWidget:
                        (value, meta) {
                      return Text(
                        _formatChartNumber(
                          value,
                        ),

                        style: TextStyle(
                          fontSize: 10,
                          color:
                          Colors.grey.shade500,
                          fontWeight:
                          FontWeight.w500,
                        ),
                      );
                    },
                  ),
                ),

                rightTitles:
                const AxisTitles(
                  sideTitles:
                  SideTitles(
                    showTitles: false,
                  ),
                ),

                topTitles:
                const AxisTitles(
                  sideTitles:
                  SideTitles(
                    showTitles: false,
                  ),
                ),

                bottomTitles:
                AxisTitles(
                  sideTitles:
                  SideTitles(
                    showTitles: true,

                    reservedSize: 30,

                    interval: 1,

                    getTitlesWidget:
                        (value, meta) {
                      final days =
                      _getLastSevenDays();

                      final index =
                      value.toInt();

                      if (index < 0 ||
                          index >=
                              days.length) {
                        return const SizedBox.shrink();
                      }

                      return Padding(
                        padding:
                        const EdgeInsets.only(
                          top: 8,
                        ),

                        child: Text(
                          days[index],

                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight:
                            FontWeight.w600,
                            color:
                            Colors.grey.shade500,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              lineTouchData:
              LineTouchData(
                enabled: true,

                touchTooltipData:
                LineTouchTooltipData(
                  getTooltipColor:
                      (_) => const Color(
                    0xff1E1446,
                  ),

                  tooltipRoundedRadius: 10,

                  getTooltipItems:
                      (touchedSpots) {
                    return touchedSpots
                        .map(
                          (spot) {
                        return LineTooltipItem(
                          '${_formatMoney(spot.y)} EGP',

                          const TextStyle(
                            color: Colors.white,
                            fontWeight:
                            FontWeight.w700,
                            fontSize: 12,
                          ),
                        );
                      },
                    )
                        .toList();
                  },
                ),
              ),

              lineBarsData: [
                LineChartBarData(
                  spots: spots,

                  isCurved: true,

                  curveSmoothness: 0.35,

                  color:
                  AppColors.secondary,

                  barWidth: 3,

                  isStrokeCapRound: true,

                  belowBarData:
                  BarAreaData(
                    show: true,

                    gradient:
                    LinearGradient(
                      begin:
                      Alignment.topCenter,

                      end:
                      Alignment.bottomCenter,

                      colors: [
                        AppColors.secondary
                            .withValues(
                          alpha: 0.20,
                        ),

                        AppColors.secondary
                            .withValues(
                          alpha: 0.0,
                        ),
                      ],
                    ),
                  ),

                  dotData:
                  FlDotData(
                    show: true,

                    getDotPainter:
                        (
                        spot,
                        percent,
                        bar,
                        index,
                        ) =>
                        FlDotCirclePainter(
                          radius: 4,

                          color:
                          Colors.white,

                          strokeWidth: 2.5,

                          strokeColor:
                          AppColors.secondary,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

// ============================================================
// RECENT BOOKINGS
// ============================================================

  Widget _buildRecentBookings(
      BuildContext context,
      LanguageProvider languageProvider,
      OwnerDashboardProvider dashboard,
      ) {
    final bookings =
    dashboard.bookings.take(4).toList();

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                languageProvider.translate(
                  'bookings',
                ),

                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff1E1446),
                ),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const OwnerBookingsScreen(),
                  ),
                );
              },

              child: Text(
                languageProvider.translate(
                  'view_all',
                ),

                style: TextStyle(
                  color: AppColors.secondary,
                  fontWeight:
                  FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        if (bookings.isEmpty)
          _buildEmptyCard(
            icon:
            Icons.calendar_month_rounded,

            text:
            languageProvider.translate(
              'no_bookings',
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white,

              borderRadius:
              BorderRadius.circular(20),

              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withValues(alpha: 0.035),

                  blurRadius: 12,

                  offset:
                  const Offset(0, 5),
                ),
              ],
            ),

            child: Column(
              children: [
                for (int i = 0;
                i < bookings.length;
                i++) ...[
                  _bookingTile(
                    bookings[i],
                  ),

                  if (i !=
                      bookings.length - 1)
                    Divider(
                      height: 1,
                      indent: 68,
                      endIndent: 16,
                      color:
                      Colors.grey.shade100,
                    ),
                ],
              ],
            ),
          ),
      ],
    );
  }

// ============================================================
// BOOKING TILE
// ============================================================

  Widget _bookingTile(
      Map<String, dynamic> booking,
      ) {
    final playerName =
        booking['player_name']?.toString() ??
            'Player';

    final pitchName =
        booking['pitch_name']?.toString() ??
            '';

    final status =
        booking['status']?.toString() ??
            '';

    final price =
    _toDouble(
      booking['total_price'],
    );

    final statusColor =
    _bookingStatusColor(
      status,
    );

    return Padding(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),

      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,

            decoration: BoxDecoration(
              color: statusColor
                  .withValues(alpha: 0.10),

              borderRadius:
              BorderRadius.circular(13),
            ),

            child: Icon(
              Icons.person_rounded,
              color: statusColor,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  playerName,

                  maxLines: 1,

                  overflow:
                  TextOverflow.ellipsis,

                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    Color(0xff1E1446),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  pitchName,

                  maxLines: 1,

                  overflow:
                  TextOverflow.ellipsis,

                  style: TextStyle(
                    fontSize: 11.5,
                    color:
                    Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment:
            CrossAxisAlignment.end,

            children: [
              Text(
                '${_formatMoney(price)} EGP',

                style: const TextStyle(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.w800,
                  color:
                  Color(0xff1E1446),
                ),
              ),

              const SizedBox(height: 4),

              Container(
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),

                decoration: BoxDecoration(
                  color: statusColor
                      .withValues(alpha: 0.10),

                  borderRadius:
                  BorderRadius.circular(8),
                ),

                child: Text(
                  _formatBookingStatus(
                    status,
                  ),

                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight:
                    FontWeight.w700,
                    color:
                    statusColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// ============================================================
// QUICK ACTIONS
// ============================================================

  Widget _buildQuickActions(
      BuildContext context,
      LanguageProvider languageProvider,
      ) {
    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,

      children: [
        Text(
          languageProvider.translate(
            'quick_actions',
          ),

          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xff1E1446),
          ),
        ),

        const SizedBox(height: 14),

        GridView.count(
          shrinkWrap: true,

          physics:
          const NeverScrollableScrollPhysics(),

          crossAxisCount: 2,

          crossAxisSpacing: 12,

          mainAxisSpacing: 12,

          childAspectRatio: 1.38,

          children: [
            actionCard(
              Icons.stadium_rounded,

              languageProvider.translate(
                'my_stadiums',
              ),

              const Color(0xff3B82F6),

                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const OwnerStadiumsScreen(),
                  ),
                );
              },
            ),

            actionCard(
              Icons.add_business_rounded,

              languageProvider.translate(
                'add_stadium',
              ),

              const Color(0xff8B5CF6),

                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const CreateStadiumScreen(),
                  ),
                );
              },
            ),

            actionCard(
              Icons.calendar_month_rounded,

              languageProvider.translate(
                'bookings',
              ),

              const Color(0xff06B6D4),

                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const OwnerBookingsScreen(),
                  ),
                );
              },
            ),

            actionCard(
              Icons.payments_rounded,

              languageProvider.translate(
                'payments',
              ),

              const Color(0xff22C55E),

                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const OwnerPaymentsScreen(),
                  ),
                );
              },
            ),

            actionCard(
              Icons.receipt_long_rounded,

              'Competition Payments',

              const Color(0xffEC4899),

                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const CompetitionPaymentsScreen(),
                  ),
                );
              },
            ),

            actionCard(
              Icons.bar_chart_rounded,

              languageProvider.translate(
                'revenue',
              ),

              const Color(0xff10B981),

                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const RevenueScreen(),
                  ),
                );
              },
            ),

            actionCard(
              Icons.star_rounded,

              languageProvider.translate(
                'reviews',
              ),

              const Color(0xffF59E0B),

                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const ReviewsScreen(),
                  ),
                );
              },
            ),

            actionCard(
              Icons.school_rounded,

              languageProvider.translate(
                'academy',
              ),

              const Color(0xffF97316),

                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const AcademyDashboardScreen(),
                  ),
                );
              },
            ),

            actionCard(
              Icons.emoji_events_rounded,

              languageProvider.translate(
                'competitions',
              ),

              const Color(0xffEF4444),

                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                    const CompetitionsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

// ============================================================
// STAT CARD
// ============================================================
//
// FIX (2026-08-29):
// Container below only enforced a `minHeight` (no `maxHeight`),
// so its height was unbounded once nested inside
// Row -> Column -> SingleChildScrollView on the dashboard body.
// The Column here had `Spacer()` widgets (Expanded with flex),
// which throws "RenderFlex children have non-zero flex but
// incoming height constraints are unbounded" inside an
// unbounded-height parent. That exception during layout was
// taking down the whole scroll view, which is why the entire
// Dashboard rendered blank.
//
// Fix: set `mainAxisSize: MainAxisSize.min` on the Column and
// replace the vertical `Spacer()` with a fixed `SizedBox`. The
// horizontal `Spacer()` inside the Row is safe (Row width is
// bounded by the Expanded from the caller) but was swapped for
// an `Expanded(child: SizedBox())` for clarity/consistency.
// ============================================================

  Widget statCard(
      String title,
      String value,
      String subtitle,
      Color color,
      IconData icon,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,

      borderRadius:
      BorderRadius.circular(19),

      child: Container(
        constraints:
        const BoxConstraints(
          minHeight: 145,
        ),

        padding:
        const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(19),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.045),

              blurRadius: 10,

              offset:
              const Offset(0, 4),
            ),
          ],
        ),

        child: Column(
// FIX: without this, the Column tries to fill the
// unbounded height coming from the parent scroll view,
// and the Spacer() below crashes the whole layout.
          mainAxisSize: MainAxisSize.min,

          crossAxisAlignment:
          CrossAxisAlignment.start,

          children: [
            Row(
              children: [
                Container(
                  padding:
                  const EdgeInsets.all(9),

                  decoration:
                  BoxDecoration(
                    color: color.withValues(
                      alpha: 0.10,
                    ),

                    borderRadius:
                    BorderRadius.circular(
                      11,
                    ),
                  ),

                  child: Icon(
                    icon,
                    color: color,
                    size: 20,
                  ),
                ),

// Safe: Row's width is bounded by the Expanded
// in _buildStatistics, so a flexible child here
// is fine.
                const Expanded(child: SizedBox()),

                Icon(
                  Icons
                      .arrow_forward_ios_rounded,
                  size: 12,
                  color:
                  Colors.grey.shade300,
                ),
              ],
            ),

// FIX: replaced `const Spacer()` (unsafe with
// unbounded height) with a fixed gap.
            const SizedBox(height: 18),

            Text(
              title,

              maxLines: 1,

              overflow:
              TextOverflow.ellipsis,

              style: TextStyle(
                color:
                Colors.grey.shade500,
                fontSize: 11.5,
                fontWeight:
                FontWeight.w600,
              ),
            ),

            const SizedBox(height: 4),

            FittedBox(
              fit:
              BoxFit.scaleDown,

              alignment:
              Alignment.centerLeft,

              child: Text(
                value,

                style: TextStyle(
                  fontWeight:
                  FontWeight.w800,
                  fontSize: 21,
                  letterSpacing: -0.4,
                  color: color,
                ),
              ),
            ),

            const SizedBox(height: 3),

            Text(
              subtitle,

              maxLines: 1,

              overflow:
              TextOverflow.ellipsis,

              style: TextStyle(
                color:
                Colors.grey.shade500,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

// ============================================================
// ACTION CARD
// ============================================================

  Widget actionCard(
      IconData icon,
      String title,
      Color color,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,

      borderRadius:
      BorderRadius.circular(18),

      child: Container(
        padding:
        const EdgeInsets.all(14),

        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius:
          BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.black
                  .withValues(alpha: 0.035),

              blurRadius: 9,

              offset:
              const Offset(0, 3),
            ),
          ],
        ),

        child: Row(
          children: [
            Container(
              padding:
              const EdgeInsets.all(10),

              decoration:
              BoxDecoration(
                color: color.withValues(
                  alpha: 0.10,
                ),

                borderRadius:
                BorderRadius.circular(13),
              ),

              child: Icon(
                icon,
                size: 23,
                color: color,
              ),
            ),

            const SizedBox(width: 11),

            Expanded(
              child: Text(
                title,

                maxLines: 2,

                overflow:
                TextOverflow.ellipsis,

                style: const TextStyle(
                  fontWeight:
                  FontWeight.w700,
                  fontSize: 12,
                  color:
                  Color(0xff1E1446),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

// ============================================================
// EMPTY CARD
// ============================================================

  Widget _buildEmptyCard({
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.symmetric(
        vertical: 28,
        horizontal: 20,
      ),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius:
        BorderRadius.circular(20),

        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withValues(alpha: 0.03),

            blurRadius: 10,

            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        children: [
          Icon(
            icon,
            size: 32,
            color: Colors.grey.shade300,
          ),

          const SizedBox(height: 9),

          Text(
            text,

            textAlign:
            TextAlign.center,

            style: TextStyle(
              color:
              Colors.grey.shade500,
              fontSize: 12,
              fontWeight:
              FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

// ============================================================
// ERROR STATE
// ============================================================

  Widget _buildErrorState(
      BuildContext context,
      LanguageProvider languageProvider,
      OwnerDashboardProvider dashboard,
      ) {
    return SingleChildScrollView(
      physics:
      const AlwaysScrollableScrollPhysics(),

      child: SizedBox(
        height: 650,

        child: Center(
          child: Padding(
            padding:
            const EdgeInsets.all(24),

            child: Column(
              mainAxisSize:
              MainAxisSize.min,

              children: [
                Container(
                  padding:
                  const EdgeInsets.all(18),

                  decoration: BoxDecoration(
                    color: Colors.red
                        .withValues(alpha: 0.08),

                    shape:
                    BoxShape.circle,
                  ),

                  child: const Icon(
                    Icons.cloud_off_rounded,
                    color: Colors.redAccent,
                    size: 34,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Unable to load dashboard',
                  textAlign:
                  TextAlign.center,

                  style: TextStyle(
                    fontWeight:
                    FontWeight.w800,
                    fontSize: 17,
                    color:
                    Color(0xff1E1446),
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  dashboard.errorMessage ??
                      'Something went wrong',

                  textAlign:
                  TextAlign.center,

                  style: TextStyle(
                    color:
                    Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 18),

                ElevatedButton(
                  onPressed:
                  dashboard.loadDashboard,

                  style:
                  ElevatedButton.styleFrom(
                    backgroundColor:
                    AppColors.secondary,

                    foregroundColor:
                    Colors.white,

                    elevation: 0,

                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),

                    shape:
                    RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(
                        12,
                      ),
                    ),
                  ),

                  child: const Text(
                    'Try Again',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// ============================================================
// SMALL ERROR
// ============================================================

  Widget _buildSmallError(
      String message,
      ) {
    return Container(
      width: double.infinity,

      padding:
      const EdgeInsets.all(12),

      decoration: BoxDecoration(
        color: Colors.red
            .withValues(alpha: 0.06),

        borderRadius:
        BorderRadius.circular(12),

        border: Border.all(
          color: Colors.red
              .withValues(alpha: 0.10),
        ),
      ),

      child: Row(
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Colors.redAccent,
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Text(
              message,

              style: const TextStyle(
                color: Colors.redAccent,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

// ============================================================
// BOTTOM NAVIGATION
// ============================================================

  Widget _buildBottomNavigation(
      BuildContext context,
      LanguageProvider languageProvider,
      ) {
    return BottomNavigationBar(
      currentIndex:
      selectedIndex,

      selectedItemColor:
      AppColors.secondary,

      unselectedItemColor:
      Colors.grey.shade400,

      showUnselectedLabels:
      true,

      type:
      BottomNavigationBarType.fixed,

      elevation: 12,

      selectedLabelStyle:
      const TextStyle(
        fontSize: 11.5,
        fontWeight:
        FontWeight.w700,
      ),

      unselectedLabelStyle:
      const TextStyle(
        fontSize: 11.5,
      ),

      onTap: (index) {
        setState(() {
          selectedIndex =
              index;
        });

        switch (index) {
          case 0:
            break;

          case 1:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const OwnerBookingsScreen(),
              ),
            );
            break;

          case 2:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const OwnerStadiumsScreen(),
              ),
            );
            break;

          case 3:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const RevenueScreen(),
              ),
            );
            break;

          case 4:
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                const OwnerProfileScreen(),
              ),
            );
            break;
        }
      },

      items: [
        BottomNavigationBarItem(
          icon: const Icon(
            Icons.dashboard_rounded,
          ),

          label:
          languageProvider.translate(
            'dashboard',
          ),
        ),

        BottomNavigationBarItem(
          icon: const Icon(
            Icons.calendar_month_rounded,
          ),

          label:
          languageProvider.translate(
            'bookings',
          ),
        ),

        BottomNavigationBarItem(
          icon: const Icon(
            Icons.stadium_rounded,
          ),

          label:
          languageProvider.translate(
            'stadiums',
          ),
        ),

        BottomNavigationBarItem(
          icon: const Icon(
            Icons.bar_chart_rounded,
          ),

          label:
          languageProvider.translate(
            'revenue',
          ),
        ),

        BottomNavigationBarItem(
          icon: const Icon(
            Icons.person_rounded,
          ),

          label:
          languageProvider.translate(
            'profile',
          ),
        ),
      ],
    );
  }

// ============================================================
// STAGGERED ANIMATION
// ============================================================

  Widget _staggered(
      int index,
      Widget child,
      ) {
    final delay =
        index * 70;

    return TweenAnimationBuilder<double>(
      tween:
      Tween(
        begin: 0,
        end: 1,
      ),

      duration:
      Duration(
        milliseconds:
        420 + delay,
      ),

      curve:
      Curves.easeOutCubic,

      builder:
          (context, value, _) {
        return Opacity(
          opacity:
          value.clamp(0, 1),

          child:
          Transform.translate(
            offset:
            Offset(
              0,
              (1 - value) * 14,
            ),

            child: child,
          ),
        );
      },
    );
  }

// ============================================================
// REAL REVENUE DATA
// ============================================================

  List<FlSpot> _buildRevenueSpots(
      OwnerDashboardProvider dashboard,
      ) {
    final now =
    DateTime.now();

    final days =
    List.generate(
      7,
          (index) {
        final date =
        DateTime(
          now.year,
          now.month,
          now.day,
        ).subtract(
          Duration(
            days: 6 - index,
          ),
        );

        return date;
      },
    );

    final values =
    List<double>.filled(
      7,
      0,
    );

    for (final payment
    in dashboard.payments) {
      final status =
      payment['status']
          ?.toString()
          .toLowerCase();

// Backend uses "paid" for approved payments.
      if (status != 'paid') {
        continue;
      }

      final rawDate =
      payment['created_at'];

      if (rawDate == null) {
        continue;
      }

      final date =
      DateTime.tryParse(
        rawDate.toString(),
      );

      if (date == null) {
        continue;
      }

      final paymentDay =
      DateTime(
        date.year,
        date.month,
        date.day,
      );

      for (int i = 0;
      i < days.length;
      i++) {
        if (_sameDay(
          paymentDay,
          days[i],
        )) {
          values[i] +=
              _toDouble(
                payment['amount'],
              );

          break;
        }
      }
    }

    return List.generate(
      7,
          (index) => FlSpot(
        index.toDouble(),
        values[index],
      ),
    );
  }

// ============================================================
// LAST 7 DAYS LABELS
// ============================================================

  List<String> _getLastSevenDays() {
    final now =
    DateTime.now();

    final result =
    <String>[];

    for (int i = 6;
    i >= 0;
    i--) {
      final date =
      DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(
        Duration(
          days: i,
        ),
      );

      result.add(
        _dayShortName(
          date.weekday,
        ),
      );
    }

    return result;
  }

// ============================================================
// WEEK DAY
// ============================================================

  String _dayShortName(
      int weekday,
      ) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';

      case DateTime.tuesday:
        return 'Tue';

      case DateTime.wednesday:
        return 'Wed';

      case DateTime.thursday:
        return 'Thu';

      case DateTime.friday:
        return 'Fri';

      case DateTime.saturday:
        return 'Sat';

      case DateTime.sunday:
        return 'Sun';

      default:
        return '';
    }
  }

// ============================================================
// MAX CHART VALUE
// ============================================================

  double _getMaxRevenue(
      List<FlSpot> spots,
      ) {
    double max =
    0;

    for (final spot in spots) {
      if (spot.y > max) {
        max = spot.y;
      }
    }

    if (max <= 0) {
      return 100;
    }

    final rounded =
        ((max * 1.25) / 100).ceil() * 100;

    return rounded
        .toDouble();
  }

// ============================================================
// CHART INTERVAL
// ============================================================

  double _getHorizontalInterval(
      double maxY,
      ) {
    if (maxY <= 100) {
      return 20;
    }

    if (maxY <= 500) {
      return 100;
    }

    if (maxY <= 1000) {
      return 200;
    }

    if (maxY <= 5000) {
      return 1000;
    }

    if (maxY <= 10000) {
      return 2000;
    }

    return maxY / 5;
  }

// ============================================================
// PAID PAYMENTS COUNT
// ============================================================

  int _paidPaymentsCount(
      OwnerDashboardProvider dashboard,
      ) {
    return dashboard.payments.where(
          (payment) {
        return payment['status']
            ?.toString()
            .toLowerCase() ==
            'paid';
      },
    ).length;
  }

// ============================================================
// BOOKING STATUS COLOR
// ============================================================

  Color _bookingStatusColor(
      String status,
      ) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return const Color(
          0xff22C55E,
        );

      case 'pending':
        return const Color(
          0xffF59E0B,
        );

      case 'rejected':
        return const Color(
          0xffEF4444,
        );

      case 'cancelled':
        return const Color(
          0xff6B7280,
        );

      default:
        return const Color(
          0xff3B82F6,
        );
    }
  }

// ============================================================
// BOOKING STATUS TEXT
// ============================================================

  String _formatBookingStatus(
      String status,
      ) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';

      case 'pending':
        return 'Pending';

      case 'rejected':
        return 'Rejected';

      case 'cancelled':
        return 'Cancelled';

      default:
        return status.isEmpty
            ? 'Unknown'
            : status;
    }
  }

// ============================================================
// SAME DAY
// ============================================================

  bool _sameDay(
      DateTime first,
      DateTime second,
      ) {
    return first.year ==
        second.year &&
        first.month ==
            second.month &&
        first.day ==
            second.day;
  }

// ============================================================
// DOUBLE
// ============================================================

  double _toDouble(
      dynamic value,
      ) {
    if (value == null) {
      return 0;
    }

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
      value.toString(),
    ) ??
        0;
  }

// ============================================================
// MONEY
// ============================================================

  String _formatMoney(
      double value,
      ) {
    if (value == value.roundToDouble()) {
      return value
          .toInt()
          .toString();
    }

    return value
        .toStringAsFixed(2);
  }

// ============================================================
// CHART NUMBER
// ============================================================

  String _formatChartNumber(
      double value,
      ) {
    if (value >= 1000) {
      final number =
          value / 1000;

      if (number ==
          number.roundToDouble()) {
        return '${number.toInt()}K';
      }

      return '${number.toStringAsFixed(1)}K';
    }

    return value
        .toInt()
        .toString();
  }
}