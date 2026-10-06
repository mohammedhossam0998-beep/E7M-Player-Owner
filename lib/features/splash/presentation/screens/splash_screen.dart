import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/startup_service.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final StartupService _startupService;

  @override
  void initState() {
    super.initState();

    _startupService = StartupService();

    _initializeAnimation();

    // Start navigation without blocking build.
    unawaited(_navigate());
  }

  // ============================================================
  // ANIMATION
  // ============================================================

  void _initializeAnimation() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1200,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  // ============================================================
  // NAVIGATION
  // ============================================================

  Future<void> _navigate() async {
    // ----------------------------------------------------------
    // Splash display duration
    // ----------------------------------------------------------

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    // ----------------------------------------------------------
    // RESTORE AUTH SESSION
    // ----------------------------------------------------------

    final authController =
    context.read<AuthController>();

    final hasToken =
    await authController.loadSavedToken();

    if (!mounted) return;

    // ----------------------------------------------------------
    // NO SAVED SESSION
    // ----------------------------------------------------------

    if (!hasToken) {
      final route =
      await _startupService.getInitialRoute();

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        route,
      );

      return;
    }

    // ----------------------------------------------------------
    // LOAD CURRENT USER
    // ----------------------------------------------------------

    final meLoaded =
    await authController.getMe();

    if (!mounted) return;

    // ----------------------------------------------------------
    // INVALID / EXPIRED SESSION
    // ----------------------------------------------------------

    if (!meLoaded ||
        authController.user == null) {
      final route =
      await _startupService.getInitialRoute();

      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        route,
      );

      return;
    }

    // ----------------------------------------------------------
    // DETERMINE USER ROLE
    // ----------------------------------------------------------

    final role = authController.user!['role']
        ?.toString()
        .toLowerCase();

    // ----------------------------------------------------------
    // NAVIGATE BY ROLE
    // ----------------------------------------------------------

    final String route;

    if (role == 'owner') {
      route = '/owner-dashboard';
    } else if (role == 'player') {
      route = '/home';
    } else {
      route = '/welcome';
    }

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      route,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // ============================================================
  // UI
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      width: 150,
                      height: 150,
                      semanticLabel: 'E7M Logo',
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'E7gzly Ml3b',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff145A32),
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'BEYOND THE GAME',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xff7CC000),
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),

              // ------------------------------------------------
              // BRANDING FOOTER
              // ------------------------------------------------
              Positioned(
                left: 0,
                right: 0,
                bottom: 56,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Image(
                      image: AssetImage(
                        'assets/images/selvera_logo.png',
                      ),
                      width: 58,
                      height: 58,
                      semanticLabel: 'Selvera Logo',
                    ),

                    SizedBox(height: 8),

                    Text(
                      'E7M with Selvera',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color(0xff145A32),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}