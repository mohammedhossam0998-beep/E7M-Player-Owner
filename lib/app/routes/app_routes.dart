import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ============================================================
// CORE / APP FLOW
// ============================================================

import 'package:e7m/features/splash/presentation/screens/splash_screen.dart';
import 'package:e7m/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:e7m/features/onboarding/presentation/screens/language_screen.dart';
import 'package:e7m/welcome_screen.dart';

// ============================================================
// AUTH
// ============================================================

import 'package:e7m/features/auth/presentation/screens/login/login_screen.dart';
import 'package:e7m/features/auth/presentation/screens/register/register_screen.dart';

// ============================================================
// PLAYER
// ============================================================

import 'package:e7m/features/player/home/home_screen.dart';
import 'package:e7m/features/player/booking/my_bookings_screen.dart';
import 'package:e7m/features/player/booking/providers/booking_provider.dart';
import 'package:e7m/features/player/booking/booking_details_screen.dart';
import 'package:e7m/features/player/notifications/presentation/screens/notifications_screen.dart';
import 'package:e7m/features/player/profile/presentation/screens/profile_screen.dart';

// ============================================================
// OWNER
// ============================================================

import 'package:e7m/features/owner/dashboard/owner_dashboard_screen.dart';

// ============================================================
// ROUTE NAMES
// ============================================================

import 'route_names.dart';

class AppRouter {
  AppRouter._();

  // ==========================================================
  // GENERATE ROUTE
  // ==========================================================

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
    // --------------------------------------------------------
    // SPLASH
    // --------------------------------------------------------

      case RouteNames.splash:
        return _page(
          const SplashScreen(),
        );

    // --------------------------------------------------------
    // ONBOARDING
    // --------------------------------------------------------

      case RouteNames.onboarding:
        return _page(
          const OnboardingScreen(),
        );

    // --------------------------------------------------------
    // LANGUAGE
    // --------------------------------------------------------

      case RouteNames.language:
        return _page(
          const LanguageScreen(),
        );

    // --------------------------------------------------------
    // WELCOME
    // --------------------------------------------------------

      case RouteNames.welcome:
        return _page(
          const WelcomeScreen(),
        );

    // --------------------------------------------------------
    // LOGIN
    // --------------------------------------------------------

      case RouteNames.login:
        return _page(
          const LoginScreen(),
        );

    // --------------------------------------------------------
    // REGISTER
    // --------------------------------------------------------

      case RouteNames.register:
        return _page(
          const RegisterScreen(),
        );

    // --------------------------------------------------------
    // PLAYER HOME
    // --------------------------------------------------------

      case RouteNames.home:
        return _page(
          const HomeScreen(),
        );

    // --------------------------------------------------------
    // PLAYER BOOKINGS
    // --------------------------------------------------------

      case RouteNames.myBookings:
        return _page(
          const MyBookingsScreen(),
        );

    // --------------------------------------------------------
    // PLAYER BOOKING DETAILS
    // --------------------------------------------------------

      case RouteNames.bookingDetails:
        final arguments = settings.arguments;

        final bookingId = arguments is int
            ? arguments
            : int.tryParse(arguments?.toString() ?? '');

        if (bookingId == null) {
          return _page(
            const Scaffold(
              body: Center(
                child: Text(
                  'Invalid booking ID',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return _page(
          _BookingDetailsLoader(
            bookingId: bookingId,
          ),
        );

    // --------------------------------------------------------
    // PLAYER NOTIFICATIONS
    // --------------------------------------------------------

      case RouteNames.notifications:
        return _page(
          const NotificationsScreen(),
        );

    // --------------------------------------------------------
    // PLAYER PROFILE
    // --------------------------------------------------------

      case RouteNames.profile:
        return _page(
          const ProfileScreen(),
        );

    // --------------------------------------------------------
    // OWNER DASHBOARD
    // --------------------------------------------------------

      case RouteNames.ownerDashboard:
        return _page(
          const OwnerDashboardScreen(),
        );

    // --------------------------------------------------------
    // UNKNOWN ROUTE
    // --------------------------------------------------------

      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text(
                '404\nPage Not Found',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
    }
  }

  // ==========================================================
  // PAGE BUILDER
  // ==========================================================

  static MaterialPageRoute _page(Widget page) {
    return MaterialPageRoute(
      builder: (_) => page,
    );
  }
}

// ============================================================
// BOOKING DETAILS LOADER
// ============================================================

class _BookingDetailsLoader extends StatefulWidget {
  final int bookingId;

  const _BookingDetailsLoader({
    required this.bookingId,
  });

  @override
  State<_BookingDetailsLoader> createState() =>
      _BookingDetailsLoaderState();
}

class _BookingDetailsLoaderState
    extends State<_BookingDetailsLoader> {

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBooking();
    });
  }

  Future<void> _loadBooking() async {
    final provider = context.read<BookingProvider>();

    final booking =
    await provider.fetchBookingDetails(widget.bookingId);

    if (!mounted) return;

    if (booking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.errorMessage ??
                'Failed to load booking details',
          ),
        ),
      );

      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => BookingDetailsScreen(
          booking: booking,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}