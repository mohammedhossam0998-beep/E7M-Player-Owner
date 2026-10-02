import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// ============================================================
// APP FLOW
// ============================================================

import 'package:e7m/features/splash/presentation/screens/splash_screen.dart';
import 'package:e7m/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:e7m/features/onboarding/presentation/screens/language_screen.dart';
import 'package:e7m/welcome_screen.dart';

import 'package:e7m/app/routes/app_routes.dart';

// ============================================================
// AUTH
// ============================================================

import 'package:e7m/features/auth/presentation/controllers/auth_controller.dart';

// ============================================================
// OWNER ACADEMY
// ============================================================

import 'package:e7m/features/owner/academy/controller/academy_controller.dart';
import 'package:e7m/features/owner/academy/repository/academy_repository_impl.dart';
import 'package:e7m/features/owner/academy/services/academy_service.dart';

import 'package:e7m/features/owner/academy/controller/program_controller.dart';
import 'package:e7m/features/owner/academy/repository/program_repository_impl.dart';
import 'package:e7m/features/owner/academy/services/program_service.dart';

import 'package:e7m/features/owner/academy/controller/schedule_controller.dart';
import 'package:e7m/features/owner/academy/repository/schedule_repository_impl.dart';
import 'package:e7m/features/owner/academy/services/schedule_service.dart';

import 'package:e7m/features/owner/academy/controller/academy_coach_controller.dart';
import 'package:e7m/features/owner/academy/repository/academy_coach_repository_impl.dart';
import 'package:e7m/features/owner/academy/services/academy_coach_service.dart';

import 'package:e7m/features/owner/academy/controller/enrollment_controller.dart';
import 'package:e7m/features/owner/academy/repository/enrollment_repository_impl.dart';
import 'package:e7m/features/owner/academy/services/enrollment_service.dart';

// ============================================================
// OWNER STADIUM
// ============================================================

import 'package:e7m/features/owner/stadium/presentation/providers/stadium_provider.dart';
import 'package:e7m/features/owner/availability/data/providers/slot_provider.dart';
import 'package:e7m/features/owner/availability/data/providers/availability_provider.dart';

// ============================================================
// PLAYER STADIUM
// ============================================================

import 'package:e7m/features/player/stadium/presentation/providers/stadium_provider.dart'
as player_stadium;
import 'package:e7m/features/player/stadium/presentation/screens/stadiums_screen.dart';

import 'package:e7m/features/player/reviews/presentation/providers/review_provider.dart'
as player_review;

// ============================================================
// PLAYER PROFILE
// ============================================================

import 'package:e7m/features/player/profile/presentation/providers/player_profile_provider.dart';

// ============================================================
// PLAYER TEAMS
// ============================================================

import 'package:e7m/features/player/teams/presentation/providers/team_provider.dart';
import 'package:e7m/features/player/teams/presentation/screens/teams_near_you_screen.dart';
import 'package:e7m/features/player/teams/presentation/screens/team_details_screen.dart';
import 'package:e7m/features/player/teams/presentation/screens/my_teams_screen.dart';
import 'package:e7m/features/player/teams/presentation/screens/team_requests_screen.dart';
import 'package:e7m/features/player/teams/presentation/screens/team_chat_screen.dart';

// ============================================================
// OWNER PAYMENTS
// ============================================================

import 'package:e7m/features/owner/payout/providers/owner_payment_provider.dart';

// ============================================================
// OWNER REVENUE
// ============================================================

import 'package:e7m/features/owner/revenue/providers/revenue_provider.dart';

// ============================================================
// OWNER NOTIFICATIONS
// ============================================================

import 'package:e7m/features/owner/notifications/providers/notification_provider.dart';

// ============================================================
// OWNER SUPPORT
// ============================================================

import 'package:e7m/features/owner/support/providers/support_provider.dart';

// ============================================================
// OWNER PROFILE
// ============================================================

import 'package:e7m/features/owner/profile/providers/owner_profile_provider.dart';
import 'package:e7m/features/owner/dashboard/presentation/providers/owner_dashboard_provider.dart';

// ============================================================
// OWNER REVIEWS
// ============================================================

import 'package:e7m/features/owner/reviews/presentation/providers/owner_review_provider.dart';

// ============================================================
// LOCALIZATION
// ============================================================

import 'package:e7m/shared/localization/language_provider.dart';

// ============================================================
// PLAYER ACADEMY
// ============================================================

import 'package:e7m/features/player/academy/presentation/providers/academy_provider.dart';

// ============================================================
// PLAYER BOOKING
// ============================================================

import 'package:e7m/features/player/booking/providers/booking_provider.dart';

// ============================================================
// PLAYER HELP & SUPPORT
// ============================================================

import 'package:e7m/features/player/settings/presentation/providers/help_support_provider.dart';

// ============================================================
// PLAYER PAYMENTS
// ============================================================

import 'package:e7m/features/player/payments/providers/payment_provider.dart';

// ============================================================
// PLAYER NOTIFICATIONS
// ============================================================

import 'package:e7m/features/player/notifications/providers/notification_provider.dart'
as player_notification;
import 'package:e7m/core/notifications/fcm_service.dart';
import 'package:e7m/features/player/notifications/providers/notification_settings_provider.dart';

// ============================================================
// OWNER COMPETITIONS
// ============================================================

import 'package:e7m/features/owner/competitions/data/services/competition_service.dart';
import 'package:e7m/features/owner/competitions/data/repositories/competition_repository.dart';
import 'package:e7m/features/owner/competitions/presentation/providers/competition_provider.dart';

// ============================================================
// PLAYER COMPETITIONS
// ============================================================

import 'package:e7m/features/player/competitions/providers/competition_provider.dart'
as player_competition;

import 'package:e7m/core/network/api_client.dart';

// ============================================================
// AI
// ============================================================

import 'package:e7m/features/ai/config/dependency_injection.dart';
import 'package:e7m/features/ai/presentation/controllers/ai_chat_controller.dart';
import 'package:e7m/features/ai/presentation/providers/ai_provider.dart';
import 'package:e7m/features/ai/domain/usecases/send_ai_message_usecase.dart';
import 'package:e7m/features/ai/domain/usecases/stream_ai_message_usecase.dart';

// ============================================================
// MAIN
// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ==========================================================
  // FIREBASE
  // ==========================================================

  if (!kIsWeb) {
    await Firebase.initializeApp();
    await FCMService.initialize();

    debugPrint('🚀 FCM INITIALIZATION FINISHED');
  }

  // ==========================================================
  // LANGUAGE
  // ==========================================================

  final languageProvider = LanguageProvider();

  await languageProvider.loadLanguage();

  // ==========================================================
  // AI
  // ==========================================================

  await AIDependencyInjection.initialize();

  // ==========================================================
  // RUN APP
  // ==========================================================

  runApp(
    MultiProvider(
      providers: [
        // ======================================================
        // LANGUAGE
        // ======================================================

        ChangeNotifierProvider<LanguageProvider>(
          create: (_) => languageProvider,
        ),

        // ======================================================
        // AUTH
        // ======================================================

        ChangeNotifierProvider<AuthController>(
          create: (_) => AuthController()..loadSavedToken(),
        ),

        // ======================================================
        // PLAYER PROFILE
        // ======================================================

        ChangeNotifierProvider<PlayerProfileProvider>(
          create: (_) => PlayerProfileProvider(),
        ),

        // ======================================================
        // PLAYER TEAMS
        // ======================================================

        ChangeNotifierProvider<TeamProvider>(
          create: (_) => TeamProvider(),
        ),

        // ======================================================
        // OWNER ACADEMY
        // ======================================================

        ChangeNotifierProvider<AcademyController>(
          create: (_) => AcademyController(
            repository: AcademyRepositoryImpl(
              service: AcademyService(),
            ),
          ),
        ),

        // ======================================================
        // OWNER ACADEMY - PROGRAMS
        // ======================================================

        ChangeNotifierProvider<ProgramController>(
          create: (_) => ProgramController(
            repository: ProgramRepositoryImpl(
              service: ProgramService(),
            ),
          ),
        ),

        // ======================================================
        // OWNER ACADEMY - SCHEDULE
        // ======================================================

        ChangeNotifierProvider<ScheduleController>(
          create: (_) => ScheduleController(
            repository: ScheduleRepositoryImpl(
              service: ScheduleService(),
            ),
          ),
        ),

        // ======================================================
        // OWNER ACADEMY - COACHES
        // ======================================================

        ChangeNotifierProvider<AcademyCoachController>(
          create: (_) => AcademyCoachController(
            repository: AcademyCoachRepositoryImpl(
              service: AcademyCoachService(),
            ),
          ),
        ),

        // ======================================================
        // OWNER ACADEMY - ENROLLMENTS
        // ======================================================

        ChangeNotifierProvider<EnrollmentController>(
          create: (_) => EnrollmentController(
            repository: EnrollmentRepositoryImpl(
              service: EnrollmentService(),
            ),
          ),
        ),

        // ======================================================
        // OWNER STADIUM
        // ======================================================

        ChangeNotifierProvider<StadiumProvider>(
          create: (_) => StadiumProvider(),
        ),

        ChangeNotifierProvider<SlotProvider>(
          create: (_) => SlotProvider(),
        ),

        ChangeNotifierProvider<AvailabilityProvider>(
          create: (_) => AvailabilityProvider(),
        ),

        // ======================================================
        // OWNER PAYMENTS
        // ======================================================

        ChangeNotifierProvider<OwnerPaymentProvider>(
          create: (_) => OwnerPaymentProvider(),
        ),

        // ======================================================
        // OWNER REVENUE
        // ======================================================

        ChangeNotifierProvider<RevenueProvider>(
          create: (_) => RevenueProvider(),
        ),

        // ======================================================
        // OWNER NOTIFICATIONS
        // ======================================================

        ChangeNotifierProvider<NotificationProvider>(
          create: (_) => NotificationProvider(),
        ),

        // ======================================================
        // OWNER SUPPORT
        // ======================================================

        ChangeNotifierProvider<SupportProvider>(
          create: (_) => SupportProvider(),
        ),

        // ======================================================
        // OWNER PROFILE
        // ======================================================

        ChangeNotifierProvider<OwnerProfileProvider>(
          create: (_) => OwnerProfileProvider(),
        ),

        ChangeNotifierProvider<OwnerDashboardProvider>(
          create: (_) => OwnerDashboardProvider(),
        ),

        // ======================================================
        // OWNER REVIEWS
        // ======================================================

        ChangeNotifierProvider<OwnerReviewProvider>(
          create: (_) => OwnerReviewProvider(),
        ),

        // ======================================================
        // PLAYER ACADEMY
        // ======================================================

        ChangeNotifierProvider<AcademyProvider>(
          create: (_) => AcademyProvider(),
        ),

        // ======================================================
        // PLAYER STADIUM
        // ======================================================

        ChangeNotifierProvider<player_stadium.StadiumProvider>(
          create: (_) => player_stadium.StadiumProvider(),
        ),

        ChangeNotifierProvider<player_review.ReviewProvider>(
          create: (_) => player_review.ReviewProvider(),
        ),

        // ======================================================
        // PLAYER BOOKING
        // ======================================================

        ChangeNotifierProvider<BookingProvider>(
          create: (_) => BookingProvider(),
        ),

        // ======================================================
        // PLAYER HELP & SUPPORT
        // ======================================================

        ChangeNotifierProvider<HelpSupportProvider>(
          create: (_) => HelpSupportProvider(),
        ),

        // ======================================================
        // PLAYER PAYMENTS
        // ======================================================

        ChangeNotifierProvider<PaymentProvider>(
          create: (_) => PaymentProvider(),
        ),

        // ======================================================
        // PLAYER NOTIFICATIONS
        // ======================================================

        ChangeNotifierProvider<
            player_notification.NotificationProvider>(
          create: (_) =>
              player_notification.NotificationProvider(),
        ),

        // ======================================================
        // ACADEMY FAVORITES
        // ======================================================

        // ======================================================
        // ACADEMY REVIEWS
        // ======================================================

        // ======================================================
        // OWNER COMPETITIONS
        // ======================================================

        ChangeNotifierProvider<CompetitionProvider>(
          create: (_) => CompetitionProvider(
            CompetitionRepository(
              CompetitionService(
                ApiClient(),
              ),
            ),
          ),
        ),

        // ======================================================
        // PLAYER COMPETITIONS
        // ======================================================

        ChangeNotifierProvider<
            player_competition.CompetitionProvider>(
          create: (_) =>
              player_competition.CompetitionProvider(),
        ),

        // ======================================================
        // AI
        // ======================================================

        ChangeNotifierProvider<AIProvider>(
          create: (_) => AIProvider(
            controller: AIChatController(
              sendAIMessageUseCase: SendAIMessageUseCase(
                AIDependencyInjection.repository,
              ),
              streamAIMessageUseCase: StreamAIMessageUseCase(
                AIDependencyInjection.repository,
              ),
            ),
          ),
        ),

        // ======================================================
        // COACH
        // ======================================================


        // ======================================================
        // NOTIFICATION SETTINGS
        // ======================================================

        ChangeNotifierProvider(
          create: (_) => NotificationSettingsProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// ============================================================
// APP
// ============================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageProvider = context.watch<LanguageProvider>();

    final locale = languageProvider.locale;

    final isArabic = locale.languageCode == 'ar';

    return MaterialApp(
      navigatorKey: FCMService.navigatorKey,
      debugShowCheckedModeBanner: false,

      // ========================================================
      // LOCALIZATION
      // ========================================================

      locale: locale,

      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],

      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ========================================================
      // TEXT DIRECTION
      // ========================================================

      builder: (context, child) {
        return Directionality(
          textDirection:
          isArabic ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },

      // ========================================================
      // ROUTES
      // ========================================================

      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/language': (_) => const LanguageScreen(),
        '/welcome': (_) => const WelcomeScreen(),

        // ======================================================
        // TEAMS
        // ======================================================

        '/teams': (_) => const TeamsNearYouScreen(),
        '/my-teams': (_) => const MyTeamsScreen(),

        // ======================================================
        // STADIUM
        // ======================================================

        '/stadiums': (_) => const StadiumsScreen(),

        // ======================================================
        // COACH
        // ======================================================

      },

      // ========================================================
      // DYNAMIC ROUTES
      // ========================================================

      onGenerateRoute: (settings) {
        // ------------------------------------------------------
        // COACH - BOOK SESSION
        // ------------------------------------------------------


        // ------------------------------------------------------
        // COACH - REVIEWS
        // ------------------------------------------------------


        // ------------------------------------------------------
        // TEAMS - DETAILS
        // ------------------------------------------------------

        if (settings.name == '/team-details') {
          final teamId = settings.arguments as int;

          return MaterialPageRoute(
            builder: (_) => TeamDetailsScreen(
              teamId: teamId,
            ),
          );
        }

        // ------------------------------------------------------
        // TEAMS - JOIN REQUESTS
        // ------------------------------------------------------

        if (settings.name == '/team-requests') {
          final args = settings.arguments as Map<String, dynamic>;

          return MaterialPageRoute(
            builder: (_) => TeamRequestsScreen(
              teamId: args['teamId'] as int,
              teamName: args['teamName'] as String?,
            ),
          );
        }

        // ------------------------------------------------------
        // TEAMS - CHAT
        // ------------------------------------------------------

        if (settings.name == '/team-chat') {
          final teamId = settings.arguments as int;

          return MaterialPageRoute(
            builder: (_) => TeamChatScreen(
              teamId: teamId,
            ),
          );
        }

        // ------------------------------------------------------
        // APP ROUTER
        // ------------------------------------------------------

        return AppRouter.generateRoute(settings);
      },

      // ========================================================
      // INITIAL SCREEN
      // ========================================================

      home: const SplashScreen(),
    );
  }
}